import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F8),
          border: Border(
            left: BorderSide(color: const Color(0xFF7B00FF).withOpacity(0.1)),
            right: BorderSide(color: const Color(0xFF7B00FF).withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Back button
                      const SizedBox(width: 8),
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Clear All button
                  GestureDetector(
                    onTap: () {
                      // TODO: Clear all notifications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All notifications cleared"),
                          backgroundColor: Color(0xFF7B00FF),
                        ),
                      );
                    },
                    child: const Text(
                      "Clear All",
                      style: TextStyle(
                        color: Color(0xFF7B00FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF7B00FF).withOpacity(0.1),
                  ),
                ),
              ),
              child: const Row(
                children: [
                  _TabButton(
                    label: "All",
                    isSelected: true,
                  ),
                  SizedBox(width: 32),
                  _TabButton(
                    label: "Unread",
                    isSelected: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Notification List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Today Section
                  _buildSectionHeader("Today"),

                  // Heavy Traffic Alert
                  _buildNotificationItem(
                    icon: Icons.warning,
                    iconColor: Colors.amber,
                    iconBackgroundColor: Colors.amber.withOpacity(0.1),
                    title: "Heavy Traffic Alert",
                    time: "10:24 AM",
                    message:
                        "Expect 20 min delay on I-95 South due to an accident ahead. Consider alternative route.",
                  ),

                  // New Message from Dispatch
                  _buildNotificationItem(
                    icon: Icons.chat_bubble,
                    iconColor: Colors.blue,
                    iconBackgroundColor: Colors.blue.withOpacity(0.1),
                    title: "New Message from Dispatch",
                    time: "09:15 AM",
                    message:
                        "\"Report of debris on the third lane of Lincoln Tunnel approach. Proceed with caution.\"",
                  ),

                  // Route Optimization
                  _buildNotificationItem(
                    icon: Icons.traffic,
                    iconColor: Colors.green,
                    iconBackgroundColor: Colors.green.withOpacity(0.1),
                    title: "Route Optimization",
                    time: "08:05 AM",
                    message:
                        "A faster route to 'Home' is available. You can save 8 minutes by switching now.",
                  ),

                  // Yesterday Section
                  _buildSectionHeader("Yesterday"),

                  // System Update
                  _buildNotificationItem(
                    icon: Icons.notifications,
                    iconColor: const Color(0xFF7B00FF),
                    iconBackgroundColor:
                        const Color(0xFF7B00FF).withOpacity(0.1),
                    title: "System Update",
                    time: "6:30 PM",
                    message:
                        "Map data for your region has been updated. New speed limit zones included.",
                    isOlder: true,
                  ),

                  // Route Optimization (Yesterday)
                  _buildNotificationItem(
                    icon: Icons.traffic,
                    iconColor: Colors.green,
                    iconBackgroundColor: Colors.green.withOpacity(0.1),
                    title: "Route Optimization",
                    time: "4:12 PM",
                    message:
                        "Traffic cleared up on your commute path. Estimated time to destination: 15 mins.",
                    isOlder: true,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String time,
    required String message,
    bool isOlder = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF7B00FF).withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOlder ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOlder ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isOlder ? Colors.grey[500] : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabButton({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? const Color(0xFF7B00FF) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? const Color(0xFF7B00FF) : Colors.grey,
        ),
      ),
    );
  }
}
