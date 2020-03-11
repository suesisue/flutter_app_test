//list all profiles
//TODO: add save (favourite) and distance filter widgets

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app_test/chat.dart';
import 'package:flutter_app_test/app_state.dart';
import 'package:scoped_model/scoped_model.dart';

class ListScreen extends StatefulWidget {

  //final bool favOnly;
  //const ListScreen(this.favOnly);

  @override
  ListScreenState createState() => ListScreenState();
}

//for google signin to work have to enable people api console.developers.google.com,
//AND add SHA1 key https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-app
class ListScreenState extends State<ListScreen> {
  bool _isFavorited = false;
  bool _applyFavFilter = false;

  Future getDocuments() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(
        "profiles").getDocuments();
    var documents = querySnapshot.documents;
    return documents.toList();
  }

  Future getCoordinates(postCode) async {
/*
    final query ="N15 3AS";
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    print("${first.featureName} : ${first.coordinates}");
*/
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(
        postCode, localeIdentifier: 'en_UK');
    return placemark[0].position.latitude;
/*
    print(placemark[0].country);
    print(placemark[0].locality);
    print(placemark[0].administrativeArea);
    print(placemark[0].postalCode);
    print(placemark[0].name);
    print(placemark[0].isoCountryCode);
    print(placemark[0].subLocality);
    print(placemark[0].subThoroughfare);
    print(placemark[0].thoroughfare);
*/
    //double distanceInMeters = await Geolocator().distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);

  }


  @override
  Widget build(BuildContext context) {

    //TODO: implement filters, see https://stackoverflow.com/questions/50567295/listview-filter-search-in-flutter
    String dropdownValue = 'One';
    print('_applyFavFilter:'+ _applyFavFilter.toString());
    return Scaffold(body: Padding(padding: const EdgeInsets.all(8.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
      SizedBox(height: 50,),
        Row(children:[
          Text('Show favourites'),
          IconButton(
              icon: (_applyFavFilter ? Icon(Icons.star) : Icon(Icons.star_border)),
              color: Colors.red[500],
              onPressed:(){_updateFavFilter();})]),
      Row(children: [
        Text('filter by mile-distance from me'),
        DropdownButton<String>(
            value: dropdownValue, icon: Icon(Icons.arrow_downward),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['One', 'Two', 'Free', 'Four'].map<
                DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value, child: Text(value),);
            }).toList())
      ]),
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('profiles').snapshots(),
        builder: (context, snapshot) {
          return _buildCard(context, snapshot.data.documents);
        },))
    ])));
  }


  void _toggleFavorite(context, otherUserAlias) {
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    if (_isFavorited) {
      _isFavorited = false;
      appState.removeFav(otherUserAlias);
    } else {
      _isFavorited = true;
      appState.addFav(otherUserAlias);
    }
    //print('favs:' + appState.favs.toString());
  }

  void _updateFavFilter() {
    if (_applyFavFilter) {
      _applyFavFilter = false;
    } else {
      _applyFavFilter = true;
    }
    //print('_applyFavFilter:' + _applyFavFilter.toString());
  }

  Widget _buildCard(BuildContext context, List<DocumentSnapshot> documents) {
    final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);

    //TODO: don't show my profile in list
    print('list.dart:userAlias:' + appState.userAlias.toString());
    return ListView(
        children: documents.map((document) {
          _isFavorited = appState.favs.contains(document['alias']);
          if (document['alias']==appState.userAlias) return SizedBox();
          //if (applyFavFilter && !appState.favs.contains(document['alias'])) return SizedBox();

          print('favs:' + appState.favs.toString());
          print('_isFavorited:' + _isFavorited.toString());

          return SizedBox(child: Card(child:
          Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
            Image.network(document['imageurl']),
            //Image.network('https://firebasestorage.googleapis.com/v0/b/sue1-6dab3.appspot.com/o/mattcturnbull%40gmail.com.jpg?alt=media&token=a278277a-0763-45d3-aff3-736c55fbf5b9'),
            //Image.network(getImageUrl(document.documentID + (".jpg"))),
            //Image.network(getImageUrl('IMG_20200301_074306.jpg')),
            Row(children:[Text('alias:',style: TextStyle(fontWeight: FontWeight.bold)), Text(document['alias'])]),
            Row(children:[Text('profile:',style: TextStyle(fontWeight: FontWeight.bold)), Text(document['profile'])]),
            Row(children:[Text('activity:',style: TextStyle(fontWeight: FontWeight.bold)), Text(document['activity'])]),
            Text(getCoordinates(document['postcode']).toString()),
            //TODO: create new chatID if new person, else get existing chatID
            IconButton(icon: Icon(Icons.chat), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  //ChatScreen(getOrCreateChatID(context,appState.userAlias,document['alias']))),);
                  ChatScreen('1')),);
            }),
            IconButton(
              icon: (_isFavorited ? Icon(Icons.star) : Icon(Icons.star_border)),
              color: Colors.red[500],
              onPressed: () => _toggleFavorite(context, document['alias']),
            ),
          ])));
        }).toList()
    );
  }

  //a newChatID will get added to 'chats' and 'messages' only when some text is submitted - see chat.dart
  Future<String> getOrCreateChatID(context, userAlias ,otherUserAlias) async {
    print(userAlias + ',' + otherUserAlias);
    QuerySnapshot query = await Firestore.instance.collection('chats').where('members',arrayContains: userAlias)
        .where('members',arrayContains: otherUserAlias).getDocuments();
    List<DocumentSnapshot> snapshots = query.documents;
    if (snapshots.length>0) {
      print(snapshots[0].data);
      return snapshots[0].data.keys.first;
    } else {
      //easier way to do this?
      QuerySnapshot query2 = await Firestore.instance.collection('chats').getDocuments();
      String lastChatID = query2.documents[0].data.keys.last;
      String newChatID = (int.parse(lastChatID) + 1) as String;
      return newChatID;
    }
  }

}