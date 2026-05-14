import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../full_image_view.dart';

class PreviewImage extends StatelessWidget {
  final XFile? imageFile;
  final String? scientificNameWithoutAuthor;
  final String? scientificNameAuthorship;
  final List<String?> commonNamesList;
  final int? remainingIdentificationRequests;
  final dynamic pickImageError;
  final bool isCameraSupported;

  const PreviewImage({
    super.key,
    this.imageFile,
    this.scientificNameWithoutAuthor,
    this.scientificNameAuthorship,
    required this.commonNamesList,
    required this.remainingIdentificationRequests,
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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImageView(imageFile: imageFile),
                    ),
                  );
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Image.file(
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
                ),
              ),
              if (scientificNameWithoutAuthor != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scientificNameWithoutAuthor!),
                          if (scientificNameAuthorship != null)
                            Text('($scientificNameAuthorship)'),
                        ],
                      ),
                      if (remainingIdentificationRequests != null)
                        Text('noch $remainingIdentificationRequests/500'),
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
