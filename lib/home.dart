// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_test/favorites.dart';
import 'package:flutter_app_test/list.dart';
import 'package:flutter_app_test/inbox.dart';
import 'package:flutter_app_test/settings.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app_test/app_state.dart';


class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    //_handleSignIn().whenComplete(()=>_checkNewUser(context)).whenComplete(()=>_getUserAlias());
    //if (!imdone) return SizedBox();
    //final appState = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    //print('home.dart:userAlias:' + appState.userAlias.toString());

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.conversation_bubble),
          title: Text('Inbox'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          title: Text('Profile'),
        ),
      ]),
      tabBuilder: (context, index) {
        if (index == 0) {
          return ListScreen();
        } else if (index == 1) {
          return InboxScreen();
        } else {
          return SettingsScreen();
        }
      },
    );
  }

}
