import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F8).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF7B00FF).withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                            color: Color(0xFF7B00FF),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Traffic Alerts",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Search button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 22,
                        ),
                      ),
                    ],
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
                    color: const Color(0xFF7B00FF).withOpacity(0.05),
                  ),
                ),
              ),
              child: const Row(
                children: [
                  _TabButton(
                    label: "Critical",
                    isSelected: true,
                  ),
                  _TabButton(
                    label: "Warning",
                    isSelected: false,
                  ),
                  _TabButton(
                    label: "Info",
                    isSelected: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Alert List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Critical Alert
                  _buildAlertCard(
                    icon: Icons.warning,
                    iconColor: Colors.red,
                    iconBackgroundColor: Colors.red.withOpacity(0.1),
                    title: "Major Accident - I-95 North",
                    badge: const _AlertBadge(
                      label: "Critical",
                      color: Colors.red,
                    ),
                    message:
                        "3-lane closure, expect heavy delays. Emergency vehicles on site.",
                    time: "2m ago",
                    distance: "0.5 miles away",
                    showShareButton: true,
                  ),

                  const SizedBox(height: 12),

                  // Warning Alert
                  _buildAlertCard(
                    icon: Icons.construction,
                    iconColor: Colors.orange,
                    iconBackgroundColor: Colors.orange.withOpacity(0.1),
                    title: "Road Construction",
                    message:
                        "Right lane closed for maintenance. Speed limit reduced to 45mph.",
                    time: "15m ago",
                    distance: "1.2 miles away",
                  ),

                  const SizedBox(height: 12),

                  // Info Alert
                  _buildAlertCard(
                    icon: Icons.traffic,
                    iconColor: Colors.blue,
                    iconBackgroundColor: Colors.blue.withOpacity(0.1),
                    title: "Heavy Traffic Congestion",
                    message:
                        "Typical peak hour buildup. Expect 10-15 min additional travel time.",
                    time: "8m ago",
                    distance: "2.8 miles away",
                  ),

                  const SizedBox(height: 12),

                  // Weather Advisory
                  _buildAlertCard(
                    icon: Icons.info,
                    iconColor: const Color(0xFF7B00FF),
                    iconBackgroundColor:
                        const Color(0xFF7B00FF).withOpacity(0.1),
                    title: "Weather Advisory",
                    message:
                        "Light rain reported in your area. Road surfaces may be slippery.",
                    time: "1h ago",
                    distance: "Local Area",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String message,
    required String time,
    required String distance,
    Widget? badge,
    bool showShareButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (badge != null) badge,
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: View on Map
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: showShareButton
                          ? const Color(0xFF7B00FF)
                          : const Color(0xFFF7F5F8),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: showShareButton
                          ? [
                              BoxShadow(
                                color: const Color(0xFF7B00FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "View on Map",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: showShareButton
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showShareButton) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Share
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Color(0xFF7B00FF),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
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
    return Expanded(
      child: Container(
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF7B00FF) : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AlertBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
