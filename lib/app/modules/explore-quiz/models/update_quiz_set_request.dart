class UpdateQuizSetRequest {
  final String title;
  final String description;
  final bool isPublished;
  final bool isPremiumOnly;

  UpdateQuizSetRequest({
    required this.title,
    required this.description,
    required this.isPublished,
    required this.isPremiumOnly,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Description': description,
      'IsPublished': isPublished,
      'IsPremiumOnly': isPremiumOnly,
    };
  }
}

