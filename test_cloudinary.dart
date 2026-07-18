import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/zpqp1swt/auto/upload');
  
  // Create a dummy file
  final file = File('test_upload.txt');
  await file.writeAsString('Hello world!');

  var request = http.MultipartRequest('POST', url);
  request.fields['upload_preset'] = 'corvus_unsigned';
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  
  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
