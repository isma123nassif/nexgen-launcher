import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:universal_gamepad/universal_gamepad.dart';

class GamepadNavigationService {
  GamepadNavigationService._();

  static final GamepadNavigationService instance = GamepadNavigationService._();

  void Function(int dx, int dy)? onDirectionPressed;
  VoidCallback? onConfirm;
  VoidCallback? onBack;
  VoidCallback? onMenu;

  StreamSubscription<GamepadButtonEvent>? _buttonSubscription;
  StreamSubscription<GamepadAxisEvent>? _axisSubscription;
  DateTime _lastAxisTime = DateTime(2000);

  bool get _axisCooldownElapsed {
    return DateTime.now().difference(_lastAxisTime).inMilliseconds >= 200;
  }

  void start() {
    _buttonSubscription = Gamepad.instance.buttonEvents.listen((event) {
      if (!event.pressed) return;

      switch (event.button) {
        case GamepadButton.dpadUp:
          onDirectionPressed?.call(0, -1);
        case GamepadButton.dpadDown:
          onDirectionPressed?.call(0, 1);
        case GamepadButton.dpadLeft:
          onDirectionPressed?.call(-1, 0);
        case GamepadButton.dpadRight:
          onDirectionPressed?.call(1, 0);
        case GamepadButton.a:
          onConfirm?.call();
        case GamepadButton.b:
          onBack?.call();
        case GamepadButton.start:
          onMenu?.call();
        default:
          break;
      }
    });

    _axisSubscription = Gamepad.instance.axisEvents.listen((event) {
      if (!_axisCooldownElapsed) return;

      switch (event.axis) {
        case GamepadAxis.leftStickX:
          if (event.value < -0.5) {
            _lastAxisTime = DateTime.now();
            onDirectionPressed?.call(-1, 0);
          } else if (event.value > 0.5) {
            _lastAxisTime = DateTime.now();
            onDirectionPressed?.call(1, 0);
          }
        case GamepadAxis.leftStickY:
          if (event.value < -0.5) {
            _lastAxisTime = DateTime.now();
            onDirectionPressed?.call(0, -1);
          } else if (event.value > 0.5) {
            _lastAxisTime = DateTime.now();
            onDirectionPressed?.call(0, 1);
          }
        default:
          break;
      }
    });
  }

  void stop() {
    _buttonSubscription?.cancel();
    _buttonSubscription = null;
    _axisSubscription?.cancel();
    _axisSubscription = null;
  }
}
