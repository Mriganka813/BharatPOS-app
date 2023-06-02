import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BulkUploadService {
  const BulkUploadService();

  Future<void> uploadFile(String id, File file) async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://cube-fpqiy.ondigitalocean.app/api/v1/bulkupload'),
    );

    // Attach the file to the request
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      // Send the request
      var response = await request.send();

      // Check if the request was successful
      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print('File upload error: $e');
    }
  }
}
