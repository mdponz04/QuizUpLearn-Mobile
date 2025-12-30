import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizkahoot/app/data/auth_api.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/model/login_request.dart';
import 'package:quizkahoot/app/model/login_response.dart';
import 'package:quizkahoot/app/routes/app_pages.dart';
import 'package:quizkahoot/app/service/auth_service.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController(text: 'tuan4@gmail.com');
  final passwordController = TextEditingController(text: '123456');
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
        // Get.offAllNamed('/home');

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

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Khởi tạo Google Sign-In (version 6.x)
      // Không cần serverClientId nếu chỉ dùng Firebase Auth
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Đăng xuất nếu đã đăng nhập trước đó (để test)
      try {
        await googleSignIn.signOut();
      } catch (e) {
        log('Sign out error (ignored): $e');
      }
      
      // Thực hiện đăng nhập Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        isLoading.value = false;
        return;
      }

      // Lấy authentication details từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // In ra idToken từ Google trước khi đăng nhập Firebase
      log('=== GOOGLE AUTHENTICATION ===');
      log('Google ID Token: ${googleAuth.idToken}');
      log('Google Access Token: ${googleAuth.accessToken}');
      log('===========================');

      // Kiểm tra idToken và accessToken
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw Exception('Không thể lấy thông tin xác thực từ Google');
      }

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase với credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Kiểm tra user credential
      if (userCredential.user == null) {
        throw Exception('Không thể đăng nhập vào Firebase');
      }
      
      // Lấy idToken từ Firebase (Firebase ID Token)
      final String? firebaseIdToken = await userCredential.user?.getIdToken();
      
      // In ra Firebase ID Token và thông tin user
      log('=== FIREBASE LOGIN SUCCESS ===');
      log('Firebase ID Token: $firebaseIdToken');
      log('User ID: ${userCredential.user?.uid}');
      log('Email: ${userCredential.user?.email}');
      log('Display Name: ${userCredential.user?.displayName}');
      log('===========================');
      
      // Kiểm tra Firebase ID Token
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Không thể lấy Firebase ID Token');
      }
      
      // Gọi API backend với Firebase ID Token
      log('=== CALLING BACKEND API ===');
      final apiResponse = await authService.loginWithGoogle(firebaseIdToken);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        // Lưu thông tin từ backend response
        await _saveAuthData(apiResponse.data!);
        
        log('=== BACKEND LOGIN SUCCESS ===');
        log('Access Token: ${apiResponse.data!.data.accessToken}');
        log('User ID: ${apiResponse.data!.data.account.userId}');
        log('Email: ${apiResponse.data!.data.account.email}');
        log('Username: ${apiResponse.data!.data.account.username}');
        log('===========================');
        
        // Hiển thị thông báo thành công
        Get.snackbar(
          'Đăng nhập Google thành công',
          'Chào mừng ${apiResponse.data!.data.account.username}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to home sau khi đăng nhập thành công
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
      } else {
        throw Exception(apiResponse.message);
      }
      
    } catch (e, stackTrace) {
      log('Google login error: $e');
      log('Stack trace: $stackTrace');
      
      String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      
      // Xử lý lỗi cụ thể
      if (e.toString().contains('ApiException: 10') || 
          e.toString().contains('DEVELOPER_ERROR') ||
          e.toString().contains('sign_in_failed')) {
        errorMessage = 'Lỗi cấu hình Google Sign-In.\n'
            'Vui lòng thêm SHA-1 fingerprint vào Firebase Console:\n'
            'SHA-1: BA:1F:9A:A8:73:82:77:39:64:86:31:4F:87:19:D6:FC:61:BB:F0:FF\n\n'
            'Hướng dẫn:\n'
            '1. Vào Firebase Console > Project Settings\n'
            '2. Chọn app Android của bạn\n'
            '3. Thêm SHA-1 fingerprint ở phần "SHA certificate fingerprints"\n'
            '4. Tải lại google-services.json\n'
            '5. Rebuild app';
      } else if (e.toString().length < 100) {
        errorMessage = e.toString();
      }
      
      Get.snackbar(
        'Lỗi đăng nhập Google',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        maxWidth: 400,
      );
    } finally {
      isLoading.value = false;
    }
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
      final account = authData.account;
      
      await BaseCommon.instance.saveAuthData(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
        accessTokenExpiry: authData.expiresAt,
        refreshTokenExpiry: authData.refreshExpiresAt,
        userInfo: {
          'id': account.id,
          'email': account.email,
          'username': account.username,
          'avatarUrl': account.avatarUrl,
          'userId': account.userId,
          'roleId': account.roleId,
          'roleName': account.roleName,
          'isEmailVerified': account.isEmailVerified,
          'isActive': account.isActive,
          'isBanned': account.isBanned,
        },
      );
      BaseCommon.instance.userId = account.userId;
    } catch (e) {
      log('Error saving auth data: $e');
    }
  }
}
