import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_request.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_response.dart';
import 'package:retrofit/retrofit.dart';

part 'ai_quiz_api.g.dart';

@RestApi()
abstract class AIQuizApi {
  factory AIQuizApi(Dio dio, {required String? baseUrl}) = _AIQuizApi;
  
  @POST('/ai/generate-quiz-set-part-1')
  Future<GenerateQuizResponse> generateQuizPart1(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-2')
  Future<GenerateQuizResponse> generateQuizPart2(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-3')
  Future<GenerateQuizResponse> generateQuizPart3(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-4')
  Future<GenerateQuizResponse> generateQuizPart4(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-5')
  Future<GenerateQuizResponse> generateQuizPart5(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-6')
  Future<GenerateQuizResponse> generateQuizPart6(@Body() GenerateQuizRequest request);

  @POST('/ai/generate-quiz-set-part-7')
  Future<GenerateQuizResponse> generateQuizPart7(@Body() GenerateQuizRequest request);
}

