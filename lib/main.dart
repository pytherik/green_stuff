import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:green_stuff/recognition_model.dart';
import 'package:green_stuff/widgets/styled_snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Green Stuff',
      home: MyHomePage(title: 'Green Stuff'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _plantNetUrl = String.fromEnvironment('PLANTNET_URL');
  XFile? _imageFile;
  String? _scientificNameWithoutAuthor;
  String? _scientificNameAuthorship;
  final List<String?> _commonNamesList = [];

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _imageFile = pickedFile;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(
                  File(_imageFile!.path),
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const Center(
                          child: Text('Dieser Bildtyp wird nicht unterstützt.'),
                        );
                      },
                ),
                if (_scientificNameWithoutAuthor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_scientificNameWithoutAuthor'),
                        if (_scientificNameAuthorship != null)
                          Text('($_scientificNameAuthorship)'),
                      ],
                    ),
                  ),
                if (_commonNamesList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trivialnamen: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ..._commonNamesList.map(
                          (name) => Text(name ?? ''),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Wähle ein Bild oder mache ein Foto.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file!;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  void _recognizeImage() async {
    if (_imageFile == null) {
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_plantNetUrl),
      );
      request.fields['organs'] = 'auto';
      final imageField = await http.MultipartFile.fromPath(
        'images',
        _imageFile!.path,
      );
      request.files.add(imageField);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final recognitionModel = RecognitionModel.fromJson(jsonData);
        if (recognitionModel.results != null &&
            recognitionModel.results!.isNotEmpty) {
          final firstResult = recognitionModel.results![0];
          setState(() {
            _scientificNameWithoutAuthor =
                firstResult.species?.scientificNameWithoutAuthor;
            _scientificNameAuthorship =
                firstResult.species?.scientificNameAuthorship;
            _commonNamesList.clear();
            if (firstResult.species?.commonNames != null) {
              _commonNamesList.addAll(firstResult.species!.commonNames!);
            }
          });
        }
      } else {
        if (mounted) {
          StyledSnackBar.show(
            context,
            'Unbekannte Spezies.',
            type: SnackBarType.error,
          );
        }
        debugPrint(
          'Diese Spezies konnte nicht gefunden werden: ${response.statusCode}',
        );
      }
    } catch (error) {
      if (mounted) {
        StyledSnackBar.show(
          context,
          'Anfrage fehlgeschlagen, prüfe deine Internetverbindung!',
          type: SnackBarType.error,
        );
      }
      debugPrint('Request failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _previewImages();
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _previewImages(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_imageFile != null)
            Column(
              children: [
                Semantics(
                  label: 'clear_picked_image',
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _commonNamesList.clear();
                        _scientificNameWithoutAuthor = null;
                      });
                    },
                    child: const Icon(Icons.clear),
                  ),
                ),
                SizedBox(height: 16),
                Semantics(
                  label: 'picked_image_recognition',
                  child: FloatingActionButton(
                    onPressed: _recognizeImage,
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          if (_imageFile == null)
            Semantics(
              label: 'image_picker_example_from_gallery',
              child: FloatingActionButton(
                onPressed: () {
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                },
                heroTag: 'image0',
                tooltip: 'Pick image from gallery',
                child: const Icon(Icons.photo),
              ),
            ),
          if (_imageFile == null &&
              _picker.supportsImageSource(ImageSource.camera))
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  _onImageButtonPressed(ImageSource.camera, context: context);
                },
                heroTag: 'image2',
                tooltip: 'Take a photo',
                child: const Icon(Icons.camera_alt),
              ),
            ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
