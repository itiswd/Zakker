import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/stats_header.dart';
import '../widgets/surah_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: surahsAsync.when(
          data: (surahs) => _buildContent(context, ref, surahs),
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
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.invalidate(surahListProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('متابعة الحفظ'),
          Spacer(),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'تحديث',
          onPressed: () {
            ref.invalidate(surahListProvider);
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'reset') {
              _showResetDialog(context, ref);
            } else if (value == 'about') {
              _showAboutDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.restart_alt, size: 20),
                  SizedBox(width: 12),
                  Text('إعادة تعيين الكل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 12),
                  Text('عن التطبيق'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List surahs) {
    if (surahs.isEmpty) {
      return const EmptyState();
    }

    return CustomScrollView(
      slivers: [
        // قسم الإحصائيات
        const SliverToBoxAdapter(child: StatsHeader()),

        // قائمة السور
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return SurahCard(surah: surahs[index]);
            }, childCount: surahs.length),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
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
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف جميع التقدم المحفوظ؟\n\n'
            'سيتم حذف جميع الصفحات والآيات المحفوظة ولن يمكن استرجاعها.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(surahListProvider.notifier).resetAllProgress();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إعادة تعيين جميع البيانات بنجاح'),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('حذف الكل'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text('عن التطبيق'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تطبيق متابعة حفظ القرآن الكريم',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text('المميزات:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              _FeatureItem(
                icon: Icons.check_circle,
                text: 'تسجيل عدد الصفحات والآيات المحفوظة',
              ),
              _FeatureItem(
                icon: Icons.check_circle,
                text: 'متابعة نسبة الإنجاز لكل سورة',
              ),
              _FeatureItem(
                icon: Icons.check_circle,
                text: 'إحصائيات شاملة للحفظ',
              ),
              _FeatureItem(icon: Icons.check_circle, text: 'واجهة سهلة وجميلة'),
              _FeatureItem(
                icon: Icons.check_circle,
                text: 'إمكانية حذف التقدم',
              ),
              SizedBox(height: 16),
              Text(
                '﴿ وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا ﴾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'وفقك الله في حفظ كتابه الكريم 🤲',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.successColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
