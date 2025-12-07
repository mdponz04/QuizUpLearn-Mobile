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

enum HostGamePhase {
  lobby,        // Chờ players join
  gameStarted,  // Game đã bắt đầu (countdown)
  question,     // Đang hiển thị câu hỏi
  result,       // Hiển thị kết quả
  leaderboard,  // Hiển thị leaderboard
  gameEnd,      // Game kết thúc
}

class _GameRoomViewState extends State<GameRoomView> {
  final GameHubService _gameHub = GameHubService();
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isStartingGame = false;
  HostGamePhase _currentPhase = HostGamePhase.lobby;
  String? _connectionStatus;
  String? _gamePin;
  
  // Game data
  int _totalPlayers = 0;
  int _totalQuestions = 0;
  int _currentQuestionIndex = 0;
  int _answerCount = 0;
  int _totalAnswers = 0;
  Map<String, dynamic>? _currentQuestion; // Lưu câu hỏi hiện tại để hiển thị
  List<Map<String, dynamic>>? _leaderboard; // Leaderboard data
  Map<String, dynamic>? _currentGroupItem; // GroupItem cho TOEIC grouped questions
  
  // Boss Fight mode
  bool _isBossFightMode = false;
  int? _bossCurrentHP;
  int? _bossMaxHP;
  List<Map<String, dynamic>>? _damageLeaderboard;
  Map<String, dynamic>? _lobbySettings;

  @override
  void initState() {
    super.initState();
    final gameData = Get.arguments as GameData?;
    if (gameData != null) {
      _gamePin = gameData.gamePin;
    }
    // Listeners sẽ được setup sau khi connect
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
        // Backend có thể gửi totalPlayers/players (camelCase) hoặc TotalPlayers/Players (PascalCase)
        final totalPlayers = data['totalPlayers'] ?? data['TotalPlayers'] ?? 0;
        // Backend có thể gửi players (camelCase) hoặc Players (PascalCase)
        final players = data['players'] ?? data['Players'] ?? [];
        log('Lobby updated: $totalPlayers players');
        setState(() {
          _totalPlayers = totalPlayers;
          _connectionStatus = 'Lobby: $_totalPlayers players';
          // Lưu players vào leaderboard nếu có
          if (players.isNotEmpty) {
            _leaderboard = List<Map<String, dynamic>>.from(players);
          }
        });
      },
      onGameStarted: (data) {
        setState(() {
          // Backend có thể gửi totalQuestions (camelCase) hoặc TotalQuestions (PascalCase)
          _totalQuestions = data['totalQuestions'] ?? data['TotalQuestions'] ?? 0;
          _currentPhase = HostGamePhase.gameStarted;
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
        log('Host received ShowQuestion: ${data.toString()}');
        setState(() {
          _currentQuestion = data;
          _currentPhase = HostGamePhase.question;
          // Backend gửi questionNumber (1-based) hoặc QuestionIndex (0-based)
          _currentQuestionIndex = data['questionNumber'] ?? 
                                 (data['QuestionIndex'] ?? data['CurrentQuestionIndex'] ?? 0) + 1;
          _totalQuestions = data['totalQuestions'] ?? data['TotalQuestions'] ?? _totalQuestions;
          _answerCount = 0;
          _totalAnswers = _totalPlayers;
          // Xử lý GroupItem cho TOEIC grouped questions
          _currentGroupItem = data['groupItem'] ?? data['GroupItem'];
        });
        log('Host phase changed to: question, questionIndex: $_currentQuestionIndex');
        Get.snackbar(
          'Thông báo',
          'Câu hỏi $_currentQuestionIndex đã được hiển thị',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      },
      onAnswerCount: (data) {
        log('Host received AnswerCount: ${data.toString()}');
        setState(() {
          // Backend gửi submitted/total (lowercase) hoặc Submitted/Total (uppercase)
          _answerCount = data['submitted'] ?? data['Submitted'] ?? 0;
          _totalAnswers = data['total'] ?? data['Total'] ?? _totalPlayers;
        });
        log('Host answer count updated: $_answerCount/$_totalAnswers');
      },
      onUpdateLeaderboard: (data) {
        // Leaderboard realtime update khi có player submit answer
        // Backend có thể gửi players (camelCase) hoặc Players (PascalCase)
        // hoặc rankings (camelCase) hoặc Rankings (PascalCase)
        final players = data['players'] ?? 
                       data['Players'] ?? 
                       data['rankings'] ?? 
                       data['Rankings'] ?? 
                       [];
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(players);
        });
        log('Leaderboard updated: ${players.length} players');
      },
      onPlayerScoreUpdated: (data) {
        // Score của player vừa submit (gửi cho tất cả)
        // Backend có thể gửi playerName/score (camelCase) hoặc PlayerName/Score (PascalCase)
        final playerName = data['playerName'] ?? data['PlayerName'] ?? '';
        final score = data['score'] ?? data['Score'] ?? 0;
        log('Player score updated: $playerName - $score');
      },
      onShowAnswerResult: (data) {
        log('Host received ShowAnswerResult: ${data.toString()}');
        setState(() {
          _currentPhase = HostGamePhase.result;
        });
        log('Host phase changed to: result');
      },
      onShowLeaderboard: (data) {
        log('Host received ShowLeaderboard: ${data.toString()}');
        setState(() {
          // Backend có thể gửi players (camelCase) hoặc Players (PascalCase)
          // hoặc rankings (camelCase) hoặc Rankings (PascalCase)
          final players = data['players'] ?? 
                         data['Players'] ?? 
                         data['rankings'] ?? 
                         data['Rankings'] ?? 
                         [];
          _leaderboard = List<Map<String, dynamic>>.from(players);
          _currentPhase = HostGamePhase.leaderboard;
        });
        log('Host phase changed to: leaderboard');
      },
      onGameEnded: (data) {
        setState(() {
          _currentPhase = HostGamePhase.gameEnd;
        });
        Get.snackbar(
          'Thông báo',
          'Game đã kết thúc!',
          backgroundColor: Colors.orange,
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
      // Boss Fight events
      onBossFightModeEnabled: (data) {
        setState(() {
          _isBossFightMode = true;
        });
        Get.snackbar(
          'Thông báo',
          'Boss Fight Mode đã được bật!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      onLobbySettingsUpdated: (data) {
        setState(() {
          _lobbySettings = data;
          _bossMaxHP = data['bossMaxHP'] ?? data['BossMaxHP'];
        });
        log('Lobby settings updated: ${data.toString()}');
      },
      onBossDamaged: (data) {
        setState(() {
          _bossCurrentHP = data['currentHP'] ?? data['CurrentHP'];
          _bossMaxHP = data['maxHP'] ?? data['MaxHP'] ?? _bossMaxHP;
        });
        log('Boss damaged: ${_bossCurrentHP}/${_bossMaxHP}');
      },
      onBossDefeated: (data) {
        setState(() {
          _bossCurrentHP = 0;
        });
        Get.snackbar(
          'Chiến thắng!',
          'Boss đã bị đánh bại!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onBossFightTimeUp: (data) {
        Get.snackbar(
          'Thông báo',
          'Hết thời gian!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      onBossFightQuestionsExhausted: (data) {
        Get.snackbar(
          'Thông báo',
          'Đã hết câu hỏi!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      onBossFightAnswerResult: (data) {
        log('Boss Fight answer result: ${data.toString()}');
      },
      onRealtimeLeaderboard: (data) {
        setState(() {
          _damageLeaderboard = List<Map<String, dynamic>>.from(
            data['players'] ?? data['Players'] ?? []
          );
        });
        log('Realtime leaderboard updated: ${_damageLeaderboard?.length} players');
      },
      onBossFightLeaderboard: (data) {
        setState(() {
          _damageLeaderboard = List<Map<String, dynamic>>.from(
            data['players'] ?? data['Players'] ?? []
          );
        });
        log('Boss Fight leaderboard updated: ${_damageLeaderboard?.length} players');
      },
      onBossState: (data) {
        setState(() {
          _bossCurrentHP = data['currentHP'] ?? data['CurrentHP'];
          _bossMaxHP = data['maxHP'] ?? data['MaxHP'];
        });
        log('Boss state: ${_bossCurrentHP}/${_bossMaxHP}');
      },
      onGameForceEnded: (data) {
        setState(() {
          _currentPhase = HostGamePhase.gameEnd;
        });
        Get.snackbar(
          'Thông báo',
          'Game đã bị kết thúc bởi moderator',
          backgroundColor: Colors.orange,
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
        // Setup listeners SAU KHI connect thành công
        _setupSignalRListeners();
        
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

  Future<void> _showQuestionResult() async {
    if (_gamePin == null) return;

    try {
      await _gameHub.showQuestionResult(_gamePin!);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể hiển thị kết quả: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _nextQuestion() async {
    if (_gamePin == null) return;

    try {
      await _gameHub.nextQuestion(_gamePin!);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể chuyển câu hỏi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showBossFightDialog() async {
    int bossHP = 100;
    int? timeLimitSeconds;
    int questionTimeLimitSeconds = 30;
    bool autoNextQuestion = false;

    final bossHPController = TextEditingController(text: '100');
    final timeLimitController = TextEditingController();
    final questionTimeController = TextEditingController(text: '30');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextConstant.subTile1(
          context,
          text: 'Bật Boss Fight Mode',
          fontWeight: FontWeight.bold,
          size: 16,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bossHPController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Boss HP',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              TextField(
                controller: timeLimitController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Thời gian giới hạn (giây, để trống = không giới hạn)',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              TextField(
                controller: questionTimeController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Thời gian mỗi câu hỏi (giây)',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              Row(
                children: [
                  TextConstant.subTile2(
                    context,
                    text: 'Tự động chuyển câu hỏi',
                    size: 12,
                  ),
                  Spacer(),
                  Switch(
                    value: autoNextQuestion,
                    onChanged: (value) {
                      setState(() {
                        autoNextQuestion = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextConstant.subTile2(
              context,
              text: 'Hủy',
              size: 12,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              bossHP = int.tryParse(bossHPController.text) ?? 100;
              timeLimitSeconds = timeLimitController.text.isEmpty
                  ? null
                  : int.tryParse(timeLimitController.text);
              questionTimeLimitSeconds =
                  int.tryParse(questionTimeController.text) ?? 30;
              Navigator.pop(context);
              _enableBossFightMode(
                bossHP,
                timeLimitSeconds,
                questionTimeLimitSeconds,
                autoNextQuestion,
              );
            },
            child: TextConstant.subTile2(
              context,
              text: 'Xác nhận',
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableBossFightMode(
    int bossHP,
    int? timeLimitSeconds,
    int questionTimeLimitSeconds,
    bool autoNextQuestion,
  ) async {
    if (_gamePin == null) return;

    try {
      await _gameHub.enableBossFightMode(
        _gamePin!,
        bossHP: bossHP,
        timeLimitSeconds: timeLimitSeconds,
        questionTimeLimitSeconds: questionTimeLimitSeconds,
        autoNextQuestion: autoNextQuestion,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể bật Boss Fight Mode: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showLobbySettingsDialog() async {
    int bossMaxHP = 100;
    int? timeLimitSeconds;
    int questionTimeLimitSeconds = 30;

    final bossHPController = TextEditingController(text: '100');
    final timeLimitController = TextEditingController();
    final questionTimeController = TextEditingController(text: '30');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextConstant.subTile1(
          context,
          text: 'Cấu hình Lobby',
          fontWeight: FontWeight.bold,
          size: 16,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bossHPController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Boss Max HP',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              TextField(
                controller: timeLimitController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Thời gian giới hạn (giây, để trống = không giới hạn)',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              TextField(
                controller: questionTimeController,
                decoration: InputDecoration(
                  labelText: TextConstant.subTile2(
                    context,
                    text: 'Thời gian mỗi câu hỏi (giây)',
                    size: 12,
                  ).data,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextConstant.subTile2(
              context,
              text: 'Hủy',
              size: 12,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              bossMaxHP = int.tryParse(bossHPController.text) ?? 100;
              timeLimitSeconds = timeLimitController.text.isEmpty
                  ? null
                  : int.tryParse(timeLimitController.text);
              questionTimeLimitSeconds =
                  int.tryParse(questionTimeController.text) ?? 30;
              Navigator.pop(context);
              _broadcastLobbySettings(
                bossMaxHP,
                timeLimitSeconds,
                questionTimeLimitSeconds,
              );
            },
            child: TextConstant.subTile2(
              context,
              text: 'Gửi',
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _broadcastLobbySettings(
    int bossMaxHP,
    int? timeLimitSeconds,
    int questionTimeLimitSeconds,
  ) async {
    if (_gamePin == null) return;

    try {
      await _gameHub.broadcastLobbySettings(
        _gamePin!,
        bossMaxHP: bossMaxHP,
        timeLimitSeconds: timeLimitSeconds,
        questionTimeLimitSeconds: questionTimeLimitSeconds,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể gửi cấu hình: $e',
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
            
            // Chỉ hiển thị QR code và PIN khi ở lobby
            if (_currentPhase == HostGamePhase.lobby) ...[
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
            ] else ...[
              // Hiển thị leaderboard khi game đã bắt đầu
              _buildLeaderboard(context),
              
              SizedBox(height: UtilsReponsive.height(32, context)),
            ],
            
            // Game Control Buttons
            _buildGameControls(context),
            
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

  Widget _buildLeaderboard(BuildContext context) {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return Container(
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
            Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH2(
              context,
              text: "Bảng xếp hạng",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.subTile1(
              context,
              text: "Chưa có dữ liệu",
              color: Colors.grey[600]!,
            ),
          ],
        ),
      );
    }

    return Container(
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
          Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH2(
            context,
            text: "Bảng xếp hạng",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          ..._leaderboard!.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            // Backend gửi playerName (camelCase) hoặc PlayerName (PascalCase)
            final playerName = player['playerName'] ?? 
                              player['PlayerName'] ?? 
                              '';
            // Backend gửi totalScore (camelCase) hoặc TotalScore (PascalCase)
            // hoặc score/Score (backward compatibility)
            final score = player['totalScore'] ?? 
                         player['TotalScore'] ?? 
                         player['score'] ?? 
                         player['Score'] ?? 0;
            // Backend gửi rank (camelCase) hoặc Rank (PascalCase)
            final rank = player['rank'] ?? 
                        player['Rank'] ?? 
                        (index + 1);
            final medals = ['🥇', '🥈', '🥉'];

            return Container(
              margin: EdgeInsets.only(
                  bottom: UtilsReponsive.height(12, context)),
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: UtilsReponsive.width(40, context),
                    child: TextConstant.titleH3(
                      context,
                      text: rank <= 3
                          ? medals[rank - 1]
                          : "$rank",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConstant.subTile1(
                          context,
                          text: playerName,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        if (player['correctAnswers'] != null || 
                            player['CorrectAnswers'] != null)
                          TextConstant.subTile2(
                            context,
                            text: "Đúng: ${player['correctAnswers'] ?? player['CorrectAnswers'] ?? 0}",
                            color: Colors.grey[600]!,
                          ),
                      ],
                    ),
                  ),
                  TextConstant.subTile1(
                    context,
                    text: "$score điểm",
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGameControls(BuildContext context) {
    return Container(
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
          // Main action button
          if (_currentPhase == HostGamePhase.lobby)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isConnecting || _isStartingGame) 
                        ? null 
                        : (_isConnected ? _startGame : _testConnect),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isConnected 
                          ? Colors.green 
                          : ColorsManager.primary,
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
                                size: 12,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isConnected 
                                    ? Icons.play_arrow 
                                    : Icons.wifi,
                                color: Colors.white,
                                size: UtilsReponsive.height(20, context),
                              ),
                              SizedBox(width: UtilsReponsive.width(8, context)),
                              TextConstant.subTile1(
                                context,
                                text: _isConnected 
                                    ? "Start Game" 
                                    : "Connect",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 12,
                              ),
                            ],
                          ),
                  ),
                ),
                if (_isConnected) ...[
                  SizedBox(height: UtilsReponsive.height(8, context)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showBossFightDialog,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange, width: 1),
                            padding: EdgeInsets.symmetric(
                              vertical: UtilsReponsive.height(12, context),
                            ),
                          ),
                          child: TextConstant.subTile2(
                            context,
                            text: 'Boss Fight',
                            color: Colors.orange,
                            size: 11,
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(8, context)),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showLobbySettingsDialog,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue, width: 1),
                            padding: EdgeInsets.symmetric(
                              vertical: UtilsReponsive.height(12, context),
                            ),
                          ),
                          child: TextConstant.subTile2(
                            context,
                            text: 'Cấu hình',
                            color: Colors.blue,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          else if (_currentPhase == HostGamePhase.gameStarted)
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: Colors.blue),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Đang đếm ngược...",
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            )
          else if (_currentPhase == HostGamePhase.question)
            Column(
              children: [
                // Boss HP Bar và Damage Leaderboard
                if (_isBossFightMode) ...[
                  _buildBossHPBar(context),
                  if (_damageLeaderboard != null && _damageLeaderboard!.isNotEmpty)
                    _buildDamageLeaderboard(context),
                ],
                // GroupItem (TOEIC grouped questions)
                if (_currentGroupItem != null)
                  _buildGroupItem(context, _currentGroupItem!),
                // Question Info Card
                if (_currentQuestion != null)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextConstant.subTile2(
                              context,
                              text: "Câu $_currentQuestionIndex/$_totalQuestions",
                              color: Colors.grey[600]!,
                              size: 11,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: UtilsReponsive.width(12, context),
                                vertical: UtilsReponsive.height(6, context),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people, color: Colors.blue, size: 14),
                                  SizedBox(width: UtilsReponsive.width(4, context)),
                                  TextConstant.subTile3(
                                    context,
                                    text: "$_answerCount/$_totalAnswers",
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    size: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: UtilsReponsive.height(16, context)),
                        TextConstant.titleH3(
                          context,
                          text: _currentQuestion!['questionText'] ?? 
                                _currentQuestion!['QuestionText'] ?? 
                                'Câu hỏi',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          size: 14,
                        ),
                        SizedBox(height: UtilsReponsive.height(16, context)),
                        // Answer options (chỉ để xem)
                        ...(_currentQuestion!['answerOptions'] ?? 
                             _currentQuestion!['Answers'] ?? 
                             _currentQuestion!['Options'] ?? []).asMap().entries.map((entry) {
                          final index = entry.key;
                          final answer = entry.value;
                          final answerLabels = ['A', 'B', 'C', 'D'];
                          final optionText = answer['optionText'] ?? 
                                           answer['OptionText'] ?? 
                                           answer['AnswerText'] ?? '';
                          
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: UtilsReponsive.height(8, context),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: UtilsReponsive.width(32, context),
                                  height: UtilsReponsive.width(32, context),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: TextConstant.subTile3(
                                      context,
                                      text: answerLabels[index],
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      size: 11,
                                    ),
                                  ),
                                ),
                                SizedBox(width: UtilsReponsive.width(12, context)),
                                Expanded(
                                  child: TextConstant.subTile2(
                                    context,
                                    text: optionText,
                                    color: Colors.black,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                // Answer count
                Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: UtilsReponsive.width(8, context)),
                      TextConstant.subTile1(
                        context,
                        text: "$_answerCount/$_totalAnswers đã trả lời",
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                // Show Result button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showQuestionResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
                        Icon(Icons.visibility, color: Colors.white),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: "Hiển thị kết quả",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else if (_currentPhase == HostGamePhase.result)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                    Icon(Icons.arrow_forward, color: Colors.white),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    TextConstant.subTile1(
                      context,
                      text: "Câu hỏi tiếp theo",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            )
          else if (_currentPhase == HostGamePhase.leaderboard)
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Đang tổng kết...",
                    color: Colors.amber[700]!,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            )
          else if (_currentPhase == HostGamePhase.gameEnd)
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.green),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Game đã kết thúc!",
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          
          if (_connectionStatus != null && _currentPhase == HostGamePhase.lobby) ...[
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
    );
  }

  Widget _buildBossHPBar(BuildContext context) {
    if (!_isBossFightMode || _bossMaxHP == null) return SizedBox.shrink();
    
    final currentHP = _bossCurrentHP ?? _bossMaxHP!;
    final percentage = currentHP / _bossMaxHP!;
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextConstant.subTile2(
                context,
                text: 'Boss HP',
                fontWeight: FontWeight.bold,
                size: 11,
              ),
              TextConstant.subTile2(
                context,
                text: '$currentHP / $_bossMaxHP',
                size: 11,
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.5 ? Colors.red : Colors.orange,
            ),
            minHeight: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildDamageLeaderboard(BuildContext context) {
    if (!_isBossFightMode || _damageLeaderboard == null || _damageLeaderboard!.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          TextConstant.subTile2(
            context,
            text: 'Bảng xếp hạng Damage',
            fontWeight: FontWeight.bold,
            size: 11,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          ..._damageLeaderboard!.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final playerName = player['playerName'] ?? player['PlayerName'] ?? '';
            final damage = player['damage'] ?? player['Damage'] ?? 0;
            
            return Padding(
              padding: EdgeInsets.only(bottom: UtilsReponsive.height(6, context)),
              child: Row(
                children: [
                  Container(
                    width: UtilsReponsive.width(24, context),
                    height: UtilsReponsive.width(24, context),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextConstant.subTile3(
                        context,
                        text: '${index + 1}',
                        size: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Expanded(
                    child: Text(
                      playerName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextConstant.subTile2(
                    context,
                    text: '$damage',
                    size: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, Map<String, dynamic> groupItem) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Passage Text
          if (groupItem['passageText'] != null && 
              groupItem['passageText'].toString().isNotEmpty) ...[
            TextConstant.subTile2(
              context,
              text: groupItem['passageText'],
              size: 11,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
          ],
          // Image
          if (groupItem['imageUrl'] != null && 
              groupItem['imageUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                groupItem['imageUrl'].toString(),
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: UtilsReponsive.height(100, context),
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
                  );
                },
              ),
            ),
          // Audio URL (chỉ hiển thị text, không có player)
          if (groupItem['audioUrl'] != null && 
              groupItem['audioUrl'].toString().isNotEmpty) ...[
            SizedBox(height: UtilsReponsive.height(8, context)),
            Row(
              children: [
                Icon(Icons.audiotrack, size: 16, color: Colors.blue),
                SizedBox(width: UtilsReponsive.width(4, context)),
                Expanded(
                  child: TextConstant.subTile3(
                    context,
                    text: 'Có audio',
                    size: 10,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

