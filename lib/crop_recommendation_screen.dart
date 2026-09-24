import 'package:flutter/material.dart';
import 'app_data.dart';
import 'crop_details_screen.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final profile = appState.profile;

    List<CropInfo> filteredCrops = appState.crops.where((crop) {
      final matchesSearch = crop.name.toLowerCase().contains(_searchController.text.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedFilter == "My Soil") {
        return crop.suitableSoil.contains(profile.soilType);
      } else if (_selectedFilter == "Kharif") {
        return crop.season.contains("Kharif");
      } else if (_selectedFilter == "Rabi") {
        return crop.season.contains("Rabi");
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Recommended Crops"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search crops (e.g. Groundnut, Maize...)",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All"),
                  _buildFilterChip("My Soil (${profile.soilType})", value: "My Soil"),
                  _buildFilterChip("Kharif Season", value: "Kharif"),
                  _buildFilterChip("Rabi Season", value: "Rabi"),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredCrops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.spa, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          "No crops found for '$_selectedFilter'",
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      final isTop = crop.suitabilityPercent >= 90;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CropDetailsScreen(crop: crop),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: isTop ? Colors.green.shade100 : Colors.blue.shade100,
                                  child: Icon(crop.icon, color: isTop ? Colors.green : Colors.blue, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            crop.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isTop ? Colors.green.shade700 : Colors.blue.shade700,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              crop.suitability,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Yield: ~${crop.expectedYieldPerAcreKg} kg/acre • Rate: ~₹${crop.averageMarketPricePerKg}/kg",
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${crop.season} • ${crop.harvestDays} Days",
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                          const Spacer(),
                                          const Text(
                                            "View Guide >",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {String? value}) {
    final chipVal = value ?? label;
    final isSelected = _selectedFilter == chipVal;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.green.shade200,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.green.shade800,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = chipVal;
          });
        },
      ),
    );
  }
}