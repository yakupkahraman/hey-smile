import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hey_smile/features/auth/data/auth_service.dart';
import 'package:hey_smile/features/auth/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // User bilgilerini SharedPreferences'a kaydet
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  // User bilgilerini SharedPreferences'tan yükle
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user from prefs: $e');
      }
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      // Token'ı kaydet
      if (result['data'] != null && result['data']['token'] != null) {
        await _authService.saveToken(result['data']['token']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
      }

      // User profilini al ve kaydet
      await fetchUserProfile();

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String email,
    required String phoneNumber,
    required String password,
    String? profilePhotoPath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        profilePhotoPath: profilePhotoPath,
      );

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // User profilini API'den al
  Future<void> fetchUserProfile() async {
    try {
      final response = await _authService.getUserProfile();

      debugPrint('User profile response: $response');

      if (response['data'] != null) {
        _currentUser = User.fromJson(response['data']);
        await _saveUserToPrefs(_currentUser!);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching user profile: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();

      // User bilgilerini temizle
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // User bilgilerini güncelle
  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserToPrefs(updatedUser);
    notifyListeners();
  }
}
