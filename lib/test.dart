import 'dart:convert';

void main() {
  String jsonString = '{"secondary_is_verified": true}';
  var data = jsonDecode(jsonString);
  print(data['secondary_is_verified']);
}
