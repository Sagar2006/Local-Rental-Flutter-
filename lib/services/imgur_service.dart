import 'dart:convert';
import 'package:http/http.dart' as http;

class ImgurService {
  static const String _clientId = 'd4ad0d3d11cde35';
  static const String _imageUrl = 'https://api.imgur.com/3/image';
  static const String _videoUrl = 'https://api.imgur.com/3/upload';
  static const int _maxVideoSize = 200 * 1024 * 1024; // 200MB (Imgur's limit)
  static const int _chunkSize = 10 * 1024 * 1024; // 10MB chunks

  static Future<String?> uploadFile(List<int> fileBytes, String fileName, {bool isVideo = false}) async {
    try {
      if (isVideo) {
        return await _uploadVideo(fileBytes, fileName);
      } else {
        return await _uploadImage(fileBytes, fileName);
      }
    } catch (e) {
      print('Error uploading to Imgur: $e');
      return null;
    }
  }

  static Future<String?> _uploadImage(List<int> fileBytes, String fileName) async {
    try {
      final response = await http.post(
        Uri.parse(_imageUrl),
        headers: {
          'Authorization': 'Client-ID $_clientId',
        },
        body: {
          'image': base64Encode(fileBytes),
          'name': fileName,
        },
      );

      print('Image upload response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['link'];
        }
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<String?> _uploadVideo(List<int> fileBytes, String fileName) async {
    try {
      if (fileBytes.length > _maxVideoSize) {
        print('Video file too large: ${fileBytes.length} bytes');
        return null;
      }

      // Create multipart request
      final uri = Uri.parse(_videoUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Client-ID $_clientId',
      });

      // Add file as multipart
      request.files.add(
        http.MultipartFile.fromBytes(
          'video',
          fileBytes,
          filename: fileName,
        ),
      );

      // Add other fields
      request.fields['type'] = 'video/mp4';
      request.fields['title'] = fileName;
      request.fields['description'] = 'Video upload';

      print('Sending video upload request...');
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('Video upload response status: ${response.statusCode}');
      print('Video upload response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final link = responseData['data']['mp4'] ?? responseData['data']['link'];
          print('Successfully uploaded video: $link');
          return link;
        }
      }

      print('Video upload failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }
} 