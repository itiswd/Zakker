import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class StorageService {
  static const String _surahsKey = 'surahs';

  Future<List<Surah>> loadSurahs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? surahsJson = prefs.getString(_surahsKey);

      if (surahsJson != null) {
        final List<dynamic> decoded = json.decode(surahsJson);
        return decoded.map((s) => Surah.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveSurahs(List<Surah> surahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        surahs.map((s) => s.toJson()).toList(),
      );
      return await prefs.setString(_surahsKey, encoded);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_surahsKey);
    } catch (e) {
      return false;
    }
  }
}
