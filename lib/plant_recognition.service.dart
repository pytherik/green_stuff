import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:green_stuff/recognition_model.dart';

class PlantRecognitionService {
  final String apiUrl;

  PlantRecognitionService(this.apiUrl);
  Future<RecognitionModel> recognize(String imagePath) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['organs'] = 'auto';

    final imageField = await http.MultipartFile.fromPath(
      'images',
      imagePath,
    );
    request.files.add(imageField);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return RecognitionModel.fromJson(jsonData);
    } else {
      throw HttpException('Fehler bei der Bestimmung: ${response.statusCode}');
    }
  }
}