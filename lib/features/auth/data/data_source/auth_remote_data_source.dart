import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/core/network/api_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<bool> requestDriveScope();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // En Android, el clientId web se pasa como serverClientId para obtener el idToken
    serverClientId: '191994979620-cg0dsf3h25f07v6ile2tq29nck72cqqt.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  Future<bool> requestDriveScope() async {
    return await _googleSignIn.requestScopes(['https://www.googleapis.com/auth/drive.readonly']);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Iniciar sesión con Google SDK
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      // 2. Obtener los detalles de autenticación de Google
      final String? serverAuthCode = googleUser.serverAuthCode;

      if (serverAuthCode == null) {
        throw Exception('No se pudo obtener el serverAuthCode de Google');
      }

      // 3. Enviar el authCode al backend (API Gateway -> Auth Service)
      final response = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiConfig.authGoogleEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'authCode': serverAuthCode}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        
        // Supongamos que tu backend responde con algo como: { user: {...}, token: 'ey...' }
        final userData = jsonResponse['user'] as Map<String, dynamic>;
        final token = jsonResponse['token'] as String?;

        return UserModel.fromJson({
          ...userData,
          'token': token,
        });
      } else {
        final jsonResponse = jsonDecode(response.body);
        final error = jsonResponse['error'] ?? 'Error del servidor';
        throw Exception('Error del backend: $error');
      }
    } catch (e) {
      // Desconectar al usuario de Google en caso de error interno
      await _googleSignIn.signOut();
      throw Exception('Fallo al iniciar sesión con Google: $e');
    }
  }
}
