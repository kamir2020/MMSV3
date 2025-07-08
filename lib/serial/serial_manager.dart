import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';
import 'utils/converter.dart';
import 'utils/crc_calculator.dart';
import 'utils/parameter_helper.dart';

enum SerialConnectionState { disconnected, connecting, connected }

class SerialManager {
  UsbPort? _port;
  ValueNotifier<SerialConnectionState> connectionState = ValueNotifier(
    SerialConnectionState.disconnected,
  );
  String? connectedDeviceName;
  final StreamController<Map<String, double>> _dataStreamController =
  StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get dataStream => _dataStreamController.stream;

  int _runningCounter = 0;
  int _communicationLevel = 0;
  String? _parentAddress;
  String? _serialNumber;
  List<String> _parameterList = [];
  Timer? _dataRequestTimer;
  Timer? _responseTimeoutTimer;
  final StringBuffer _responseBuffer = StringBuffer();
  String? _lookupString;
  bool _isReading = false; // To prevent overlapping read cycles

  Future<List<UsbDevice>> getAvailableDevices() async {
    return UsbSerial.listDevices();
  }

  Future<void> connect(UsbDevice device) async {
    if (connectionState.value == SerialConnectionState.connected) return;
    try {
      connectionState.value = SerialConnectionState.connecting;
      _port = await device.create();
      if (_port == null) {
        disconnect();
        return;
      }
      bool openResult = await _port!.open();
      if (!openResult) {
        disconnect();
        return;
      }
      await _port!.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );
      connectedDeviceName = device.productName ?? 'Unknown Device';
      connectionState.value = SerialConnectionState.connected;
      _port!.inputStream!.listen(
        _onDataReceived,
        onError: (e) {
          print("Stream Error: $e");
          disconnect();
        },
        onDone: () {
          print("Stream Closed");
          disconnect();
        },
      );
    } catch (e) {
      print("Connection Error: $e");
      disconnect();
      rethrow;
    }
  }

  void disconnect() {
    if (connectionState.value != SerialConnectionState.disconnected) {
      print("Disconnecting...");
      stopAutoReading();
      _port?.close();
      _port = null;
      connectedDeviceName = null;
      connectionState.value = SerialConnectionState.disconnected;
    }
  }

  void startAutoReading({Duration interval = const Duration(seconds: 5)}) {
    stopAutoReading();
    if (connectionState.value == SerialConnectionState.connected) {
      startLiveReading(); // Start first read immediately
      // This timer just triggers a new read cycle if one isn't already running
      _dataRequestTimer = Timer.periodic(interval, (_) => startLiveReading());
    }
  }

  void stopAutoReading() {
    _dataRequestTimer?.cancel();
    _dataRequestTimer = null;
    _cancelTimeout();
    _isReading = false;
  }

  void startLiveReading() {
    // FIX: Only start a new read cycle if not already busy
    if (connectionState.value != SerialConnectionState.connected || _isReading) {
      return;
    }
    _isReading = true; // Mark as busy
    print("--- Starting New Read Cycle ---");
    _communicationLevel = 0;
    _sendCommand(0);
  }

  void _onDataReceived(Uint8List data) {
    if (data.isEmpty) return;
    String responseHex = Converter.byteArrayToHexString(data);
    _responseBuffer.write(responseHex);
    print("Received Chunk (Buffer: ${_responseBuffer.length} chars): $responseHex");
    _processBuffer();
  }

  void _processBuffer() {
    String buffer = _responseBuffer.toString();
    if (_lookupString == null) return;

    int startIndex = buffer.indexOf(_lookupString!);
    if (startIndex == -1) return; // Wait for more data

    // Discard any garbage data before the start of the response
    if (startIndex > 0) {
      buffer = buffer.substring(startIndex);
    }

    // Check for full header to determine length
    if (buffer.length < 34) return;

    try {
      int dataBlockLength = int.parse(buffer.substring(30, 34), radix: 16);
      int totalMessageLength = 34 + (dataBlockLength * 2) + 4;

      if (buffer.length >= totalMessageLength) {
        _cancelTimeout(); // Found a complete message, cancel timeout
        String completeResponse = buffer.substring(0, totalMessageLength);

        // FIX: Correctly remove only the processed message from the buffer
        _responseBuffer.clear();
        _responseBuffer.write(buffer.substring(totalMessageLength));

        print("Processing Full Response: $completeResponse");
        _handleResponse(completeResponse);

        if(_responseBuffer.isNotEmpty) _processBuffer();
      }
    } catch (e) {
      print("Buffer processing error: $e. Resetting cycle.");
      _responseBuffer.clear();
      _isReading = false;
    }
  }

  void _handleResponse(String response) {
    switch (_communicationLevel) {
      case 0: _handleResponseLevel0(response); break;
      case 1: _handleResponseLevel1(response); break;
      case 2: _handleResponseLevel2(response); break;
    }
  }

  void _handleResponseLevel0(String responseHex) {
    try {
      _parentAddress = responseHex.substring(86, 94);
      _serialNumber = Converter.hexToAscii(responseHex.substring(68, 86));
      print("Parsed L0 -> Address: $_parentAddress, Serial: $_serialNumber");
      _communicationLevel = 1;
      Future.delayed(const Duration(milliseconds: 200), () => _sendCommand(1));
    } catch (e) {
      print("Error parsing L0: $e");
      _isReading = false; // End this cycle on error
    }
  }

  void _handleResponseLevel1(String responseHex) {
    try {
      int dataBlockLength = int.parse(responseHex.substring(30, 34), radix: 16);
      String paramsBlock = responseHex.substring(34, 34 + (dataBlockLength * 2));
      _parameterList = [
        for (int i = 0; i <= paramsBlock.length - 6; i += 6)
          ParameterHelper.getDescription(paramsBlock.substring(i + 2, i + 6))
      ];
      print("Parsed L1 -> Parameters: $_parameterList");
      _communicationLevel = 2;
      Future.delayed(const Duration(milliseconds: 200), () => _sendCommand(2));
    } catch (e) {
      print("Error parsing L1: $e");
      _isReading = false;
    }
  }

  void _handleResponseLevel2(String responseHex) {
    try {
      int dataBlockLength = int.parse(responseHex.substring(30, 34), radix: 16);
      String valuesBlock = responseHex.substring(34, 34 + (dataBlockLength * 2));
      List<double> values = [
        for (int i = 0; i <= valuesBlock.length - 8; i += 8)
          Converter.hexToFloat(valuesBlock.substring(i, i + 8))
      ];

      if (_parameterList.length == values.length) {
        Map<String, double> finalReadings = Map.fromIterables(_parameterList, values);
        _dataStreamController.add(finalReadings);
      } else {
        print("L2 Data Mismatch: ${values.length} values for ${_parameterList.length} parameters");
      }
    } catch (e) {
      print("Error parsing L2: $e");
    } finally {
      _isReading = false; // Read cycle is complete, allow the next one
    }
  }

  void _sendCommand(int level) {
    String seqNo = (_runningCounter++ & 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    _lookupString = '7E02$seqNo';

    String commandBody;
    switch (level) {
      case 0:
        commandBody = '0000000002000000200000010000';
        break;
      case 1:
        commandBody = '${_parentAddress}02000000200000180000';
        break;
      case 2:
        commandBody = '${_parentAddress}02000000200000190000';
        break;
      default: return;
    }

    String commandHex = '7E02$seqNo$commandBody';
    Uint8List commandBytes = Converter.hexStringToByteArray(commandHex);
    String crc = Crc16Ccitt.computeCrc16Ccitt(commandBytes);
    String finalPacket = commandHex + crc;
    _port?.write(Converter.hexStringToByteArray(finalPacket));
    print("Sent (Lvl: $level): $finalPacket (Expecting: $_lookupString)");

    _cancelTimeout();
    _responseTimeoutTimer = Timer(const Duration(seconds: 3), () {
      print("Response timeout for Level $level. Unlocking for next cycle.");
      _isReading = false; // Allow next read cycle to start
    });
  }

  void _cancelTimeout() {
    _responseTimeoutTimer?.cancel();
    _responseTimeoutTimer = null;
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
    connectionState.dispose();
  }
}
