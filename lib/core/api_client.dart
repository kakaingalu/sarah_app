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

  static Future<Map<String, dynamic>> updateListing({
    required int listingId,
    String? title,
    String? description,
    double? price,
    int? bedrooms,
    String? address,
    List<File> images = const [],
  }) async {
    final formMap = <String, dynamic>{
      if (title != null) 'title': title,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (address != null) 'address': address,
      if (images.isNotEmpty)
        'images': [
          for (final img in images)
            await MultipartFile.fromFile(img.path, filename: img.path.split('/').last),
        ],
    };
    final formData = FormData.fromMap(formMap);
    final res = await _dio.put('/listings/$listingId', data: formData);
    return res.data as Map<String, dynamic>;
  }


  static Future<Map<String, dynamic>> initiatePayment(int listingId) async {
    try {
      final response = await _dio.post(
        '/payments/initiate',
        data: {'listing_id': listingId},
        options: Options(headers: {'Authorization': 'Bearer ${await TokenStore.read()}'}),
      );
      return {
        'redirect_url': response.data['redirect_url'] ?? '',
        'order_tracking_id': response.data['order_tracking_id'] ?? '',
      };
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(String orderTrackingId) async {
    try {
      final response = await _dio.post(
        '/payments/verify/$orderTrackingId',
        options: Options(headers: {'Authorization': 'Bearer ${await TokenStore.read()}'}),
      );
      return {
        'status': response.data['status'] ?? 'PENDING',
        'contact_info': response.data['contact_info'],
      };
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  static Future<Map<String, dynamic>> checkContactUnlocked(int listingId) async {
    try {
      final response = await _dio.get(
        '/payments/listing/$listingId/unlocked',
        options: Options(headers: {'Authorization': 'Bearer ${await TokenStore.read()}'}),
      );
      return {
        'owner_name': response.data['owner_name'] ?? 'Unknown',
        'owner_email': response.data['owner_email'] ?? '',
        'listing_id': response.data['listing_id'] ?? listingId,
        'is_unlocked': response.data['is_unlocked'] ?? false,
      };
    } catch (e) {
      throw Exception('Failed to check contact: $e');
    }
  }
}
