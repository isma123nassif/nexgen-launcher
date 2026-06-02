import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/game.dart';
import '../providers/game_provider.dart';
import '../widgets/backdrop_widget.dart';
import '../widgets/game_card.dart';
import '../widgets/navigation_shell.dart';
import 'game_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _focusedBackdropUrl = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _clockTimer;
  TimeOfDay _currentTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = TimeOfDay.now());
      }
    });
    ref.read(gamesListProvider);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropWidget(
        imageUrl: _focusedBackdropUrl,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEXGEN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE53935),
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    _currentTime.format(context),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: const Color(0xFFE53935).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildGamesSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesSection() {
    final gamesAsync = ref.watch(gamesListProvider);
    return gamesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      ),
      error: (err, _) => const Center(
        child: Text(
          'Error loading games',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      data: (games) {
        if (games.isEmpty) {
          return const Center(
            child: Text(
              'No games found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          );
        }
        return NavigationShell(
          columnCount: 5,
          itemCount: games.length,
          itemBuilder: (ctx, i, focusNode) => AspectRatio(
            aspectRatio: 2 / 3,
            child: GameCard(
              game: games[i],
              focusNode: focusNode,
              onFocused: () => setState(
                () => _focusedBackdropUrl = games[i].backdropUrl,
              ),
              onTap: () => _openDetail(games[i]),
            ),
          ),
          onItemSelected: (i) => _openDetail(games[i]),
        );
      },
    );
  }

  void _openDetail(Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameDetailPage(game: game)),
    );
  }
}
