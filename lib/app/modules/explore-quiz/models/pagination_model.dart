class PaginationModel {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final String? searchTerm;
  final String? sortBy;
  final String? sortDirection;

  PaginationModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.searchTerm,
    this.sortBy,
    this.sortDirection,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
      searchTerm: json['searchTerm']?.toString(),
      sortBy: json['sortBy']?.toString(),
      sortDirection: json['sortDirection']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
      'searchTerm': searchTerm,
      'sortBy': sortBy,
      'sortDirection': sortDirection,
    };
  }
}

