import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_response.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_set_detail_response.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_set_api.g.dart';

@RestApi()
abstract class QuizSetApi {
  factory QuizSetApi(Dio dio, {required String? baseUrl}) = _QuizSetApi;
  
  @POST('/quizset/published/search')
  Future<QuizSetResponse> getQuizSets(@Body() Map<String, dynamic> body);
  
  @POST('/quizset/search')
  Future<QuizSetResponse> searchQuizSets(@Body() Map<String, dynamic> body);
  
  @POST('/quizset/creator/search')
  Future<QuizSetResponse> getQuizSetsByCreator(@Query('creatorId') String userId, @Body() Map<String, dynamic> body);
  
  @GET('/quizset/{id}')
  Future<QuizSetDetailResponse> getQuizSetById(@Path('id') String id);
}
