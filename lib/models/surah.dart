import 'package:quran/quran.dart' as quran;

class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int totalVerses;
  final int totalPages;
  final String revelationType; // مكية أو مدنية
  final int memorizedPages;
  final int memorizedVerses;
  final List<int> memorizedPageNumbers; // أرقام الصفحات المحفوظة
  final DateTime? lastUpdated;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalVerses,
    required this.totalPages,
    required this.revelationType,
    this.memorizedPages = 0,
    this.memorizedVerses = 0,
    this.memorizedPageNumbers = const [],
    this.lastUpdated,
  });

  // إنشاء سورة من باكج quran
  factory Surah.fromQuranPackage(int surahNumber) {
    final totalVerses = quran.getVerseCount(surahNumber);
    final nameArabic = quran.getSurahNameArabic(surahNumber);
    final nameEnglish = quran.getSurahName(surahNumber);
    final revelationType = quran.getPlaceOfRevelation(surahNumber);

    // حساب عدد الصفحات للسورة
    final startPage = quran.getPageNumber(surahNumber, 1);
    final endPage = quran.getPageNumber(surahNumber, totalVerses);
    final totalPages = endPage - startPage + 1;

    return Surah(
      number: surahNumber,
      nameArabic: nameArabic,
      nameEnglish: nameEnglish,
      totalVerses: totalVerses,
      totalPages: totalPages,
      revelationType: revelationType,
    );
  }

  // النسبة المئوية للحفظ (بناءً على الصفحات)
  double get progressByPages {
    if (totalPages == 0) return 0.0;
    return memorizedPages / totalPages;
  }

  // النسبة المئوية للحفظ (بناءً على الآيات)
  double get progressByVerses {
    if (totalVerses == 0) return 0.0;
    return memorizedVerses / totalVerses;
  }

  // متوسط نسبة الإنجاز
  double get averageProgress {
    return (progressByPages + progressByVerses) / 2;
  }

  // هل اكتملت السورة
  bool get isCompleted {
    return memorizedPages >= totalPages && memorizedVerses >= totalVerses;
  }

  // هل بدأ الحفظ
  bool get hasStarted {
    return memorizedPages > 0 || memorizedVerses > 0;
  }

  // نسبة الإنجاز كنص
  String get progressText {
    return '${(averageProgress * 100).toStringAsFixed(1)}%';
  }

  // نوع الوحي بالعربية
  String get revelationTypeArabic {
    return revelationType == 'Meccan' ? 'مكية' : 'مدنية';
  }

  Surah copyWith({
    int? memorizedPages,
    int? memorizedVerses,
    List<int>? memorizedPageNumbers,
    DateTime? lastUpdated,
  }) {
    return Surah(
      number: number,
      nameArabic: nameArabic,
      nameEnglish: nameEnglish,
      totalVerses: totalVerses,
      totalPages: totalPages,
      revelationType: revelationType,
      memorizedPages: memorizedPages ?? this.memorizedPages,
      memorizedVerses: memorizedVerses ?? this.memorizedVerses,
      memorizedPageNumbers: memorizedPageNumbers ?? this.memorizedPageNumbers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'nameArabic': nameArabic,
    'nameEnglish': nameEnglish,
    'totalVerses': totalVerses,
    'totalPages': totalPages,
    'revelationType': revelationType,
    'memorizedPages': memorizedPages,
    'memorizedVerses': memorizedVerses,
    'memorizedPageNumbers': memorizedPageNumbers,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      totalVerses: json['totalVerses'] as int,
      totalPages: json['totalPages'] as int,
      revelationType: json['revelationType'] as String,
      memorizedPages: json['memorizedPages'] as int? ?? 0,
      memorizedVerses: json['memorizedVerses'] as int? ?? 0,
      memorizedPageNumbers:
          (json['memorizedPageNumbers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}
