import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hey_smile/features/threatments/domain/hair_checkup.dart';

class TreatmentService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String baseUrl = 'https://hey-smile-api.yusufacmaci.com';

  TreatmentService()
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
          log('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          log('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<HairCheckup>> getHairCheckups() async {
    try {
      final response = await _dio.get('/api/hair-checkups/me');
      log('Get Hair Checkups Response: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> checkupsJson = response.data['data'] as List;
        log('Hair Checkups JSON: $checkupsJson');
        return checkupsJson.map((json) {
          log('Processing hair checkup: $json');
          return HairCheckup.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        throw response.data['message'] ?? 'Hair checkup\'lar alınamadı.';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Error in getHairCheckups: $e');
      rethrow;
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
