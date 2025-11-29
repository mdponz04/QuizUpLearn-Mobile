import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_history_model.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_history_api.g.dart';

@RestApi()
abstract class QuizHistoryApi {
  factory QuizHistoryApi(Dio dio, {required String? baseUrl}) = _QuizHistoryApi;
  
  @GET('/quizattempt/user/{userId}/history')
  Future<QuizAttemptHistoryResponse> getUserHistory(
    @Path('userId') String userId, {
    @Query('quizSetId') String? quizSetId,
    @Query('status') String? status,
    @Query('attemptType') String? attemptType,
  });
}

