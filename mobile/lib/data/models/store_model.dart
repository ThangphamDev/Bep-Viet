/// Store/Market model for nearby places
class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final double? rating;
  final int? userRatingsTotal;
  final String? openingHours;
  final String type; // 'market', 'supermarket', 'grocery'
  final double? distance; // in meters
  final String? photoReference;
  final bool isOpen;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.rating,
    this.userRatingsTotal,
    this.openingHours,
    required this.type,
    this.distance,
    this.photoReference,
    this.isOpen = false,
  });

  // No longer needed - PlacesService creates Store objects directly from OSM data

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1000) {
      return '${distance!.round()}m';
    }
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }

  String get ratingText {
    if (rating == null) return 'Chưa có đánh giá';
    return '${rating!.toStringAsFixed(1)} ⭐ ($userRatingsTotal lượt)';
  }
}
