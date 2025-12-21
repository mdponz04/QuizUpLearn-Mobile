class MistakeQuizzesResponse {
  final List<dynamic>? data;
  final Pagination? pagination;

  MistakeQuizzesResponse({
    this.data,
    this.pagination,
  });

  factory MistakeQuizzesResponse.fromJson(Map<String, dynamic> json) {
    return MistakeQuizzesResponse(
      data: json['data'] as List<dynamic>?,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'pagination': pagination?.toJson(),
    };
  }

  int get count => data?.length ?? 0;
  
  // Get total count from pagination
  int get totalCount => pagination?.totalCount ?? 0;
}

class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final String? searchTerm;
  final String? sortBy;
  final String? sortDirection;

  Pagination({
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

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
      searchTerm: json['searchTerm'],
      sortBy: json['sortBy'],
      sortDirection: json['sortDirection'],
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

