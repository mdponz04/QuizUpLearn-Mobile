import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_answer_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_answer_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/finish_quiz_response.dart';
import 'package:retrofit/retrofit.dart';

part 'single_mode_api.g.dart';

@RestApi()
abstract class SingleModeApi {
  factory SingleModeApi(Dio dio, {required String? baseUrl}) = _SingleModeApi;
  
  @POST('/quizattempt/single/start')
  Future<StartQuizResponse> startQuiz(@Body() StartQuizRequest request);

  @POST('/quizattemptdetail')
  Future<SubmitAnswerResponse> submitAnswer(@Body() SubmitAnswerRequest request);

  @POST('/quizattempt/{attemptId}/finish')
  Future<FinishQuizResponse> finishQuiz(@Path('attemptId') String attemptId);
}
