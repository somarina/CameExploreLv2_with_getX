import 'package:frontend/app/localization/language/languages/en_us.dart';
import 'package:frontend/app/localization/language/languages/km_kh.dart';
import 'package:get/get.dart';

class AppTranslatation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {"kmKH": kmKH, "enUS": enUS};
}
