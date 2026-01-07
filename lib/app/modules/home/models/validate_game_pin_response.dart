class ValidateGamePinResponse {
  final bool success;
  final ValidateGamePinData? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  ValidateGamePinResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory ValidateGamePinResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where data is bool (true/false) or Map
    ValidateGamePinData? data;
    try {
      if (json['data'] != null) {
        if (json['data'] is bool) {
          // If data is bool, create ValidateGamePinData with isValid = data value
          data = ValidateGamePinData(
            isValid: json['data'] as bool,
            gamePin: null,
            status: null,
          );
        } else if (json['data'] is Map) {
          // If data is Map, parse normally
          try {
            data = ValidateGamePinData.fromJson(json['data'] as Map<String, dynamic>);
          } catch (e) {
            // Fallback: if parsing fails, treat as valid if data exists
            data = ValidateGamePinData(
              isValid: true,
              gamePin: null,
              status: null,
            );
          }
        }
      }
    } catch (e) {
      // If any error occurs, set data to null
      data = null;
    }
    
    return ValidateGamePinResponse(
      success: json['success'] ?? false,
      data: data,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

class ValidateGamePinData {
  final bool isValid;
  final String? gamePin;
  final String? status;

  ValidateGamePinData({
    required this.isValid,
    this.gamePin,
    this.status,
  });

  factory ValidateGamePinData.fromJson(Map<String, dynamic> json) {
    return ValidateGamePinData(
      isValid: json['isValid'] ?? json['valid'] ?? false,
      gamePin: json['gamePin'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'gamePin': gamePin,
      'status': status,
    };
  }
}

