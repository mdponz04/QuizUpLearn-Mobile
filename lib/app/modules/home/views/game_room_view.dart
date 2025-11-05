import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../models/create_game_response.dart';

class GameRoomView extends StatelessWidget {
  const GameRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameData = Get.arguments as GameData?;
    
    if (gameData == null) {
      return Scaffold(
        appBar: AppBar(
          title: TextConstant.titleH2(
            context,
            text: "Game Room",
            color: ColorsManager.primary,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorsManager.primary,
            ),
          ),
        ),
        body: Center(
          child: TextConstant.titleH3(
            context,
            text: "Không tìm thấy thông tin game",
            color: Colors.grey[600]!,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Game Room",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorsManager.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: UtilsReponsive.height(20, context)),
            
            // Game PIN
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextConstant.subTile2(
                    context,
                    text: "Game PIN",
                    color: Colors.grey[600]!,
                  ),
                  SizedBox(height: UtilsReponsive.height(12, context)),
                  TextConstant.titleH1(
                    context,
                    text: gameData.gamePin,
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                    size: 48,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: UtilsReponsive.height(32, context)),
            
            // QR Code
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextConstant.subTile1(
                    context,
                    text: "Quét mã QR để tham gia",
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  QrImageView(
                    data: gameData.gamePin,
                    version: QrVersions.auto,
                    size: UtilsReponsive.width(250, context),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: UtilsReponsive.height(32, context)),
            
            // Game Session Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConstant.titleH3(
                    context,
                    text: "Thông tin Game",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  _buildInfoRow(
                    context,
                    "Session ID",
                    gameData.gameSessionId,
                  ),
                  SizedBox(height: UtilsReponsive.height(12, context)),
                  _buildInfoRow(
                    context,
                    "Created",
                    _formatDateTime(gameData.createdAt),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: UtilsReponsive.height(32, context)),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: gameData.gamePin));
                      Get.snackbar(
                        'Thành công',
                        'Đã copy PIN vào clipboard',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorsManager.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: UtilsReponsive.height(16, context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copy,
                          color: ColorsManager.primary,
                          size: UtilsReponsive.height(20, context),
                        ),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: "Copy PIN",
                          color: ColorsManager.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(16, context)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: UtilsReponsive.height(16, context),
                      ),
                    ),
                    child: TextConstant.subTile1(
                      context,
                      text: "Đóng",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(20, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: UtilsReponsive.width(100, context),
          child: TextConstant.subTile2(
            context,
            text: "$label:",
            color: Colors.grey[600]!,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: TextConstant.subTile2(
            context,
            text: value,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

