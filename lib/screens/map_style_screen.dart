import 'package:flutter/material.dart';

class MapStyleScreen extends StatefulWidget {
  const MapStyleScreen({super.key});

  @override
  State<MapStyleScreen> createState() => _MapStyleScreenState();
}

class _MapStyleScreenState extends State<MapStyleScreen> {
  // Map style
  String selectedMapStyle = 'standard';

  // Display options
  bool show3DBuildings = true;
  double trafficIntensity = 75;
  String autoZoomSensitivity = 'Low';

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
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F8).withOpacity(0.8),
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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Style Section
                    const Text(
                      "MAP STYLE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B00FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Map style options grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMapStyleOption(
                            label: "Standard",
                            value: "standard",
                            icon: Icons.map,
                            color1: const Color(0xFFF1F5F9),
                            color2: const Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMapStyleOption(
                            label: "Satellite",
                            value: "satellite",
                            imageUrl:
                                "https://lh3.googleusercontent.com/aida-public/AB6AXuAj2_K85fQXu56qC3cp8K5J2J5sUjMwJ_aP3XRwLUoT3v2GjQCGtWAbEf-WIDcfU_VbVvkBWOHssgQ8aaDYe4_qYQFcrdwv1Cr54nv7Q3eR0a9N5Ncm-x1BTO9tRT8QvI4QfGGRcI-ufCiGMSil9wP23utjHOvMiNNww5PfPV7wfWVqiC3kphCkZrDfTru-w2mNfnqrHbdidIFnsKJX30IfTr-fWX2W160lcSO3k1oRg_lsmLqYnXNMU3snxO3l5KOw6zkUQ5ASsvUc",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMapStyleOption(
                            label: "Terrain",
                            value: "terrain",
                            imageUrl:
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRYoXLMuXkosuvlZkYDFvq16ntzHopfRHPqA&s",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Display Options
                    const Text(
                      "DISPLAY OPTIONS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B00FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3D Buildings Toggle
                    _buildToggleOption(
                      icon: Icons.apartment,
                      title: "3D Buildings",
                      subtitle: "Show detailed architectural structures",
                      value: show3DBuildings,
                      onChanged: (value) {
                        setState(() {
                          show3DBuildings = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Traffic Intensity Slider
                    _buildSliderOption(
                      icon: Icons.traffic,
                      title: "Traffic Layer Intensity",
                      subtitle: "Adjust visibility of congestion data",
                      value: trafficIntensity,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      labels: const ["Minimal", "Balanced", "High Contrast"],
                      onChanged: (value) {
                        setState(() {
                          trafficIntensity = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Auto-zoom Sensitivity
                    _buildAutoZoomOption(),

                    const SizedBox(height: 24),

                    // Live Preview
                    const Text(
                      "LIVE PREVIEW",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B00FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildLivePreview(),

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

  Widget _buildMapStyleOption({
    required String label,
    required String value,
    IconData? icon,
    String? imageUrl,
    Color? color1,
    Color? color2,
  }) {
    final isSelected = selectedMapStyle == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMapStyle = value;
        });
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF7B00FF) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            icon ?? Icons.map,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color1 ?? Colors.grey[300]!,
                            color2 ?? Colors.grey[400]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon ?? Icons.map,
                          color: const Color(0xFF7B00FF).withOpacity(0.4),
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF7B00FF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7B00FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
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

          // Custom Toggle
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: value ? const Color(0xFF7B00FF) : Colors.grey[300],
              ),
              padding: const EdgeInsets.all(2),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
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

  Widget _buildSliderOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required List<String> labels,
    required ValueChanged<double> onChanged,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7B00FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
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
            ],
          ),

          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF7B00FF),
              inactiveTrackColor: const Color(0xFF7B00FF).withOpacity(0.2),
              thumbColor: const Color(0xFF7B00FF),
              overlayColor: const Color(0xFF7B00FF).withOpacity(0.1),
              valueIndicatorColor: const Color(0xFF7B00FF),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),

          // Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((label) {
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoZoomOption() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Color(0xFF7B00FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Text(
                "Auto-zoom Sensitivity",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Options
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildZoomOption("Low", autoZoomSensitivity == "Low"),
                _buildZoomOption("Medium", autoZoomSensitivity == "Medium"),
                _buildZoomOption("High", autoZoomSensitivity == "High"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomOption(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            autoZoomSensitivity = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF7B00FF) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B00FF).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            "https://lh3.googleusercontent.com/aida-public/AB6AXuAdDdTXHUsYUqhiCvamjPx_D9vQ1ajDjalgYGIBSYtwag7nIOq7-jsv_rn8MBiV9K_Up-EFBedw1MH4SmqO47vRIEzPo5OTN7QdgHf8jwcKYRcGjqNEH3I2AHZPV5aVv9sPZj3xXoJSONBR-2JslPJl0JfSdol9hf81Ws_NzweAWPGpucHbMpKjL9wAPyqyaE2L7_7rezV5cTVv7HEHH1Jd_5kZGvnKhh4h4cHxX7THRgjL1YynOt6eGr8FwlfFr9RvBE88ENq1EyRf",
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
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
            ),
          ),

          // Live indicator
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "ACTIVE LIVE VIEW",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
