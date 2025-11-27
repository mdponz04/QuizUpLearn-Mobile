import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/payment/views/payment_result_view.dart';
import 'package:quizkahoot/app/service/url_handler_service.dart';

/// Service để xử lý deep links khi app mở từ payment gateway
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// Xử lý deep link URL
  static Future<void> handleDeepLink(String? url) async {
    if (url == null || url.isEmpty) return;
    
    log("DeepLinkService: Received URL: $url");
    
    // Kiểm tra xem có phải app URL không
    if (!UrlHandlerService.isAppUrl(url)) {
      log("DeepLinkService: Not an app URL, ignoring");
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      log("DeepLinkService: URI: ${uri.toString()}");
      
      // Payment result routes
      if (uri.toString().contains('/payment/')) {
        final segments = uri.pathSegments;
        log("DeepLinkService: Segments: $segments");
        // if (segments.length >= 2) {
          final planId = uri.queryParameters['planId'];
          
          if (planId != null) {
            PaymentResultType resultType;
            switch (segments[0]) {
              case 'success':
                resultType = PaymentResultType.success;
                break;
              case 'cancel':
                resultType = PaymentResultType.cancel;
                break;
              case 'failure':
                resultType = PaymentResultType.failure;
                break;
              default:
                log("DeepLinkService: Unknown payment result type: ${segments[1]}");
                return;
            }
            
            log("DeepLinkService: Navigating to payment result: $resultType");
            
            // Navigate đến payment result screen
            Get.to(
              () => PaymentResultView(
                resultType: resultType,
                planId: planId,
                orderCode: uri.queryParameters['orderCode'],
                message: uri.queryParameters['message'],
                error: uri.queryParameters['error'],
                reason: uri.queryParameters['reason'],
              ),
            );
          } else {
            log("DeepLinkService: Missing planId in payment URL");
          }
        // }
      }
    } catch (e) {
      log("DeepLinkService: Error handling deep link: $e");
    }
  }
}

