import 'package:flutter/material.dart';
import 'app_data.dart';
import 'weather_service.dart';
import 'farm_map_screen.dart';
import 'crop_recommendation_screen.dart';
import 'weather_screen.dart';
import 'seed_shop_screen.dart';
import 'harvest_marketplace_screen.dart';
import 'crop_waste_marketplace_screen.dart';
import 'profit_prediction_screen.dart';
import 'ai_assistant_screen.dart';
import 'notification_screen.dart';
import 'farmer_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
    _loadLiveWeather();
  }

  void _loadLiveWeather() async {
    final loc = WeatherService().getLocationByQuery(_appState.profile.location);
    final data = await WeatherService().fetchWeatherForLocation(loc);
    if (mounted) {
      _appState.updateWeather(data);
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _appState.profile;
    final unreadCount = _appState.notifications.where((n) => !n.isRead).length;
    final weather = _appState.currentWeather;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Krishi360 AI"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: "Farm Map",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FarmMapScreen()),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: "Alerts & Notifications",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      "$unreadCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Farmer Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmerDetailsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerDetailsScreen(),
                  ),
                );
              },
              child: Card(
                color: Colors.green.shade100,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    "Welcome ${profile.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("${profile.soilType} • ${profile.landAreaAcres} Acres • ${profile.location}"),
                  trailing: const Icon(Icons.edit, size: 20, color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeatherScreen(),
                  ),
                );
              },
              child: Card(
                color: weather != null && weather.rainProbability >= 50 ? Colors.blue.shade100 : Colors.lightBlue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    weather != null && weather.rainProbability >= 50 ? Icons.cloud_queue : Icons.wb_sunny,
                    color: Colors.blue.shade700,
                    size: 36,
                  ),
                  title: Text(
                    weather != null ? "${weather.temperature.toStringAsFixed(1)}°C • ${weather.condition}" : "32.0°C • Partly Sunny",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    weather != null ? "Rain Chance: ${weather.rainProbability}% • Humidity: ${weather.humidity}% • Tap for Radar" : "Rain Chance: 60% • Tap for live Agri forecast",
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard(
                    context,
                    Icons.grass,
                    "Crops",
                    "Advisory & Sowing",
                    Colors.green,
                    const CropRecommendationScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.cloud,
                    "Weather",
                    "Real API & Radar",
                    Colors.lightBlue,
                    const WeatherScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.map,
                    "Farm Map",
                    "Satellite & GPS",
                    Colors.indigo,
                    const FarmMapScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.smart_toy,
                    "AI Assistant",
                    "Voice TTS & Yield",
                    Colors.teal.shade700,
                    const AIAssistantScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.store,
                    "Seed Shop",
                    "Certified Seeds",
                    Colors.teal,
                    const SeedShopScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.sell,
                    "Harvest",
                    "Sell Produce",
                    Colors.amber.shade800,
                    const HarvestMarketplaceScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.eco,
                    "Crop Waste",
                    "Biomass & Residue",
                    Colors.lightGreen.shade700,
                    const CropWasteMarketplaceScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.show_chart,
                    "Profit",
                    "Yield & ROI Calc",
                    Colors.deepOrange,
                    const ProfitPredictionScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.notifications,
                    "Alerts",
                    "$unreadCount pending",
                    Colors.red.shade600,
                    const NotificationScreen(),
                  ),
                  _buildCard(
                    context,
                    Icons.person,
                    "Profile",
                    "Land & Farm Info",
                    Colors.green.shade800,
                    const FarmerDetailsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}