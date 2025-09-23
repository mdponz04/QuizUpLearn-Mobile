import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill email if available
    emailController.text = "example@gmail.com";
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
      
      // Simulate login API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to home on success
      Get.offAllNamed('/home');
      Get.snackbar(
        'Success',
        'Welcome back!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
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
}
