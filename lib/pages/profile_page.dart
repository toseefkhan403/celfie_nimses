import 'package:flutter/material.dart';
import 'package:arctic_pups/utils/colors.dart';
import 'package:arctic_pups/utils/size_util.dart';
import 'package:flutter/widgets.dart';
import 'package:arctic_pups/pages/login_page.dart';
import 'package:arctic_pups/main.dart';
import 'package:arctic_pups/pages/notifications_page.dart';
import 'package:arctic_pups/pages/change_theme.dart';
import 'package:arctic_pups/pages/home_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:arctic_pups/utils/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String photoUrl, username, display_name, bio, flames, friends, postCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? Center(
            child: SpinKitChasingDots(
              color: Colors.white,
            ))
            : SingleChildScrollView(child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 102.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 25.0, bottom: 25.0, left: 59.0),
                        child: Text(username),
                      ),
                      SizedBox(
                        width: 115.0,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SettingsList()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.settings),
                        ),
                      )
                    ],
                  ),
                  //photo and stuff
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.contain,
                            ),
                            border: Border.all(
                                width: 34.0, color: Colors.orange)),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 110.0, left: 50.0),
                        child: Chip(
                          label: Text(
                            'Persona',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.white,
                          labelPadding: EdgeInsets.symmetric(
                              vertical: -3.0, horizontal: 4.0),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 40.0,
                  ),

                  Text(display_name),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.face,
                          size: 40.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '$friends',
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.white,
                            width: 2.0,
                            height: 40.0,
                          ),
                        ),
                        Icon(
                          Icons.favorite_border,
                          size: 40.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            flames == null ? '0' : '$flames',
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () {},
                    splashColor: Colors.grey,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 100.0, vertical: 15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: Offset(0.0, 32.0)),
                          ],
                          borderRadius: new BorderRadius.circular(36.0),
                          border: Border.all(
                              color: Colors.black87, width: 1.0)),
                      child: Text(
                        'Get Golden Likes',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway'),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      bio,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(12.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Posts',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          fontFamily: 'Raleway'),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  //staggered grid view here
                  GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      padding: const EdgeInsets.all(1.5),
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children : gridView
                  ),

                ],
              ),
            ))));
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  List<dynamic> friendsList = List(),
      postsList = List();

  void _initData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(user.uid)
        .once();

    DataSnapshot snapshot1 = await FirebaseDatabase.instance
        .reference()
        .child("user_friends")
        .child(user.uid)
        .once();

    DataSnapshot snapshot2 = await FirebaseDatabase.instance
        .reference()
        .child("user_posts")
        .child(user.uid)
        .once();

    DataSnapshot s =
    await FirebaseDatabase.instance.reference().child('posts').once();

    try {
      if (snapshot1 != null)
        friendsList =
            (snapshot1.value as Map<dynamic, dynamic>).values.toList();
    } catch (e) {}

    try {
      if (snapshot2 != null)
        postsList = (s.value as Map<dynamic, dynamic>).values.toList();

      for(int i=0 ; i< postsList.length ; i++){
        gridView.add(Container(color: Colors.white, child: Image.network(postsList[i]['photoUrl1'], fit: BoxFit.cover,),));
      }

//      postsList = (snapshot2.value as Map<dynamic, dynamic>).values.toList();
    } catch (e) {}

    for (int i = 0; i < postsList.length; i++)
      print(postsList[i]['photoUrl1']);

    setState(() {
      photoUrl = snapshot.value['photoUrl'];
      username = snapshot.value['username'];
      bio = snapshot.value['bio'];
      display_name = snapshot.value['display_name'];
      flames = snapshot.value['flames'];
      friends = friendsList.length.toString();
      postCount = postsList.length.toString();
      _isLoading = false;
    });
  }

  List<Widget> gridView = List();
}
