import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/surah_card.dart';

enum SurahFilter { all, completed, inProgress, notStarted, meccan, medinan }

class QuranSearchDelegate extends SearchDelegate<Surah?> {
  final WidgetRef ref;
  SurahFilter currentFilter = SurahFilter.all;

  QuranSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'ابحث عن سورة';

  TextDirection get textDirection => TextDirection.rtl;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white30,
        selectionHandleColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.white.withAlpha(51),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () => close(context, null),
        tooltip: 'رجوع',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return query.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear, color: AppTheme.cardColor),
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
            tooltip: 'مسح',
          )
        : SizedBox();
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: surahsAsync.when(
        data: (surahs) {
          // تطبيق الفلتر
          var filteredSurahs = _applyFilter(surahs);

          // تطبيق البحث
          if (query.isNotEmpty) {
            filteredSurahs = _searchSurahs(filteredSurahs, query);
          }

          if (filteredSurahs.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // رأس النتائج
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.backgroundColor,
                child: Row(
                  children: [
                    Icon(
                      _getFilterIcon(),
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFilterLabel(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredSurahs.length} سورة',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // قائمة النتائج
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = filteredSurahs[index];
                    return GestureDetector(
                      onTap: () => close(context, surah),
                      child: SurahCard(surah: surah),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text('حدث خطأ', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }

  List<Surah> _applyFilter(List<Surah> surahs) {
    switch (currentFilter) {
      case SurahFilter.completed:
        return surahs.where((s) => s.isCompleted).toList();
      case SurahFilter.inProgress:
        return surahs.where((s) => s.hasStarted && !s.isCompleted).toList();
      case SurahFilter.notStarted:
        return surahs.where((s) => !s.hasStarted).toList();
      case SurahFilter.meccan:
        return surahs.where((s) => s.revelationType == 'Meccan').toList();
      case SurahFilter.medinan:
        return surahs.where((s) => s.revelationType == 'Medinan').toList();
      case SurahFilter.all:
        return surahs;
    }
  }

  List<Surah> _searchSurahs(List<Surah> surahs, String query) {
    final lowerQuery = query.toLowerCase();

    return surahs.where((surah) {
      // البحث في الاسم العربي
      if (surah.nameArabic.contains(query)) return true;

      // البحث في الاسم الإنجليزي
      if (surah.nameEnglish.toLowerCase().contains(lowerQuery)) return true;

      // البحث برقم السورة
      if (surah.number.toString() == query) return true;

      // البحث المتقدم
      // مثلاً: "مكية" أو "مدنية"
      if (query == 'مكية' && surah.revelationType == 'Meccan') return true;
      if (query == 'مدنية' && surah.revelationType == 'Medinan') return true;

      // البحث في النسبة المئوية
      if (query.contains('%')) {
        final percentStr = query.replaceAll('%', '').trim();
        final percent = double.tryParse(percentStr);
        if (percent != null) {
          final surahPercent = surah.averageProgress * 100;
          if (surahPercent >= percent) return true;
        }
      }

      return false;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد نتائج',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'ابحث عن سورة بالاسم أو الرقم'
                  : 'لم يتم العثور على نتائج لـ "$query"',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSearchTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: AppTheme.accentColor,
              ),
              SizedBox(width: 8),
              Text(
                'نصائح للبحث:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('ابحث باسم السورة (الفاتحة، البقرة)'),
          _buildTipItem('ابحث برقم السورة (1، 2، 114)'),
          _buildTipItem('ابحث بنوع السورة (مكية، مدنية)'),
          _buildTipItem('استخدم الفلاتر للتصنيف'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon() {
    switch (currentFilter) {
      case SurahFilter.completed:
        return Icons.check_circle_rounded;
      case SurahFilter.inProgress:
        return Icons.pending_rounded;
      case SurahFilter.notStarted:
        return Icons.radio_button_unchecked_rounded;
      case SurahFilter.meccan:
        return Icons.location_on;
      case SurahFilter.medinan:
        return Icons.location_city;
      case SurahFilter.all:
        return Icons.list_rounded;
    }
  }

  String _getFilterLabel() {
    switch (currentFilter) {
      case SurahFilter.completed:
        return 'السور المكتملة';
      case SurahFilter.inProgress:
        return 'السور الجارية';
      case SurahFilter.notStarted:
        return 'السور التي لم تبدأ';
      case SurahFilter.meccan:
        return 'السور المكية';
      case SurahFilter.medinan:
        return 'السور المدنية';
      case SurahFilter.all:
        return query.isEmpty ? 'جميع السور' : 'نتائج البحث';
    }
  }
}
