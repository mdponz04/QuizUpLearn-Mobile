import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_response.dart';
import 'package:retrofit/retrofit.dart';

part 'dashboard_api.g.dart';

@RestApi()
abstract class DashboardApi {
  factory DashboardApi(Dio dio, {required String? baseUrl}) = _DashboardApi;
  
  @GET('/dashboard')
  Future<DashboardResponse> getDashboard();
  
  @GET('/userweakpoint/user')
  Future<UserWeakPointResponse> getUserWeakPoints();
}

