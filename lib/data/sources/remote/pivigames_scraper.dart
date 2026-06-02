import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser show parse;
import '../../../domain/entities/game.dart';

class PiviGamesScraper {
  final Dio _dio;

  PiviGamesScraper() : _dio = Dio();

  Future<List<Game>> fetchGames({int page = 1}) async {
    try {
      final response = await _dio.get(
        'https://pivigames.blog/wp-json/wp/v2/posts',
        queryParameters: {
          'per_page': 20,
          'page': page,
          'orderby': 'date',
          '_embed': true,
        },
      );

      if (response.data is! List) return [];
      final List<dynamic> items = response.data as List<dynamic>;

      return items.map((item) {
        final String rawId = item['id']?.toString() ?? '';
        final String rawTitle = item['title']?['rendered']?.toString() ?? '';
        final String rawExcerpt = item['excerpt']?['rendered']?.toString() ?? '';
        final String rawContent = item['content']?['rendered']?.toString() ?? '';

        String coverUrl = '';
        final embedded = item['_embedded'];
        if (embedded != null && embedded is Map) {
          final media = embedded['wp:featuredmedia'];
          if (media != null && media is List && media.isNotEmpty) {
            coverUrl = media[0]?['source_url']?.toString() ?? '';
          }
        }

        String description = '';
        try {
          final document = html_parser.parse(rawExcerpt);
          description = document.body?.text ?? '';
          description = description
              .replaceAll('\n', ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (description.length > 200) {
            description = '${description.substring(0, 200)}...';
          }
        } catch (_) {
          description = '';
        }

        String? magnetLink;
        try {
          final magnetMatch = RegExp(r'magnet:\?[^\s\<\>]+').firstMatch(rawContent);
          magnetLink = magnetMatch?.group(0);
        } catch (_) {
          magnetLink = null;
        }

        return Game(
          id: 'pivi_$rawId',
          title: rawTitle.isNotEmpty ? rawTitle : 'Untitled',
          description: description,
          coverUrl: coverUrl,
          backdropUrl: coverUrl,
          magnetLink: magnetLink,
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
}
