import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductSuggestion {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String sourceUrl;
  final String category;
  final String brand;

  const ProductSuggestion({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.source = '',
    this.sourceUrl = '',
    this.category = '',
    this.brand = '',
  });
}

/// Internet-assisted product catalog lookup.
///
/// Search is intentionally product-only: Wikipedia pages are filtered for the
/// requested brand/category, while images come from Wikimedia Commons rather
/// than general web/article thumbnails. The service is optional and always
/// falls back to an empty result when the network is unavailable.
class ProductCatalogService {
  static final Map<String, List<ProductSuggestion>> _cache = {};
  static final Map<String, String?> _imageCache = {};

  static const _blockedTerms = <String>{
    'film',
    'movie',
    'actor',
    'actress',
    'politician',
    'politics',
    'election',
    'president',
    'football',
    'cricket',
    'song',
    'album',
    'novel',
    'person',
    'band',
    'city',
    'planet',
    'galaxy (astronomy)',
  };

  static const _categoryAliases = <String, List<String>>{
    'Mobile Phones': ['mobile', 'smartphone', 'phone'],
    'Laptops': ['laptop', 'notebook computer', 'notebook'],
    'Televisions': ['television', 'tv'],
    'Refrigerators': ['refrigerator', 'fridge'],
    'Air Conditioners': ['air conditioner', 'air conditioning'],
    'Washing Machines': ['washing machine'],
    'Audio': ['headphone', 'earbuds', 'earphone', 'speaker', 'audio'],
    'Cameras': ['camera'],
    'Printers': ['printer'],
    'Networking': ['router', 'network', 'switch'],
    'Storage': ['solid-state drive', 'ssd', 'hard disk', 'storage'],
    'Monitors': ['monitor', 'display'],
    'Gaming': ['gaming', 'game console', 'graphics card'],
    'Smartwatches': ['smartwatch', 'watch'],
  };

  static Future<List<ProductSuggestion>> suggest({
    required String query,
    String brand = '',
    String category = '',
  }) async {
    final cleanQuery = query.trim();
    final cleanBrand = brand.trim();
    final cleanCategory = category.trim();
    if (cleanQuery.length < 2) return const [];

    final key = '${cleanBrand.toLowerCase()}|${cleanCategory.toLowerCase()}|${cleanQuery.toLowerCase()}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final searchText = [cleanBrand, cleanQuery, cleanCategory]
        .where((v) => v.isNotEmpty)
        .join(' ');

    try {
      final uri = Uri.https('en.wikipedia.org', '/w/rest.php/v1/search/page', {
        'q': searchText,
        'limit': '12',
      });
      final response = await http.get(uri, headers: const {
        'Accept': 'application/json',
        'Api-User-Agent': 'InventoryShop/3.0 product catalog lookup',
      }).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = decoded['pages'] as List<dynamic>? ?? const [];
      final candidates = <ProductSuggestion>[];

      for (final raw in pages) {
        final item = raw as Map<String, dynamic>;
        final title = item['title']?.toString().trim() ?? '';
        if (title.isEmpty) continue;

        final description = item['description']?.toString().trim() ?? '';
        final haystack = '$title $description'.toLowerCase();
        final score = _score(
          title: title,
          description: description,
          query: cleanQuery,
          brand: cleanBrand,
          category: cleanCategory,
        );
        if (score <= 0) continue;

        final thumbnail = item['thumbnail'] as Map<String, dynamic>?;
        final image = _normaliseUrl(thumbnail?['url']?.toString() ?? '');
        candidates.add(ProductSuggestion(
          title: title,
          description: description.isEmpty
              ? '$cleanBrand ${cleanCategory.isEmpty ? 'product' : cleanCategory}'
              : description,
          imageUrl: image,
          source: 'Wikipedia',
          sourceUrl: 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
          category: cleanCategory,
          brand: cleanBrand,
        ));

        // Avoid retaining obvious non-product results even if the API ranks them.
        if (_blockedTerms.any(haystack.contains)) {
          candidates.removeLast();
        }
      }

      final ranked = candidates.toList()
        ..sort((a, b) => _score(
              title: b.title,
              description: b.description,
              query: cleanQuery,
              brand: cleanBrand,
              category: cleanCategory,
            ).compareTo(_score(
              title: a.title,
              description: a.description,
              query: cleanQuery,
              brand: cleanBrand,
              category: cleanCategory,
            )));

      // Wikimedia Commons is a much safer product-image source than a general
      // image search. Enrich the top results without failing the whole search.
      final enriched = <ProductSuggestion>[];
      for (final item in ranked.take(6)) {
        var image = item.imageUrl;
        if (image.isEmpty) {
          image = await _commonsImage(
            '${item.brand} ${item.title} ${item.category}'.trim(),
          );
        }
        enriched.add(ProductSuggestion(
          title: item.title,
          description: item.description,
          imageUrl: image,
          source: item.source,
          sourceUrl: item.sourceUrl,
          category: item.category,
          brand: item.brand,
        ));
      }

      _cache[key] = enriched;
      return enriched;
    } catch (_) {
      return const [];
    }
  }

  static int _score({
    required String title,
    required String description,
    required String query,
    required String brand,
    required String category,
  }) {
    final t = title.toLowerCase();
    final d = description.toLowerCase();
    final q = query.toLowerCase();
    final b = brand.toLowerCase();
    var score = 0;

    if (b.isNotEmpty && t.contains(b)) {
      score += 100;
    } else if (b.isNotEmpty && d.contains(b)) {
      score += 35;
    } else if (b.isNotEmpty) {
      return -1000;
    }

    final aliases = _categoryAliases[category] ??
        (category.isEmpty ? const <String>[] : [category.toLowerCase()]);
    if (aliases.isNotEmpty) {
      final categoryMatch = aliases.any((a) => '$t $d'.contains(a));
      if (categoryMatch) {
        score += 60;
      } else {
        return -500;
      }
    }

    final queryTokens = q
        .split(RegExp(r'[^a-z0-9]+'))
        .where((v) => v.length >= 2)
        .toList();
    for (final token in queryTokens) {
      if (t.contains(token)) score += 35;
      if (d.contains(token)) score += 8;
    }
    if (t == q) score += 80;
    if (t.contains(q)) score += 55;

    if (_blockedTerms.any((term) => '$t $d'.contains(term))) score -= 1000;
    return score;
  }

  static Future<String?> findImage(String query, {
    String brand = '',
    String category = '',
  }) async {
    final key = '${brand.trim()}|${category.trim()}|${query.trim()}'.toLowerCase();
    if (key.length < 3) return null;
    if (_imageCache.containsKey(key)) return _imageCache[key];

    try {
      final image = await _commonsImage(
        [brand.trim(), query.trim(), category.trim()]
            .where((v) => v.isNotEmpty)
            .join(' '),
      );
      if (image != null && image.isNotEmpty) {
        _imageCache[key] = image;
        return image;
      }
    } catch (_) {
      // Optional network feature; use the saved/placeholder image instead.
    }

    _imageCache[key] = null;
    return null;
  }

  static Future<String?> _commonsImage(String query) async {
    if (query.trim().length < 3) return null;
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '6',
      'gsrlimit': '8',
      'prop': 'imageinfo',
      'iiprop': 'url|mime',
      'iiurlwidth': '640',
      'format': 'json',
      'origin': '*',
    });

    final response = await http.get(uri, headers: const {
      'Accept': 'application/json',
      'User-Agent': 'InventoryShop/3.0 product image lookup',
    }).timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final pages = decoded['query']?['pages'] as Map<String, dynamic>?;
    if (pages == null) return null;

    final queryWords = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((v) => v.length >= 2)
        .toList();
    String? best;
    var bestScore = -1;

    for (final raw in pages.values) {
      final item = raw as Map<String, dynamic>;
      final title = item['title']?.toString().toLowerCase() ?? '';
      final info = (item['imageinfo'] as List<dynamic>?)?.firstOrNull
          as Map<String, dynamic>?;
      if (info == null) continue;
      final mime = info['mime']?.toString() ?? '';
      if (!mime.startsWith('image/')) continue;
      final url = _normaliseUrl(info['thumburl']?.toString() ?? info['url']?.toString() ?? '');
      if (url.isEmpty) continue;

      var score = 0;
      for (final word in queryWords) {
        if (title.contains(word)) score += 20;
      }
      if (title.contains('logo') || title.contains('icon')) score -= 20;
      if (title.contains('person') || title.contains('portrait')) score -= 50;
      if (score > bestScore) {
        bestScore = score;
        best = url;
      }
    }
    return bestScore > 0 ? best : null;
  }

  static String _normaliseUrl(String url) {
    if (url.startsWith('//')) return 'https:$url';
    return url;
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
