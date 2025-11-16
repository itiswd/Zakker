import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../providers/surah_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/stats_header.dart';
import '../widgets/surah_card.dart';

enum SurahFilter { all, completed, inProgress, notStarted, meccan, medinan }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SurahFilter _currentFilter = SurahFilter.all;
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: surahsAsync.when(
          data: (surahs) => _buildContent(context, ref, surahs),
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل البيانات...'),
              ],
            ),
          ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
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
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('متابعة الحفظ'),
          const Spacer(),
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
                  Icon(
                    Icons.restart_alt,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text('إعادة تعيين الكل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Surah> surahs,
  ) {
    if (surahs.isEmpty) {
      return const EmptyState();
    }

    // تطبيق الفلاتر والبحث
    var filteredSurahs = _applyFilter(surahs);
    if (_searchQuery.isNotEmpty) {
      filteredSurahs = _searchSurahs(filteredSurahs, _searchQuery);
    }

    return CustomScrollView(
      slivers: [
        // قسم الإحصائيات
        const SliverToBoxAdapter(child: StatsHeader()),

        // خانة البحث
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, _isSearchActive ? 16 : 16, 16, 8),
            child: _buildSearchBar(context, ref),
          ),
        ),

        // أزرار الفلاتر
        SliverToBoxAdapter(child: _buildFilterChips()),

        // عداد النتائج
        if (_searchQuery.isNotEmpty || _currentFilter != SurahFilter.all)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildResultsHeader(filteredSurahs.length),
            ),
          ),

        // قائمة السور
        if (filteredSurahs.isEmpty)
          SliverFillRemaining(child: _buildEmptyResults())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return SurahCard(surah: filteredSurahs[index]);
              }, childCount: filteredSurahs.length),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: _isSearchActive ? 4 : 2,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withAlpha(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearchActive
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
            width: _isSearchActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن سورة بالاسم أو الرقم...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _isSearchActive = value.isNotEmpty;
                  });
                },
                onTap: () {
                  setState(() {
                    _isSearchActive = true;
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearchActive = false;
                    _currentFilter = SurahFilter.all;
                  });
                },
              )
            else
              PopupMenuButton<SurahFilter>(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (filter) {
                  setState(() {
                    _currentFilter = filter;
                    _isSearchActive = true;
                  });
                },
                itemBuilder: (context) => [
                  _buildFilterMenuItem(
                    SurahFilter.all,
                    'جميع السور',
                    Icons.list_rounded,
                  ),
                  const PopupMenuDivider(),
                  _buildFilterMenuItem(
                    SurahFilter.completed,
                    'السور المكتملة',
                    Icons.check_circle_rounded,
                  ),
                  _buildFilterMenuItem(
                    SurahFilter.inProgress,
                    'السور الجارية',
                    Icons.pending_rounded,
                  ),
                  _buildFilterMenuItem(
                    SurahFilter.notStarted,
                    'السور التي لم تبدأ',
                    Icons.radio_button_unchecked_rounded,
                  ),
                  const PopupMenuDivider(),
                  _buildFilterMenuItem(
                    SurahFilter.meccan,
                    'السور المكية',
                    Icons.location_on,
                  ),
                  _buildFilterMenuItem(
                    SurahFilter.medinan,
                    'السور المدنية',
                    Icons.location_city,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SurahFilter> _buildFilterMenuItem(
    SurahFilter filter,
    String label,
    IconData icon,
  ) {
    final isSelected = _currentFilter == filter;
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 20, color: AppTheme.primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 16),
          _buildFilterChip(SurahFilter.all, 'الكل', Icons.list_rounded),
          _buildFilterChip(
            SurahFilter.completed,
            'مكتملة',
            Icons.check_circle_rounded,
          ),
          _buildFilterChip(
            SurahFilter.inProgress,
            'جارية',
            Icons.pending_rounded,
          ),
          _buildFilterChip(
            SurahFilter.notStarted,
            'متبقية',
            Icons.radio_button_unchecked_rounded,
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(SurahFilter filter, String label, IconData icon) {
    final isSelected = _currentFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _currentFilter = filter;
          });
        },
        checkmarkColor: AppTheme.cardColor,
        selectedColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.primaryColor.withAlpha(26),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(_getFilterIcon(), size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            _getFilterLabel(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count سورة',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
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
              _searchQuery.isEmpty
                  ? 'لم يتم العثور على سور بهذا الفلتر'
                  : 'لم يتم العثور على نتائج لـ "$_searchQuery"',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _currentFilter = SurahFilter.all;
                  _isSearchActive = false;
                });
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('إعادة تعيين البحث'),
            ),
          ],
        ),
      ),
    );
  }

  List<Surah> _applyFilter(List<Surah> surahs) {
    switch (_currentFilter) {
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
      if (query == 'مكية' && surah.revelationType == 'Meccan') return true;
      if (query == 'مدنية' && surah.revelationType == 'Medinan') return true;

      return false;
    }).toList();
  }

  IconData _getFilterIcon() {
    switch (_currentFilter) {
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
    switch (_currentFilter) {
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
        return _searchQuery.isEmpty ? 'جميع السور' : 'نتائج البحث';
    }
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
              onPressed: () async {
                await ref.read(surahListProvider.notifier).resetAllProgress();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إعادة تعيين جميع البيانات بنجاح'),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
                  color: AppTheme.primaryColor.withAlpha(26),
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
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تطبيق متابعة حفظ القرآن الكريم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'النسخة 1.0 - محسّنة بباكج Quran',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 16),
                Text(
                  'المميزات:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'بيانات دقيقة 100% من مصدر موثوق',
                ),
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
                  text: 'إحصائيات شاملة ومفصلة',
                ),
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'معلومات السور (مكية/مدنية)',
                ),
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'واجهة سهلة وجميلة',
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
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
