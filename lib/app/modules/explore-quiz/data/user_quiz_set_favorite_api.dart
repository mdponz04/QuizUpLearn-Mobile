import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_favorite_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/create_user_quiz_set_favorite_response.dart';
import 'package:retrofit/retrofit.dart';

part 'user_quiz_set_favorite_api.g.dart';

@RestApi()
abstract class UserQuizSetFavoriteApi {
  factory UserQuizSetFavoriteApi(Dio dio, {required String? baseUrl}) = _UserQuizSetFavoriteApi;
  
  @POST('/userquizsetfavorite/user/search')
  Future<UserQuizSetFavoriteResponse> getUserFavorites(
    @Query('userId') String userId,
    @Query('includeDeleted') bool includeDeleted,
    @Body() Map<String, dynamic> body,
  );

  @POST('/userquizsetfavorite')
  Future<CreateUserQuizSetFavoriteResponse> createFavorite(
    @Body() Map<String, dynamic> body,
  );
}

