import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/routes/app_pages.dart';

enum PaymentResultType {
  success,
  cancel,
  failure,
}

class PaymentResultView extends StatelessWidget {
  final PaymentResultType resultType;
  final String? planId;
  final String? orderCode;
  final String? message;
  final String? error;
  final String? reason;

  const PaymentResultView({
    super.key,
    required this.resultType,
    this.planId,
    this.orderCode,
    this.message,
    this.error,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Payment Result",
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: ColorsManager.primary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              _buildIcon(context),
              
              SizedBox(height: UtilsReponsive.height(24, context)),
              
              // Title
              TextConstant.titleH1(
                context,
                text: _getTitle(),
                color: _getTitleColor(),
                fontWeight: FontWeight.bold,
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Message
              if (message != null || _getDefaultMessage() != null)
                TextConstant.subTile1(
                  context,
                  text: message ?? _getDefaultMessage() ?? '',
                  color: Colors.grey[600]!,
                  // textAlign: TextAlign.center,
                ),
              
              if (error != null) ...[
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile3(
                  context,
                  text: "Error: $error",
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
              ],
              
              if (reason != null) ...[
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile3(
                  context,
                  text: "Reason: $reason",
                  color: Colors.orange,
                  textAlign: TextAlign.center,
                ),
              ],
              
              SizedBox(height: UtilsReponsive.height(32, context)),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate về home và clear navigation stack
                    Get.offAllNamed(Routes.HOME);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: UtilsReponsive.height(16, context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextConstant.subTile2(
                    context,
                    text: "Back to Home",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (resultType) {
      case PaymentResultType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentResultType.cancel:
        icon = Icons.cancel;
        color = Colors.orange;
        break;
      case PaymentResultType.failure:
        icon = Icons.error;
        color = Colors.red;
        break;
    }
    
    return Container(
      width: UtilsReponsive.width(100, context),
      height: UtilsReponsive.width(100, context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: UtilsReponsive.width(60, context),
        color: color,
      ),
    );
  }

  String _getTitle() {
    switch (resultType) {
      case PaymentResultType.success:
        return "Payment Successful!";
      case PaymentResultType.cancel:
        return "Payment Cancelled";
      case PaymentResultType.failure:
        return "Payment Failed";
    }
  }

  Color _getTitleColor() {
    switch (resultType) {
      case PaymentResultType.success:
        return Colors.green;
      case PaymentResultType.cancel:
        return Colors.orange;
      case PaymentResultType.failure:
        return Colors.red;
    }
  }

  String? _getDefaultMessage() {
    switch (resultType) {
      case PaymentResultType.success:
        return "Your subscription has been activated successfully!";
      case PaymentResultType.cancel:
        return "You cancelled the payment. You can try again later.";
      case PaymentResultType.failure:
        return "Payment failed. Please try again or contact support.";
    }
  }
}

