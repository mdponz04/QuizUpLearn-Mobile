class MistakeQuizzesResponse {
  final List<dynamic>? data;

  MistakeQuizzesResponse({
    this.data,
  });

  factory MistakeQuizzesResponse.fromJson(Map<String, dynamic> json) {
    return MistakeQuizzesResponse(
      data: json['data'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }

  int get count => data?.length ?? 0;
}

