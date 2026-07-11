import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmark {
  final int surahId;
  final String surahName;      // Arabic name
  final String surahBangla;    // Bangla name
  final int ayahIndex;         // 1-based
  final String arabicText;
  final String bnText;

  const Bookmark({
    required this.surahId,
    required this.surahName,
    required this.surahBangla,
    required this.ayahIndex,
    required this.arabicText,
    required this.bnText,
  });

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'surahName': surahName,
        'surahBangla': surahBangla,
        'ayahIndex': ayahIndex,
        'arabicText': arabicText,
        'bnText': bnText,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        surahId: json['surahId'] as int,
        surahName: json['surahName'] as String,
        surahBangla: json['surahBangla'] as String,
        ayahIndex: json['ayahIndex'] as int,
        arabicText: json['arabicText'] as String,
        bnText: json['bnText'] as String,
      );
}

class BookmarkService extends ChangeNotifier {
  static const _key = 'bookmarks';
  List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  int get count => _bookmarks.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = json.decode(raw) as List;
      _bookmarks = list
          .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  bool isBookmarked(int surahId, int ayahIndex) {
    return _bookmarks
        .any((b) => b.surahId == surahId && b.ayahIndex == ayahIndex);
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final exists = isBookmarked(bookmark.surahId, bookmark.ayahIndex);
    if (exists) {
      _bookmarks.removeWhere(
          (b) => b.surahId == bookmark.surahId && b.ayahIndex == bookmark.ayahIndex);
    } else {
      _bookmarks.insert(0, bookmark);
    }
    await _save();
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    _bookmarks.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(_bookmarks.map((b) => b.toJson()).toList()));
  }
}
