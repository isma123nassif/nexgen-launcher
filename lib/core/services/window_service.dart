import 'package:window_manager/window_manager.dart';

class WindowService {
  WindowService._();

  static Future<void> initialize() async {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setFullScreen(true);
  }

  static Future<void> setFullscreen(bool fullscreen) async {
    await windowManager.setFullScreen(fullscreen);
  }

  static Future<void> minimize() async {
    await windowManager.minimize();
  }

  static Future<void> close() async {
    await windowManager.close();
  }
}
