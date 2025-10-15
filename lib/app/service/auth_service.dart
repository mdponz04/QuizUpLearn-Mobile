import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/auth_api.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/model/login_request.dart';
import 'package:quizkahoot/app/model/login_response.dart';
import 'package:quizkahoot/app/model/register_request.dart';
import 'package:quizkahoot/app/model/register_response.dart';

class AuthService {
  AuthService({required this.authApi});
  AuthApi authApi;


  Future<BaseResponse<LoginReponse>> login(LoginRequest request) async {
    try {
      final response = await authApi.login(request.toJson());
      log("responseD ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Success',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred',
      );
    }
  }
  Future<BaseResponse<RegisterResponse>> register(RegisterRequest request) async {
    try {
      final response = await authApi.register(request.toJson());
      return BaseResponse(
        isSuccess: true,
        message: 'Success',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred',
      );
    }
  }
}
