import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

Future<BluetoothDevice?> showBluetoothDeviceListDialog({
  required BuildContext context,
  required List<BluetoothDevice> devices,
  String title = 'Select a Paired Device',
}) {
  return showDialog<BluetoothDevice>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: devices.map((device) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(device),
            child: ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text(device.name ?? 'Unknown Device'),
              subtitle: Text(device.address),
            ),
          );
        }).toList(),
      );
    },
  );
}