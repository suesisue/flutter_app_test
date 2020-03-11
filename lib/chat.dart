import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:async/async.dart';
import 'package:flutter_app_test/app_state.dart';
import 'package:scoped_model/scoped_model.dart';

//structure chats in db like so (this is doc for firebaseStorage not cloud_firestore btw, don't get confused):
//https://firebase.google.com/docs/database/web/structure-data

class ChatScreen extends StatefulWidget
{
  final String chatID;
  const ChatScreen(this.chatID);
  //const ChatScreen({Key key, this.chatID}): super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  final TextEditingController _textEditingController = new TextEditingController();

  DocumentSnapshot _snap;
  Future<DocumentSnapshot> getFirstSnap() async {
    _snap =  await Firestore.instance.collection('messages').document(widget.chatID).snapshots().first;
    print(_snap.data);
  }

  @override
  Widget build(BuildContext context) {
    //getFirstSnap();
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    print('chat.dart:userAlias:' + appState.userAlias.toString());

    return new Scaffold(
      appBar: new AppBar(title: new Text("Chat history"),),
      body: new Column(
        children: [
          new Flexible(child:
            StreamBuilder<DocumentSnapshot> (
            stream:Firestore.instance.collection('messages').document(widget.chatID).snapshots(),
            builder: (context, snapshot) {
              //print('snap:' + snapshot.hasData.toString());
              Map<String,dynamic> msgs = snapshot.data.data;//assume sorted?
              print('chat.dart:msgs:' + msgs.toString());
              List<String> sortedKeys = msgs.keys.toList()..sort();

              var msgs_sorted = Map.fromEntries(msgs.entries.toList()..sort((e1, e2) =>
                  int.parse(e1.key).compareTo(int.parse(e2.key))));
              print('chat.dart:msgs:' + msgs_sorted.toString());

              return ListView(
                children: msgs_sorted.entries.map((msg) {
                  if (msg.value['name']==appState.userAlias) {
                    return Align(alignment: Alignment.topRight, child:
                    Container(decoration: BoxDecoration(border: new Border.all(color: Colors.grey, width:1.0, style: BorderStyle.solid), borderRadius: new BorderRadius.circular(10.0),color: Colors.green[50]),
                          child:Text(msg.value['message']),padding:EdgeInsets.all(5.0),));
                  } else {
                    return Align(alignment: Alignment.topLeft, child:
                    Container(decoration: BoxDecoration(border: new Border.all(color: Colors.grey, width:1.0, style: BorderStyle.solid), borderRadius: new BorderRadius.circular(10.0)),
                        child:Text(msg.value['message']),padding:EdgeInsets.all(5.0),));
                  }
                }).toList());
            },)
/*
            FirebaseAnimatedList(
                query: FirebaseDatabase.instance.reference().child("chats").child('from').equalTo('zihuayang2046@gmail.com'),
                reverse: false,
                itemBuilder: (_, snapshot, animation, x){return Text(snapshot.value.toString());}
            ),
*/
          ),

          new Card(child: new TextField(
            controller: _textEditingController,
            onSubmitted: _textMessageSubmitted,
            decoration:new InputDecoration.collapsed(hintText: "Send a message"),
            )),
        ],
      ),
    );
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);

    int timestamp = new DateTime.now().millisecondsSinceEpoch;
    String msgID = timestamp.toString();
    DocumentReference chatRef = await Firestore.instance.collection('messages').document(widget.chatID);
    DocumentSnapshot doc = await chatRef.get();

    if (doc.exists) {
      chatRef.setData({msgID:{'name': appState.userAlias, 'message':text}},merge:true);
      Firestore.instance.collection('chats').document(widget.chatID).updateData({'last_message':text,'name':appState.userAlias});
    } else {
      chatRef.setData({msgID:{'name': appState.userAlias, 'message':text}});
      Firestore.instance.collection('chats').document(widget.chatID).setData({'last_message':text,'name':appState.userAlias});
    }

  }

}
