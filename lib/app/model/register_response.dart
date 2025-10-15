// To parse this JSON data, do
//
//     final registerResponse = registerResponseFromJson(jsonString);

import 'dart:convert';

RegisterResponse registerResponseFromJson(String str) => RegisterResponse.fromJson(json.decode(str));

String registerResponseToJson(RegisterResponse data) => json.encode(data.toJson());

class RegisterResponse {
    bool success;
    Data data;
    dynamic message;
    dynamic error;
    dynamic errorType;

    RegisterResponse({
        required this.success,
        required this.data,
        required this.message,
        required this.error,
        required this.errorType,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
        error: json["error"],
        errorType: json["errorType"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
        "error": error,
        "errorType": errorType,
    };
}

class Data {
    String id;
    String email;
    String userId;
    String roleId;
    bool isEmailVerified;
    dynamic lastLoginAt;
    int loginAttempts;
    dynamic lockoutUntil;
    bool isActive;
    bool isBanned;
    DateTime createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    Data({
        required this.id,
        required this.email,
        required this.userId,
        required this.roleId,
        required this.isEmailVerified,
        required this.lastLoginAt,
        required this.loginAttempts,
        required this.lockoutUntil,
        required this.isActive,
        required this.isBanned,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        email: json["email"],
        userId: json["userId"],
        roleId: json["roleId"],
        isEmailVerified: json["isEmailVerified"],
        lastLoginAt: json["lastLoginAt"],
        loginAttempts: json["loginAttempts"],
        lockoutUntil: json["lockoutUntil"],
        isActive: json["isActive"],
        isBanned: json["isBanned"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"],
        deletedAt: json["deletedAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "userId": userId,
        "roleId": roleId,
        "isEmailVerified": isEmailVerified,
        "lastLoginAt": lastLoginAt,
        "loginAttempts": loginAttempts,
        "lockoutUntil": lockoutUntil,
        "isActive": isActive,
        "isBanned": isBanned,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
    };
}
