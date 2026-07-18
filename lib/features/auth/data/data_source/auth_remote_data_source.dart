import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> loginWithEmail(String email, String password);
  Future<bool> requestDriveScope();
  Future<bool> requestClassroomScopes(String jwtToken);
  Future<String?> getDriveAccessToken();
  Future<void> signOutFromGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    // en web no se debe pasar serverclientid porque lanza un error usa el del indexhtml
    serverClientId: kIsWeb ? null : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );

  @override
  Future<bool> requestDriveScope() async {
    return await _googleSignIn.requestScopes(['https://www.googleapis.com/auth/drive.readonly']);
  }

  @override
  Future<bool> requestClassroomScopes(String jwtToken) async {
    try {
      if (_googleSignIn.currentUser == null) {
        final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
        if (account == null) {
          return false;
        }
      }

      bool success = await _googleSignIn.requestScopes([
        'https://www.googleapis.com/auth/classroom.courses.readonly',
        'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
        'https://www.googleapis.com/auth/drive.readonly'
      ]);
      
      if (success) {
        // fire and forget to not block the ui
        _syncClassroomMaterials(jwtToken);
      }
      
      return success;
    } catch (e) {
      print('Error en requestClassroomScopes: $e');
      return false;
    }
  }

  Future<void> _syncClassroomMaterials(String jwtToken) async {
    try {
      final token = await getDriveAccessToken();
      if (token == null) return;
      
      GoogleSignInAccount? user = _googleSignIn.currentUser;
      final teacherId = user?.id ?? "unknown";

      // 1 fetch classroom courses
      final response = await http.get(
        Uri.parse('https://classroom.googleapis.com/v1/courses?courseStates=ACTIVE'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final courses = data['courses'] as List<dynamic>? ?? [];

        for (var course in courses) {
          final courseId = course['id'];
          final teacherFolder = course['teacherFolder'];
          final ownerId = course['ownerId'];

          
          if (teacherFolder != null && teacherFolder['id'] != null) {
            final folderId = teacherFolder['id'];
            
            // 2 send to backend ingest
            try {
              final ingestUrl = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringSubjectIngest}');
              final ingestResponse = await http.post(
                ingestUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $jwtToken',
                },
                body: jsonEncode({
                  'course_id': courseId.toString(),
                  'course_name': course['name']?.toString() ?? 'Materia Sin Nombre',
                  'teacher_id': teacherId.toString(),
                  'folder_id': folderId.toString(),
                  'access_token': token,
                }),
              );
              } catch (e) {
              // ingest failed, continue
            }
          }
        }
      } else {
        // courses fetch failed
      }
    } catch (e) {
      // sync materials failed silently
    }
  }


  @override
  Future<String?> getDriveAccessToken() async {
    try {
      final user = _googleSignIn.currentUser;
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final targetUrl = '${ApiConfig.apiGatewayUrl}${ApiEndpoints.authLogin}';
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] == null) {
          throw Exception('La respuesta del backend no contiene los datos del usuario.');
        }
        return UserModel.fromJson({
          ...data['user'],
          'token': data['token'],
        });
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error desconocido del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Excepción durante loginWithEmail: $e');
    }
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

      final targetUrl = '${ApiConfig.apiGatewayUrl}${ApiConfig.authGoogleEndpoint}';
      final response = await http.post(
        Uri.parse(targetUrl),
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
              Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.notificationsDevice}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'userId': userId.toString(),
                'fcmToken': fcmToken
              })
            );
          }
        } catch(e) {
          // FCM registration failed silently
        }

        return UserModel.fromJson({
          ...userData,
          'token': token,
          'photoUrl': userData['photoUrl'] ?? googleUser.photoUrl,
          'name': userData['name'] ?? googleUser.displayName,
        });
      } else {
        final jsonResponse = jsonDecode(response.body);
        var error = jsonResponse['error'] ?? jsonResponse['message'] ?? jsonResponse['detail'] ?? 'Error del servidor';
        if (error is Map) {
          error = error['message'] ?? error['detail'] ?? error.toString();
        }

        if (error.toString().contains('Esta cuenta de Google no está registrada')) {
          throw Exception('USER_NOT_REGISTERED|${googleUser.email}|${serverAuthCode ?? ""}');
        }
        throw Exception(error.toString());
      }
    } catch (e, stackTrace) {
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
    
    // IMPORTANTE: Recrear la instancia para resetear los scopes que el profe haya aceptado
    // De lo contrario, si entra un estudiante después en la misma sesión de la app,
    // Google SignIn seguirá recordando y pidiendo los scopes de Classroom/Drive.
    _googleSignIn = GoogleSignIn(
      serverClientId: kIsWeb ? null : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
      ],
    );
  }
}
