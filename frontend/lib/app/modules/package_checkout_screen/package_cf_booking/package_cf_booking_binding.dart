part of 'package_cf_booking_view.dart';

class PackageCfBookingViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => PackageCfBookingViewController());
   }
}