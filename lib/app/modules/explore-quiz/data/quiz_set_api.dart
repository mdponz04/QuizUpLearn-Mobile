import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_response.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_set_api.g.dart';

@RestApi()
abstract class QuizSetApi {
  factory QuizSetApi(Dio dio, {required String? baseUrl}) = _QuizSetApi;
  
  @GET('/quizset')
  Future<QuizSetResponse> getQuizSets();
}
