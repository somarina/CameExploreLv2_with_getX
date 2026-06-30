part of 'hotel_write_review_view.dart';

class WriteReviewScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => WriteReviewScreenViewController());
   }
}