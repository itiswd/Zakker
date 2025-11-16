import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showDetails(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: surah.isCompleted
                ? LinearGradient(
                    colors: [AppTheme.successColor.withAlpha(13), Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSurahNumber(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                surah.nameArabic,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _buildRevelationType(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.auto_stories_rounded,
                              text:
                                  '${surah.memorizedPages}/${surah.totalPages}',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.article_rounded,
                              text:
                                  '${surah.memorizedVerses}/${surah.totalVerses}',
                            ),
                          ],
                        ),
                        if (surah.lastUpdated != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'آخر تحديث: ${_formatDate(surah.lastUpdated!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusIcon(),
                ],
              ),
              const SizedBox(height: 14),
              _buildProgressBar(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${(surah.averageProgress * 100).toStringAsFixed(0)}% مكتمل',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (surah.isCompleted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppTheme.successColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'مكتمل',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (surah.hasStarted) _buildResetButton(context, ref),
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: surah.isCompleted
            ? AppTheme.successGradient
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                (surah.isCompleted
                        ? AppTheme.successColor
                        : AppTheme.primaryColor)
                    .withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${surah.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildRevelationType() {
    final isMeccan = surah.revelationType == 'Meccan';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMeccan
            ? AppTheme.primaryColor.withAlpha(26)
            : const Color(0xFF2196F3).withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        surah.revelationTypeArabic,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isMeccan ? AppTheme.primaryColor : const Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (surah.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withAlpha(38),
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
      size: 28,
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SingleProgressBar(
                label: 'الصفحات',
                progress: surah.progressByPages,
                isCompleted: surah.memorizedPages >= surah.totalPages,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SingleProgressBar(
                label: 'الآيات',
                progress: surah.progressByVerses,
                isCompleted: surah.memorizedVerses >= surah.totalVerses,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showResetConfirmation(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 14, color: AppTheme.errorColor),
            SizedBox(width: 4),
            Text(
              'إعادة تعيين',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${intl.DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return intl.DateFormat('yyyy/MM/dd').format(date);
    }
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
            'هل تريد حذف التقدم المحفوظ في سورة ${surah.nameArabic}؟\n\n'
            'سيتم حذف ${surah.memorizedPages} صفحة و ${surah.memorizedVerses} آية.',
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
                    content: Text(
                      'تم إعادة تعيين تقدم سورة ${surah.nameArabic}',
                    ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final bool isCompleted;

  const _SingleProgressBar({
    required this.label,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? AppTheme.successGradient
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
