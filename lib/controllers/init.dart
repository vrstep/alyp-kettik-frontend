import 'package:get/get.dart';

import 'dto.dart';

Future<void> init() async {
  Get.put(DataBaseOperations(), permanent: true);
}
