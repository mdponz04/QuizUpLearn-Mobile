import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_comment_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/create_quiz_set_comment_response.dart';
import 'package:retrofit/retrofit.dart';

part 'quiz_set_comment_api.g.dart';

@RestApi()
abstract class QuizSetCommentApi {
  factory QuizSetCommentApi(Dio dio, {required String? baseUrl}) = _QuizSetCommentApi;
  
  @POST('/quizsetcomment/quizset/{id}/search')
  Future<QuizSetCommentResponse> getQuizSetComments(
    @Path('id') String id,
    @Query('includeDeleted') bool includeDeleted,
    @Body() Map<String, dynamic> body,
  );

  @POST('/quizsetcomment')
  Future<CreateQuizSetCommentResponse> createComment(
    @Body() Map<String, dynamic> body,
  );
}

