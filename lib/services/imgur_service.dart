import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ImgurService {
  static const String _clientId = 'd4ad0d3d11cde35';
  static const String _imageUrl = 'https://api.imgur.com/3/image';
  static const String _videoUrl = 'https://api.imgur.com/3/upload';
  static const int _maxVideoSize = 200 * 1024 * 1024; // 200MB (Imgur's limit)
  static const int _chunkSize = 10 * 1024 * 1024; // 10MB chunks

  // Add a stream controller for upload progress
  static final _uploadProgressController = StreamController<double>.broadcast();
  static Stream<double> get uploadProgress => _uploadProgressController.stream;

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

      final uri = Uri.parse(_videoUrl);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Client-ID $_clientId',
      });

      final multipartFile = http.MultipartFile.fromBytes(
        'video',
        fileBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);
      request.fields['type'] = 'video/mp4';
      request.fields['title'] = fileName;

      final totalBytes = fileBytes.length;
      var uploadedBytes = 0;

      // Send the request
      final response = await request.send();

      // Convert the response stream to bytes
      final List<int> responseBytes = [];
      await for (final chunk in response.stream.asBroadcastStream()) {
        responseBytes.addAll(chunk);
        uploadedBytes += chunk.length;
        final progress = uploadedBytes / totalBytes;
        _uploadProgressController.add(progress);
      }

      // Complete the upload
      _uploadProgressController.add(1.0);

      // Create response from collected bytes
      final responseData = http.Response(
        String.fromCharCodes(responseBytes),
        response.statusCode,
        headers: response.headers,
      );

      print('Video upload response status: ${responseData.statusCode}');
      print('Video upload response: ${responseData.body}');

      if (responseData.statusCode == 200) {
        final jsonResponse = json.decode(responseData.body);
        if (jsonResponse['success'] == true) {
          final link = jsonResponse['data']['mp4'] ?? jsonResponse['data']['link'];
          print('Successfully uploaded video: $link');
          return link;
        }
      }

      return null;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }
} 