import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';

class GameCard extends StatefulWidget {
  final Game game;
  final FocusNode focusNode;
  final VoidCallback? onTap;
  final VoidCallback? onFocused;

  const GameCard({
    super.key,
    required this.game,
    required this.focusNode,
    this.onTap,
    this.onFocused,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isFocused = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    final focused = widget.focusNode.hasFocus;
    if (focused && focused != _isFocused) {
      widget.onFocused?.call();
    }
    setState(() {
      _isFocused = focused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isFocused ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFFE53935)
                  : Colors.transparent,
              width: 3.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.game.coverUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: widget.game.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _buildFallback(),
                  )
                else
                  _buildFallback(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      widget.game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (widget.game.isInstalled)
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(
          Icons.videogame_asset,
          size: 48.0,
          color: Colors.white24,
        ),
      ),
    );
  }
}
