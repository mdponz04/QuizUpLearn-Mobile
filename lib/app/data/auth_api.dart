import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/model/login_request.dart';
import 'package:quizkahoot/app/model/login_response.dart';
import 'package:quizkahoot/app/model/register_response.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {required String? baseUrl}) = _AuthApi;
  
  @POST('/auth/login')
  Future<LoginReponse> login(@Body() Map<String, dynamic> queryParams);

  @POST('/auth/register')
  Future<RegisterResponse> register(@Body() Map<String, dynamic> queryParams);
}