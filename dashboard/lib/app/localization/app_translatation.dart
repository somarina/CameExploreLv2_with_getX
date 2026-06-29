import 'package:get/get.dart';

import 'language/languages/en_us.dart';
import 'language/languages/km_kh.dart';

class AppTranslatation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {"kmKH": kmKH, "enUS": enUS};
}