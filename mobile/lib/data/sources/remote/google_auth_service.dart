import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class GoogleAuthService {
  final Dio _dio;
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService(this._dio) {
    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
      // Add serverClientId to get ID Token
      serverClientId: '823375731447-5c6ihm72td3vfil639r4is13h8fjcvq1.apps.googleusercontent.com',
    );
  }

  /// Sign in with Google and get account
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Try to sign in silently first
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, prompt user
      account ??= await _googleSignIn.signIn();
      
      return account;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  /// Get ID Token from current signed-in account
  Future<String?> getIdToken() async {
    try {
      // Get current user
      final account = _googleSignIn.currentUser;
      if (account == null) {
        print('No current user');
        return null;
      }

      // Get authentication
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    } catch (error) {
      print('Error getting ID token: $error');
      return null;
    }
  }

  /// Sign out and disconnect from Google
  Future<void> signOut() async {
    try {
      // Disconnect will force user to select account again next time
      await _googleSignIn.disconnect();
      print('Google disconnected successfully');
    } catch (error) {
      print('Error disconnecting: $error');
      // Fallback to signOut if disconnect fails
      try {
        await _googleSignIn.signOut();
        print('Google signed out successfully');
      } catch (e) {
        print('Error signing out: $e');
      }
    }
  }

  /// Login to backend with Google ID Token
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '${AppConfig.ngrokBaseUrl}/api/auth/google',
        data: {'idToken': idToken},
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Google login failed');
      }
    } catch (e) {
      print('Backend Google login error: $e');
      throw Exception('Đăng nhập Google thất bại');
    }
  }

  /// Complete Google Sign-In flow
  Future<Map<String, dynamic>?> signInAndAuthenticate() async {
    try {
      // Step 1: Sign in with Google
      final account = await signIn();
      if (account == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // Step 2: Get ID Token
      final idToken = await getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Google ID Token');
      }

      // Step 3: Send ID Token to backend
      final authData = await loginWithGoogle(idToken);
      
      return authData;
    } catch (error) {
      print('Complete Google Sign-In error: $error');
      rethrow;
    }
  }
}
