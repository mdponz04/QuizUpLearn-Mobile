import '../models/matching_model.dart';

class MatchingData {
  static List<MatchingModel> getAvailablePlayers() {
    return [
      MatchingModel(
        id: 'player_1',
        name: 'Alex Johnson',
        avatar: 'assets/images/astrorocket.png',
        level: 15,
        rating: 1850,
        country: 'USA',
        isOnline: true,
        languages: ['English', 'Spanish'],
        totalMatches: 127,
        wins: 89,
        losses: 38,
        winRate: 0.70,
        preferredDifficulty: 'Advanced',
        interests: ['Grammar', 'Vocabulary', 'Literature'],
      ),
      MatchingModel(
        id: 'player_2',
        name: 'Sarah Chen',
        avatar: 'assets/images/astrorocket.png',
        level: 12,
        rating: 1720,
        country: 'Canada',
        isOnline: true,
        languages: ['English', 'French', 'Mandarin'],
        totalMatches: 95,
        wins: 67,
        losses: 28,
        winRate: 0.71,
        preferredDifficulty: 'Intermediate',
        interests: ['Business English', 'Speaking'],
      ),
      MatchingModel(
        id: 'player_3',
        name: 'Marco Silva',
        avatar: 'assets/images/astrorocket.png',
        level: 18,
        rating: 1980,
        country: 'Brazil',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
        languages: ['English', 'Portuguese', 'Spanish'],
        totalMatches: 203,
        wins: 156,
        losses: 47,
        winRate: 0.77,
        preferredDifficulty: 'Advanced',
        interests: ['Academic English', 'Writing'],
      ),
      MatchingModel(
        id: 'player_4',
        name: 'Emma Wilson',
        avatar: 'assets/images/astrorocket.png',
        level: 10,
        rating: 1650,
        country: 'UK',
        isOnline: true,
        languages: ['English'],
        totalMatches: 78,
        wins: 52,
        losses: 26,
        winRate: 0.67,
        preferredDifficulty: 'Intermediate',
        interests: ['Conversation', 'Pronunciation'],
      ),
      MatchingModel(
        id: 'player_5',
        name: 'Yuki Tanaka',
        avatar: 'assets/images/astrorocket.png',
        level: 14,
        rating: 1790,
        country: 'Japan',
        isOnline: true,
        languages: ['English', 'Japanese'],
        totalMatches: 112,
        wins: 78,
        losses: 34,
        winRate: 0.70,
        preferredDifficulty: 'Advanced',
        interests: ['Technical English', 'Reading'],
      ),
      MatchingModel(
        id: 'player_6',
        name: 'Ahmed Hassan',
        avatar: 'assets/images/astrorocket.png',
        level: 11,
        rating: 1680,
        country: 'Egypt',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        languages: ['English', 'Arabic'],
        totalMatches: 86,
        wins: 58,
        losses: 28,
        winRate: 0.67,
        preferredDifficulty: 'Intermediate',
        interests: ['General English', 'Listening'],
      ),
      MatchingModel(
        id: 'player_7',
        name: 'Lisa Park',
        avatar: 'assets/images/astrorocket.png',
        level: 16,
        rating: 1920,
        country: 'South Korea',
        isOnline: true,
        languages: ['English', 'Korean'],
        totalMatches: 145,
        wins: 108,
        losses: 37,
        winRate: 0.74,
        preferredDifficulty: 'Advanced',
        interests: ['IELTS', 'Academic Writing'],
      ),
      MatchingModel(
        id: 'player_8',
        name: 'Carlos Rodriguez',
        avatar: 'assets/images/astrorocket.png',
        level: 9,
        rating: 1580,
        country: 'Mexico',
        isOnline: true,
        languages: ['English', 'Spanish'],
        totalMatches: 64,
        wins: 41,
        losses: 23,
        winRate: 0.64,
        preferredDifficulty: 'Beginner',
        interests: ['Basic Grammar', 'Vocabulary'],
      ),
      // Additional players for multiplayer solo sessions
      MatchingModel(
        id: 'player_9',
        name: 'Emma Wilson',
        avatar: 'assets/images/astrorocket.png',
        level: 14,
        rating: 1790,
        country: 'UK',
        isOnline: true,
        languages: ['English', 'French'],
        totalMatches: 112,
        wins: 78,
        losses: 34,
        winRate: 0.70,
        preferredDifficulty: 'Intermediate',
        interests: ['Literature', 'Writing'],
      ),
      MatchingModel(
        id: 'player_10',
        name: 'David Kim',
        avatar: 'assets/images/astrorocket.png',
        level: 16,
        rating: 1920,
        country: 'South Korea',
        isOnline: true,
        languages: ['English', 'Korean', 'Japanese'],
        totalMatches: 156,
        wins: 108,
        losses: 48,
        winRate: 0.69,
        preferredDifficulty: 'Advanced',
        interests: ['Business English', 'TOEFL'],
      ),
      MatchingModel(
        id: 'player_11',
        name: 'Lisa Anderson',
        avatar: 'assets/images/astrorocket.png',
        level: 11,
        rating: 1650,
        country: 'Australia',
        isOnline: true,
        languages: ['English'],
        totalMatches: 89,
        wins: 56,
        losses: 33,
        winRate: 0.63,
        preferredDifficulty: 'Intermediate',
        interests: ['Speaking', 'Pronunciation'],
      ),
      MatchingModel(
        id: 'player_12',
        name: 'Ahmed Hassan',
        avatar: 'assets/images/astrorocket.png',
        level: 13,
        rating: 1740,
        country: 'Egypt',
        isOnline: true,
        languages: ['English', 'Arabic', 'French'],
        totalMatches: 98,
        wins: 67,
        losses: 31,
        winRate: 0.68,
        preferredDifficulty: 'Intermediate',
        interests: ['Grammar', 'Reading'],
      ),
      MatchingModel(
        id: 'player_13',
        name: 'Yuki Tanaka',
        avatar: 'assets/images/astrorocket.png',
        level: 17,
        rating: 1950,
        country: 'Japan',
        isOnline: true,
        languages: ['English', 'Japanese'],
        totalMatches: 134,
        wins: 92,
        losses: 42,
        winRate: 0.69,
        preferredDifficulty: 'Advanced',
        interests: ['IELTS', 'Academic English'],
      ),
      MatchingModel(
        id: 'player_14',
        name: 'Maria Garcia',
        avatar: 'assets/images/astrorocket.png',
        level: 10,
        rating: 1620,
        country: 'Spain',
        isOnline: true,
        languages: ['English', 'Spanish', 'Catalan'],
        totalMatches: 76,
        wins: 48,
        losses: 28,
        winRate: 0.63,
        preferredDifficulty: 'Beginner',
        interests: ['Basic Vocabulary', 'Conversation'],
      ),
      MatchingModel(
        id: 'player_15',
        name: 'James Thompson',
        avatar: 'assets/images/astrorocket.png',
        level: 19,
        rating: 2010,
        country: 'New Zealand',
        isOnline: true,
        languages: ['English', 'Maori'],
        totalMatches: 178,
        wins: 125,
        losses: 53,
        winRate: 0.70,
        preferredDifficulty: 'Advanced',
        interests: ['Literature', 'Creative Writing'],
      ),
      MatchingModel(
        id: 'player_16',
        name: 'Anna Petrov',
        avatar: 'assets/images/astrorocket.png',
        level: 12,
        rating: 1680,
        country: 'Russia',
        isOnline: true,
        languages: ['English', 'Russian', 'German'],
        totalMatches: 87,
        wins: 58,
        losses: 29,
        winRate: 0.67,
        preferredDifficulty: 'Intermediate',
        interests: ['Grammar', 'Vocabulary'],
      ),
      MatchingModel(
        id: 'player_17',
        name: 'Hassan Ali',
        avatar: 'assets/images/astrorocket.png',
        level: 15,
        rating: 1820,
        country: 'Pakistan',
        isOnline: true,
        languages: ['English', 'Urdu', 'Arabic'],
        totalMatches: 103,
        wins: 71,
        losses: 32,
        winRate: 0.69,
        preferredDifficulty: 'Intermediate',
        interests: ['Business English', 'Speaking'],
      ),
      MatchingModel(
        id: 'player_18',
        name: 'Sophie Martin',
        avatar: 'assets/images/astrorocket.png',
        level: 8,
        rating: 1550,
        country: 'France',
        isOnline: true,
        languages: ['English', 'French'],
        totalMatches: 59,
        wins: 36,
        losses: 23,
        winRate: 0.61,
        preferredDifficulty: 'Beginner',
        interests: ['Basic Grammar', 'Vocabulary'],
      ),
      MatchingModel(
        id: 'player_19',
        name: 'Raj Patel',
        avatar: 'assets/images/astrorocket.png',
        level: 16,
        rating: 1890,
        country: 'India',
        isOnline: true,
        languages: ['English', 'Hindi', 'Gujarati'],
        totalMatches: 142,
        wins: 98,
        losses: 44,
        winRate: 0.69,
        preferredDifficulty: 'Advanced',
        interests: ['IELTS', 'Academic Writing'],
      ),
      MatchingModel(
        id: 'player_20',
        name: 'Jennifer Lee',
        avatar: 'assets/images/astrorocket.png',
        level: 13,
        rating: 1760,
        country: 'Singapore',
        isOnline: true,
        languages: ['English', 'Mandarin', 'Malay'],
        totalMatches: 94,
        wins: 64,
        losses: 30,
        winRate: 0.68,
        preferredDifficulty: 'Intermediate',
        interests: ['Business English', 'TOEFL'],
      ),
      MatchingModel(
        id: 'player_21',
        name: 'Michael Brown',
        avatar: 'assets/images/astrorocket.png',
        level: 11,
        rating: 1640,
        country: 'Ireland',
        isOnline: true,
        languages: ['English', 'Irish'],
        totalMatches: 81,
        wins: 52,
        losses: 29,
        winRate: 0.64,
        preferredDifficulty: 'Intermediate',
        interests: ['Speaking', 'Literature'],
      ),
      MatchingModel(
        id: 'player_22',
        name: 'Fatima Al-Zahra',
        avatar: 'assets/images/astrorocket.png',
        level: 14,
        rating: 1780,
        country: 'UAE',
        isOnline: true,
        languages: ['English', 'Arabic', 'French'],
        totalMatches: 108,
        wins: 74,
        losses: 34,
        winRate: 0.69,
        preferredDifficulty: 'Intermediate',
        interests: ['Business English', 'Speaking'],
      ),
      MatchingModel(
        id: 'player_23',
        name: 'Thomas Mueller',
        avatar: 'assets/images/astrorocket.png',
        level: 17,
        rating: 1940,
        country: 'Germany',
        isOnline: true,
        languages: ['English', 'German', 'French'],
        totalMatches: 129,
        wins: 89,
        losses: 40,
        winRate: 0.69,
        preferredDifficulty: 'Advanced',
        interests: ['Academic English', 'IELTS'],
      ),
      MatchingModel(
        id: 'player_24',
        name: 'Isabella Rossi',
        avatar: 'assets/images/astrorocket.png',
        level: 9,
        rating: 1590,
        country: 'Italy',
        isOnline: true,
        languages: ['English', 'Italian', 'Spanish'],
        totalMatches: 67,
        wins: 42,
        losses: 25,
        winRate: 0.63,
        preferredDifficulty: 'Beginner',
        interests: ['Basic Grammar', 'Vocabulary'],
      ),
      MatchingModel(
        id: 'player_25',
        name: 'Chen Wei',
        avatar: 'assets/images/astrorocket.png',
        level: 18,
        rating: 1970,
        country: 'China',
        isOnline: true,
        languages: ['English', 'Mandarin', 'Cantonese'],
        totalMatches: 151,
        wins: 105,
        losses: 46,
        winRate: 0.70,
        preferredDifficulty: 'Advanced',
        interests: ['TOEFL', 'Academic Writing'],
      ),
      MatchingModel(
        id: 'player_26',
        name: 'Olga Kowalski',
        avatar: 'assets/images/astrorocket.png',
        level: 12,
        rating: 1700,
        country: 'Poland',
        isOnline: true,
        languages: ['English', 'Polish', 'German'],
        totalMatches: 92,
        wins: 61,
        losses: 31,
        winRate: 0.66,
        preferredDifficulty: 'Intermediate',
        interests: ['Grammar', 'Reading'],
      ),
      MatchingModel(
        id: 'player_27',
        name: 'Pedro Santos',
        avatar: 'assets/images/astrorocket.png',
        level: 15,
        rating: 1830,
        country: 'Portugal',
        isOnline: true,
        languages: ['English', 'Portuguese', 'Spanish'],
        totalMatches: 115,
        wins: 79,
        losses: 36,
        winRate: 0.69,
        preferredDifficulty: 'Intermediate',
        interests: ['Business English', 'Speaking'],
      ),
      MatchingModel(
        id: 'player_28',
        name: 'Nina Johansson',
        avatar: 'assets/images/astrorocket.png',
        level: 10,
        rating: 1610,
        country: 'Sweden',
        isOnline: true,
        languages: ['English', 'Swedish', 'Norwegian'],
        totalMatches: 73,
        wins: 46,
        losses: 27,
        winRate: 0.63,
        preferredDifficulty: 'Beginner',
        interests: ['Basic Vocabulary', 'Conversation'],
      ),
      MatchingModel(
        id: 'player_29',
        name: 'Viktor Petrov',
        avatar: 'assets/images/astrorocket.png',
        level: 16,
        rating: 1900,
        country: 'Bulgaria',
        isOnline: true,
        languages: ['English', 'Bulgarian', 'Russian'],
        totalMatches: 137,
        wins: 94,
        losses: 43,
        winRate: 0.69,
        preferredDifficulty: 'Advanced',
        interests: ['IELTS', 'Academic English'],
      ),
      MatchingModel(
        id: 'player_30',
        name: 'Amara Okafor',
        avatar: 'assets/images/astrorocket.png',
        level: 13,
        rating: 1750,
        country: 'Nigeria',
        isOnline: true,
        languages: ['English', 'Yoruba', 'Hausa'],
        totalMatches: 96,
        wins: 65,
        losses: 31,
        winRate: 0.68,
        preferredDifficulty: 'Intermediate',
        interests: ['Speaking', 'Business English'],
      ),
    ];
  }

  static List<MatchingModel> getOnlinePlayers() {
    return getAvailablePlayers().where((player) => player.isOnline).toList();
  }

  static List<MatchingModel> getPlayersByLevel(int minLevel, int maxLevel) {
    return getAvailablePlayers().where((player) => 
        player.level >= minLevel && player.level <= maxLevel).toList();
  }

  static List<MatchingModel> getPlayersByRating(int minRating, int maxRating) {
    return getAvailablePlayers().where((player) => 
        player.rating >= minRating && player.rating <= maxRating).toList();
  }

  static List<MatchingModel> getPlayersByDifficulty(String difficulty) {
    return getAvailablePlayers().where((player) => 
        player.preferredDifficulty.toLowerCase() == difficulty.toLowerCase()).toList();
  }

  static MatchingModel? findBestMatch(MatchingModel currentPlayer, MatchingType type) {
    final availablePlayers = getOnlinePlayers()
        .where((player) => player.id != currentPlayer.id)
        .toList();

    if (availablePlayers.isEmpty) return null;

    // Simple matching algorithm based on rating and level
    availablePlayers.sort((a, b) {
      final ratingDiffA = (a.rating - currentPlayer.rating).abs();
      final ratingDiffB = (b.rating - currentPlayer.rating).abs();
      final levelDiffA = (a.level - currentPlayer.level).abs();
      final levelDiffB = (b.level - currentPlayer.level).abs();
      
      // Prioritize by rating difference, then level difference
      if (ratingDiffA != ratingDiffB) {
        return ratingDiffA.compareTo(ratingDiffB);
      }
      return levelDiffA.compareTo(levelDiffB);
    });

    return availablePlayers.first;
  }

  static List<MatchingModel> findGroupMembers(MatchingModel currentPlayer, int groupSize) {
    final availablePlayers = getOnlinePlayers()
        .where((player) => player.id != currentPlayer.id)
        .toList();

    if (availablePlayers.isEmpty) return [];

    // Find players with similar skill level
    final currentRating = currentPlayer.rating;
    final ratingRange = 200; // ±200 rating points
    
    final suitablePlayers = availablePlayers.where((player) =>
        (player.rating - currentRating).abs() <= ratingRange).toList();

    // Sort by rating proximity and take the required number
    suitablePlayers.sort((a, b) {
      final ratingDiffA = (a.rating - currentRating).abs();
      final ratingDiffB = (b.rating - currentRating).abs();
      return ratingDiffA.compareTo(ratingDiffB);
    });

    return suitablePlayers.take(groupSize - 1).toList(); // -1 because current player is already included
  }

  static List<MatchingModel> findMultiplayerSoloPlayers(MatchingModel currentPlayer, int totalPlayers) {
    final availablePlayers = getOnlinePlayers()
        .where((player) => player.id != currentPlayer.id)
        .toList();

    // For multiplayer solo, always return exactly 24 players (total 25 including current player)
    final requiredPlayers = totalPlayers - 1; // 24 players needed
    
    if (availablePlayers.length < requiredPlayers) {
      // If we don't have enough online players, use all available players
      // In real app, this would be handled by server-side matching
      return availablePlayers.take(requiredPlayers).toList();
    }

    // Sort by rating proximity to current player
    final currentRating = currentPlayer.rating;
    availablePlayers.sort((a, b) {
      final ratingDiffA = (a.rating - currentRating).abs();
      final ratingDiffB = (b.rating - currentRating).abs();
      return ratingDiffA.compareTo(ratingDiffB);
    });

    // Return exactly 24 players (closest to current player's rating)
    return availablePlayers.take(requiredPlayers).toList();
  }

  static MatchingSessionModel createMatchingSession({
    required String eventId,
    required String eventTitle,
    required MatchingType type,
    required MatchingModel currentPlayer,
    List<MatchingModel>? opponents,
  }) {
    final now = DateTime.now();
    final sessionId = 'session_${now.millisecondsSinceEpoch}';
    
    List<MatchingModel> participants = [currentPlayer];
    if (opponents != null) {
      participants.addAll(opponents);
    }

    return MatchingSessionModel(
      id: sessionId,
      eventId: eventId,
      eventTitle: eventTitle,
      type: type,
      status: MatchingStatus.waiting,
      participants: participants,
      createdAt: now,
      maxParticipants: type == MatchingType.oneOnOne ? 2 : 
                      type == MatchingType.group ? 4 : 25,
      difficulty: 'Intermediate', // Default difficulty
      totalQuestions: 20,
      duration: 15,
    );
  }

  static MatchingModel getCurrentPlayer() {
    // This would typically come from user authentication
    return MatchingModel(
      id: 'current_player',
      name: 'You',
      avatar: 'assets/images/astrorocket.png',
      level: 13,
      rating: 1750,
      country: 'Vietnam',
      isOnline: true,
      languages: ['English', 'Vietnamese'],
      totalMatches: 98,
      wins: 72,
      losses: 26,
      winRate: 0.73,
      preferredDifficulty: 'Intermediate',
      interests: ['Grammar', 'Speaking', 'Business English'],
    );
  }
}
