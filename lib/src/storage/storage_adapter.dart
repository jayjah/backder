import 'dart:convert';

import 'package:hive/hive.dart';

import 'model/storage.dart';

abstract class StorageAdapter {
  static const String _key = '0';
  static const String _boxName = 'vaultBox';
  static String boxKey = '';
  static Future<bool> put(Store store) async {
    final box = await _getStorageBox();
    if (box == null) {
      return false;
    }
    await box.put(_key, store);
    return true;
  }

  static Future<Store> get({String withKey}) async {
    final box = await _getStorageBox();
    if (box == null) {
      return null;
    }
    final result = await box.get(withKey ?? _key);
    return result;
  }

  static Future<Box> _getStorageBox() async {
    if (boxKey.isEmpty) {
      return null;
    }
    final encryptedBox = await Hive.openBox(_boxName,
        encryptionCipher: HiveAesCipher(utf8.encode(boxKey)));
    return encryptedBox;
  }
}
