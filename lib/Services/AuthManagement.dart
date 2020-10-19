import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  BuildContext context;
  SharedPreferences _prefs;

  initialise() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Auth(context) {
    this.context = context;
    initialise();
  }

  Future<void> signIn(String _email, String _password) async {
    // Start showing progress indicator
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Just a moment');
    pr.show();

    // Sign in -> Set shared preferences(root, admin, email) -> check if user is email verified -> Navigate to home screen on success
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then((user) async {
      getAdmins(_email).then((docs) {
        _prefs.setBool('admin', docs.documents.length > 0);
        _prefs.setString("email", _email);
      });
      getRoots(_email).then((docs) {
        _prefs.setBool('root', docs.documents.length > 0);
      });
      FirebaseUser user = await getUser();
      pr.hide();
      if (user.isEmailVerified) {
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        Fluttertoast.showToast(msg: 'Email not verified!');
      }
    }).catchError((e) {
      pr.hide();
      print(e);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        tittle: 'Error',
        desc: "Recheck your network connection or credentials",
        animType: AnimType.BOTTOMSLIDE,
      ).show();
    });
  }

  Future<String> signUp(String name, String email, String password) async {
    FirebaseUser user;
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Creating account');
    pr.show();

    // Add user data to *users* collection -> Sign up -> Send Email verification -> Set shared preferences -> return user id

    await Firestore.instance.collection('/users').add(
        {'name': name, 'email': email, 'isadmin': false}).then((val) async {
      _prefs.setString('email', email);
      _prefs.setBool('admin', false);
      _prefs.setBool('root', false);

      user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      await user.sendEmailVerification();
      pr.hide();
      Fluttertoast.showToast(
          msg: 'Account created successfully, Please verify your email',
          toastLength: Toast.LENGTH_LONG);
      Navigator.of(context).pop();
    }).catchError((e) async {
      pr.hide();
      Fluttertoast.showToast(msg: 'Error creating account');
    });

    return user.uid;
  }

  // Returns current user of type FirebaseUser
  getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  // Return user email
  Future<String> getUserEmail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.email;
  }

  Future<void> signOut() async {
    // Signout -> Set preferences to null -> navigate to landing page
    await FirebaseAuth.instance.signOut().then((value) {
      _prefs.setBool('admin', null);
      _prefs.setString('email', null);
      _prefs.setBool('root', null);
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/landingpage', (v) => false);
    }).catchError((e) {
      print(e);
    });
  }

  getAdmins(String email) {
    var docs = Firestore.instance
        .collection('/users')
        .where('email', isEqualTo: email)
        .where('isadmin', isEqualTo: true)
        .getDocuments();
    return docs;
  }

  getRoots(String email) {
    var docs = Firestore.instance
        .collection('/root')
        .where('email', isEqualTo: email)
        .getDocuments();
    return docs;
  }

  resetPassword(email) async {
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Sending password reset email');
    pr.show();
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    pr.hide();
    Fluttertoast.showToast(msg: 'Email sent!');
  }

  verifyEmail() async {
    FirebaseUser user = await getUser();
    if (user == null) {
      Fluttertoast.showToast(msg: 'User not found, Try signing up');
    } else {
      user.sendEmailVerification();
    }
  }
}
