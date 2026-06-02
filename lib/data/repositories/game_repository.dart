import '../../domain/entities/game.dart';
import '../sources/local/hive_service.dart';
import '../sources/remote/pivigames_scraper.dart';
import '../sources/remote/gamezfull_scraper.dart';

class GameRepository {
  final HiveService _hiveService;
  final PiviGamesScraper _piviGamesScraper;
  final GamezFullScraper _gamezFullScraper;

  GameRepository({
    required this._hiveService,
    required this._piviGamesScraper,
    required this._gamezFullScraper,
  });

  Future<List<Game>> fetchAndCacheGames({int page = 1}) async {
    final results = await Future.wait([
      _piviGamesScraper.fetchGames(page: page),
      _gamezFullScraper.fetchGames(page: page),
    ]);

    final List<Game> merged = [];
    final Set<String> seenIds = {};

    for (final list in results) {
      for (final game in list) {
        if (seenIds.add(game.id)) {
          merged.add(game);
        }
      }
    }

    try {
      await _hiveService.saveGames(merged);
    } catch (_) {}

    return merged;
  }

  Future<List<Game>> getLocalGames() async {
    return _hiveService.getAllGames();
  }

  List<Game> searchGames(String query, {required List<Game> from}) {
    if (query.isEmpty) return from;
    final lowerQuery = query.toLowerCase();
    return from.where((game) {
      return game.title.toLowerCase().contains(lowerQuery) ||
          game.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> markInstalled(String id, String path, String exe) async {
    final games = await _hiveService.getAllGames();
    final found = games.where((g) => g.id == id).toList();
    if (found.isEmpty) return;
    final game = found.first;
    final updated = game.copyWith(
      installPath: path,
      executableName: exe,
      isInstalled: true,
    );
    await _hiveService.saveGame(updated);
  }

  Future<void> updatePlayTime(String id, int minutes) async {
    await _hiveService.updatePlayTime(id, minutes);
  }
}
