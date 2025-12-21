import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_report_api.g.dart';

@RestApi()
abstract class QuizReportApi {
  factory QuizReportApi(Dio dio, {required String? baseUrl}) = _QuizReportApi;
  
  @POST('/quizreport')
  Future<dynamic> reportQuiz(@Body() Map<String, dynamic> body);
}

