import 'package:http/http.dart' as http;
void main() async {
  try {
    final res = await http.get(Uri.parse('https://corvus.eduartrob.site/api/v1/health'));
    print('Health: ${res.statusCode}');
  } catch(e) {
    print(e);
  }
}
