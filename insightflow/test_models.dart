import 'dart:convert';
import 'dart:io';

void main() async {
  final envFile = File('.env');
  final lines = envFile.readAsLinesSync();
  String apiKey = '';
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  final modelsToTest = [
    'gemini-3-flash-preview',
  ];

  for (final model in modelsToTest) {
    print('Testing $model...');
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
    final request = await HttpClient().postUrl(url);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      "contents": [{"parts": [{"text": "Hello"}]}]
    }));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error: $body\n');
    } else {
      print('SUCCESS!\n');
    }
    await Future.delayed(Duration(seconds: 1));
  }
}
