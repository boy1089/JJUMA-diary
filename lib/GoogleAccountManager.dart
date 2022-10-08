import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
// import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as parse;
import 'package:http/http.dart' as http;

class GoogleAccountManager {
  GoogleSignInAccount? currentUser;

  GoogleAccountManager() {
    print("creating googleAccountManager");
    init();
    print("created googleAccountManager");

  }

  void init() async {
    await Firebase.initializeApp();
    await FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
      } else {}
    });
    await signInWithGoogle();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    currentUser = await GoogleSignIn(scopes: <String>[
      'profile',
      'https://www.googleapis.com/auth/photoslibrary',
      'https://www.googleapis.com/auth/photoslibrary.sharing'
    ]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await currentUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
