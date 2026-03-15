// models/login_activity_model.dart
class LoginActivity {
  final String deviceName;
  final String deviceType; // smartphone, laptop, etc.
  final String location;
  final DateTime timestamp;
  final bool isActive;
  final bool isCurrentDevice;
  final String ipAddress;

  LoginActivity({
    required this.deviceName,
    required this.deviceType,
    required this.location,
    required this.timestamp,
    required this.isActive,
    required this.isCurrentDevice,
    required this.ipAddress,
  });

  // Tạo bản sao với thời gian mới cho thiết bị hiện tại
  LoginActivity.current({
    required this.deviceName,
    required this.deviceType,
    required this.location,
    required this.ipAddress,
  })  : timestamp = DateTime.now(),
        isActive = true,
        isCurrentDevice = true;

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'deviceType': deviceType,
        'location': location,
        'timestamp': timestamp.toIso8601String(),
        'isActive': isActive,
        'isCurrentDevice': isCurrentDevice,
        'ipAddress': ipAddress,
      };

  factory LoginActivity.fromJson(Map<String, dynamic> json) => LoginActivity(
        deviceName: json['deviceName'],
        deviceType: json['deviceType'],
        location: json['location'],
        timestamp: DateTime.parse(json['timestamp']),
        isActive: json['isActive'],
        isCurrentDevice: json['isCurrentDevice'],
        ipAddress: json['ipAddress'],
      );
}
