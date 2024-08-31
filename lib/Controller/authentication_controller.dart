import 'package:firebase_auth/firebase_auth.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/messages.dart';

class Authentication {
  final user = FirebaseAuth.instance.currentUser;

  Future<String?> registerUser(
      String email, String password, String name) async {
    try {
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String authUID = userCred.user!.uid;
      await UserDBController().userSetup(name, authUID, email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Messages.passwordTooWeak;
      } else if (e.code == 'email-already-in-use') {
        return Messages.accountAlreadyExsists;
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return Messages.invalidCredentials;
      } else if (e.code == 'user-not-found') {
        return Messages.userNotFoundForEmail;
      } else if (e.code == 'wrong-password') {
        return Messages.wrongPassword;
      }
    }
    return null;
  }
}
