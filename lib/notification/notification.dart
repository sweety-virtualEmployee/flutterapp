import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterapp/HomePage.dart';
import 'package:flutterapp/main.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController text = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? mtoken = " ";

  @override
  void initState() {
    super.initState();

    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  void getTokenFromFirestore() async {}

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("User").doc("QzNE1N7VSjeMgucRkNPjNbmuq4i1").set({
      'token': token,
    });
    await FirebaseFirestore.instance.collection("User").doc("aKZmWhHwjiU7RXlSG3G0U6BSBFy2").set({
      'token': token,
    });
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAA6IAb9qE:APA91bGvMV5a7qKjzdeKuCO4ux7Z163jUiZM_5wCefl3xhNRcQ0xevPWMsXiGjJ8ee6mByOtQUpR7Y4kpkCPux_K4b47jJwamDdREIDjHPe8tmBvm6qiMa3a6a_yccj8jqzYlDuXvwKX',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'id': '1', 'status': 'done'},
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });

      saveToken(token!);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  IconButton( onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>  HomePageScreen(),
              ));
        }, icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text("Notification",style: TextStyle(color: Colors.white),),
        actions:  const [

        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left:20,right:20,top:50),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: text,
                    decoration: InputDecoration(hintText: "Message"),
                  ),
                  TextFormField(
                    controller: title,
                    decoration: InputDecoration(hintText: "Title"),
                  ),
                  TextFormField(
                    controller: body,
                    decoration: InputDecoration(hintText: "Body"),
                  ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     String name = username.text.trim();
                  //     String titleText = title.text;
                  //     String bodyText = body.text;
                  //
                  //     if(name != "") {
                  //       DocumentSnapshot snap =
                  //       await FirebaseFirestore.instance.collection("UserTokens").doc(name).get();
                  //
                  //       String token = snap['token'];
                  //       print(token);
                  //
                  //       sendPushMessage(token, titleText, bodyText);
                  //     }
                  //   },
                  //   child: Container(
                  //     height: 40,
                  //     width: 200,
                  //     color: Colors.red,
                  //
                  //   ),
                  // ),
                  const SizedBox(height:30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton(
                        color: Colors.blue,
                        child:const  Text("Send Notification to ALL"),
                        onPressed: () async {
                          var headers = {
                            'Content-Type': 'application/json',
                            'Authorization':
                            'key=AAAA6IAb9qE:APA91bGvMV5a7qKjzdeKuCO4ux7Z163jUiZM_5wCefl3xhNRcQ0xevPWMsXiGjJ8ee6mByOtQUpR7Y4kpkCPux_K4b47jJwamDdREIDjHPe8tmBvm6qiMa3a6a_yccj8jqzYlDuXvwKX'
                          };
                          var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
                          request.body = json.encode({
                            "to": "/topics/all",
                            "priority": "high",
                            "notification": {"title": title.text, "body": body.text, "text": text.text}
                          });
                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

                          if (response.statusCode == 200) {
                            var data = json.decode(await response.stream.bytesToString());
                            print("$data");
                          } else {
                            print(response.reasonPhrase);
                          }
                        }),
                  )  ,
                  const SizedBox(height:20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton(
                        color: Colors.blue,
                        child:const  Text("Send Notification to Single"),
                        onPressed: () async {
                          var headers = {
                            'Content-Type': 'application/json',
                            'Authorization': 'key=AAAA6IAb9qE:APA91bGvMV5a7qKjzdeKuCO4ux7Z163jUiZM_5wCefl3xhNRcQ0xevPWMsXiGjJ8ee6mByOtQUpR7Y4kpkCPux_K4b47jJwamDdREIDjHPe8tmBvm6qiMa3a6a_yccj8jqzYlDuXvwKX'
                          };
                          var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
                          request.body = json.encode({
                            "to": token,
                            "priority": "high",
                            "notification": {"title": title.text, "body": body.text, "text": text.text}
                          });
                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

                          if (response.statusCode == 200) {
                            print(await response.stream.bytesToString());
                          }
                          else {
                            print(response.reasonPhrase);
                          }

                        }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
