import 'dart:async';
import 'dart:io';
import 'package:green_stuff/plant_recognition.service.dart';
import 'package:green_stuff/widgets/custom_fab.dart';
import 'package:green_stuff/widgets/preview_image.dart';
import 'package:green_stuff/widgets/styled_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const GreenStuff());
}

class GreenStuff extends StatelessWidget {
  const GreenStuff({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Green Stuff',
      debugShowCheckedModeBanner: false,
      home: ImageSelectPage(title: 'Green Stuff'),
    );
  }
}

class ImageSelectPage extends StatefulWidget {
  const ImageSelectPage({super.key, this.title});

  final String? title;

  @override
  State<ImageSelectPage> createState() => _ImageSelectPageState();
}

class _ImageSelectPageState extends State<ImageSelectPage> {
  final apiKey = const String.fromEnvironment('API_KEY');
  late final url = 'https://my-api.plantnet.org/v2/identify/all?api-key=$apiKey&lang=de';
  late final PlantRecognitionService _recognitionService = PlantRecognitionService(url);
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _scientificName;
  String? _authorship;
  final List<String?> _commonNamesList = [];
  int? _remainingIdentificationRequests;

  dynamic _pickImageError;
  String? _retrieveDataError;

  bool isPending = false;

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

  Widget _buildPreviewWidget() {
    final String? error = _retrieveDataError;
    if (error != null) {
      _retrieveDataError = null;
    }

    return PreviewImage(
      imageFile: _imageFile,
      scientificNameWithoutAuthor: _scientificName,
      scientificNameAuthorship: _authorship,
      commonNamesList: _commonNamesList,
      remainingIdentificationRequests: _remainingIdentificationRequests,
      pickImageError: _pickImageError,
      isCameraSupported: _picker.supportsImageSource(ImageSource.camera),
    );
  }

  void _recognizeImage() async {
    if (_imageFile == null) {
      return;
    }
    setState(() => isPending = true);

    try {
      final recognitionModel = await _recognitionService.recognize(
        _imageFile!.path,
      );

      if (recognitionModel.results != null &&
          recognitionModel.results!.isNotEmpty) {
        final firstResult = recognitionModel.results![0];
        setState(() {
          _scientificName = firstResult.species?.scientificNameWithoutAuthor;
          _authorship = firstResult.species?.scientificNameAuthorship;
          _commonNamesList.clear();
          if (firstResult.species?.commonNames != null) {
            _commonNamesList.addAll(firstResult.species!.commonNames!);
          }
          _remainingIdentificationRequests =
              recognitionModel.remainingIdentificationRequests;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        StyledSnackBar.show(
          context,
          'Diese Spezies kann nicht bestimmt werden.',
          type: SnackBarType.error,
        );
      }
    } catch (error) {
      if (mounted) {
        StyledSnackBar.show(
          context,
          'Anfrage fehlgeschlagen. Prüfe die Internetverbindung.',
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() => isPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCameraSupported = _picker.supportsImageSource(
      ImageSource.camera,
    );
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xffeaeaea),
          appBar: AppBar(
            title: Text(widget.title!),
            backgroundColor: Color(0xffeaeaea),
          ),
          body: _buildPreviewWidget(),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (_imageFile == null)
                buildImageSourceButtons(context, isCameraSupported),
              if (_imageFile != null) buildImageProcessingButtons(),
              SizedBox(height: 30),
            ],
          ),
        ),
        if (isPending)
          Positioned.fill(
            child: Container(
              color: Color(0x8A000000),
              child: Center(
                child: const SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(color: Color(0xffd1d98d)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Padding buildImageSourceButtons(
    BuildContext context,
    bool isCameraSupported,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFab(
            icon: Icon(Icons.photo, size: 50),
            description: 'Bild auswählen',
            heroTag: 'gallery',
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery, context: context);
            },
          ),
          if (_imageFile == null && isCameraSupported)
            CustomFab(
              icon: Icon(Icons.camera_alt, size: 50),
              description: 'Foto machen',
              heroTag: 'camera',
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
            ),
        ],
      ),
    );
  }

  Padding buildImageProcessingButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFab(
            icon: Icon(Icons.clear, size: 50),
            description: 'nächstePflanze',
            heroTag: 'clear',
            onPressed: () {
              setState(() {
                _imageFile = null;
                _commonNamesList.clear();
                _scientificName = null;
              });
            },
          ),
          CustomFab(
            icon: Icon(Icons.send, size: 50),
            description: 'Pflanze bestimmen',
            heroTag: 'send',
            onPressed: _recognizeImage,
          ),
        ],
      ),
    );
  }
}
