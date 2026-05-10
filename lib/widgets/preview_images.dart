import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PreviewImages extends StatelessWidget {
  final XFile? imageFile;
  final String? scientificNameWithoutAuthor;
  final String? scientificNameAuthorship;
  final List<String?> commonNamesList;
  final dynamic pickImageError;
  final bool isCameraSupported;

  const PreviewImages({
    super.key,
    this.imageFile,
    this.scientificNameWithoutAuthor,
    this.scientificNameAuthorship,
    required this.commonNamesList,
    this.pickImageError,
    required this.isCameraSupported,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                File(imageFile!.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Dieser Bildtyp wird nicht unterstützt.'),
                  );
                },
              ),
              if (scientificNameWithoutAuthor != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scientificNameWithoutAuthor!),
                      if (scientificNameAuthorship != null)
                        Text('($scientificNameAuthorship)'),
                    ],
                  ),
                ),
              if (commonNamesList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trivialnamen: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...commonNamesList.map((name) => Text(name!)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (pickImageError != null) {
      return Text(
        'Bildauswahl Fehler: $pickImageError',
        textAlign: TextAlign.center,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/app_icon.png',
            width: double.infinity,
            height: 300,
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Wähle eine Pflanze aus der Bildergalerie deines Telefons.',
                  ),
                  if (isCameraSupported)
                    TextSpan(
                      text: ' Du kannst auch ein Foto machen aber beachte: das Bild wird nicht gespeichert.'
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
