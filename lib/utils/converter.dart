// utils/converter.dart
import 'dart:typed_data';

class Converter {
  static Uint8List hexStringToByteArray(String hex) {
    hex = hex.replaceAll(" ", "").toUpperCase();
    if (hex.length % 2 != 0) hex = '0' + hex;
    return Uint8List.fromList(
      List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)),
    );
  }

  static String byteArrayToHexString(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
  }

  static double hexToFloat(String hexString) {
    if (hexString.length != 8) throw ArgumentError("Hex string must be 8 characters for a 32-bit float.");
    final int intValue = int.parse(hexString, radix: 16);
    final ByteData byteData = ByteData(4);
    byteData.setUint32(0, intValue, Endian.big);
    return byteData.getFloat32(0, Endian.big);
  }

  static String hexToAscii(String hexString) {
    // Matches Converter.hexToAscii from Converter.java
    StringBuffer output = StringBuffer();
    for (int i = 0; i < hexString.length; i += 2) {
      String str = hexString.substring(i, i + 2);
      output.write(String.fromCharCode(int.parse(str, radix: 16)));
    }
    return output.toString();
  }
}