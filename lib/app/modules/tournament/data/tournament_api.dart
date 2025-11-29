import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_response.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_joined_response.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_join_response.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_today_response.dart';
import 'package:retrofit/retrofit.dart';

part 'tournament_api.g.dart';

@RestApi()
abstract class TournamentApi {
  factory TournamentApi(Dio dio, {required String? baseUrl}) = _TournamentApi;
  
  @GET('/tournament')
  Future<TournamentResponse> getTournaments(
    @Query('includeDeleted') bool includeDeleted,
  );
  
  @GET('/tournament/{id}/joined')
  Future<TournamentJoinedResponse> checkJoined(
    @Path('id') String tournamentId,
  );
  
  @POST('/tournament/{id}/join')
  Future<TournamentJoinResponse> joinTournament(
    @Path('id') String tournamentId,
    @Body() Map<String, dynamic> body,
  );
  
  @GET('/tournament/{id}/today')
  Future<TournamentTodayResponse> getTournamentToday(
    @Path('id') String tournamentId,
  );
}

