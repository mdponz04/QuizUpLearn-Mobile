import 'dart:async';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

/// Service để quản lý SignalR connection với OneVsOneHub
/// Quản lý tất cả các events và methods cho Player1 và Player2
class OneVsOneHubService {
  HubConnection? _connection;
  String? _currentRoomPin;
  bool _isConnected = false;

  // ==================== CONNECTION MANAGEMENT ====================

  /// Khởi tạo và kết nối đến SignalR Hub
  Future<bool> connect(String baseUrl) async {
    try {
      final hubUrl = '$baseUrl/one-vs-one-hub';
      
      // Lấy access token từ BaseCommon
      final accessToken = await BaseCommon.instance.getAccessToken();
      if (accessToken == null) {
        log('Error: No access token found');
        _onConnectionError?.call('No access token found. Please login again.');
        return false;
      }

      // Tạo HttpConnectionOptions với access token
      final httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => accessToken,
      );

      _connection = HubConnectionBuilder()
          .withUrl(hubUrl, options: httpOptions)
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
      log('SignalR connected successfully to OneVsOneHub');
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
        _currentRoomPin = null;
        log('SignalR disconnected');
      }
    } catch (e) {
      log('Error disconnecting SignalR: $e');
    }
  }

  /// Kiểm tra trạng thái kết nối
  bool get isConnected => _isConnected && _connection?.state == HubConnectionState.Connected;

  // ==================== PLAYER1 METHODS ====================

  /// Player1 kết nối vào room sau khi tạo (qua API)
  Future<void> player1Connect(String roomPin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentRoomPin = roomPin;
      await _connection!.invoke('Player1Connect', args: [roomPin]);
      log('Player1Connect called for room: $roomPin');
    } catch (e) {
      log('Error in player1Connect: $e');
      throw e;
    }
  }

  /// Player1 bắt đầu game
  Future<void> startGame(String roomPin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('StartGame', args: [roomPin]);
      log('StartGame called for room: $roomPin');
    } catch (e) {
      log('Error in startGame: $e');
      throw e;
    }
  }

  /// Player1 hủy room
  Future<void> cancelRoom(String roomPin) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('CancelRoom', args: [roomPin]);
      log('CancelRoom called for room: $roomPin');
    } catch (e) {
      log('Error in cancelRoom: $e');
      throw e;
    }
  }

  // ==================== PLAYER2 METHODS ====================

  /// Player2 join vào room bằng PIN
  Future<void> player2Join(String roomPin, String playerName) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      _currentRoomPin = roomPin;
      await _connection!.invoke('Player2Join', args: [roomPin, playerName]);
      log('Player2Join called: $playerName joined room $roomPin');
    } catch (e) {
      log('Error in player2Join: $e');
      throw e;
    }
  }

  // ==================== COMMON METHODS ====================

  /// Player submit câu trả lời
  Future<void> submitAnswer(String roomPin, String questionId, String answerId) async {
    try {
      if (!isConnected) {
        throw Exception('Not connected to SignalR');
      }
      await _connection!.invoke('SubmitAnswer', args: [roomPin, questionId, answerId]);
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

  // Callbacks cho Player1 events
  Function(Map<String, dynamic>)? _onPlayer1Connected;
  
  // Callbacks cho Player2 events
  Function(Map<String, dynamic>)? _onPlayer2Joined;
  
  // Callbacks cho common events
  Function(Map<String, dynamic>)? _onPlayerJoined;
  Function(Map<String, dynamic>)? _onRoomUpdated;
  Function(Map<String, dynamic>)? _onRoomReady;
  Function(Map<String, dynamic>)? _onGameStarted;
  Function(Map<String, dynamic>)? _onShowQuestion;
  Function(Map<String, dynamic>)? _onAnswerSubmitted;
  Function(Map<String, dynamic>)? _onShowRoundResult;
  Function(Map<String, dynamic>)? _onGameEnded;
  Function(Map<String, dynamic>)? _onRoomCancelled;
  Function(Map<String, dynamic>)? _onPlayerDisconnected;

  // Error callback
  Function(String)? _onError;

  /// Setup tất cả event listeners
  void setupEventListeners({
    // Connection events
    Function()? onConnected,
    Function(String)? onConnectionError,
    Function(Object?)? onConnectionClosed,

    // Player1 events
    Function(Map<String, dynamic>)? onPlayer1Connected,

    // Player2 events
    Function(Map<String, dynamic>)? onPlayer2Joined,

    // Common events
    Function(Map<String, dynamic>)? onPlayerJoined,
    Function(Map<String, dynamic>)? onRoomUpdated,
    Function(Map<String, dynamic>)? onRoomReady,
    Function(Map<String, dynamic>)? onGameStarted,
    Function(Map<String, dynamic>)? onShowQuestion,
    Function(Map<String, dynamic>)? onAnswerSubmitted,
    Function(Map<String, dynamic>)? onShowRoundResult,
    Function(Map<String, dynamic>)? onGameEnded,
    Function(Map<String, dynamic>)? onRoomCancelled,
    Function(Map<String, dynamic>)? onPlayerDisconnected,

    // Error
    Function(String)? onError,
  }) {
    // Store callbacks
    _onConnected = onConnected;
    _onConnectionError = onConnectionError;
    _onConnectionClosed = onConnectionClosed;
    _onPlayer1Connected = onPlayer1Connected;
    _onPlayer2Joined = onPlayer2Joined;
    _onPlayerJoined = onPlayerJoined;
    _onRoomUpdated = onRoomUpdated;
    _onRoomReady = onRoomReady;
    _onGameStarted = onGameStarted;
    _onShowQuestion = onShowQuestion;
    _onAnswerSubmitted = onAnswerSubmitted;
    _onShowRoundResult = onShowRoundResult;
    _onGameEnded = onGameEnded;
    _onRoomCancelled = onRoomCancelled;
    _onPlayerDisconnected = onPlayerDisconnected;
    _onError = onError;

    if (_connection == null) {
      log('Warning: Cannot setup listeners, connection is null');
      return;
    }

    // ==================== CONNECTION EVENTS ====================
    // (Handled in connect() method)

    // ==================== PLAYER1 EVENTS ====================
    _connection!.on('Player1Connected', (arguments) {
      log('Event: Player1Connected');
      _onPlayer1Connected?.call(_parseArguments(arguments));
    });

    // ==================== PLAYER2 EVENTS ====================
    _connection!.on('Player2Joined', (arguments) {
      log('Event: Player2Joined');
      _onPlayer2Joined?.call(_parseArguments(arguments));
    });

    // ==================== COMMON EVENTS ====================
    _connection!.on('PlayerJoined', (arguments) {
      log('Event: PlayerJoined');
      _onPlayerJoined?.call(_parseArguments(arguments));
    });

    _connection!.on('RoomUpdated', (arguments) {
      log('Event: RoomUpdated');
      _onRoomUpdated?.call(_parseArguments(arguments));
    });

    _connection!.on('RoomReady', (arguments) {
      log('Event: RoomReady');
      _onRoomReady?.call(_parseArguments(arguments));
    });

    _connection!.on('GameStarted', (arguments) {
      log('Event: GameStarted');
      _onGameStarted?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowQuestion', (arguments) {
      log('Event: ShowQuestion');
      _onShowQuestion?.call(_parseArguments(arguments));
    });

    _connection!.on('AnswerSubmitted', (arguments) {
      log('Event: AnswerSubmitted');
      _onAnswerSubmitted?.call(_parseArguments(arguments));
    });

    _connection!.on('ShowRoundResult', (arguments) {
      log('Event: ShowRoundResult');
      _onShowRoundResult?.call(_parseArguments(arguments));
    });

    _connection!.on('GameEnded', (arguments) {
      log('Event: GameEnded');
      _onGameEnded?.call(_parseArguments(arguments));
    });

    _connection!.on('RoomCancelled', (arguments) {
      log('Event: RoomCancelled');
      _onRoomCancelled?.call(_parseArguments(arguments));
    });

    _connection!.on('PlayerDisconnected', (arguments) {
      log('Event: PlayerDisconnected');
      _onPlayerDisconnected?.call(_parseArguments(arguments));
    });

    // ==================== ERROR EVENT ====================
    _connection!.on('Error', (arguments) {
      log('Event: Error');
      final errorMessage = arguments?.isNotEmpty == true 
          ? arguments![0].toString() 
          : 'Unknown error';
      _onError?.call(errorMessage);
    });

    log('All event listeners setup completed for OneVsOneHub');
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

  /// Get current room PIN
  String? get currentRoomPin => _currentRoomPin;

  /// Dispose resources
  void dispose() {
    disconnect();
    _connection = null;
    _currentRoomPin = null;
    _isConnected = false;
    
    // Clear all callbacks
    _onConnected = null;
    _onConnectionError = null;
    _onConnectionClosed = null;
    _onPlayer1Connected = null;
    _onPlayer2Joined = null;
    _onPlayerJoined = null;
    _onRoomUpdated = null;
    _onRoomReady = null;
    _onGameStarted = null;
    _onShowQuestion = null;
    _onAnswerSubmitted = null;
    _onShowRoundResult = null;
    _onGameEnded = null;
    _onRoomCancelled = null;
    _onPlayerDisconnected = null;
    _onError = null;
  }
}

