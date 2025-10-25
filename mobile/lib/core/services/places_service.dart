import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../data/models/store_model.dart';

/// Places Service using OpenStreetMap ONLY - FREE, no billing!
class PlacesService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Search for nearby stores using OpenStreetMap ONLY
  Future<List<Store>> searchNearbyStores({
    required double latitude,
    required double longitude,
    int radius = 5000,
    List<String> keywords = const [],
  }) async {
    try {
      // Search OpenStreetMap for ALL shops nearby
      final osmStores = await _searchNearbyShops(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      // Remove duplicates
      final uniqueStores = _removeDuplicates(osmStores);

      // Sort by distance
      uniqueStores.sort((a, b) {
        if (a.distance == null || b.distance == null) return 0;
        return a.distance!.compareTo(b.distance!);
      });

      // Return up to 50 stores
      return uniqueStores.take(50).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Store>> _searchNearbyShops({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    // Overpass QL query - TÌM TẤT CẢ shops gần đây (đơn giản)
    final query =
        '[out:json][timeout:30];'
        '('
        // TẤT CẢ nodes có tag shop (bất kỳ loại nào)
        'node["shop"](around:$radius,$latitude,$longitude);'
        // TẤT CẢ ways có tag shop
        'way["shop"](around:$radius,$latitude,$longitude);'
        ');'
        'out center;';

    try {
      final response = await http
          .post(
            Uri.parse(_overpassUrl),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'BepVietApp/1.0',
            },
            body: 'data=$query',
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List? ?? [];

        final stores = <Store>[];
        for (var element in elements) {
          try {
            final store = _parseOsmElement(element, latitude, longitude);
            if (store != null) stores.add(store);
          } catch (e) {
            // Skip invalid elements
          }
        }

        return stores;
      }
    } catch (e) {
      // Silent fail
    }

    return [];
  }

  Store? _parseOsmElement(
    Map<String, dynamic> element,
    double userLat,
    double userLon,
  ) {
    final tags = element['tags'] as Map<String, dynamic>?;
    if (tags == null) return null;

    // Get coordinates
    double? lat;
    double? lon;

    if (element['type'] == 'node') {
      lat = element['lat']?.toDouble();
      lon = element['lon']?.toDouble();
    } else if (element['type'] == 'way') {
      // For ways, use center
      final center = element['center'] as Map<String, dynamic>?;
      lat = center?['lat']?.toDouble();
      lon = center?['lon']?.toDouble();
    }

    if (lat == null || lon == null) return null;

    // Get name - prioritize brand for chain stores
    String name = tags['brand'] ?? tags['name'] ?? tags['official_name'] ?? '';

    // Clean up name
    name = name.trim();

    // If no name, use shop type as name
    if (name.isEmpty) {
      final shop = tags['shop'] ?? 'store';
      name = _parseShopType(shop);
    }

    // Skip ONLY if completely empty or generic
    if (name.isEmpty || name == 'shop' || name == 'store') return null;

    final shop = tags['shop'] ?? 'store';

    return Store(
      id: element['id']?.toString() ?? '',
      name: name,
      address: _buildAddress(tags),
      latitude: lat,
      longitude: lon,
      phoneNumber: tags['phone'],
      rating: null,
      userRatingsTotal: null,
      openingHours: tags['opening_hours'],
      type: _parseShopType(shop),
      photoReference: null,
      isOpen: _checkIfOpen(tags['opening_hours']),
      distance: _calculateDistance(userLat, userLon, lat, lon),
    );
  }

  String _buildAddress(Map<String, dynamic> tags) {
    // Try full address first
    if (tags['addr:full'] != null && tags['addr:full'].toString().isNotEmpty) {
      return tags['addr:full'];
    }

    final parts = <String>[];

    // Build from components
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);

    // Add ward/district/city
    if (tags['addr:ward'] != null) parts.add(tags['addr:ward']);
    if (tags['addr:district'] != null) parts.add(tags['addr:district']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);

    // If we have street, that's minimum
    if (parts.isNotEmpty && tags['addr:street'] != null) {
      return parts.join(', ');
    }

    // Fallback: just street name
    if (tags['addr:street'] != null) {
      return tags['addr:street'];
    }

    // Last resort: district + city
    if (tags['addr:district'] != null || tags['addr:city'] != null) {
      final fallback = <String>[];
      if (tags['addr:district'] != null) fallback.add(tags['addr:district']);
      if (tags['addr:city'] != null) fallback.add(tags['addr:city']);
      return fallback.join(', ');
    }

    return 'Thành phố Hồ Chí Minh';
  }

  String _parseShopType(String shop) {
    final shopLower = shop.toLowerCase();

    if (shopLower.contains('supermarket')) return 'Siêu thị';
    if (shopLower.contains('convenience')) return 'Cửa hàng tiện lợi';
    if (shopLower.contains('grocery')) return 'Tạp hóa';
    if (shopLower.contains('mall')) return 'Trung tâm mua sắm';
    if (shopLower.contains('department')) return 'Cửa hàng bách hóa';

    return 'Cửa hàng';
  }

  bool _checkIfOpen(String? openingHours) {
    if (openingHours == null) return true; // Assume open if no data
    if (openingHours == '24/7') return true;

    // Check current time (Vietnam timezone UTC+7)
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = now.hour;

    // Simple heuristic: Most stores open 7AM-10PM
    // If has opening hours, parse it
    if (openingHours.contains('-')) {
      try {
        // Try to parse "07:00-22:00" format
        final parts = openingHours.split('-');
        if (parts.length == 2) {
          final openHour = int.tryParse(parts[0].split(':')[0]) ?? 7;
          final closeHour = int.tryParse(parts[1].split(':')[0]) ?? 22;
          return hour >= openHour && hour < closeHour;
        }
      } catch (e) {
        // Parse failed, assume open
      }
    }

    // Default: open during typical business hours
    return hour >= 7 && hour < 22;
  }

  List<Store> _removeDuplicates(List<Store> stores) {
    final Map<String, Store> uniqueMap = {};
    for (var store in stores) {
      if (!uniqueMap.containsKey(store.id)) {
        uniqueMap[store.id] = store;
      }
    }
    return uniqueMap.values.toList();
  }

  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Haversine formula
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(endLat - startLat);
    final double dLng = _toRadians(endLng - startLng);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get photo URL (OpenStreetMap doesn't provide photos)
  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    return null; // OSM doesn't provide photos
  }
}
