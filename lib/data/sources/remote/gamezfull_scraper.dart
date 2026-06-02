import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import '../../../domain/entities/game.dart';

class GameDetail {
  final String description;
  final String? magnetLink;
  final String backdropUrl;

  const GameDetail({
    this.description = '',
    this.magnetLink,
    this.backdropUrl = '',
  });
}

class GamezFullScraper {
  final Dio _dio;

  GamezFullScraper() : _dio = Dio();

  Future<List<Game>> fetchGames({int page = 1}) async {
    try {
      final response = await _dio.get('https://gamezfull.com/page/$page/');
      final document = parse(response.data.toString());

      final articles = document.querySelectorAll('article');
      if (articles.isEmpty) return [];

      return articles.map((article) {
        final titleElement = article.querySelector('h2 a') ?? article.querySelector('h3 a');
        final title = titleElement?.text.trim() ?? '';
        final postUrl = titleElement?.attributes['href'] ?? '';

        final imgElement = article.querySelector('img');
        final coverUrl = imgElement?.attributes['src'] ?? '';

        String slug = '';
        if (postUrl.isNotEmpty) {
          final segments = postUrl.replaceAll(RegExp(r'/$'), '').split('/');
          final rawSlug = segments.isNotEmpty ? segments.last : '';
          slug = rawSlug.replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '');
        }

        return Game(
          id: 'gamezfull_$slug',
          title: title.isNotEmpty ? title : 'Untitled',
          coverUrl: coverUrl,
          description: '',
          backdropUrl: '',
          magnetLink: null,
          isInstalled: false,
          playTimeMinutes: 0,
        );
      }).toList();
    } on DioException {
      return [];
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<GameDetail> fetchGameDetail(String url) async {
    try {
      final response = await _dio.get(url);
      final document = parse(response.data.toString());

      String description = '';
      try {
        final entryContent = document.querySelector('.entry-content');
        if (entryContent != null) {
          final firstP = entryContent.querySelector('p');
          if (firstP != null) {
            description = firstP.text.trim();
            description = description
                .replaceAll('\n', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            if (description.length > 500) {
              description = '${description.substring(0, 500)}...';
            }
          }
        }
      } catch (_) {
        description = '';
      }

      String? magnetLink;
      try {
        final magnetAnchor = document.querySelector('a[href^="magnet:?"]');
        magnetLink = magnetAnchor?.attributes['href'];
      } catch (_) {
        magnetLink = null;
      }

      String backdropUrl = '';
      try {
        final metaOgImage = document.querySelector('meta[property="og:image"]');
        backdropUrl = metaOgImage?.attributes['content'] ?? '';
      } catch (_) {
        backdropUrl = '';
      }

      return GameDetail(
        description: description,
        magnetLink: magnetLink,
        backdropUrl: backdropUrl,
      );
    } on DioException {
      return const GameDetail();
    } on FormatException {
      return const GameDetail();
    } on TypeError {
      return const GameDetail();
    } catch (_) {
      return const GameDetail();
    }
  }
}
