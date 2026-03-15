import 'package:flutter/material.dart';

class TrafficOverlayScreen extends StatefulWidget {
  const TrafficOverlayScreen({super.key});

  @override
  State<TrafficOverlayScreen> createState() => _TrafficOverlayScreenState();
}

class _TrafficOverlayScreenState extends State<TrafficOverlayScreen> {
  // Map Layers
  bool trafficDensity = true;
  bool trafficIncidents = true;
  bool publicTransport = false;
  bool parkingAvailability = false;

  // Overlay Opacity
  double overlayOpacity = 75;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    "Traffic Overlay",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Live Preview Image - Đã bỏ const
                    _buildLivePreview(),

                    const SizedBox(height: 24),

                    // Map Layers Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "MAP LAYERS",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B00FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildLayerCard(
                      children: [
                        _buildLayerItem(
                          icon: Icons.traffic,
                          title: "Traffic Density",
                          value: trafficDensity,
                          onChanged: (value) {
                            setState(() {
                              trafficDensity = value;
                            });
                          },
                          showBorder: true,
                        ),
                        _buildLayerItem(
                          icon: Icons.warning,
                          title: "Traffic Incidents",
                          value: trafficIncidents,
                          onChanged: (value) {
                            setState(() {
                              trafficIncidents = value;
                            });
                          },
                          showBorder: true,
                        ),
                        _buildLayerItem(
                          icon: Icons.directions_bus,
                          title: "Public Transport",
                          value: publicTransport,
                          onChanged: (value) {
                            setState(() {
                              publicTransport = value;
                            });
                          },
                          showBorder: true,
                        ),
                        _buildLayerItem(
                          icon: Icons.local_parking,
                          title: "Parking Availability",
                          value: parkingAvailability,
                          onChanged: (value) {
                            setState(() {
                              parkingAvailability = value;
                            });
                          },
                          showBorder: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Overlay Opacity Section
                    _buildOpacitySection(),

                    const SizedBox(height: 16),

                    // Info Text
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Adjusting these settings will update your map view in real-time. Traffic data is updated every 2 minutes for maximum accuracy.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),

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

  Widget _buildLivePreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCfEM6HvZq75m4JvdtLtaVFCPKM9U1OE_rknsKftIjfEtE3DqSOaw5-VhWtwKn__QheLr38fM08avza5LpP0p-cnjbKLKHYlo5pygeEUVQsND4Ej8nCZ0RNwgUGLyT08zwdXVZ5wnywPnH0CoFopvYMgpq7vdTwZUjjc-sieziIKsqfA28Ux444vr358CTidrFaQsYHnG29cGdOzUoIDZk4pQOz_lY6fuPjgdEbJ71USvEN-7uxHGREvxtMLCPym4jwuUtjm7rQsPY",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Live Preview badge
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF7B00FF),
                borderRadius:
                    BorderRadius.all(Radius.circular(999)), // Sửa ở đây
              ),
              child: const Text(
                "LIVE PREVIEW",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerCard({required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildLayerItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showBorder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: const Color(0xFF7B00FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildOpacitySection() {
    return Column(
      children: [
        // Title and percentage
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "OVERLAY OPACITY",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B00FF),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${overlayOpacity.round()}%",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B00FF),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Slider Card
        Container(
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
              // Custom Slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFF7B00FF),
                  inactiveTrackColor: const Color(0xFF7B00FF).withOpacity(0.2),
                  thumbColor: const Color(0xFF7B00FF),
                  overlayColor: const Color(0xFF7B00FF).withOpacity(0.1),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: overlayOpacity,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      overlayOpacity = value;
                    });
                  },
                ),
              ),

              // Labels
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TRANSPARENT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "OPAQUE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
