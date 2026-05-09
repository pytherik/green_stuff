import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PreviewImages extends StatelessWidget {
  final XFile? imageFile;
  final String? scientificNameWithoutAuthor;
  final String? scientificNameAuthorship;
  final List<String?> commonNamesList;
  final dynamic pickImageError;
  final String? retrieveDataError;

  const PreviewImages({
    super.key,
    this.imageFile,
    this.scientificNameWithoutAuthor,
    this.scientificNameAuthorship,
    required this.commonNamesList,
    this.pickImageError,
    this.retrieveDataError,
  });

  @override
  Widget build(BuildContext context) {
    // Fehler beim Wiederherstellen verlorener Daten (Android)
    if (retrieveDataError != null) {
      return Text(
        retrieveDataError!,
        textAlign: TextAlign.center,
      );
    }

    // Wenn ein Bild vorhanden ist, zeige die Details an
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
                height: 300,
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
                      Text(
                        scientificNameWithoutAuthor!,
                      ),
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
                      ...commonNamesList
                          .map((name) => Text(name!)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Fehler beim Auswählen des Bildes
    if (pickImageError != null) {
      return Text(
        'Pick image error: $pickImageError',
        textAlign: TextAlign.center,
      );
    }

    // Standardanzeige, wenn nichts ausgewählt wurde
    return Center(
      child: const Text(
        'Wähle ein Bild oder mache ein Foto.',
        textAlign: TextAlign.center,
      ),
    );
  }
}