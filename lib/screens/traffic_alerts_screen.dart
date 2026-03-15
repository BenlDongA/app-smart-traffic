import 'package:flutter/material.dart';

class TrafficAlertsScreen extends StatefulWidget {
  const TrafficAlertsScreen({super.key});

  @override
  State<TrafficAlertsScreen> createState() => _TrafficAlertsScreenState();
}

class _TrafficAlertsScreenState extends State<TrafficAlertsScreen> {
  // Notification preferences
  bool accidents = true;
  bool congestion = true;
  bool roadConstruction = false;
  bool speedCameras = true;

  // Audio settings
  double alertVolume = 80;

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
            // Header - ĐÃ SỬA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F8),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF7B00FF).withOpacity(0.1),
                  ),
                ),
              ),
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
                  const SizedBox(width: 12),
                  const Text(
                    "Traffic Alerts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Preferences
                    const Text(
                      "NOTIFICATION PREFERENCES",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accidents Toggle
                    _buildToggleItem(
                      icon: Icons.warning,
                      title: "Accidents",
                      subtitle:
                          "Major and minor accidents on your current route.",
                      value: accidents,
                      onChanged: (value) {
                        setState(() {
                          accidents = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Congestion Toggle
                    _buildToggleItem(
                      icon: Icons.traffic,
                      title: "Congestion",
                      subtitle:
                          "Real-time updates on heavy traffic and bottlenecks.",
                      value: congestion,
                      onChanged: (value) {
                        setState(() {
                          congestion = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Road Construction Toggle
                    _buildToggleItem(
                      icon: Icons.construction,
                      title: "Road Construction",
                      subtitle:
                          "Information about roadworks and lane closures.",
                      value: roadConstruction,
                      onChanged: (value) {
                        setState(() {
                          roadConstruction = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Speed Cameras Toggle
                    _buildToggleItem(
                      icon: Icons.photo_camera,
                      title: "Speed Cameras",
                      subtitle:
                          "Get alerted when approaching speed enforcement units.",
                      value: speedCameras,
                      onChanged: (value) {
                        setState(() {
                          speedCameras = value;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Audio Settings
                    const Text(
                      "AUDIO SETTINGS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildVolumeSlider(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7B00FF).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7B00FF),
              size: 24,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildVolumeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7B00FF).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.volume_up,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Alert Volume",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                "${alertVolume.round()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B00FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF7B00FF),
              inactiveTrackColor: const Color(0xFF7B00FF).withOpacity(0.2),
              thumbColor: const Color(0xFF7B00FF),
              overlayColor: const Color(0xFF7B00FF).withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: alertVolume,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  alertVolume = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
