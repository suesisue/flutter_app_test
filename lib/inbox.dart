import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_test/chat.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app_test/app_state.dart';

class InboxScreen extends StatelessWidget {

  @override
  // querying user1 or user2
  // https://stackoverflow.com/questions/53287717/flutter-merge-two-firestore-streams-into-a-single-stream?rq=1
  Widget build(BuildContext context) {
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    return Scaffold(body:
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('chats').where('members',arrayContains: appState.userAlias).snapshots(),
        builder: (context, snapshot) {
          List<DocumentSnapshot> documents = snapshot.data.documents;
          return ListView(
              children: (documents.map((document) {
                List<String> members = List.from(document['members']);
                members.remove(appState.userAlias);
                //String otherMembers = members.reduce((value, element) => value + ',' + element);
                String otherMembers = members[0];
                String chatID = document.documentID;
                return GestureDetector(
                  child: SizedBox(height:50,child:
                    Card(child:
                    Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Text(otherMembers, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(document['last_message'])]))),
                  onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen(chatID)),);
                },); //TODO dsplay last msg
              })).toList());
        }
    ));
  }

}