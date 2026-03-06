import 'package:flutter/material.dart';

class MyButtonWidget extends StatelessWidget {
  final String textButton;
  IconData buttonsIcon;
  final dynamic fn;
  MyButtonWidget(
      {Key? key,
      required this.textButton,
      this.buttonsIcon = Icons.save,
      required this.fn})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: fn,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(textButton,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18)),
                  Icon(buttonsIcon, color: Colors.white)
                ])));
  }
}
