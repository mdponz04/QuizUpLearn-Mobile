import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../models/create_game_response.dart';
import '../../../service/game_hub_service.dart';

class GameRoomView extends StatefulWidget {
  const GameRoomView({super.key});

  @override
  State<GameRoomView> createState() => _GameRoomViewState();
}

class _GameRoomViewState extends State<GameRoomView> {
  final GameHubService _gameHub = GameHubService();
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isStartingGame = false;
  bool _isGameStarted = false;
  String? _connectionStatus;
  String? _gamePin;

  @override
  void initState() {
    super.initState();
    final gameData = Get.arguments as GameData?;
    if (gameData != null) {
      _gamePin = gameData.gamePin;
    }
    _setupSignalRListeners();
  }

  void _setupSignalRListeners() {
    _gameHub.setupEventListeners(
      onConnected: () {
        setState(() {
          _isConnected = true;
          _connectionStatus = 'Đã kết nối';
        });
        Get.snackbar(
          'Thành công',
          'Đã kết nối SignalR',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onConnectionError: (error) {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Lỗi: $error';
        });
        Get.snackbar(
          'Lỗi',
          'Không thể kết nối SignalR: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      onConnectionClosed: (error) {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Đã ngắt kết nối';
        });
      },
      onHostConnected: (data) {
        Get.snackbar(
          'Thành công',
          'Host đã kết nối vào game',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onLobbyUpdated: (data) {
        log('Lobby updated: ${data['TotalPlayers']} players');
        setState(() {
          _connectionStatus = 'Lobby: ${data['TotalPlayers']} players';
        });
      },
      onGameStarted: (data) {
        setState(() {
          _isGameStarted = true;
          _isStartingGame = false;
          _connectionStatus = 'Game đã bắt đầu';
        });
        Get.snackbar(
          'Thành công',
          'Game đã bắt đầu!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onShowQuestion: (data) {
        log('Show question: ${data['QuestionId']}');
        Get.snackbar(
          'Thông báo',
          'Câu hỏi đã được hiển thị',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      },
      onError: (error) {
        setState(() {
          _isStartingGame = false;
        });
        Get.snackbar(
          'Lỗi',
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> _testConnect() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Đang kết nối...';
      _isConnected = false;
    });

    try {
      const baseUrl = 'https://qul-api.onrender.com';
      final connected = await _gameHub.connect(baseUrl);

      if (connected) {
        final gameData = Get.arguments as GameData?;
        if (gameData != null) {
          _gamePin = gameData.gamePin;
          // Test HostConnect
          await _gameHub.hostConnect(gameData.gamePin);
        }
      } else {
        setState(() {
          _connectionStatus = 'Không thể kết nối';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Lỗi: $e';
      });
      Get.snackbar(
        'Lỗi',
        'Lỗi khi test connect: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _startGame() async {
    if (_isStartingGame || _gamePin == null) return;

    setState(() {
      _isStartingGame = true;
      _connectionStatus = 'Đang bắt đầu game...';
    });

    try {
      await _gameHub.startGame(_gamePin!);
    } catch (e) {
      setState(() {
        _isStartingGame = false;
        _connectionStatus = 'Lỗi khi start game: $e';
      });
      Get.snackbar(
        'Lỗi',
        'Không thể bắt đầu game: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _gameHub.dispose();
    super.dispose();
  }

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
            
            // Test Connect Button
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
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isConnecting || _isStartingGame) 
                          ? null 
                          : (_isConnected ? _startGame : _testConnect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isGameStarted
                            ? Colors.orange
                            : (_isConnected 
                                ? Colors.green 
                                : ColorsManager.primary),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: UtilsReponsive.height(16, context),
                        ),
                      ),
                      child: _isConnecting || _isStartingGame
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: UtilsReponsive.height(20, context),
                                  height: UtilsReponsive.height(20, context),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: UtilsReponsive.width(12, context)),
                                TextConstant.subTile1(
                                  context,
                                  text: _isConnecting 
                                      ? "Đang kết nối..." 
                                      : "Đang bắt đầu game...",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isGameStarted
                                      ? Icons.play_circle_filled
                                      : (_isConnected 
                                          ? Icons.play_arrow 
                                          : Icons.wifi),
                                  color: Colors.white,
                                  size: UtilsReponsive.height(20, context),
                                ),
                                SizedBox(width: UtilsReponsive.width(8, context)),
                                TextConstant.subTile1(
                                  context,
                                  text: _isGameStarted
                                      ? "Game đã bắt đầu"
                                      : (_isConnected 
                                          ? "Start Game" 
                                          : "Connect"),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_connectionStatus != null) ...[
                    SizedBox(height: UtilsReponsive.height(12, context)),
                    TextConstant.subTile3(
                      context,
                      text: _connectionStatus!,
                      color: _isConnected 
                          ? Colors.green 
                          : Colors.grey[600]!,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
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

