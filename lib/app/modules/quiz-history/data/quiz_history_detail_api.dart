import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_detail_model.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_history_detail_api.g.dart';

@RestApi()
abstract class QuizHistoryDetailApi {
  factory QuizHistoryDetailApi(Dio dio, {required String? baseUrl}) = _QuizHistoryDetailApi;
  
  @GET('/quizattemptdetail/attempt/{attemptId}')
  Future<QuizAttemptDetailResponse> getAttemptDetails(
    @Path('attemptId') String attemptId,
    @Query('isDeleted') bool isDeleted,
  );
}

