import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Service xử lý URL schemes và deep links cho payment callbacks
class UrlHandlerService {
  // Custom URL scheme cho app
  static const String _appScheme = 'quizuplearn';
  
  /// Tạo callback URL cho payment success
  static String createPaymentSuccessUrl({
    required String planId,
    String? orderCode,
  }) {
    final params = <String, String>{
      'planId': planId,
    };
    
    if (orderCode != null) {
      params['orderCode'] = orderCode;
    }
    
    return _buildUrl(
      path: '/payment/success',
      params: params,
    );
  }
  
  /// Tạo callback URL cho payment cancel
  static String createPaymentCancelUrl({
    required String planId,
    String? reason,
  }) {
    final params = <String, String>{
      'planId': planId,
    };
    
    if (reason != null) {
      params['reason'] = reason;
    }
    
    return _buildUrl(
      path: '/payment/cancel',
      params: params,
    );
  }
  
  /// Tạo callback URL cho payment failure
  static String createPaymentFailureUrl({
    required String planId,
    String? error,
  }) {
    final params = <String, String>{
      'planId': planId,
    };
    
    if (error != null) {
      params['error'] = error;
    }
    
    return _buildUrl(
      path: '/payment/failure',
      params: params,
    );
  }
  
  /// Build URL với scheme và parameters
  static String _buildUrl({
    required String path,
    Map<String, String>? params,
  }) {
    // Đảm bảo path không bắt đầu bằng / để có đúng 2 dấu // trong scheme
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // Tạo URL string trực tiếp để đảm bảo format: quizuplearn://path
    var url = '$_appScheme://$cleanPath';
    
    // Thêm query parameters nếu có
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
    }
    
    log("Build URL: $url");
    return url;
  }
  
  /// Parse URL để lấy thông tin
  static Map<String, String>? parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      if (uri.scheme != _appScheme) {
        return null;
      }
      
      final result = <String, String>{};
      
      // Add path segments
      if (uri.pathSegments.isNotEmpty) {
        result['path'] = uri.path;
        result['segments'] = uri.pathSegments.join('/');
      }
      
      // Add query parameters
      result.addAll(uri.queryParameters);
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing URL: $e');
      }
      return null;
    }
  }
  
  /// Kiểm tra URL có phải là app URL không
  static bool isAppUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == _appScheme;
    } catch (e) {
      return false;
    }
  }
  
  /// Lấy plan ID từ URL
  static String? getPlanIdFromUrl(String url) {
    final parsed = parseUrl(url);
    return parsed?['planId'];
  }
  
  /// Lấy order code từ URL
  static String? getOrderCodeFromUrl(String url) {
    final parsed = parseUrl(url);
    return parsed?['orderCode'];
  }
  
  /// Lấy path từ URL
  static String? getPathFromUrl(String url) {
    final parsed = parseUrl(url);
    return parsed?['path'];
  }
}

