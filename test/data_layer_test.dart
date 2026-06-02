import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:nexgen_launcher/core/constants/app_constants.dart';
import 'package:nexgen_launcher/data/models/game_model.dart';
import 'package:nexgen_launcher/data/repositories/game_repository.dart';
import 'package:nexgen_launcher/data/sources/local/hive_service.dart';
import 'package:nexgen_launcher/data/sources/remote/gamezfull_scraper.dart';
import 'package:nexgen_launcher/data/sources/remote/pivigames_scraper.dart';
import 'package:nexgen_launcher/domain/entities/game.dart';

// ---------------------------------------------------------------------------
// Stub scrapers — override fetchGames to return predetermined lists
// ---------------------------------------------------------------------------

class StubPiviGamesScraper extends PiviGamesScraper {
  final List<Game> games;
  StubPiviGamesScraper(this.games);

  @override
  Future<List<Game>> fetchGames({int page = 1}) async => games;
}

class StubGamezFullScraper extends GamezFullScraper {
  final List<Game> games;
  StubGamezFullScraper(this.games);

  @override
  Future<List<Game>> fetchGames({int page = 1}) async => games;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Game fullGame({String id = 'a', String title = 'Alpha'}) {
  return Game(
    id: id,
    title: title,
    description: 'desc-$id',
    coverUrl: 'https://cover.example/$id.jpg',
    backdropUrl: 'https://bd.example/$id.jpg',
    magnetLink: 'magnet:?xt=urn:btih:$id',
    installPath: '/games/$id',
    executableName: '$id.exe',
    isInstalled: true,
    playTimeMinutes: 42,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // 1. Game entity
  // =========================================================================
  group('Game', () {
    test('constructor sets fields correctly', () {
      final game = fullGame();

      expect(game.id, 'a');
      expect(game.title, 'Alpha');
      expect(game.description, 'desc-a');
      expect(game.coverUrl, 'https://cover.example/a.jpg');
      expect(game.backdropUrl, 'https://bd.example/a.jpg');
      expect(game.magnetLink, 'magnet:?xt=urn:btih:a');
      expect(game.installPath, '/games/a');
      expect(game.executableName, 'a.exe');
      expect(game.isInstalled, true);
      expect(game.playTimeMinutes, 42);
    });

    test('default values for non-required fields', () {
      const game = Game(id: 'b', title: 'Beta');

      expect(game.description, '');
      expect(game.coverUrl, '');
      expect(game.backdropUrl, '');
      expect(game.magnetLink, isNull);
      expect(game.installPath, isNull);
      expect(game.executableName, isNull);
      expect(game.isInstalled, false);
      expect(game.playTimeMinutes, 0);
    });

    test('copyWith() returns new Game with changed fields, originals unchanged', () {
      final original = fullGame(id: 'x', title: 'Original');
      final copy = original.copyWith(
        id: 'y',
        title: 'Copy',
        description: 'new-desc',
        coverUrl: 'new-cover',
        backdropUrl: 'new-bd',
        magnetLink: 'new-magnet',
        installPath: '/new/path',
        executableName: 'new.exe',
        isInstalled: false,
        playTimeMinutes: 99,
      );

      // New instance with overridden fields
      expect(copy.id, 'y');
      expect(copy.title, 'Copy');
      expect(copy.description, 'new-desc');
      expect(copy.coverUrl, 'new-cover');
      expect(copy.backdropUrl, 'new-bd');
      expect(copy.magnetLink, 'new-magnet');
      expect(copy.installPath, '/new/path');
      expect(copy.executableName, 'new.exe');
      expect(copy.isInstalled, false);
      expect(copy.playTimeMinutes, 99);

      // Original unchanged
      expect(original.id, 'x');
      expect(original.title, 'Original');
      expect(original.description, 'desc-x');
      expect(original.isInstalled, true);
      expect(original.playTimeMinutes, 42);
    });

    test('copyWith() preserves original values when null is passed', () {
      final original = fullGame(id: 'g1', title: 'Keep');
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.coverUrl, original.coverUrl);
      expect(copy.backdropUrl, original.backdropUrl);
      expect(copy.magnetLink, original.magnetLink);
      expect(copy.installPath, original.installPath);
      expect(copy.executableName, original.executableName);
      expect(copy.isInstalled, original.isInstalled);
      expect(copy.playTimeMinutes, original.playTimeMinutes);
    });

    test('== returns true for same id, false for different id', () {
      final a1 = Game(id: '1', title: 'Game A');
      final a2 = Game(id: '1', title: 'Game A variant');
      final b = Game(id: '2', title: 'Game B');

      expect(a1 == a2, true);
      expect(a1 == b, false);
      expect(a2 == b, false);
    });

    test('hashCode equals for same id', () {
      final a1 = Game(id: '1', title: 'Foo');
      final a2 = Game(id: '1', title: 'Bar');

      expect(a1.hashCode, a2.hashCode);
    });

    test('Game.test() factory returns non-null Game with id=test_1', () {
      final testGame = Game.test();

      expect(testGame, isNotNull);
      expect(testGame.id, 'test_1');
      expect(testGame.title, 'Test Game');
      expect(testGame.description, 'A test game for development');
    });
  });

  // =========================================================================
  // 2. GameModel
  // =========================================================================
  group('GameModel', () {
    test('GameModel.fromEntity(game) maps all fields correctly', () {
      final entity = fullGame(id: 'e1', title: 'Entity');
      final model = GameModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.description, entity.description);
      expect(model.coverUrl, entity.coverUrl);
      expect(model.backdropUrl, entity.backdropUrl);
      expect(model.magnetLink, entity.magnetLink);
      expect(model.installPath, entity.installPath);
      expect(model.executableName, entity.executableName);
      expect(model.isInstalled, entity.isInstalled);
      expect(model.playTimeMinutes, entity.playTimeMinutes);
    });

    test('GameModel.fromEntity handles nullable fields as null', () {
      const entity = Game(id: 'min', title: 'Minimal');
      final model = GameModel.fromEntity(entity);

      expect(model.magnetLink, isNull);
      expect(model.installPath, isNull);
      expect(model.executableName, isNull);
      expect(model.isInstalled, false);
      expect(model.playTimeMinutes, 0);
    });

    test('gameModel.toEntity() returns Game with same fields', () {
      const model = GameModel(
        id: 'm1',
        title: 'Model',
        description: 'desc',
        coverUrl: 'cover',
        backdropUrl: 'bd',
        magnetLink: 'magnet:?xt=urn:btih:m1',
        installPath: '/path',
        executableName: 'm1.exe',
        isInstalled: true,
        playTimeMinutes: 60,
      );
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.title, model.title);
      expect(entity.description, model.description);
      expect(entity.coverUrl, model.coverUrl);
      expect(entity.backdropUrl, model.backdropUrl);
      expect(entity.magnetLink, model.magnetLink);
      expect(entity.installPath, model.installPath);
      expect(entity.executableName, model.executableName);
      expect(entity.isInstalled, model.isInstalled);
      expect(entity.playTimeMinutes, model.playTimeMinutes);
    });

    test('toEntity() round-trips with fromEntity()', () {
      final entity = fullGame(id: 'rt', title: 'RoundTrip');
      final model = GameModel.fromEntity(entity);
      final back = model.toEntity();

      expect(back, entity);
      expect(back.id, entity.id);
      expect(back.title, entity.title);
      expect(back.playTimeMinutes, entity.playTimeMinutes);
    });

    test('GameModelAdapter has typeId == 0', () {
      final adapter = GameModelAdapter();

      expect(adapter.typeId, 0);
    });
  });

  // =========================================================================
  // 3. HiveService
  // =========================================================================
  group('HiveService', () {
    late HiveService hiveService;

    setUpAll(() async {
      Hive.init(Directory.systemTemp.path);
      if (!Hive.isAdapterRegistered(GameModelAdapter().typeId)) {
        Hive.registerAdapter(GameModelAdapter());
      }
    });

    setUp(() async {
      hiveService = HiveService();
      await hiveService.openBox();
    });

    tearDown(() async {
      final box = hiveService.box;
      if (box != null && box.isOpen) {
        await box.clear();
        await box.close();
      }
    });

    test('openBox() opens a box without throwing', () async {
      final service = HiveService();
      await service.openBox();

      expect(service.box, isNotNull);
      expect(service.box!.isOpen, true);

      await service.closeBox();
    });

    test('openBox() is idempotent', () async {
      await hiveService.openBox();

      expect(hiveService.box, isNotNull);
      expect(hiveService.box!.isOpen, true);
    });

    test('saveGame() stores a game, getAllGames() returns it', () async {
      final game = fullGame(id: 'saved', title: 'Saved Game');

      await hiveService.saveGame(game);
      final results = await hiveService.getAllGames();

      expect(results.length, 1);
      expect(results.first.id, 'saved');
      expect(results.first.title, 'Saved Game');
      expect(results.first.playTimeMinutes, 42);
    });

    test('getAllGames() returns empty list when box is empty', () async {
      final results = await hiveService.getAllGames();

      expect(results, isEmpty);
    });

    test('saveGame() overwrites game with same id', () async {
      final v1 = Game(id: 'ow', title: 'First Write', playTimeMinutes: 10);
      final v2 = Game(id: 'ow', title: 'Overwrite', playTimeMinutes: 20);

      await hiveService.saveGame(v1);
      await hiveService.saveGame(v2);
      final results = await hiveService.getAllGames();

      expect(results.length, 1);
      expect(results.first.title, 'Overwrite');
      expect(results.first.playTimeMinutes, 20);
    });

    test('updatePlayTime() updates playTimeMinutes correctly', () async {
      final game = Game(id: 'pt', title: 'PlayTime', playTimeMinutes: 0);

      await hiveService.saveGame(game);
      await hiveService.updatePlayTime('pt', 120);
      final results = await hiveService.getAllGames();

      expect(results.length, 1);
      expect(results.first.playTimeMinutes, 120);
    });

    test('updatePlayTime() does nothing for non-existent id', () async {
      await hiveService.updatePlayTime('ghost', 999);
      final results = await hiveService.getAllGames();

      expect(results, isEmpty);
    });

    test('deleteGame() removes the game', () async {
      await hiveService.saveGame(Game(id: 'del', title: 'Delete Me'));
      expect((await hiveService.getAllGames()).length, 1);

      await hiveService.deleteGame('del');
      expect((await hiveService.getAllGames()), isEmpty);
    });

    test('deleteGame() does not throw when game does not exist', () async {
      await hiveService.deleteGame('nope');
      // Should not throw
    });

    test('clearAll() empties the box', () async {
      await hiveService.saveGame(Game(id: 'c1', title: 'Clear 1'));
      await hiveService.saveGame(Game(id: 'c2', title: 'Clear 2'));
      expect((await hiveService.getAllGames()).length, 2);

      await hiveService.saveGames([]);
      expect((await hiveService.getAllGames()), isEmpty);
    });
  });

  // =========================================================================
  // 4. GameRepository
  // =========================================================================
  group('GameRepository', () {
    late HiveService hiveService;

    setUpAll(() async {
      Hive.init(Directory.systemTemp.path);
      if (!Hive.isAdapterRegistered(GameModelAdapter().typeId)) {
        Hive.registerAdapter(GameModelAdapter());
      }
    });

    setUp(() async {
      hiveService = HiveService();
      await hiveService.openBox();
    });

    tearDown(() async {
      final box = hiveService.box;
      if (box != null && box.isOpen) {
        await box.clear();
        await box.close();
      }
    });

    GameRepository repoWith({
      List<Game> pivi = const [],
      List<Game> gamezfull = const [],
    }) {
      return GameRepository(
        hiveService: hiveService,
        piviGamesScraper: StubPiviGamesScraper(pivi),
        gamezFullScraper: StubGamezFullScraper(gamezfull),
      );
    }

    test('fetchAndCacheGames() merges results from both scrapers', () async {
      final a = Game(id: '1', title: 'A');
      final b = Game(id: '2', title: 'B');
      final c = Game(id: '3', title: 'C');

      final repo = repoWith(
        pivi: [a, b],
        gamezfull: [c],
      );

      final merged = await repo.fetchAndCacheGames();

      expect(merged.length, 3);
      expect(merged.map((g) => g.id).toSet(), {'1', '2', '3'});
    });

    test('fetchAndCacheGames() deduplicates by id', () async {
      final game1a = Game(id: '1', title: 'Shared', description: 'from pivi');
      final game1b = Game(id: '1', title: 'Shared', description: 'from gamezfull');
      final unique = Game(id: '2', title: 'Only Here');

      final repo = repoWith(
        pivi: [game1a],
        gamezfull: [game1b, unique],
      );

      final merged = await repo.fetchAndCacheGames();

      expect(merged.length, 2);
      expect(merged.where((g) => g.id == '1').length, 1);
      expect(merged.where((g) => g.id == '2').length, 1);
    });

    test('fetchAndCacheGames() handles empty scrapers', () async {
      final repo = repoWith();

      final merged = await repo.fetchAndCacheGames();

      expect(merged, isEmpty);
    });

    test('fetchAndCacheGames() caches results in Hive', () async {
      final game = Game(id: 'cached', title: 'Cached');
      final repo = repoWith(pivi: [game]);

      await repo.fetchAndCacheGames();
      final local = await hiveService.getAllGames();

      expect(local.length, 1);
      expect(local.first.id, 'cached');
    });

    test('searchGames() filters correctly by title', () {
      final games = [
        Game(id: '1', title: 'Action Arena'),
        Game(id: '2', title: 'Adventure Quest'),
        Game(id: '3', title: 'Racing Thunder'),
      ];
      final repo = repoWith();

      final results = repo.searchGames('action', from: games);

      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('searchGames() filters by description too', () {
      final games = [
        Game(id: '1', title: 'Foo', description: 'bar'),
        Game(id: '2', title: 'Baz', description: 'qux action packed'),
      ];
      final repo = repoWith();

      final results = repo.searchGames('action', from: games);

      expect(results.length, 1);
      expect(results.first.id, '2');
    });

    test('searchGames() is case-insensitive', () {
      final games = [
        Game(id: '1', title: 'ACTION'),
        Game(id: '2', title: 'action'),
        Game(id: '3', title: 'Action'),
      ];
      final repo = repoWith();

      final results = repo.searchGames('ACTion', from: games);

      expect(results.length, 3);
    });

    test('searchGames() returns all games when query is empty', () {
      final games = [
        Game(id: '1', title: 'A'),
        Game(id: '2', title: 'B'),
      ];
      final repo = repoWith();

      final results = repo.searchGames('', from: games);

      expect(results.length, 2);
    });

    test('searchGames() returns empty when nothing matches', () {
      final games = [Game(id: '1', title: 'Zelda')];
      final repo = repoWith();

      final results = repo.searchGames('xylophone', from: games);

      expect(results, isEmpty);
    });

    test('markInstalled() updates isInstalled=true in Hive', () async {
      final game = Game(id: 'inst', title: 'Install Me', isInstalled: false);
      await hiveService.saveGame(game);

      final repo = repoWith();
      await repo.markInstalled('inst', '/mnt/games/inst', 'game.exe');

      final local = await hiveService.getAllGames();
      expect(local.length, 1);
      expect(local.first.id, 'inst');
      expect(local.first.isInstalled, true);
      expect(local.first.installPath, '/mnt/games/inst');
      expect(local.first.executableName, 'game.exe');
    });

    test('markInstalled() does nothing for non-existent id', () async {
      final repo = repoWith();
      await repo.markInstalled('ghost', '/fake', 'none.exe');

      final local = await hiveService.getAllGames();
      expect(local, isEmpty);
    });

    test('markInstalled() preserves other fields', () async {
      final game = Game(
        id: 'keep',
        title: 'Preserve Me',
        description: 'original desc',
        coverUrl: 'original cover',
        playTimeMinutes: 30,
        isInstalled: false,
      );
      await hiveService.saveGame(game);

      final repo = repoWith();
      await repo.markInstalled('keep', '/path', 'run.exe');

      final local = await hiveService.getAllGames();
      expect(local.first.title, 'Preserve Me');
      expect(local.first.description, 'original desc');
      expect(local.first.coverUrl, 'original cover');
      expect(local.first.playTimeMinutes, 30);
    });

    test('updatePlayTime() delegates to hiveService', () async {
      final game = Game(id: 'play', title: 'Playable', playTimeMinutes: 0);
      await hiveService.saveGame(game);

      final repo = repoWith();
      await repo.updatePlayTime('play', 180);

      final local = await hiveService.getAllGames();
      expect(local.first.playTimeMinutes, 180);
    });
  });
}
