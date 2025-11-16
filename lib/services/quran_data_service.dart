import 'package:quran/quran.dart' as quran;

import '../models/surah.dart';

/// خدمة للتعامل مع بيانات القرآن الكريم باستخدام باكج quran
class QuranDataService {
  // إجمالي عدد السور في القرآن
  static const int totalSurahs = 114;

  // إجمالي عدد الصفحات في القرآن
  static const int totalPages = 604;

  /// الحصول على جميع السور من باكج quran
  static List<Surah> getAllSurahs() {
    return List.generate(
      totalSurahs,
      (index) => Surah.fromQuranPackage(index + 1),
    );
  }

  /// الحصول على سورة معينة
  static Surah getSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > totalSurahs) {
      throw ArgumentError('رقم السورة يجب أن يكون بين 1 و $totalSurahs');
    }
    return Surah.fromQuranPackage(surahNumber);
  }

  /// الحصول على إجمالي عدد الآيات في القرآن
  static int getTotalVerses() {
    return quran.totalVerseCount;
  }

  /// الحصول على عدد الآيات في سورة معينة
  static int getVerseCount(int surahNumber) {
    return quran.getVerseCount(surahNumber);
  }

  /// الحصول على رقم الصفحة لآية معينة
  static int getPageNumber(int surahNumber, int verseNumber) {
    return quran.getPageNumber(surahNumber, verseNumber);
  }

  /// الحصول على رقم الجزء لآية معينة
  static int getJuzNumber(int surahNumber, int verseNumber) {
    return quran.getJuzNumber(surahNumber, verseNumber);
  }

  /// الحصول على نوع السورة (مكية/مدنية)
  static String getPlaceOfRevelation(int surahNumber) {
    return quran.getPlaceOfRevelation(surahNumber);
  }

  /// الحصول على اسم السورة بالعربية
  static String getSurahNameArabic(int surahNumber) {
    return quran.getSurahNameArabic(surahNumber);
  }

  /// الحصول على اسم السورة بالإنجليزية
  static String getSurahNameEnglish(int surahNumber) {
    return quran.getSurahName(surahNumber);
  }

  /// الحصول على نص الآية
  static String getVerse(
    int surahNumber,
    int verseNumber, {
    bool withBasmala = false,
  }) {
    return quran.getVerse(
      surahNumber,
      verseNumber,
      verseEndSymbol: withBasmala,
    );
  }

  /// الحصول على البسملة
  static String getBasmala() {
    return quran.basmala;
  }

  /// التحقق من صحة رقم السورة
  static bool isValidSurahNumber(int surahNumber) {
    return surahNumber >= 1 && surahNumber <= totalSurahs;
  }

  /// التحقق من صحة رقم الآية في السورة
  static bool isValidVerseNumber(int surahNumber, int verseNumber) {
    if (!isValidSurahNumber(surahNumber)) return false;
    final verseCount = getVerseCount(surahNumber);
    return verseNumber >= 1 && verseNumber <= verseCount;
  }

  /// الحصول على إحصائيات سورة معينة
  static Map<String, dynamic> getSurahStats(int surahNumber) {
    final surah = getSurah(surahNumber);
    final startPage = getPageNumber(surahNumber, 1);
    final endPage = getPageNumber(surahNumber, surah.totalVerses);
    final startJuz = getJuzNumber(surahNumber, 1);
    final endJuz = getJuzNumber(surahNumber, surah.totalVerses);

    return {
      'number': surahNumber,
      'nameArabic': surah.nameArabic,
      'nameEnglish': surah.nameEnglish,
      'totalVerses': surah.totalVerses,
      'totalPages': surah.totalPages,
      'revelationType': surah.revelationTypeArabic,
      'startPage': startPage,
      'endPage': endPage,
      'startJuz': startJuz,
      'endJuz': endJuz,
      'pageRange': startJuz == endJuz
          ? 'الجزء $startJuz'
          : 'من الجزء $startJuz إلى $endJuz',
    };
  }

  /// الحصول على السور المكية
  static List<Surah> getMeccanSurahs() {
    return getAllSurahs().where((s) => s.revelationType == 'Meccan').toList();
  }

  /// الحصول على السور المدنية
  static List<Surah> getMedinanSurahs() {
    return getAllSurahs().where((s) => s.revelationType == 'Medinan').toList();
  }

  /// حساب النسبة المئوية للإنجاز في القرآن كاملاً
  static double calculateTotalProgress(List<Surah> surahs) {
    final totalMemorizedPages = surahs.fold<int>(
      0,
      (sum, s) => sum + s.memorizedPages,
    );
    return (totalMemorizedPages / totalPages) * 100;
  }

  /// حساب إجمالي الآيات المحفوظة
  static int calculateTotalMemorizedVerses(List<Surah> surahs) {
    return surahs.fold<int>(0, (sum, s) => sum + s.memorizedVerses);
  }

  /// حساب إجمالي الصفحات المحفوظة
  static int calculateTotalMemorizedPages(List<Surah> surahs) {
    return surahs.fold<int>(0, (sum, s) => sum + s.memorizedPages);
  }

  /// الحصول على عدد السور المكتملة
  static int getCompletedSurahsCount(List<Surah> surahs) {
    return surahs.where((s) => s.isCompleted).length;
  }

  /// الحصول على عدد السور قيد الحفظ
  static int getInProgressSurahsCount(List<Surah> surahs) {
    return surahs.where((s) => s.hasStarted && !s.isCompleted).length;
  }
}
