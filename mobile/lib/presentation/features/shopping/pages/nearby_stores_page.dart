import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/places_service.dart';
import '../../../../data/models/store_model.dart';

class NearbyStoresPage extends StatefulWidget {
  const NearbyStoresPage({super.key});

  @override
  State<NearbyStoresPage> createState() => _NearbyStoresPageState();
}

class _NearbyStoresPageState extends State<NearbyStoresPage>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  final Completer<GoogleMapController> _mapController = Completer();
  late TabController _tabController;

  Position? _currentPosition;
  List<Store> _stores = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Store? _selectedStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNearbyStores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyStores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _errorMessage = 'Không thể lấy vị trí hiện tại. Vui lòng bật GPS.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentPosition = position;
      });

      // Search nearby stores
      final stores = await _placesService.searchNearbyStores(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000, // 5km
      );

      // Create markers
      final markers = <Marker>{};

      // Add current location marker
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
        ),
      );

      // Add store markers
      for (int i = 0; i < stores.length; i++) {
        final store = stores[i];
        markers.add(
          Marker(
            markerId: MarkerId(store.id),
            position: LatLng(store.latitude, store.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: store.name,
              snippet: '${store.distanceText} • ${store.type}',
            ),
            onTap: () {
              setState(() {
                _selectedStore = store;
              });
              _showStoreDetails(store);
            },
          ),
        );
      }

      setState(() {
        _stores = stores;
        _markers = markers;
        _isLoading = false;
      });

      // Move camera to current location
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tìm cửa hàng: $e';
        _isLoading = false;
      });
    }
  }

  void _showStoreDetails(Store store) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StoreDetailsSheet(store: store),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng gần đây'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadNearbyStores,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Bản đồ'),
            Tab(icon: Icon(Icons.list), text: 'Danh sách'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : TabBarView(
              controller: _tabController,
              children: [_buildMapView(), _buildListView()],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNearbyStores,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(child: Text('Không có vị trí'));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
        }
      },
    );
  }

  Widget _buildListView() {
    if (_stores.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy cửa hàng nào gần đây',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _stores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = _stores[index];
        return _StoreCard(store: store, onTap: () => _showStoreDetails(store));
      },
    );
  }
}

// Store Card Widget
class _StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Store Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStoreIcon(store.type),
                  color: Colors.teal,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: store.isOpen
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            store.isOpen ? 'Đang mở' : 'Đã đóng',
                            style: TextStyle(
                              fontSize: 11,
                              color: store.isOpen ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (store.rating != null) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            store.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Distance
              Column(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.distanceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStoreIcon(String type) {
    switch (type.toLowerCase()) {
      case 'siêu thị':
        return Icons.store;
      case 'tạp hóa':
        return Icons.shopping_basket;
      case 'cửa hàng tiện lợi':
        return Icons.local_convenience_store;
      case 'trung tâm mua sắm':
        return Icons.shopping_bag;
      default:
        return Icons.storefront;
    }
  }
}

// Store Details Bottom Sheet
class _StoreDetailsSheet extends StatelessWidget {
  final Store store;

  const _StoreDetailsSheet({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: store.isOpen
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  store.isOpen ? 'Đang mở cửa' : 'Đã đóng cửa',
                  style: TextStyle(
                    fontSize: 13,
                    color: store.isOpen ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, store.address),
          if (store.phoneNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, store.phoneNumber!),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(Icons.directions_walk, store.distanceText),
          if (store.rating != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.star,
              '${store.rating!.toStringAsFixed(1)} ⭐ (${store.userRatingsTotal} đánh giá)',
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(store),
                  icon: const Icon(Icons.directions),
                  label: const Text('Chỉ đường'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (store.phoneNumber != null) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _callStore(store),
                  icon: const Icon(Icons.call),
                  label: const Text('Gọi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  void _openDirections(Store store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callStore(Store store) async {
    if (store.phoneNumber == null) return;
    final url = Uri.parse('tel:${store.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
