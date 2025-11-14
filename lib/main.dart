import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const QuranHifdhApp());
}

class QuranHifdhApp extends StatelessWidget {
  const QuranHifdhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابعة حفظ القرآن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF00695C),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Surah {
  final int number;
  final String name;
  final int totalPages;
  final int totalAyahs;
  int memorizedPages;
  int memorizedAyahs;

  Surah({
    required this.number,
    required this.name,
    required this.totalPages,
    required this.totalAyahs,
    this.memorizedPages = 0,
    this.memorizedAyahs = 0,
  });

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'totalPages': totalPages,
    'totalAyahs': totalAyahs,
    'memorizedPages': memorizedPages,
    'memorizedAyahs': memorizedAyahs,
  };

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    number: json['number'],
    name: json['name'],
    totalPages: json['totalPages'],
    totalAyahs: json['totalAyahs'],
    memorizedPages: json['memorizedPages'] ?? 0,
    memorizedAyahs: json['memorizedAyahs'] ?? 0,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Surah> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSurahs();
  }

  void _initializeSurahs() async {
    await _loadSurahs();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? surahsJson = prefs.getString('surahs');

    if (surahsJson != null) {
      final List<dynamic> decoded = json.decode(surahsJson);
      surahs = decoded.map((s) => Surah.fromJson(s)).toList();
    } else {
      // بيانات السور الأساسية (عدد الصفحات والآيات لكل سورة)
      surahs = [
        Surah(number: 1, name: 'الفاتحة', totalPages: 1, totalAyahs: 7),
        Surah(number: 2, name: 'البقرة', totalPages: 48, totalAyahs: 286),
        Surah(number: 3, name: 'آل عمران', totalPages: 37, totalAyahs: 200),
        Surah(number: 4, name: 'النساء', totalPages: 44, totalAyahs: 176),
        Surah(number: 5, name: 'المائدة', totalPages: 27, totalAyahs: 120),
        Surah(number: 6, name: 'الأنعام', totalPages: 28, totalAyahs: 165),
        Surah(number: 7, name: 'الأعراف', totalPages: 40, totalAyahs: 206),
        Surah(number: 8, name: 'الأنفال', totalPages: 16, totalAyahs: 75),
        Surah(number: 9, name: 'التوبة', totalPages: 26, totalAyahs: 129),
        Surah(number: 10, name: 'يونس', totalPages: 21, totalAyahs: 109),
        Surah(number: 11, name: 'هود', totalPages: 21, totalAyahs: 123),
        Surah(number: 12, name: 'يوسف', totalPages: 21, totalAyahs: 111),
        Surah(number: 13, name: 'الرعد', totalPages: 9, totalAyahs: 43),
        Surah(number: 14, name: 'إبراهيم', totalPages: 9, totalAyahs: 52),
        Surah(number: 15, name: 'الحجر', totalPages: 7, totalAyahs: 99),
        Surah(number: 16, name: 'النحل', totalPages: 21, totalAyahs: 128),
        Surah(number: 17, name: 'الإسراء', totalPages: 17, totalAyahs: 111),
        Surah(number: 18, name: 'الكهف', totalPages: 18, totalAyahs: 110),
        Surah(number: 19, name: 'مريم', totalPages: 11, totalAyahs: 98),
        Surah(number: 20, name: 'طه', totalPages: 15, totalAyahs: 135),
        Surah(number: 21, name: 'الأنبياء', totalPages: 15, totalAyahs: 112),
        Surah(number: 22, name: 'الحج', totalPages: 13, totalAyahs: 78),
        Surah(number: 23, name: 'المؤمنون', totalPages: 11, totalAyahs: 118),
        Surah(number: 24, name: 'النور', totalPages: 13, totalAyahs: 64),
        Surah(number: 25, name: 'الفرقان', totalPages: 10, totalAyahs: 77),
        Surah(number: 26, name: 'الشعراء', totalPages: 16, totalAyahs: 227),
        Surah(number: 27, name: 'النمل', totalPages: 12, totalAyahs: 93),
        Surah(number: 28, name: 'القصص', totalPages: 14, totalAyahs: 88),
        Surah(number: 29, name: 'العنكبوت', totalPages: 11, totalAyahs: 69),
        Surah(number: 30, name: 'الروم', totalPages: 8, totalAyahs: 60),
      ];
      await _saveSurahs();
    }
  }

  Future<void> _saveSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(surahs.map((s) => s.toJson()).toList());
    await prefs.setString('surahs', encoded);
  }

  int get totalMemorizedPages {
    return surahs.fold(0, (sum, surah) => sum + surah.memorizedPages);
  }

  int get totalMemorizedAyahs {
    return surahs.fold(0, (sum, surah) => sum + surah.memorizedAyahs);
  }

  int get totalPages => 604; // إجمالي صفحات المصحف
  int get totalAyahs => 6236; // إجمالي آيات القرآن

  double get pagesPercentage => (totalMemorizedPages / totalPages) * 100;
  double get ayahsPercentage => (totalMemorizedAyahs / totalAyahs) * 100;

  void _showSurahDetails(Surah surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SurahDetailsSheet(
        surah: surah,
        onUpdate: (pages, ayahs) {
          setState(() {
            surah.memorizedPages = pages;
            surah.memorizedAyahs = ayahs;
          });
          _saveSurahs();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '📖 متابعة حفظ القرآن الكريم',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('عن التطبيق'),
                    content: const Text(
                      'تطبيق متابعة حفظ القرآن الكريم\n\n'
                      '• سجل عدد الصفحات والآيات المحفوظة\n'
                      '• تابع نسبة إنجازك\n'
                      '• حدد أهدافك اليومية\n\n'
                      'وفقك الله في حفظ كتابه الكريم 🤲',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('حسناً'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // قسم الإحصائيات
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'إجمالي الحفظ',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'الصفحات',
                          '$totalMemorizedPages',
                          'من $totalPages',
                          '${pagesPercentage.toStringAsFixed(1)}%',
                          Icons.menu_book,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'الآيات',
                          '$totalMemorizedAyahs',
                          'من $totalAyahs',
                          '${ayahsPercentage.toStringAsFixed(1)}%',
                          Icons.format_align_right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pagesPercentage / 100,
                      minHeight: 12,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD54F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'نسبة الإنجاز الكلية: ${pagesPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // قائمة السور
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  final progress = surah.totalPages > 0
                      ? (surah.memorizedPages / surah.totalPages)
                      : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () => _showSurahDetails(surah),
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00695C),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${surah.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'سورة ${surah.name}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${surah.memorizedPages}/${surah.totalPages} صفحة • ${surah.memorizedAyahs}/${surah.totalAyahs} آية',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (surah.memorizedPages == surah.totalPages &&
                                    surah.memorizedAyahs == surah.totalAyahs)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  )
                                else
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0
                                      ? Colors.green
                                      : const Color(0xFF00897B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% مكتمل',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    String percentage,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00695C), size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percentage,
              style: const TextStyle(
                color: Color(0xFF00695C),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SurahDetailsSheet extends StatefulWidget {
  final Surah surah;
  final Function(int pages, int ayahs) onUpdate;

  const SurahDetailsSheet({
    super.key,
    required this.surah,
    required this.onUpdate,
  });

  @override
  State<SurahDetailsSheet> createState() => _SurahDetailsSheetState();
}

class _SurahDetailsSheetState extends State<SurahDetailsSheet> {
  late int memorizedPages;
  late int memorizedAyahs;

  @override
  void initState() {
    super.initState();
    memorizedPages = widget.surah.memorizedPages;
    memorizedAyahs = widget.surah.memorizedAyahs;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'سورة ${widget.surah.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildCounter(
              'عدد الصفحات المحفوظة',
              memorizedPages,
              widget.surah.totalPages,
              (value) => setState(() => memorizedPages = value),
            ),
            const SizedBox(height: 20),
            _buildCounter(
              'عدد الآيات المحفوظة',
              memorizedAyahs,
              widget.surah.totalAyahs,
              (value) => setState(() => memorizedAyahs = value),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onUpdate(memorizedPages, memorizedAyahs);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF00695C)),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
    String label,
    int value,
    int max,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF00695C),
                iconSize: 32,
              ),
              Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  Text(
                    'من $max',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF00695C),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / max,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00695C),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${((value / max) * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
