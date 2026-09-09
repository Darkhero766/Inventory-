import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductSuggestion {
  final String title;
  final String description;
  final String imageUrl;

  const ProductSuggestion({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

/// Internet-assisted product lookup with a no-network fallback.
/// Suggestions use Wikipedia while product imagery prefers Openverse's
/// openly licensed image index. Both services are optional; the app remains
/// usable when the network is unavailable.
class ProductCatalogService {
  static final Map<String, List<ProductSuggestion>> _cache = {};
  static final Map<String, String?> _imageCache = {};

  static Future<List<ProductSuggestion>> suggest({
    required String query,
    String brand = '',
    String category = '',
  }) async {
    final q = [brand, query, category]
        .where((v) => v.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (q.length < 3) return const [];

    final key = q.toLowerCase();
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final uri = Uri.https('en.wikipedia.org', '/w/rest.php/v1/search/page', {
        'q': q,
        'limit': '6',
      });
      final response = await http.get(uri, headers: const {
        'Accept': 'application/json',
        'Api-User-Agent': 'InventoryShop/2.1 (electronics inventory app)',
      }).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = decoded['pages'] as List<dynamic>? ?? const [];
      final results = pages.map((raw) {
        final item = raw as Map<String, dynamic>;
        final thumbnail = item['thumbnail'] as Map<String, dynamic>?;
        final image = thumbnail?['url']?.toString() ?? '';
        return ProductSuggestion(
          title: item['title']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          imageUrl: image.startsWith('//') ? 'https:$image' : image,
        );
      }).where((item) => item.title.isNotEmpty).toList(growable: false);

      _cache[key] = results;
      return results;
    } catch (_) {
      return const [];
    }
  }

  static Future<String?> findImage(String query) async {
    final key = query.trim().toLowerCase();
    if (key.length < 3) return null;
    if (_imageCache.containsKey(key)) return _imageCache[key];

    try {
      final uri = Uri.https('api.openverse.org', '/v1/images/', {
        'q': query,
        'page_size': '8',
      });
      final response = await http.get(uri, headers: const {
        'Accept': 'application/json',
        'User-Agent': 'InventoryShop/2.1',
      }).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>? ?? const [];
        for (final raw in results) {
          final item = raw as Map<String, dynamic>;
          final thumb = item['thumbnail']?.toString() ?? '';
          final image = item['url']?.toString() ?? '';
          final chosen = thumb.isNotEmpty ? thumb : image;
          if (chosen.isNotEmpty) {
            _imageCache[key] = chosen;
            return chosen;
          }
        }
      }
    } catch (_) {
      // Fall through to the Wikipedia thumbnail fallback.
    }

    final suggestions = await suggest(query: query);
    final image = suggestions.firstWhere(
      (item) => item.imageUrl.isNotEmpty,
      orElse: () => const ProductSuggestion(title: '', description: '', imageUrl: ''),
    ).imageUrl;
    _imageCache[key] = image.isEmpty ? null : image;
    return image.isEmpty ? null : image;
  }
}
