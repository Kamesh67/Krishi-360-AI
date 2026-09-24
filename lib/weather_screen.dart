import 'package:flutter/material.dart';
import 'app_data.dart';
import 'weather_service.dart';
import 'farm_map_screen.dart';
import 'harvest_marketplace_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  late LocationCoordinates _selectedLocation;
  LiveWeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final profile = AppState().profile;
    _selectedLocation = _weatherService.getLocationByQuery(profile.location);
    _loadWeather();
  }

  void _loadWeather() async {
    setState(() => _isLoading = true);
    final data = await _weatherService.fetchWeatherForLocation(_selectedLocation);
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
      AppState().updateWeather(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weatherData;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Real Weather & Agri Radar"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: "Open Farm Map",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmMapScreen(
                    initialLat: _selectedLocation.latitude,
                    initialLng: _selectedLocation.longitude,
                  ),
                ),
              );
              if (result is LocationCoordinates) {
                setState(() => _selectedLocation = result);
                _loadWeather();
              }
            },
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: "Refresh Live Weather",
            onPressed: _isLoading ? null : _loadWeather,
          ),
        ],
      ),
      body: _isLoading && weather == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Location Selector & Map Shortcut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<LocationCoordinates>(
                              value: _selectedLocation,
                              isExpanded: true,
                              items: WeatherService.supportedLocations.map((loc) {
                                return DropdownMenuItem(value: loc, child: Text(loc.displayName));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedLocation = val);
                                  _loadWeather();
                                }
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pin_drop, color: Colors.green),
                          tooltip: "View on Map",
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmMapScreen(
                                  initialLat: _selectedLocation.latitude,
                                  initialLng: _selectedLocation.longitude,
                                ),
                              ),
                            );
                            if (result is LocationCoordinates) {
                              setState(() => _selectedLocation = result);
                              _loadWeather();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Main Weather Card
                  if (weather != null) ...[
                    Card(
                      color: weather.rainProbability >= 50 ? Colors.blue.shade100 : Colors.orange.shade100,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              weather.rainProbability >= 50 ? Icons.thunderstorm : Icons.wb_sunny,
                              size: 54,
                              color: weather.rainProbability >= 50 ? Colors.blue.shade800 : Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${weather.temperature.toStringAsFixed(1)}°C",
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: weather.isLive ? Colors.green : Colors.blueGrey,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          weather.isLive ? "LIVE API" : "CALCULATED",
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    weather.condition,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "GPS: ${_selectedLocation.latitude}°N, ${_selectedLocation.longitude}°E",
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Metrics Grid (Rain Chance, Humidity, Wind, Soil Moisture)
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.blue.shade100,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: const Icon(Icons.cloud, color: Colors.blue),
                              title: const Text("Rain Chance", style: TextStyle(fontSize: 12)),
                              subtitle: Text(
                                "${weather.rainProbability}%",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: weather.rainProbability >= 60 ? Colors.blue.shade900 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            color: Colors.green.shade100,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: const Icon(Icons.water_drop, color: Colors.green),
                              title: const Text("Humidity", style: TextStyle(fontSize: 12)),
                              subtitle: Text("${weather.humidity}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.teal.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: const Icon(Icons.air, color: Colors.teal),
                              title: const Text("Wind Speed", style: TextStyle(fontSize: 12)),
                              subtitle: Text("${weather.windSpeedKmH} km/h", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            color: Colors.purple.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: const Icon(Icons.grass, color: Colors.purple),
                              title: const Text("Soil Moisture", style: TextStyle(fontSize: 12)),
                              subtitle: Text("${weather.soilMoisture.toStringAsFixed(0)}% (Good)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Real Agri Advisory
                    Card(
                      color: weather.rainProbability >= 50 ? Colors.amber.shade100 : Colors.green.shade100,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  weather.rainProbability >= 50 ? Icons.warning_amber_rounded : Icons.eco,
                                  color: weather.rainProbability >= 50 ? Colors.amber.shade900 : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Real Agricultural Advisory",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weather.advisory,
                              style: const TextStyle(fontSize: 13, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 5-Day Real Forecast
                    const Text(
                      "5-Day Meteorological Forecast",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...weather.dailyForecasts.map((f) {
                      IconData iconData = Icons.wb_sunny;
                      Color iconColor = Colors.orange;
                      if (f.icon == "rain" || f.icon == "heavy_rain") {
                        iconData = Icons.grain;
                        iconColor = Colors.blue;
                      } else if (f.icon == "thunder") {
                        iconData = Icons.thunderstorm;
                        iconColor = Colors.indigo;
                      } else if (f.icon == "cloudy") {
                        iconData = Icons.cloud;
                        iconColor = Colors.blueGrey;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          dense: true,
                          leading: Icon(iconData, color: iconColor),
                          title: Text(f.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${f.condition} • Rain: ${f.rainChance}%"),
                          trailing: Text(
                            "${f.maxTemp.toStringAsFixed(0)}° / ${f.minTemp.toStringAsFixed(0)}°C",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.map, color: Colors.green),
                          label: const Text("View Farm Map"),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmMapScreen(
                                  initialLat: _selectedLocation.latitude,
                                  initialLng: _selectedLocation.longitude,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.sell),
                          label: const Text("Sell Harvest"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HarvestMarketplaceScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}