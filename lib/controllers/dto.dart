import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';

import '../models/models.dart';
import '../utils/server.dart';

class Provider extends GetConnect {
  Future<dynamic> getDataFromServer(String url) => get(
    url,
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'RapidAPI/4.2.0 (Macintosh; OS X/14.3.1) GCDHTTPRequest',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  Future<dynamic> sendDataToServer(String url, body) => post(
    url,
    body,
    headers: {
      'Accept': 'application/json',
      'Connection': 'close',
      'User-Agent': 'RapidAPI/4.2.0 (Macintosh; OS X/14.3.1) GCDHTTPRequest',
    },
    contentType: 'multipart/form-data',
  );

  Future<dynamic> updateDataOnServer(
    String url,
    int id,
    Map<String, dynamic> body,
  ) => patch(
    "$url/$id",
    body,
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'RapidAPI/4.2.0 (Macintosh; OS X/14.3.1) GCDHTTPRequest',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  Future<dynamic> deleteDataOnServer(String url, id) => delete(
    "$url?id=$id",
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'RapidAPI/4.2.0 (Macintosh; OS X/14.3.1) GCDHTTPRequest',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

class DataBaseOperations extends GetxController {
  List<Product> products = [];

  String currentDate = DateTime.now().toString().substring(0, 10);

  dynamic uploadPhoto(Uint8List file) async {
    dynamic answer = {};
    final formData = FormData({
      'file': MultipartFile(file, filename: "корзина.jpg"),
    });
    await Provider().sendDataToServer(uploadFileUrl, formData).then((response) {
      if (response.status.hasError) {
        Get.snackbar(
          "Error",
          "Failed to upload document: ${response.statusText}",
        );
        answer = null;
        return answer;
      } else if (response.body == null) {
        Get.snackbar("Error", "Received null response from server");
        answer = null;
        return answer;
      } else {
        answer = jsonDecode(response.bodyString);
        return answer;
      }
    });
    return answer;
  }
}
