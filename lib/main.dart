import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_app_test/home.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_app_test/settings.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app_test/app_state.dart';

//tidy these up into global or app_state
final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
bool imdone = false;



void main() => runApp(ScopedModel<AppState>(model: AppState(), child:MyApp()));

class MyApp extends StatelessWidget {

  Future<Null> _handleSignIn(model) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential))
        .user;
    print("signed in " + user.displayName + ',' + user.email);
    model.setUserID(user.email);
    //return user;
  }

  //when onboarding new users, add to profiles db with imageurl, location coordinates etc
  Future<Null> _checkNewUser(context, appState) async {
    DocumentSnapshot doc = await Firestore.instance.collection("profiles").document(appState.userID).get();
    //print(doc.toString());
    bool isNewUser = !doc.exists;
    appState.setIsNewUser(isNewUser);
    //if (_isNewUser==null) {print('_isNewUser is null');}
    print('_isNewUser' + isNewUser.toString());
    if (isNewUser) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()),);
    }
  }

  Future<Null> _getUserAlias(appState) async {
    //print(model.userID.toString());
    DocumentSnapshot doc = await Firestore.instance.collection('profiles').document(appState.userID).get();
    //print(doc.exists.toString());
    print(doc.data);
    appState.setUserAlias(doc.data['alias']);
    //print('main.dart:userAlias:' + userAlias);
  }

  Future<Widget> fun(context) async {
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    await _handleSignIn(appState);
    await _checkNewUser(context,appState);
    await _getUserAlias(appState);
    imdone = true;
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  Builder(
        //https://stackoverflow.com/questions/56746976/flutter-stuck-on-log-in
        //https://stackoverflow.com/questions/44004451/navigator-operation-requested-with-a-context-that-does-not-include-a-navigator
      builder: (context) =>  GoogleSignInButton(
        onPressed: () => fun(context).then((response){
          //final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
          //print('main.dart:userAlias:' + appState.userAlias.toString());
          //print('main.dart:userID:' + appState.userID.toString());
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));}))
    ));
  }
}

