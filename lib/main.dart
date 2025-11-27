import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/payment/views/payment_result_view.dart';
import 'package:quizkahoot/app/routes/app_pages.dart';
import 'package:quizkahoot/app/service/deep_link_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Xử lý deep link khi app mở lần đầu
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      log("MyApp: Initial deep link: $initialLink");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DeepLinkService.handleDeepLink(initialLink.toString());
      });
    }

    // Listen cho deep links khi app đang chạy
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        log("MyApp: Received deep link: $uri");
        DeepLinkService.handleDeepLink(uri.toString());
      },
      onError: (err) {
        log("MyApp: Deep link error: $err");
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      onGenerateRoute: (settings) {
        log("onGenerateRoute: ${settings.name}");
        // Handle deep links for payment callbacks
        // Parse URI trực tiếp như pharma_booking_mobile
        try {
          final uri = Uri.parse(settings.name ?? '');
          
          // Payment result routes
          if (uri.path.startsWith('/payment/')) {
            final segments = uri.pathSegments;
            if (segments.length >= 2) {
              final planId = uri.queryParameters['planId'];
              
              if (planId != null) {
                PaymentResultType resultType;
                switch (segments[1]) {
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
                    return null;
                }
                
                return GetPageRoute(
                  settings: settings,
                  page: () => PaymentResultView(
                    resultType: resultType,
                    planId: planId,
                    orderCode: uri.queryParameters['orderCode'],
                    message: uri.queryParameters['message'],
                    error: uri.queryParameters['error'],
                    reason: uri.queryParameters['reason'],
                  ),
                );
              }
            }
          }
        } catch (e) {
          log("onGenerateRoute error: $e");
        }
        
        return null;
      },
    );
  }
}
