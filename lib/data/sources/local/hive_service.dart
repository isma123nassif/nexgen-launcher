import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/game.dart';
import '../../models/game_model.dart';
import '../../../core/constants/app_constants.dart';

class HiveService {
  Box<GameModel>? _box;

  Future<void> openBox() async {
    if (_box != null && _box!.isOpen) return;

    if (!Hive.isAdapterRegistered(GameModelAdapter().typeId)) {
      Hive.registerAdapter(GameModelAdapter());
    }

    _box = await Hive.openBox<GameModel>(AppConstants.hiveBoxName);
  }

  Future<List<Game>> getAllGames() async {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.map((model) => model.toEntity()).toList();
  }

  Future<void> saveGame(Game game) async {
    if (_box == null || !_box!.isOpen) return;
    await _box!.put(game.id, GameModel.fromEntity(game));
  }

  Future<void> saveGames(List<Game> games) async {
    if (_box == null || !_box!.isOpen) return;
    await _box!.clear();
    final models = <String, GameModel>{};
    for (final game in games) {
      models[game.id] = GameModel.fromEntity(game);
    }
    await _box!.putAll(models);
  }

  Future<void> updatePlayTime(String id, int minutes) async {
    if (_box == null || !_box!.isOpen) return;
    final existing = _box!.get(id);
    if (existing == null) return;
    final updated = GameModel(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      coverUrl: existing.coverUrl,
      backdropUrl: existing.backdropUrl,
      magnetLink: existing.magnetLink,
      installPath: existing.installPath,
      executableName: existing.executableName,
      isInstalled: existing.isInstalled,
      playTimeMinutes: minutes,
    );
    await _box!.put(id, updated);
  }

  Future<void> deleteGame(String id) async {
    if (_box == null || !_box!.isOpen) return;
    await _box!.delete(id);
  }

  Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  Box<GameModel>? get box => _box;
}
