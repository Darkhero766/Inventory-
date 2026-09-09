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

/// Key-free internet catalog helper. The app remains usable offline when the
/// remote service is unavailable.
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
        .join(' ');
    if (q.trim().length < 3) return const [];
    final key = q.trim().toLowerCase();
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
    final results = await suggest(query: query);
    final image = results.isEmpty || results.first.imageUrl.isEmpty
        ? null
        : results.first.imageUrl;
    _imageCache[key] = image;
    return image;
  }
}
