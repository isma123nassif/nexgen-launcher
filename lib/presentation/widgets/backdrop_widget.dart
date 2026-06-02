import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BackdropWidget extends StatefulWidget {
  final String imageUrl;
  final Widget child;

  const BackdropWidget({
    super.key,
    required this.imageUrl,
    required this.child,
  });

  @override
  State<BackdropWidget> createState() => _BackdropWidgetState();
}

class _BackdropWidgetState extends State<BackdropWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Container(
            key: ValueKey(widget.imageUrl),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
            ),
            child: Opacity(
              opacity: 0.25,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
