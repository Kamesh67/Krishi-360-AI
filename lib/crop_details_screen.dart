import 'package:flutter/material.dart';
import 'app_data.dart';
import 'seed_shop_screen.dart';
import 'weather_screen.dart';
import 'profit_prediction_screen.dart';

class CropDetailsScreen extends StatelessWidget {
  final CropInfo? crop;

  const CropDetailsScreen({super.key, this.crop});

  @override
  Widget build(BuildContext context) {
    final currentCrop = crop ?? AppState().crops.first;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text("${currentCrop.name} Advisory"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              color: Colors.green.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Icon(currentCrop.icon, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentCrop.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${currentCrop.suitability} for your soil",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Season: ${currentCrop.season} • ${currentCrop.harvestDays} Days Cycle",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildScheduleCard(
              context,
              icon: Icons.calendar_month,
              iconColor: Colors.blue,
              title: "Sowing / Seeding Window",
              subtitle: currentCrop.seedingDate,
            ),

            _buildScheduleCard(
              context,
              icon: Icons.water_drop,
              iconColor: Colors.teal,
              title: "Watering Schedule",
              subtitle: currentCrop.waterSchedule,
              actionLabel: "+ Set Alert",
              onAction: () {
                AppState().addNotification(
                  NotificationItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: "Watering Alert: ${currentCrop.name}",
                    message: "Irrigation scheduled as per ${currentCrop.waterSchedule}.",
                    time: "Just now",
                    icon: Icons.water_drop,
                    iconColor: Colors.blue,
                    category: "reminder",
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Watering reminder added for ${currentCrop.name}!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),

            _buildScheduleCard(
              context,
              icon: Icons.science,
              iconColor: Colors.purple,
              title: "Fertilizer Recommendation",
              subtitle: currentCrop.fertilizerSchedule,
              actionLabel: "+ Set Alert",
              onAction: () {
                AppState().addNotification(
                  NotificationItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: "Fertilizer Alert: ${currentCrop.name}",
                    message: currentCrop.fertilizerSchedule,
                    time: "Just now",
                    icon: Icons.science,
                    iconColor: Colors.purple,
                    category: "reminder",
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Fertilizer reminder added for ${currentCrop.name}!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),

            _buildScheduleCard(
              context,
              icon: Icons.bug_report,
              iconColor: Colors.red,
              title: "Pest & Disease Management",
              subtitle: currentCrop.pesticideSchedule,
            ),

            _buildScheduleCard(
              context,
              icon: Icons.agriculture,
              iconColor: Colors.green.shade800,
              title: "Harvest Timeline & Expected Yield",
              subtitle: "${currentCrop.harvestSchedule}\nEst. Yield: ~${currentCrop.expectedYieldPerAcreKg} Kg/Acre",
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.store),
                    label: const Text("Buy Seeds"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeedShopScreen(initialCrop: currentCrop.name),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud),
                    label: const Text("Weather"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              icon: const Icon(Icons.calculate, color: Colors.green),
              label: Text(
                "Calculate ${currentCrop.name} Profit & ROI",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfitPredictionScreen(initialCrop: currentCrop.name),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 13)),
        ),
        trailing: actionLabel != null
            ? TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: Colors.green,
                ),
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            : null,
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
         ),
    );
  }
}