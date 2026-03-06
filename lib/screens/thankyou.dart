import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/my_button.dart';


class ThankyouPage extends StatelessWidget {
  const ThankyouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            Text("Спасибо за покупку!"),
            MyButtonWidget(
              textButton: "Вернуться в магазин",
              fn: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
