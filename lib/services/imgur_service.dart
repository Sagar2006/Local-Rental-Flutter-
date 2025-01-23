import 'dart:convert';
import 'package:http/http.dart' as http;

class ImgurService {
  static const String _clientId = 'd4ad0d3d11cde35'; // Replace with your Imgur client ID
  static const String _apiUrl = 'https://api.imgur.com/3/image';

  static Future<String?> uploadFile(List<int> fileBytes, String fileName) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Client-ID $_clientId',
        },
        body: {
          'image': base64Encode(fileBytes),
          'name': fileName,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['link'];
      }
      return null;
    } catch (e) {
      // print('Error uploading to Imgur: $e');
      return null;
    }
  }
} 