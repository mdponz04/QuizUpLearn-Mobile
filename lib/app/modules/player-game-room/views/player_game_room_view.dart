import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/service/game_hub_service.dart';

enum GamePhase {
  scanning,      // Đang scan QR
  enteringPin,   // Đang nhập PIN
  lobby,         // Chờ trong lobby
  gameStarted,   // Game đã bắt đầu (countdown)
  question,      // Đang hiển thị câu hỏi
  result,        // Hiển thị kết quả câu hỏi
  leaderboard,   // Hiển thị leaderboard
  gameEnd,       // Game kết thúc
  error,         // Lỗi
}

class PlayerGameRoomView extends StatefulWidget {
  const PlayerGameRoomView({super.key});

  @override
  State<PlayerGameRoomView> createState() => _PlayerGameRoomViewState();
}

class _PlayerGameRoomViewState extends State<PlayerGameRoomView> {
  final GameHubService _gameHub = GameHubService();
  final TextEditingController _playerNameController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  GamePhase _currentPhase = GamePhase.enteringPin;
  String? _gamePin;
  String? _playerName;
  bool _isConnecting = false;
  bool _hasSubmittedAnswer = false;

  // Game data
  int _totalPlayers = 0;
  List<Map<String, dynamic>> _players = [];
  int _totalQuestions = 0;
  int _currentQuestionIndex = 0;
  Map<String, dynamic>? _currentQuestion;
  int _timeRemaining = 0;
  Timer? _timer;
  String? _selectedAnswerId;
  Map<String, dynamic>? _questionResult;
  List<Map<String, dynamic>>? _leaderboard;
  Map<String, dynamic>? _finalResult;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['mode'] == 'scan') {
        _currentPhase = GamePhase.scanning;
      } else if (args['gamePin'] != null) {
        _gamePin = args['gamePin'];
        _currentPhase = GamePhase.enteringPin;
      }
    }
    // Listeners sẽ được setup sau khi connect
  }

  void _setupSignalRListeners() {
    _gameHub.setupEventListeners(
      onConnected: () {
        // Connection established
      },
      onConnectionError: (error) {
        setState(() {
          _currentPhase = GamePhase.error;
        });
        Get.snackbar('Lỗi', 'Không thể kết nối: $error',
            backgroundColor: Colors.red, colorText: Colors.white);
      },
      onConnectionClosed: (error) {
        // Connection closed
      },
      onJoinedGame: (data) {
        setState(() {
          _currentPhase = GamePhase.lobby;
        });
        Get.snackbar('Thành công', 'Đã tham gia game!',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onLobbyUpdated: (data) {
        setState(() {
          // Backend có thể gửi totalPlayers/players (camelCase) hoặc TotalPlayers/Players (PascalCase)
          _totalPlayers = data['totalPlayers'] ?? data['TotalPlayers'] ?? 0;
          _players = List<Map<String, dynamic>>.from(
              data['players'] ?? data['Players'] ?? []);
        });
      },
      onGameStarted: (data) {
        setState(() {
          // Backend có thể gửi totalQuestions (camelCase) hoặc TotalQuestions (PascalCase)
          _totalQuestions = data['totalQuestions'] ?? data['TotalQuestions'] ?? 0;
          _currentPhase = GamePhase.gameStarted;
        });
        // Sau 3 giây sẽ nhận ShowQuestion
      },
      onShowQuestion: (data) {
        log('Player received ShowQuestion: ${data.toString()}');
        setState(() {
          _currentQuestion = data;
          // Backend gửi questionNumber (1-based) hoặc QuestionIndex (0-based)
          _currentQuestionIndex = data['questionNumber'] ?? 
                                 (data['QuestionIndex'] ?? data['CurrentQuestionIndex'] ?? 0) + 1;
          _totalQuestions = data['totalQuestions'] ?? data['TotalQuestions'] ?? _totalQuestions;
          _currentPhase = GamePhase.question;
          _hasSubmittedAnswer = false;
          _selectedAnswerId = null;
          // Backend có thể gửi timeLimit hoặc TimeLimit hoặc Seconds
          _timeRemaining = data['timeLimit'] ?? data['TimeLimit'] ?? data['Seconds'] ?? 30;
        });
        _startTimer();
        log('Player phase changed to: question, questionIndex: $_currentQuestionIndex');
      },
      onQuestionTimeUpdated: (data) {
        setState(() {
          // Backend có thể gửi seconds (lowercase) hoặc Seconds (PascalCase)
          _timeRemaining = data['seconds'] ?? data['Seconds'] ?? _timeRemaining;
        });
      },
      onAnswerCount: (data) {
        // Backend có thể gửi submitted/total (lowercase) hoặc Submitted/Total (PascalCase)
        final submitted = data['submitted'] ?? data['Submitted'] ?? 0;
        final total = data['total'] ?? data['Total'] ?? 0;
        log('Answer count: $submitted/$total');
      },
      onUpdateLeaderboard: (data) {
        // Leaderboard realtime update
        // Backend có thể gửi players (camelCase) hoặc Players (PascalCase)
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(
              data['players'] ?? data['Players'] ?? []);
        });
      },
      onPlayerScoreUpdated: (data) {
        // Score của player vừa submit
        // Backend có thể gửi playerName/score (camelCase) hoặc PlayerName/Score (PascalCase)
        final playerName = data['playerName'] ?? data['PlayerName'] ?? '';
        final score = data['score'] ?? data['Score'] ?? 0;
        log('Player score updated: $playerName - $score');
      },
      onAnswerSubmitted: (data) {
        setState(() {
          _hasSubmittedAnswer = true;
        });
        Get.snackbar('Thành công', 'Đã gửi câu trả lời!',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onShowAnswerResult: (data) {
        log('Player received ShowAnswerResult: ${data.toString()}');
        _timer?.cancel();
        setState(() {
          _questionResult = data;
          _currentPhase = GamePhase.result;
        });
        log('Player phase changed to: result');
      },
      onShowLeaderboard: (data) {
        log('Player received ShowLeaderboard: ${data.toString()}');
        setState(() {
          // Backend có thể gửi rankings (camelCase) hoặc Rankings (PascalCase)
          // hoặc finalRankings/FinalRankings (khi game end)
          // hoặc players/Players (backward compatibility)
          final rankings = data['finalRankings'] ?? 
                          data['FinalRankings'] ?? 
                          data['rankings'] ?? 
                          data['Rankings'] ?? 
                          data['players'] ?? 
                          data['Players'] ?? [];
          _leaderboard = List<Map<String, dynamic>>.from(rankings);
          
          // Kiểm tra nếu đây là câu hỏi cuối cùng thì chuyển sang gameEnd
          final currentQuestion = data['currentQuestion'] ?? 
                                  data['CurrentQuestion'] ?? 
                                  data['questionNumber'] ?? 
                                  data['QuestionNumber'] ?? 0;
          final totalQuestions = data['totalQuestions'] ?? 
                                data['TotalQuestions'] ?? 
                                _totalQuestions;
          
          // Nếu có finalRankings hoặc currentQuestion >= totalQuestions thì là game end
          if (data['finalRankings'] != null || 
              data['FinalRankings'] != null || 
              currentQuestion >= totalQuestions) {
            // Đây là kết quả cuối cùng
            _finalResult = data;
            _currentPhase = GamePhase.gameEnd;
            log('Player phase changed to: gameEnd (final result)');
            log('Game End Data: ${data.toString()}');
            log('Game End Rankings: ${rankings.toString()}');
            log('Game End Current Question: $currentQuestion, Total: $totalQuestions');
          } else {
            // Leaderboard giữa chừng
            _currentPhase = GamePhase.leaderboard;
            log('Player phase changed to: leaderboard');
          }
        });
      },
      onGameEnded: (data) {
        _timer?.cancel();
        log('Player received GameEnded event: ${data.toString()}');
        setState(() {
          _finalResult = data;
          _currentPhase = GamePhase.gameEnd;
        });
        log('Player phase changed to: gameEnd (GameEnded event)');
        log('Game End Final Result: ${_finalResult.toString()}');
      },
      onError: (error) {
        Get.snackbar('Lỗi', error,
            backgroundColor: Colors.red, colorText: Colors.white);
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _connectAndJoin() async {
    if (_gamePin == null || _playerNameController.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên người chơi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() {
      _isConnecting = true;
      _playerName = _playerNameController.text.trim();
    });

    try {
      const baseUrl = 'https://qul-api.onrender.com';
      
      final connected = await _gameHub.connect(baseUrl);

      if (connected) {
        // Setup listeners SAU KHI connect thành công
        _setupSignalRListeners();
        await _gameHub.joinGame(_gamePin!, _playerName!);
      } else {
        setState(() {
          _isConnecting = false;
          _currentPhase = GamePhase.error;
        });
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _currentPhase = GamePhase.error;
      });
      Get.snackbar('Lỗi', 'Lỗi khi tham gia game: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswerId == null || _currentQuestion == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn đáp án',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_hasSubmittedAnswer) {
      return;
    }

    try {
      // Backend gửi questionId (lowercase) hoặc QuestionId (uppercase)
      final questionId = _currentQuestion!['questionId']?.toString() ?? 
                         _currentQuestion!['QuestionId']?.toString() ?? '';
      
      await _gameHub.submitAnswer(
        _gamePin!,
        questionId,
        _selectedAnswerId!,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gửi câu trả lời: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scannerController.dispose();
    _playerNameController.dispose();
    _gameHub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chơi Game",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.primary),
        ),
      ),
      body: _buildCurrentPhase(context),
    );
  }

  Widget _buildCurrentPhase(BuildContext context) {
    switch (_currentPhase) {
      case GamePhase.scanning:
        return _buildQRScanner(context);
      case GamePhase.enteringPin:
        return _buildEnterPlayerName(context);
      case GamePhase.lobby:
        return _buildLobby(context);
      case GamePhase.gameStarted:
        return _buildGameStarted(context);
      case GamePhase.question:
        return _buildQuestion(context);
      case GamePhase.result:
        return _buildResult(context);
      case GamePhase.leaderboard:
        return _buildLeaderboard(context);
      case GamePhase.gameEnd:
        return _buildGameEnd(context);
      case GamePhase.error:
        return _buildError(context);
    }
  }

  Widget _buildQRScanner(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    _gamePin = barcode.rawValue;
                    _currentPhase = GamePhase.enteringPin;
                  });
                  _scannerController.stop();
                  break;
                }
              }
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
          color: Colors.white,
          child: TextConstant.subTile1(
            context,
            text: "Quét QR code để tham gia game",
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildEnterPlayerName(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: UtilsReponsive.height(40, context)),
          Icon(
            Icons.person_add,
            size: UtilsReponsive.height(80, context),
            color: ColorsManager.primary,
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH2(
            context,
            text: "Nhập tên người chơi",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          if (_gamePin != null)
            TextConstant.subTile2(
              context,
              text: "Game PIN: $_gamePin",
              color: Colors.grey[600]!,
            ),
          SizedBox(height: UtilsReponsive.height(32, context)),
          TextField(
            controller: _playerNameController,
            decoration: InputDecoration(
              hintText: "Tên người chơi",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person, color: ColorsManager.primary),
            ),
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectAndJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(16, context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isConnecting
                  ? CircularProgressIndicator(color: Colors.white)
                  : TextConstant.subTile1(
                      context,
                      text: "Tham gia",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobby(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(20, context)),
          Container(
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
                Icon(Icons.people, size: 64, color: ColorsManager.primary),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH2(
                  context,
                  text: "Đang chờ...",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile2(
                  context,
                  text: "Chờ host bắt đầu game",
                  color: Colors.grey[600]!,
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                TextConstant.titleH1(
                  context,
                  text: "$_totalPlayers",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                  size: 48,
                ),
                TextConstant.subTile2(
                  context,
                  text: "người chơi",
                  color: Colors.grey[600]!,
                ),
              ],
            ),
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.titleH3(
                  context,
                  text: "Danh sách người chơi",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                if (_players.isEmpty)
                  TextConstant.subTile2(
                    context,
                    text: "Chưa có người chơi nào",
                    color: Colors.grey[600]!,
                  )
                else
                  ..._players.map((player) => Padding(
                        padding: EdgeInsets.only(
                            bottom: UtilsReponsive.height(8, context)),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: ColorsManager.primary),
                            SizedBox(width: UtilsReponsive.width(8, context)),
                            Expanded(
                              child: TextConstant.subTile1(
                                context,
                                text: player['playerName'] ?? player['PlayerName'] ?? '',
                                color: Colors.black,
                              ),
                            ),
                            if ((player['playerName'] ?? player['PlayerName']) == _playerName)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: UtilsReponsive.width(8, context),
                                  vertical: UtilsReponsive.height(4, context),
                                ),
                                decoration: BoxDecoration(
                                  color: ColorsManager.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextConstant.subTile4(
                                  context,
                                  text: "Bạn",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 10,
                                ),
                              ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStarted(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_filled,
              size: 100, color: ColorsManager.primary),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH1(
            context,
            text: "Game đã bắt đầu!",
            color: ColorsManager.primary,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.subTile1(
            context,
            text: "Chuẩn bị cho câu hỏi đầu tiên...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    if (_currentQuestion == null) {
      log('ERROR: _currentQuestion is null in _buildQuestion');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.subTile1(
              context,
              text: "Không có dữ liệu câu hỏi",
              color: Colors.red,
            ),
          ],
        ),
      );
    }

    final question = _currentQuestion!;
    log('Building question UI: ${question.toString()}');
    
    // Backend gửi answerOptions (với answerId và optionText)
    final answers = List<Map<String, dynamic>>.from(
      question['answerOptions'] ?? question['Answers'] ?? question['Options'] ?? []
    );
    
    if (answers.isEmpty) {
      log('ERROR: No answers found in question data');
      return Center(
        child: TextConstant.subTile1(
          context,
          text: "Không có đáp án",
          color: Colors.red,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          // Question header
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextConstant.subTile2(
                      context,
                      text: "Câu $_currentQuestionIndex/$_totalQuestions",
                      color: Colors.grey[600]!,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(12, context),
                        vertical: UtilsReponsive.height(6, context),
                      ),
                      decoration: BoxDecoration(
                        color: _timeRemaining <= 5
                            ? Colors.red
                            : ColorsManager.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextConstant.subTile1(
                        context,
                        text: "$_timeRemaining",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH2(
                  context,
                  text: question['questionText'] ?? question['QuestionText'] ?? '',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          // Answers
          ...answers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            // Backend gửi answerId (lowercase) hoặc AnswerId (uppercase)
            final answerId = answer['answerId']?.toString() ?? answer['AnswerId']?.toString();
            final isSelected = _selectedAnswerId == answerId;
            final answerLabels = ['A', 'B', 'C', 'D'];

            return Container(
              margin: EdgeInsets.only(
                  bottom: UtilsReponsive.height(12, context)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasSubmittedAnswer
                      ? null
                      : () {
                          // Backend gửi answerId (lowercase) hoặc AnswerId (uppercase)
                          final answerId = answer['answerId']?.toString() ?? 
                                         answer['AnswerId']?.toString();
                          setState(() {
                            _selectedAnswerId = answerId;
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorsManager.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? ColorsManager.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: UtilsReponsive.width(40, context),
                          height: UtilsReponsive.width(40, context),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorsManager.primary
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: TextConstant.subTile1(
                              context,
                              text: answerLabels[index],
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: UtilsReponsive.width(16, context)),
                        Expanded(
                          child: TextConstant.subTile1(
                            context,
                            text: answer['optionText'] ?? answer['OptionText'] ?? answer['AnswerText'] ?? '',
                            color: Colors.black,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: ColorsManager.primary),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: UtilsReponsive.height(24, context)),
          // Submit button
          if (!_hasSubmittedAnswer)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswerId == null ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(16, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: TextConstant.subTile1(
                  context,
                  text: "Gửi câu trả lời",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Đã gửi câu trả lời",
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    if (_questionResult == null) {
      log('ERROR: _questionResult is null in _buildResult');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.subTile1(
              context,
              text: "Đang tải kết quả...",
              color: Colors.grey[600]!,
            ),
          ],
        ),
      );
    }

    log('Building result UI: ${_questionResult.toString()}');
    
    // Backend có thể gửi correctAnswerId/correctAnswer (camelCase) hoặc CorrectAnswerId/CorrectAnswer (PascalCase)
    final correctAnswerId = _questionResult!['correctAnswerId']?.toString() ?? 
                            _questionResult!['CorrectAnswerId']?.toString() ?? 
                            _questionResult!['correctAnswer']?.toString() ??
                            _questionResult!['CorrectAnswer']?.toString();
    final isCorrect = _selectedAnswerId == correctAnswerId;
    // Backend có thể gửi statistics (lowercase) hoặc Statistics (PascalCase)
    final statistics = _questionResult!['statistics'] ?? _questionResult!['Statistics'] ?? {};

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: UtilsReponsive.height(40, context)),
                    // Icon và text chính
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: UtilsReponsive.height(120, context),
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: UtilsReponsive.height(24, context)),
                    TextConstant.titleH1(
                      context,
                      text: isCorrect ? "Đúng!" : "Sai!",
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      size: 56,
                    ),
                    SizedBox(height: UtilsReponsive.height(32, context)),
                    // Đáp án đúng
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(20, context)),
                      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextConstant.subTile2(
                            context,
                            text: "Đáp án đúng",
                            color: Colors.grey[600]!,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: UtilsReponsive.height(8, context)),
                          TextConstant.titleH3(
                            context,
                            text: _questionResult!['correctAnswerText'] ?? 
                                  _questionResult!['CorrectAnswerText'] ?? 
                                  '',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    // Statistics
                    if (statistics.isNotEmpty) ...[
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(20, context)),
                        padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextConstant.titleH3(
                              context,
                              text: "Thống kê",
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: UtilsReponsive.height(16, context)),
                            _buildStatRow(context, "Số người đúng",
                                "${statistics['correctCount'] ?? statistics['CorrectCount'] ?? 0}"),
                            SizedBox(height: UtilsReponsive.height(8, context)),
                            _buildStatRow(context, "Số người sai",
                                "${statistics['incorrectCount'] ?? statistics['IncorrectCount'] ?? 0}"),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: UtilsReponsive.height(40, context)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextConstant.subTile2(
            context,
            text: label,
            color: Colors.grey[600]!,
          ),
          TextConstant.subTile1(
            context,
            text: value,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      log('Leaderboard is null or empty');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.subTile1(
              context,
              text: "Đang tải leaderboard...",
              color: Colors.grey[600]!,
            ),
          ],
        ),
      );
    }
    
    log('Building leaderboard UI: ${_leaderboard!.length} players');

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          Container(
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
                  final isCurrentPlayer = playerName == _playerName;
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
                      color: isCurrentPlayer
                          ? ColorsManager.primary.withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentPlayer
                            ? ColorsManager.primary
                            : Colors.transparent,
                        width: 2,
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
                                fontWeight: isCurrentPlayer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
          ),
        ],
      ),
    );
  }

  Widget _buildGameEnd(BuildContext context) {
    if (_finalResult == null) {
      log('_buildGameEnd: _finalResult is null');
      return SizedBox();
    }

    log('_buildGameEnd: Building UI with _finalResult: ${_finalResult.toString()}');

    // Backend gửi finalRankings (camelCase) hoặc FinalRankings (PascalCase)
    // hoặc rankings/Rankings/players/Players (backward compatibility)
    final finalLeaderboard = List<Map<String, dynamic>>.from(
        _finalResult!['finalRankings'] ?? 
        _finalResult!['FinalRankings'] ?? 
        _finalResult!['rankings'] ?? 
        _finalResult!['Rankings'] ?? 
        _finalResult!['players'] ?? 
        _finalResult!['Players'] ?? []);
    
    // Backend có thể gửi winner (camelCase) hoặc Winner (PascalCase)
    final winner = _finalResult!['winner'] ?? _finalResult!['Winner'];
    
    log('_buildGameEnd: finalLeaderboard length: ${finalLeaderboard.length}');
    log('_buildGameEnd: finalLeaderboard data: ${finalLeaderboard.toString()}');
    log('_buildGameEnd: winner: ${winner.toString()}');

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(40, context)),
          Icon(Icons.celebration, size: 100, color: Colors.amber),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH1(
            context,
            text: "Game kết thúc!",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(32, context)),
          Container(
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
                TextConstant.titleH2(
                  context,
                  text: "Kết quả cuối cùng",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                // Hiển thị winner nếu có
                if (winner != null) ...[
                  SizedBox(height: UtilsReponsive.height(24, context)),
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                        SizedBox(width: UtilsReponsive.width(12, context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextConstant.subTile2(
                                context,
                                text: "Người chiến thắng",
                                color: Colors.grey[600]!,
                              ),
                              SizedBox(height: UtilsReponsive.height(4, context)),
                              TextConstant.titleH3(
                                context,
                                text: winner['playerName'] ?? 
                                      winner['PlayerName'] ?? 
                                      '',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              if (winner['totalScore'] != null || 
                                  winner['TotalScore'] != null)
                                TextConstant.subTile2(
                                  context,
                                  text: "${winner['totalScore'] ?? winner['TotalScore'] ?? 0} điểm",
                                  color: Colors.amber[700]!,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: UtilsReponsive.height(24, context)),
                ...finalLeaderboard.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  // Backend gửi playerName (camelCase) hoặc PlayerName (PascalCase)
                  final playerName = player['playerName'] ?? 
                                    player['PlayerName'] ?? 
                                    '';
                  final isCurrentPlayer = playerName == _playerName;
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
                      color: isCurrentPlayer
                          ? ColorsManager.primary.withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentPlayer
                            ? ColorsManager.primary
                            : Colors.transparent,
                        width: 2,
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
                                fontWeight: isCurrentPlayer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
          ),
          SizedBox(height: UtilsReponsive.height(32, context)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(16, context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: TextConstant.subTile1(
                context,
                text: "Quay lại",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH2(
            context,
            text: "Đã xảy ra lỗi",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primary,
            ),
            child: TextConstant.subTile1(
              context,
              text: "Quay lại",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

