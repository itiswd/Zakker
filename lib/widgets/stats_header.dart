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
                'إجمالي الحفظ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // كروت الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.auto_stories_rounded,
                      title: 'الصفحات',
                      value: '${stats['totalMemorizedPages']}',
                      total: '${stats['totalPages']}',
                      percentage: stats['pagesPercentage'] as double,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.article_rounded,
                      title: 'الآيات',
                      value: '${stats['totalMemorizedAyahs']}',
                      total: '${stats['totalAyahs']}',
                      percentage: stats['ayahsPercentage'] as double,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // الأيقونة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(height: 4),

          // العنوان
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // الرقم الرئيسي
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          // من إجمالي
          Text(
            'من $total',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),

          // النسبة المئوية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: AlignmentGeometry.center,
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getPercentageColor(percentage),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
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

class _OverallProgressBar extends StatelessWidget {
  final double percentage;

  const _OverallProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط التقدم
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * (percentage / 100),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // النص
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'نسبة الإنجاز الكلية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // رسالة تحفيزية
        if (percentage > 0) ...[
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(percentage),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 100) return 'ما شاء الله! أتممت حفظ القرآن الكريم🎉';
    if (percentage >= 75) return 'ممتاز! أنت قريب من إتمام الحفظ💪';
    if (percentage >= 50) return 'رائع! أنت في منتصف الطريق🌟';
    if (percentage >= 25) return 'بداية موفقة! استمر في المذاكرة✨';
    return 'انطلق في رحلة الحفظ المباركة🚀';
  }
}
