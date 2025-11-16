import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';

class StatsHeader extends ConsumerWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              // العنوان
              const Text(
                'إحصائيات الحفظ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // كروت الإحصائيات الرئيسية
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.menu_book_rounded,
                      title: 'الصفحات',
                      value: '${stats['totalMemorizedPages']}',
                      total: '${stats['totalPages']}',
                      percentage: stats['pagesPercentage'] as double,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.article_rounded,
                      title: 'الآيات',
                      value: '${stats['totalMemorizedVerses']}',
                      total: '${stats['totalVerses']}',
                      percentage: stats['versesPercentage'] as double,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // كرت السور
              _SurahsStatsCard(
                completedSurahs: stats['completedSurahs'] as int,
                inProgressSurahs: stats['inProgressSurahs'] as int,
                notStartedSurahs: stats['notStartedSurahs'] as int,
                totalSurahs: stats['totalSurahs'] as int,
              ),
              const SizedBox(height: 24),

              // شريط التقدم الكلي
              _OverallProgressBar(
                percentage: stats['pagesPercentage'] as double,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String total;
  final double percentage;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'من $total',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getPercentageColor(percentage),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.successColor;
    if (percentage >= 50) return const Color(0xFFFFB300);
    if (percentage >= 25) return const Color(0xFFFF9800);
    return AppTheme.primaryColor;
  }
}

class _SurahsStatsCard extends StatelessWidget {
  final int completedSurahs;
  final int inProgressSurahs;
  final int notStartedSurahs;
  final int totalSurahs;

  const _SurahsStatsCard({
    required this.completedSurahs,
    required this.inProgressSurahs,
    required this.notStartedSurahs,
    required this.totalSurahs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_books_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'إحصائيات السور',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SurahStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'مكتملة',
                  value: completedSurahs,
                  color: AppTheme.successColor,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.dividerColor),
              Expanded(
                child: _SurahStatItem(
                  icon: Icons.pending_rounded,
                  label: 'جارية',
                  value: inProgressSurahs,
                  color: const Color(0xFFFFB300),
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.dividerColor),
              Expanded(
                child: _SurahStatItem(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'متبقية',
                  value: notStartedSurahs,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _SurahStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _OverallProgressBar extends StatelessWidget {
  final double percentage;

  const _OverallProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'نسبة الإنجاز الكلية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (percentage > 0) ...[
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(percentage),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 100) return 'ما شاء الله! أتممت حفظ القرآن الكريم 🎉';
    if (percentage >= 75) return 'ممتاز! أنت قريب من إتمام الحفظ 💪';
    if (percentage >= 50) return 'رائع! أنت في منتصف الطريق 🌟';
    if (percentage >= 25) return 'بداية موفقة! استمر في المذاكرة ✨';
    return 'انطلق في رحلة الحفظ المباركة 🚀';
  }
}
