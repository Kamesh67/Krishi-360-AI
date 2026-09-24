import 'package:flutter/material.dart';
import 'app_data.dart';
import 'weather_service.dart';

class FarmMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const FarmMapScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  late double _latitude;
  late double _longitude;
  String _selectedCity = "Erode Central";
  String _mapType = "satellite"; // 'satellite', 'terrain', 'standard'
  bool _showPOIs = true;
  bool _showFarmBoundary = true;
  bool _showCanalNetwork = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = AppState().profile;
    final loc = WeatherService().getLocationByQuery(profile.location);
    _latitude = widget.initialLat ?? loc.latitude;
    _longitude = widget.initialLng ?? loc.longitude;
    _selectedCity = loc.city;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCityChanged(String cityName) {
    final loc = WeatherService.supportedLocations.firstWhere(
      (l) => l.city == cityName,
      orElse: () => WeatherService.supportedLocations.first,
    );
    setState(() {
      _selectedCity = cityName;
      _latitude = loc.latitude;
      _longitude = loc.longitude;
    });
  }

  void _locateMyGPS() {
    // Exact Erode Ag-Tech GPS Center
    setState(() {
      _latitude = 11.3410;
      _longitude = 77.7172;
      _selectedCity = "Erode Central";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("GPS Locked: Erode Agricultural Zone (11.3410°N, 77.7172°E)"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveLocation() {
    final loc = WeatherService.supportedLocations.firstWhere(
      (l) => l.city == _selectedCity,
      orElse: () => LocationCoordinates(
        city: _selectedCity,
        state: "Tamil Nadu",
        latitude: _latitude,
        longitude: _longitude,
        district: "Erode",
        villageOrArea: "$_selectedCity Farm Block",
      ),
    );

    AppState().setProfileLocation(loc.displayName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Farm Location Set: ${loc.displayName}\nGPS: ${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, loc);
  }

  String _getSoilAndCanalInfo(String city) {
    if (city.contains("Perundurai")) {
      return "Red Sandy Loam • Bhavani Sagar Canal Reach • Ideal for Turmeric & Tapioca";
    } else if (city.contains("Bhavani") || city.contains("Gobi")) {
      return "Alluvial Clay Loam • Kalingarayan Canal Basin • Ideal for Paddy, Sugarcane & Banana";
    } else if (city.contains("Kodumudi") || city.contains("Modakkurichi")) {
      return "Cauvery Riverbed Soil • Perennial Irrigation • Ideal for Sugarcane & Banana";
    } else if (city.contains("Anthiyur")) {
      return "Red Gravelly Soil • Groundnut & Tapioca Belt";
    }
    return "Rich Red Loam Soil • Kalingarayan Canal & Drip Zone";
  }

  @override
  Widget build(BuildContext context) {
    final acres = AppState().profile.landAreaAcres;
    final soilInfo = _getSoilAndCanalInfo(_selectedCity);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Erode Farm & Agricultural Map", style: TextStyle(fontSize: 16)),
            Text("Tamil Nadu • Kalingarayan & Cauvery Basin", style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: "Lock Live GPS Position",
            onPressed: _locateMyGPS,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Set as My Farm Location",
            onPressed: _saveLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map Canvas
          GestureDetector(
            onTapDown: (details) {
              final size = MediaQuery.of(context).size;
              final tapX = details.localPosition.dx / size.width;
              final tapY = details.localPosition.dy / size.height;

              setState(() {
                _latitude = double.parse((_latitude + (tapY - 0.5) * 0.035).toStringAsFixed(4));
                _longitude = double.parse((_longitude + (tapX - 0.5) * 0.035).toStringAsFixed(4));
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Farm Pin placed: Erode (Lat: $_latitude°N, Lng: $_longitude°E)"),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: _ErodeFarmMapPainter(
                    mapType: _mapType,
                    showBoundary: _showFarmBoundary,
                    showPOIs: _showPOIs,
                    showCanal: _showCanalNetwork,
                    lat: _latitude,
                    lng: _longitude,
                    cityName: _selectedCity,
                    acres: acres,
                  ),
                ),
              ),
            ),
          ),

          // Top Controls (City / Taluk Selector & Layer Switches)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search / Taluk Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_drop, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: WeatherService.supportedLocations.any((l) => l.city == _selectedCity)
                                ? _selectedCity
                                : WeatherService.supportedLocations.first.city,
                            isExpanded: true,
                            items: WeatherService.supportedLocations.map((loc) {
                              return DropdownMenuItem(
                                value: loc.city,
                                child: Text(
                                  "${loc.city} (${loc.district})",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) _onCityChanged(val);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.gps_fixed, color: Colors.blue),
                        tooltip: "Get GPS Location",
                        onPressed: _locateMyGPS,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Map Layers & Overlays
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLayerChip("Satellite Imagery", "satellite", Icons.satellite_alt),
                      _buildLayerChip("Canal & Topography", "terrain", Icons.terrain),
                      _buildLayerChip("Road Map", "standard", Icons.map),
                      const SizedBox(width: 6),
                      FilterChip(
                        avatar: const Icon(Icons.store, size: 14, color: Colors.amber),
                        label: const Text("Mandis & POIs"),
                        selected: _showPOIs,
                        selectedColor: Colors.green.shade200,
                        backgroundColor: Colors.white,
                        onSelected: (val) => setState(() => _showPOIs = val),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        avatar: const Icon(Icons.water, size: 14, color: Colors.blue),
                        label: const Text("Canal Network"),
                        selected: _showCanalNetwork,
                        selectedColor: Colors.green.shade200,
                        backgroundColor: Colors.white,
                        onSelected: (val) => setState(() => _showCanalNetwork = val),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        avatar: const Icon(Icons.crop_landscape, size: 14, color: Colors.green),
                        label: Text("$acres Ac Boundary"),
                        selected: _showFarmBoundary,
                        selectedColor: Colors.green.shade200,
                        backgroundColor: Colors.white,
                        onSelected: (val) => setState(() => _showFarmBoundary = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Real Location Information Card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(Icons.agriculture, color: Colors.green, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$_selectedCity Farm Plot ($acres Acres)",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "GPS: ${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E (Erode Dt.)",
                                style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                soilInfo,
                                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricPill("Perundurai Mandi", "4.2 km", Colors.amber.shade900),
                        _buildMetricPill("Kalingarayan Canal", "150 m", Colors.blue),
                        _buildMetricPill("Aavin Chithode", "5.8 km", Colors.purple),
                        _buildMetricPill("KVK Gobi", "14 km", Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: Text("Confirm & Set as My $_selectedCity Farm"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _saveLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String title, String distance, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        Text(distance, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildLayerChip(String label, String type, IconData icon) {
    final isSelected = _mapType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        avatar: Icon(icon, size: 15, color: isSelected ? Colors.green.shade900 : Colors.grey.shade700),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        selectedColor: Colors.green.shade200,
        backgroundColor: Colors.white,
        onSelected: (selected) {
          if (selected) setState(() => _mapType = type);
        },
      ),
    );
  }
}

class _ErodeFarmMapPainter extends CustomPainter {
  final String mapType;
  final bool showBoundary;
  final bool showPOIs;
  final bool showCanal;
  final double lat;
  final double lng;
  final String cityName;
  final double acres;

  _ErodeFarmMapPainter({
    required this.mapType,
    required this.showBoundary,
    required this.showPOIs,
    required this.showCanal,
    required this.lat,
    required this.lng,
    required this.cityName,
    required this.acres,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint();
    if (mapType == "satellite") {
      bgPaint.color = const Color(0xFF1E3F20); // Lush agricultural green of Erode delta
    } else if (mapType == "terrain") {
      bgPaint.color = const Color(0xFFB8A678); // Earthy terrain
    } else {
      bgPaint.color = const Color(0xFFE9EEEA); // Standard road map
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw field boundary grids (Erode Turmeric & Paddy plots)
    final gridPaint = Paint()
      ..color = mapType == "satellite"
          ? const Color(0xFF28552B)
          : (mapType == "terrain" ? const Color(0xFFA89668) : const Color(0xFFD0DDD2))
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const gridSize = 42.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Cauvery & Bhavani River Confluence (North-East flowing river)
    final riverPaint = Paint()
      ..color = const Color(0xFF29B6F6)
      ..strokeWidth = 18.0
      ..style = PaintingStyle.stroke;

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.28);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.38,
      size.width * 0.65,
      size.height * 0.18,
      size.width,
      size.height * 0.30,
    );
    canvas.drawPath(riverPath, riverPaint);

    // Draw River Label
    _drawMapLabel(canvas, Offset(size.width * 0.45, size.height * 0.23), "🌊 Cauvery & Bhavani River Confluence", Colors.white, Colors.blue.shade900);

    // Draw Kalingarayan Canal (historic irrigation canal through Erode)
    if (showCanal) {
      final canalPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;

      final canalPath = Path();
      canalPath.moveTo(size.width * 0.1, size.height * 0.32);
      canalPath.cubicTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.48,
        size.width * 0.9,
        size.height * 0.75,
      );
      canvas.drawPath(canalPath, canalPaint);
      _drawMapLabel(canvas, Offset(size.width * 0.50, size.height * 0.58), "💧 Kalingarayan Canal (Canal Reach)", Colors.white, Colors.teal.shade900);
    }

    // Draw Center Farm Boundary Polygon
    final center = Offset(size.width / 2, size.height / 2);

    if (showBoundary) {
      final boundaryPaint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      final strokeBoundary = Paint()
        ..color = Colors.greenAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final boundaryPath = Path();
      boundaryPath.moveTo(center.dx - 65, center.dy - 45);
      boundaryPath.lineTo(center.dx + 70, center.dy - 55);
      boundaryPath.lineTo(center.dx + 60, center.dy + 65);
      boundaryPath.lineTo(center.dx - 55, center.dy + 55);
      boundaryPath.close();

      canvas.drawPath(boundaryPath, boundaryPaint);
      canvas.drawPath(boundaryPath, strokeBoundary);

      _drawMapLabel(canvas, Offset(center.dx - 45, center.dy - 20), "🌱 $cityName Farm ($acres Ac)", Colors.black87, Colors.greenAccent);
    }

    // Draw Farm Pin Marker
    final pinPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(center, 12, pinPaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);

    // Draw Erode Regional Agricultural POIs
    if (showPOIs) {
      _drawPOIMarker(canvas, Offset(center.dx + 110, center.dy - 100), "🏛️ Perundurai Turmeric Mandi (4.2 km)", Colors.amber.shade800);
      _drawPOIMarker(canvas, Offset(center.dx - 120, center.dy - 80), "🌾 Semmampalayam Regulated Market", Colors.orange.shade800);
      _drawPOIMarker(canvas, Offset(center.dx - 110, center.dy + 90), "🏪 Gobi Kisan Agro Center (14 km)", Colors.teal);
      _drawPOIMarker(canvas, Offset(center.dx + 100, center.dy + 110), "🌦️ KVK Erode Weather Radar (Myrada)", Colors.blue);
      _drawPOIMarker(canvas, Offset(center.dx - 80, center.dy - 130), "🥛 Aavin Dairy & Bio-Waste (Chithode)", Colors.purple);
      _drawPOIMarker(canvas, Offset(center.dx + 130, center.dy + 40), "🏭 Sakthi Sugars Mill Gate (Appakudal)", Colors.green);
    }
  }

  void _drawPOIMarker(Canvas canvas, Offset offset, String label, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(offset, 8, p);
    canvas.drawCircle(offset, 3, Paint()..color = Colors.white);

    _drawMapLabel(canvas, Offset(offset.dx - 30, offset.dy + 10), label, Colors.white, color.withValues(alpha: 0.9));
  }

  void _drawMapLabel(Canvas canvas, Offset offset, String text, Color textColor, Color bgColor) {
    final textSpan = TextSpan(
      text: " $text ",
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        backgroundColor: bgColor,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ErodeFarmMapPainter oldDelegate) {
    return oldDelegate.mapType != mapType ||
        oldDelegate.showBoundary != showBoundary ||
        oldDelegate.showPOIs != showPOIs ||
        oldDelegate.showCanal != showCanal ||
        oldDelegate.lat != lat ||
        oldDelegate.lng != lng ||
        oldDelegate.cityName != cityName ||
        oldDelegate.acres != acres;
  }
}
