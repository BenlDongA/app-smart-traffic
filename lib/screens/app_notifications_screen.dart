import 'package:flutter/material.dart';

class AppNotificationsScreen extends StatefulWidget {
  const AppNotificationsScreen({super.key});

  @override
  State<AppNotificationsScreen> createState() => _AppNotificationsScreenState();
}

class _AppNotificationsScreenState extends State<AppNotificationsScreen> {
  // Real-time Alerts
  bool trafficAlerts = true;
  bool accidentReports = true;
  bool speedCameraWarnings = false;

  // System Updates
  bool appAnnouncements = true;
  bool marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Notification Settings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),

                  // Real-time Alerts Section
                  const Text(
                    "REAL-TIME ALERTS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B00FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Traffic Alerts
                  _buildNotificationItem(
                    icon: Icons.traffic,
                    title: "Traffic Alerts",
                    subtitle: "Heaviness and congestion",
                    value: trafficAlerts,
                    onChanged: (value) {
                      setState(() {
                        trafficAlerts = value;
                      });
                    },
                  ),

                  // Accident Reports
                  _buildNotificationItem(
                    icon: Icons.warning,
                    title: "Accident Reports",
                    subtitle: "Major incidents nearby",
                    value: accidentReports,
                    onChanged: (value) {
                      setState(() {
                        accidentReports = value;
                      });
                    },
                  ),

                  // Speed Camera Warnings
                  _buildNotificationItem(
                    icon: Icons.photo_camera,
                    title: "Speed Camera Warnings",
                    subtitle: "Fixed and mobile units",
                    value: speedCameraWarnings,
                    onChanged: (value) {
                      setState(() {
                        speedCameraWarnings = value;
                      });
                    },
                    showBorder: false,
                  ),

                  const SizedBox(height: 24),

                  // System Updates Section
                  const Text(
                    "SYSTEM UPDATES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B00FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // App Announcements
                  _buildNotificationItem(
                    icon: Icons.campaign,
                    title: "App Announcements",
                    subtitle: "New features and updates",
                    value: appAnnouncements,
                    onChanged: (value) {
                      setState(() {
                        appAnnouncements = value;
                      });
                    },
                  ),

                  // Marketing Emails
                  _buildNotificationItem(
                    icon: Icons.mail,
                    title: "Marketing Emails",
                    subtitle: "Weekly digest and tips",
                    value: marketingEmails,
                    onChanged: (value) {
                      setState(() {
                        marketingEmails = value;
                      });
                    },
                    showBorder: false,
                  ),

                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B00FF).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF7B00FF).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xFF7B00FF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Disabling notifications may affect your ability to avoid sudden traffic jams or road hazards in real-time.",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: const Color(0xFF7B00FF).withOpacity(0.05),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7B00FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Custom Switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 51,
              height: 31,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: value ? const Color(0xFF7B00FF) : Colors.grey[300],
              ),
              padding: const EdgeInsets.all(2),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
