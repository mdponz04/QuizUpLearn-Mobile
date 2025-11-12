import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_request.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_response.dart';
import 'package:retrofit/retrofit.dart';

part 'ai_quiz_api.g.dart';

@RestApi()
abstract class AIQuizApi {
  factory AIQuizApi(Dio dio, {required String? baseUrl}) = _AIQuizApi;
  
  @POST('/ai/generate-quiz-set')
  Future<GenerateQuizResponse> generateQuiz(
    @Query('quizPart') int quizPart,
    @Body() GenerateQuizRequest request,
  );
}

