import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/notification_response.dart';

part 'notification_api.g.dart';

@RestApi()
abstract class NotificationApi {
  factory NotificationApi(Dio dio, {String baseUrl}) = _NotificationApi;

  @GET('/usernotification/user')
  Future<NotificationResponse> getUserNotifications();

  @PUT('/usernotification/{id}/mark-as-read')
  Future<MarkAsReadResponse> markAsRead(@Path('id') String id);

  @PATCH('/usernotification/user/mark-all-read')
  Future<MarkAsReadResponse> markAllAsRead();
}
