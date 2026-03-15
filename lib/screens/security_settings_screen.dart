import 'package:flutter/material.dart';
import '../services/device_info_service.dart';
import '../services/login_history_service.dart';
import '../models/login_activity_model.dart';
import 'change_password_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_session.dart';
import 'login_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool twoFactor = true;
  bool biometric = false;

  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final LoginHistoryService _loginHistoryService = LoginHistoryService();

  List<LoginActivity> _loginActivities = [];
  bool _isLoading = true;
  LoginActivity? _currentDevice;

  @override
  void initState() {
    super.initState();
    _loadLoginActivities();
    _recordCurrentDevice();
  }

  Future<void> _loadLoginActivities() async {
    setState(() => _isLoading = true);

    try {
      final history = await _loginHistoryService.getLoginHistory();
      setState(() {
        _loginActivities = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading login history: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordCurrentDevice() async {
    try {
      final deviceInfo = await _deviceInfoService.getCurrentDeviceInfo();
      final ipAddress = await _deviceInfoService.getIpAddress();

      String location = await _deviceInfoService.getLocationFromIP(ipAddress);

      final position = await _deviceInfoService.getCurrentLocation();
      if (position != null) {
        final city = await _deviceInfoService.getCityFromCoordinates(
            position.latitude, position.longitude);
        if (city != 'Unknown City') {
          location = city;
        }
      }

      final currentActivity = LoginActivity.current(
        deviceName: deviceInfo['deviceName'],
        deviceType: deviceInfo['deviceType'],
        location: location,
        ipAddress: ipAddress,
      );

      setState(() {
        _currentDevice = currentActivity;
      });

      await _loginHistoryService.saveLoginActivity(currentActivity);
      await _loadLoginActivities();
    } catch (e) {
      print('Error recording current device: $e');
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("https://api-app-gttm.onrender.com/api/users/me");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer ${UserSession.token}",
        },
      );

      if (response.statusCode == 200) {
        /// clear session
        UserSession.user = null;
        UserSession.token = null;

        /// về màn login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Delete failed"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f5f8),
      body: Column(
        children: [
          // Khoảng cách với status bar
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Custom Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xfff7f5f8).withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF7b00ff).withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Security Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Authentication Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AUTHENTICATION",
                        style: TextStyle(
                          color: Color(0xFF7b00ff),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Two-factor authentication card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7b00ff).withOpacity(0.1),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Two-factor authentication",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Protect your account with an extra security layer",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Custom Switch
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  twoFactor = !twoFactor;
                                });
                              },
                              child: Container(
                                width: 51,
                                height: 31,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: twoFactor
                                      ? const Color(0xFF7b00ff)
                                      : Colors.grey[300],
                                ),
                                padding: const EdgeInsets.all(2),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: twoFactor
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
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
                      ),

                      const SizedBox(height: 12),

                      // Biometric Login card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7b00ff).withOpacity(0.1),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Biometric Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Use FaceID or Fingerprint to unlock app",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Custom Switch
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  biometric = !biometric;
                                });
                              },
                              child: Container(
                                width: 51,
                                height: 31,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: biometric
                                      ? const Color(0xFF7b00ff)
                                      : Colors.grey[300],
                                ),
                                padding: const EdgeInsets.all(2),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: biometric
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
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
                      ),
                    ],
                  ),
                ),

                // Login Activity Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "LOGIN ACTIVITY",
                            style: TextStyle(
                              color: Color(0xFF7b00ff),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: _loginActivities.length > 2
                                ? () {
                                    // Navigate to full login history screen
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF7b00ff),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                            ),
                            child: const Text(
                              "See all",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Color(0xFF7b00ff),
                            ),
                          ),
                        )
                      else if (_loginActivities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7b00ff).withOpacity(0.1),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "No login history yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _loginActivities.take(2).map((activity) {
                            return _buildLoginActivityItem(activity);
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Device Management
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DEVICE MANAGEMENT",
                        style: TextStyle(
                          color: Color(0xFF7b00ff),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7b00ff).withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color(0xFF7b00ff)
                                          .withOpacity(0.05),
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.devices,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Recognized Devices",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Log out of all devices",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Account Security Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Change Password
                      // Change Password
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF7b00ff).withOpacity(0.1),
                          foregroundColor: const Color(0xFF7b00ff),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.password, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Delete Account
                      OutlinedButton(
                        onPressed: _deleteAccount,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 0.5),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Delete Account",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Disclaimer text
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Deleting your account will permanently remove all your traffic reports and preferences. This action cannot be undone.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginActivityItem(LoginActivity activity) {
    IconData iconData;

    // Phân loại icon dựa trên device type
    switch (activity.deviceType) {
      case 'smartphone':
        iconData = Icons.smartphone;
        break;
      case 'tablet':
        iconData = Icons.tablet;
        break;
      case 'laptop':
        iconData = Icons.laptop;
        break;
      default:
        iconData = Icons.computer;
    }

    // Nếu là thiết bị hiện tại và đang chạy trên điện thoại
    if (activity.isCurrentDevice) {
      if (activity.deviceType == 'smartphone') {
        iconData = Icons.smartphone;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7b00ff).withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7b00ff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: const Color(0xFF7b00ff),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.deviceName.length > 30
                      ? '${activity.deviceName.substring(0, 27)}...'
                      : activity.deviceName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${activity.location} • ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (activity.isActive)
                      const Text(
                        'Active now',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7b00ff),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        _getTimeAgo(activity.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                if (activity.isCurrentDevice)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '• This device',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
