import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

class DioIntercepTorCustom extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Thêm Authorization header nếu có token
    final authHeader = await BaseCommon.instance.getAuthorizationHeader();
    if (authHeader != null) {
      options.headers["Authorization"] = authHeader;
    }
    
    final fullUrl = options.uri.toString();
    log('➡️ [API - ${DateTime.now()}][REQUEST] ${options.method} $fullUrl');
    log('➡️ [API - ${DateTime.now()}][REQUEST][DATA] ${jsonEncode(options.data)}');

     
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
 
    log('✅ [API][RESPONSE] ${response.realUri} ${response.statusCode} ${jsonEncode(response.data)} ');
    if (response.data is Map<String, dynamic> &&
        !response.data.containsKey('data')) {
          log("onResponse");
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['message'] ?? response.data['title'] ?? "Unknown error",
        ),
      );
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("onError ${err.response?.data}");
    String errorMessage = "No connection";

    if (err.response != null) {
      switch (err.response?.statusCode) {
        case 400:
          errorMessage = "Bad Request";
          break;
        case 401:
          errorMessage = "Unauthorized - Please login again";
          break;
        case 403:
          errorMessage = "Forbidden - You don't have permission";
          break;
        case 404:
          errorMessage = "Not Found";
          break;
        case 500:
          errorMessage = "Internal Server Error";
          break;
        default:
          errorMessage = err.response?.data['message'] ?? "API Error";
      }
    } else if (err.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Connection timeout";
    } else if (err.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Response timeout";
    } else if (err.type == DioExceptionType.badCertificate) {
      errorMessage = "Bad SSL Certificate";
    } else if (err.type == DioExceptionType.cancel) {
      errorMessage = "Request cancelled";
    }

    handler.reject(
      DioException(requestOptions: err.requestOptions, error: errorMessage),
    );
  }
}
