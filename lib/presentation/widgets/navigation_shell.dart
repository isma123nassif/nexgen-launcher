import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/gamepad_navigation_service.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.columnCount,
    required this.itemCount,
    required this.itemBuilder,
    this.onItemSelected,
  });

  final int columnCount;
  final int itemCount;
  final Widget Function(BuildContext, int, FocusNode) itemBuilder;
  final void Function(int index)? onItemSelected;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  List<FocusNode> _focusNodes = [];
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.itemCount, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });

    final gp = GamepadNavigationService.instance;
    gp.onDirectionPressed = _handleDirection;
    gp.onConfirm = () => widget.onItemSelected?.call(_focusedIndex);
    gp.onBack = () {};
    gp.start();
  }

  @override
  void dispose() {
    GamepadNavigationService.instance.stop();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleDirection(int dx, int dy) {
    final rows = (widget.itemCount / widget.columnCount).ceil();
    final currentRow = _focusedIndex ~/ widget.columnCount;
    final currentCol = _focusedIndex % widget.columnCount;
    final newCol = (currentCol + dx).clamp(0, widget.columnCount - 1);
    final newRow = (currentRow + dy).clamp(0, rows - 1);
    final newIndex =
        (newRow * widget.columnCount + newCol).clamp(0, widget.itemCount - 1);
    if (newIndex != _focusedIndex) {
      setState(() => _focusedIndex = newIndex);
      _focusNodes[newIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _handleDirection(-1, 0);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _handleDirection(1, 0);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _handleDirection(0, -1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _handleDirection(0, 1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.space) {
            widget.onItemSelected?.call(_focusedIndex);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.columnCount,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) =>
              widget.itemBuilder(context, index, _focusNodes[index]),
        ),
      ),
    );
  }
}
