import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_response.dart';
import 'package:retrofit/retrofit.dart';

part 'game_api.g.dart';

@RestApi()
abstract class GameApi {
  factory GameApi(Dio dio, {required String? baseUrl}) = _GameApi;
  
  @POST('/game/create')
  Future<CreateGameResponse> createGame(@Body() CreateGameRequest request);
}

