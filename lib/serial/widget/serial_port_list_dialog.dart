import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

Future<UsbDevice?> showSerialPortListDialog({
  required BuildContext context,
  required List<UsbDevice> devices,
  String title = 'Select a Serial Device',
}) {
  return showDialog<UsbDevice>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: devices.map((device) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(device),
            child: ListTile(
              leading: Icon(Icons.usb),
              title: Text(device.productName ?? 'Unknown Device'),
              subtitle: Text('VID: ${device.vid}, PID: ${device.pid}'),
            ),
          );
        }).toList(),
      );
    },
  );
}