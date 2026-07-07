import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<bool> requestDriveScope();
  Future<bool> requestClassroomScopes(String jwtToken);
  Future<String?> getDriveAccessToken();
  Future<void> signOutFromGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // En Web, no se debe pasar serverClientId porque lanza un error. Usa el del index.html
    serverClientId: kIsWeb ? null : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.student-submissions.me.readonly',
      'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
      'https://www.googleapis.com/auth/drive.readonly',
    ],
  );

  @override
  Future<bool> requestDriveScope() async {
    return await _googleSignIn.requestScopes(['https://www.googleapis.com/auth/drive.readonly']);
  }

  @override
  Future<bool> requestClassroomScopes(String jwtToken) async {
    bool success = await _googleSignIn.requestScopes([
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
      'https://www.googleapis.com/auth/drive.readonly'
    ]);
    
    if (success) {
      // Fire and forget to not block the UI
      _syncClassroomMaterials(jwtToken);
    }
    
    return success;
  }

  Future<void> _syncClassroomMaterials(String jwtToken) async {
    try {
      final token = await getDriveAccessToken();
      if (token == null) return;
      
      GoogleSignInAccount? user = _googleSignIn.currentUser;
      final teacherId = user?.id ?? "unknown";

      // 1. Fetch classroom courses
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
          print('DEBUG: Course $courseId ownerId: $ownerId');
          
          if (teacherFolder != null && teacherFolder['id'] != null) {
            final folderId = teacherFolder['id'];
            
            // 2. Send to backend ingest
            try {
              final ingestUrl = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/subject/ingest');
              final ingestResponse = await http.post(
                ingestUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $jwtToken',
                },
                body: jsonEncode({
                  'course_id': courseId.toString(),
                  'teacher_id': teacherId.toString(),
                  'folder_id': folderId.toString(),
                  'access_token': token,
                }),
              );
              print('Ingest for $courseId: ${ingestResponse.statusCode}');
            } catch (e) {
              print('Error calling ingest for $courseId: $e');
            }
          }
        }
      } else {
        print('Error fetching courses: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in _syncClassroomMaterials: $e');
    }
  }


  @override
  Future<String?> getDriveAccessToken() async {
    try {
      final googleSignInForDrive = GoogleSignIn(
        serverClientId: kIsWeb ? null : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/classroom.courses.readonly',
          'https://www.googleapis.com/auth/classroom.student-submissions.me.readonly',
          'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
          'https://www.googleapis.com/auth/drive.readonly',
        ],
      );
      final user = await googleSignInForDrive.signInSilently();
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (e) {
      print('Error getting drive token: $e');
      return null;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      print('🔵 Iniciando flujo de Google Sign-In (GoogleSignIn.signIn)...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('🟡 Google Sign-In: El usuario canceló la selección de cuenta.');
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      print('✅ Google Sign-In exitoso: Email = ${googleUser.email}');
      final String? serverAuthCode = googleUser.serverAuthCode;

      if (serverAuthCode == null) {
        print('❌ Google Sign-In: serverAuthCode es null.');
        throw Exception('No se pudo obtener el serverAuthCode de Google');
      }

      print('🔵 Enviando serverAuthCode al backend...');
      final targetUrl = '${ApiConfig.apiGatewayUrl}${ApiConfig.authGoogleEndpoint}';
      print('URL Backend: $targetUrl');
      
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'authCode': serverAuthCode}),
      ).timeout(ApiConfig.connectionTimeout);

      print('🔵 Backend respondió con status code: ${response.statusCode}');
      print('Body de la respuesta: ${response.body}');

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
        print('❌ Error del backend: $error');
        throw Exception(error.toString());
      }
    } catch (e, stackTrace) {
      print('❌ ERROR CRÍTICO EN signInWithGoogle (Remote Data Source):');
      print('Excepción: $e');
      print('Stack Trace:\n$stackTrace');
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
