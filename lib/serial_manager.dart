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
  // FIX: Changed the stream type to match the expected output.
  final StreamController<Map<String, double>> _dataStreamController =
  StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get dataStream => _dataStreamController.stream;

  int _runningCounter = 0;
  int _communicationLevel = 0;
  String? _parentAddress;
  String? _serialNumber; // Added to store sonde serial number
  List<String> _parameterList = [];
  Timer? _dataRequestTimer;
  Timer? _responseTimeoutTimer;
  String? _lastSentCommand; // To track the last command for echo detection
  StringBuffer _responseBuffer =
  StringBuffer(); // Buffer for accumulating responses
  int _retryCount = 0; // Track retries to prevent infinite loops
  static const int _maxRetries = 5; // Maximum retries before giving up
  String? _lookupString; // To track expected response prefix

  Future<List<UsbDevice>> getAvailableDevices() async {
    try {
      final devices = await UsbSerial.listDevices();
      print(
        "Available devices: ${devices.map((d) => '${d.productName} (VID: ${d.vid}, PID: ${d.pid})').join(', ')}",
      );
      return devices;
    } catch (e) {
      print("Error listing devices: $e");
      return [];
    }
  }

  Future<void> connect(UsbDevice device) async {
    if (connectionState.value == SerialConnectionState.connected) return;
    try {
      print(
        "Attempting to connect to ${device.productName} (VID: ${device.vid}, PID: ${device.pid}, Manufacturer: ${device.manufacturerName}, DeviceId: ${device.deviceId})",
      );
      connectionState.value = SerialConnectionState.connecting;
      _port = await device.create();
      if (_port == null) {
        print("Failed to create port for ${device.productName}");
        disconnect();
        return;
      }
      bool openResult = await _port!.open();
      if (!openResult) {
        print("Failed to open port for ${device.productName}");
        disconnect();
        return;
      }
      print("Port opened successfully for ${device.productName}");
      await _port!.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );
      print(
        "Port parameters set: 115200 baud, 8 data bits, 1 stop bit, no parity",
      );
      connectedDeviceName = device.productName ?? 'Unknown Device';
      connectionState.value = SerialConnectionState.connected;
      print("Connected to ${connectedDeviceName}");
      _port!.inputStream!.listen(
        _onDataReceived,
        onError: (e) {
          print("Stream error: $e");
          disconnect();
        },
        onDone: () {
          print("Stream closed");
          disconnect();
        },
      );
    } catch (e) {
      print("Error connecting to ${device.productName}: $e");
      disconnect();
      throw e;
    }
  }

  void disconnect() {
    if (connectionState.value != SerialConnectionState.disconnected) {
      print("Disconnecting from ${connectedDeviceName}");
      _port?.close();
      _port = null;
      connectedDeviceName = null;
      connectionState.value = SerialConnectionState.disconnected;
      _cancelTimeout();
      _responseBuffer.clear();
      _retryCount = 0;
      _communicationLevel = 0;
      _parentAddress = null;
      _serialNumber = null;
      _parameterList.clear();
      _lastSentCommand = null;
      _lookupString = null;
    }
  }

  void startAutoReading({Duration interval = const Duration(seconds: 5)}) {
    stopAutoReading();
    if (connectionState.value == SerialConnectionState.connected) {
      print("Starting auto reading");
      startLiveReading();
    }
    _dataRequestTimer = Timer.periodic(interval, (Timer t) {
      if (connectionState.value == SerialConnectionState.connected) {
        startLiveReading();
      } else {
        stopAutoReading();
      }
    });
  }

  void stopAutoReading() {
    print("Stopping auto reading");
    _dataRequestTimer?.cancel();
    _dataRequestTimer = null;
    _cancelTimeout();
  }

  void startLiveReading() {
    if (connectionState.value != SerialConnectionState.connected) return;
    print("Initiating live reading");
    _communicationLevel = 0;
    _parameterList.clear();
    _parentAddress = null;
    _serialNumber = null;
    _retryCount = 0;
    _responseBuffer.clear();
    _lastSentCommand = null;
    _lookupString = null;
    _sendCommand(0);
  }

  void _onDataReceived(Uint8List data) {
    _cancelTimeout();
    if (data.isEmpty) {
      print("Received empty data");
      return;
    }
    String responseHex = Converter.byteArrayToHexString(data);
    print(
      "Received (Lvl: $_communicationLevel, ${data.length} bytes): $responseHex",
    );

    if (_lastSentCommand != null && responseHex == _lastSentCommand) {
      print("Received echo of sent command, waiting for actual response");
      _responseTimeoutTimer = Timer(const Duration(seconds: 2), () {
        print(
          "No actual response after echo, retrying Level $_communicationLevel",
        );
        _retryCommand(_communicationLevel);
      });
      return;
    }

    _responseBuffer.write(responseHex);
    String buffer = _responseBuffer.toString();
    if (_lookupString == null) {
      print("No lookup string set, waiting for more data");
      return;
    }

    int startIndex = buffer.indexOf(_lookupString!);
    if (startIndex >= 0) {
      try {
        if (buffer.length >= startIndex + 34) {
          String lengthStr = buffer.substring(startIndex + 30, startIndex + 34);
          int dataBlockLength = int.parse(lengthStr, radix: 16);

          int totalLength = startIndex + 34 + (dataBlockLength * 2) + 4;

          if (buffer.length >= totalLength) {
            String response = buffer.substring(startIndex, totalLength);
            _responseBuffer.clear();
            switch (_communicationLevel) {
              case 0:
                _handleResponseLevel0(response);
                break;
              case 1:
                _handleResponseLevel1(response);
                break;
              case 2:
                _handleResponseLevel2(response);
                break;
            }
            _retryCount = 0;
          } else {
            _responseTimeoutTimer = Timer(const Duration(seconds: 2), () {
              print("Incomplete response, retrying Level $_communicationLevel");
              _retryCommand(_communicationLevel);
            });
          }
        }
      } catch (e) {
        print("Error parsing response: $e");
        _retryCommand(_communicationLevel);
      }
    } else {
      _responseTimeoutTimer = Timer(const Duration(seconds: 2), () {
        print(
          "No valid response with lookup string $_lookupString, retrying Level $_communicationLevel",
        );
        _retryCommand(_communicationLevel);
      });
    }
  }

  void _handleResponseLevel0(String responseHex) {
    print("Processing Level 0 response: $responseHex");
    try {
      if (responseHex.length < 94) {
        print("Level 0 response is too short: ${responseHex.length} bytes");
        _retryCommand(0);
        return;
      }
      final int dataBlockLength = int.parse(
        responseHex.substring(30, 34),
        radix: 16,
      );
      print("Data block length: $dataBlockLength");
      if (dataBlockLength == 38) {
        const int dataBlockStart = 34;
        const int parentAddressOffset = 52;
        const int serialOffset = 34;
        final int addressStart = dataBlockStart + parentAddressOffset;
        final int serialStart = dataBlockStart + serialOffset;
        _parentAddress = responseHex.substring(addressStart, addressStart + 8);
        _serialNumber = Converter.hexToAscii(
          responseHex.substring(serialStart, serialStart + 18),
        );
        print(
          "Successfully Parsed Parent Address: $_parentAddress, Serial: $_serialNumber",
        );
        if (_parentAddress == "00000000") {
          print("Invalid parent address, retrying Level 0");
          _retryCommand(0);
        } else {
          _communicationLevel = 1;
          Future.delayed(const Duration(milliseconds: 500), () {
            _sendCommand(1);
          });
        }
      } else {
        print("Unexpected data block length: $dataBlockLength, expected 38");
        _retryCommand(0);
      }
    } catch (e) {
      print("Error parsing Level 0 response: $e");
      _retryCommand(0);
    }
  }

  void _handleResponseLevel1(String responseHex) {
    print("Processing Level 1 response: $responseHex");
    try {
      if (responseHex.length < 38) {
        print("Level 1 response is too short: ${responseHex.length} bytes");
        _retryCommand(1);
        return;
      }
      final int dataBlockLength = int.parse(
        responseHex.substring(30, 34),
        radix: 16,
      );
      print("Data block length: $dataBlockLength");
      final String parametersDataBlock = responseHex.substring(
        34,
        34 + (dataBlockLength * 2),
      );
      _parameterList.clear();
      for (int i = 0; i <= parametersDataBlock.length - 6; i += 6) {
        String parameterCode = parametersDataBlock.substring(i + 2, i + 6);
        String description = ParameterHelper.getDescription(parameterCode);
        if (description.isNotEmpty) {
          _parameterList.add(description);
        }
      }
      print("Parsed Parameters: $_parameterList");
      if (_parameterList.isEmpty) {
        print("No valid parameters found, retrying Level 1");
        _retryCommand(1);
      } else {
        _communicationLevel = 2;
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendCommand(2);
        });
      }
    } catch (e) {
      print("Error parsing Level 1 response: $e");
      _retryCommand(1);
    }
  }

  void _handleResponseLevel2(String responseHex) {
    print("Processing Level 2 response: $responseHex");
    try {
      if (responseHex.length < 38) {
        print("Level 2 response is too short: ${responseHex.length} bytes");
        _retryCommand(1);
        return;
      }
      final int dataBlockLength = int.parse(
        responseHex.substring(30, 34),
        radix: 16,
      );
      print("Data block length: $dataBlockLength");
      final String valuesDataBlock = responseHex.substring(
        34,
        34 + (dataBlockLength * 2),
      );
      final List<double> parameterValues = [];
      for (int i = 0; i <= valuesDataBlock.length - 8; i += 8) {
        String valueHex = valuesDataBlock.substring(i, i + 8);
        parameterValues.add(Converter.hexToFloat(valueHex));
      }
      if (_parameterList.length == parameterValues.length) {
        Map<String, double> finalReadings = {};
        for (int i = 0; i < _parameterList.length; i++) {
          finalReadings[_parameterList[i]] = parameterValues[i];
        }
        print("Final Parsed Readings: $finalReadings");

        // FIX: Changed to only send the Map<String, double> of readings
        _dataStreamController.add(finalReadings);

        _communicationLevel = 1;
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendCommand(1);
        });
      } else {
        print(
          "Mismatch: ${parameterValues.length} values for ${_parameterList.length} parameters",
        );
        _retryCommand(1);
      }
    } catch (e) {
      print("Error parsing Level 2 response: $e");
      _retryCommand(1);
    }
  }

  void _sendCommand(int level) {
    if (_retryCount >= _maxRetries) {
      print("Max retries reached for Level $level, disconnecting");
      disconnect();
      return;
    }
    _cancelTimeout();
    String commandHex;
    if (level == 0) {
      commandHex = _getCommand0();
    } else if (level == 1) {
      if (_parentAddress == null) {
        print("Parent address not set, reverting to Level 0");
        _communicationLevel = 0;
        _retryCommand(0);
        return;
      }
      commandHex = _getCommand1();
    } else {
      if (_parentAddress == null) {
        print("Parent address not set, reverting to Level 0");
        _communicationLevel = 0;
        _retryCommand(0);
        return;
      }
      commandHex = _getCommand2();
    }

    Uint8List commandBytes = Converter.hexStringToByteArray(commandHex);
    String crcHexString = Crc16Ccitt.computeCrc16Ccitt(commandBytes);
    String finalHexPacket = commandHex + crcHexString;
    _lastSentCommand = finalHexPacket;
    _lookupString =
    '7E02${(_runningCounter - 1).toRadixString(16).padLeft(2, '0').toUpperCase()}';
    Uint8List packetToSend = Converter.hexStringToByteArray(finalHexPacket);

    _port?.write(packetToSend);
    print("Sent (Lvl: $level, ${packetToSend.length} bytes): $finalHexPacket");

    _responseTimeoutTimer = Timer(const Duration(seconds: 2), () {
      print("Response timeout for Level $level command");
      _retryCommand(level);
    });
  }

  void _retryCommand(int level) {
    _retryCount++;
    print(
      "Retrying command for Level $level (Attempt ${_retryCount}/$_maxRetries)",
    );
    _sendCommand(level);
  }

  void _cancelTimeout() {
    _responseTimeoutTimer?.cancel();
    _responseTimeoutTimer = null;
  }

  String _getCommand0() {
    String seqNo = (_runningCounter++ & 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    return '7E02${seqNo}0000000002000000200000010000';
  }

  String _getCommand1() {
    String seqNo = (_runningCounter++ & 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    return '7E02${seqNo}${_parentAddress}02000000200000180000';
  }

  String _getCommand2() {
    String seqNo = (_runningCounter++ & 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    return '7E02${seqNo}${_parentAddress}02000000200000190000';
  }

  void dispose() {
    print("Disposing SerialManager");
    disconnect();
    _dataStreamController.close();
    connectionState.dispose();
  }
}
