import 'dart:async';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

/// GameHubService V3 - Fully synchronized with Web app EventPlayerPage
/// 
/// Key features:
/// - JWT token authentication (REQUIRED)
/// - All events matching Web app exactly
/// - Individual player flow (Boss Fight mode)
/// - Questions exhausted handling
/// - PlayerCompletedAllQuestions event
/// - Match timer support
/// - Auto-reconnect with re-join
class GameHubServiceV3 {
  HubConnection? _connection;
  String? _currentGamePin;
  bool _isConnected = false;

  // ==================== CONNECTION MANAGEMENT ====================

  /// Connect to SignalR Hub with JWT token (REQUIRED - giống Web app)
  Future<bool> connect(String baseUrl) async {
    try {
      final hubUrl = '$baseUrl/game-hub';
      
      // Get access token (REQUIRED - giống Web app)
      final accessToken = await BaseCommon.instance.getAccessToken();
      if (accessToken == null) {
        log('❌ Error: No access token found - JWT token required for GameHub');
        _onConnectionError?.call('No access token found. Please login again.');
        return false;
      }

      // Create HttpConnectionOptions with access token (giống Web app)
      final httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => accessToken,
      );

      _connection = HubConnectionBuilder()
          .withUrl(hubUrl, options: httpOptions)
          .withAutomaticReconnect() // Automatic reconnect (Flutter package doesn't support custom intervals)
          .build();

      // Setup connection lifecycle
      _connection!.onclose(({error}) {
        _isConnected = false;
        log('SignalR V3 connection closed: $error');
        _onConnectionClosed?.call(error);
      });

      await _connection!.start();
      _isConnected = true;
      log('✅ SignalR V3 connected successfully to GameHub');
      _onConnected?.call();
      return true;
    } catch (e) {
      log('❌ Error connecting to SignalR V3: $e');
      _isConnected = false;
      _onConnectionError?.call(e.toString());
      return false;
    }
  }

  /// Disconnect from SignalR
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.stop();
        _connection = null;
        _isConnected = false;
        _currentGamePin = null;
        log('SignalR V3 disconnected');
      }
    } catch (e) {
      log('Error disconnecting SignalR V3: $e');
    }
  }

  /// Check connection status
  bool get isConnected => _isConnected && _connection?.state == HubConnectionState.Connected;

  // ==================== PLAYER METHODS ====================

  /// Player join game (REQUIRES JWT TOKEN - giống Web app)
  Future<void> joinGame(String gamePin, String playerName) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentGamePin = gamePin;
      await _connection!.invoke('JoinGame', args: [gamePin, playerName]);
      log('📤 [SignalR INVOKE] JoinGame V3: $playerName joined game $gamePin');
    } catch (e) {
      log('❌ Error in joinGame V3: $e');
      throw e;
    }
  }

  /// Player leave game
  Future<void> leaveGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('LeaveGame', args: [gamePin]);
      log('📤 [SignalR INVOKE] LeaveGame V3 called for game: $gamePin');
    } catch (e) {
      log('❌ Error in leaveGame V3: $e');
      throw e;
    }
  }

  /// Player submit Boss Fight answer (individual flow - giống Web app)
  Future<void> submitBossFightAnswer(
    String gamePin,
    String questionId,
    String answerId,
  ) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke(
        'SubmitBossFightAnswer',
        args: [gamePin, questionId, answerId],
      );
      log('📤 [SignalR INVOKE] SubmitBossFightAnswer V3: questionId=$questionId, answerId=$answerId');
    } catch (e) {
      log('❌ Error in submitBossFightAnswer V3: $e');
      throw e;
    }
  }

  /// Player request next question (individual flow - giống Web app)
  Future<void> getPlayerNextQuestion(String gamePin) async {
    try {
      log('📤 [SignalR INVOKE] GetPlayerNextQuestion V3 - Checking connection...');
      if (!isConnected) {
        log('❌ GetPlayerNextQuestion V3 - Not connected to SignalR');
        throw Exception('Not connected to SignalR');
      }
      log('📤 [SignalR INVOKE] GetPlayerNextQuestion V3 - Connection OK, invoking with gamePin: $gamePin');
      await _connection!.invoke('GetPlayerNextQuestion', args: [gamePin]);
      log('✅ [SignalR INVOKE] GetPlayerNextQuestion V3 called successfully for game: $gamePin');
    } catch (e) {
      log('❌ Error in getPlayerNextQuestion V3: $e');
      log('❌ Error stack trace: ${StackTrace.current}');
      throw e;
    }
  }

  // ==================== EVENT LISTENERS ====================

  // Connection callbacks
  Function()? _onConnected;
  Function(String)? _onConnectionError;
  Function(Object?)? _onConnectionClosed;

  // Player events (giống Web app EventPlayerPage)
  Function(Map<String, dynamic>)? _onJoinedGame;
  Function(Map<String, dynamic>)? _onJoinRejected;
  Function(Map<String, dynamic>)? _onLobbyUpdated;
  Function(Map<String, dynamic>)? _onPlayerJoined;
  Function(Map<String, dynamic>)? _onGameStarted;
  Function(Map<String, dynamic>)? _onShowQuestion;
  Function(Map<String, dynamic>)? _onAnswerSubmitted;
  Function(Map<String, dynamic>)? _onPlayerScoreUpdated;
  Function(Map<String, dynamic>)? _onShowAnswerResult;
  Function(Map<String, dynamic>)? _onShowLeaderboard;
  Function(Map<String, dynamic>)? _onGameEnded;
  Function(Map<String, dynamic>)? _onGameCancelled;
  Function(Map<String, dynamic>)? _onGameForceEnded;

  // Boss Fight events (giống Web app EventPlayerPage)
  Function(Map<String, dynamic>)? _onBossFightModeEnabled;
  Function(Map<String, dynamic>)? _onLobbySettingsUpdated;
  Function(Map<String, dynamic>)? _onBossDamaged;
  Function(Map<String, dynamic>)? _onBossDefeated;
  Function(Map<String, dynamic>)? _onBossFightTimeUp;
  Function(Map<String, dynamic>)? _onBossFightQuestionsExhausted;
  Function(Map<String, dynamic>)? _onBossFightLeaderboard;
  Function(Map<String, dynamic>)? _onBossState;
  Function(Map<String, dynamic>)? _onBossFightAnswerResult;
  Function(Map<String, dynamic>)? _onPlayerQuestion;
  Function(Map<String, dynamic>)? _onPlayerCompletedAllQuestions;

  // Error callback
  Function(String)? _onError;

  /// Setup all event listeners (matching Web app EventPlayerPage exactly)
  void setupEventListeners({
    // Connection events
    Function()? onConnected,
    Function(String)? onConnectionError,
    Function(Object?)? onConnectionClosed,

    // Player events
    Function(Map<String, dynamic>)? onJoinedGame,
    Function(Map<String, dynamic>)? onJoinRejected,
    Function(Map<String, dynamic>)? onLobbyUpdated,
    Function(Map<String, dynamic>)? onPlayerJoined,
    Function(Map<String, dynamic>)? onGameStarted,
    Function(Map<String, dynamic>)? onShowQuestion,
    Function(Map<String, dynamic>)? onAnswerSubmitted,
    Function(Map<String, dynamic>)? onPlayerScoreUpdated,
    Function(Map<String, dynamic>)? onShowAnswerResult,
    Function(Map<String, dynamic>)? onShowLeaderboard,
    Function(Map<String, dynamic>)? onGameEnded,
    Function(Map<String, dynamic>)? onGameCancelled,
    Function(Map<String, dynamic>)? onGameForceEnded,

    // Boss Fight events
    Function(Map<String, dynamic>)? onBossFightModeEnabled,
    Function(Map<String, dynamic>)? onLobbySettingsUpdated,
    Function(Map<String, dynamic>)? onBossDamaged,
    Function(Map<String, dynamic>)? onBossDefeated,
    Function(Map<String, dynamic>)? onBossFightTimeUp,
    Function(Map<String, dynamic>)? onBossFightQuestionsExhausted,
    Function(Map<String, dynamic>)? onBossFightLeaderboard,
    Function(Map<String, dynamic>)? onBossState,
    Function(Map<String, dynamic>)? onBossFightAnswerResult,
    Function(Map<String, dynamic>)? onPlayerQuestion,
    Function(Map<String, dynamic>)? onPlayerCompletedAllQuestions,

    // Error
    Function(String)? onError,
  }) {
    // Store callbacks
    _onConnected = onConnected;
    _onConnectionError = onConnectionError;
    _onConnectionClosed = onConnectionClosed;
    _onJoinedGame = onJoinedGame;
    _onJoinRejected = onJoinRejected;
    _onLobbyUpdated = onLobbyUpdated;
    _onPlayerJoined = onPlayerJoined;
    _onGameStarted = onGameStarted;
    _onShowQuestion = onShowQuestion;
    _onAnswerSubmitted = onAnswerSubmitted;
    _onPlayerScoreUpdated = onPlayerScoreUpdated;
    _onShowAnswerResult = onShowAnswerResult;
    _onShowLeaderboard = onShowLeaderboard;
    _onGameEnded = onGameEnded;
    _onGameCancelled = onGameCancelled;
    _onGameForceEnded = onGameForceEnded;
    _onBossFightModeEnabled = onBossFightModeEnabled;
    _onLobbySettingsUpdated = onLobbySettingsUpdated;
    _onBossDamaged = onBossDamaged;
    _onBossDefeated = onBossDefeated;
    _onBossFightTimeUp = onBossFightTimeUp;
    _onBossFightQuestionsExhausted = onBossFightQuestionsExhausted;
    _onBossFightLeaderboard = onBossFightLeaderboard;
    _onBossState = onBossState;
    _onBossFightAnswerResult = onBossFightAnswerResult;
    _onPlayerQuestion = onPlayerQuestion;
    _onPlayerCompletedAllQuestions = onPlayerCompletedAllQuestions;
    _onError = onError;

    if (_connection == null) {
      log('⚠️ Warning: Cannot setup listeners V3, connection is null');
      return;
    }

    if (_connection!.state != HubConnectionState.Connected) {
      log('⚠️ Warning: Cannot setup listeners V3, connection state is: ${_connection!.state}');
      // Vẫn tiếp tục setup listeners, chúng sẽ được đăng ký khi connection ready
    }

    log('🔧 Setting up event listeners V3 (matching Web app EventPlayerPage)...');

    // ==================== CONNECTION & AUTH EVENTS ====================
    
    // Joined game successfully (giống Web app)
    _connection!.on('JoinedGame', (arguments) {
      log('✅ [SignalR EVENT] JoinedGame V3 received, arguments: $arguments');
      final parsedData = _parseArguments(arguments);
      log('✅ [SignalR EVENT] JoinedGame V3 parsed data: $parsedData');
      _onJoinedGame?.call(parsedData);
    });

    // Join rejected (authentication failed or other errors - giống Web app)
    _connection!.on('JoinRejected', (arguments) {
      log('❌ [SignalR EVENT] JoinRejected V3 received, arguments: $arguments');
      final parsedData = _parseArguments(arguments);
      _onJoinRejected?.call(parsedData);
    });

    // ==================== LOBBY EVENTS ====================
    
    // Lobby updated (player list - giống Web app)
    _connection!.on('LobbyUpdated', (arguments) {
      log('📋 [SignalR EVENT] LobbyUpdated V3 received');
      _onLobbyUpdated?.call(_parseArguments(arguments));
    });

    // New player joined (giống Web app)
    _connection!.on('PlayerJoined', (arguments) {
      log('👤 [SignalR EVENT] PlayerJoined V3 received');
      _onPlayerJoined?.call(_parseArguments(arguments));
    });

    // ==================== GAME START EVENTS ====================
    
    // Game started (giống Web app)
    _connection!.on('GameStarted', (arguments) {
      log('🎮 [SignalR EVENT] GameStarted V3 received');
      _onGameStarted?.call(_parseArguments(arguments));
    });

    // Show question (legacy - giống Web app)
    _connection!.on('ShowQuestion', (arguments) {
      log('❓ [SignalR EVENT] ShowQuestion V3 received');
      _onShowQuestion?.call(_parseArguments(arguments));
    });

    // Answer submitted confirmation (giống Web app)
    _connection!.on('AnswerSubmitted', (arguments) {
      log('✔️ [SignalR EVENT] AnswerSubmitted V3 received');
      _onAnswerSubmitted?.call(_parseArguments(arguments));
    });

    // Player score updated (giống Web app)
    _connection!.on('PlayerScoreUpdated', (arguments) {
      log('📊 [SignalR EVENT] PlayerScoreUpdated V3 received');
      _onPlayerScoreUpdated?.call(_parseArguments(arguments));
    });

    // Show answer result (legacy - giống Web app)
    _connection!.on('ShowAnswerResult', (arguments) {
      log('📊 [SignalR EVENT] ShowAnswerResult V3 received');
      _onShowAnswerResult?.call(_parseArguments(arguments));
    });

    // Show leaderboard (intermediate - giống Web app)
    _connection!.on('ShowLeaderboard', (arguments) {
      log('📊 [SignalR EVENT] ShowLeaderboard V3 received');
      _onShowLeaderboard?.call(_parseArguments(arguments));
    });

    // Game ended (legacy - giống Web app)
    _connection!.on('GameEnded', (arguments) {
      log('🏁 [SignalR EVENT] GameEnded V3 received');
      _onGameEnded?.call(_parseArguments(arguments));
    });

    // Game cancelled (giống Web app)
    _connection!.on('GameCancelled', (arguments) {
      log('❌ [SignalR EVENT] GameCancelled V3 received');
      _onGameCancelled?.call(_parseArguments(arguments));
    });

    // Game force ended (giống Web app)
    _connection!.on('GameForceEnded', (arguments) {
      log('🛑 [SignalR EVENT] GameForceEnded V3 received');
      _onGameForceEnded?.call(_parseArguments(arguments));
    });

    // ==================== BOSS FIGHT EVENTS ====================
    
    // Boss Fight mode enabled (giống Web app)
    _connection!.on('BossFightModeEnabled', (arguments) {
      log('🔥 [SignalR EVENT] BossFightModeEnabled V3 received');
      _onBossFightModeEnabled?.call(_parseArguments(arguments));
    });

    // Lobby settings updated (giống Web app)
    _connection!.on('LobbySettingsUpdated', (arguments) {
      log('⚙️ [SignalR EVENT] LobbySettingsUpdated V3 received');
      _onLobbySettingsUpdated?.call(_parseArguments(arguments));
    });

    // Boss damaged (global event - giống Web app)
    _connection!.on('BossDamaged', (arguments) {
      log('⚔️ [SignalR EVENT] BossDamaged V3 received');
      _onBossDamaged?.call(_parseArguments(arguments));
    });

    // Boss defeated (giống Web app)
    _connection!.on('BossDefeated', (arguments) {
      log('🎉 [SignalR EVENT] BossDefeated V3 received');
      _onBossDefeated?.call(_parseArguments(arguments));
    });

    // Boss fight time up (giống Web app)
    _connection!.on('BossFightTimeUp', (arguments) {
      log('⏰ [SignalR EVENT] BossFightTimeUp V3 received');
      _onBossFightTimeUp?.call(_parseArguments(arguments));
    });

    // Boss fight questions exhausted (giống Web app)
    _connection!.on('BossFightQuestionsExhausted', (arguments) {
      log('📝 [SignalR EVENT] BossFightQuestionsExhausted V3 received');
      _onBossFightQuestionsExhausted?.call(_parseArguments(arguments));
    });

    // Boss fight leaderboard (giống Web app)
    _connection!.on('BossFightLeaderboard', (arguments) {
      log('🏆 [SignalR EVENT] BossFightLeaderboard V3 received');
      _onBossFightLeaderboard?.call(_parseArguments(arguments));
    });

    // Boss state update (giống Web app)
    _connection!.on('BossState', (arguments) {
      log('💪 [SignalR EVENT] BossState V3 received');
      _onBossState?.call(_parseArguments(arguments));
    });

    // ==================== BOSS FIGHT INDIVIDUAL FLOW EVENTS ====================
    
    // Boss Fight answer result (immediate feedback - giống Web app)
    _connection!.on('BossFightAnswerResult', (arguments) {
      log('📢 [SignalR EVENT] BossFightAnswerResult V3 received, arguments: $arguments');
      final parsedData = _parseArguments(arguments);
      log('📢 [SignalR EVENT] BossFightAnswerResult V3 parsed data: $parsedData');
      if (_onBossFightAnswerResult != null) {
        _onBossFightAnswerResult!.call(parsedData);
        log('✅ [SignalR EVENT] BossFightAnswerResult V3 callback called');
      } else {
        log('⚠️ [SignalR EVENT] BossFightAnswerResult V3 callback is null!');
      }
    });

    // Player's next question (individual flow - giống Web app)
    _connection!.on('PlayerQuestion', (arguments) {
      log('🎯 [SignalR EVENT] PlayerQuestion V3 received');
      _onPlayerQuestion?.call(_parseArguments(arguments));
    });

    // Player completed all questions (giống Web app)
    _connection!.on('PlayerCompletedAllQuestions', (arguments) {
      log('✅ [SignalR EVENT] PlayerCompletedAllQuestions V3 received');
      _onPlayerCompletedAllQuestions?.call(_parseArguments(arguments));
    });

    // ==================== ERROR EVENT ====================
    _connection!.on('Error', (arguments) {
      log('❌ [SignalR EVENT] Error V3 received');
      final errorMessage = arguments?.isNotEmpty == true
          ? arguments![0].toString()
          : 'Unknown error';
      _onError?.call(errorMessage);
    });

    // ==================== CONNECTION STATE CHANGES ====================
    // Note: Flutter signalr_netcore package doesn't support onreconnecting/onreconnected callbacks
    // Reconnection is handled automatically by withAutomaticReconnect()

    log('✅ All event listeners V3 setup completed (matching Web app EventPlayerPage)');
  }

  /// Parse arguments from SignalR event
  Map<String, dynamic> _parseArguments(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return {};
    }

    // If argument is a Map, return directly
    if (arguments.length == 1 && arguments[0] is Map) {
      return Map<String, dynamic>.from(arguments[0] as Map);
    }

    // If it's a list of arguments, convert to Map
    final result = <String, dynamic>{};
    for (var i = 0; i < arguments.length; i++) {
      result['arg$i'] = arguments[i];
    }
    return result;
  }

  /// Get current game PIN
  String? get currentGamePin => _currentGamePin;

  /// Dispose resources
  void dispose() {
    disconnect();
    _connection = null;
    _currentGamePin = null;
    _isConnected = false;

    // Clear all callbacks
    _onConnected = null;
    _onConnectionError = null;
    _onConnectionClosed = null;
    _onJoinedGame = null;
    _onJoinRejected = null;
    _onLobbyUpdated = null;
    _onPlayerJoined = null;
    _onGameStarted = null;
    _onShowQuestion = null;
    _onAnswerSubmitted = null;
    _onPlayerScoreUpdated = null;
    _onShowAnswerResult = null;
    _onShowLeaderboard = null;
    _onGameEnded = null;
    _onGameCancelled = null;
    _onGameForceEnded = null;
    _onBossFightModeEnabled = null;
    _onLobbySettingsUpdated = null;
    _onBossDamaged = null;
    _onBossDefeated = null;
    _onBossFightTimeUp = null;
    _onBossFightQuestionsExhausted = null;
    _onBossFightLeaderboard = null;
    _onBossState = null;
    _onBossFightAnswerResult = null;
    _onPlayerQuestion = null;
    _onPlayerCompletedAllQuestions = null;
    _onError = null;
  }
}

