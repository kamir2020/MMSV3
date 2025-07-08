import 'dart:typed_data';
import 'dart:convert';

Uint8List hexStringToByteArray(String hex) {
  hex = hex.replaceAll(" ", "").toUpperCase();
  if (hex.length % 2 != 0) hex = '0' + hex;
  return Uint8List.fromList(
      List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}

String byteArrayToHexString(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

double hexToFloat(String hexString) {
  if (hexString.length != 8) throw ArgumentError("Hex string must be 8 characters for a 32-bit float.");
  final int intValue = int.parse(hexString, radix: 16);
  final ByteData byteData = ByteData(4);
  byteData.setUint32(0, intValue, Endian.big);
  return byteData.getFloat32(0, Endian.big);
}