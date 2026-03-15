import 'package:get/get.dart';

import 'dto.dart';
import 'auth_controller.dart';
import 'session_controller.dart';
import 'product_controller.dart';

Future<void> init() async {
  Get.put(DataBaseOperations(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(SessionController(), permanent: true);
  Get.put(ProductController(), permanent: true);
}
