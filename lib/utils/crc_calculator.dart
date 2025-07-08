// utils/crc_calculator.dart
import 'dart:typed_data';

class Crc16Ccitt {
  static String computeCrc16Ccitt(Uint8List bytes) {
    int crc = 0xFFFF; // Initial value
    int polynomial = 0x1021; // Matches Java's 0x1021
    for (int b in bytes) {
      for (int i = 0; i < 8; i++) {
        bool bit = ((b >> (7 - i) & 1) == 1);
        bool c15 = ((crc >> 15 & 1) == 1);
        crc <<= 1;
        if (c15 ^ bit) crc ^= polynomial;
      }
    }
    crc &= 0xffff;
    return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
  }
}