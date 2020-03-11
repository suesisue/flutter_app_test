//edit profile here
//if onboarding, set condition on field values, ie. non-null

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app_test/app_state.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  //final reference = FirebaseDatabase.instance.reference().child('messages');
  TextEditingController profileInputController;
  TextEditingController activityInputController;
  TextEditingController aliasInputController;
  File _image;

  @override
  initState() {
    profileInputController = new TextEditingController();
    activityInputController = new TextEditingController();
    super.initState();
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('blah'),),
        body:StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('messages').snapshots(),
            builder:(context,snapshot){
              if (!snapshot.hasData) return Text('Loading...');
              return ListView(
                children:snapshot.data.documents.map((document)=> new Text(document['email'])).toList(),
              );
            }
        )
    );
  }
*/

  //is this gonna work? async function applied to stream?
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future submitEdits(BuildContext context) async {
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Profile Picture uploaded");
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });

    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    DocumentReference ref = Firestore.instance.collection('profiles').document(appState.userID);
    DocumentSnapshot doc = await ref.get();
    Uri downloadUrl = await firebaseStorageRef.getDownloadURL();
    if (doc.exists) {
      ref.setData({'imageurl': downloadUrl.toString()});
    } else {
      ref.updateData({'imageurl': downloadUrl.toString()});
    }

    if (profileInputController.text.isNotEmpty) {
          ref.updateData({'profile': profileInputController.text});
          ref.updateData({'alias': aliasInputController.text});
          //ref.updateData({'activity': activityInputController.text});
          //ref.updateData({'postcode': postcodeInputController.text});
          //.catchError((err) => print(err));
    }
    //Navigate.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    print('settings.dart:userID:' + appState.userID.toString());
    if (appState.isNewUser){
      return Scaffold(
          appBar: AppBar(title: Text('Edit Profile')),
          body: newUserProfileBuilder(context));
          }
    return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('profiles').document(appState.userID).snapshots(),
            builder: (context, snapshot) {
              DocumentSnapshot document = snapshot.data;
              return profileBuilder(context, document);
              }
        )
    );
  }

  Widget profileBuilder(context, document) {
    profileInputController.text = document['profile'];

    return SingleChildScrollView(child:Padding(padding: const EdgeInsets.all(8.0),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        children: [
      Center(child:Row(children: [
        SizedBox(width: 180, height: 180,
          child: (_image != null) ? Image.file(_image) :Image.network(document['imageurl']),),
        IconButton(icon: Icon(FontAwesomeIcons.camera), onPressed: () {getImage();},),
        ])),
      TextFormField(decoration: InputDecoration(labelText: 'alias:'),initialValue: document['alias'],),
      Container(alignment:Alignment.topLeft,height:200,width: 200,//padding: const EdgeInsets.all(10.0),
        child:TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          //controller: profileInputController,
          decoration: InputDecoration(labelText: 'describe yourself a little...'),initialValue: document['profile'],),
      ),
      Row(children: <Widget>[
        RaisedButton(onPressed: () {Navigator.of(context).pop();}, child: Text('cancel'),),
        RaisedButton(onPressed: () {submitEdits(context);}, child: Text('submit'),),
      ],),
    ])));
  }


  Widget newUserProfileBuilder(context) {
    return SingleChildScrollView(child:Column(children: [
      Center(child:Row(children: [
        SizedBox(width: 180, height: 180,
          child: Icon(FontAwesomeIcons.plus)),
        IconButton(icon: Icon(FontAwesomeIcons.camera), onPressed: () {getImage();},),
      ])),
      TextFormField(decoration: InputDecoration(labelText: 'alias:')),
      TextFormField(
          //keyboardType: TextInputType.multiline,
          //maxLines: null,
          //controller: profileInputController,
          decoration: InputDecoration(labelText: 'describe yourself a little...'),
        ),
      Row(children: <Widget>[
        RaisedButton(onPressed: () {Navigator.of(context).pop();}, child: Text('cancel'),),
        RaisedButton(onPressed: () {submitEdits(context);}, child: Text('submit'),),
      ],),
    ]));
  }

  /*
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Text('Edit Profile')),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('profiles').snapshots(),
        builder: (context, snapshot) {
          return ListView(
            children: snapshot.data.documents.map((document){
              //profileInputController.text = document['profile'];
              //activityInputController.text = document['activity'];
              return Column(children:[Text(document['profile']),Text(document['activity'])]);
            }).toList(),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Edit',
        child: Icon(FontAwesomeIcons.pen),
      ),
    );
  }
*/


/*
  _showDialog() async {
    await showDialog<String> (
      context: context,
      child: AlertDialog(
        content:Column(
          children:<Widget>[
            new TextFormField(
              decoration: InputDecoration(labelText: 'describe yourself a little...'),
              controller: profileInputController,
              //initialValue: profileInputController.text,
            ),
            new TextFormField(
              decoration: InputDecoration(labelText: "activities you're interested in..."),
              controller: activityInputController,
              //initialValue: activityInputController.text,
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child:Text('Cancel'),
            onPressed: (){
              profileInputController.clear();
              activityInputController.clear();
              Navigator.pop(context);
            }),
          FlatButton(
            child: Text('Add'),
            onPressed: (){
              if (profileInputController.text.isNotEmpty && activityInputController.text.isNotEmpty){
                Firestore.instance.collection('profiles').document(userID).setData({
                  'profile': profileInputController.text, 'activity': activityInputController.text
                }).then((result)=>{
                  Navigator.pop(context),profileInputController.clear(),activityInputController.clear(),
                }).catchError((err)=>print(err));
              }
            }),
        ],
      )
    );
  }
*/

//chats - set ref to be user-timestamp

}
