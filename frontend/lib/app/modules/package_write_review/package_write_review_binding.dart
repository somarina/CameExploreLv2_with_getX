part of 'package_write_review_view.dart';

class PackageWriteReviewViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => PackageWriteReviewViewController());
   }
}