import 'dart:async';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';

/// GameHubService V2 - Improved version based on Web app structure
/// 
/// Key improvements:
/// - Better state management
/// - Cleaner event handling
/// - Improved error handling
/// - Better separation of concerns
class GameHubServiceV2 {
  HubConnection? _connection;
  String? _currentGamePin;
  bool _isConnected = false;

  // ==================== CONNECTION MANAGEMENT ====================

  /// Connect to SignalR Hub
  Future<bool> connect(String baseUrl) async {
    try {
      final hubUrl = '$baseUrl/game-hub';

      _connection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .withAutomaticReconnect()
          .build();

      // Setup connection lifecycle
      _connection!.onclose(({error}) {
        _isConnected = false;
        log('SignalR connection closed: $error');
        _onConnectionClosed?.call(error);
      });

      await _connection!.start();
      _isConnected = true;
      log('✅ SignalR V2 connected successfully');
      _onConnected?.call();
      return true;
    } catch (e) {
      log('❌ Error connecting to SignalR V2: $e');
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
        log('SignalR V2 disconnected');
      }
    } catch (e) {
      log('Error disconnecting SignalR V2: $e');
    }
  }

  /// Check connection status
  bool get isConnected => _isConnected && _connection?.state == HubConnectionState.Connected;

  // ==================== PLAYER METHODS ====================

  /// Player join game
  Future<void> joinGame(String gamePin, String playerName) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentGamePin = gamePin;
      await _connection!.invoke('JoinGame', args: [gamePin, playerName]);
      log('JoinGame V2 called: $playerName joined game $gamePin');
    } catch (e) {
      log('Error in joinGame V2: $e');
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
      log('LeaveGame V2 called for game: $gamePin');
    } catch (e) {
      log('Error in leaveGame V2: $e');
      throw e;
    }
  }

  /// Player submit answer (normal mode)
  Future<void> submitAnswer(String gamePin, String questionId, String answerId) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('SubmitAnswer', args: [gamePin, questionId, answerId]);
      log('SubmitAnswer V2 called: questionId=$questionId, answerId=$answerId');
    } catch (e) {
      log('Error in submitAnswer V2: $e');
      throw e;
    }
  }

  /// Player submit Boss Fight answer (per-player flow)
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
      log('SubmitBossFightAnswer V2 called: questionId=$questionId, answerId=$answerId');
    } catch (e) {
      log('Error in submitBossFightAnswer V2: $e');
      throw e;
    }
  }

  /// Player request next question (Boss Fight per-player flow)
  Future<void> getPlayerNextQuestion(String gamePin) async {
    try {
      log('📤 getPlayerNextQuestion V2 - Checking connection...');
      if (!isConnected) {
        log('❌ getPlayerNextQuestion V2 - Not connected to SignalR');
        throw Exception('Not connected to SignalR');
      }
      log('📤 getPlayerNextQuestion V2 - Connection OK, invoking GetPlayerNextQuestion with gamePin: $gamePin');
      await _connection!.invoke('GetPlayerNextQuestion', args: [gamePin]);
      log('✅ GetPlayerNextQuestion V2 called successfully for game: $gamePin');
    } catch (e) {
      log('❌ Error in getPlayerNextQuestion V2: $e');
      log('❌ Error stack trace: ${StackTrace.current}');
      throw e;
    }
  }

  // ==================== HOST METHODS ====================

  /// Host connect to game
  Future<void> hostConnect(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentGamePin = gamePin;
      await _connection!.invoke('HostConnect', args: [gamePin]);
      log('HostConnect V2 called for game: $gamePin');
    } catch (e) {
      log('Error in hostConnect V2: $e');
      throw e;
    }
  }

  /// Host start game
  Future<void> startGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('StartGame', args: [gamePin]);
      log('StartGame V2 called for game: $gamePin');
    } catch (e) {
      log('Error in startGame V2: $e');
      throw e;
    }
  }

  /// Host show question result
  Future<void> showQuestionResult(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('ShowQuestionResult', args: [gamePin]);
      log('ShowQuestionResult V2 called for game: $gamePin');
    } catch (e) {
      log('Error in showQuestionResult V2: $e');
      throw e;
    }
  }

  /// Host next question
  Future<void> nextQuestion(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('NextQuestion', args: [gamePin]);
      log('NextQuestion V2 called for game: $gamePin');
    } catch (e) {
      log('Error in nextQuestion V2: $e');
      throw e;
    }
  }

  /// Host cancel game
  Future<void> cancelGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('CancelGame', args: [gamePin]);
      log('CancelGame V2 called for game: $gamePin');
    } catch (e) {
      log('Error in cancelGame V2: $e');
      throw e;
    }
  }

  // ==================== BOSS FIGHT MODE METHODS ====================

  /// Host enable Boss Fight mode
  Future<void> enableBossFightMode(
    String gamePin, {
    int bossHP = 10000,
    int? timeLimitSeconds,
    int questionTimeLimitSeconds = 30,
    bool autoNextQuestion = true,
  }) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      final args = <dynamic>[
        gamePin,
        bossHP,
        timeLimitSeconds,
        questionTimeLimitSeconds,
        autoNextQuestion,
      ];
      await _connection!.invoke('EnableBossFightMode', args: args.cast<Object>());
      log('EnableBossFightMode V2 called: bossHP=$bossHP, timeLimit=$timeLimitSeconds');
    } catch (e) {
      log('Error in enableBossFightMode V2: $e');
      throw e;
    }
  }

  /// Host broadcast lobby settings
  Future<void> broadcastLobbySettings(
    String gamePin, {
    required int bossMaxHP,
    int? timeLimitSeconds,
    required int questionTimeLimitSeconds,
  }) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      final args = <dynamic>[
        gamePin,
        bossMaxHP,
        timeLimitSeconds,
        questionTimeLimitSeconds,
      ];
      await _connection!.invoke('BroadcastLobbySettings', args: args.cast<Object>());
      log('BroadcastLobbySettings V2 called: bossMaxHP=$bossMaxHP');
    } catch (e) {
      log('Error in broadcastLobbySettings V2: $e');
      throw e;
    }
  }

  /// Boss Fight: Auto move to next question
  Future<void> bossFightNextQuestion(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('BossFightNextQuestion', args: [gamePin]);
      log('BossFightNextQuestion V2 called for game: $gamePin');
    } catch (e) {
      log('Error in bossFightNextQuestion V2: $e');
      throw e;
    }
  }

  /// Get realtime leaderboard
  Future<void> getRealtimeLeaderboard(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('GetRealtimeLeaderboard', args: [gamePin]);
      log('GetRealtimeLeaderboard V2 called for game: $gamePin');
    } catch (e) {
      log('Error in getRealtimeLeaderboard V2: $e');
      throw e;
    }
  }

  /// Host force end game
  Future<void> forceEndGame(String gamePin, {String reason = 'Game ended by moderator'}) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('ForceEndGame', args: [gamePin, reason]);
      log('ForceEndGame V2 called for game: $gamePin, reason: $reason');
    } catch (e) {
      log('Error in forceEndGame V2: $e');
      throw e;
    }
  }

  // ==================== EVENT LISTENERS ====================

  // Connection callbacks
  Function()? _onConnected;
  Function(String)? _onConnectionError;
  Function(Object?)? _onConnectionClosed;

  // Player events
  Function(Map<String, dynamic>)? _onJoinedGame;
  Function(Map<String, dynamic>)? _onLobbyUpdated;
  Function(Map<String, dynamic>)? _onPlayerJoined;
  Function(Map<String, dynamic>)? _onPlayerLeft;
  Function(Map<String, dynamic>)? _onPlayerDisconnected;
  Function(Map<String, dynamic>)? _onGameStarted;
  Function(Map<String, dynamic>)? _onShowQuestion;
  Function(Map<String, dynamic>)? _onAnswerSubmitted;
  Function(Map<String, dynamic>)? _onShowAnswerResult;
  Function(Map<String, dynamic>)? _onShowLeaderboard;
  Function(Map<String, dynamic>)? _onGameEnded;
  Function(Map<String, dynamic>)? _onGameCancelled;

  // Boss Fight events
  Function(Map<String, dynamic>)? _onBossFightModeEnabled;
  Function(Map<String, dynamic>)? _onLobbySettingsUpdated;
  Function(Map<String, dynamic>)? _onBossDamaged;
  Function(Map<String, dynamic>)? _onBossDefeated;
  Function(Map<String, dynamic>)? _onBossFightTimeUp;
  Function(Map<String, dynamic>)? _onBossFightQuestionsExhausted;
  Function(Map<String, dynamic>)? _onBossFightAnswerResult;
  Function(Map<String, dynamic>)? _onPlayerQuestion;
  Function(Map<String, dynamic>)? _onRealtimeLeaderboard;
  Function(Map<String, dynamic>)? _onBossFightLeaderboard;
  Function(Map<String, dynamic>)? _onBossState;
  Function(Map<String, dynamic>)? _onGameForceEnded;

  // Error callback
  Function(String)? _onError;

  /// Setup all event listeners (based on Web app structure)
  void setupEventListeners({
    // Connection events
    Function()? onConnected,
    Function(String)? onConnectionError,
    Function(Object?)? onConnectionClosed,

    // Player events
    Function(Map<String, dynamic>)? onJoinedGame,
    Function(Map<String, dynamic>)? onLobbyUpdated,
    Function(Map<String, dynamic>)? onPlayerJoined,
    Function(Map<String, dynamic>)? onPlayerLeft,
    Function(Map<String, dynamic>)? onPlayerDisconnected,
    Function(Map<String, dynamic>)? onGameStarted,
    Function(Map<String, dynamic>)? onShowQuestion,
    Function(Map<String, dynamic>)? onAnswerSubmitted,
    Function(Map<String, dynamic>)? onShowAnswerResult,
    Function(Map<String, dynamic>)? onShowLeaderboard,
    Function(Map<String, dynamic>)? onGameEnded,
    Function(Map<String, dynamic>)? onGameCancelled,

    // Boss Fight events
    Function(Map<String, dynamic>)? onBossFightModeEnabled,
    Function(Map<String, dynamic>)? onLobbySettingsUpdated,
    Function(Map<String, dynamic>)? onBossDamaged,
    Function(Map<String, dynamic>)? onBossDefeated,
    Function(Map<String, dynamic>)? onBossFightTimeUp,
    Function(Map<String, dynamic>)? onBossFightQuestionsExhausted,
    Function(Map<String, dynamic>)? onBossFightAnswerResult,
    Function(Map<String, dynamic>)? onPlayerQuestion,
    Function(Map<String, dynamic>)? onRealtimeLeaderboard,
    Function(Map<String, dynamic>)? onBossFightLeaderboard,
    Function(Map<String, dynamic>)? onBossState,
    Function(Map<String, dynamic>)? onGameForceEnded,

    // Error
    Function(String)? onError,
  }) {
    // Store callbacks
    _onConnected = onConnected;
    _onConnectionError = onConnectionError;
    _onConnectionClosed = onConnectionClosed;
    _onJoinedGame = onJoinedGame;
    _onLobbyUpdated = onLobbyUpdated;
    _onPlayerJoined = onPlayerJoined;
    _onPlayerLeft = onPlayerLeft;
    _onPlayerDisconnected = onPlayerDisconnected;
    _onGameStarted = onGameStarted;
    _onShowQuestion = onShowQuestion;
    _onAnswerSubmitted = onAnswerSubmitted;
    _onShowAnswerResult = onShowAnswerResult;
    _onShowLeaderboard = onShowLeaderboard;
    _onGameEnded = onGameEnded;
    _onGameCancelled = onGameCancelled;
    _onBossFightModeEnabled = onBossFightModeEnabled;
    _onLobbySettingsUpdated = onLobbySettingsUpdated;
    _onBossDamaged = onBossDamaged;
    _onBossDefeated = onBossDefeated;
    _onBossFightTimeUp = onBossFightTimeUp;
    _onBossFightQuestionsExhausted = onBossFightQuestionsExhausted;
    _onBossFightAnswerResult = onBossFightAnswerResult;
    _onPlayerQuestion = onPlayerQuestion;
    _onRealtimeLeaderboard = onRealtimeLeaderboard;
    _onBossFightLeaderboard = onBossFightLeaderboard;
    _onBossState = onBossState;
    _onGameForceEnded = onGameForceEnded;
    _onError = onError;

    if (_connection == null) {
      log('⚠️ Warning: Cannot setup listeners V2, connection is null');
      return;
    }

    if (_connection!.state != HubConnectionState.Connected) {
      log('⚠️ Warning: Cannot setup listeners V2, connection state is: ${_connection!.state}');
      // Vẫn tiếp tục setup listeners, chúng sẽ được đăng ký khi connection ready
    }

    log('🔧 Setting up event listeners V2...');

    // ==================== PLAYER EVENTS ====================
    _connection!.on('JoinedGame', (arguments) {
      log('Event V2: JoinedGame received, arguments: $arguments');
      final parsedData = _parseArguments(arguments);
      log('Event V2: JoinedGame parsed data: $parsedData');
      _onJoinedGame?.call(parsedData);
      log('Event V2: JoinedGame callback called');
    });

    _connection!.on('LobbyUpdated', (arguments) {
      log('Event V2: LobbyUpdated');
      _onLobbyUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerJoined', (arguments) {
      log('Event V2: PlayerJoined');
      _onPlayerJoined?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerLeft', (arguments) {
      log('Event V2: PlayerLeft');
      _onPlayerLeft?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerDisconnected', (arguments) {
      log('Event V2: PlayerDisconnected');
      _onPlayerDisconnected?.call(_parseArguments(arguments));
    });

    _connection!.on('GameStarted', (arguments) {
      log('Event V2: GameStarted');
      _onGameStarted?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowQuestion', (arguments) {
      log('Event V2: ShowQuestion');
      _onShowQuestion?.call(_parseArguments(arguments));
    });

    _connection!.on('AnswerSubmitted', (arguments) {
      log('Event V2: AnswerSubmitted');
      _onAnswerSubmitted?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowAnswerResult', (arguments) {
      log('Event V2: ShowAnswerResult');
      _onShowAnswerResult?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowLeaderboard', (arguments) {
      log('Event V2: ShowLeaderboard');
      _onShowLeaderboard?.call(_parseArguments(arguments));
    });

    _connection!.on('GameEnded', (arguments) {
      log('Event V2: GameEnded');
      _onGameEnded?.call(_parseArguments(arguments));
    });

    _connection!.on('GameCancelled', (arguments) {
      log('Event V2: GameCancelled');
      _onGameCancelled?.call(_parseArguments(arguments));
    });

    // ==================== BOSS FIGHT EVENTS ====================
    _connection!.on('BossFightModeEnabled', (arguments) {
      log('Event V2: BossFightModeEnabled');
      _onBossFightModeEnabled?.call(_parseArguments(arguments));
    });

    _connection!.on('LobbySettingsUpdated', (arguments) {
      log('Event V2: LobbySettingsUpdated');
      _onLobbySettingsUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('BossDamaged', (arguments) {
      log('Event V2: BossDamaged');
      _onBossDamaged?.call(_parseArguments(arguments));
    });

    _connection!.on('BossDefeated', (arguments) {
      log('Event V2: BossDefeated');
      _onBossDefeated?.call(_parseArguments(arguments));
    });

    _connection!.on('BossFightTimeUp', (arguments) {
      log('Event V2: BossFightTimeUp');
      _onBossFightTimeUp?.call(_parseArguments(arguments));
    });

    _connection!.on('BossFightQuestionsExhausted', (arguments) {
      log('Event V2: BossFightQuestionsExhausted');
      _onBossFightQuestionsExhausted?.call(_parseArguments(arguments));
    });

    _connection!.on('BossFightAnswerResult', (arguments) {
      log('✅ Event V2: BossFightAnswerResult received, arguments: $arguments');
      final parsedData = _parseArguments(arguments);
      log('✅ Event V2: BossFightAnswerResult parsed data: $parsedData');
      if (_onBossFightAnswerResult != null) {
        _onBossFightAnswerResult!.call(parsedData);
        log('✅ Event V2: BossFightAnswerResult callback called');
      } else {
        log('⚠️ Event V2: BossFightAnswerResult callback is null!');
      }
    });

    _connection!.on('PlayerQuestion', (arguments) {
      log('Event V2: PlayerQuestion');
      _onPlayerQuestion?.call(_parseArguments(arguments));
    });

    _connection!.on('RealtimeLeaderboard', (arguments) {
      log('Event V2: RealtimeLeaderboard');
      _onRealtimeLeaderboard?.call(_parseArguments(arguments));
    });

    _connection!.on('BossFightLeaderboard', (arguments) {
      log('Event V2: BossFightLeaderboard');
      _onBossFightLeaderboard?.call(_parseArguments(arguments));
    });

    _connection!.on('BossState', (arguments) {
      log('Event V2: BossState');
      _onBossState?.call(_parseArguments(arguments));
    });

    _connection!.on('GameForceEnded', (arguments) {
      log('Event V2: GameForceEnded');
      _onGameForceEnded?.call(_parseArguments(arguments));
    });

    // ==================== ERROR EVENT ====================
    _connection!.on('Error', (arguments) {
      log('Event V2: Error');
      final errorMessage = arguments?.isNotEmpty == true
          ? arguments![0].toString()
          : 'Unknown error';
      _onError?.call(errorMessage);
    });

    log('✅ All event listeners V2 setup completed');
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
    _onLobbyUpdated = null;
    _onPlayerJoined = null;
    _onPlayerLeft = null;
    _onPlayerDisconnected = null;
    _onGameStarted = null;
    _onShowQuestion = null;
    _onAnswerSubmitted = null;
    _onShowAnswerResult = null;
    _onShowLeaderboard = null;
    _onGameEnded = null;
    _onGameCancelled = null;
    _onBossFightModeEnabled = null;
    _onLobbySettingsUpdated = null;
    _onBossDamaged = null;
    _onBossDefeated = null;
    _onBossFightTimeUp = null;
    _onBossFightQuestionsExhausted = null;
    _onBossFightAnswerResult = null;
    _onPlayerQuestion = null;
    _onRealtimeLeaderboard = null;
    _onBossFightLeaderboard = null;
    _onBossState = null;
    _onGameForceEnded = null;
    _onError = null;
  }
}

