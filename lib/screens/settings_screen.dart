import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_session.dart';
import 'login_screen.dart';
import 'profile_settings_screen.dart';
import 'security_settings_screen.dart';
import 'traffic_alerts_screen.dart'; // Thêm import
import 'app_notifications_screen.dart'; // Thêm import
import 'map_style_screen.dart'; // Thêm import
import 'traffic_overlay_screen.dart'; // Thêm import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = UserSession.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// PROFILE CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: Row(
              children: [
                /// AVATAR
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300",
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(width: 16),

                /// USER INFO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?["name"] ?? "Unknown User",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?["email"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?["sdt"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    const Chip(
                      label: Text(
                        "SMARTTRAFFIC USER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Color(0xFF8B5CF6),
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ACCOUNT SECTION
          const Text(
            "ACCOUNT",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF8B5CF6)),
                  title: Text("Profile"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSettingsScreen(),
                      ),
                    );

                    setState(() {}); // refresh lại user
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security, color: Color(0xFF8B5CF6)),
                  title: Text("Security"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecuritySettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// NOTIFICATIONS
          const Text(
            "NOTIFICATIONS",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.traffic, color: Color(0xFF8B5CF6)),
                  title: Text("Traffic Alerts"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrafficAlertsScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active,
                      color: Color(0xFF8B5CF6)),
                  title: Text("App Notifications"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppNotificationsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// MAP PREFERENCES
          const Text(
            "MAP PREFERENCES",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.map, color: Color(0xFF8B5CF6)),
                  title: Text("Map Style"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MapStyleScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.layers, color: Color(0xFF8B5CF6)),
                  title: Text("Traffic Overlay"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrafficOverlayScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// SIGN OUT
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () async {
              /// xóa user trong RAM
              UserSession.user = null;

              /// xóa trạng thái login đã lưu
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              /// quay về login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
