// lib/services/device_info_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert'; // THÊM DÒNG NÀY

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<Map<String, dynamic>> getCurrentDeviceInfo() async {
    String deviceName = '';
    String deviceType = 'smartphone';
    String osVersion = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      deviceType = _getDeviceType(androidInfo.model);
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      deviceName = '${iosInfo.utsname.machine}';
      deviceType = _getDeviceType(iosInfo.utsname.machine);
      osVersion = 'iOS ${iosInfo.systemVersion}';
    }

    return {
      'deviceName': deviceName,
      'deviceType': deviceType,
      'osVersion': osVersion,
    };
  }

  String _getDeviceType(String model) {
    model = model.toLowerCase();
    if (model.contains('iphone') ||
        model.contains('android') && !model.contains('tab')) {
      return 'smartphone';
    } else if (model.contains('ipad') || model.contains('tab')) {
      return 'tablet';
    } else if (model.contains('macbook') || model.contains('laptop')) {
      return 'laptop';
    } else {
      return 'computer';
    }
  }

  Future<String> getIpAddress() async {
    try {
      String? ip = await _networkInfo.getWifiIP();
      if (ip != null && ip.isNotEmpty) {
        return ip;
      }
    } catch (e) {
      print('Error getting local IP: $e');
    }

    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org')).timeout(
                const Duration(seconds: 5),
              );
      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      print('Error getting public IP: $e');
    }

    return 'Unknown IP';
  }

  Future<String> getLocationFromIP(String ip) async {
    if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
      return 'Local Network';
    }

    try {
      final response = await http
          .get(
            Uri.parse('http://ipapi.co/$ip/json/'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Bây giờ đã có jsonDecode
        if (data['city'] != null && data['country_name'] != null) {
          return '${data['city']}, ${data['country_name']}';
        }
      }
    } catch (e) {
      print('Error getting location from IP: $e');
    }

    return 'Unknown Location';
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getCityFromCoordinates(
      double latitude, double longitude) async {
    return 'Unknown City';
  }
}
