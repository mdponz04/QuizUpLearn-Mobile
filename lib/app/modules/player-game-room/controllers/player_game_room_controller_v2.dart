import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../service/game_hub_service_v2.dart';

/// PlayerGameRoomController V2 - Improved version based on Web app structure
/// 
/// Key improvements:
/// - Better state management (GetX observables)
/// - Cleaner separation of concerns
/// - Improved error handling
/// - Auto-next question with 2-second delay
/// - Better Boss Fight mode support
class PlayerGameRoomControllerV2 extends GetxController {
  final GameHubServiceV2 _gameHub = GameHubServiceV2();
  final TextEditingController playerNameController = TextEditingController();

  // ==================== GAME PHASE ====================
  // 'enteringPin' → 'connecting' → 'lobby' → 'countdown' → 'playing' → 'answered' → 'finalResult'
  final RxString gamePhase = 'enteringPin'.obs;

  // ==================== CONNECTION STATES ====================
  final RxBool isLoading = false.obs; // Start as false, only true when actually connecting
  final Rxn<String> errorMessage = Rxn<String>();
  final RxString connectionStatus = 'disconnected'.obs;

  // ==================== GAME SESSION DATA ====================
  final Rxn<Map<String, dynamic>> gameSession = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> players = <Map<String, dynamic>>[].obs;
  final RxInt totalPlayers = 0.obs;

  // ==================== GAME STATES ====================
  final RxInt countdownValue = 3.obs;
  final Rxn<Map<String, dynamic>> currentQuestion = Rxn<Map<String, dynamic>>();
  final RxInt timeLeft = 30.obs;
  final Rxn<String> selectedAnswerId = Rxn<String>();
  final RxBool isAnswerSubmitted = false.obs;

  // ==================== BOSS FIGHT MODE ====================
  // TODO: Hard code Boss Fight mode cho multi player
  // Tạm thời set true để luôn dùng Boss Fight flow
  final RxBool isBossFightMode = true.obs; // Hard code: true cho multi player
  final RxBool isPerPlayerFlow = true.obs; // Hard code: true cho per-player flow
  final RxInt bossMaxHP = 10000.obs;
  final RxInt bossCurrentHP = 10000.obs;
  final RxInt totalDamageDealt = 0.obs;
  final RxInt myDamageDealt = 0.obs;
  final RxInt lastDamage = 0.obs;
  final RxBool showDamageEffect = false.obs;
  final RxBool bossDefeated = false.obs;
  final Rxn<List<Map<String, dynamic>>> damageLeaderboard = Rxn<List<Map<String, dynamic>>>();
  final Rxn<Map<String, dynamic>> lobbySettings = Rxn<Map<String, dynamic>>();

  // Match timer
  final Rxn<int> matchTimeRemaining = Rxn<int>();
  final Rxn<int> matchTotalTime = Rxn<int>();
  DateTime? matchStartTime;

  // Question time limit
  final RxInt questionTimeLimitSeconds = 30.obs;

  // ==================== RESULTS ====================
  final Rxn<Map<String, dynamic>> lastAnswerResult = Rxn<Map<String, dynamic>>();
  final RxInt myScore = 0.obs;
  final RxInt myCorrectAnswers = 0.obs;
  final RxInt myTotalAnswered = 0.obs;
  final Rxn<Map<String, dynamic>> finalResult = Rxn<Map<String, dynamic>>();

  // ==================== GROUP ITEM (TOEIC) ====================
  final Rxn<Map<String, dynamic>> currentGroupItem = Rxn<Map<String, dynamic>>();

  // ==================== TIMERS ====================
  Timer? _questionTimer;
  Timer? _autoNextTimer;
  Timer? _matchTimer;

  // ==================== GAME PIN & PLAYER NAME ====================
  String? gamePin;
  String? playerName;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false; // Ensure loading is false when entering
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      gamePin = args['gamePin'] as String?;
      playerName = args['playerName'] as String?;
      // Nếu đã có playerName từ args, set vào controller
      if (playerName != null) {
        playerNameController.text = playerName!;
      }
    }
    // Nếu không có gamePin hoặc playerName, giữ phase là enteringPin
    if (gamePin == null || playerName == null || playerName!.isEmpty) {
      gamePhase.value = 'enteringPin';
      isLoading.value = false; // Ensure not loading when waiting for input
    }

    // Clean up auto-next timer when phase changes (giống Web app useEffect)
    // Web app: useEffect(() => { if (gamePhase !== 'answered' && autoNextTimerRef.current) { clearTimeout(...) } }, [gamePhase])
    ever(gamePhase, (String phase) {
      if (phase != 'answered' && _autoNextTimer != null) {
        log('🧹 Cleaning up auto-next timer (phase changed to: $phase)');
        _autoNextTimer?.cancel();
        _autoNextTimer = null;
      }
    });
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    _autoNextTimer?.cancel();
    _matchTimer?.cancel();
    playerNameController.dispose();
    _gameHub.dispose();
    super.onClose();
  }

  // ==================== CONNECTION ====================

  /// Connect to SignalR and join game
  Future<void> connectAndJoin(String baseUrl) async {
    // Validate inputs
    if (gamePin == null || gamePin!.isEmpty) {
      errorMessage.value = 'Vui lòng nhập Game PIN';
      return;
    }

    final name = playerNameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = 'Vui lòng nhập tên người chơi';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      connectionStatus.value = 'connecting';
      gamePhase.value = 'connecting';
      playerName = name; // Lưu tên đã nhập

      // Connect to SignalR
      final connected = await _gameHub.connect(baseUrl);
      if (!connected) {
        errorMessage.value = 'Không thể kết nối đến server';
        connectionStatus.value = 'error';
        isLoading.value = false;
        gamePhase.value = 'error';
        return;
      }

      // Setup event listeners
      _setupEventListeners();

      // Join game
      if (gamePin != null && playerName != null) {
        log('📤 Joining game V2: gamePin=$gamePin, playerName=$playerName');
        await _gameHub.joinGame(gamePin!, playerName!);
        log('📤 JoinGame called, waiting for JoinedGame event...');
      } else {
        log('⚠️ Cannot join game: gamePin=$gamePin, playerName=$playerName');
        errorMessage.value = 'Thiếu thông tin game PIN hoặc tên người chơi';
        connectionStatus.value = 'error';
        isLoading.value = false;
        gamePhase.value = 'error';
      }
    } catch (e) {
      log('Error connecting V2: $e');
      errorMessage.value = e.toString();
      connectionStatus.value = 'error';
      isLoading.value = false;
      gamePhase.value = 'error';
    }
  }

  // ==================== EVENT LISTENERS SETUP ====================

  void _setupEventListeners() {
    log('🔧 Setting up event listeners V2 in controller...');
    _gameHub.setupEventListeners(
      onConnected: () {
        connectionStatus.value = 'connected';
      },
      onConnectionError: (error) {
        errorMessage.value = error;
        connectionStatus.value = 'error';
        isLoading.value = false;
      },
      onConnectionClosed: (error) {
        connectionStatus.value = 'disconnected';
      },
      onJoinedGame: (data) {
        log('✅ onJoinedGame received V2: ${data.toString()}');
        isLoading.value = false;
        connectionStatus.value = 'connected';
        gamePhase.value = 'lobby';
        errorMessage.value = null;
        log('✅ Game phase updated to: lobby');
      },
      onLobbyUpdated: (data) {
        final playerList = data['players'] ?? data['Players'] ?? [];
        if (playerList is List) {
          players.value = List<Map<String, dynamic>>.from(
            playerList.map((p) => p is Map ? Map<String, dynamic>.from(p) : {}),
          );
        }
        totalPlayers.value = data['totalPlayers'] ?? data['TotalPlayers'] ?? players.length;
      },
      onPlayerJoined: (data) {
        // Handle new player joined
      },
      onGameStarted: (data) {
        gamePhase.value = 'countdown';
        countdownValue.value = 3;

        // Set Boss Fight mode info
        if (data['isBossFightMode'] ?? data['IsBossFightMode'] ?? false) {
          isBossFightMode.value = true;
          bossMaxHP.value = data['bossMaxHP'] ?? data['BossMaxHP'] ?? 10000;
          bossCurrentHP.value = data['bossCurrentHP'] ?? data['BossCurrentHP'] ?? 10000;
        }

        // Set match timer
        final totalMatchTime = data['gameTimeLimitSeconds'] ?? 
                              data['GameTimeLimitSeconds'] ?? 
                              600; // default 10 mins
        matchTotalTime.value = totalMatchTime;
        matchStartTime = DateTime.now();
        matchTimeRemaining.value = totalMatchTime;

        // Countdown animation
        _startCountdown();
      },
      onShowQuestion: (data) {
        // Skip if per-player flow (will receive via PlayerQuestion)
        if (isBossFightMode.value && isPerPlayerFlow.value) {
          return;
        }
        _handleShowQuestion(data);
      },
      onAnswerSubmitted: (data) {
        isAnswerSubmitted.value = true;
        log('📝 AnswerSubmitted received V2: ${data.toString()}');
        
        // Fallback: Nếu không nhận được BossFightAnswerResult sau 1 giây, 
        // tự động set phase = 'answered' để trigger auto-next question
        // (Giống Web app: nếu không có BossFightAnswerResult, vẫn cần request next question)
        if (isBossFightMode.value && isPerPlayerFlow.value) {
          Timer(const Duration(seconds: 1), () {
            // Nếu sau 1 giây vẫn chưa có result, tự động chuyển sang answered phase
            // để trigger auto-next question (giống Web app logic)
            if (lastAnswerResult.value == null && gamePhase.value == 'playing') {
              log('⚠️ BossFightAnswerResult not received after 1s, using fallback to trigger next question');
              // Tạo result tạm thời để show UI
              lastAnswerResult.value = {
                'isCorrect': false, // Không biết đúng/sai nếu không có result
                'pointsEarned': 0,
                'correctAnswerId': null,
                'correctAnswerText': '',
              };
              gamePhase.value = 'answered';
            }
          });
        }
      },
      onShowAnswerResult: (data) {
        // Normal mode: show result
        // Note: Normal mode doesn't auto-request next question
        // Host controls the flow
        
        // Nếu là Boss Fight per-player flow và chưa có result, có thể dùng ShowAnswerResult
        if (isBossFightMode.value && isPerPlayerFlow.value && lastAnswerResult.value == null) {
          // Tìm result của player này
          final playerResults = data['playerResults'] ?? data['PlayerResults'] ?? [];
          if (playerResults is List) {
            for (var pr in playerResults) {
              final pName = pr['playerName'] ?? pr['PlayerName'];
              if (pName == playerName) {
                final resultData = {
                  'isCorrect': pr['isCorrect'] ?? pr['IsCorrect'] ?? false,
                  'pointsEarned': pr['pointsEarned'] ?? pr['PointsEarned'] ?? 0,
                  'correctAnswerId': data['correctAnswerId'] ?? data['CorrectAnswerId'],
                  'correctAnswerText': data['correctAnswerText'] ?? data['CorrectAnswerText'] ?? '',
                };
                lastAnswerResult.value = resultData;
                
                // Update stats
                final points = resultData['pointsEarned'] as int;
                final isCorrect = resultData['isCorrect'] as bool;
                myScore.value += points;
                myTotalAnswered.value++;
                if (isCorrect) {
                  myCorrectAnswers.value++;
                  myDamageDealt.value += points;
                }
                
                gamePhase.value = 'answered';
                log('✅ Using ShowAnswerResult for answered phase (Boss Fight per-player)');
                return;
              }
            }
          }
        }
        
        gamePhase.value = 'result';
      },
      onGameEnded: (data) {
        gamePhase.value = 'finalResult';
        finalResult.value = data;
      },
      onGameCancelled: (data) {
        errorMessage.value = 'Game đã bị hủy';
        gamePhase.value = 'error';
      },
      // Boss Fight events
      onBossFightModeEnabled: (data) {
        isBossFightMode.value = true;
        bossMaxHP.value = data['bossMaxHP'] ?? data['BossMaxHP'] ?? 10000;
        bossCurrentHP.value = data['bossCurrentHP'] ?? data['BossCurrentHP'] ?? 10000;
        isPerPlayerFlow.value = data['isPerPlayerFlow'] ?? data['IsPerPlayerFlow'] ?? false;
      },
      onLobbySettingsUpdated: (data) {
        lobbySettings.value = data;
        bossMaxHP.value = data['bossMaxHP'] ?? data['BossMaxHP'] ?? bossMaxHP.value;
        bossCurrentHP.value = data['bossCurrentHP'] ?? data['BossCurrentHP'] ?? bossCurrentHP.value;
        final timeLimit = data['timeLimitSeconds'] ?? data['TimeLimitSeconds'];
        if (timeLimit != null) {
          matchTotalTime.value = timeLimit;
        }
        final questionTime = data['questionTimeLimitSeconds'] ?? data['QuestionTimeLimitSeconds'];
        if (questionTime != null) {
          questionTimeLimitSeconds.value = questionTime;
        }
      },
      onBossDamaged: (data) {
        final damage = data['damageDealt'] ?? data['DamageDealt'] ?? 0;
        bossCurrentHP.value = data['bossCurrentHP'] ?? data['BossCurrentHP'] ?? bossCurrentHP.value;
        totalDamageDealt.value = data['totalDamageDealt'] ?? data['TotalDamageDealt'] ?? totalDamageDealt.value;
        
        lastDamage.value = damage;
        showDamageEffect.value = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          showDamageEffect.value = false;
        });
      },
      onBossDefeated: (data) {
        bossDefeated.value = true;
        bossCurrentHP.value = 0;
        gamePhase.value = 'finalResult';
        finalResult.value = data;
      },
      onBossFightTimeUp: (data) {
        gamePhase.value = 'finalResult';
        finalResult.value = data;
      },
      onBossFightQuestionsExhausted: (data) {
        gamePhase.value = 'finalResult';
        finalResult.value = data;
      },
      onBossFightAnswerResult: (data) {
        log('✅✅✅ onBossFightAnswerResult received V2: ${data.toString()}');
        log('✅✅✅ onBossFightAnswerResult - data type: ${data.runtimeType}');
        log('✅✅✅ onBossFightAnswerResult - data keys: ${data.keys.toList()}');
        // Normalize data (camelCase + PascalCase)
        final resultData = Map<String, dynamic>.from(data);
        resultData['isCorrect'] = data['isCorrect'] ?? data['IsCorrect'] ?? false;
        resultData['correctAnswerId'] = data['correctAnswerId'] ?? data['CorrectAnswerId'];
        resultData['correctAnswerText'] = data['correctAnswerText'] ?? data['CorrectAnswerText'] ?? '';
        resultData['pointsEarned'] = data['pointsEarned'] ?? data['PointsEarned'] ?? 0;

        lastAnswerResult.value = resultData;
        
        // Update stats
        final points = resultData['pointsEarned'] as int;
        final isCorrect = resultData['isCorrect'] as bool;
        myScore.value += points;
        myTotalAnswered.value++;
        if (isCorrect) {
          myCorrectAnswers.value++;
          myDamageDealt.value += points;
        }

        // Set phase to 'answered' - this will trigger the auto-next timer logic
        // Giống Web app: sau khi nhận BossFightAnswerResult, set phase = 'answered'
        gamePhase.value = 'answered';

        // Auto-request next question after 2 seconds (Boss Fight per-player flow)
        // Giống Web app: logic trong renderAnsweredPhase - check timer null và set timeout
        log('🔍 Checking conditions for auto-next timer:');
        log('  - isBossFightMode: ${isBossFightMode.value}');
        log('  - isPerPlayerFlow: ${isPerPlayerFlow.value}');
        log('  - gamePin: $gamePin');
        
        if (isBossFightMode.value && !isPerPlayerFlow.value) {
          // Cancel existing timer if any
          _autoNextTimer?.cancel();
          
          // Set new timer only if timer is null (giống Web app: if (autoNextTimerRef.current === null))
          if (_autoNextTimer == null || !_autoNextTimer!.isActive) {
            log('⏰ Setting auto-next timer for Boss Fight per-player flow...');
            _autoNextTimer = Timer(const Duration(seconds: 2), () {
              log('⏰⏰⏰ Timer triggered! Auto-requesting next question after 2 seconds...');
              _autoNextTimer = null; // Clear ref after execution (giống Web app)
              if (gamePin != null) {
                log('📤 Calling getPlayerNextQuestion with gamePin: $gamePin');
                log('📤 Connection status: ${_gameHub.isConnected}');
                try {
                  _gameHub.getPlayerNextQuestion(gamePin!);
                  log('✅ getPlayerNextQuestion called successfully');
                } catch (e) {
                  log('❌ Error calling getPlayerNextQuestion: $e');
                  errorMessage.value = 'Lỗi khi lấy câu hỏi tiếp theo: $e';
                }
              } else {
                log('⚠️ Cannot call getPlayerNextQuestion: gamePin is null');
              }
            });
            log('✅ Auto-next timer set successfully, will trigger in 2 seconds');
          } else {
            log('⚠️ Auto-next timer already active, skipping...');
          }
        } else {
          log('⚠️ Conditions not met for auto-next timer');
        }
      },
      onPlayerQuestion: (data) {
        // Cancel auto-next timer
        _autoNextTimer?.cancel();
        _autoNextTimer = null;

        // Handle new question
        _handleShowQuestion(data);
      },
      onRealtimeLeaderboard: (data) {
        final rankings = data['players'] ?? data['Players'] ?? [];
        if (rankings is List) {
          damageLeaderboard.value = List<Map<String, dynamic>>.from(
            rankings.map((r) => r is Map ? Map<String, dynamic>.from(r) : {}),
          );
        }
      },
      onBossFightLeaderboard: (data) {
        final rankings = data['players'] ?? data['Players'] ?? [];
        if (rankings is List) {
          damageLeaderboard.value = List<Map<String, dynamic>>.from(
            rankings.map((r) => r is Map ? Map<String, dynamic>.from(r) : {}),
          );
        }
      },
      onBossState: (data) {
        bossCurrentHP.value = data['bossCurrentHP'] ?? data['BossCurrentHP'] ?? bossCurrentHP.value;
        bossMaxHP.value = data['bossMaxHP'] ?? data['BossMaxHP'] ?? bossMaxHP.value;
        totalDamageDealt.value = data['totalDamageDealt'] ?? data['TotalDamageDealt'] ?? totalDamageDealt.value;
      },
      onGameForceEnded: (data) {
        gamePhase.value = 'finalResult';
        finalResult.value = data;
      },
      onError: (error) {
        errorMessage.value = error;
      },
    );
  }

  // ==================== HELPER METHODS ====================

  void _startCountdown() {
    int countdown = 3;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      countdownValue.value = countdown;
      if (countdown <= 0) {
        timer.cancel();
      }
    });
  }

  void _handleShowQuestion(Map<String, dynamic> data) {
    // Extract group item for TOEIC grouped questions
    final groupItem = data['groupItem'] ?? data['GroupItem'];
    
    currentQuestion.value = data;
    if (groupItem != null && groupItem is Map) {
      currentGroupItem.value = Map<String, dynamic>.from(groupItem);
    } else {
      currentGroupItem.value = null;
    }
    
    timeLeft.value = data['timeLimit'] ?? data['TimeLimit'] ?? questionTimeLimitSeconds.value;
    selectedAnswerId.value = null;
    isAnswerSubmitted.value = false;
    lastAnswerResult.value = null;
    gamePhase.value = 'playing';

    // Start question timer
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        timer.cancel();
        // Auto-submit if time runs out
        if (!isAnswerSubmitted.value && currentQuestion.value != null) {
          submitAnswer(null);
        }
      }
    });
  }

  // Note: Match timer can be started if needed
  // void _startMatchTimer() {
  //   _matchTimer?.cancel();
  //   if (matchStartTime == null || matchTotalTime.value == null) return;
  //
  //   _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (matchStartTime == null || matchTotalTime.value == null) {
  //       timer.cancel();
  //       return;
  //     }
  //
  //     final elapsed = DateTime.now().difference(matchStartTime!).inSeconds;
  //     final remaining = (matchTotalTime.value! - elapsed).clamp(0, matchTotalTime.value!);
  //     matchTimeRemaining.value = remaining;
  //
  //     if (remaining <= 0) {
  //       timer.cancel();
  //       // Time expired - request next question to trigger server check
  //       if (gamePin != null) {
  //         _gameHub.bossFightNextQuestion(gamePin!);
  //       }
  //     }
  //   });
  // }

  // ==================== ACTIONS ====================

  /// Request next question after delay (giống Web app renderAnsweredPhase logic)
  /// Được gọi từ view khi phase = 'answered'
  void requestNextQuestionAfterDelay() {
    // Chỉ set timer nếu chưa có timer đang chạy (giống Web app: if (autoNextTimerRef.current === null))
    if (_autoNextTimer == null || !_autoNextTimer!.isActive) {
      if (isBossFightMode.value && isPerPlayerFlow.value && gamePhase.value == 'answered') {
        log('⏰ Setting auto-next timer from view (Boss Fight per-player flow)...');
        _autoNextTimer?.cancel();
        _autoNextTimer = Timer(const Duration(seconds: 2), () {
          log('⏰ Auto-requesting next question after 2 seconds...');
          _autoNextTimer = null; // Clear ref after execution (giống Web app)
          if (gamePin != null) {
            log('📤 Calling getPlayerNextQuestion with gamePin: $gamePin');
            try {
              _gameHub.getPlayerNextQuestion(gamePin!);
              log('✅ getPlayerNextQuestion called successfully');
            } catch (e) {
              log('❌ Error calling getPlayerNextQuestion: $e');
            }
          } else {
            log('⚠️ Cannot call getPlayerNextQuestion: gamePin is null');
          }
        });
      }
    }
  }

  /// Submit answer
  Future<void> submitAnswer(String? answerId) async {
    if (isAnswerSubmitted.value || currentQuestion.value == null) return;

    selectedAnswerId.value = answerId;
    isAnswerSubmitted.value = true;

    try {
      if (gamePin == null) return;

      final question = currentQuestion.value;
      if (question == null) return;

      final questionId = question['questionId']?.toString() ?? 
                        question['QuestionId']?.toString() ?? '';

      // TODO: Hard code Boss Fight mode cho multi player
      // Tạm thời luôn dùng submitBossFightAnswer cho multi player mode
      // Sau này sẽ check isBossFightMode và isPerPlayerFlow từ server
      await _gameHub.submitBossFightAnswer(
        gamePin!,
        questionId,
        answerId ?? '00000000-0000-0000-0000-000000000000',
      );
      
      // Code cũ (để tham khảo):
      // if (isBossFightMode.value && isPerPlayerFlow.value) {
      //   await _gameHub.submitBossFightAnswer(...);
      // } else {
      //   await _gameHub.submitAnswer(...);
      // }
    } catch (e) {
      log('Error submitting answer V2: $e');
      errorMessage.value = 'Không thể gửi câu trả lời: $e';
    }
  }

  /// Request next question (Boss Fight per-player flow)
  Future<void> requestNextQuestion() async {
    try {
      if (gamePin == null) return;
      await _gameHub.getPlayerNextQuestion(gamePin!);
    } catch (e) {
      log('Error requesting next question V2: $e');
      errorMessage.value = 'Không thể lấy câu hỏi tiếp theo: $e';
    }
  }

  /// Leave game
  Future<void> leaveGame() async {
    try {
      if (gamePin != null) {
        await _gameHub.leaveGame(gamePin!);
      }
    } catch (e) {
      log('Error leaving game V2: $e');
    }
  }

  // ==================== GETTERS ====================

  bool get isConnected => _gameHub.isConnected;
  
  String get formattedMatchTime {
    final remaining = matchTimeRemaining.value;
    if (remaining == null) return '--:--';
    final mins = remaining ~/ 60;
    final secs = remaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

