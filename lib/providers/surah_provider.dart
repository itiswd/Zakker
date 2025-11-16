import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../services/quran_data_service.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final surahListProvider =
    NotifierProvider<SurahListNotifier, AsyncValue<List<Surah>>>(
      SurahListNotifier.new,
    );

class SurahListNotifier extends Notifier<AsyncValue<List<Surah>>> {
  late final StorageService _storageService;

  @override
  AsyncValue<List<Surah>> build() {
    _storageService = ref.watch(storageServiceProvider);
    _loadSurahs();
    return const AsyncValue.loading();
  }

  Future<void> _loadSurahs() async {
    state = const AsyncValue.loading();

    try {
      final savedSurahs = await _storageService.loadSurahs();

      if (savedSurahs.isEmpty) {
        // استخدام بيانات من باكج quran
        final defaultSurahs = QuranDataService.getAllSurahs();
        state = AsyncValue.data(defaultSurahs);
        await _storageService.saveSurahs(defaultSurahs);
      } else {
        state = AsyncValue.data(savedSurahs);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSurah(
    int surahNumber,
    int memorizedPages,
    int memorizedVerses, {
    List<int>? memorizedPageNumbers,
  }) async {
    final currentState = state;

    currentState.whenData((surahs) async {
      final updatedSurahs = surahs.map((surah) {
        if (surah.number == surahNumber) {
          return surah.copyWith(
            memorizedPages: memorizedPages,
            memorizedVerses: memorizedVerses,
            memorizedPageNumbers: memorizedPageNumbers,
            lastUpdated: DateTime.now(),
          );
        }
        return surah;
      }).toList();

      state = AsyncValue.data(updatedSurahs);
      await _storageService.saveSurahs(updatedSurahs);
    });
  }

  Future<void> resetSurahProgress(int surahNumber) async {
    final currentState = state;

    currentState.whenData((surahs) async {
      final updatedSurahs = surahs.map((surah) {
        if (surah.number == surahNumber) {
          return surah.copyWith(
            memorizedPages: 0,
            memorizedVerses: 0,
            memorizedPageNumbers: [],
            lastUpdated: DateTime.now(),
          );
        }
        return surah;
      }).toList();

      state = AsyncValue.data(updatedSurahs);
      await _storageService.saveSurahs(updatedSurahs);
    });
  }

  Future<void> resetAllProgress() async {
    final defaultSurahs = QuranDataService.getAllSurahs();
    state = AsyncValue.data(defaultSurahs);
    await _storageService.clearAllData();
    await _storageService.saveSurahs(defaultSurahs);
  }

  Future<void> refreshData() async {
    await _loadSurahs();
  }
}

// Provider للإحصائيات المحسّنة
final statsProvider = Provider<Map<String, dynamic>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);

  return surahsAsync.when(
    data: (surahs) {
      final totalMemorizedPages = QuranDataService.calculateTotalMemorizedPages(
        surahs,
      );
      final totalMemorizedVerses =
          QuranDataService.calculateTotalMemorizedVerses(surahs);
      final completedSurahs = QuranDataService.getCompletedSurahsCount(surahs);
      final inProgressSurahs = QuranDataService.getInProgressSurahsCount(
        surahs,
      );

      final totalPages = QuranDataService.totalPages;
      final totalVerses = QuranDataService.getTotalVerses();

      final pagesPercentage = (totalMemorizedPages / totalPages) * 100;
      final versesPercentage = (totalMemorizedVerses / totalVerses) * 100;
      final surahsPercentage =
          (completedSurahs / QuranDataService.totalSurahs) * 100;

      return {
        'totalMemorizedPages': totalMemorizedPages,
        'totalMemorizedVerses': totalMemorizedVerses,
        'totalPages': totalPages,
        'totalVerses': totalVerses,
        'pagesPercentage': pagesPercentage,
        'versesPercentage': versesPercentage,
        'completedSurahs': completedSurahs,
        'inProgressSurahs': inProgressSurahs,
        'totalSurahs': QuranDataService.totalSurahs,
        'surahsPercentage': surahsPercentage,
        'notStartedSurahs':
            QuranDataService.totalSurahs - completedSurahs - inProgressSurahs,
      };
    },
    loading: () => {
      'totalMemorizedPages': 0,
      'totalMemorizedVerses': 0,
      'totalPages': QuranDataService.totalPages,
      'totalVerses': QuranDataService.getTotalVerses(),
      'pagesPercentage': 0.0,
      'versesPercentage': 0.0,
      'completedSurahs': 0,
      'inProgressSurahs': 0,
      'totalSurahs': QuranDataService.totalSurahs,
      'surahsPercentage': 0.0,
      'notStartedSurahs': QuranDataService.totalSurahs,
    },
    error: (_, __) => {
      'totalMemorizedPages': 0,
      'totalMemorizedVerses': 0,
      'totalPages': QuranDataService.totalPages,
      'totalVerses': QuranDataService.getTotalVerses(),
      'pagesPercentage': 0.0,
      'versesPercentage': 0.0,
      'completedSurahs': 0,
      'inProgressSurahs': 0,
      'totalSurahs': QuranDataService.totalSurahs,
      'surahsPercentage': 0.0,
      'notStartedSurahs': QuranDataService.totalSurahs,
    },
  );
});

// Provider للسور المكتملة
final completedSurahsProvider = Provider<List<Surah>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);
  return surahsAsync.maybeWhen(
    data: (surahs) => surahs.where((s) => s.isCompleted).toList(),
    orElse: () => [],
  );
});

// Provider للسور قيد الحفظ
final inProgressSurahsProvider = Provider<List<Surah>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);
  return surahsAsync.maybeWhen(
    data: (surahs) =>
        surahs.where((s) => s.hasStarted && !s.isCompleted).toList(),
    orElse: () => [],
  );
});

// Provider للسور التي لم تبدأ
final notStartedSurahsProvider = Provider<List<Surah>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);
  return surahsAsync.maybeWhen(
    data: (surahs) => surahs.where((s) => !s.hasStarted).toList(),
    orElse: () => [],
  );
});
