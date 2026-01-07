import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_response.dart';
import 'package:quizkahoot/app/modules/home/models/validate_game_pin_response.dart';
import 'package:quizkahoot/app/modules/home/models/game_session_response.dart';
import 'package:retrofit/retrofit.dart';

part 'game_api.g.dart';

@RestApi()
abstract class GameApi {
  factory GameApi(Dio dio, {required String? baseUrl}) = _GameApi;
  
  @POST('/game/create')
  Future<CreateGameResponse> createGame(@Body() CreateGameRequest request);
  
  @GET('/game/validate/{gamePin}')
  Future<ValidateGamePinResponse> validateGamePin(@Path('gamePin') String gamePin);
  
  @GET('/game/session/{gamePin}')
  Future<GameSessionResponse> getGameSession(@Path('gamePin') String gamePin);
}

