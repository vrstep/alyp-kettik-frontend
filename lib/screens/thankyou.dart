import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home.dart';
import '../widgets/my_button.dart';

class ThankyouPage extends StatelessWidget {
  const ThankyouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Image.asset("assets/images/thanks.png", width: 150),
          Text(
            "Спасибо за покупку!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          MyButtonWidget(
            textButton: "Вернуться в магазин",
            buttonsIcon: Icons.shopping_bag,
            fn: () {
              Get.offAll(HomePage());
            },
          ),
        ],
      ),
    );
  }
}
