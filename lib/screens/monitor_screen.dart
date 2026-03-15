import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'alert_screen.dart'; // Thêm import này

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cameras = [
      {
        "id": "sJvEFrG0wq0",
        "title": "Quang Trung - Đà Nẵng",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdBoTr_Sdn6MeagnyrXmeqglDYMA6-nrlCzg&s"
      },
      {
        "id": "G_G8A6JU_LI",
        "title": "Hải Phòng - Đà Nẵng",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNjMHe1ZAhZCHtRe8Vqr89t8ZuU7G6mvHyOA&s"
      },
      {
        "id": "cyRo5UgQU0A",
        "title": "Lê Văn Lương - Hà Nội",
        "image":
            "https://hoanghamobile.com/tin-tuc/wp-content/uploads/2024/04/anh-ha-noi.jpg"
      },
      {
        "id": "8JCk5M_xrBs",
        "title": "Walworth Road -London",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0Waity-g2jHb1xt_ljrEYshujmouHrI9F0Q&s"
      },
      {
        "id": "6dp-bvQ7RWo",
        "title": "Tokyo Shinjuku - Japan",
        "image":
            "https://t4.ftcdn.net/jpg/02/51/12/11/360_F_251121174_5xQyUCqSrkswyLHbM9Ne8DQ8Qb0o1HGw.jpg"
      },
      {
        "id": "DjdUEyjx8GM",
        "title": "Shinjuku Kabukicho - Japan",
        "image":
            "https://media.istockphoto.com/id/615236798/photo/tokyo-tower-night-view-of-tokyo-metropolitan-city.jpg?s=612x612&w=0&k=20&c=evXG6kRJ34pwbpJpV0qkW5CnwmEf_-4V6Ec_HdXner8="
      },
      {
        "id": "fUsJZTHeZn4",
        "title": "St. Petersburg - Russia",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_aLTnGtoVoBGLyoPlx7nEpmkwvOtzpTigBg&s"
      },
      {
        "id": "u7GyFcQJs98",
        "title": "Southampton - UK",
        "image":
            "https://www.centreforcities.org/wp-content/uploads/2021/08/Southampton-tile.png"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER - Thêm Traffic Alerts icon
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
                  // Icon and title
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.videocam,
                      color: Color(0xFF7B00FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Traffic Monitor",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  // Traffic Alerts Button - THÊM MỚI
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlertScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                        ),
                        // Badge thông báo
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
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
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Refresh button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B00FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B00FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // TABS - All Cameras, Favorites, Nearby
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  _TabButton(
                    label: "All Cameras",
                    isSelected: true,
                  ),
                  SizedBox(width: 24),
                  _TabButton(
                    label: "Favorites",
                    isSelected: false,
                  ),
                  SizedBox(width: 24),
                  _TabButton(
                    label: "Nearby",
                    isSelected: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // GRID CAMERAS
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: cameras.length,
                itemBuilder: (context, index) {
                  return CameraCard(
                    videoId: cameras[index]["id"]!,
                    title: cameras[index]["title"]!,
                    imageUrl: cameras[index]["image"]!,
                  );
                },
              ),
            ),
          ],
        ),
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
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF7B00FF) : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class CameraCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String imageUrl;

  const CameraCard({
    super.key,
    required this.videoId,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenVideo(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // LIVE badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 6,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title and location at bottom
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenVideo(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          "https://www.youtube.com/embed/$videoId?autoplay=1&mute=1&controls=1",
        ),
      );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
