import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hey_smile/features/tracker/domain/reminder.dart';
import 'package:http_parser/http_parser.dart';

class TrackerService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String baseUrl = 'https://hey-smile-api.yusufacmaci.com';

  TrackerService()
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

  Future<Reminder> createReminder({
    required String title,
    required String content,
    required DateTime date,
  }) async {
    try {
      // Format date as "2025-01-28"
      final formattedDate =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final requestData = {
        'title': title,
        'content': content,
        'date': formattedDate,
      };

      log('Create Reminder Request: $requestData');

      final response = await _dio.post(
        '/api/reminders/',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      log('Create Reminder Response: ${response.data}');

      if (response.data['success'] == true) {
        return Reminder.fromJson(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Reminder oluşturulamadı.';
      }
    } on DioException catch (e) {
      log('DioException in createReminder: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      log('Error in createReminder: $e');
      rethrow;
    }
  }

  Future<List<Reminder>> getReminders() async {
    try {
      final response = await _dio.get('/api/reminders/me');
      log('Get Reminders Response: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> remindersJson = response.data['data'] as List;
        log('Reminders JSON: $remindersJson');
        return remindersJson.map((json) {
          log('Processing reminder: $json');
          return Reminder.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        throw response.data['message'] ?? 'Reminder\'lar alınamadı.';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Error in getReminders: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      log('Delete Reminder Request: $reminderId');

      final response = await _dio.delete('/api/reminders/$reminderId');

      log('Delete Reminder Response: ${response.data}');

      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'Reminder silinemedi.';
      }
    } on DioException catch (e) {
      log('DioException in deleteReminder: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      log('Error in deleteReminder: $e');
      rethrow;
    }
  }

  // Create hair checkup with images
  Future<Map<String, dynamic>> createHairCheckup({
    required String userNotes,
    required String imageFrontPath,
    required String imageBackPath,
    required String imageLeftPath,
    required String imageRightPath,
    required String imageTopPath,
  }) async {
    try {
      // FormData oluştur
      final formData = FormData.fromMap({
        // hairCheckup JSON string olarak
        'hairCheckup': MultipartFile.fromString(
          '{"userNotes":"$userNotes"}',
          contentType: MediaType('application', 'json'),
        ),
        // Image files
        'imageFront': await MultipartFile.fromFile(
          imageFrontPath,
          filename: imageFrontPath.split('/').last,
        ),
        'imageBack': await MultipartFile.fromFile(
          imageBackPath,
          filename: imageBackPath.split('/').last,
        ),
        'imageLeft': await MultipartFile.fromFile(
          imageLeftPath,
          filename: imageLeftPath.split('/').last,
        ),
        'imageRight': await MultipartFile.fromFile(
          imageRightPath,
          filename: imageRightPath.split('/').last,
        ),
        'imageTop': await MultipartFile.fromFile(
          imageTopPath,
          filename: imageTopPath.split('/').last,
        ),
      });

      log('Create Hair Checkup Request with form-data');

      final response = await _dio.post('/api/hair-checkups/', data: formData);

      log('Create Hair Checkup Response: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw response.data['message'] ?? 'Hair checkup oluşturulamadı.';
      }
    } on DioException catch (e) {
      log('DioException in createHairCheckup: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      log('Error in createHairCheckup: $e');
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
