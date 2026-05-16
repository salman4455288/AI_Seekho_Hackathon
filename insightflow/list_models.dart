import 'dart:convert';
import 'dart:io';

void main() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('.env file not found.');
    return;
  }
  
  final lines = envFile.readAsLinesSync();
  String apiKey = '';
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
    print('API key not set in .env');
    return;
  }

  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();

  if (response.statusCode != 200) {
    print('Error: ${response.statusCode} - $responseBody');
    return;
  }

  final data = jsonDecode(responseBody) as Map<String, dynamic>;
  final models = data['models'] as List<dynamic>;

  print('Available models supporting generateContent:');
  for (final model in models) {
    final name = model['name'];
    final supportedMethods = model['supportedGenerationMethods'] as List<dynamic>? ?? [];
    if (supportedMethods.contains('generateContent')) {
      print('- $name');
    }
  }
}
