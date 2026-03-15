import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  LatLng? currentLocation;
  LatLng? searchedLocation;
  double currentHeading = 0;

  bool isLoading = true;
  bool isSatellite = false;
  bool showTrafficLayer = false; // Thêm traffic layer
  bool show3DBuildings = false; // Thêm 3D buildings

  List<dynamic> suggestions = [];
  bool showSuggestions = false;

  List<LatLng> poiLocations = [];
  List<LatLng> routePoints = [];

  double? routeDistanceKm;
  double? routeDurationMin;

  StreamSubscription<Position>? positionStream;
  Timer? _debounce;

  // Lưu lịch sử tìm kiếm
  List<String> recentSearches = [];

  final LatLng defaultLocation = const LatLng(20.8449, 106.6881); // Hải Phòng

  @override
  void initState() {
    super.initState();
    _listenLocation();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    positionStream?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // Load lịch sử tìm kiếm
  Future<void> _loadRecentSearches() async {
    // Trong thực tế, load từ SharedPreferences
    setState(() {
      recentSearches = [
        "Nhà hát lớn Hải Phòng",
        "Cầu Rồng Đà Nẵng",
        "Bến xe Lạc Long"
      ];
    });
  }

  /* ================= LOCATION ================= */
  Future<void> _listenLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => isLoading = false);
      return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      final loc = LatLng(position.latitude, position.longitude);
      setState(() {
        currentLocation = loc;
        currentHeading = position.heading;
        isLoading = false;
      });
    });
  }

  /* ================= SEARCH ================= */
  Future<void> searchPlace(String query) async {
    if (query.isEmpty) return;

    final lat = currentLocation?.latitude ?? defaultLocation.latitude;
    final lon = currentLocation?.longitude ?? defaultLocation.longitude;

    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1"
        "&countrycodes=vn"
        "&viewbox=${lon - 1},${lat + 1},${lon + 1},${lat - 1}";

    final res = await http.get(
      Uri.parse(url),
      headers: {"User-Agent": "smarttraffic-app"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        final place = LatLng(
          double.parse(data[0]["lat"]),
          double.parse(data[0]["lon"]),
        );

        setState(() {
          searchedLocation = place;
          showSuggestions = false;
          poiLocations.clear();
          routePoints.clear();
          routeDistanceKm = null;
          routeDurationMin = null;

          // Thêm vào lịch sử tìm kiếm
          if (!recentSearches.contains(query)) {
            recentSearches.insert(0, query);
            if (recentSearches.length > 5) recentSearches.removeLast();
          }
        });

        mapController.move(place, 16);
      } else {
        _showErrorSnackBar("Không tìm thấy địa điểm");
      }
    }
  }

  Future<void> fetchSuggestions(String query) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        setState(() {
          suggestions.clear();
          showSuggestions = false;
        });
        return;
      }

      final lat = currentLocation?.latitude ?? defaultLocation.latitude;
      final lon = currentLocation?.longitude ?? defaultLocation.longitude;

      final url =
          "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5"
          "&countrycodes=vn"
          "&viewbox=${lon - 1},${lat + 1},${lon + 1},${lat - 1}";

      final res = await http.get(
        Uri.parse(url),
        headers: {"User-Agent": "smarttraffic-app"},
      );

      if (res.statusCode == 200) {
        setState(() {
          suggestions = jsonDecode(res.body);
          showSuggestions = true;
        });
      }
    });
  }

  void selectSuggestion(dynamic place) {
    final lat = double.parse(place["lat"]);
    final lon = double.parse(place["lon"]);
    final location = LatLng(lat, lon);
    final displayName = place["display_name"];

    setState(() {
      searchedLocation = location;
      searchController.text = displayName;
      showSuggestions = false;
      poiLocations.clear();
      routePoints.clear();
      routeDistanceKm = null;
      routeDurationMin = null;

      // Thêm vào lịch sử tìm kiếm
      if (!recentSearches.contains(displayName)) {
        recentSearches.insert(0, displayName);
        if (recentSearches.length > 5) recentSearches.removeLast();
      }
    });

    mapController.move(location, 16);
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      suggestions.clear();
      showSuggestions = false;
      searchedLocation = null;
      poiLocations.clear();
      routePoints.clear();
      routeDistanceKm = null;
      routeDurationMin = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /* ================= POI ================= */
  Future<void> fetchNearbyPOI(String type, String displayName) async {
    if (currentLocation == null) return;

    final lat = currentLocation!.latitude;
    final lon = currentLocation!.longitude;

    final query = """
    [out:json];
    node[amenity=$type](around:2000,$lat,$lon);
    out;
    """;

    final res = await http.post(
      Uri.parse("https://overpass-api.de/api/interpreter"),
      body: query,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final elements = data["elements"] as List;

      setState(() {
        poiLocations = elements.map((e) => LatLng(e["lat"], e["lon"])).toList();
        searchedLocation = null;
        routePoints.clear();
        showSuggestions = false;
      });

      // Hiển thị số lượng tìm thấy
      if (poiLocations.isNotEmpty) {
        _showInfoSnackBar(
            "Tìm thấy ${poiLocations.length} $displayName gần bạn");
      } else {
        _showInfoSnackBar("Không tìm thấy $displayName nào gần đây");
      }
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF7B00FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openCategoryMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tìm kiếm gần đây",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Recent searches
              if (recentSearches.isNotEmpty) ...[
                ...recentSearches.map((search) => ListTile(
                      leading:
                          const Icon(Icons.history, color: Color(0xFF7B00FF)),
                      title: Text(search),
                      onTap: () {
                        Navigator.pop(context);
                        searchPlace(search);
                      },
                    )),
                const Divider(),
              ],
              const Text(
                "Tiện ích xung quanh",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip(
                    icon: Icons.local_gas_station,
                    label: "Cây xăng",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("fuel", "cây xăng");
                    },
                  ),
                  _buildCategoryChip(
                    icon: Icons.restaurant,
                    label: "Nhà hàng",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("restaurant", "nhà hàng");
                    },
                  ),
                  _buildCategoryChip(
                    icon: Icons.local_parking,
                    label: "Bãi đỗ xe",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("parking", "bãi đỗ xe");
                    },
                  ),
                  _buildCategoryChip(
                    icon: Icons.local_hospital,
                    label: "Bệnh viện",
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("hospital", "bệnh viện");
                    },
                  ),
                  _buildCategoryChip(
                    icon: Icons.school,
                    label: "Trường học",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("school", "trường học");
                    },
                  ),
                  _buildCategoryChip(
                    icon: Icons.local_cafe,
                    label: "Cà phê",
                    color: Colors.brown,
                    onTap: () {
                      Navigator.pop(context);
                      fetchNearbyPOI("cafe", "quán cà phê");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= ROUTING ================= */
  Future<void> getRouteToSearchedLocation() async {
    if (currentLocation == null || searchedLocation == null) return;

    setState(() => isLoading = true);

    final start = currentLocation!;
    final end = searchedLocation!;

    final url = "https://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};${end.longitude},${end.latitude}"
        "?overview=full&geometries=geojson&alternatives=true"; // Thêm alternatives

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final route = data["routes"][0];
      final coords = route["geometry"]["coordinates"] as List;

      setState(() {
        routePoints = coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
        routeDistanceKm = route["distance"] / 1000;
        routeDurationMin = route["duration"] / 60;
      });

      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(routePoints),
          padding: const EdgeInsets.all(40),
        ),
      );

      _showInfoSnackBar(
          "Khoảng cách: ${routeDistanceKm!.toStringAsFixed(1)}km • Thời gian: ${routeDurationMin!.toStringAsFixed(0)} phút");
    }

    setState(() => isLoading = false);
  }

  /* ================= MAP CONTROLS ================= */
  void zoomIn() {
    mapController.move(
      mapController.camera.center,
      mapController.camera.zoom + 1,
    );
  }

  void zoomOut() {
    mapController.move(
      mapController.camera.center,
      mapController.camera.zoom - 1,
    );
  }

  void goToMyLocation() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 16);
    }
  }

  void resetMap() {
    mapController.move(defaultLocation, 12);
    setState(() {
      searchedLocation = null;
      poiLocations.clear();
      routePoints.clear();
      routeDistanceKm = null;
      routeDurationMin = null;
    });
  }

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    final center = currentLocation ?? defaultLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              maxZoom: 19,
              minZoom: 3,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: isSatellite
                    ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                    : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.smarttraffic',
              ),
              // Traffic layer (giả lập)
              if (showTrafficLayer)
                Opacity(
                  opacity: 0.5,
                  child: TileLayer(
                    urlTemplate:
                        "https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}.jpg",
                    userAgentPackageName: 'com.example.smarttraffic',
                  ),
                ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation!,
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: currentHeading * pi / 180,
                        child: const Icon(Icons.navigation,
                            color: Colors.blue, size: 40),
                      ),
                    ),
                  if (searchedLocation != null)
                    Marker(
                      point: searchedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 40),
                    ),
                  ...poiLocations.map(
                    (p) => Marker(
                      point: p,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.green, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isLoading) const Center(child: CircularProgressIndicator()),

          // Header / Search Area
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      // Menu button
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: openCategoryMenu,
                        color: Colors.grey[600],
                      ),
                      // Search icon - ĐÃ SỬA để có thể nhấn
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF7B00FF),
                          size: 20,
                        ),
                        onPressed: () {
                          if (searchController.text.isNotEmpty) {
                            searchPlace(searchController.text);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      // Search field
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: fetchSuggestions,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              searchPlace(value);
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Tìm kiếm địa điểm...",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: clearSearch,
                          color: Colors.grey[600],
                        ),
                      // Account circle
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {},
                        color: const Color(0xFF7B00FF),
                      ),
                    ],
                  ),
                ),

                // Suggestions
                if (showSuggestions && suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final place = suggestions[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.place, color: Color(0xFF7B00FF)),
                          title: Text(
                            place["display_name"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => selectSuggestion(place),
                        );
                      },
                    ),
                  ),

                // Quick Shortcut Chips
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickChip(
                        icon: Icons.home,
                        label: "Nhà",
                        onTap: () => searchPlace("Home"),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickChip(
                        icon: Icons.work,
                        label: "Công ty",
                        onTap: () => searchPlace("Work"),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickChip(
                        icon: Icons.favorite,
                        label: "Yêu thích",
                        onTap: () => searchPlace("Favorite"),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickChip(
                        icon: Icons.restaurant,
                        label: "Ăn uống",
                        onTap: () => fetchNearbyPOI("restaurant", "nhà hàng"),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickChip(
                        icon: Icons.local_gas_station,
                        label: "Xăng",
                        onTap: () => fetchNearbyPOI("fuel", "cây xăng"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Route Info
          if (routeDistanceKm != null)
            Positioned(
              bottom: 120,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${routeDistanceKm!.toStringAsFixed(1)} km",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${routeDurationMin!.toStringAsFixed(0)} phút",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Controls
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              children: [
                // Zoom controls
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: zoomIn,
                        color: Colors.grey[600],
                      ),
                      const Divider(height: 1),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: zoomOut,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // My location button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: goToMyLocation,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Reset map button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.center_focus_strong),
                    onPressed: resetMap,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Layers button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(isSatellite ? Icons.map : Icons.layers),
                    onPressed: () {
                      setState(() => isSatellite = !isSatellite);
                    },
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Traffic layer toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: showTrafficLayer
                          ? const Color(0xFF7B00FF)
                          : const Color(0xFF7B00FF).withOpacity(0.1),
                      width: showTrafficLayer ? 2 : 1,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.traffic),
                    onPressed: () {
                      setState(() => showTrafficLayer = !showTrafficLayer);
                      _showInfoSnackBar(showTrafficLayer
                          ? "Đã bật lớp giao thông"
                          : "Đã tắt lớp giao thông");
                    },
                    color: showTrafficLayer
                        ? const Color(0xFF7B00FF)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Traffic Chatbot FAB
          Positioned(
            right: 16,
            bottom: 60,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B00FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "TRAFFIC CHATBOT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Routing Button
          if (searchedLocation != null)
            Positioned(
              bottom: 40,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: getRouteToSearchedLocation,
                icon: const Icon(Icons.directions),
                label: const Text("Chỉ đường đến đây"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B00FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF7B00FF).withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF7B00FF).withOpacity(0.1),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF7B00FF),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
