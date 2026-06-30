import 'package:get/get.dart';

import 'detail_developer_controller.dart';

class DetailDeveloperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailDeveloperViewController>(
      () => DetailDeveloperViewController(),
    );
  }
}