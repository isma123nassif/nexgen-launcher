import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/game.dart';

@HiveType(typeId: 0)
class GameModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String coverUrl;

  @HiveField(4)
  final String backdropUrl;

  @HiveField(5)
  final String? magnetLink;

  @HiveField(6)
  final String? installPath;

  @HiveField(7)
  final String? executableName;

  @HiveField(8)
  final bool isInstalled;

  @HiveField(9)
  final int playTimeMinutes;

  const GameModel({
    required this.id,
    required this.title,
    this.description = '',
    this.coverUrl = '',
    this.backdropUrl = '',
    this.magnetLink,
    this.installPath,
    this.executableName,
    this.isInstalled = false,
    this.playTimeMinutes = 0,
  });

  factory GameModel.fromEntity(Game game) {
    return GameModel(
      id: game.id,
      title: game.title,
      description: game.description,
      coverUrl: game.coverUrl,
      backdropUrl: game.backdropUrl,
      magnetLink: game.magnetLink,
      installPath: game.installPath,
      executableName: game.executableName,
      isInstalled: game.isInstalled,
      playTimeMinutes: game.playTimeMinutes,
    );
  }

  Game toEntity() {
    return Game(
      id: id,
      title: title,
      description: description,
      coverUrl: coverUrl,
      backdropUrl: backdropUrl,
      magnetLink: magnetLink,
      installPath: installPath,
      executableName: executableName,
      isInstalled: isInstalled,
      playTimeMinutes: playTimeMinutes,
    );
  }
}

class GameModelAdapter extends TypeAdapter<GameModel> {
  @override
  final int typeId = 0;

  @override
  GameModel read(BinaryReader reader) {
    return GameModel(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
      coverUrl: reader.read(),
      backdropUrl: reader.read(),
      magnetLink: reader.read() as String?,
      installPath: reader.read() as String?,
      executableName: reader.read() as String?,
      isInstalled: reader.read(),
      playTimeMinutes: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GameModel obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.coverUrl);
    writer.write(obj.backdropUrl);
    writer.write(obj.magnetLink);
    writer.write(obj.installPath);
    writer.write(obj.executableName);
    writer.write(obj.isInstalled);
    writer.write(obj.playTimeMinutes);
  }
}
