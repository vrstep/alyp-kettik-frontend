import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoAssetWidget extends StatelessWidget {
  final XFile image;
  const PhotoAssetWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final File imagefile = File(image.path);
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(4)),
      child: Image.file(imagefile),
    );
  }
}
