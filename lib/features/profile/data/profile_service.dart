import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ProfileService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _healthDataKey = 'health_questionnaire_data';

  // Save health questionnaire data
  Future<void> saveHealthData(Map<String, String> healthData) async {
    try {
      final jsonString = jsonEncode(healthData);
      await _storage.write(key: _healthDataKey, value: jsonString);
    } catch (e) {
      throw Exception('Failed to save health data: $e');
    }
  }

  // Load health questionnaire data
  Future<Map<String, String?>> loadHealthData() async {
    try {
      final jsonString = await _storage.read(key: _healthDataKey);
      if (jsonString == null) {
        return {
          'medicalConditions': null,
          'allergies': null,
          'pastSurgeries': null,
          'currentMedications': null,
        };
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      return {
        'medicalConditions': data['medicalConditions']?.toString(),
        'allergies': data['allergies']?.toString(),
        'pastSurgeries': data['pastSurgeries']?.toString(),
        'currentMedications': data['currentMedications']?.toString(),
      };
    } catch (e) {
      throw Exception('Failed to load health data: $e');
    }
  }

  // Clear health questionnaire data
  Future<void> clearHealthData() async {
    try {
      await _storage.delete(key: _healthDataKey);
    } catch (e) {
      throw Exception('Failed to clear health data: $e');
    }
  }
}
