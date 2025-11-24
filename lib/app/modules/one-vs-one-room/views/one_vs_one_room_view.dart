import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/service/one_vs_one_hub_service.dart';
import '../../home/models/create_one_vs_one_room_response.dart';

class OneVsOneRoomView extends StatefulWidget {
  const OneVsOneRoomView({super.key});

  @override
  State<OneVsOneRoomView> createState() => _OneVsOneRoomViewState();
}

enum OneVsOneRoomPhase {
  connecting,    // Đang kết nối SignalR
  waiting,       // Chờ Player2 join (Player1) hoặc chờ Player1 start (Player2)
  ready,         // Cả 2 đã sẵn sàng
  gameStarted,  // Game đã bắt đầu (countdown)
  question,      // Đang hiển thị câu hỏi
  roundResult,  // Hiển thị kết quả round
  gameEnd,       // Game kết thúc
  error,         // Lỗi
}

class _OneVsOneRoomViewState extends State<OneVsOneRoomView> {
  final OneVsOneHubService _hubService = OneVsOneHubService();
  bool _isConnecting = false;
  bool _isStartingGame = false;
  OneVsOneRoomPhase _currentPhase = OneVsOneRoomPhase.connecting;
  String? _roomPin;
  bool _isPlayer1 = false; // true nếu là Player1 (người tạo phòng)
  String? _player2Name; // Tên Player2 khi join
  
  // Game data
  int _totalQuestions = 0;
  int _currentQuestionIndex = 0;
  Map<String, dynamic>? _currentQuestion;
  int _timeRemaining = 0;
  Timer? _timer;
  String? _selectedAnswerId;
  bool _hasSubmittedAnswer = false;
  Map<String, dynamic>? _roundResult;
  Map<String, dynamic>? _finalResult;
  
  // Player info
  Map<String, dynamic>? _player1Info;
  Map<String, dynamic>? _player2Info;
  List<Map<String, dynamic>> _playersList = []; // List of all players for multiplayer
  int? _gameMode; // 0 = 1vs1, 1 = Multiplayer
  int? _maxPlayers;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    log('args: ${jsonEncode(args)}');
    // Nếu là OneVsOneRoomData (Player1 tạo phòng)
    if (args is OneVsOneRoomData) {
      _roomPin = args.roomPin;
      _isPlayer1 = true; // Người tạo phòng là Player1
    }
    // Nếu là Map (Player2 join)
    else if (args is Map<String, dynamic>) {
      _roomPin = args['roomPin'] as String?;
      _isPlayer1 = args['isPlayer1'] as bool? ?? false;
      _player2Name = args['playerName'] as String?;
    }
    
    _setupAudioPlayer();
    _connectToSignalR();
  }
  
  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
          if (state == PlayerState.playing || state == PlayerState.completed) {
            _isAudioLoading = false;
          }
        });
      }
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = false;
        });
      }
    });
  }
  
  Future<void> _playAudio() async {
    final audioUrl = _currentQuestion?['audioUrl'];
    if (audioUrl == null || audioUrl.toString().isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Không có audio cho câu hỏi này',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      setState(() {
        _isAudioLoading = true;
      });
      await _audioPlayer.play(UrlSource(audioUrl.toString()));
    } catch (e) {
      log('Error playing audio: $e');
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _isAudioPlaying = false;
        });
        Get.snackbar(
          'Lỗi',
          'Không thể phát audio. Vui lòng thử lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
  
  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
      if (mounted) {
        setState(() {
          _isAudioPlaying = false;
        });
      }
    } catch (e) {
      log('Error pausing audio: $e');
    }
  }
  
  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isAudioPlaying = false;
          _isAudioLoading = false;
        });
      }
    } catch (e) {
      log('Error stopping audio: $e');
    }
  }
  
  Future<void> _toggleAudio() async {
    if (_isAudioPlaying) {
      await _pauseAudio();
    } else {
      await _playAudio();
    }
  }

  void _connectToSignalR() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _currentPhase = OneVsOneRoomPhase.connecting;
    });

    try {
      const baseUrl = 'https://qul-api.onrender.com';
      
      final connected = await _hubService.connect(baseUrl);

      if (connected) {
        _setupSignalRListeners();
        
        if (_isPlayer1 && _roomPin != null) {
          // Player1 connect
          await _hubService.player1Connect(_roomPin!);
        } else if (!_isPlayer1 && _roomPin != null && _player2Name != null) {
          // Player join (Player2, Player3, ...)
          await _hubService.playerJoin(_roomPin!, _player2Name!);
        }
      } else {
        setState(() {
          _currentPhase = OneVsOneRoomPhase.error;
        });
      }
    } catch (e) {
      setState(() {
        _currentPhase = OneVsOneRoomPhase.error;
      });
      Get.snackbar(
        'Lỗi',
        'Lỗi khi kết nối: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _setupSignalRListeners() {
    _hubService.setupEventListeners(
      onConnected: () {
        // Connection established
      },
      onConnectionError: (error) {
        setState(() {
          _currentPhase = OneVsOneRoomPhase.error;
        });
        Get.snackbar('Lỗi', 'Không thể kết nối: $error',
            backgroundColor: Colors.red, colorText: Colors.white);
      },
      onConnectionClosed: (error) {
        // Connection closed
      },
      onPlayer1Connected: (data) {
        setState(() {
          _currentPhase = OneVsOneRoomPhase.waiting;
        });
        Get.snackbar('Thành công', 'Đã kết nối với tư cách Player1',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onPlayer2Joined: (data) {
        // @deprecated - use onPlayerJoined instead
        setState(() {
          _currentPhase = OneVsOneRoomPhase.waiting;
        });
        Get.snackbar('Thành công', 'Đã tham gia phòng!',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onPlayerJoined: (data) {
        // Cập nhật thông tin player (new event from Hub)
        log('PlayerJoined: ${data.toString()}');
        setState(() {
          _currentPhase = OneVsOneRoomPhase.waiting;
        });
        Get.snackbar('Thành công', 'Đã tham gia phòng!',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onPlayerJoinedRoom: (data) {
        // Event broadcast to all players when someone joins
        final playerName = data['playerName'] ?? '';
        log('PlayerJoinedRoom: $playerName joined');
        Get.snackbar('Thông báo', '$playerName đã tham gia phòng',
            backgroundColor: Colors.blue, colorText: Colors.white);
      },
      onRoomUpdated: (data) {
        setState(() {
          _player1Info = data['player1'];
          _player2Info = data['player2'];
          // New fields for multiplayer support
          // Parse Mode - có thể là số (0/1) hoặc string ("OneVsOne"/"Multiplayer")
          final modeValue = data['mode'];
          if (modeValue != null) {
            if (modeValue is int) {
              _gameMode = modeValue;
            } else if (modeValue is String) {
              final modeStr = modeValue.toString().toLowerCase();
              if (modeStr == 'Multiplayer' || modeStr.contains('Multi')) {
                _gameMode = 1;
              } else {
                _gameMode = 0; // OneVsOne
              }
            } else {
              _gameMode = int.tryParse(modeValue.toString());
            }
          }
          _maxPlayers = data['maxPlayers'];
          
          // Parse Players list if available (for multiplayer)
          if (data['players'] != null && data['players'] is List) {
            _playersList = List<Map<String, dynamic>>.from(
              (data['players'] as List).map((p) => Map<String, dynamic>.from(p))
            );
          } else {
            // Fallback to Player1/Player2 for 1vs1 mode
            _playersList = [];
            if (_player1Info != null) _playersList.add(_player1Info!);
            if (_player2Info != null) _playersList.add(_player2Info!);
          }
        });
        log('RoomUpdated: ${data.toString()}');
      },
      onRoomReady: (data) {
        setState(() {
          _player1Info = data['player1'];
          _player2Info = data['player2'];
          
          // Parse Mode - có thể là số (0/1) hoặc string ("OneVsOne"/"Multiplayer")
          final modeValue = data['mode'];
          if (modeValue != null) {
            if (modeValue is int) {
              _gameMode = modeValue;
            } else if (modeValue is String) {
              final modeStr = modeValue.toString().toLowerCase();
              if (modeStr == 'multiplayer' || modeStr.contains('multi')) {
                _gameMode = 1;
              } else {
                _gameMode = 0; // OneVsOne
              }
            } else {
              _gameMode = int.tryParse(modeValue.toString());
            }
          }
          
          // Parse Players list if available (for multiplayer)
          if (data['players'] != null && data['players'] is List) {
            _playersList = List<Map<String, dynamic>>.from(
              (data['players'] as List).map((p) => Map<String, dynamic>.from(p))
            );
          } else {
            // Fallback to Player1/Player2 for 1vs1 mode
            _playersList = [];
            if (_player1Info != null) _playersList.add(_player1Info!);
            if (_player2Info != null) _playersList.add(_player2Info!);
          }
          
          // Trong multiplayer mode, giữ phase = waiting để players khác vẫn có thể join
          // Chỉ chuyển sang ready trong 1vs1 mode (cần đúng 2 players)
          final isMultiplayer = _gameMode == 1 || 
                                (modeValue != null && modeValue.toString().toLowerCase().contains('multi'));
          
          if (isMultiplayer) {
            // Multiplayer: giữ waiting, chỉ Player1 mới thấy button start
            _currentPhase = OneVsOneRoomPhase.waiting;
            log('RoomReady: Multiplayer mode - keeping phase = waiting');
          } else {
            // 1vs1: chuyển sang ready khi đủ 2 players
            _currentPhase = OneVsOneRoomPhase.ready;
            log('RoomReady: 1vs1 mode - changing phase = ready');
          }
        });
        
        final playerCount = data['playerCount'] ?? _playersList.length;
        final isMultiplayer = _gameMode == 1 || 
                              (data['mode'] != null && data['mode'].toString().toLowerCase().contains('multi'));
        final message = isMultiplayer
            ? '$playerCount người chơi đã sẵn sàng! Bạn có thể bắt đầu game hoặc chờ thêm người chơi.'
            : 'Cả 2 người chơi đã sẵn sàng!';
        Get.snackbar('Thông báo', message,
            backgroundColor: Colors.blue, colorText: Colors.white);
      },
      onGameStarted: (data) {
        setState(() {
          _totalQuestions = data['totalQuestions'] ?? 0;
          _currentPhase = OneVsOneRoomPhase.gameStarted;
          _isStartingGame = false;
        });
        Get.snackbar('Thông báo', 'Game đã bắt đầu!',
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      onShowQuestion: (data) {
        log('ShowQuestion: ${data.toString()}');
        // Stop audio from previous question
        _stopAudio();
        setState(() {
          _currentQuestion = data;
          _currentQuestionIndex = data['questionNumber'] ?? 
                                 (data['questionIndex'] ?? 0) + 1;
          _totalQuestions = data['totalQuestions'] ?? _totalQuestions;
          _currentPhase = OneVsOneRoomPhase.question;
          _hasSubmittedAnswer = false;
          _selectedAnswerId = null;
          _timeRemaining = data['timeLimit'] ?? 30;
        });
        _startTimer();
      },
      onAnswerSubmitted: (data) {
        setState(() {
          _hasSubmittedAnswer = true;
        });
        
        // Show progress if multiplayer mode
        final answeredCount = data['answeredCount'];
        final totalPlayers = data['totalPlayers'];
        final message = data['message'] ?? '';
        
        if (answeredCount != null && totalPlayers != null && answeredCount < totalPlayers) {
          Get.snackbar('Thông báo', message,
              backgroundColor: Colors.blue, colorText: Colors.white);
        } else {
          Get.snackbar('Thành công', message.isNotEmpty ? message : 'Đã gửi câu trả lời!',
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      },
      onShowRoundResult: (data) {
        log('ShowRoundResult: ${data.toString()}');
        _timer?.cancel();
        setState(() {
          _roundResult = data;
          _currentPhase = OneVsOneRoomPhase.roundResult;
          // Reset để chuẩn bị cho câu hỏi tiếp theo
          _hasSubmittedAnswer = false;
          _selectedAnswerId = null;
        });
      },
      onGameEnded: (data) {
        _timer?.cancel();
        log('GameEnded: ${data.toString()}');
        setState(() {
          _finalResult = data;
          _currentPhase = OneVsOneRoomPhase.gameEnd;
        });
        Get.snackbar('Thông báo', 'Game đã kết thúc!',
            backgroundColor: Colors.orange, colorText: Colors.white);
      },
      onRoomCancelled: (data) {
        Get.snackbar('Thông báo', 'Phòng đã bị hủy',
            backgroundColor: Colors.orange, colorText: Colors.white);
        Get.back();
      },
      onPlayerDisconnected: (data) {
        Get.snackbar('Thông báo', 'Đối thủ đã rời phòng',
            backgroundColor: Colors.orange, colorText: Colors.white);
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

  Future<void> _startGame() async {
    if (_isStartingGame || _roomPin == null || !_isPlayer1) return;

    setState(() {
      _isStartingGame = true;
    });

    try {
      await _hubService.startGame(_roomPin!);
    } catch (e) {
      setState(() {
        _isStartingGame = false;
      });
      Get.snackbar('Lỗi', 'Không thể bắt đầu game: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswerId == null || _currentQuestion == null || _roomPin == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn đáp án',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_hasSubmittedAnswer) {
      return;
    }

    try {
      final questionId = _currentQuestion!['questionId']?.toString() ?? '';
      
      await _hubService.submitAnswer(_roomPin!, questionId, _selectedAnswerId!);
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gửi câu trả lời: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _hubService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "1 vs 1 Room",
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
      case OneVsOneRoomPhase.connecting:
        return _buildConnecting(context);
      case OneVsOneRoomPhase.waiting:
        return _buildWaiting(context);
      case OneVsOneRoomPhase.ready:
        return _buildReady(context);
      case OneVsOneRoomPhase.gameStarted:
        return _buildGameStarted(context);
      case OneVsOneRoomPhase.question:
        return _buildQuestion(context);
      case OneVsOneRoomPhase.roundResult:
        return _buildRoundResult(context);
      case OneVsOneRoomPhase.gameEnd:
        return _buildGameEnd(context);
      case OneVsOneRoomPhase.error:
        return _buildError(context);
    }
  }

  Widget _buildConnecting(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsManager.primary),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.subTile1(
            context,
            text: "Đang kết nối...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildWaiting(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Room PIN (chỉ hiển thị cho Player1)
          if (_isPlayer1 && _roomPin != null) ...[
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
                    text: "Room PIN",
                    color: Colors.grey[600]!,
                  ),
                  SizedBox(height: UtilsReponsive.height(12, context)),
                  TextConstant.titleH1(
                    context,
                    text: _roomPin!,
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                    size: 48,
                  ),
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _roomPin!));
                      Get.snackbar('Thành công', 'Đã copy PIN',
                          backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    icon: Icon(Icons.copy, color: ColorsManager.primary),
                    label: TextConstant.subTile2(
                      context,
                      text: "Copy PIN",
                      color: ColorsManager.primary,
                    ),
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
                    data: _roomPin!,
                    version: QrVersions.auto,
                    size: UtilsReponsive.width(250, context),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: UtilsReponsive.height(32, context)),
          ],
          
          // Players info
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
                TextConstant.titleH3(
                  context,
                  text: "Người chơi",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                // Display players list (supports both 1vs1 and multiplayer)
                if (_playersList.isNotEmpty) ...[
                  ..._playersList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final isHost = player['isHost'] ?? false;
                    final playerLabel = isHost 
                        ? "Host" 
                        : (_gameMode == 1 ? "Player ${index + 1}" : (index == 0 ? "Player 1" : "Player 2"));
                    final color = isHost 
                        ? Colors.purple 
                        : (index == 0 ? Colors.blue : Colors.orange);
                    
                    return Column(
                      children: [
                        if (index > 0)
                          SizedBox(height: UtilsReponsive.height(12, context)),
                        _buildPlayerInfo(context, player, playerLabel, color),
                      ],
                    );
                  }),
                  // Show waiting message if not enough players
                  if (_gameMode == 0 && _playersList.length < 2) ...[
                    SizedBox(height: UtilsReponsive.height(12, context)),
                    Padding(
                      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                      child: TextConstant.subTile2(
                        context,
                        text: "Đang chờ Player 2...",
                        color: Colors.grey[600]!,
                      ),
                    ),
                  ] else if (_gameMode == 1) ...[
                    // Multiplayer mode: luôn hiển thị thông báo (có thể start với 2+ players)
                    SizedBox(height: UtilsReponsive.height(12, context)),
                    Padding(
                      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                      child: Column(
                        children: [
                          TextConstant.subTile2(
                            context,
                            text: _maxPlayers != null && _playersList.length < _maxPlayers!
                                ? "Đang chờ thêm người chơi... (${_playersList.length}/$_maxPlayers)"
                                : "${_playersList.length} người chơi đã tham gia",
                            color: Colors.grey[600]!,
                          ),
                          if (_isPlayer1 && _playersList.length >= 2) ...[
                            SizedBox(height: UtilsReponsive.height(8, context)),
                            TextConstant.subTile3(
                              context,
                              text: "Bạn có thể bắt đầu game ngay hoặc chờ thêm người chơi",
                              color: Colors.blue,
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  // Fallback: show Player1/Player2 if Players list not available
                  if (_player1Info != null)
                    _buildPlayerInfo(context, _player1Info!, "Player 1", Colors.blue),
                  if (_player1Info != null && _player2Info != null)
                    SizedBox(height: UtilsReponsive.height(12, context)),
                  if (_player2Info != null)
                    _buildPlayerInfo(context, _player2Info!, "Player 2", Colors.orange)
                  else
                    Padding(
                      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                      child: TextConstant.subTile2(
                        context,
                        text: "Đang chờ Player 2...",
                        color: Colors.grey[600]!,
                      ),
                    ),
                ],
              ],
            ),
          ),
          
          // Start Game Button (hiển thị trong waiting phase nếu multiplayer và đã có >= 2 players)
          if (_isPlayer1 && _gameMode == 1 && _playersList.length >= 2) ...[
            SizedBox(height: UtilsReponsive.height(32, context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isStartingGame ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(16, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isStartingGame
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          TextConstant.subTile1(
                            context,
                            text: "Bắt đầu game (${_playersList.length} người chơi)",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context, Map<String, dynamic> player, String label, Color color) {
    final playerName = player['playerName'] ?? '';
    final score = player['score'] ?? 0;
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextConstant.subTile1(
              context,
              text: label,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: TextConstant.subTile1(
              context,
              text: playerName,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextConstant.subTile1(
            context,
            text: "$score điểm",
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(40, context)),
          Icon(Icons.check_circle, size: 100, color: Colors.green),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH1(
            context,
            text: "Sẵn sàng!",
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.subTile1(
            context,
            text: "Cả 2 người chơi đã sẵn sàng",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(32, context)),
          if (_isPlayer1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isStartingGame ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(16, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isStartingGame
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          TextConstant.subTile1(
                            context,
                            text: "Bắt đầu game",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
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
          Icon(Icons.play_circle_filled, size: 100, color: ColorsManager.primary),
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
      return Center(child: CircularProgressIndicator());
    }

    final question = _currentQuestion!;
    log('Building question UI: ${question.toString()}');
    
    final answers = List<Map<String, dynamic>>.from(
      question['answerOptions'] ?? question['options'] ?? []
    );
    
    log('Answers parsed: ${answers.length} answers found');
    for (var i = 0; i < answers.length; i++) {
      log('Answer $i: ${answers[i].toString()}');
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
                        color: _timeRemaining <= 5 ? Colors.red : ColorsManager.primary,
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
                  text: question['questionText'] ?? '',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                
                // Audio player (if available)
                if ((question['audioUrl'] ?? question['audioUrl']) != null &&
                    (question['audioUrl'] ?? question['audioUrl']).toString().isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: UtilsReponsive.height(16, context)),
                    child: _buildAudioPlayer(context),
                  ),
                
                // Image (if available)
                if ((question['imageUrl'] ?? question['imageUrl']) != null &&
                    (question['imageUrl'] ?? question['imageUrl']).toString().isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: UtilsReponsive.height(16, context)),
                    child: _buildImage(context, question),
                  ),
              ],
            ),
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Answers
          ...answers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            final answerId = answer['answerId']?.toString() ?? '';
            final isSelected = _selectedAnswerId == answerId;
            final answerLabels = ['A', 'B', 'C', 'D'];
            
            // Parse optionText với nhiều field names khác nhau
            final optionText = answer['optionText'] ?? 
                             answer['answerText'] ??
                             answer['text'] ??
                             '';
            
            log('Answer $index: answerId=$answerId, optionText="$optionText"');

            return Container(
              margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasSubmittedAnswer ? null : () {
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
                        color: isSelected ? ColorsManager.primary : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: UtilsReponsive.width(40, context),
                          height: UtilsReponsive.width(40, context),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorsManager.primary : Colors.grey[300],
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
                            text: optionText.isNotEmpty 
                                ? optionText 
                                : 'Option ${answerLabels[index]}',
                            color: Colors.black,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: ColorsManager.primary),
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

  Widget _buildAudioPlayer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: ColorsManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleAudio,
            child: Container(
              padding: EdgeInsets.all(UtilsReponsive.width(4, context)),
              child: _isAudioLoading
                  ? SizedBox(
                      width: UtilsReponsive.height(24, context),
                      height: UtilsReponsive.height(24, context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorsManager.primary,
                      ),
                    )
                  : Icon(
                      _isAudioPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: ColorsManager.primary,
                      size: UtilsReponsive.height(32, context),
                    ),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile3(
                  context,
                  text: _isAudioPlaying
                      ? "Đang phát audio..."
                      : "Nhấn để phát audio",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.w600,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, Map<String, dynamic> question) {
    final imageUrl = question['imageUrl'];
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: UtilsReponsive.height(300, context),
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl.toString(),
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            height: UtilsReponsive.height(200, context),
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                color: ColorsManager.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: UtilsReponsive.height(200, context),
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: UtilsReponsive.height(48, context),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile3(
                  context,
                  text: "Không thể tải hình ảnh",
                  color: Colors.grey[600]!,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundResult(BuildContext context) {
    if (_roundResult == null) {
      return Center(child: CircularProgressIndicator());
    }

    log('Building round result UI: ${_roundResult.toString()}');
    
    final correctAnswerText = _roundResult!['correctAnswerText'] ?? '';
    
    // Check if multiplayer mode (has playerResults list)
    final playerResults = _roundResult!['playerResults'] ?? _roundResult!['playersResults'];
    final isMultiplayer = playerResults != null && playerResults is List && playerResults.length > 2;
    
    // Find current player's result
    Map<String, dynamic>? currentPlayerResult;
    List<Map<String, dynamic>> allPlayersResults = [];
    
    if (playerResults != null && playerResults is List && playerResults.isNotEmpty) {
      // Parse từ playerResults list (ưu tiên - có pointsEarned)
      allPlayersResults = List<Map<String, dynamic>>.from(
        playerResults.map((p) => Map<String, dynamic>.from(p))
      );
      
      // Find current player by name or index
      if (_isPlayer1 && allPlayersResults.isNotEmpty) {
        currentPlayerResult = allPlayersResults.firstWhere(
          (p) => (p['playerName'] ?? '').toString().contains('Player1') || p == allPlayersResults[0],
          orElse: () => allPlayersResults[0],
        );
      } else if (!_isPlayer1 && allPlayersResults.length > 1) {
        // Find current player (not Player1)
        currentPlayerResult = allPlayersResults.firstWhere(
          (p) => (p['playerName'] ?? '').toString() != 'Player1' && p != allPlayersResults[0],
          orElse: () => allPlayersResults.length > 1 ? allPlayersResults[1] : allPlayersResults[0],
        );
      } else {
        currentPlayerResult = allPlayersResults.isNotEmpty ? allPlayersResults[0] : {};
      }
      
      // Sort by pointsEarned (descending) - điểm của round này
      allPlayersResults.sort((a, b) {
        final pointsA = a['pointsEarned'] ?? a['score'] ?? 0;
        final pointsB = b['pointsEarned'] ?? b['score'] ?? 0;
        return pointsB.compareTo(pointsA);
      });
    } else {
      // Fallback: use player1Result and player2Result
      final player1Result = _roundResult!['player1Result'] ?? {};
      final player2Result = _roundResult!['player2Result'] ?? {};
      
      currentPlayerResult = _isPlayer1 ? player1Result : player2Result;
      allPlayersResults = [
        if (player1Result.isNotEmpty) player1Result,
        if (player2Result.isNotEmpty) player2Result,
      ];
      
      // Sort by pointsEarned (descending)
      allPlayersResults.sort((a, b) {
        final pointsA = a['pointsEarned'] ?? a['score'] ?? 0;
        final pointsB = b['pointsEarned'] ?? b['score'] ?? 0;
        return pointsB.compareTo(pointsA);
      });
    }
    
    final currentPlayerName = currentPlayerResult?['playerName'] ?? (_isPlayer1 ? 'Player1' : 'Player2');
    // Parse pointsEarned (điểm của round này) thay vì score (tổng điểm)
    final currentPlayerScore = currentPlayerResult?['pointsEarned'] ?? currentPlayerResult?['score'] ?? 0;
    final currentPlayerIsCorrect = currentPlayerResult?['isCorrect'] ?? false;
    
    // Check if current player is winner (highest pointsEarned or tied with highest)
    final highestScore = allPlayersResults.isNotEmpty 
        ? (allPlayersResults[0]['pointsEarned'] ?? allPlayersResults[0]['score'] ?? 0)
        : 0;
    final isCurrentPlayerWinner = currentPlayerScore >= highestScore;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Result Header
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
                Icon(
                  currentPlayerIsCorrect ? Icons.check_circle : Icons.cancel,
                  size: UtilsReponsive.height(80, context),
                  color: currentPlayerIsCorrect ? Colors.green : Colors.red,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH1(
                  context,
                  text: currentPlayerIsCorrect ? "Đúng!" : "Sai!",
                  color: currentPlayerIsCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile2(
                  context,
                  text: "Câu $_currentQuestionIndex/$_totalQuestions",
                  color: Colors.grey[600]!,
                ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Correct Answer
          if (correctAnswerText.isNotEmpty)
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
                  TextConstant.subTile2(
                    context,
                    text: "Đáp án đúng",
                    color: Colors.grey[600]!,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: UtilsReponsive.height(8, context)),
                  TextConstant.titleH3(
                    context,
                    text: correctAnswerText,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Players Comparison
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
                TextConstant.titleH3(
                  context,
                  text: isMultiplayer ? "Bảng xếp hạng round" : "Kết quả round",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(20, context)),
                
                // Display all players (sorted by pointsEarned)
                ...allPlayersResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final playerResult = entry.value;
                  final playerName = playerResult['playerName'] ?? 'Player ${index + 1}';
                  // Parse pointsEarned (điểm của round này) thay vì score
                  final playerScore = playerResult['pointsEarned'] ?? playerResult['score'] ?? 0;
                  final playerIsCorrect = playerResult['isCorrect'] ?? false;
                  final isCurrentPlayer = playerName == currentPlayerName;
                  final isTopPlayer = index == 0 && playerScore == highestScore;
                  
                  return Column(
                    children: [
                      if (index > 0)
                        SizedBox(height: UtilsReponsive.height(12, context)),
                      _buildPlayerResultCard(
                        context,
                        playerName,
                        playerScore,
                        playerIsCorrect,
                        isCurrentPlayer,
                        isTopPlayer: isTopPlayer,
                        rank: index + 1,
                      ),
                    ],
                  );
                }),
                
                SizedBox(height: UtilsReponsive.height(20, context)),
                
                // Winner indicator
                if (isCurrentPlayerWinner && currentPlayerScore == highestScore)
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.green),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: isMultiplayer ? "Bạn đứng đầu!" : "Bạn dẫn đầu!",
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  )
                else if (currentPlayerScore < highestScore)
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_down, color: Colors.orange),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: isMultiplayer ? "Có người chơi khác dẫn đầu" : "Đối thủ dẫn đầu",
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  )
                else if (currentPlayerScore == highestScore && allPlayersResults.where((p) => (p['pointsEarned'] ?? p['score'] ?? 0) == highestScore).length > 1)
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.equalizer, color: Colors.blue),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: "Hòa!",
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Waiting for next question
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: UtilsReponsive.height(20, context),
                  height: UtilsReponsive.height(20, context),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                TextConstant.subTile1(
                  context,
                  text: "Đang chờ câu hỏi tiếp theo...",
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(20, context)),
        ],
      ),
    );
  }

  Widget _buildPlayerResultCard(
    BuildContext context,
    String playerName,
    int score,
    bool isCorrect,
    bool isCurrentPlayer, {
    bool isTopPlayer = false,
    int? rank,
  }) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? ColorsManager.primary.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? ColorsManager.primary
              : Colors.grey[300]!,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge (for multiplayer)
          if (rank != null && isTopPlayer)
            Container(
              margin: EdgeInsets.only(right: UtilsReponsive.width(12, context)),
              padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.emoji_events, color: Colors.white, size: UtilsReponsive.height(20, context)),
            )
          else if (rank != null)
            Container(
              margin: EdgeInsets.only(right: UtilsReponsive.width(12, context)),
              width: UtilsReponsive.width(32, context),
              height: UtilsReponsive.width(32, context),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TextConstant.subTile1(
                  context,
                  text: "$rank",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Status Icon
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: Colors.white,
              size: UtilsReponsive.height(20, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Player Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile1(
                  context,
                  text: playerName,
                  color: Colors.black,
                  fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.w500,
                ),
                if (isCurrentPlayer)
                  TextConstant.subTile4(
                    context,
                    text: "Bạn",
                    color: ColorsManager.primary,
                    size: 10,
                  ),
              ],
            ),
          ),
          
          // Score
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.width(12, context),
              vertical: UtilsReponsive.height(6, context),
            ),
            decoration: BoxDecoration(
              color: isCurrentPlayer ? ColorsManager.primary : (isTopPlayer ? Colors.amber : Colors.grey[300]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextConstant.subTile1(
              context,
              text: "$score điểm",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEnd(BuildContext context) {
    if (_finalResult == null) {
      return Center(child: CircularProgressIndicator());
    }

    log('Building game end UI: ${_finalResult.toString()}');
    
    // Parse data từ backend - ưu tiên rankings list (cho multiplayer)
    final rankings = _finalResult!['rankings'];
    final winner = _finalResult!['winner'];
    final mode = _finalResult!['mode'] ?? 0;
    final isMultiplayer = mode == 1;
    
    List<Map<String, dynamic>> allPlayersResults = [];
    Map<String, dynamic>? currentPlayerResult;
    
    if (rankings != null && rankings is List && rankings.isNotEmpty) {
      // Parse từ rankings list (đúng cho cả 1vs1 và multiplayer)
      allPlayersResults = List<Map<String, dynamic>>.from(
        rankings.map((p) => Map<String, dynamic>.from(p))
      );
      
      // Sort by score descending
      allPlayersResults.sort((a, b) {
        final scoreA = a['score'] ?? 0;
        final scoreB = b['score'] ?? 0;
        return scoreB.compareTo(scoreA);
      });
      
      // Find current player - try to match by userId or connectionId
      // For now, use _isPlayer1 to determine (first player is Player1)
      if (_isPlayer1 && allPlayersResults.isNotEmpty) {
        currentPlayerResult = allPlayersResults.firstWhere(
          (p) => p['playerName'] == 'Player1' || p == allPlayersResults[0],
          orElse: () => allPlayersResults[0],
        );
      } else {
        // Find current player (not the first one, or match by name)
        currentPlayerResult = allPlayersResults.firstWhere(
          (p) => p != allPlayersResults[0],
          orElse: () => allPlayersResults.isNotEmpty ? allPlayersResults[0] : {},
        );
      }
    } else {
      // Fallback: parse từ player1/player2 (backward compatibility)
      final player1Result = _finalResult!['player1'] ?? _finalResult!['player1Result'] ?? {};
      final player2Result = _finalResult!['player2'] ?? _finalResult!['player2Result'] ?? {};
      
      currentPlayerResult = _isPlayer1 ? player1Result : player2Result;
      allPlayersResults = [
        if (player1Result.isNotEmpty) player1Result,
        if (player2Result.isNotEmpty) player2Result,
      ];
      
      // Sort by score
      allPlayersResults.sort((a, b) {
        final scoreA = a['score'] ?? 0;
        final scoreB = b['score'] ?? 0;
        return scoreB.compareTo(scoreA);
      });
    }
    
    // Get current player info (for winner determination)
    final currentPlayerName = currentPlayerResult?['playerName'] ?? (_isPlayer1 ? 'Player1' : 'Player2');
    final currentPlayerUserId = currentPlayerResult?['userId'] ?? '';
    
    // Get highest score
    final highestScore = allPlayersResults.isNotEmpty 
        ? (allPlayersResults[0]['score'] ?? 0)
        : 0;
    
    // Determine winner using winner object or score comparison
    final winnerName = winner != null 
        ? (winner['playerName'] ?? '')
        : (allPlayersResults.isNotEmpty ? (allPlayersResults[0]['playerName'] ?? '') : '');
    
    final winnerUserId = winner != null
        ? (winner['userId'] ?? '')
        : (allPlayersResults.isNotEmpty ? (allPlayersResults[0]['userId'] ?? '') : '');
    
    // Check if current player is winner
    final isCurrentPlayerWinner = winnerUserId.isNotEmpty && currentPlayerUserId == winnerUserId;
    final isDraw = winner == null && allPlayersResults.where((p) => (p['score'] ?? 0) == highestScore).length > 1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        children: [
          SizedBox(height: UtilsReponsive.height(40, context)),
          
          // Winner Badge
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber,
                  Colors.orange,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.emoji_events, size: 100, color: Colors.white),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH2(
                  context,
                  text: isDraw ? "Hòa!" : (isCurrentPlayerWinner ? "Bạn thắng!" : "Bạn thua"),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                if (!isDraw) ...[
                  SizedBox(height: UtilsReponsive.height(8, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Người chiến thắng: $winnerName",
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(32, context)),
          
          // Final Results
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
                  text: isMultiplayer ? "Bảng xếp hạng cuối cùng" : "Kết quả cuối cùng",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Display all players (sorted by score)
                ...allPlayersResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final playerResult = entry.value;
                  final playerName = playerResult['playerName'] ?? 'Player ${index + 1}';
                  final playerScore = playerResult['score'] ?? 0;
                  final playerCorrectAnswers = playerResult['correctAnswers'] ?? 0;
                  final playerUserId = playerResult['userId'] ?? '';
                  
                  final isCurrentPlayer = playerUserId == currentPlayerUserId || playerName == currentPlayerName;
                  final isWinner = playerUserId == winnerUserId || (index == 0 && playerScore == highestScore);
                  
                  return Column(
                    children: [
                      if (index > 0)
                        SizedBox(height: UtilsReponsive.height(16, context)),
                      _buildFinalPlayerCard(
                        context,
                        playerName,
                        playerScore,
                        playerCorrectAnswers,
                        _totalQuestions,
                        isCurrentPlayer,
                        isWinner && !isDraw,
                        rank: index + 1,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(32, context)),
          
          // Action Button
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
          
          SizedBox(height: UtilsReponsive.height(20, context)),
        ],
      ),
    );
  }

  Widget _buildFinalPlayerCard(
    BuildContext context,
    String playerName,
    int totalScore,
    int correctAnswers,
    int totalQuestions,
    bool isCurrentPlayer,
    bool isWinner, {
    int? rank,
  }) {
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? ColorsManager.primary.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? ColorsManager.primary
              : (isWinner ? Colors.amber : Colors.grey[300]!),
          width: isCurrentPlayer || isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank badge or Winner Badge
              if (rank != null && isWinner)
                Container(
                  margin: EdgeInsets.only(right: UtilsReponsive.width(12, context)),
                  padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emoji_events, color: Colors.white, size: UtilsReponsive.height(20, context)),
                )
              else if (rank != null)
                Container(
                  margin: EdgeInsets.only(right: UtilsReponsive.width(12, context)),
                  width: UtilsReponsive.width(32, context),
                  height: UtilsReponsive.width(32, context),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextConstant.subTile1(
                      context,
                      text: "$rank",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isWinner)
                Container(
                  margin: EdgeInsets.only(right: UtilsReponsive.width(12, context)),
                  padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emoji_events, color: Colors.white, size: UtilsReponsive.height(20, context)),
                ),
              
              // Player Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.titleH3(
                      context,
                      text: playerName,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    if (isCurrentPlayer)
                      TextConstant.subTile4(
                        context,
                        text: "Bạn",
                        color: ColorsManager.primary,
                        size: 10,
                      ),
                  ],
                ),
              ),
              
              // Total Score
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(16, context),
                  vertical: UtilsReponsive.height(8, context),
                ),
                decoration: BoxDecoration(
                  color: isCurrentPlayer ? ColorsManager.primary : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextConstant.titleH3(
                  context,
                  text: "$totalScore",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  "Đúng",
                  "$correctAnswers/$totalQuestions",
                  Colors.green,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              Expanded(
                child: _buildStatItem(
                  context,
                  "Độ chính xác",
                  "$accuracy%",
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextConstant.subTile1(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile4(
            context,
            text: label,
            color: Colors.grey[600]!,
            size: 10,
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

