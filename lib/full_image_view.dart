import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FullImageView extends StatelessWidget {
  final XFile? imageFile;

  const FullImageView({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vollansicht')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).pop();
          },
          child: Center(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Image.file(
                File(imageFile!.path),

                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
