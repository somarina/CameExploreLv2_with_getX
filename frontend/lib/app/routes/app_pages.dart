import 'package:frontend/app/modules/auth/forget_password/views/confirm_screen.dart';
import 'package:frontend/app/modules/auth/forget_password/views/otp_screen.dart';
import 'package:frontend/app/modules/auth/forget_password/views/reset_password_screen.dart';
import 'package:frontend/app/modules/choose_room_screen/choose_room_screen_view.dart';
import 'package:frontend/app/modules/choose_room_screen/confirmed_booking/confirmed_booking_view.dart';
import 'package:frontend/app/modules/choose_room_screen/guest_info_screen/guest_info_screen_view.dart';
import 'package:frontend/app/modules/detail_places_screen/detail_places_screen_view.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_binding.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_view.dart';
import 'package:frontend/app/modules/home_see_all_screen/home_see_all_screen_view.dart';
import 'package:frontend/app/modules/hotel_detail_screen/hotel_detail_photo/hotel_detail_photo_view.dart';
import 'package:frontend/app/modules/hotel_detail_screen/hotel_detail_screen_view.dart';
import 'package:frontend/app/modules/hotel_detail_screen/reviews_hotel_screen/reviews_hotel_screen_view.dart';
import 'package:frontend/app/modules/hotel_write_review/hotel_write_review_view.dart';
import 'package:frontend/app/modules/itinerary_screen/itinerary_screen_view.dart';
import 'package:frontend/app/modules/package_checkout_screen/package_cf_booking/package_cf_booking_view.dart';
import 'package:frontend/app/modules/package_checkout_screen/package_checkout_screen_view.dart';
import 'package:frontend/app/modules/package_detail_screen/package_detail_screen_view.dart';
import 'package:frontend/app/modules/package_write_review/package_write_review_view.dart';
import 'package:frontend/app/modules/profile_screen/about_app_screen/about_app_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/about_organization_screen/about_organization_screen_binding.dart';
import 'package:frontend/app/modules/profile_screen/about_organization_screen/about_organization_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/change_pwd_screen/change_pwd_screen_binding.dart';
import 'package:frontend/app/modules/profile_screen/change_pwd_screen/change_pwd_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/comment_screen/comment_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/detail_developer/detail_developer_binding.dart';
import 'package:frontend/app/modules/profile_screen/detail_developer/detail_developer_view.dart';
import 'package:frontend/app/modules/profile_screen/edit_screen/edit_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/help_support_screen/help_support_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/notification_screen/notification_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/private_security_screen/private_security_screen_view.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';

import '../modules/ai_screen/bindings/ai_screen_binding.dart';
import '../modules/ai_screen/views/ai_screen_view.dart';
import '../modules/ar_screen/bindings/ar_screen_binding.dart';
import '../modules/ar_screen/views/ar_screen_view.dart';
import '../modules/auth/forget_password/bindings/forget_password_binding.dart';
import '../modules/auth/forget_password/views/forget_password_view.dart';
import '../modules/auth/login_screen/bindings/login_screen_binding.dart';
import '../modules/auth/login_screen/views/login_screen_view.dart';
import '../modules/auth/register_screen/bindings/register_screen_binding.dart';
import '../modules/auth/register_screen/views/register_screen_view.dart';
import '../modules/booking_screen/bindings/booking_screen_binding.dart';
import '../modules/booking_screen/views/booking_screen_view.dart';
import '../modules/button_navbar/bindings/button_navbar_binding.dart';
import '../modules/button_navbar/views/button_navbar_view.dart';
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
import '../modules/profile_screen/userProfile_screen/user_profile_screen_view.dart';
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
    // GetPage(
    //   name: _Paths.DETAIL_SCREEN,
    //   page: () => const DetailScreenView(),
    //   binding: DetailScreenBinding(),
    // ),
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
    GetPage(
      name: _Paths.FORGET_PASSWORD,
      page: () => const ForgetPasswordView(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.OTP_SCREEN,
      page: () => const OtpScreen(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER_SCREEN,
      page: () => const RegisterScreenView(),
      binding: RegisterScreenBinding(),
    ),
    GetPage(
      name: _Paths.USERPROFILE_SCREEN,
      page: () => UserProfileScreenView(),
      binding: UserProfileScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_SCREEN,
      page: () => EditScreenView(),
      binding: EditScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.ABOUTAPP_SCREEN,
      page: () => AboutAppScreenView(),
      binding: AboutAppScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.HELPSUPPORT_SCREEN,
      page: () => HelpSupportScreenView(),
      binding: HelpSupportScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK_SCREEN,
      page: () => CommentScreenView(),
      binding: CommentScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_SCREEN,
      page: () => NotificationScreenView(),
      binding: NotificationScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.ABOUTORGANIZATION_SCREEN,
      page: () => AboutOrganizationScreenView(),
      binding: AboutOrganizationBinding(),
    ),
    GetPage(
      name: _Paths.DETAILDEVELOPER_SCREEN,
      page: () => DetailDeveloperView(),
      binding: DetailDeveloperBinding(),
    ),
    GetPage(
      name: _Paths.SECURITY_SCREEN,
      page: () => PrivateSecurityScreenView(),
      binding: PrivateSecurityScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.CHANGEPWD_SCREEN,
      page: () => ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.THEME_SCREEN,
      page: () => ThemeModeView(),
      binding: ThemeModeViewBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING_SCREEN,
      page: () => const BookingScreenView(),
      binding: BookingScreenBinding(),
    ),
    GetPage(
      name: _Paths.CONFIRM_PASSWORD,
      page: () => const ConfirmScreen(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.HOME_SEEALL,
      page: () => const HomeSeeAllScreenView(),
      binding: HomeSeeAllScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.WRITE_REVIEW,
      page: () => const WriteReviewScreenView(),
      binding: WriteReviewScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.REVIEW_HOTEL,
      page: () => const ReviewsHotelScreenView(),
      binding: ReviewsHotelScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.CHOOSE_ROOM,
      page: () => const ChooseRoomScreenView(),
      binding: ChooseRoomScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_DETAIL,
      page: () => const PackageDetailScreenView(),
      binding: PackageDetailScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_DETAIL,
      page: () => const PackageDetailScreenView(),
      binding: PackageDetailScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_CHECKOUT,
      page: () => const PackageCheckoutScreenView(),
      binding: PackageCheckoutScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.ITINERARY,
      page: () => const ItineraryScreenView(),
      binding: ItineraryScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.HOTEL_DETAIL,
      page: () => const HotelDetailScreenView(),
      binding: HotelDetailScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.HOTEL_PHOTO,
      page: () => const HotelDetailPhotoView(),
      binding: HotelDetailPhotoViewBinding(),
    ),
    GetPage(
      name: _Paths.REVIEW_HOTEL,
      page: () => const ReviewsHotelScreenView(),
      binding: ReviewsHotelScreenViewBinding(),
    ),

    GetPage(
      name: _Paths.PACKAGE_REVIEW,
      page: () => const PackageWriteReviewView(),
      binding: PackageWriteReviewViewBinding(),
    ),
    GetPage(
      name: _Paths.CHOOSE_ROOM,
      page: () => const ChooseRoomScreenView(),
      binding: ChooseRoomScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.GUEST_INFO,
      page: () => const GuestInfoScreenView(),
      binding: GuestInfoScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.CONFIRM_BOOKING,
      page: () => const ConfirmedBookingView(),
      binding: ConfirmedBookingViewBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_CF_BOOKING,
      page: () => const PackageCfBookingView(),
      binding: PackageCfBookingViewBinding(),
    ),
    GetPage(
      name: _Paths.WRITE_REVIEW,
      page: () => const WriteReviewScreenView(),
      binding: WriteReviewScreenViewBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_SCREEN,
      page: () => const DetailPlacesScreenView(),
      binding: DetailPlacesScreenViewBinding(),
    ),
  ];
}
