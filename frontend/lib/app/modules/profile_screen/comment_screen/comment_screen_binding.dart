part of 'comment_screen_view.dart';

class CommentScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => CommentScreenViewController());
   }
}