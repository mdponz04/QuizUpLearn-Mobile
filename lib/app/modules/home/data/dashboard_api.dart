import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/mistake_quizzes_response.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_response.dart';
import 'package:retrofit/retrofit.dart';

part 'dashboard_api.g.dart';

@RestApi()
abstract class DashboardApi {
  factory DashboardApi(Dio dio, {required String? baseUrl}) = _DashboardApi;
  
  @GET('/dashboard')
  Future<DashboardResponse> getDashboard();
  
  @GET('/userweakpoint/user')
  Future<UserWeakPointResponse> getUserWeakPoints();
  
  @GET('/usermistake/mistake-quizzes/user')
  Future<MistakeQuizzesResponse> getMistakeQuizzes(
    @Query('Page') int page,
    @Query('PageSize') int pageSize,
  );
  
  @POST('/usermistake/mistake-quizzes/start')
  Future<StartQuizResponse> startMistakeQuiz(@Body() StartQuizRequest request);
  
  @POST('/usermistake/mistake-quizzes/submit')
  Future<SubmitAllAnswersResponse> submitMistakeQuiz(@Body() SubmitAllAnswersRequest request);
}

