import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../data/models/store_model.dart';

/// Places Service using OpenStreetMap - FREE, no billing required!
class PlacesService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Search for nearby stores using OpenStreetMap
  Future<List<Store>> searchNearbyStores({
    required double latitude,
    required double longitude,
    int radius = 5000,
    List<String> keywords = const [
      'Bách Hóa Xanh',
      'Winmart',
      'Co.opmart',
      'Big C',
      'Lotte Mart',
      'Aeon',
    ],
  }) async {
    try {
      final List<Store> allStores = [];

      // Search for all shops in the area
      final stores = await _searchNearbyShops(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      allStores.addAll(stores);

      // Remove duplicates
      final uniqueStores = _removeDuplicates(allStores);

      // Sort by distance
      uniqueStores.sort((a, b) {
        if (a.distance == null || b.distance == null) return 0;
        return a.distance!.compareTo(b.distance!);
      });

      return uniqueStores.take(30).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Store>> _searchNearbyShops({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    // Overpass QL query to get all shops
    final query =
        '[out:json][timeout:25];'
        '('
        'node["shop"](around:$radius,$latitude,$longitude);'
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

    final name = tags['name'] ?? tags['brand'] ?? 'Cửa hàng';
    final shop = tags['shop'] ?? 'store';

    // Skip if no proper name
    if (name == 'Cửa hàng' && shop == 'store') return null;

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
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:district'] != null) parts.add(tags['addr:district']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);

    return parts.isEmpty ? 'Không có địa chỉ' : parts.join(', ');
  }

  String _parseShopType(String shop) {
    switch (shop.toLowerCase()) {
      case 'supermarket':
        return 'Siêu thị';
      case 'convenience':
        return 'Cửa hàng tiện lợi';
      case 'grocery':
        return 'Tạp hóa';
      case 'mall':
        return 'Trung tâm mua sắm';
      case 'department_store':
        return 'Cửa hàng bách hóa';
      default:
        return 'Cửa hàng';
    }
  }

  bool _checkIfOpen(String? openingHours) {
    if (openingHours == null) return false;
    if (openingHours == '24/7') return true;
    // Simple check - assume open if has hours
    return openingHours.isNotEmpty;
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
