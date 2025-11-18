import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String baseUrl = 'https://hey-smile-api.yusufacmaci.com';

  AuthService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Token'ı secure storage'dan al ve ekle
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
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
    try {
      // User bilgilerini JSON olarak hazırla
      final userJson = {
        "firstName": firstName,
        "lastName": lastName,
        "dateOfBirth": dateOfBirth,
        "email": email,
        "phoneNumber": phoneNumber,
        "password": password,
      };

      // FormData oluştur - user kısmını JSON string olarak gönder
      final formData = FormData.fromMap({
        'user': MultipartFile.fromString(
          json.encode(userJson),
          contentType: MediaType('application', 'json'),
        ),
      });

      // Profil fotoğrafı varsa ekle
      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'profilePhoto',
            await MultipartFile.fromFile(
              profilePhotoPath,
              filename: profilePhotoPath.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post('/api/auth/register', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Token'ı secure storage'dan sil
      await _secureStorage.delete(key: 'auth_token');

      // Login durumunu SharedPreferences'tan sil
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);

      // Opsiyonel: API'ye logout isteği gönder
      // await _dio.post('/api/auth/logout');
    } catch (e) {
      throw 'Çıkış yapılırken bir hata oluştu.';
    }
  }

  // Token'ı kaydet
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Token'ı al
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Token'ı kontrol et
  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/users/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put('/auth/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Forgot password
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'token': token, 'password': newPassword},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Hata yönetimi
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'];
        if (statusCode == 401) {
          return message ?? 'Kimlik doğrulama hatası.';
        } else if (statusCode == 404) {
          return message ?? 'İstenen kaynak bulunamadı.';
        } else if (statusCode == 500) {
          return message ?? 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
        }
        return message ?? 'Bir hata oluştu. Lütfen tekrar deneyin.';
      case DioExceptionType.cancel:
        return 'İstek iptal edildi.';
      case DioExceptionType.connectionError:
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }
}
