import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<bool> requestDriveScope();
  Future<String?> getDriveAccessToken();
  Future<void> signOutFromGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  Future<bool> requestDriveScope() async {
    return await _googleSignIn.requestScopes(['https://www.googleapis.com/auth/drive.readonly']);
  }

  @override
  Future<String?> getDriveAccessToken() async {
    GoogleSignInAccount? user = _googleSignIn.currentUser;
    if (user == null) {
      try {
        user = await _googleSignIn.signInSilently();
      } catch (e) {
        print('Error silent sign in: $e');
      }
    }
    final GoogleSignInAuthentication? auth = await user?.authentication;
    return auth?.accessToken;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      final String? serverAuthCode = googleUser.serverAuthCode;

      if (serverAuthCode == null) {
        throw Exception('No se pudo obtener el serverAuthCode de Google');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiConfig.authGoogleEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'authCode': serverAuthCode}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        
        final userData = jsonResponse['user'] as Map<String, dynamic>;
        final token = jsonResponse['token'] as String?;
        final userId = userData['id'] ?? userData['id_usuario'];

        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && userId != null) {
            await http.post(
              Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/device'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'userId': userId.toString(),
                'fcmToken': fcmToken
              })
            );
            print('✅ FCM Token registrado en el backend de Notificaciones');
          }
        } catch(e) {
          print('❌ Error registrando FCM Token: $e');
        }

        return UserModel.fromJson({
          ...userData,
          'token': token,
          'photoUrl': googleUser.photoUrl ?? userData['photoUrl'],
          'name': googleUser.displayName ?? userData['name'],
        });
      } else {
        final jsonResponse = jsonDecode(response.body);
        var error = jsonResponse['error'] ?? jsonResponse['message'] ?? jsonResponse['detail'] ?? 'Error del servidor';
        if (error is Map) {
          error = error['message'] ?? error['detail'] ?? error.toString();
        }
        throw Exception(error.toString());
      }
    } catch (e) {
      await _googleSignIn.signOut();
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  @override
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      await _googleSignIn.signOut();
    }
  }
}
