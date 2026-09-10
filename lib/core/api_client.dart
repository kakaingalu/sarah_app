import 'package:dio/dio.dart';
import 'dart:io';
import 'constants.dart';
import 'token_store.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStore.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  static Future<Map<String, dynamic>> chat({
    required List<Map<String, String>> messages,
  }) async {
    final res = await _dio.post('/chat', data: {'messages': messages});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/signup',
      data: {'name': name, 'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    final res = await _dio.post('/google-login', data: {'id_token': idToken});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createListing({
    required String title,
    String? description,
    required double price,
    int? bedrooms,
    String? address,
    List<File> images = const [],
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'price': price,
      if (description != null) 'description': description,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (address != null) 'address': address,
      'images': [
        for (final img in images)
          await MultipartFile.fromFile(img.path, filename: img.path.split('/').last),
      ],
    };
    final formData = FormData.fromMap(formMap);
    final res = await _dio.post('/listings', data: formData);
    return res.data as Map<String, dynamic>;
  }
}
