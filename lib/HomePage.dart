import 'package:flutter/material.dart';
import 'package:flutterapp/notification/notification.dart';
import 'package:flutterapp/screens/profilepage.dart';

class HomePageScreen extends StatefulWidget {
  final user;
   HomePageScreen({Key? key, this.user}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("HomePage",style: TextStyle(color: Colors.white),),
        actions:  [
          IconButton( onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          }, icon: const Icon(Icons.ad_units,color: Colors.white,)),
          IconButton( onPressed: () {
            /*Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );*/
          }, icon: const Icon(Icons.add_alert_rounded,color: Colors.white,)),
          IconButton( onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  user: widget.user,
                ),
              ),
            );
          }, icon: const Icon(Icons.supervised_user_circle_rounded,color: Colors.white,)),

        ],
      ),
      body: const Center(
        child: Text("Notification"),
      ),
    );
  }
}
