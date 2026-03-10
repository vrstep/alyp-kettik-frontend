import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/server.dart';


class DataBaseOperations extends GetxController {
  String currentDate = DateTime.now().toString().substring(0, 10);

  dynamic uploadPhoto(Uint8List file, {String mime = 'image/jpeg'}) async {
    final ext = mime == 'image/png' ? 'png' : 'jpg';

    final uri = Uri.parse(uploadFileUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', file, filename: 'basket.$ext'),
      );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 120));
    } catch (e) {
      Get.snackbar(
        "Ошибка",
        "Таймаут или нет соединения: $e",
        duration: const Duration(seconds: 5),
      );
      return null;
    }

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      Get.snackbar(
        "Ошибка сервера",
        "Код ${streamed.statusCode}: $body",
        duration: const Duration(seconds: 5),
      );
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (e) {
      Get.snackbar("Ошибка", "Не удалось разобрать ответ: $e");
      return null;
    }
  }
}
