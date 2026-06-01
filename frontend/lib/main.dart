import 'package:flutter/widgets.dart';
import 'package:frontend/app/localization/app_translatation.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  GetStorage.init();
  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // language
      translations: AppTranslatation(),
      locale: Locale("kmKH"), // enUS
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
