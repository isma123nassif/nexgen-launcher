class Game {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String backdropUrl;
  final String? magnetLink;
  final String? installPath;
  final String? executableName;
  final bool isInstalled;
  final int playTimeMinutes;

  const Game({
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

  Game copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    String? backdropUrl,
    String? magnetLink,
    String? installPath,
    String? executableName,
    bool? isInstalled,
    int? playTimeMinutes,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      magnetLink: magnetLink ?? this.magnetLink,
      installPath: installPath ?? this.installPath,
      executableName: executableName ?? this.executableName,
      isInstalled: isInstalled ?? this.isInstalled,
      playTimeMinutes: playTimeMinutes ?? this.playTimeMinutes,
    );
  }

  factory Game.test() {
    return const Game(
      id: 'test_1',
      title: 'Test Game',
      description: 'A test game for development',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Game(id: $id, title: $title, isInstalled: $isInstalled)';
  }
}
