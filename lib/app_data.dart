import 'package:flutter/material.dart';
import 'weather_service.dart';

// --- Data Models ---

class FertilizerDetail {
  final String basalDose;
  final String vegetativeDose;
  final String floweringDose;
  final String micronutrients;
  final String organicAlternative;

  const FertilizerDetail({
    required this.basalDose,
    required this.vegetativeDose,
    required this.floweringDose,
    required this.micronutrients,
    required this.organicAlternative,
  });
}

class CropInfo {
  final String name;
  final String suitability;
  final int suitabilityPercent;
  final String season;
  final List<String> suitableSoil;
  final String seedingDate;
  final String waterSchedule;
  final String fertilizerSchedule;
  final String pesticideSchedule;
  final String harvestSchedule;
  final int harvestDays;
  final int expectedYieldPerAcreKg;
  final int averageMarketPricePerKg;
  final int estimatedCostPerAcre;
  final IconData icon;
  final FertilizerDetail fertilizerDetail;

  const CropInfo({
    required this.name,
    required this.suitability,
    required this.suitabilityPercent,
    required this.season,
    required this.suitableSoil,
    required this.seedingDate,
    required this.waterSchedule,
    required this.fertilizerSchedule,
    required this.pesticideSchedule,
    required this.harvestSchedule,
    required this.harvestDays,
    required this.expectedYieldPerAcreKg,
    required this.averageMarketPricePerKg,
    required this.estimatedCostPerAcre,
    this.icon = Icons.grass,
    required this.fertilizerDetail,
  });
}

class SeedProduct {
  final String id;
  final String shopName;
  final String cropName;
  final String variety;
  final double pricePerKg;
  final double rating;
  final String location;
  final bool inStock;

  const SeedProduct({
    required this.id,
    required this.shopName,
    required this.cropName,
    required this.variety,
    required this.pricePerKg,
    required this.rating,
    required this.location,
    this.inStock = true,
  });
}

class HarvestBuyer {
  final String name;
  final String cropType;
  final double ratePerKg;
  final String phone;
  final String location;
  final bool isVerified;

  const HarvestBuyer({
    required this.name,
    required this.cropType,
    required this.ratePerKg,
    required this.phone,
    required this.location,
    this.isVerified = true,
  });
}

class WasteBuyer {
  final String name;
  final String wasteType;
  final double ratePerKg;
  final String phone;
  final String location;

  const WasteBuyer({
    required this.name,
    required this.wasteType,
    required this.ratePerKg,
    required this.phone,
    required this.location,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final String category; // 'reminder', 'weather', 'order', 'market'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.category,
    this.isRead = false,
  });
}

class FarmerProfile {
  String name;
  String phone;
  String location;
  double landAreaAcres;
  String soilType;
  String waterSource;

  FarmerProfile({
    this.name = "Kamesh",
    this.phone = "9876543210",
    this.location = "Erode, Tamil Nadu",
    this.landAreaAcres = 3.0,
    this.soilType = "Red Loam Soil",
    this.waterSource = "Kalingarayan Canal & Drip Borewell",
  });
}

// --- Centralized App State & Database ---

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final FarmerProfile profile = FarmerProfile();
  LiveWeatherData? currentWeather;

  final List<NotificationItem> notifications = [
    NotificationItem(
      id: "1",
      title: "Turmeric Nutrition Alert",
      message: "Apply Gypsum 100kg/acre + Ferrous Sulphate on Erode Turmeric (Day 60).",
      time: "1 hour ago",
      icon: Icons.science,
      iconColor: Colors.amber.shade800,
      category: "reminder",
    ),
    NotificationItem(
      id: "2",
      title: "Kalingarayan Canal Water Release",
      message: "Bhavani river canal rotation scheduled for tomorrow morning.",
      time: "3 hours ago",
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      category: "reminder",
    ),
    NotificationItem(
      id: "3",
      title: "Erode Weather Radar Alert",
      message: "55% chance of light showers in Erode district tomorrow evening.",
      time: "Yesterday",
      icon: Icons.thunderstorm,
      iconColor: Colors.orange,
      category: "weather",
    ),
    NotificationItem(
      id: "4",
      title: "Perundurai Turmeric Mandi Rate",
      message: "Erode Finger Turmeric auction surged to ₹14,500/quintal (₹145/kg).",
      time: "2 days ago",
      icon: Icons.trending_up,
      iconColor: Colors.green,
      category: "market",
    ),
  ];

  final List<CropInfo> crops = const [
    CropInfo(
      name: "Turmeric (Erode Manjal)",
      suitability: "98% Suitable (GI Tag Zone)",
      suitabilityPercent: 98,
      season: "May - July Sowing (Kharif)",
      suitableSoil: ["Red Loam Soil", "Black Clay Loam", "Alluvial Soil"],
      seedingDate: "15 May - 15 June",
      waterSchedule: "Every 5-7 Days (Kalingarayan canal / Drip)",
      fertilizerSchedule: "Basal NPK 25:60:60 + Micronutrient spray at Day 60 & 90",
      pesticideSchedule: "Apply Trichoderma for Rhizome Rot prevention at Day 45",
      harvestSchedule: "270-285 Days After Planting (Feb - March)",
      harvestDays: 280,
      expectedYieldPerAcreKg: 10000,
      averageMarketPricePerKg: 140,
      estimatedCostPerAcre: 85000,
      icon: Icons.spa,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 75 kg + MOP (Potash) 50 kg + Neem Cake 200 kg + FYM 10 tons/acre",
        vegetativeDose: "Urea 35 kg + Micronutrient mix (TNAU Turmeric Booster) at Day 60",
        floweringDose: "Urea 30 kg + Potash 40 kg + Gypsum 100 kg/acre at Day 120 (Rhizome bulking)",
        micronutrients: "Ferrous Sulphate 5 kg + Zinc Sulphate 5 kg/acre (prevents leaf chlorosis)",
        organicAlternative: "Panchagavya 3% spray + Jeevamrut every 15 days via drip irrigation",
      ),
    ),
    CropInfo(
      name: "Sugarcane (Bhavani Belt)",
      suitability: "94% Suitable",
      suitabilityPercent: 94,
      season: "Special Season (Dec - Feb)",
      suitableSoil: ["Black Clay Soil", "Red Loam Soil"],
      seedingDate: "15 December - 15 February",
      waterSchedule: "Every 7-10 Days (Furrow / Drip)",
      fertilizerSchedule: "Heavy feeder: 110:45:45 NPK kg/acre in 4 splits",
      pesticideSchedule: "Control for Early Shoot Borer with Chlorantraniliprole",
      harvestSchedule: "330-360 Days After Planting",
      harvestDays: 345,
      expectedYieldPerAcreKg: 45000,
      averageMarketPricePerKg: 4,
      estimatedCostPerAcre: 70000,
      icon: Icons.park,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 100 kg + MOP 50 kg + Pressmud 5 tons/acre at furrow planting",
        vegetativeDose: "Urea 60 kg/acre at 45 days and 90 days after planting",
        floweringDose: "Final earthing up: Urea 50 kg + MOP 40 kg/acre at Day 120",
        micronutrients: "Ferrous Sulphate 10 kg + Zinc Sulphate 10 kg/acre",
        organicAlternative: "Bio-compost from Sakthi Sugars + Acetobacter bio-fertilizer",
      ),
    ),
    CropInfo(
      name: "Banana (Grand Naine / Nendran)",
      suitability: "92% Suitable",
      suitabilityPercent: 92,
      season: "All Season (Gobi & Kodumudi basin)",
      suitableSoil: ["Alluvial Soil", "Red Loam Soil", "Clay Loam"],
      seedingDate: "February - April & August - October",
      waterSchedule: "Daily 15-20 Litres/plant with Drip fertigation",
      fertilizerSchedule: "Weekly fertigation with 19:19:19, 13:0:45, and Potassium Nitrate",
      pesticideSchedule: "Pseudostem borer injection with Beauveria bassiana",
      harvestSchedule: "300-330 Days After Planting",
      harvestDays: 315,
      expectedYieldPerAcreKg: 32000,
      averageMarketPricePerKg: 26,
      estimatedCostPerAcre: 90000,
      icon: Icons.eco,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 50g + Potash 100g + Neem cake 500g + FYM 10kg per pit",
        vegetativeDose: "19:19:19 (5 kg/acre/week) via drip from 2nd to 5th month",
        floweringDose: "0:0:50 Sulphate of Potash 6 kg/acre/week during bunch emergence",
        micronutrients: "TNAU Banana Booster 500g/100L spray at bunch shooting",
        organicAlternative: "Vermicompost 5 kg/plant + Cow urine slurry monthly",
      ),
    ),
    CropInfo(
      name: "Paddy (CO-51 / ADT-45)",
      suitability: "90% Suitable",
      suitabilityPercent: 90,
      season: "Kuruvai / Thaladi (June-July & Oct-Nov)",
      suitableSoil: ["Clay Loam", "Alluvial Riverbed Soil"],
      seedingDate: "15 June - 15 July",
      waterSchedule: "Continuous shallow standing water 2-4 cm",
      fertilizerSchedule: "NPK 50:25:25 kg/acre in 3 equal splits",
      pesticideSchedule: "Neem oil spray at 30 days against leaf folder",
      harvestSchedule: "115-125 Days After Transplanting",
      harvestDays: 120,
      expectedYieldPerAcreKg: 2800,
      averageMarketPricePerKg: 25,
      estimatedCostPerAcre: 28000,
      icon: Icons.grain,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 50 kg + MOP 25 kg + Zinc Sulphate 10 kg/acre at final puddling",
        vegetativeDose: "Urea 30 kg/acre at active tillering (Day 25)",
        floweringDose: "Urea 20 kg + MOP 10 kg/acre at panicle initiation (Day 50)",
        micronutrients: "Zinc Sulphate 0.5% spray if leaves show Khaira yellowing",
        organicAlternative: "Azospirillum + Phosphobacteria 2 kg/acre + Green manure (Daincha)",
      ),
    ),
    CropInfo(
      name: "Groundnut (TMV-7 / VRI-2)",
      suitability: "88% Suitable",
      suitabilityPercent: 88,
      season: "Kharif & Rabi (Anthiyur / Bhavani)",
      suitableSoil: ["Red Sandy Loam", "Red Soil"],
      seedingDate: "June - July & Dec - Jan",
      waterSchedule: "Every 4-5 Days (critical at flowering & pegging)",
      fertilizerSchedule: "DAP 40 kg + Gypsum 160 kg/acre in 2 splits",
      pesticideSchedule: "Spray Chlorpyrifos on Day 35 for Spodoptera leaf miner",
      harvestSchedule: "105-115 Days After Sowing",
      harvestDays: 110,
      expectedYieldPerAcreKg: 1300,
      averageMarketPricePerKg: 78,
      estimatedCostPerAcre: 42000,
      icon: Icons.grass,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 40 kg + MOP 20 kg + Gypsum 80 kg/acre at sowing",
        vegetativeDose: "Urea 15 kg/acre at 20 days after germination",
        floweringDose: "Gypsum 120 kg/acre at Day 40-45 (essential for bold pod filling)",
        micronutrients: "TNAU Groundnut Booster spray at 35 and 50 days",
        organicAlternative: "Rhizobium seed treatment + 5 tons enriched farmyard manure",
      ),
    ),
    CropInfo(
      name: "Tapioca / Cassava (Gobi & Sathyamangalam)",
      suitability: "86% Suitable",
      suitabilityPercent: 86,
      season: "April - June & Oct - Nov",
      suitableSoil: ["Red Soil", "Sandy Loam"],
      seedingDate: "May - June",
      waterSchedule: "Every 7-10 Days (Drought tolerant)",
      fertilizerSchedule: "NPK 20:20:40 kg/acre at planting & 60 days",
      pesticideSchedule: "Sticky traps and predatory mites for Mealybug control",
      harvestSchedule: "270-300 Days After Planting",
      harvestDays: 285,
      expectedYieldPerAcreKg: 14000,
      averageMarketPricePerKg: 12,
      estimatedCostPerAcre: 45000,
      icon: Icons.circle,
      fertilizerDetail: FertilizerDetail(
        basalDose: "DAP 50 kg + MOP 40 kg/acre at stake planting",
        vegetativeDose: "Urea 30 kg + Potash 30 kg/acre at 60 days during earthing up",
        floweringDose: "MOP (Potash) 30 kg/acre at 120 days for maximum starch development",
        micronutrients: "Magnesium Sulphate 10 kg + Borax 2 kg/acre",
        organicAlternative: "Wood ash 200 kg/acre + 8 tons Farmyard manure",
      ),
    ),
  ];

  final List<SeedProduct> seedProducts = [
    const SeedProduct(
      id: "S1",
      shopName: "Erode Central Regulated Seed Market",
      cropName: "Turmeric",
      variety: "Erode Local Salem Gold (GI Certified)",
      pricePerKg: 145.0,
      rating: 4.9,
      location: "Semmampalayam Regulated Market, Erode",
    ),
    const SeedProduct(
      id: "S2",
      shopName: "Perundurai Agro Farmer Producer Co.",
      cropName: "Turmeric",
      variety: "IISR Pragati High Curcumin",
      pricePerKg: 155.0,
      rating: 4.8,
      location: "SIPCOT Industrial Complex, Perundurai",
    ),
    const SeedProduct(
      id: "S3",
      shopName: "Gobichettipalayam Kisan Kendra",
      cropName: "Paddy",
      variety: "CO-51 Certified Foundation Seed",
      pricePerKg: 42.0,
      rating: 4.7,
      location: "Kutchery Street, Gobi",
    ),
    const SeedProduct(
      id: "S4",
      shopName: "Bhavani River Basin Seed Hub",
      cropName: "Sugarcane",
      variety: "Co 0238 / Co 86032 Tissue Culture",
      pricePerKg: 8.5,
      rating: 4.9,
      location: "Kalingarayan Bridge, Bhavani",
    ),
    const SeedProduct(
      id: "S5",
      shopName: "Anthiyur Farmers Agro Mart",
      cropName: "Groundnut",
      variety: "TMV-7 Bold Pod Hybrid",
      pricePerKg: 110.0,
      rating: 4.6,
      location: "Cattle Fair Road, Anthiyur",
    ),
    const SeedProduct(
      id: "S6",
      shopName: "Sathyamangalam Agro Bio Care",
      cropName: "Banana",
      variety: "Grand Naine G9 Tissue Culture Plants",
      pricePerKg: 18.0,
      rating: 4.8,
      location: "Mysore Trunk Road, Sathy",
    ),
  ];

  final List<HarvestBuyer> harvestBuyers = [
    const HarvestBuyer(
      name: "Erode Turmeric Merchants Association",
      cropType: "Turmeric",
      ratePerKg: 142.5,
      phone: "9443211220",
      location: "Semmampalayam Market Yard, Erode",
      isVerified: true,
    ),
    const HarvestBuyer(
      name: "Perundurai Spices & Agro Exporters",
      cropType: "Turmeric",
      ratePerKg: 146.0,
      phone: "9443211221",
      location: "Agro SEZ, Perundurai",
      isVerified: true,
    ),
    const HarvestBuyer(
      name: "Sakthi Sugars Direct Cane Mill",
      cropType: "Sugarcane",
      ratePerKg: 4.2,
      phone: "9443211222",
      location: "Appakudal Mill Gate, Bhavani",
      isVerified: true,
    ),
    const HarvestBuyer(
      name: "Gobi Modern Rice Millers Association",
      cropType: "Paddy",
      ratePerKg: 25.5,
      phone: "9443211223",
      location: "Sathy Main Road, Gobichettipalayam",
      isVerified: true,
    ),
    const HarvestBuyer(
      name: "Cauvery Banana Trading Co.",
      cropType: "Banana",
      ratePerKg: 27.0,
      phone: "9443211224",
      location: "River Gate, Kodumudi",
      isVerified: true,
    ),
  ];

  final List<WasteBuyer> wasteBuyers = [
    const WasteBuyer(
      name: "Aavin Erode Dairy Farmers Cooperative",
      wasteType: "Sugarcane Tops, Paddy Straw & Fodder",
      ratePerKg: 5.5,
      phone: "9443299110",
      location: "Chithode Dairy Plant, Erode (6 km)",
    ),
    const WasteBuyer(
      name: "Erode Bio-Power & Biomass Energy Unit",
      wasteType: "Turmeric Boiled Residue & Tapioca Stalks",
      ratePerKg: 4.8,
      phone: "9443299111",
      location: "Perundurai SIPCOT Phase II",
    ),
    const WasteBuyer(
      name: "Bhavanisagar Cattle Feed & Bio-Gas Center",
      wasteType: "Banana Pseudostem & Green Residue",
      ratePerKg: 4.0,
      phone: "9443299112",
      location: "Dam Road, Bhavanisagar",
    ),
  ];

  // Helper Methods
  void addNotification(NotificationItem item) {
    notifications.insert(0, item);
    notifyListeners();
  }

  void removeNotification(String id) {
    notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var item in notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String location,
    required double landArea,
    required String soilType,
    required String waterSource,
  }) {
    profile.name = name;
    profile.phone = phone;
    profile.location = location;
    profile.landAreaAcres = landArea;
    profile.soilType = soilType;
    profile.waterSource = waterSource;
    notifyListeners();
  }

  void setProfileLocation(String location) {
    profile.location = location;
    notifyListeners();
  }

  void updateWeather(LiveWeatherData data) {
    currentWeather = data;
    notifyListeners();
  }

  void addHarvestListing(HarvestBuyer buyer) {
    harvestBuyers.insert(0, buyer);
    notifyListeners();
  }

  void addWasteListing(WasteBuyer buyer) {
    wasteBuyers.insert(0, buyer);
    notifyListeners();
  }

  CropInfo getCropByName(String name) {
    final lower = name.toLowerCase();
    return crops.firstWhere(
      (c) => c.name.toLowerCase().contains(lower) || lower.contains(c.name.toLowerCase()),
      orElse: () => crops.first,
    );
  }
}
