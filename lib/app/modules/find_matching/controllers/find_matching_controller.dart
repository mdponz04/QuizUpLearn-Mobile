import 'dart:async';
import 'package:get/get.dart';
import '../models/matching_model.dart';
import '../data/matching_data.dart';

class FindMatchingController extends GetxController {
  // Event data from navigation
  late String eventId;
  late String eventTitle;
  late MatchingType matchingType;

  // Current player
  final currentPlayer = MatchingData.getCurrentPlayer().obs;

  // Matching session
  final matchingSession = Rxn<MatchingSessionModel>();
  final isSearching = false.obs;
  final searchProgress = 0.0.obs;
  final estimatedTime = 30.obs; // seconds

  // Available players for manual selection
  final availablePlayers = <MatchingModel>[].obs;
  final selectedPlayers = <MatchingModel>[].obs;

  // Timer for search animation
  Timer? _searchTimer;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    loadAvailablePlayers();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    _progressTimer?.cancel();
    super.onClose();
  }

  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      eventId = arguments['eventId'] ?? '';
      eventTitle = arguments['eventTitle'] ?? 'Quiz Event';
      final eventTypeString = arguments['eventType'] ?? 'oneOnOne';
      switch (eventTypeString) {
        case 'group':
          matchingType = MatchingType.group;
          break;
        case 'multiplayerSolo':
          matchingType = MatchingType.multiplayerSolo;
          break;
        default:
          matchingType = MatchingType.oneOnOne;
      }
    } else {
      // Default values for testing
      eventId = 'test_event';
      eventTitle = 'Test Quiz';
      matchingType = MatchingType.oneOnOne;
    }
  }

  void loadAvailablePlayers() {
    availablePlayers.value = MatchingData.getAvailablePlayers();
  }

  void startMatching() {
    if (isSearching.value) return;

    isSearching.value = true;
    searchProgress.value = 0.0;
    estimatedTime.value = 30;

    // Start search animation
    _startSearchAnimation();

    // Simulate finding opponents
    _simulateMatching();
  }

  void _startSearchAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (searchProgress.value < 0.9) {
        searchProgress.value += 0.01;
      }
    });
  }

  void _simulateMatching() {
    // Simulate network delay
    _searchTimer = Timer(const Duration(seconds: 3), () {
      _findOpponents();
    });
  }

  void _findOpponents() {
    _progressTimer?.cancel();
    searchProgress.value = 1.0;

    List<MatchingModel> opponents = [];
    
    if (matchingType == MatchingType.oneOnOne) {
      // For 1v1, find exactly 1 opponent
      final opponent = MatchingData.findBestMatch(currentPlayer.value, matchingType);
      if (opponent != null) {
        opponents = [opponent];
      }
    } else if (matchingType == MatchingType.group) {
      // For group, find exactly 3 teammates (total 4 players including current player)
      opponents = MatchingData.findGroupMembers(currentPlayer.value, 4);
    } else if (matchingType == MatchingType.multiplayerSolo) {
      // For multiplayer solo, find exactly 24 other players (total 25 players including current player)
      opponents = MatchingData.findMultiplayerSoloPlayers(currentPlayer.value, 25);
    }

    // Check if we have enough players for the match type
    final requiredPlayers = matchingType == MatchingType.oneOnOne ? 1 : 
                           matchingType == MatchingType.group ? 3 : 24;
    
    // For multiplayer solo, always create session (assume we can find enough players)
    if (matchingType == MatchingType.multiplayerSolo) {
      _createMatchingSession(opponents);
    } else if (opponents.length >= requiredPlayers) {
      _createMatchingSession(opponents);
    } else {
      _handleInsufficientPlayers(opponents.length, requiredPlayers);
    }
  }

  void _createMatchingSession(List<MatchingModel> opponents) {
    final session = MatchingData.createMatchingSession(
      eventId: eventId,
      eventTitle: eventTitle,
      type: matchingType,
      currentPlayer: currentPlayer.value,
      opponents: opponents,
    );

    matchingSession.value = session;
    isSearching.value = false;

    // Update session status to matched
    Timer(const Duration(seconds: 1), () {
      _updateSessionStatus(MatchingStatus.matched);
    });

    // Start quiz after a delay
    Timer(const Duration(seconds: 5), () {
      _startQuiz();
    });
  }

  void _updateSessionStatus(MatchingStatus status) {
    if (matchingSession.value != null) {
      final session = matchingSession.value!;
      final updatedSession = MatchingSessionModel(
        id: session.id,
        eventId: session.eventId,
        eventTitle: session.eventTitle,
        type: session.type,
        status: status,
        participants: session.participants,
        createdAt: session.createdAt,
        matchedAt: status == MatchingStatus.matched ? DateTime.now() : session.matchedAt,
        startedAt: status == MatchingStatus.inProgress ? DateTime.now() : session.startedAt,
        endedAt: session.endedAt,
        maxParticipants: session.maxParticipants,
        difficulty: session.difficulty,
        totalQuestions: session.totalQuestions,
        duration: session.duration,
      );
      matchingSession.value = updatedSession;
    }
  }

  void _startQuiz() {
    _updateSessionStatus(MatchingStatus.starting);
    
    Timer(const Duration(seconds: 2), () {
      _updateSessionStatus(MatchingStatus.inProgress);
      
      // Navigate to appropriate quiz screen based on matching type
      if (matchingType == MatchingType.oneOnOne) {
        // Navigate to 1v1 quiz screen
        Get.toNamed('/play-solo', arguments: {
          'sessionId': matchingSession.value?.id,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'opponent': matchingSession.value?.participants.firstWhere(
            (p) => p.id != currentPlayer.value.id
          ),
        });
      } else if (matchingType == MatchingType.group) {
        // Navigate to group quiz screen
        Get.snackbar(
          "Group Quiz",
          "Group quiz feature coming soon!",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (matchingType == MatchingType.multiplayerSolo) {
        // Navigate to multiplayer solo quiz screen
        Get.toNamed('/play-multi', arguments: {
          'sessionId': matchingSession.value?.id,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'participants': matchingSession.value?.participants,
        });
      }
    });
  }


  void _handleInsufficientPlayers(int found, int required) {
    isSearching.value = false;
    searchProgress.value = 0.0;
    
    final matchType = matchingType == MatchingType.oneOnOne ? "1v1" : "group";
    Get.snackbar(
      "Not Enough Players",
      "Found $found players, need $required for $matchType match. Try again later.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void cancelMatching() {
    _searchTimer?.cancel();
    _progressTimer?.cancel();
    isSearching.value = false;
    searchProgress.value = 0.0;
    matchingSession.value = null;
  }

  void selectPlayer(MatchingModel player) {
    if (selectedPlayers.contains(player)) {
      selectedPlayers.remove(player);
    } else {
      if (matchingType == MatchingType.oneOnOne) {
        selectedPlayers.clear();
        selectedPlayers.add(player);
      } else {
        if (selectedPlayers.length < 3) { // Max 3 other players for group
          selectedPlayers.add(player);
        }
      }
    }
  }

  void startCustomMatching() {
    final requiredPlayers = matchingType == MatchingType.oneOnOne ? 1 : 
                           matchingType == MatchingType.group ? 3 : 24;
    
    if (selectedPlayers.length < requiredPlayers) {
      final matchType = matchingType == MatchingType.oneOnOne ? "1v1" : 
                       matchingType == MatchingType.group ? "group" : "multiplayer solo";
      Get.snackbar(
        "Not Enough Players",
        "Please select $requiredPlayers players for $matchType match.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Take only the required number of players
    final playersToUse = selectedPlayers.take(requiredPlayers).toList();
    _createMatchingSession(playersToUse);
  }

  bool isPlayerSelected(MatchingModel player) {
    return selectedPlayers.contains(player);
  }

  bool canSelectMorePlayers() {
    if (matchingType == MatchingType.oneOnOne) {
      return selectedPlayers.isEmpty;
    } else if (matchingType == MatchingType.group) {
      return selectedPlayers.length < 3;
    } else {
      return selectedPlayers.length < 24;
    }
  }

  String get matchingTitle {
    try {
      return matchingType.displayName;
    } catch (e) {
      return "Find Matching";
    }
  }

  String get matchingDescription {
    try {
      return matchingType.description;
    } catch (e) {
      return "Find opponents to compete with";
    }
  }

  String get matchingIcon {
    try {
      return matchingType.icon;
    } catch (e) {
      return 'assets/images/do_quiz.png';
    }
  }

  String get matchingColor {
    try {
      return matchingType.color;
    } catch (e) {
      return '#3B82F6';
    }
  }

  List<MatchingModel> get otherParticipants {
    if (matchingSession.value == null) return [];
    return matchingSession.value!.participants
        .where((p) => p.id != currentPlayer.value.id)
        .toList();
  }
}
