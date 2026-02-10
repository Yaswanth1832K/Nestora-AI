import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  final String cloudName = 'dc2z6j2g4';
  final String uploadPreset = 'house_rental_unsigned';

  Future<String> uploadImage(dynamic imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      // For web, imageFile should be Uint8List
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageFile as List<int>,
        filename: 'upload.jpg',
      ));
    } else {
      // For mobile, imageFile should be File
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        (imageFile as File).path,
      ));
    }

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonResponse = jsonDecode(responseString);

    if (response.statusCode == 200) {
      return jsonResponse['secure_url'] as String;
    } else {
      throw Exception('Failed to upload image to Cloudinary: ${jsonResponse['error']?['message'] ?? responseString}');
    }
  }
}
