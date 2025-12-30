import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsManager.primary,
              ColorsManager.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: UtilsReponsive.height(50, context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Top section with logo and title - flexible height
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(24, context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo placeholder - smaller on small screens
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/login.png',
                              width: UtilsReponsive.height(125, context),
                              height: UtilsReponsive.height(125, context),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Quiz\nUpLearn",
                              style: GoogleFonts.montserratAlternates(
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black87,
                                    spreadRadius: 10,
                                    blurRadius: 2,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                                letterSpacing: 3,
                                color: Colors.white,
                                fontSize: UtilsReponsive.formatFontSize(
                                  36,
                                  context,
                                ),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // White container with form - flexible height
                Container(
                  margin: EdgeInsets.only(
                    top: UtilsReponsive.height(40, context),
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: _buildLoginForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(20, context),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: UtilsReponsive.height(20, context)),

            // Welcome Back title
            TextConstant.titleH1(
              context,
              text: "Chào mừng bạn trở lại",
              color: Colors.black,
              size: 24,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: UtilsReponsive.height(4, context)),

            TextConstant.subTile1(
              context,
              text: "Đăng nhập",
              color: Colors.grey[600]!,
              size: 14,
            ),

            SizedBox(height: UtilsReponsive.height(24, context)),

            // Email field
            _buildEmailField(context),

            SizedBox(height: UtilsReponsive.height(16, context)),

            // Password field
            _buildPasswordField(context),

            SizedBox(height: UtilsReponsive.height(12, context)),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.forgotPassword,
                child: TextConstant.subTile2(
                  context,
                  text: "Quên mật khẩu?",
                  color: ColorsManager.primary,
                ),
              ),
            ),

            SizedBox(height: UtilsReponsive.height(20, context)),

            // Login button
            _buildLoginButton(context),

            SizedBox(height: UtilsReponsive.height(20, context)),

            // Or divider
            _buildOrDivider(context),

            SizedBox(height: UtilsReponsive.height(16, context)),

            // Social login buttons
            _buildSocialButtons(context),

            SizedBox(height: UtilsReponsive.height(24, context)),

            // Sign up link
            _buildSignUpLink(context),

            SizedBox(height: UtilsReponsive.height(20, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: controller.emailController,
      validator: controller.validateEmail,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Nhập email",
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ColorsManager.primary),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: UtilsReponsive.width(12, context),
          vertical: UtilsReponsive.height(12, context),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        validator: controller.validatePassword,
        obscureText: !controller.isPasswordVisible.value,
        decoration: InputDecoration(
          labelText: "Mật khẩu",
          hintText: "Nhập mật khẩu",
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            onPressed: controller.togglePasswordVisibility,
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorsManager.primary),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(12, context),
            vertical: UtilsReponsive.height(12, context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: UtilsReponsive.height(48, context),
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child:
              controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : TextConstant.subTile1(
                    context,
                    text: "ĐĂNG NHẬP",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 16,
                  ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    return Column(
      children: [
        // Google button
        Obx(
          () => InkWell(
            onTap: controller.isLoading.value ? null : controller.loginWithGoogle,
            child: Container(
              width: double.infinity,
              height: UtilsReponsive.height(48, context),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google icon
                  const Icon(
                    Icons.g_mobiledata,
                    size: 24,
                    color: Color(0xFF4285F4), // Google Blue
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Đăng nhập bằng Google",
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextConstant.subTile2(
            context,
            text: "Không có tài khoản? ",
            color: Colors.grey[600]!,
          ),
          TextButton(
            onPressed: () => Get.toNamed('/register'),
            child: TextConstant.subTile2(
              context,
              text: "Đăng ký",
              color: ColorsManager.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
