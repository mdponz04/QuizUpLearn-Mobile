import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../service/game_hub_service_v3.dart';
import '../../../service/basecommon.dart';
import '../../../data/dio_interceptor.dart';
import '../../home/data/game_api.dart';
import '../../home/data/game_service.dart';

const baseUrl = 'https://qul-api.onrender.com/api'; // For REST API calls
const signalRBaseUrl = 'https://qul-api.onrender.com'; // For SignalR (no /api prefix)

/// PlayerGameRoomController V3 - Fully synchronized with Web app EventPlayerPage
/// 
/// Key features matching Web app:
/// - Validate game PIN before connecting (REST API)
/// - Get game session before connecting (REST API)
/// - JWT token required for SignalR connection
/// - Individual player flow (Boss Fight mode)
/// - Questions exhausted handling with PlayerCompletedAllQuestions event
/// - Match timer countdown
/// - Auto-request next question after 2 seconds (only if not exhausted)
/// - Navigation guards to prevent accidental leaves
/// - All events matching Web app exactly
class PlayerGameRoomControllerV3 extends GetxController {
  final GameHubServiceV3 _gameHub = GameHubServiceV3();
  final TextEditingController playerNameController = TextEditingController();

  // ==================== GAME PHASE ====================
  // 'enteringPin' → 'connecting' → 'lobby' → 'countdown' → 'playing' → 'answered' → 'finalResult'
  // enteringPin: Nhập tên người chơi (nếu chưa có từ arguments)
  final RxString gamePhase = 'enteringPin'.obs;
  
  // Keep ref in sync with state for SignalR handlers (avoids closure issues - giống Web app)
  final RxString gamePhaseRef = 'connecting'.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Sync ref with state
    ever(gamePhase, (String phase) {
      gamePhaseRef.value = phase;
    });
    
    // Initialize from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      gamePin = args['gamePin'] as String?;
      playerName = args['playerName'] as String?;
      eventName = args['eventName'] as String?;
      eventId = args['eventId'] as String?;
      
      if (playerName != null) {
        playerNameController.text = playerName!;
      }
    }
    
    // Nếu có đủ gamePin và playerName, auto-connect
    // Nếu thiếu, giữ phase là enteringPin để user nhập
    if (gamePin != null && playerName != null && playerName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        connectAndJoin();
      });
    } else {
      // Thiếu thông tin → giữ phase là enteringPin để user nhập
      gamePhase.value = 'enteringPin';
      isLoading.value = false; // Không loading khi đang chờ input
    }
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
  final RxBool isBossFightMode = false.obs;
  final RxInt bossMaxHP = 10000.obs;
  final RxInt bossCurrentHP = 10000.obs;
  final RxInt totalDamageDealt = 0.obs;
  final RxInt myDamageDealt = 0.obs;
  final RxInt lastDamage = 0.obs;
  final RxBool showDamageEffect = false.obs;
  final RxBool bossDefeated = false.obs;
  
  // Questions exhausted tracking (giống Web app)
  final RxBool questionsExhausted = false.obs;
  final RxBool waitingForOthers = false.obs;
  final RxInt completedPlayersCount = 0.obs;

  // Match timer state (giống Web app)
  final Rxn<int> matchTimeRemaining = Rxn<int>();
  DateTime? matchStartTime;
  final Rxn<int> matchTotalTime = Rxn<int>();
  
  // Lobby settings state (from mod updates - giống Web app)
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
  String? eventName;
  String? eventId;

  // ==================== VALIDATE AND FETCH GAME SESSION ====================
  // (Giống Web app validateAndFetchSession function)

  Future<bool> validateAndFetchSession() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Step 1: Validate game PIN (giống Web app)
      log('🔍 [BACKEND API] Validating game PIN: $gamePin');
      final dio = Dio();
      dio.interceptors.add(DioIntercepTorCustom());
      final gameService = GameService(
        gameApi: GameApi(dio, baseUrl: baseUrl),
      );
      
      final validateResponse = await gameService.validateGamePin(gamePin!);
      log('✅ [BACKEND API] Validate game PIN response: ${validateResponse.toString()}');

      if (!validateResponse.isSuccess ) {
        log('❌ [BACKEND API] Game PIN validation failed: ${validateResponse.message}');
        errorMessage.value = validateResponse.message;
        isLoading.value = false;
        return false;
      }

      // Step 2: Get game session (giống Web app)
      log('🔍 [BACKEND API] Getting game session for PIN: $gamePin');
      final sessionResponse = await gameService.getGameSession(gamePin!);
      log('✅ [BACKEND API] Game session response: ${sessionResponse.toString()}');

      if (sessionResponse.isSuccess && sessionResponse.data != null) {
        final session = sessionResponse.data!;
        // Convert GameSessionData to Map for compatibility
        gameSession.value = {
          'gamePin': session.gamePin,
          'gameSessionId': session.gameSessionId,
          'hostUserId': session.hostUserId,
          'hostUserName': session.hostUserName,
          'quizSetId': session.quizSetId,
          'quizSetTitle': session.quizSetTitle,
          'status': session.status,
          'totalPlayers': session.totalPlayers,
          'totalQuestions': session.totalQuestions,
          'players': session.players?.map((p) => {
            'playerId': p.playerId,
            'playerName': p.playerName,
            'joinedAt': p.joinedAt?.toIso8601String(),
          }).toList(),
        };
        
        // Update players list
        if (session.players != null) {
          players.value = session.players!.map((p) => {
            'playerId': p.playerId,
            'playerName': p.playerName,
            'joinedAt': p.joinedAt?.toIso8601String(),
          }).toList();
        }
        totalPlayers.value = session.totalPlayers;
        
        // Note: Boss HP and other settings will be received from host via LobbySettingsUpdated event
        // Don't calculate here - let the host control these settings (giống Web app)
      }

      return true;
    } catch (err) {
      log('❌ Error validating/fetching game: $err');
      errorMessage.value = err.toString();
      isLoading.value = false;
      return false;
    }
  }

  // ==================== SIGNALR CONNECTION ====================
  // (Giống Web app setupSignalR function)

  Future<void> connectAndJoin() async {
    // Validate inputs (giống V2)
    if (gamePin == null || gamePin!.isEmpty) {
      errorMessage.value = 'Vui lòng nhập Game PIN';
      gamePhase.value = 'enteringPin';
      return;
    }

    final name = playerNameController.text.trim();
    if (name.isEmpty) {
      // Nếu chưa có playerName từ arguments, lấy từ controller
      if (playerName == null || playerName!.isEmpty) {
        errorMessage.value = 'Vui lòng nhập tên người chơi';
        gamePhase.value = 'enteringPin';
        return;
      }
    } else {
      playerName = name; // Lưu tên đã nhập
    }

    // Skip if already connected (giống Web app)
    if (_gameHub.isConnected && gamePhase.value == 'connecting') {
      try {
        await _gameHub.joinGame(gamePin!, playerName!);
      } catch (err) {
        log('❌ JoinGame error: $err');
      }
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      connectionStatus.value = 'connecting';
      gamePhase.value = 'connecting';

      // Step 1: Validate and fetch session (giống Web app)
      final isValid = await validateAndFetchSession();
      if (!isValid) {
        return;
      }

      // Step 2: Get token (giống Web app)
      final token = await BaseCommon.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'Vui lòng đăng nhập để tiếp tục';
        isLoading.value = false;
        connectionStatus.value = 'error';
        // Redirect to login after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
        return;
      }

      // Step 3: Connect to SignalR (giống Web app)
      // SignalR hub URL không có /api prefix (giống V2 và Web app)
      final connected = await _gameHub.connect(signalRBaseUrl);
      if (!connected) {
        errorMessage.value = 'Không thể kết nối đến server';
        connectionStatus.value = 'error';
        isLoading.value = false;
        gamePhase.value = 'error';
        return;
      }

      // Step 5: Setup event listeners (giống Web app)
      _setupEventListeners();

      // Step 6: Join game as player (giống Web app)
      log('📤 [SignalR INVOKE] Joining game - JoinGame: gamePin=$gamePin, playerName=$playerName');
      await _gameHub.joinGame(gamePin!, playerName!);
      log('✅ [SignalR INVOKE] JoinGame successful');
      
    } catch (err) {
      log('❌ SignalR setup error: $err');
      errorMessage.value = err.toString();
      isLoading.value = false;
      connectionStatus.value = 'error';
      gamePhase.value = 'error';
    }
  }

  // ==================== EVENT LISTENERS SETUP ====================
  // (Giống Web app - tất cả events từ EventPlayerPage)

  void _setupEventListeners() {
    log('🔧 Setting up event listeners V3 in controller...');
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
      
      // ==================== CONNECTION & AUTH EVENTS ====================
      
      // Joined game successfully (giống Web app)
      onJoinedGame: (data) {
        log('✅ [SignalR EVENT] JoinedGame received V3: ${data.toString()}');
        isLoading.value = false;
        connectionStatus.value = 'connected';
        gamePhase.value = 'lobby';
        errorMessage.value = null;
      },
      
      // Join rejected (authentication failed or other errors - giống Web app)
      onJoinRejected: (data) {
        log('❌ [SignalR EVENT] JoinRejected received V3: ${data.toString()}');
        final errorMsg = data['Message'] ?? 
                        data['message'] ?? 
                        'Không thể tham gia game. Vui lòng đăng nhập lại.';
        errorMessage.value = errorMsg;
        isLoading.value = false;
        connectionStatus.value = 'error';
        // Redirect to login after 3 seconds if auth error
        if (errorMsg.toLowerCase().contains('đăng nhập') || 
            errorMsg.toLowerCase().contains('token')) {
          Future.delayed(const Duration(seconds: 3), () {
            Get.offAllNamed('/login');
          });
        }
      },
      
      // ==================== LOBBY EVENTS ====================
      
      // Lobby updated (player list - giống Web app)
      onLobbyUpdated: (data) {
        log('📋 [SignalR EVENT] LobbyUpdated received V3: ${data.toString()}');
        final playerList = data['Players'] ?? data['players'] ?? [];
        if (playerList is List) {
          players.value = List<Map<String, dynamic>>.from(
            playerList.map((p) => p is Map ? Map<String, dynamic>.from(p) : {}),
          );
        }
        totalPlayers.value = data['TotalPlayers'] ?? 
                            data['totalPlayers'] ?? 
                            playerList.length;
        // Boss HP is now controlled by host via LobbySettingsUpdated event
        // Do NOT recalculate locally (giống Web app)
      },
      
      // New player joined (giống Web app)
      onPlayerJoined: (player) {
        log('👤 [SignalR EVENT] PlayerJoined received V3: ${player.toString()}');
        players.refresh();
      },
      
      // ==================== GAME START EVENTS ====================
      
      // Game started (giống Web app)
      onGameStarted: (data) {
        log('🎮 [SignalR EVENT] GameStarted received V3: ${data.toString()}');
        gamePhase.value = 'countdown';
        countdownValue.value = 3;
        questionsExhausted.value = false; // Reset questions exhausted flag when game starts
        waitingForOthers.value = false; // Reset waiting flag
        completedPlayersCount.value = 0; // Reset completed count
        
        // Set Boss Fight mode info from backend (giống Web app)
        if (data['IsBossFightMode'] ?? data['isBossFightMode'] ?? false) {
          isBossFightMode.value = true;
          bossMaxHP.value = data['BossMaxHP'] ?? data['bossMaxHP'] ?? 10000;
          bossCurrentHP.value = data['BossCurrentHP'] ?? data['bossCurrentHP'] ?? 10000;
        }
        
        // Set match timer info (giống Web app)
        final totalMatchTime = data['GameTimeLimitSeconds'] ?? 
                              data['gameTimeLimitSeconds'] ?? 
                              600; // default 10 mins
        matchTotalTime.value = totalMatchTime is int ? totalMatchTime : totalMatchTime.toInt();
        matchStartTime = DateTime.now();
        matchTimeRemaining.value = totalMatchTime is int ? totalMatchTime : totalMatchTime.toInt();
        
        // Countdown animation (giống Web app)
        _startCountdown();
      },
      
      // ==================== QUESTION EVENTS ====================
      
      // Show question (legacy - giống Web app)
      onShowQuestion: (question) {
        log('❓ [SignalR EVENT] ShowQuestion received V3: ${question.toString()}');
        // Skip if per-player flow (will receive via PlayerQuestion)
        if (isBossFightMode.value) {
          return;
        }
        _handleShowQuestion(question);
      },
      
      // Answer submitted confirmation (giống Web app)
      onAnswerSubmitted: (data) {
        log('✔️ [SignalR EVENT] AnswerSubmitted received V3: ${data.toString()}');
        isAnswerSubmitted.value = true;
      },
      
      // Player score updated (giống Web app)
      onPlayerScoreUpdated: (data) {
        log('📊 [SignalR EVENT] PlayerScoreUpdated received V3: ${data.toString()}');
        final newScore = data['Score'] ?? data['score'] ?? 0;
        myScore.value = newScore;
      },
      
      // Show answer result (legacy - giống Web app)
      onShowAnswerResult: (result) {
        log('📊 [SignalR EVENT] ShowAnswerResult received V3: ${result.toString()}');
        // In boss fight mode, we use BossFightAnswerResult instead
        if (isBossFightMode.value) {
          return;
        }
        // Normal mode handling...
      },
      
      // ==================== BOSS FIGHT MODE EVENTS ====================
      
      // Boss Fight mode enabled (giống Web app)
      onBossFightModeEnabled: (data) {
        log('🔥 [SignalR EVENT] BossFightModeEnabled received V3: ${data.toString()}');
        isBossFightMode.value = true;
        bossMaxHP.value = data['BossMaxHP'] ?? data['bossMaxHP'] ?? 10000;
        bossCurrentHP.value = data['BossCurrentHP'] ?? data['bossCurrentHP'] ?? 10000;
        // Update time settings from mod
        final timeLimit = data['TimeLimitSeconds'] ?? data['timeLimitSeconds'];
        if (timeLimit != null) {
          matchTotalTime.value = timeLimit is int ? timeLimit : timeLimit.toInt();
        }
        final questionTime = data['QuestionTimeLimitSeconds'] ?? data['questionTimeLimitSeconds'];
        if (questionTime != null) {
          questionTimeLimitSeconds.value = questionTime is int ? questionTime : questionTime.toInt();
        }
      },
      
      // Lobby settings updated in real-time by mod (giống Web app)
      onLobbySettingsUpdated: (data) {
        log('⚙️ [SignalR EVENT] LobbySettingsUpdated received V3: ${data.toString()}');
        final newBossMaxHP = data['BossMaxHP'] ?? data['bossMaxHP'] ?? 10000;
        final newBossCurrentHP = data['BossCurrentHP'] ?? data['bossCurrentHP'] ?? 10000;
        bossMaxHP.value = newBossMaxHP;
        bossCurrentHP.value = newBossCurrentHP;
        // Update time settings
        final timeLimitSeconds = data['TimeLimitSeconds'] ?? data['timeLimitSeconds'];
        if (timeLimitSeconds != null) {
          matchTotalTime.value = timeLimitSeconds is int ? timeLimitSeconds : timeLimitSeconds.toInt();
        }
        final questionTime = data['QuestionTimeLimitSeconds'] ?? data['questionTimeLimitSeconds'];
        if (questionTime != null) {
          questionTimeLimitSeconds.value = questionTime is int ? questionTime : questionTime.toInt();
        }
      },
      
      // Boss damaged (global event when any player deals damage - giống Web app)
      onBossDamaged: (data) {
        log('⚔️ [SignalR EVENT] BossDamaged received V3: ${data.toString()}');
        final damage = data['DamageDealt'] ?? data['damageDealt'] ?? 0;
        final currentHP = data['BossCurrentHP'] ?? data['bossCurrentHP'];
        final maxHP = data['BossMaxHP'] ?? data['bossMaxHP'];
        final totalDmg = data['TotalDamageDealt'] ?? data['totalDamageDealt'] ?? 0;
        
        // Update boss HP
        if (currentHP != null && currentHP is int) {
          bossCurrentHP.value = currentHP;
        }
        if (maxHP != null && maxHP is int) {
          bossMaxHP.value = maxHP;
        }
        totalDamageDealt.value = totalDmg;
        
        // Show damage effect
        lastDamage.value = damage;
        showDamageEffect.value = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          showDamageEffect.value = false;
        });
        
        // NOTE: Don't update myDamageDealt/myCorrectAnswers here!
        // BossFightAnswerResult already handles player stats tracking (giống Web app)
      },
      
      // Boss defeated (giống Web app - ưu tiên camelCase)
      onBossDefeated: (data) {
        log('🎉 [SignalR EVENT] BossDefeated received V3: ${data.toString()}');
        bossDefeated.value = true;
        bossCurrentHP.value = 0;
        gamePhase.value = 'finalResult';
        gamePhaseRef.value = 'finalResult'; // Update ref immediately
        
        finalResult.value = {
          'totalDamageDealt': data['totalDamageDealt'] ?? data['TotalDamageDealt'],
          'timeToDefeat': data['timeToDefeat'] ?? data['TimeToDefeat'],
          'rankings': (data['damageRankings'] ?? data['DamageRankings'] ?? []).map((r) => {
            'rank': r['rank'] ?? r['Rank'],
            'playerName': r['playerName'] ?? r['PlayerName'],
            'totalDamage': r['totalDamage'] ?? r['TotalDamage'] ?? 0,
            'correctAnswers': r['correctAnswers'] ?? r['CorrectAnswers'] ?? 0,
            'totalAnswered': r['totalAnswered'] ?? r['TotalAnswered'] ?? 0,
            'damagePercent': r['damagePercent'] ?? r['DamagePercent'] ?? 0,
          }).toList(),
          'mvpPlayer': data['mvpPlayer'] ?? data['MvpPlayer'],
        };
      },
      
      // Boss fight time up (boss wins - giống Web app - ưu tiên camelCase)
      onBossFightTimeUp: (data) {
        log('⏰ [SignalR EVENT] BossFightTimeUp received V3: ${data.toString()}');
        // Extract and normalize rankings from server data (giống Web app)
        final rankings = (data['damageRankings'] ?? data['DamageRankings'] ?? []).map((r) => {
          'rank': r['rank'] ?? r['Rank'],
          'playerName': r['playerName'] ?? r['PlayerName'],
          'totalDamage': r['totalDamage'] ?? r['TotalDamage'] ?? 0,
          'correctAnswers': r['correctAnswers'] ?? r['CorrectAnswers'] ?? 0,
          'totalAnswered': r['totalAnswered'] ?? r['TotalAnswered'] ?? 0,
          'damagePercent': r['damagePercent'] ?? r['DamagePercent'] ?? 0,
        }).toList();
        bossDefeated.value = false;
        gamePhase.value = 'finalResult';
        gamePhaseRef.value = 'finalResult'; // Update ref immediately
        finalResult.value = {
          'bossWins': true,
          'message': data['message'] ?? data['Message'] ?? "Time's up! The boss has won!",
          'bossCurrentHP': data['bossCurrentHP'] ?? data['BossCurrentHP'],
          'bossMaxHP': data['bossMaxHP'] ?? data['BossMaxHP'],
          'totalDamageDealt': data['totalDamageDealt'] ?? data['TotalDamageDealt'],
          'rankings': rankings,
          'mvpPlayer': data['mvpPlayer'] ?? data['MvpPlayer'],
        };
      },
      
      // Boss fight questions exhausted (boss wins - giống Web app - ưu tiên camelCase)
      onBossFightQuestionsExhausted: (data) {
        log('📝 [SignalR EVENT] BossFightQuestionsExhausted received V3: ${data.toString()}');
        // Extract and normalize rankings from server data (giống Web app)
        final rankings = (data['damageRankings'] ?? data['DamageRankings'] ?? []).map((r) => {
          'rank': r['rank'] ?? r['Rank'],
          'playerName': r['playerName'] ?? r['PlayerName'],
          'totalDamage': r['totalDamage'] ?? r['TotalDamage'] ?? 0,
          'correctAnswers': r['correctAnswers'] ?? r['CorrectAnswers'] ?? 0,
          'totalAnswered': r['totalAnswered'] ?? r['TotalAnswered'] ?? 0,
          'damagePercent': r['damagePercent'] ?? r['DamagePercent'] ?? 0,
        }).toList();
        bossDefeated.value = false;
        gamePhase.value = 'finalResult';
        gamePhaseRef.value = 'finalResult'; // Update ref immediately
        finalResult.value = {
          'bossWins': true,
          'message': data['message'] ?? data['Message'] ?? "Đã trả lời tất cả câu hỏi nhưng boss vẫn còn sống!",
          'bossCurrentHP': data['bossCurrentHP'] ?? data['BossCurrentHP'],
          'bossMaxHP': data['bossMaxHP'] ?? data['BossMaxHP'],
          'totalDamageDealt': data['totalDamageDealt'] ?? data['TotalDamageDealt'],
          'rankings': rankings,
          'mvpPlayer': data['mvpPlayer'] ?? data['MvpPlayer'],
        };
      },
      
      // Boss fight leaderboard (giống Web app)
      onBossFightLeaderboard: (data) {
        log('🏆 [SignalR EVENT] BossFightLeaderboard received V3: ${data.toString()}');
        // Update rankings silently - don't interrupt gameplay (giống Web app)
        bossCurrentHP.value = data['BossCurrentHP'] ?? data['bossCurrentHP'] ?? bossCurrentHP.value;
        totalDamageDealt.value = data['TotalDamageDealt'] ?? data['totalDamageDealt'] ?? totalDamageDealt.value;
      },
      
      // Boss state update (giống Web app)
      onBossState: (data) {
        log('💪 [SignalR EVENT] BossState received V3: ${data.toString()}');
        bossCurrentHP.value = data['BossCurrentHP'] ?? data['bossCurrentHP'] ?? bossCurrentHP.value;
        bossMaxHP.value = data['BossMaxHP'] ?? data['bossMaxHP'] ?? bossMaxHP.value;
        totalDamageDealt.value = data['TotalDamageDealt'] ?? data['totalDamageDealt'] ?? totalDamageDealt.value;
      },
      
      // ==================== BOSS FIGHT INDIVIDUAL FLOW EVENTS ====================
      
      // Boss Fight answer result (immediate feedback for individual player - giống Web app)
      onBossFightAnswerResult: (result) {
        log('📢 [SignalR EVENT] BossFightAnswerResult received V3: ${result.toString()}');
        final isCorrect = result['IsCorrect'] ?? result['isCorrect'] ?? false;
        final pointsEarned = result['PointsEarned'] ?? result['pointsEarned'] ?? 0;
        final correctAnswers = result['CorrectAnswers'] ?? result['correctAnswers'];
        final totalAnswered = result['TotalAnswered'] ?? result['totalAnswered'];
        final totalQuestions = result['TotalQuestions'] ?? result['totalQuestions']; // Server's authoritative value
        
        lastAnswerResult.value = {
          'isCorrect': isCorrect,
          'pointsEarned': pointsEarned,
          'correctAnswerId': result['CorrectAnswerId'] ?? result['correctAnswerId'],
          'correctAnswerText': result['CorrectAnswerText'] ?? result['correctAnswerText'] ?? '',
        };

        // Update my stats - use server's authoritative values (giống Web app)
        final pointsEarnedInt = pointsEarned is int ? pointsEarned : (pointsEarned as num).toInt();
        myScore.value += pointsEarnedInt;
        if (correctAnswers != null) {
          myCorrectAnswers.value = correctAnswers is int ? correctAnswers : (correctAnswers as num).toInt();
        }
        if (totalAnswered != null) {
          myTotalAnswered.value = totalAnswered is int ? totalAnswered : (totalAnswered as num).toInt();
        }
        if (isCorrect) {
          myDamageDealt.value += pointsEarnedInt;
        }

        // CRITICAL: Check if player completed all questions using SERVER'S authoritative data
        // This is 100% reliable - no dependency on frontend state (giống Web app)
        if (totalQuestions != null && totalAnswered != null && totalAnswered >= totalQuestions) {
          log('✅ [SERVER CHECK] Player completed all questions! totalAnswered=$totalAnswered, totalQuestions=$totalQuestions');
          questionsExhausted.value = true; // Set flag IMMEDIATELY to prevent timer scheduling
        } else {
          log('📊 [SERVER CHECK] Player progress: totalAnswered=$totalAnswered, totalQuestions=$totalQuestions');
        }

        // Show answered phase with feedback (giống Web app)
        gamePhase.value = 'answered';
      },
      
      // Player completed all questions but others haven't (individual notification - giống Web app)
      onPlayerCompletedAllQuestions: (data) {
        log('✅ [SignalR EVENT] PlayerCompletedAllQuestions received V3: ${data.toString()}');
        // Mark that this player is waiting for others (giống Web app)
        questionsExhausted.value = true;
        waitingForOthers.value = true;
        completedPlayersCount.value = data['CompletedPlayersCount'] ?? 
                                      data['completedPlayersCount'] ?? 
                                      0;
        gamePhase.value = 'answered'; // Show waiting state
        currentQuestion.value = null; // Clear current question
        
        final totalPlayersCount = data['TotalPlayersCount'] ?? 
                                 data['totalPlayersCount'] ?? 
                                 totalPlayers.value;
        final completedCount = data['CompletedPlayersCount'] ?? 
                              data['completedPlayersCount'] ?? 
                              0;
        final message = data['Message'] ?? 
                       data['message'] ?? 
                       'Bạn đã hoàn thành tất cả câu hỏi! Đang chờ ${totalPlayersCount - completedCount} người chơi khác...';
        
        // Show snackbar notification (giống Web app)
        Get.snackbar(
          'Thông báo',
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },
      
      // Player's next question (individual flow - giống Web app)
      onPlayerQuestion: (question) {
        log('🎯 [SignalR EVENT] PlayerQuestion received V3: ${question.toString()}');
        // Check if question is null or empty (questions exhausted - giống Web app)
        if (question.isEmpty) {
          log('⚠️ [INFO] No more questions available - waiting for game end event');
          // Mark questions as exhausted to prevent further requests
          questionsExhausted.value = true;
          // Stay in answered phase, server will send BossFightQuestionsExhausted or BossDefeated
          gamePhase.value = 'answered'; // Show waiting state
          currentQuestion.value = null; // Clear current question
          Get.snackbar(
            'Thông báo',
            'Bạn đã trả lời hết câu hỏi! Đang chờ những người chơi khác...',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        
        // Handle new question
        _handleShowQuestion(question);
      },
      
      // Game force ended by host (giống Web app - ưu tiên camelCase)
      onGameForceEnded: (data) {
        log('🛑 [SignalR EVENT] GameForceEnded received V3: ${data.toString()}');
        gamePhase.value = 'finalResult';
        gamePhaseRef.value = 'finalResult'; // Update ref immediately
        finalResult.value = {
          'forceEnded': true,
          'message': data['message'] ?? data['Message'] ?? 'Game ended by moderator',
          'rankings': (data['finalRankings'] ?? data['FinalRankings'] ?? []).map((r) => {
            'rank': r['rank'] ?? r['Rank'],
            'playerName': r['playerName'] ?? r['PlayerName'],
            'totalDamage': r['totalScore'] ?? r['TotalScore'] ?? 0,
            'correctAnswers': r['correctAnswers'] ?? r['CorrectAnswers'] ?? 0,
            'totalAnswered': r['totalAnswered'] ?? r['TotalAnswered'] ?? 0,
          }).toList(),
          'winner': data['winner'] ?? data['Winner'],
          'isBossFightMode': data['isBossFightMode'] ?? data['IsBossFightMode'],
          'bossDefeated': data['bossDefeated'] ?? data['BossDefeated'],
          'bossMaxHP': data['bossMaxHP'] ?? data['BossMaxHP'],
          'bossCurrentHP': data['bossCurrentHP'] ?? data['BossCurrentHP'],
          'totalDamageDealt': data['totalDamageDealt'] ?? data['TotalDamageDealt'],
        };
      },
      
      // Game ended (legacy - giống Web app - ưu tiên camelCase)
      onGameEnded: (data) {
        log('🏁 [SignalR EVENT] GameEnded received V3: ${data.toString()}');
        gamePhase.value = 'finalResult';
        gamePhaseRef.value = 'finalResult'; // Update ref immediately
        
        // Determine if boss was defeated
        final defeated = bossCurrentHP.value <= 0;
        bossDefeated.value = defeated;
        
        finalResult.value = {
          'totalQuestions': data['totalQuestions'] ?? data['TotalQuestions'],
          'rankings': (data['rankings'] ?? data['Rankings'] ?? []).map((r) => {
            'rank': r['rank'] ?? r['Rank'],
            'playerName': r['playerName'] ?? r['PlayerName'],
            'score': r['score'] ?? r['Score'] ?? 0,
            'correctAnswers': r['correctAnswers'] ?? r['CorrectAnswers'] ?? 0,
            'totalAnswered': r['totalAnswered'] ?? r['TotalAnswered'] ?? 0,
          }).toList(),
        };
      },
      
      // Game cancelled (giống Web app)
      onGameCancelled: (data) {
        log('❌ [SignalR EVENT] GameCancelled received V3: ${data.toString()}');
        // Don't show kick dialog if game already ended naturally (in finalResult phase)
        // This prevents backend cleanup from kicking users who are viewing final results
        // Use gamePhaseRef.value instead of gamePhase.value to avoid closure issues (giống Web app)
        if (gamePhaseRef.value == 'finalResult') {
          return;
        }
        // Show error message for actual host cancellation during active game
        errorMessage.value = data['Message'] ?? 
                            data['message'] ?? 
                            'Game đã bị hủy bởi host';
      },
      
      // Error (giống Web app)
      onError: (message) {
        log('❌ SignalR Error V3: $message');
        errorMessage.value = message;
        isLoading.value = false;
        // Stop connection and redirect back after a short delay (giống Web app)
        Future.delayed(const Duration(seconds: 2), () {
          _gameHub.disconnect();
          Get.back();
        });
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
        // After countdown, automatically request first question for Boss Fight mode (giống Web app)
        Future.delayed(const Duration(milliseconds: 500), () {
          log('⏭️ [AUTO] Requesting first question after countdown');
          handleRequestNextQuestion();
        });
      }
    });
  }

  void _handleShowQuestion(Map<String, dynamic> data) {
    // Extract group item data for TOEIC-style grouped questions (Parts 3,4,6,7 - giống Web app)
    // Ưu tiên camelCase (chữ cái đầu viết thường) như SignalR trả về
    final groupItem = data['groupItem'] ?? data['GroupItem'];
    
    // Parse answer options (giống Web app - ưu tiên camelCase)
    final answerOptionsRaw = data['answerOptions'] ?? data['AnswerOptions'] ?? [];
    final List<Map<String, dynamic>> answerOptions = [];
    if (answerOptionsRaw is List) {
      for (var opt in answerOptionsRaw) {
        if (opt is Map) {
          answerOptions.add({
            'answerId': opt['answerId'] ?? opt['AnswerId'] ?? '',
            'optionText': opt['optionText'] ?? opt['OptionText'] ?? '',
            'optionLabel': opt['optionLabel'] ?? opt['OptionLabel'], // A, B, C, D (optional)
          });
        }
      }
    }
    log('📋 Parsed ${answerOptions.length} answer options from PlayerQuestion');
    
    currentQuestion.value = {
      'questionId': data['questionId'] ?? data['QuestionId'],
      'questionText': data['questionText'] ?? data['QuestionText'],
      'imageUrl': data['imageUrl'] ?? data['ImageUrl'],
      'audioUrl': data['audioUrl'] ?? data['AudioUrl'],
      'questionNumber': data['questionNumber'] ?? data['QuestionNumber'],
      'totalQuestions': data['totalQuestions'] ?? data['TotalQuestions'],
      'timeLimit': data['timeLimit'] ?? data['TimeLimit'] ?? questionTimeLimitSeconds.value,
      'quizGroupItemId': data['quizGroupItemId'] ?? data['QuizGroupItemId'],
      // Answer options (giống Web app)
      'answerOptions': answerOptions,
      // Group item data (shared passage/audio/image for TOEIC Parts 3,4,6,7)
      'groupItem': groupItem,
    };
    
    if (groupItem != null && groupItem is Map) {
      currentGroupItem.value = Map<String, dynamic>.from(groupItem);
    } else {
      currentGroupItem.value = null;
    }
    
    timeLeft.value = data['timeLimit'] ?? 
                    data['TimeLimit'] ?? 
                    questionTimeLimitSeconds.value;
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
        // Auto-submit empty answer if time runs out (giống Web app)
        if (!isAnswerSubmitted.value && currentQuestion.value != null) {
          submitAnswer(null);
        }
      }
    });
  }

  // ==================== MATCH TIMER COUNTDOWN ====================
  // (Giống Web app match timer logic)
  // Note: Match timer is handled by server, we just display the remaining time
  // Server sends BossFightTimeUp event when time expires

  // Helper function to format time as MM:SS (giống Web app)
  String formatTime(int? seconds) {
    if (seconds == null) return '--:--';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ==================== ACTIONS ====================

  /// Submit answer (giống Web app)
  Future<void> submitAnswer(String? answerId) async {
    if (isAnswerSubmitted.value || currentQuestion.value == null) return;

    log('🎯 [USER ACTION] Submitting answer: answerId=$answerId, questionId=${currentQuestion.value?['questionId']}, gamePin=$gamePin');
    selectedAnswerId.value = answerId;
    isAnswerSubmitted.value = true;

    try {
      if (!_gameHub.isConnected) {
        log('❌ [ERROR] Not connected to SignalR hub when submitting answer');
        errorMessage.value = 'Mất kết nối đến server';
        return;
      }

      // Use Boss Fight specific submit for individual player flow (giống Web app)
      log('📤 [SignalR INVOKE] SubmitBossFightAnswer: gamePin=$gamePin, questionId=${currentQuestion.value?['questionId']}, answerId=$answerId');
      await _gameHub.submitBossFightAnswer(
        gamePin!,
        currentQuestion.value!['questionId'].toString(),
        answerId ?? '00000000-0000-0000-0000-000000000000', // Empty GUID for no answer
      );
      log('✅ [SignalR INVOKE] SubmitBossFightAnswer successful');
    } catch (err) {
      log('❌ [ERROR] Error submitting answer: $err');
      errorMessage.value = 'Không thể gửi câu trả lời';
    }
  }

  /// Request next question (giống Web app handleRequestNextQuestion)
  Future<void> handleRequestNextQuestion() async {
    try {
      // SAFEGUARD #1: Check if questions exhausted flag is already set (giống Web app)
      if (questionsExhausted.value) {
        log('⚠️ [SAFEGUARD #1] Questions already exhausted, not requesting more');
        return;
      }
      
      // SAFEGUARD #2: Don't request if we've already answered all questions based on count (giống Web app)
      final totalQuestionsInSet = gameSession.value?['totalQuestions'] ?? 
                                  currentQuestion.value?['totalQuestions'] ?? 
                                  0;
      if (totalQuestionsInSet > 0 && myTotalAnswered.value >= totalQuestionsInSet) {
      log('⚠️ [SAFEGUARD #2] Already answered all questions, not requesting more: myTotalAnswered=${myTotalAnswered.value}, totalQuestionsInSet=$totalQuestionsInSet');
        questionsExhausted.value = true;
        return;
      }
      
      log('⏭️ [USER ACTION] Requesting next question for gamePin: $gamePin');
      if (!_gameHub.isConnected) {
        log('❌ [ERROR] Not connected to SignalR hub when requesting next question');
        errorMessage.value = 'Mất kết nối đến server';
        return;
      }

      log('📤 [SignalR INVOKE] GetPlayerNextQuestion: gamePin=$gamePin');
      await _gameHub.getPlayerNextQuestion(gamePin!);
      log('✅ [SignalR INVOKE] GetPlayerNextQuestion successful');
    } catch (err) {
      log('❌ [ERROR] Error getting next question: $err');
      errorMessage.value = 'Không thể lấy câu hỏi tiếp theo';
    }
  }

  /// Auto-request next question after delay (giống Web app renderAnsweredPhase logic)
  /// Được gọi từ view khi phase = 'answered'
  void requestNextQuestionAfterDelay() {
    // ✅ FINAL FIX: ONLY check questionsExhausted flag - it's set reliably by server's response
    // No need to check gameSession.totalQuestions (might be stale) or myTotalAnswered (might lag)
    // Server sends TotalQuestions in every BossFightAnswerResult, so questionsExhausted is 100% accurate
    // (Giống Web app: if (!questionsExhausted && autoNextTimerRef.current === null && gamePhase === 'answered'))
    if (!questionsExhausted.value && 
        _autoNextTimer == null && 
        gamePhase.value == 'answered') {
      _autoNextTimer = Timer(const Duration(seconds: 2), () {
        _autoNextTimer = null;
        // Double-check before requesting (in case PlayerCompletedAllQuestions arrived during the 2-second wait)
        handleRequestNextQuestion();
      });
    }
  }

  /// Leave game (giống Web app)
  Future<void> leaveGame() async {
    log('🚪 [USER ACTION] Leaving game: gamePin=$gamePin, playerName=$playerName');
    try {
      if (_gameHub.isConnected) {
        log('📤 [SignalR INVOKE] LeaveGame: gamePin=$gamePin');
        await _gameHub.leaveGame(gamePin!);
        log('✅ [SignalR INVOKE] LeaveGame successful');
      }
    } catch (err) {
      log('❌ [ERROR] Error leaving game: $err');
    }
  }

  // ==================== GETTERS ====================

  bool get isConnected => _gameHub.isConnected;
  
  String get formattedMatchTime {
    final remaining = matchTimeRemaining.value;
    if (remaining == null) return '--:--';
    return formatTime(remaining);
  }
}

