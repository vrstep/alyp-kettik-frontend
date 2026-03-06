import 'package:flutter/material.dart';

class MyInputWidget extends StatelessWidget {
  final String inputName;
  final TextEditingController textEditingController;
  const MyInputWidget(
      {super.key, required this.inputName, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        margin: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          scrollPadding: const EdgeInsets.all(96),
          decoration: InputDecoration(
            filled: true,
            labelText: inputName,
            errorStyle: const TextStyle(color: Colors.red),
            labelStyle: const TextStyle(color: Colors.black87),
            floatingLabelStyle: const TextStyle(color: Colors.black),
            enabledBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 0, color: Colors.transparent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 0, color: Colors.transparent),
            ),
            errorBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 0,
                color: Colors.black,
              ),
            ),
          ),
          controller: textEditingController,
        ));
  }
}