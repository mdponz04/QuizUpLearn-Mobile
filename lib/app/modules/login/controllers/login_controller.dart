import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/auth_api.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/model/login_request.dart';
import 'package:quizkahoot/app/model/login_response.dart';
import 'package:quizkahoot/app/service/auth_service.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;
  late AuthService authService;

  @override
  void onInit() {
    super.onInit();
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    authService = AuthService(authApi: AuthApi(dio, baseUrl: baseUrl));
    
    // Initialize BaseCommon
    BaseCommon.instance.init();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.login(
        LoginRequest(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
      if (response.isSuccess) {
        // Save complete authentication data
        await _saveAuthData(response.data!);
        
        // Navigate to home on success
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/home');

        Get.snackbar(
          'Lỗi đăng nhập',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
     
    } catch (e) {
       Get.offAllNamed('/home');
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.snackbar(
      'Info',
      'Password reset link will be sent to your email',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void loginWithGoogle() {
    Get.snackbar(
      'Info',
      'Google login will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void loginWithFacebook() {
    Get.snackbar(
      'Info',
      'Facebook login will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Save authentication data to BaseCommon
  Future<void> _saveAuthData(LoginReponse loginResponse) async {
    try {
      final authData = loginResponse.data;
      await BaseCommon.instance.saveAuthData(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
        accessTokenExpiry: authData.expiresAt,
        refreshTokenExpiry: authData.refreshExpiresAt,
        userInfo: {
          'id': authData.account.id,
          'email': authData.account.email,
          'userId': authData.account.userId,
          'roleId': authData.account.roleId,
          'isEmailVerified': authData.account.isEmailVerified,
          'isActive': authData.account.isActive,
          'isBanned': authData.account.isBanned,
        },
      );
      BaseCommon.instance.userId = authData.account.userId;
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }
}
