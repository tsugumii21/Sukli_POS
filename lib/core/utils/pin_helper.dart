import 'dart:convert';
import 'package:crypto/crypto.dart';

/// PinHelper provides secure hashing and verification for 4-digit cashier PINs.
class PinHelper {
  /// Hashes a 4-digit PIN string using SHA-256.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verifies a raw PIN string against a stored SHA-256 hash.
  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }
}
