import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_response.dart';
import 'package:retrofit/retrofit.dart';

part 'single_mode_api.g.dart';

@RestApi()
abstract class SingleModeApi {
  factory SingleModeApi(Dio dio, {required String? baseUrl}) = _SingleModeApi;
  
  @POST('/quizattempt/single/start')
  Future<StartQuizResponse> startQuiz(@Body() StartQuizRequest request);

  @POST('/quizattemptdetail/submit')
  Future<SubmitAllAnswersResponse> submitAllAnswers(@Body() SubmitAllAnswersRequest request);

}
