import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/event_join_response.dart';
import 'package:quizkahoot/app/modules/home/models/event_leaderboard_model.dart';
import 'package:quizkahoot/app/modules/home/models/event_response.dart';
import 'package:retrofit/retrofit.dart';

part 'event_api.g.dart';

@RestApi()
abstract class EventApi {
  factory EventApi(Dio dio, {required String? baseUrl}) = _EventApi;

  @GET('/event/all')
  Future<EventResponse> getAllEvents();

  @GET('/event/{id}/leaderboard')
  Future<EventLeaderboardResponse> getEventLeaderboard(@Path('id') String eventId);

  @POST('/event/{id}/join')
  Future<EventJoinResponse> joinEvent(@Path('id') String eventId);
}

