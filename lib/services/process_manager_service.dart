import 'dart:async';
import 'dart:io';
import '../domain/entities/game.dart';
import '../data/sources/local/hive_service.dart';
import '../core/services/window_service.dart';

class ProcessManagerService {
  ProcessManagerService._();
  static final instance = ProcessManagerService._();

  Process? _activeProcess;
  Stopwatch? _stopwatch;
  // ignore: unused_field
  StreamSubscription<ProcessSignal>? _sigintSub;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> launchGame(Game game, HiveService hiveService) async {
    if (_isRunning) return;
    if (game.installPath == null || game.executableName == null) {
      throw ArgumentError('Game has no install path or executable');
    }

    final execPath = '${game.installPath}/${game.executableName}';
    final isWindows = Platform.isWindows;
    final isExe = game.executableName!.toLowerCase().endsWith('.exe');

    List<String> command;
    if (isWindows) {
      command = [execPath];
    } else if (isExe) {
      command = ['wine', execPath];
    } else {
      command = [execPath];
    }

    _stopwatch = Stopwatch()..start();
    _isRunning = true;

    _activeProcess = await Process.start(
      command.first,
      command.skip(1).toList(),
      workingDirectory: game.installPath,
      runInShell: false,
      mode: ProcessStartMode.detachedWithStdio,
    );

    await WindowService.minimize();

    _activeProcess!.exitCode.then((exitCode) {
      _onProcessExit(game, hiveService);
    });
  }

  Future<void> _onProcessExit(Game game, HiveService hiveService) async {
    _stopwatch?.stop();
    final sessionMinutes = (_stopwatch?.elapsed.inSeconds ?? 0) ~/ 60;
    _isRunning = false;
    _activeProcess = null;
    _stopwatch = null;

    if (sessionMinutes > 0) {
      await hiveService.updatePlayTime(
        game.id,
        game.playTimeMinutes + sessionMinutes,
      );
    }

    await WindowService.setFullscreen(true);
  }

  Future<void> killGame() async {
    _activeProcess?.kill(ProcessSignal.sigterm);
    await Future.delayed(const Duration(seconds: 2));
    if (_isRunning) {
      _activeProcess?.kill(ProcessSignal.sigkill);
    }
  }
}
