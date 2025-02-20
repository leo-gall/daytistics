import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Convert the key to bytes
final List<int> keyBytes = utf8.encode(dotenv.env['SECRET_KEY']!);
final algorithm = AesGcm.with256bits(); // AES-256-GCM

// Encrypt function
Future<String> encrypt(String text) async {
  final secretKey = SecretKey(keyBytes);
  final nonce = algorithm.newNonce(); // Generate IV
  final secretBox = await algorithm.encrypt(
    utf8.encode(text),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Encode IV + Encrypted Data as base64
  final encoded = base64Encode(nonce + secretBox.cipherText);
  return encoded;
}

// Decrypt function
Future<String> decrypt(String encryptedText) async {
  final secretKey = SecretKey(keyBytes);
  final data = base64Decode(encryptedText);
  final nonce = data.sublist(0, 12);
  final cipherText = data.sublist(12);

  final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac.empty);
  final decryptedBytes = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );

  return utf8.decode(decryptedBytes);
}
