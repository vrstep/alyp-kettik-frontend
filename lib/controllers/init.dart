import 'package:get/get.dart';

import 'dto.dart';
import 'auth_controller.dart';
import 'session_controller.dart';
import 'product_controller.dart';

Future<void> init() async {
  Get.put(DataBaseOperations(), permanent: true);
  final auth = Get.put(AuthController(), permanent: true);
  final session = Get.put(SessionController(), permanent: true);
  Get.put(ProductController(), permanent: true);

  // Restore persisted auth session before the app renders
  await auth.tryRestoreSession();

  // Restore cached shopping session from local storage (instant)
  await session.restoreCachedSession();

  // If logged in, refresh session state from server (updates cache)
  if (auth.isLoggedIn) {
    await session.fetchActiveSession();
  }
}
