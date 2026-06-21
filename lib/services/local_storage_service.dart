import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static late SharedPreferencesBox userStateBox;
  static late SharedPreferencesBox pendingWritesBox;
  static const secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    userStateBox = SharedPreferencesBox(prefs, 'user_state');
    pendingWritesBox = SharedPreferencesBox(prefs, 'pending_writes', isList: true);
  }

  static Future<void> clearUserData() async {
    await userStateBox.clear();
    await pendingWritesBox.clear();
    await secureStorage.deleteAll();
  }
}

class SharedPreferencesBox {
  final SharedPreferences _prefs;
  final String _prefix;
  final bool isList;
  List<dynamic> _list = [];

  SharedPreferencesBox(this._prefs, this._prefix, {this.isList = false}) {
    if (isList) {
      final dataStr = _prefs.getString(_prefix);
      if (dataStr != null) {
        try {
          _list = json.decode(dataStr) as List<dynamic>;
        } catch (_) {
          _list = [];
        }
      }
    }
  }

  int get length => isList ? _list.length : 0;
  bool get isNotEmpty => isList ? _list.isNotEmpty : false;
  bool get isEmpty => isList ? _list.isEmpty : true;

  dynamic get(dynamic key, {dynamic defaultValue}) {
    if (isList) {
      return null;
    }
    final val = _prefs.get('${_prefix}_$key');
    if (val == null) return defaultValue;
    if (val is String && (val.startsWith('{') || val.startsWith('['))) {
      try {
        return json.decode(val);
      } catch (_) {
        return val;
      }
    }
    return val;
  }

  Future<void> put(dynamic key, dynamic value) async {
    if (isList) return;
    final prefKey = '${_prefix}_$key';
    if (value is String) {
      await _prefs.setString(prefKey, value);
    } else if (value is int) {
      await _prefs.setInt(prefKey, value);
    } else if (value is double) {
      await _prefs.setDouble(prefKey, value);
    } else if (value is bool) {
      await _prefs.setBool(prefKey, value);
    } else {
      await _prefs.setString(prefKey, json.encode(value));
    }
  }

  Future<int> add(dynamic value) async {
    if (isList) {
      _list.add(value);
      await _prefs.setString(_prefix, json.encode(_list));
      return _list.length - 1;
    }
    return 0;
  }

  dynamic getAt(int index) {
    if (isList && index >= 0 && index < _list.length) {
      return _list[index];
    }
    return null;
  }

  Future<void> deleteAt(int index) async {
    if (isList && index >= 0 && index < _list.length) {
      _list.removeAt(index);
      await _prefs.setString(_prefix, json.encode(_list));
    }
  }

  Future<void> remove(dynamic key) async {
    if (isList) return;
    await _prefs.remove('${_prefix}_$key');
  }

  Future<void> clear() async {
    if (isList) {
      _list.clear();
      await _prefs.remove(_prefix);
    } else {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('${_prefix}_')) {
          await _prefs.remove(key);
        }
      }
    }
  }
}
