import 'package:flutter/material.dart';
import 'app_data.dart';
import 'crop_recommendation_screen.dart';
import 'farm_map_screen.dart';
import 'weather_service.dart';

class FarmerDetailsScreen extends StatefulWidget {
  const FarmerDetailsScreen({super.key});

  @override
  State<FarmerDetailsScreen> createState() => _FarmerDetailsScreenState();
}

class _FarmerDetailsScreenState extends State<FarmerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _landAreaController;

  String _selectedSoil = "Red Soil";
  String _selectedIrrigation = "Drip Irrigation";

  final List<String> _soilTypes = [
    "Red Soil",
    "Black Soil",
    "Sandy Soil",
    "Loamy Soil",
    "Clay Soil",
  ];

  final List<String> _irrigationSources = [
    "Drip Irrigation",
    "Borewell / Tube Well",
    "Canal / River",
    "Sprinkler System",
    "Rainfed / Monsoon",
  ];

  @override
  void initState() {
    super.initState();
    final profile = AppState().profile;
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
    _locationController = TextEditingController(text: profile.location);
    _landAreaController = TextEditingController(text: profile.landAreaAcres.toString());
    _selectedSoil = _soilTypes.contains(profile.soilType) ? profile.soilType : _soilTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _landAreaController.dispose();
    super.dispose();
  }

  void _saveProfile({bool navigateToCrops = false}) {
    if (!_formKey.currentState!.validate()) return;

    final acres = double.tryParse(_landAreaController.text.trim()) ?? 1.0;

    AppState().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      landArea: acres,
      soilType: _selectedSoil,
      waterSource: _selectedIrrigation,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile for ${_nameController.text} updated successfully!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    if (navigateToCrops) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CropRecommendationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Farmer Details"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save Profile",
            onPressed: () => _saveProfile(navigateToCrops: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Farmer Name",
                          prefixIcon: Icon(Icons.person, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          prefixIcon: Icon(Icons.phone, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.length < 10 ? "Enter 10-digit number" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: "Location / District",
                          prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map, color: Colors.green),
                            tooltip: "Pick Location on Farm Map",
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FarmMapScreen(),
                                ),
                              );
                              if (result is LocationCoordinates) {
                                setState(() {
                                  _locationController.text = result.displayName;
                                });
                              }
                            },
                          ),
                          border: const OutlineInputBorder(),
                          hintText: "e.g. Nashik, Maharashtra",
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _landAreaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Land Area (Acres)",
                          prefixIcon: Icon(Icons.landscape, color: Colors.green),
                          border: OutlineInputBorder(),
                          suffixText: "Acres",
                        ),
                        validator: (v) {
                          if (v == null || double.tryParse(v) == null) {
                            return "Enter valid land area";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSoil,
                        decoration: const InputDecoration(
                          labelText: "Soil Type",
                          prefixIcon: Icon(Icons.terrain, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        items: _soilTypes.map((soil) {
                          return DropdownMenuItem(
                            value: soil,
                            child: Text(soil),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSoil = val);
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedIrrigation,
                        decoration: const InputDecoration(
                          labelText: "Water / Irrigation Source",
                          prefixIcon: Icon(Icons.water, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        items: _irrigationSources.map((source) {
                          return DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedIrrigation = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.psychology),
                label: const Text(
                  "Get AI Crop Recommendations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _saveProfile(navigateToCrops: true),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.save, color: Colors.green),
                label: const Text(
                  "Save Details Only",
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _saveProfile(navigateToCrops: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}