class Surah {
  final int number;
  final String name;
  final int totalPages;
  final int totalAyahs;
  final int memorizedPages;
  final int memorizedAyahs;

  const Surah({
    required this.number,
    required this.name,
    required this.totalPages,
    required this.totalAyahs,
    this.memorizedPages = 0,
    this.memorizedAyahs = 0,
  });

  double get progress {
    if (totalPages == 0) return 0.0;
    return memorizedPages / totalPages;
  }

  bool get isCompleted {
    return memorizedPages == totalPages && memorizedAyahs == totalAyahs;
  }

  Surah copyWith({int? memorizedPages, int? memorizedAyahs}) {
    return Surah(
      number: number,
      name: name,
      totalPages: totalPages,
      totalAyahs: totalAyahs,
      memorizedPages: memorizedPages ?? this.memorizedPages,
      memorizedAyahs: memorizedAyahs ?? this.memorizedAyahs,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'totalPages': totalPages,
    'totalAyahs': totalAyahs,
    'memorizedPages': memorizedPages,
    'memorizedAyahs': memorizedAyahs,
  };

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    number: json['number'] as int,
    name: json['name'] as String,
    totalPages: json['totalPages'] as int,
    totalAyahs: json['totalAyahs'] as int,
    memorizedPages: json['memorizedPages'] as int? ?? 0,
    memorizedAyahs: json['memorizedAyahs'] as int? ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}
