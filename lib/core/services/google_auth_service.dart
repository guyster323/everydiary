import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 인증 서비스
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google 로그인
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Google 로그인 시작');

      // Google Sign-In 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ Google 로그인 취소됨');
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        debugPrint('✅ Google 로그인 성공: ${user.email}');
        return user;
      } else {
        debugPrint('❌ Google 로그인 실패: 사용자 정보 없음');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Google 로그인 오류: $e');
      return null;
    }
  }

  /// Google 로그아웃
  Future<void> signOut() async {
    try {
      debugPrint('🔄 Google 로그아웃 시작');
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint('✅ Google 로그아웃 완료');
    } catch (e) {
      debugPrint('❌ Google 로그아웃 오류: $e');
    }
  }

  /// 현재 사용자 정보
  User? get currentUser => _auth.currentUser;

  /// 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 로그인 상태 확인
  bool get isSignedIn => _auth.currentUser != null;
}

