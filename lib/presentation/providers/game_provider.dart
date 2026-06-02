import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game.dart';
import '../../data/sources/local/hive_service.dart';
import '../../data/sources/remote/pivigames_scraper.dart';
import '../../data/sources/remote/gamezfull_scraper.dart';
import '../../data/repositories/game_repository.dart';
import '../../services/process_manager_service.dart';

final hiveServiceProvider = FutureProvider<HiveService>((ref) async {
  try {
    final service = HiveService();
    await service.openBox();
    return service;
  } catch (e) {
    rethrow;
  }
});

final piviScraperProvider = Provider<PiviGamesScraper>((ref) {
  return PiviGamesScraper();
});

final gamezFullScraperProvider = Provider<GamezFullScraper>((ref) {
  return GamezFullScraper();
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider).asData?.value;
  final piviScraper = ref.watch(piviScraperProvider);
  final gamezFullScraper = ref.watch(gamezFullScraperProvider);

  if (hiveService == null) {
    throw StateError('HiveService not initialized');
  }

  return GameRepository(
    hiveService: hiveService,
    piviGamesScraper: piviScraper,
    gamezFullScraper: gamezFullScraper,
  );
});

final gamesListProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.fetchAndCacheGames();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredGamesProvider = Provider.autoDispose<List<Game>>((ref) {
  final gamesAsync = ref.watch(gamesListProvider);
  final query = ref.watch(searchQueryProvider);

  final games = gamesAsync.valueOrNull ?? [];
  if (query.isEmpty) return games;

  final repository = ref.watch(gameRepositoryProvider);
  return repository.searchGames(query, from: games);
});

final currentPageProvider = StateProvider<int>((ref) => 1);

final selectedGameIdProvider = StateProvider<String?>((ref) => null);

final processManagerProvider = Provider<ProcessManagerService>((ref) {
  return ProcessManagerService.instance;
});

final isGameRunningProvider = StateProvider<bool>((ref) => false);

final activeGameIdProvider = StateProvider<String?>((ref) => null);
