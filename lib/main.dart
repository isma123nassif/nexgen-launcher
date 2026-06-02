import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/window_service.dart';
import 'data/models/game_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowService.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(GameModelAdapter());
  runApp(const ProviderScope(child: App()));
}
