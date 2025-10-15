// To parse this JSON data, do
//
//     final registerRequest = registerRequestFromJson(jsonString);

import 'dart:convert';

RegisterRequest registerRequestFromJson(String str) => RegisterRequest.fromJson(json.decode(str));

String registerRequestToJson(RegisterRequest data) => json.encode(data.toJson());

class RegisterRequest {
    String confirmPassword;
    String email;
    String fullName;
    String password;

    RegisterRequest({
        required this.confirmPassword,
        required this.email,
        required this.fullName,
        required this.password,
    });

    factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
        confirmPassword: json["confirmPassword"],
        email: json["email"],
        fullName: json["fullName"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "confirmPassword": confirmPassword,
        "email": email,
        "fullName": fullName,
        "password": password,
    };
}
