import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Read secure storage
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  
  // Decide initial route based on token
  String initialRoute = token != null ? '/home-student' : '/';

  runApp(MyApp(initialRoute: initialRoute));
}
