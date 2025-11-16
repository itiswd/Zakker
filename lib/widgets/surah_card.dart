import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/surah_details_sheet.dart';

class SurahCard extends ConsumerWidget {
  final Surah surah;

  const SurahCard({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetails(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // رقم السورة
                  _buildSurahNumber(),
                  const SizedBox(width: 14),

                  // معلومات السورة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // أيقونة الحالة
                  _buildStatusIcon(),
                ],
              ),
              const SizedBox(height: 14),

              // شريط التقدم
              _buildProgressBar(),
              const SizedBox(height: 8),

              // النسبة المئوية والإجراءات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(surah.progress * 100).toStringAsFixed(0)}% مكتمل',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (surah.memorizedPages > 0 || surah.memorizedAyahs > 0)
                    _buildResetButton(context, ref),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahNumber() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: surah.isCompleted
            ? AppTheme.successGradient
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (surah.isCompleted
                        ? AppTheme.successColor
                        : AppTheme.primaryColor)
                    .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${surah.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (surah.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: AppTheme.successColor,
          size: 24,
        ),
      );
    }

    return const Icon(
      Icons.chevron_left_rounded,
      color: AppTheme.textSecondary,
      size: 24,
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * surah.progress,
                height: 10,
                decoration: BoxDecoration(
                  gradient: surah.isCompleted
                      ? AppTheme.successGradient
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showResetConfirmation(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 16, color: AppTheme.errorColor),
            SizedBox(width: 4),
            Text(
              'إعادة تعيين',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SurahDetailsSheet(surah: surah),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('إعادة تعيين التقدم'),
            ],
          ),
          content: Text(
            'هل تريد حذف التقدم المحفوظ في سورة ${surah.name}؟\n\n'
            'سيتم حذف ${surah.memorizedPages} صفحة و ${surah.memorizedAyahs} آية.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(surahListProvider.notifier)
                    .resetSurahProgress(surah.number);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إعادة تعيين تقدم سورة ${surah.name}'),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }
}
