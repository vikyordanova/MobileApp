import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapErrorToBg(e.code);
    } catch (e, stack) {
      print('🔥 Login error: $e');
      print(stack);
      throw 'Възникна неочаквана грешка. Опитайте отново.';
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'createdAt': DateTime.now(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapErrorToBg(e.code);
    } catch (e, stack) {
      print('🔥 Register error: $e');
      print(stack);
      throw 'Възникна неочаквана грешка. Опитайте отново.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapErrorToBg(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Невалиден имейл адрес.';
      case 'user-disabled':
        return 'Този акаунт е деактивиран.';
      case 'user-not-found':
        return 'Няма потребител с този имейл.';
      case 'wrong-password':
        return 'Грешна парола.';
      case 'email-already-in-use':
        return 'Имейлът вече се използва.';
      case 'weak-password':
        return 'Паролата трябва да съдържа поне 6 символа.';
      default:
        return 'Възникна грешка. Опитайте отново.';
    }
  }
}
