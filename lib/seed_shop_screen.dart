import 'package:flutter/material.dart';
import 'app_data.dart';

class SeedShopScreen extends StatefulWidget {
  final String? initialCrop;

  const SeedShopScreen({super.key, this.initialCrop});

  @override
  State<SeedShopScreen> createState() => _SeedShopScreenState();
}

class _SeedShopScreenState extends State<SeedShopScreen> {
  late String _selectedCropFilter;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _cropFilters = [
    "All",
    "Groundnut",
    "Maize",
    "Onion",
    "Cotton",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCrop != null && _cropFilters.contains(widget.initialCrop)) {
      _selectedCropFilter = widget.initialCrop!;
    } else {
      _selectedCropFilter = "All";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCheckoutDialog(SeedProduct product) {
    int quantityKg = 10;
    String paymentMethod = "Cash on Delivery (COD)";
    final addressController = TextEditingController(text: AppState().profile.location);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double totalAmount = quantityKg * product.pricePerKg;

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Order ${product.cropName} Seeds",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    product.shopName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  Text("Variety: ${product.variety} • ₹${product.pricePerKg.toStringAsFixed(0)}/Kg"),
                  const SizedBox(height: 16),

                  // Quantity Selector
                  const Text("Select Quantity (Kg):", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.outlined(
                        icon: const Icon(Icons.remove),
                        onPressed: quantityKg > 1
                            ? () => setModalState(() => quantityKg -= 1)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Text(
                          "$quantityKg Kg",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.add),
                        onPressed: () => setModalState(() => quantityKg += 1),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        children: [5, 10, 25, 50].map((preset) {
                          return ChoiceChip(
                            label: Text("${preset}kg"),
                            selected: quantityKg == preset,
                            onSelected: (selected) {
                              if (selected) setModalState(() => quantityKg = preset);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Delivery Address
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Delivery Address / Farm Location",
                      prefixIcon: Icon(Icons.local_shipping, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Payment Method
                  DropdownButtonFormField<String>(
                    initialValue: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: "Payment Method",
                      prefixIcon: Icon(Icons.payment, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Cash on Delivery (COD)",
                        child: Text("Cash on Delivery (COD)"),
                      ),
                      DropdownMenuItem(
                        value: "UPI / QR Payment",
                        child: Text("UPI / Online Payment"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentMethod = val);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Total Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch % 100000}";
                        AppState().addNotification(
                          NotificationItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: "Seed Order Placed ($orderId)",
                            message: "Ordered $quantityKg Kg ${product.variety} from ${product.shopName}. Total: ₹${totalAmount.toStringAsFixed(0)} ($paymentMethod).",
                            time: "Just now",
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                            category: "order",
                          ),
                        );

                        Navigator.pop(ctx);

                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 28),
                                SizedBox(width: 8),
                                Text("Order Confirmed!"),
                              ],
                            ),
                            content: Text(
                              "Your order for $quantityKg Kg ${product.cropName} seeds from ${product.shopName} has been received.\n\nOrder ID: $orderId\nEstimated Delivery: 2-3 business days to ${addressController.text}.",
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(c),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Confirm Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final seedProducts = AppState().seedProducts.where((p) {
      final matchesSearch = p.shopName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.variety.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.cropName.toLowerCase().contains(_searchController.text.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedCropFilter != "All") {
        return p.cropName.toLowerCase() == _selectedCropFilter.toLowerCase();
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Certified Seed Shops"),
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
                hintText: "Search seed shops or varieties...",
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
                children: _cropFilters.map((filter) {
                  final isSelected = _selectedCropFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.green.shade800,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCropFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: seedProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No seed vendors found for selected filter",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: seedProducts.length,
                    itemBuilder: (context, index) {
                      final product = seedProducts[index];
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
                                    backgroundColor: Colors.green.shade100,
                                    child: const Icon(Icons.store, color: Colors.green),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              product.shopName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified, size: 16, color: Colors.blue),
                                          ],
                                        ),
                                        Text(
                                          product.location,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 2),
                                        Text(
                                          product.rating.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${product.cropName} Seeds",
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        Text(
                                          product.variety,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${product.pricePerKg.toStringAsFixed(0)}/kg",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Text("In Stock", style: TextStyle(fontSize: 11, color: Colors.teal)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.shopping_cart, size: 18),
                                  label: const Text("Order Seeds Now"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _openCheckoutDialog(product),
                                ),
                              ),
                            ],
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
}