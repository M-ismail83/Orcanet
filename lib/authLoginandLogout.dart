import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

Future<String?> logIn({required String email, required String password}) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return "Success";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      return 'Wrong password provided for that user.';
    } else {
      return e.message;
    }
  } catch (e) {
    return e.toString();
  }
}

Future<String?> logOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    return "Success";
  } catch (e) {
    return e.toString();
  }
}

Future<User?> createUserWithEmailAndPassword(
    String email, String password) async {
  try {
    final credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return credentials.user;
  } catch (e) {
    log("Something went wrong");
  }
  return null;
}
