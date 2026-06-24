import 'package:flutter/material.dart';
import 'package:mobile/app.dart';

import 'package:mobile/core/di/di.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar inyección de dependencias
  setupDependencies();
  
  // Crear el AuthProvider
  final authProvider = AuthProvider(signInWithGoogleUseCase: getIt());
  
  // Verificar el token guardado ANTES de correr la app (este es tu Splash invisible)
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => InspirationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
