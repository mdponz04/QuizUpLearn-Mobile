import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/toggle_like_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/count_like_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_like_response.dart';
import 'package:retrofit/retrofit.dart';

part 'user_quiz_set_like_api.g.dart';

@RestApi()
abstract class UserQuizSetLikeApi {
  factory UserQuizSetLikeApi(Dio dio, {required String? baseUrl}) = _UserQuizSetLikeApi;
  
  @POST('/userquizsetlike/user/search')
  Future<UserQuizSetLikeResponse> getUserLikes(
    @Query('userId') String userId,
    @Query('includeDeleted') bool includeDeleted,
    @Body() Map<String, dynamic> body,
  );

  @POST('/userquizsetlike/toggle-like/quiz-set-id/{quizSetId}')
  Future<ToggleLikeResponse> toggleLike(
    @Path('quizSetId') String quizSetId,
    @Query('userId') String userId,
  );

  @GET('/userquizsetlike/count/quizset/{quizSetId}')
  Future<CountLikeResponse> getLikeCount(
    @Path('quizSetId') String quizSetId,
  );
}

