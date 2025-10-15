import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/auth_api.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/model/register_request.dart';
import 'package:quizkahoot/app/routes/app_pages.dart';
import 'package:quizkahoot/app/service/auth_service.dart';

class RegisterController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isLoading = false.obs;
  var agreeToTerms = false.obs;
  late AuthService authService;

  @override
  void onInit() {
    super.onInit();
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    authService = AuthService(authApi: AuthApi(dio, baseUrl: baseUrl));
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateTerms(bool? value) {
    if (value == null || !value) {
      return 'You must agree to the terms and conditions';
    }
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar(
        'Lỗi',
        'Bạn phải đồng ý với điều khoản và điều kiện',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.register(
        RegisterRequest(
          fullName: fullNameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        ),
      );
      if (response.isSuccess) {
        // Navigate to login on success
        Get.back();
        await Future.delayed(const Duration(seconds: 1));
        Get.snackbar(
          'Thông báo',
          'Đăng ký thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đăng ký thất bại. Vui lòng thử lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithGoogle() {
    Get.snackbar(
      'Info',
      'Google registration will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void loginWithFacebook() {
    Get.snackbar(
      'Info',
      'Facebook registration will be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
