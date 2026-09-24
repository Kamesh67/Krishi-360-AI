import 'package:flutter/material.dart';
import 'app_data.dart';

class ProfitPredictionScreen extends StatefulWidget {
  final String? initialCrop;

  const ProfitPredictionScreen({super.key, this.initialCrop});

  @override
  State<ProfitPredictionScreen> createState() => _ProfitPredictionScreenState();
}

class _ProfitPredictionScreenState extends State<ProfitPredictionScreen> {
  late CropInfo _selectedCrop;
  double _landAreaAcres = 2.5;
  late double _expectedYieldKgPerAcre;
  late double _marketPricePerKg;
  late double _costPerAcre;

  @override
  void initState() {
    super.initState();
    final appState = AppState();
    if (widget.initialCrop != null) {
      _selectedCrop = appState.getCropByName(widget.initialCrop!);
    } else {
      _selectedCrop = appState.crops.first;
    }
    _landAreaAcres = appState.profile.landAreaAcres;
    _updateValuesForCrop(_selectedCrop);
  }

  void _updateValuesForCrop(CropInfo crop) {
    _expectedYieldKgPerAcre = crop.expectedYieldPerAcreKg.toDouble();
    _marketPricePerKg = crop.averageMarketPricePerKg.toDouble();
    _costPerAcre = crop.estimatedCostPerAcre.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    // Calculations
    final double totalYieldKg = _landAreaAcres * _expectedYieldKgPerAcre;
    final double grossRevenue = totalYieldKg * _marketPricePerKg;
    final double totalCost = _landAreaAcres * _costPerAcre;
    final double netProfit = grossRevenue - totalCost;
    final double roiPercent = totalCost > 0 ? (netProfit / totalCost) * 100 : 0.0;
    final bool isProfitable = netProfit > 0;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Profit & ROI Predictor"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: "Save Projection",
            onPressed: () {
              appState.addNotification(
                NotificationItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: "Profit Projection Saved",
                  message: "${_selectedCrop.name} ($_landAreaAcres Acres): Expected Profit ₹${netProfit.toStringAsFixed(0)} with ROI ${roiPercent.toStringAsFixed(1)}%.",
                  time: "Just now",
                  icon: Icons.show_chart,
                  iconColor: Colors.deepOrange,
                  category: "market",
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Projection saved to Notifications!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Crop & Land Area Selection Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Crop & Farm Parameters",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CropInfo>(
                      initialValue: _selectedCrop,
                      decoration: const InputDecoration(
                        labelText: "Select Crop",
                        prefixIcon: Icon(Icons.grass, color: Colors.green),
                        border: OutlineInputBorder(),
                      ),
                      items: appState.crops.map((crop) {
                        return DropdownMenuItem(
                          value: crop,
                          child: Text(crop.name),
                        );
                      }).toList(),
                      onChanged: (newCrop) {
                        if (newCrop != null) {
                          setState(() {
                            _selectedCrop = newCrop;
                            _updateValuesForCrop(newCrop);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Land Area:", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          "${_landAreaAcres.toStringAsFixed(1)} Acres",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _landAreaAcres,
                      min: 0.5,
                      max: 20.0,
                      divisions: 39,
                      activeColor: Colors.green,
                      label: "${_landAreaAcres.toStringAsFixed(1)} Acres",
                      onChanged: (val) => setState(() => _landAreaAcres = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Yield & Price Inputs Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Yield & Market Estimations",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Expected Yield / Acre:"),
                        Text(
                          "${_expectedYieldKgPerAcre.toStringAsFixed(0)} Kg/Acre",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _expectedYieldKgPerAcre,
                      min: (_selectedCrop.expectedYieldPerAcreKg * 0.4),
                      max: (_selectedCrop.expectedYieldPerAcreKg * 1.8),
                      activeColor: Colors.blue,
                      onChanged: (v) => setState(() => _expectedYieldKgPerAcre = v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Selling Market Price:"),
                        Text(
                          "₹${_marketPricePerKg.toStringAsFixed(1)} / Kg",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    Slider(
                      value: _marketPricePerKg,
                      min: (_selectedCrop.averageMarketPricePerKg * 0.5),
                      max: (_selectedCrop.averageMarketPricePerKg * 2.0),
                      activeColor: Colors.teal,
                      onChanged: (v) => setState(() => _marketPricePerKg = v),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Prediction Results
            Card(
              color: isProfitable ? Colors.green.shade100 : Colors.red.shade100,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Expected Total Profit:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "₹${netProfit.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isProfitable ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryMetric("Total Harvest", "${totalYieldKg.toStringAsFixed(0)} Kg"),
                        _buildSummaryMetric("Gross Revenue", "₹${grossRevenue.toStringAsFixed(0)}"),
                        _buildSummaryMetric("Total Cost", "₹${totalCost.toStringAsFixed(0)}"),
                        _buildSummaryMetric("Estimated ROI", "${roiPercent.toStringAsFixed(1)}%"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Farming Tip Card
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Tip: You can generate an additional ₹${(_landAreaAcres * 3500).toStringAsFixed(0)} by selling crop residue/waste in the Crop Waste Marketplace!",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade800)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}