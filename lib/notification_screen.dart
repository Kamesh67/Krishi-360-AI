import 'package:flutter/material.dart';
import 'app_data.dart';
import 'weather_screen.dart';
import 'crop_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AppState _appState = AppState();
  String _selectedCategory = "All";

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

  void _openAddReminderDialog() {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String category = "reminder";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.add_alert, color: Colors.green),
                SizedBox(width: 8),
                Text("Add Custom Reminder"),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Reminder Title",
                      hintText: "e.g. Weeding Maize field",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: msgController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Details / Instruction",
                      hintText: "e.g. Check soil moisture & apply herbicide",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "reminder", child: Text("Farming Reminder")),
                      DropdownMenuItem(value: "weather", child: Text("Weather Alert")),
                      DropdownMenuItem(value: "market", child: Text("Market & Price Alert")),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
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
                  if (titleController.text.trim().isEmpty) return;

                  IconData icon = Icons.notifications;
                  Color iconColor = Colors.green;
                  if (category == "weather") {
                    icon = Icons.cloud;
                    iconColor = Colors.blue;
                  } else if (category == "market") {
                    icon = Icons.trending_up;
                    iconColor = Colors.amber.shade800;
                  } else {
                    icon = Icons.alarm;
                    iconColor = Colors.purple;
                  }

                  _appState.addNotification(
                    NotificationItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      message: msgController.text.trim().isEmpty
                          ? "Custom reminder created."
                          : msgController.text.trim(),
                      time: "Just now",
                      icon: icon,
                      iconColor: iconColor,
                      category: category,
                    ),
                  );

                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reminder added successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Save Alert"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _appState.notifications.where((n) {
      if (_selectedCategory == "All") return true;
      if (_selectedCategory == "Reminders") return n.category == "reminder";
      if (_selectedCategory == "Weather") return n.category == "weather";
      if (_selectedCategory == "Market & Orders") return n.category == "market" || n.category == "order";
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Alerts & Notifications"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: () {
              _appState.markAllNotificationsAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications marked as read"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert),
        label: const Text("New Reminder"),
        onPressed: _openAddReminderDialog,
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Reminders", "Weather", "Market & Orders"].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.green.shade800,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          "No notifications in '$_selectedCategory'",
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          _appState.removeNotification(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("'${item.title}' removed"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: item.isRead ? Colors.white : Colors.green.shade50,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.iconColor.withValues(alpha: 0.15),
                              child: Icon(item.icon, color: item.iconColor),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.message, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.time,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() => item.isRead = true);
                              if (item.category == "weather") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                                );
                              } else if (item.category == "reminder") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CropDetailsScreen()),
                                );
                              }
                            },
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