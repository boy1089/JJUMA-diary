import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:test_location_2nd/global.dart' as global;

class GoogleAccountManager {
  GoogleSignInAccount? currentUser;

  GoogleAccountManager() {
    debugPrint("creating googleAccountManager");
    init();
    debugPrint("created googleAccountManager, user : ${global.currentUser?.id}");

  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
      } else {}
    });

    // await signInWithGoogle();
  }

  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential? userCredential;

    if (kIsWeb){
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);

      } catch (e) {
        print(e);
      }
    } else {
      // Trigger the authentication flow
      global.currentUser = await GoogleSignIn(scopes: <String>[
        'profile',
        'https://www.googleapis.com/auth/photoslibrary',
        'https://www.googleapis.com/auth/photoslibrary.sharing'
      ]).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await global.currentUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      try {
        userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }
    // Once signed in, return the UserCredential
    return userCredential;
  }

  static Future<void> signOut({required BuildContext context}) async {
    // final GoogleSignIn googleSignIn = GoogleSignIn();
    await Firebase.initializeApp();
    print("signing out.. ${global.currentUser}");
    try {
      if (!kIsWeb) {
        // await googleSignIn.disconnect();
        await FirebaseAuth.instance.signOut();
      }
      await FirebaseAuth.instance.signOut();
      global.currentUser = null;
    } catch (e) {
      print("e");
    }
  }
}
