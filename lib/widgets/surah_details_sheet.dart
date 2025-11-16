import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';

class SurahDetailsSheet extends ConsumerStatefulWidget {
  final Surah surah;

  const SurahDetailsSheet({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailsSheet> createState() => _SurahDetailsSheetState();
}

class _SurahDetailsSheetState extends ConsumerState<SurahDetailsSheet>
    with SingleTickerProviderStateMixin {
  late int memorizedPages;
  late int memorizedAyahs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    memorizedPages = widget.surah.memorizedPages;
    memorizedAyahs = widget.surah.memorizedVerses;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startLongPress(
    Function(int) onChanged,
    int value,
    int max,
    bool isIncrement,
  ) {
    _longPressTimer?.cancel();
    _longPressTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (isIncrement) {
        if (value < max) {
          onChanged(value + 1);
        } else {
          timer.cancel();
        }
      } else {
        if (value > 0) {
          onChanged(value - 1);
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _stopLongPress() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 8,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مؤشر السحب
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // عنوان السورة
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // عداد الصفحات
                  _buildCounter(
                    icon: Icons.auto_stories_rounded,
                    label: 'عدد الصفحات المحفوظة',
                    value: memorizedPages,
                    max: widget.surah.totalPages,
                    onChanged: (value) =>
                        setState(() => memorizedPages = value),
                  ),
                  const SizedBox(height: 20),

                  // عداد الآيات
                  _buildCounter(
                    icon: Icons.article_rounded,
                    label: 'عدد الآيات المحفوظة',
                    value: memorizedAyahs,
                    max: widget.surah.totalVerses,
                    onChanged: (value) =>
                        setState(() => memorizedAyahs = value),
                  ),
                  const SizedBox(height: 32),

                  // الأزرار
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سورة ${widget.surah.nameArabic}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'السورة رقم ${widget.surah.number}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required IconData icon,
    required String label,
    required int value,
    required int max,
    required Function(int) onChanged,
  }) {
    final progress = max > 0 ? value / max : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع الأيقونة
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // العداد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر الإنقاص
              _CounterButton(
                icon: Icons.remove_rounded,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                onLongPressStart: value > 0
                    ? () => _startLongPress(onChanged, value, max, false)
                    : null,
                onLongPressEnd: _stopLongPress,
              ),

              // القيمة والإجمالي
              Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'من $max',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              // زر الزيادة
              _CounterButton(
                icon: Icons.add_rounded,
                onPressed: value < max ? () => onChanged(value + 1) : null,
                onLongPressStart: value < max
                    ? () => _startLongPress(onChanged, value, max, true)
                    : null,
                onLongPressEnd: _stopLongPress,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // شريط التقدم
          ClipRRect(
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
                      duration: const Duration(milliseconds: 200),
                      width: constraints.maxWidth * progress,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: progress == 1.0
                            ? AppTheme.successGradient
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // النسبة المئوية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (progress == 1.0)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'مكتمل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _saveProgress,
            icon: const Icon(Icons.check_rounded),
            label: const Text('حفظ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('إلغاء'),
          ),
        ),
      ],
    );
  }

  void _saveProgress() {
    ref
        .read(surahListProvider.notifier)
        .updateSurah(widget.surah.number, memorizedPages, memorizedAyahs);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ التقدم في سورة ${widget.surah.nameArabic}'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            ref
                .read(surahListProvider.notifier)
                .updateSurah(
                  widget.surah.number,
                  widget.surah.memorizedPages,
                  widget.surah.memorizedVerses,
                );
          },
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const _CounterButton({
    required this.icon,
    this.onPressed,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPressStart: onLongPressStart != null
          ? (_) => onLongPressStart!()
          : null,
      onLongPressEnd: onLongPressEnd != null ? (_) => onLongPressEnd!() : null,
      onLongPressCancel: onLongPressEnd,
      child: Material(
        color: onPressed != null
            ? AppTheme.primaryColor
            : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: onPressed != null ? AppTheme.cardShadow : null,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : AppTheme.textSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
