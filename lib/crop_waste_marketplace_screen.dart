import 'package:flutter/material.dart';
import 'app_data.dart';

class CropWasteMarketplaceScreen extends StatefulWidget {
  const CropWasteMarketplaceScreen({super.key});

  @override
  State<CropWasteMarketplaceScreen> createState() => _CropWasteMarketplaceScreenState();
}

class _CropWasteMarketplaceScreenState extends State<CropWasteMarketplaceScreen> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _sellWasteDialog(WasteBuyer buyer) {
    final qtyController = TextEditingController(text: "800");

    showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final qty = double.tryParse(qtyController.text) ?? 0;
            final totalPayout = qty * buyer.ratePerKg;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text("Sell Waste to ${buyer.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Waste Type: ${buyer.wasteType}"),
                    Text("Rate Offered: ₹${buyer.ratePerKg}/Kg (₹${(buyer.ratePerKg * 1000).toStringAsFixed(0)}/Ton)"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Estimated Waste Weight (Kg)",
                        suffixText: "Kg",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Estimated Income:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "₹${totalPayout.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    AppState().addNotification(
                      NotificationItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: "Crop Waste Pickup Booked",
                        message: "${buyer.name} booked pickup for ${qty.toStringAsFixed(0)} Kg ${buyer.wasteType}. Payout: ₹${totalPayout.toStringAsFixed(0)}.",
                        time: "Just now",
                        icon: Icons.eco,
                        iconColor: Colors.lightGreen.shade800,
                        category: "market",
                      ),
                    );

                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Pickup scheduled with ${buyer.name}! Earn ₹${totalPayout.toStringAsFixed(0)}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Confirm Pickup"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openPostWasteDialog() {
    final typeController = TextEditingController(text: "Groundnut Stalks & Shells");
    final rateController = TextEditingController(text: "4.5");
    final phoneController = TextEditingController(text: _appState.profile.phone);
    final locController = TextEditingController(text: _appState.profile.location);

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.eco, color: Colors.green),
            SizedBox(width: 8),
            Text("List Crop Waste"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Waste Type / Residue", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Expected Rate (₹/Kg)",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Contact Number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: "Pickup Farm Location", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final rate = double.tryParse(rateController.text) ?? 4.0;
              final newListing = WasteBuyer(
                name: "${_appState.profile.name}'s Farm Biomass",
                wasteType: typeController.text.trim(),
                ratePerKg: rate,
                phone: phoneController.text.trim(),
                location: locController.text.trim(),
              );
              _appState.addWasteListing(newListing);
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Crop waste listed successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Publish Listing"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buyers = _appState.wasteBuyers;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Crop Waste Marketplace"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Post Waste for Sale",
            onPressed: _openPostWasteDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: buyers.length,
        itemBuilder: (context, index) {
          final buyer = buyers[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.lightGreen.shade100,
                        child: const Icon(Icons.eco, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buyer.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              buyer.location,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${buyer.ratePerKg.toStringAsFixed(1)}/Kg",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.recycling, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Looking for: ${buyer.wasteType}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.currency_rupee, size: 18),
                      label: const Text("Calculate & Sell Residue"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _sellWasteDialog(buyer),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}