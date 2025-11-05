import 'dart:async';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';

/// Service để quản lý SignalR connection với GameHub
/// Quản lý tất cả các events và methods cho Host và Player
class GameHubService {
  HubConnection? _connection;
  String? _currentGamePin;
  bool _isConnected = false;

  // ==================== CONNECTION MANAGEMENT ====================

  /// Khởi tạo và kết nối đến SignalR Hub
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
      log('SignalR connected successfully');
      _onConnected?.call();
      return true;
    } catch (e) {
      log('Error connecting to SignalR: $e');
      _isConnected = false;
      _onConnectionError?.call(e.toString());
      return false;
    }
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.stop();
        _connection = null;
        _isConnected = false;
        _currentGamePin = null;
        log('SignalR disconnected');
      }
    } catch (e) {
      log('Error disconnecting SignalR: $e');
    }
  }

  /// Kiểm tra trạng thái kết nối
  bool get isConnected => _isConnected && _connection?.state == HubConnectionState.Connected;

  // ==================== HOST METHODS ====================

  /// Host kết nối vào game sau khi tạo (qua API)
  Future<void> hostConnect(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentGamePin = gamePin;
      await _connection!.invoke('HostConnect', args: [gamePin]);
      log('HostConnect called for game: $gamePin');
    } catch (e) {
      log('Error in hostConnect: $e');
      throw e;
    }
  }

  /// Host bắt đầu game
  Future<void> startGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('StartGame', args: [gamePin]);
      log('StartGame called for game: $gamePin');
    } catch (e) {
      log('Error in startGame: $e');
      throw e;
    }
  }

  /// Host đặt thời gian cho câu hỏi hiện tại (giây)
  Future<void> setCurrentQuestionTime(String gamePin, int seconds) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('SetCurrentQuestionTime', args: [gamePin, seconds]);
      log('SetCurrentQuestionTime called: $seconds seconds');
    } catch (e) {
      log('Error in setCurrentQuestionTime: $e');
      throw e;
    }
  }

  /// Host trigger hiển thị kết quả câu hỏi
  Future<void> showQuestionResult(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('ShowQuestionResult', args: [gamePin]);
      log('ShowQuestionResult called for game: $gamePin');
    } catch (e) {
      log('Error in showQuestionResult: $e');
      throw e;
    }
  }

  /// Host chuyển sang câu hỏi tiếp theo
  Future<void> nextQuestion(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('NextQuestion', args: [gamePin]);
      log('NextQuestion called for game: $gamePin');
    } catch (e) {
      log('Error in nextQuestion: $e');
      throw e;
    }
  }

  /// Host hủy game
  Future<void> cancelGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('CancelGame', args: [gamePin]);
      log('CancelGame called for game: $gamePin');
    } catch (e) {
      log('Error in cancelGame: $e');
      throw e;
    }
  }

  // ==================== PLAYER METHODS ====================

  /// Player join vào game bằng PIN
  Future<void> joinGame(String gamePin, String playerName) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentGamePin = gamePin;
      await _connection!.invoke('JoinGame', args: [gamePin, playerName]);
      log('JoinGame called: $playerName joined game $gamePin');
    } catch (e) {
      log('Error in joinGame: $e');
      throw e;
    }
  }

  /// Player rời game (trước khi start)
  Future<void> leaveGame(String gamePin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('LeaveGame', args: [gamePin]);
      log('LeaveGame called for game: $gamePin');
    } catch (e) {
      log('Error in leaveGame: $e');
      throw e;
    }
  }

  /// Player submit câu trả lời
  Future<void> submitAnswer(String gamePin, String questionId, String answerId) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('SubmitAnswer', args: [gamePin, questionId, answerId]);
      log('SubmitAnswer called: questionId=$questionId, answerId=$answerId');
    } catch (e) {
      log('Error in submitAnswer: $e');
      throw e;
    }
  }

  // ==================== EVENT LISTENERS ====================

  // Callbacks cho connection events
  Function()? _onConnected;
  Function(String)? _onConnectionError;
  Function(Object?)? _onConnectionClosed;

  // Callbacks cho Host events
  Function(Map<String, dynamic>)? _onHostConnected;
  Function(Map<String, dynamic>)? _onLobbyUpdated;
  Function(Map<String, dynamic>)? _onPlayerJoined;
  Function(Map<String, dynamic>)? _onPlayerLeft;
  Function(Map<String, dynamic>)? _onPlayerDisconnected;
  Function(Map<String, dynamic>)? _onGameStarted;
  Function(Map<String, dynamic>)? _onShowQuestion;
  Function(Map<String, dynamic>)? _onQuestionTimeUpdated;
  Function(Map<String, dynamic>)? _onAnswerCount;
  Function(Map<String, dynamic>)? _onUpdateLeaderboard;
  Function(Map<String, dynamic>)? _onPlayerScoreUpdated;
  Function(Map<String, dynamic>)? _onShowAnswerResult;
  Function(Map<String, dynamic>)? _onShowLeaderboard;
  Function(Map<String, dynamic>)? _onGameEnded;
  Function(Map<String, dynamic>)? _onGameCancelled;

  // Callbacks cho Player events
  Function(Map<String, dynamic>)? _onJoinedGame;
  Function(Map<String, dynamic>)? _onAnswerSubmitted;

  // Error callback
  Function(String)? _onError;

  /// Setup tất cả event listeners
  void setupEventListeners({
    // Connection events
    Function()? onConnected,
    Function(String)? onConnectionError,
    Function(Object?)? onConnectionClosed,

    // Host events
    Function(Map<String, dynamic>)? onHostConnected,
    Function(Map<String, dynamic>)? onLobbyUpdated,
    Function(Map<String, dynamic>)? onPlayerJoined,
    Function(Map<String, dynamic>)? onPlayerLeft,
    Function(Map<String, dynamic>)? onPlayerDisconnected,
    Function(Map<String, dynamic>)? onGameStarted,
    Function(Map<String, dynamic>)? onShowQuestion,
    Function(Map<String, dynamic>)? onQuestionTimeUpdated,
    Function(Map<String, dynamic>)? onAnswerCount,
    Function(Map<String, dynamic>)? onUpdateLeaderboard,
    Function(Map<String, dynamic>)? onPlayerScoreUpdated,
    Function(Map<String, dynamic>)? onShowAnswerResult,
    Function(Map<String, dynamic>)? onShowLeaderboard,
    Function(Map<String, dynamic>)? onGameEnded,
    Function(Map<String, dynamic>)? onGameCancelled,

    // Player events
    Function(Map<String, dynamic>)? onJoinedGame,
    Function(Map<String, dynamic>)? onAnswerSubmitted,

    // Error
    Function(String)? onError,
  }) {
    // Store callbacks
    _onConnected = onConnected;
    _onConnectionError = onConnectionError;
    _onConnectionClosed = onConnectionClosed;
    _onHostConnected = onHostConnected;
    _onLobbyUpdated = onLobbyUpdated;
    _onPlayerJoined = onPlayerJoined;
    _onPlayerLeft = onPlayerLeft;
    _onPlayerDisconnected = onPlayerDisconnected;
    _onGameStarted = onGameStarted;
    _onShowQuestion = onShowQuestion;
    _onQuestionTimeUpdated = onQuestionTimeUpdated;
    _onAnswerCount = onAnswerCount;
    _onUpdateLeaderboard = onUpdateLeaderboard;
    _onPlayerScoreUpdated = onPlayerScoreUpdated;
    _onShowAnswerResult = onShowAnswerResult;
    _onShowLeaderboard = onShowLeaderboard;
    _onGameEnded = onGameEnded;
    _onGameCancelled = onGameCancelled;
    _onJoinedGame = onJoinedGame;
    _onAnswerSubmitted = onAnswerSubmitted;
    _onError = onError;

    if (_connection == null) {
      log('Warning: Cannot setup listeners, connection is null');
      return;
    }

    // ==================== CONNECTION EVENTS ====================
    // (Handled in connect() method)

    // ==================== HOST EVENTS ====================
    _connection!.on('HostConnected', (arguments) {
      log('Event: HostConnected');
      _onHostConnected?.call(_parseArguments(arguments));
    });

    _connection!.on('LobbyUpdated', (arguments) {
      log('Event: LobbyUpdated');
      _onLobbyUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerJoined', (arguments) {
      log('Event: PlayerJoined');
      _onPlayerJoined?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerLeft', (arguments) {
      log('Event: PlayerLeft');
      _onPlayerLeft?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerDisconnected', (arguments) {
      log('Event: PlayerDisconnected');
      _onPlayerDisconnected?.call(_parseArguments(arguments));
    });

    _connection!.on('GameStarted', (arguments) {
      log('Event: GameStarted');
      _onGameStarted?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowQuestion', (arguments) {
      log('Event: ShowQuestion');
      _onShowQuestion?.call(_parseArguments(arguments));
    });

    _connection!.on('QuestionTimeUpdated', (arguments) {
      log('Event: QuestionTimeUpdated');
      _onQuestionTimeUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('AnswerCount', (arguments) {
      log('Event: AnswerCount');
      _onAnswerCount?.call(_parseArguments(arguments));
    });

    _connection!.on('UpdateLeaderboard', (arguments) {
      log('Event: UpdateLeaderboard');
      _onUpdateLeaderboard?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerScoreUpdated', (arguments) {
      log('Event: PlayerScoreUpdated');
      _onPlayerScoreUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowAnswerResult', (arguments) {
      log('Event: ShowAnswerResult');
      _onShowAnswerResult?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowLeaderboard', (arguments) {
      log('Event: ShowLeaderboard');
      _onShowLeaderboard?.call(_parseArguments(arguments));
    });

    _connection!.on('GameEnded', (arguments) {
      log('Event: GameEnded');
      _onGameEnded?.call(_parseArguments(arguments));
    });

    _connection!.on('GameCancelled', (arguments) {
      log('Event: GameCancelled');
      _onGameCancelled?.call(_parseArguments(arguments));
    });

    // ==================== PLAYER EVENTS ====================
    _connection!.on('JoinedGame', (arguments) {
      log('Event: JoinedGame');
      _onJoinedGame?.call(_parseArguments(arguments));
    });

    _connection!.on('AnswerSubmitted', (arguments) {
      log('Event: AnswerSubmitted');
      _onAnswerSubmitted?.call(_parseArguments(arguments));
    });

    // ==================== ERROR EVENT ====================
    _connection!.on('Error', (arguments) {
      log('Event: Error');
      final errorMessage = arguments?.isNotEmpty == true 
          ? arguments![0].toString() 
          : 'Unknown error';
      _onError?.call(errorMessage);
    });

    log('All event listeners setup completed');
  }

  /// Parse arguments từ SignalR event
  Map<String, dynamic> _parseArguments(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return {};
    }

    // Nếu argument là một object (Map), trả về trực tiếp
    if (arguments.length == 1 && arguments[0] is Map) {
      return Map<String, dynamic>.from(arguments[0] as Map);
    }

    // Nếu là list các arguments, convert sang Map
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
    _onHostConnected = null;
    _onLobbyUpdated = null;
    _onPlayerJoined = null;
    _onPlayerLeft = null;
    _onPlayerDisconnected = null;
    _onGameStarted = null;
    _onShowQuestion = null;
    _onQuestionTimeUpdated = null;
    _onAnswerCount = null;
    _onUpdateLeaderboard = null;
    _onPlayerScoreUpdated = null;
    _onShowAnswerResult = null;
    _onShowLeaderboard = null;
    _onGameEnded = null;
    _onGameCancelled = null;
    _onJoinedGame = null;
    _onAnswerSubmitted = null;
    _onError = null;
  }
}

