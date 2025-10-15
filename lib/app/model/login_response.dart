// To parse this JSON data, do
//
//     final loginReponse = loginReponseFromJson(jsonString);

import 'dart:convert';

LoginReponse loginReponseFromJson(String str) => LoginReponse.fromJson(json.decode(str));

String loginReponseToJson(LoginReponse data) => json.encode(data.toJson());

class LoginReponse {
    bool success;
    Data data;
    dynamic message;
    dynamic error;
    dynamic errorType;

    LoginReponse({
        required this.success,
        required this.data,
        required this.message,
        required this.error,
        required this.errorType,
    });

    factory LoginReponse.fromJson(Map<String, dynamic> json) => LoginReponse(
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
    Account account;
    String accessToken;
    DateTime expiresAt;
    String refreshToken;
    DateTime refreshExpiresAt;

    Data({
        required this.account,
        required this.accessToken,
        required this.expiresAt,
        required this.refreshToken,
        required this.refreshExpiresAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        account: Account.fromJson(json["account"]),
        accessToken: json["accessToken"],
        expiresAt: DateTime.parse(json["expiresAt"]),
        refreshToken: json["refreshToken"],
        refreshExpiresAt: DateTime.parse(json["refreshExpiresAt"]),
    );

    Map<String, dynamic> toJson() => {
        "account": account.toJson(),
        "accessToken": accessToken,
        "expiresAt": expiresAt.toIso8601String(),
        "refreshToken": refreshToken,
        "refreshExpiresAt": refreshExpiresAt.toIso8601String(),
    };
}

class Account {
    String id;
    String email;
    String userId;
    String roleId;
    bool isEmailVerified;
    DateTime lastLoginAt;
    int loginAttempts;
    dynamic lockoutUntil;
    bool isActive;
    bool isBanned;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    Account({
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

    factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        email: json["email"],
        userId: json["userId"],
        roleId: json["roleId"],
        isEmailVerified: json["isEmailVerified"],
        lastLoginAt: DateTime.parse(json["lastLoginAt"]),
        loginAttempts: json["loginAttempts"],
        lockoutUntil: json["lockoutUntil"],
        isActive: json["isActive"],
        isBanned: json["isBanned"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "userId": userId,
        "roleId": roleId,
        "isEmailVerified": isEmailVerified,
        "lastLoginAt": lastLoginAt.toIso8601String(),
        "loginAttempts": loginAttempts,
        "lockoutUntil": lockoutUntil,
        "isActive": isActive,
        "isBanned": isBanned,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "deletedAt": deletedAt,
    };
}
