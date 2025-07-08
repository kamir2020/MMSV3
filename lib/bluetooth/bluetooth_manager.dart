import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'utils/converter.dart';
import 'utils/crc_calculator.dart';
import 'utils/parameter_helper.dart';

enum BluetoothConnectionState { disconnected, connecting, connected }

class BluetoothManager {

  Timer? _dataRequestTimer;

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  ValueNotifier<BluetoothConnectionState> connectionState = ValueNotifier(BluetoothConnectionState.disconnected);
  String? connectedDeviceName;
  String? connectedDeviceAddress;
  final StreamController<Map<String, double>> _dataStreamController = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get dataStream => _dataStreamController.stream;

  int _runningCounter = 0;
  int _communicationLevel = 0;
  String? _parentAddress;
  List<String> _parameterList = [];

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting paired devices: $e");
      return [];
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    if (connectionState.value == BluetoothConnectionState.connected) return;
    try {
      connectionState.value = BluetoothConnectionState.connecting;
      _connection = await BluetoothConnection.toAddress(device.address);
      connectedDeviceName = device.name;
      connectedDeviceAddress = device.address;
      connectionState.value = BluetoothConnectionState.connected;
      _connection!.input!.listen(_onDataReceived).onDone(disconnect);
    } catch (e) {
      print("Error connecting: $e");
      disconnect();
    }
  }

  void disconnect() {
    if (connectionState.value != BluetoothConnectionState.disconnected) {
      _connection?.dispose();
      _connection = null;
      connectedDeviceName = null;
      connectedDeviceAddress = null;
      connectionState.value = BluetoothConnectionState.disconnected;
    }
  }

  /// Starts a periodic timer that requests data automatically.
  void startAutoReading({Duration interval = const Duration(seconds: 5)}) {
    // Cancel any existing timer to prevent duplicates.
    stopAutoReading();

    // Request the first reading immediately without waiting for the timer.
    if (connectionState.value == BluetoothConnectionState.connected) {
      startLiveReading();
    }

    // Start a new timer that calls startLiveReading periodically.
    _dataRequestTimer = Timer.periodic(interval, (Timer t) {
      if (connectionState.value == BluetoothConnectionState.connected) {
        startLiveReading();
      } else {
        // If we get disconnected for any reason, stop the timer.
        stopAutoReading();
      }
    });
  }

  /// Stops the automatic data refresh timer.
  void stopAutoReading() {
    _dataRequestTimer?.cancel();
    _dataRequestTimer = null;
  }




  void startLiveReading() {
    if (connectionState.value != BluetoothConnectionState.connected) return;
    _communicationLevel = 0;
    _parameterList.clear();
    _parentAddress = null;
    _sendCommand(0);
  }

  void _onDataReceived(Uint8List data) {
    if (data.isEmpty) return;
    String responseHex = byteArrayToHexString(data).toUpperCase();
    print("Received (Lvl: $_communicationLevel): $responseHex");
    switch (_communicationLevel) {
      case 0: _handleResponseLevel0(responseHex); break;
      case 1: _handleResponseLevel1(responseHex); break;
      case 2: _handleResponseLevel2(responseHex); break;
    }
  }

  void _handleResponseLevel0(String responseHex) {
    try {
      if (responseHex.length < 94)
      { // 34 for header + 52 for offset + 8 for address
        print("Level 0 response is too short.");
        return;
      }


      final int dataBlockLength = int.parse(responseHex.substring(30, 34), radix: 16);
      if (dataBlockLength == 38)
      {
        const int dataBlockStart = 34;
        const int parentAddressOffset = 52;
        final int addressStart = dataBlockStart + parentAddressOffset;

        _parentAddress = responseHex.substring(addressStart, addressStart + 8);

        print("Successfully Parsed Parent Address: $_parentAddress");

        if (_parentAddress != "00000000") {
          _communicationLevel = 1;

          // Give the sonde a moment before we send the next command.
          Future.delayed(const Duration(milliseconds: 500)).then((_) {
            _sendCommand(1); // Move to next step
          });
        }
      }
    } catch (e) {
      print("Error parsing Level 0 response: $e");
      disconnect();
    }
  }

  void _handleResponseLevel1(String responseHex) {
    try {
      if (responseHex.length < 38) return;
      final int dataBlockLength = int.parse(responseHex.substring(30, 34), radix: 16);
      final String parametersDataBlock = responseHex.substring(34, 34 + (dataBlockLength * 2));
      _parameterList.clear();
      for (int i = 0; i <= parametersDataBlock.length - 6; i += 6) {
        String parameterCode = parametersDataBlock.substring(i + 2, i + 6);
        _parameterList.add(ParameterHelper.getDescription(parameterCode));
      }
      print("Parsed Parameters: $_parameterList");
      _communicationLevel = 2;


      // **** ADD THIS DELAY ****
      Future.delayed(const Duration(milliseconds: 500)).then((_) {
        _sendCommand(2); // Move to final step
      });

    }
    catch (e) {
      print("Error parsing Level 1 response: $e");
      disconnect();
    }
  }

  void _handleResponseLevel2(String responseHex) {
    try {
      if (responseHex.length < 38) return;
      final int dataBlockLength = int.parse(responseHex.substring(30, 34), radix: 16);
      final String valuesDataBlock = responseHex.substring(34, 34 + (dataBlockLength * 2));
      final List<double> parameterValues = [];
      for (int i = 0; i <= valuesDataBlock.length - 8; i += 8) {
        String valueHex = valuesDataBlock.substring(i, i + 8);
        parameterValues.add(hexToFloat(valueHex));
      }

      if (_parameterList.length == parameterValues.length) {
        Map<String, double> finalReadings = {};
        for (int i = 0; i < _parameterList.length; i++) {
          finalReadings[_parameterList[i]] = parameterValues[i];
        }
        print("Final Parsed Readings: $finalReadings");
        _dataStreamController.add(finalReadings);
      }
      _communicationLevel = 0;
    } catch (e) {
      print("Error parsing Level 2 response: $e");
      disconnect();
    }
  }

  void _sendCommand(int level) {
    String commandHex;
    if (level == 0) commandHex = _getCommand0();
    else if (level == 1) commandHex = _getCommand1();
    else commandHex = _getCommand2();

    Uint8List commandBytes = hexStringToByteArray(commandHex);
    String crcHexString = computeCrc16Ccitt(commandBytes);
    String finalHexPacket = commandHex + crcHexString;
    Uint8List packetToSend = hexStringToByteArray(finalHexPacket);

    _connection?.output.add(packetToSend);
    print("Sent (Lvl: $level): $finalHexPacket");
  }

  String _getCommand0() {
    String seqNo = (_runningCounter++ & 255).toRadixString(16).padLeft(2, '0');
    return '7E02${seqNo}0000000002000000200000010000';
  }

  String _getCommand1() {
    String seqNo = (_runningCounter++ & 255).toRadixString(16).padLeft(2, '0');
    return '7E02$seqNo${_parentAddress}02000000200000180000';
  }

  String _getCommand2() {
    String seqNo = (_runningCounter++ & 255).toRadixString(16).padLeft(2, '0');
    return '7E02$seqNo${_parentAddress}02000000200000190000';
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
    connectionState.dispose();
  }
}