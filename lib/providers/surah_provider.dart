import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/surah_data.dart';
import '../models/surah.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final surahListProvider =
    StateNotifierProvider<SurahListNotifier, AsyncValue<List<Surah>>>((ref) {
      return SurahListNotifier(ref.watch(storageServiceProvider));
    });

class SurahListNotifier extends StateNotifier<AsyncValue<List<Surah>>> {
  final StorageService _storageService;

  SurahListNotifier(this._storageService) : super(const AsyncValue.loading()) {
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    state = const AsyncValue.loading();

    try {
      final savedSurahs = await _storageService.loadSurahs();

      if (savedSurahs.isEmpty) {
        state = AsyncValue.data(List.from(SurahData.defaultSurahs));
        await _storageService.saveSurahs(SurahData.defaultSurahs);
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
    int memorizedAyahs,
  ) async {
    state.whenData((surahs) async {
      final updatedSurahs = surahs.map((surah) {
        if (surah.number == surahNumber) {
          return surah.copyWith(
            memorizedPages: memorizedPages,
            memorizedAyahs: memorizedAyahs,
          );
        }
        return surah;
      }).toList();

      state = AsyncValue.data(updatedSurahs);
      await _storageService.saveSurahs(updatedSurahs);
    });
  }

  Future<void> resetSurahProgress(int surahNumber) async {
    state.whenData((surahs) async {
      final updatedSurahs = surahs.map((surah) {
        if (surah.number == surahNumber) {
          return surah.copyWith(memorizedPages: 0, memorizedAyahs: 0);
        }
        return surah;
      }).toList();

      state = AsyncValue.data(updatedSurahs);
      await _storageService.saveSurahs(updatedSurahs);
    });
  }

  Future<void> resetAllProgress() async {
    state = AsyncValue.data(List.from(SurahData.defaultSurahs));
    await _storageService.clearAllData();
    await _storageService.saveSurahs(SurahData.defaultSurahs);
  }
}

// Provider للإحصائيات
final statsProvider = Provider<Map<String, dynamic>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);

  return surahsAsync.when(
    data: (surahs) {
      final totalMemorizedPages = surahs.fold<int>(
        0,
        (sum, surah) => sum + surah.memorizedPages,
      );
      final totalMemorizedAyahs = surahs.fold<int>(
        0,
        (sum, surah) => sum + surah.memorizedAyahs,
      );

      final pagesPercentage =
          (totalMemorizedPages / SurahData.totalPages) * 100;
      final ayahsPercentage =
          (totalMemorizedAyahs / SurahData.totalAyahs) * 100;

      return {
        'totalMemorizedPages': totalMemorizedPages,
        'totalMemorizedAyahs': totalMemorizedAyahs,
        'totalPages': SurahData.totalPages,
        'totalAyahs': SurahData.totalAyahs,
        'pagesPercentage': pagesPercentage,
        'ayahsPercentage': ayahsPercentage,
      };
    },
    loading: () => {
      'totalMemorizedPages': 0,
      'totalMemorizedAyahs': 0,
      'totalPages': SurahData.totalPages,
      'totalAyahs': SurahData.totalAyahs,
      'pagesPercentage': 0.0,
      'ayahsPercentage': 0.0,
    },
    error: (_, __) => {
      'totalMemorizedPages': 0,
      'totalMemorizedAyahs': 0,
      'totalPages': SurahData.totalPages,
      'totalAyahs': SurahData.totalAyahs,
      'pagesPercentage': 0.0,
      'ayahsPercentage': 0.0,
    },
  );
});
