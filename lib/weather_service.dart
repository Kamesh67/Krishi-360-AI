import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationCoordinates {
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String? district;
  final String? villageOrArea;

  const LocationCoordinates({
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.district,
    this.villageOrArea,
  });

  String get displayName => villageOrArea != null ? "$villageOrArea, $city, $state" : "$city, $state";
}

class LiveWeatherData {
  final String locationName;
  final double temperature;
  final int rainProbability;
  final int humidity;
  final double windSpeedKmH;
  final double soilMoisture;
  final String condition;
  final String iconCode;
  final bool isLive;
  final List<DailyForecast> dailyForecasts;
  final String advisory;

  const LiveWeatherData({
    required this.locationName,
    required this.temperature,
    required this.rainProbability,
    required this.humidity,
    required this.windSpeedKmH,
    required this.soilMoisture,
    required this.condition,
    required this.iconCode,
    this.isLive = true,
    required this.dailyForecasts,
    required this.advisory,
  });
}

class DailyForecast {
  final String dayName;
  final double maxTemp;
  final double minTemp;
  final int rainChance;
  final String condition;
  final String icon;

  const DailyForecast({
    required this.dayName,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
    required this.condition,
    required this.icon,
  });
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // Erode District Taluks and Major Agricultural Hubs
  static const List<LocationCoordinates> supportedLocations = [
    LocationCoordinates(
      city: "Erode Central",
      state: "Tamil Nadu",
      latitude: 11.3410,
      longitude: 77.7172,
      district: "Erode",
      villageOrArea: "Collectorate & Semmampalayam Market",
    ),
    LocationCoordinates(
      city: "Perundurai",
      state: "Tamil Nadu",
      latitude: 11.2758,
      longitude: 77.5828,
      district: "Erode",
      villageOrArea: "Perundurai Turmeric Mandi & SIPCOT",
    ),
    LocationCoordinates(
      city: "Gobichettipalayam",
      state: "Tamil Nadu",
      latitude: 11.4544,
      longitude: 77.4338,
      district: "Erode",
      villageOrArea: "Gobi Paddy Basin & KVK Agronomy",
    ),
    LocationCoordinates(
      city: "Bhavani",
      state: "Tamil Nadu",
      latitude: 11.4485,
      longitude: 77.6833,
      district: "Erode",
      villageOrArea: "Bhavani Sangameshwarar & Canal Basin",
    ),
    LocationCoordinates(
      city: "Sathyamangalam",
      state: "Tamil Nadu",
      latitude: 11.5034,
      longitude: 77.2415,
      district: "Erode",
      villageOrArea: "Bhavanisagar Dam & Banana Belt",
    ),
    LocationCoordinates(
      city: "Modakkurichi",
      state: "Tamil Nadu",
      latitude: 11.2374,
      longitude: 77.7719,
      district: "Erode",
      villageOrArea: "Kalingarayan Canal Farming Block",
    ),
    LocationCoordinates(
      city: "Kodumudi",
      state: "Tamil Nadu",
      latitude: 11.0805,
      longitude: 77.8860,
      district: "Erode",
      villageOrArea: "Cauvery Riverbank Sugarcane & Banana",
    ),
    LocationCoordinates(
      city: "Anthiyur",
      state: "Tamil Nadu",
      latitude: 11.5794,
      longitude: 77.5878,
      district: "Erode",
      villageOrArea: "Anthiyur Groundnut & Tapioca Hub",
    ),
    LocationCoordinates(
      city: "Chithode",
      state: "Tamil Nadu",
      latitude: 11.4116,
      longitude: 77.6744,
      district: "Erode",
      villageOrArea: "Aavin Dairy & Bio-Waste Plant",
    ),
    LocationCoordinates(
      city: "Coimbatore",
      state: "Tamil Nadu",
      latitude: 11.0168,
      longitude: 76.9558,
      district: "Coimbatore",
      villageOrArea: "TNAU Agri University",
    ),
    LocationCoordinates(
      city: "Salem",
      state: "Tamil Nadu",
      latitude: 11.6643,
      longitude: 78.1460,
      district: "Salem",
      villageOrArea: "Tapioca Sago & Mango Belt",
    ),
    LocationCoordinates(
      city: "Tiruppur",
      state: "Tamil Nadu",
      latitude: 11.1085,
      longitude: 77.3411,
      district: "Tiruppur",
      villageOrArea: "Palladam Poultry & Cotton Belt",
    ),
  ];

  LocationCoordinates getLocationByQuery(String query) {
    final lower = query.toLowerCase();
    return supportedLocations.firstWhere(
      (loc) => lower.contains(loc.city.toLowerCase()) || loc.displayName.toLowerCase().contains(lower),
      orElse: () => supportedLocations.first,
    );
  }

  Future<LiveWeatherData> fetchWeatherForLocation(LocationCoordinates loc) async {
    try {
      final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=${loc.latitude}&longitude=${loc.longitude}"
        "&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m"
        "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
        "&timezone=auto",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        final daily = data['daily'];

        final double temp = (current['temperature_2m'] as num).toDouble();
        final int humidity = (current['relative_humidity_2m'] as num).toInt();
        final double wind = (current['wind_speed_10m'] as num).toDouble();
        final int weatherCode = (current['weather_code'] as num).toInt();

        final List<dynamic> rainProbList = daily['precipitation_probability_max'] ?? [];
        final int rainProb = rainProbList.isNotEmpty ? (rainProbList[0] as num).toInt() : 45;

        final weatherInfo = _mapWeatherCode(weatherCode, rainProb);

        List<DailyForecast> forecasts = [];
        final List<dynamic> dates = daily['time'] ?? [];
        final List<dynamic> maxTemps = daily['temperature_2m_max'] ?? [];
        final List<dynamic> minTemps = daily['temperature_2m_min'] ?? [];
        final List<dynamic> codes = daily['weather_code'] ?? [];

        final dayNames = ["Today", "Tomorrow", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"];

        for (int i = 0; i < dates.length && i < 5; i++) {
          final dayCode = (codes[i] as num).toInt();
          final dayRain = i < rainProbList.length ? (rainProbList[i] as num).toInt() : 20;
          final mapped = _mapWeatherCode(dayCode, dayRain);

          forecasts.add(
            DailyForecast(
              dayName: i < dayNames.length ? dayNames[i] : "Day ${i + 1}",
              maxTemp: (maxTemps[i] as num).toDouble(),
              minTemp: (minTemps[i] as num).toDouble(),
              rainChance: dayRain,
              condition: mapped['condition']!,
              icon: mapped['icon']!,
            ),
          );
        }

        final advisory = _generateAgriAdvisory(loc.city, temp, rainProb, humidity, wind);

        return LiveWeatherData(
          locationName: loc.displayName,
          temperature: temp,
          rainProbability: rainProb,
          humidity: humidity,
          windSpeedKmH: wind,
          soilMoisture: (humidity * 0.85).clamp(40, 90).toDouble(),
          condition: weatherInfo['condition']!,
          iconCode: weatherInfo['icon']!,
          isLive: true,
          dailyForecasts: forecasts,
          advisory: advisory,
        );
      }
    } catch (_) {
      // Fallback
    }

    return _generateRealisticFallback(loc);
  }

  Map<String, String> _mapWeatherCode(int code, int rainProb) {
    if (code == 0) return {"condition": "Clear Sky & Sunny", "icon": "sunny"};
    if (code == 1 || code == 2) return {"condition": "Mainly Clear / Partly Sunny", "icon": "partly_sunny"};
    if (code == 3) return {"condition": "Overcast & Cloudy", "icon": "cloudy"};
    if (code >= 51 && code <= 67) return {"condition": "Rain Showers ($rainProb% Chance)", "icon": "rain"};
    if (code >= 71 && code <= 77) return {"condition": "Hail / Cold Wave", "icon": "cold"};
    if (code >= 80 && code <= 82) return {"condition": "Heavy Rain Showers ($rainProb%)", "icon": "heavy_rain"};
    if (code >= 95) return {"condition": "Thunderstorm & Rain ($rainProb%)", "icon": "thunder"};
    return {"condition": "Partly Cloudy", "icon": "partly_sunny"};
  }

  String _generateAgriAdvisory(String city, double temp, int rainChance, int humidity, double wind) {
    if (rainChance >= 60) {
      return "⚠️ High Rain Probability ($rainChance%) in $city: Suspend canal/borewell irrigation. Protect harvested Turmeric & Paddy drying in field yards. Avoid pesticide spray today.";
    } else if (wind > 20) {
      return "💨 High wind speed ($wind km/h) in $city: Avoid spraying agrochemicals to prevent drift. Stake Banana trees to prevent lodging.";
    } else if (temp > 35) {
      return "☀️ High Temperature ($temp°C) in $city: Provide light evening irrigation through drip systems for Turmeric & Sugarcane. Mulch soil to conserve moisture.";
    } else {
      return "✅ Ideal Farming Weather in $city: Optimum conditions for fertilizer application (DAP/Urea/Potash) and micro-nutrient foliar spray between 4 PM - 6 PM.";
    }
  }

  LiveWeatherData _generateRealisticFallback(LocationCoordinates loc) {
    final double temp = (31.0 + (loc.latitude % 2)).clamp(28.0, 36.0);
    final int rainChance = 55;
    final int humidity = 72;

    return LiveWeatherData(
      locationName: loc.displayName,
      temperature: double.parse(temp.toStringAsFixed(1)),
      rainProbability: rainChance,
      humidity: humidity,
      windSpeedKmH: 12.5,
      soilMoisture: 70.0,
      condition: "Partly Cloudy (Rain Chance $rainChance%)",
      iconCode: "partly_sunny",
      isLive: false,
      dailyForecasts: [
        DailyForecast(dayName: "Today", maxTemp: temp, minTemp: temp - 8, rainChance: rainChance, condition: "Partly Cloudy", icon: "partly_sunny"),
        DailyForecast(dayName: "Tomorrow", maxTemp: temp - 1, minTemp: temp - 9, rainChance: 65, condition: "Light Rain Showers", icon: "rain"),
        DailyForecast(dayName: "Day 3", maxTemp: temp + 1, minTemp: temp - 7, rainChance: 30, condition: "Clear & Sunny", icon: "sunny"),
        DailyForecast(dayName: "Day 4", maxTemp: temp + 2, minTemp: temp - 6, rainChance: 15, condition: "Clear Sky", icon: "sunny"),
        DailyForecast(dayName: "Day 5", maxTemp: temp, minTemp: temp - 8, rainChance: 25, condition: "Cloudy", icon: "cloudy"),
      ],
      advisory: _generateAgriAdvisory(loc.city, temp, rainChance, humidity, 12.5),
    );
  }
}
