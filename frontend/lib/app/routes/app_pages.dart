import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_binding.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_view.dart';
import 'package:get/get.dart';

import '../modules/ai_screen/bindings/ai_screen_binding.dart';
import '../modules/ai_screen/views/ai_screen_view.dart';
import '../modules/ar_screen/bindings/ar_screen_binding.dart';
import '../modules/ar_screen/views/ar_screen_view.dart';
import '../modules/auth/login_screen/bindings/login_screen_binding.dart';
import '../modules/auth/login_screen/views/login_screen_view.dart';
import '../modules/button_navbar/bindings/button_navbar_binding.dart';
import '../modules/button_navbar/views/button_navbar_view.dart';
import '../modules/detail_screen/bindings/detail_screen_binding.dart';
import '../modules/detail_screen/views/detail_screen_view.dart';
import '../modules/discover_screen/explore_screen/explore_screen_view.dart';
import '../modules/discover_screen/nearby_screen/nearby_screen_binding.dart';
import '../modules/discover_screen/nearby_screen/nearby_screen_view.dart';
import '../modules/discover_screen/search_screen/search_screen_view.dart';
import '../modules/favorite_screen/bindings/favorite_screen_binding.dart';
import '../modules/favorite_screen/views/favorite_screen_view.dart';
import '../modules/home_screen/bindings/home_screen_binding.dart';
import '../modules/home_screen/views/home_screen_view.dart';
import '../modules/onboarding_screen/bindings/onboarding_screen_binding.dart';
import '../modules/onboarding_screen/views/onboarding_screen_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME_SCREEN,
      page: () => const HomeScreenView(),
      binding: HomeScreenBinding(),
    ),
    GetPage(
      name: _Paths.AI_SCREEN,
      page: () => const AiScreenView(),
      binding: AiScreenBinding(),
    ),
    GetPage(
      name: _Paths.AR_SCREEN,
      page: () => const ArScreenView(),
      binding: ArScreenBinding(),
    ),
    GetPage(
      name: _Paths.BUTTON_NAVBAR,
      page: () => const ButtonNavbarView(),
      binding: ButtonNavbarBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_SCREEN,
      page: () => const DetailScreenView(),
      binding: DetailScreenBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_SCREEN,
      page: () => const SearchScreenView(),
      binding: SearchScreenBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITE_SCREEN,
      page: () => const FavoriteScreenView(),
      binding: FavoriteScreenBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING_SCREEN,
      page: () => const OnboardingScreenView(),
      binding: OnboardingScreenBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.FAV_SCREEN_2,
      page: () => const FavScreen2View(),
      binding: FavScreen2ViewBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE_SCREEN,
      page: () => const ExploreView(),
      binding: ExploreScreenBinding(),
    ),
    GetPage(
      name: _Paths.NEARBY_SCREEN,
      page: () => NearbyScreenView(),
      binding: NearbyScreenBinding(),
    ),
  ];
}
