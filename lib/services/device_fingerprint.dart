import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceFingerprintService {
  static final DeviceFingerprintService _instance = DeviceFingerprintService._internal();
  factory DeviceFingerprintService() => _instance;
  DeviceFingerprintService._internal();

  String? _cachedFingerprint;

  /// Generate a unique device fingerprint
  Future<String> generateFingerprint() async {
    if (_cachedFingerprint != null) {
      return _cachedFingerprint!;
    }

    final deviceInfo = DeviceInfoPlugin();
    String platformId = '';
    String deviceName = '';
    
    try {
      // Get platform-specific device ID
      platformId = await PlatformDeviceId.getDeviceId ?? 'unknown';
      
      // Get additional device info
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
        
        // Combine: Platform ID + Computer Name + Number of Cores
        final fingerprintData = '$platformId-${windowsInfo.computerName}-${windowsInfo.numberOfCores}';
        _cachedFingerprint = _hashString(fingerprintData);
        
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceName = macInfo.computerName;
        
        final fingerprintData = '$platformId-${macInfo.computerName}-${macInfo.model}';
        _cachedFingerprint = _hashString(fingerprintData);
        
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceName = linuxInfo.name;
        
        final fingerprintData = '$platformId-${linuxInfo.machineId}';
        _cachedFingerprint = _hashString(fingerprintData);
      }
    } catch (e) {
      print('Error generating fingerprint: $e');
      _cachedFingerprint = _hashString(platformId);
    }

    return _cachedFingerprint!;
  }

  /// Get device name
  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name;
      }
    } catch (e) {
      print('Error getting device name: $e');
    }
    
    return 'Unknown Device';
  }

  /// Hash a string using SHA256
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear cached fingerprint (useful for testing)
  void clearCache() {
    _cachedFingerprint = null;
  }
}
