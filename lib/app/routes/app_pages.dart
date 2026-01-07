import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/player-game-room/views/player_game_room_view_v3.dart';

import '../modules/badge/bindings/badge_binding.dart';
import '../modules/badge/views/badge_view.dart';
import '../modules/find_matching/bindings/find_matching_binding.dart';
import '../modules/find_matching/views/find_matching_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/on_boarding/bindings/on_boarding_binding.dart';
import '../modules/on_boarding/views/on_boarding_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/play-event/bindings/play_event_binding.dart';
import '../modules/play-event/views/play_event_view.dart';
import '../modules/play-multi/bindings/play_multi_binding.dart';
import '../modules/play-multi/views/play_multi_view.dart';
import '../modules/play-solo/bindings/play_solo_binding.dart';
import '../modules/play-solo/views/play_solo_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/tab-home/bindings/tab_home_binding.dart';
import '../modules/tab-home/views/tab_home_view.dart';
import '../modules/explore-quiz/bindings/explore_quiz_binding.dart';
import '../modules/explore-quiz/views/explore_quiz_view.dart';
import '../modules/explore-quiz/bindings/favorite_quiz_binding.dart';
import '../modules/explore-quiz/views/favorite_quiz_view.dart';
import '../modules/placement-tests/bindings/placement_tests_binding.dart';
import '../modules/placement-tests/views/placement_tests_view.dart';
import '../modules/single-mode/bindings/single_mode_binding.dart';
import '../modules/single-mode/views/quiz_playing_view.dart';
import '../modules/single-mode/views/quiz_result_view.dart';
import '../modules/home/views/game_room_view.dart';
import '../modules/one-vs-one-room/views/one_vs_one_room_view.dart';
import '../modules/quiz-history/bindings/quiz_history_binding.dart';
import '../modules/quiz-history/views/quiz_history_view.dart';
import '../modules/quiz-history/bindings/quiz_history_detail_binding.dart';
import '../modules/quiz-history/views/quiz_history_detail_view.dart';
import '../modules/explore-quiz/bindings/quiz_detail_binding.dart';
import '../modules/explore-quiz/views/quiz_detail_view.dart';
import '../modules/tab-home/bindings/dashboard_detail_binding.dart';
import '../modules/tab-home/views/dashboard_detail_view.dart';
import '../modules/tournament/bindings/tournament_binding.dart';
import '../modules/tournament/bindings/tournament_detail_binding.dart';
import '../modules/tournament/views/tournament_view.dart';
import '../modules/tournament/views/tournament_detail_view.dart';
import '../modules/home/bindings/event_detail_binding.dart';
import '../modules/home/views/event_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ON_BOARDING,
      page: () => const OnBoardingView(),
      binding: OnBoardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.TAB_HOME,
      page: () => const TabHomeView(),
      binding: TabHomeBinding(),
    ),
    GetPage(
      name: _Paths.BADGE,
      page: () => const BadgeView(),
      binding: BadgeBinding(),
    ),
    GetPage(
      name: _Paths.PLAY_EVENT,
      page: () => const PlayEventView(),
      binding: PlayEventBinding(),
    ),
    GetPage(
      name: _Paths.FIND_MATCHING,
      page: () => const FindMatchingView(),
      binding: FindMatchingBinding(),
    ),
    GetPage(
      name: _Paths.PLAY_SOLO,
      page: () => const PlaySoloView(),
      binding: PlaySoloBinding(),
    ),
    GetPage(
      name: _Paths.PLAY_MULTI,
      page: () => const PlayMultiView(),
      binding: PlayMultiBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE_QUIZ,
      page: () => const ExploreQuizView(),
      binding: ExploreQuizBinding(),
    ),
    GetPage(
      name: _Paths.PLACEMENT_TESTS,
      page: () => const PlacementTestsView(),
      binding: PlacementTestsBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_PLAYING,
      page: () => const QuizPlayingView(),
      binding: SingleModeBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_RESULT,
      page: () => QuizResultView(result: Get.arguments),
    ),
    GetPage(
      name: _Paths.GAME_ROOM,
      page: () => const GameRoomView(),
    ),
    GetPage(
      name: _Paths.PLAYER_GAME_ROOM,
      page: () => const PlayerGameRoomViewV3(),
    ),
    GetPage(
      name: _Paths.ONE_VS_ONE_ROOM,
      page: () => const OneVsOneRoomView(),
    ),
    GetPage(
      name: _Paths.QUIZ_HISTORY,
      page: () => const QuizHistoryView(),
      binding: QuizHistoryBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_HISTORY_DETAIL,
      page: () => const QuizHistoryDetailView(),
      binding: QuizHistoryDetailBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_DETAIL,
      page: () => const QuizDetailView(),
      binding: QuizDetailBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITE_QUIZZES,
      page: () => const FavoriteQuizView(),
      binding: FavoriteQuizBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_DETAIL,
      page: () => const DashboardDetailView(),
      binding: DashboardDetailBinding(),
    ),
    GetPage(
      name: _Paths.TOURNAMENT,
      page: () => const TournamentView(),
      binding: TournamentBinding(),
    ),
    GetPage(
      name: _Paths.TOURNAMENT_DETAIL,
      page: () => const TournamentDetailView(),
      binding: TournamentDetailBinding(),
    ),
    GetPage(
      name: _Paths.EVENT_DETAIL,
      page: () => const EventDetailView(),
      binding: EventDetailBinding(),
    ),
  ];
}
