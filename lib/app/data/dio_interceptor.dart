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
      // Ưu tiên lấy message, nếu không có thì lấy error, sau đó mới lấy title
      final errorMessage = response.data['message'];
      log("errorMessage ${errorMessage}");
      final errorText = errorMessage != null && errorMessage.isNotEmpty
          ? errorMessage
          : (response.data['error']?.toString() ?? 
             response.data['title']?.toString() ?? 
             "Unknown error");
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: errorText,
        ),
      );
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("onError hi ${err.response?.data} ${err.requestOptions.path}");
    String errorMessage = "No connection";

    if (err.response != null) {
      final errorData = err.response?.data;
      
      // Ưu tiên lấy message từ response, nếu không có thì lấy error
      String? apiErrorMessage;
      if (errorData is Map) {
        // Lấy message và convert sang String
        final messageValue = errorData['message'];
        if (messageValue != null) {
          apiErrorMessage = messageValue.toString();
          // Nếu message là "null" string hoặc rỗng, thì coi như null
          if (apiErrorMessage == 'null' || apiErrorMessage.isEmpty) {
            apiErrorMessage = null;
          }
        }
        
        // Nếu không có message hoặc message rỗng, lấy error
        if (apiErrorMessage == null || apiErrorMessage.isEmpty) {
          final errorValue = errorData['error'];
          if (errorValue != null) {
            apiErrorMessage = errorValue.toString();
          }
        }
        
        log("apiErrorMessage after processing: ${apiErrorMessage}");
      }
      
      switch (err.response?.statusCode) {
        case 400:
          errorMessage = apiErrorMessage ?? "Bad Request";
          break;
        case 401:
          errorMessage = apiErrorMessage ?? "Unauthorized - Please login again";
          break;
        case 403:
          errorMessage = apiErrorMessage ?? "Forbidden - You don't have permission";
          break;
        case 404:
          errorMessage = apiErrorMessage ?? "Not Found";
          break;
        case 500:
          errorMessage = apiErrorMessage ?? "Internal Server Error";
          break;
        default:
          errorMessage = apiErrorMessage ?? "API Error";
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

    // Giữ lại response data khi reject để service có thể truy cập
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: errorMessage,
      ),
    );
  }
}
