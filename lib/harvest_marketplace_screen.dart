import 'package:flutter/material.dart';
import 'app_data.dart';
import 'crop_waste_marketplace_screen.dart';

class HarvestMarketplaceScreen extends StatefulWidget {
  const HarvestMarketplaceScreen({super.key});

  @override
  State<HarvestMarketplaceScreen> createState() => _HarvestMarketplaceScreenState();
}

class _HarvestMarketplaceScreenState extends State<HarvestMarketplaceScreen> {
  final AppState _appState = AppState();
  String _selectedCrop = "All";

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

  void _callBuyer(HarvestBuyer buyer) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.green),
            const SizedBox(width: 8),
            Text("Contact ${buyer.name}"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Buyer: ${buyer.name}"),
            Text("Purchasing: ${buyer.cropType} @ ₹${buyer.ratePerKg}/Kg"),
            Text("Location: ${buyer.location}"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    "+91 ${buyer.phone}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling ${buyer.name} at ${buyer.phone}..."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Dial Call"),
          ),
        ],
      ),
    );
  }

  void _requestSellQuote(HarvestBuyer buyer) {
    final qtyController = TextEditingController(text: "500");

    showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final qty = double.tryParse(qtyController.text) ?? 0;
            final totalPayout = qty * buyer.ratePerKg;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text("Sell ${buyer.cropType} to ${buyer.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rate Offered: ₹${buyer.ratePerKg}/Kg (₹${(buyer.ratePerKg * 100).toStringAsFixed(0)}/Quintal)"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity (Kg)",
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
                          const Text("Estimated Payout:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        title: "Sell Request Sent to ${buyer.name}",
                        message: "Requested to sell ${qty.toStringAsFixed(0)} Kg ${buyer.cropType} @ ₹${buyer.ratePerKg}/Kg. Buyer will contact you shortly.",
                        time: "Just now",
                        icon: Icons.sell,
                        iconColor: Colors.amber.shade800,
                        category: "market",
                      ),
                    );

                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sell request of ₹${totalPayout.toStringAsFixed(0)} sent to ${buyer.name}!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Confirm Sell Request"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openPostHarvestDialog() {
    final cropController = TextEditingController(text: "Groundnut");
    final rateController = TextEditingController(text: "78");
    final phoneController = TextEditingController(text: _appState.profile.phone);
    final locController = TextEditingController(text: _appState.profile.location);

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.add_business, color: Colors.green),
            SizedBox(width: 8),
            Text("List Your Harvest"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cropController,
                decoration: const InputDecoration(labelText: "Crop Name", border: OutlineInputBorder()),
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
                decoration: const InputDecoration(labelText: "Your Contact Number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: "Farm / Market Location", border: OutlineInputBorder()),
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
              final rate = double.tryParse(rateController.text) ?? 75.0;
              final newListing = HarvestBuyer(
                name: "${_appState.profile.name}'s Farm Lot",
                cropType: cropController.text.trim(),
                ratePerKg: rate,
                phone: phoneController.text.trim(),
                location: locController.text.trim(),
                isVerified: false,
              );
              _appState.addHarvestListing(newListing);
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Your harvest lot has been posted to the marketplace!"),
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
    final buyers = _appState.harvestBuyers.where((b) {
      if (_selectedCrop != "All") {
        return b.cropType.toLowerCase() == _selectedCrop.toLowerCase();
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Harvest Marketplace"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Post My Harvest",
            onPressed: _openPostHarvestDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Groundnut", "Maize", "Onion"].map((crop) {
                  final isSelected = _selectedCrop == crop;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: ChoiceChip(
                      label: Text(crop),
                      selected: isSelected,
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCrop = crop);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
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
                                backgroundColor: Colors.amber.shade100,
                                child: Icon(Icons.person, color: Colors.amber.shade900),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          buyer.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        if (buyer.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, size: 16, color: Colors.blue),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      "Buying ${buyer.cropType} • ${buyer.location}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${buyer.ratePerKg.toStringAsFixed(1)}/kg",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "₹${(buyer.ratePerKg * 100).toStringAsFixed(0)}/quintal",
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.phone, size: 18),
                                  label: const Text("Call Buyer"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green),
                                  ),
                                  onPressed: () => _callBuyer(buyer),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.sell, size: 18),
                                  label: const Text("Sell Harvest"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _requestSellQuote(buyer),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.eco),
              label: const Text("Sell Crop Waste / Agricultural Biomass"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropWasteMarketplaceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}