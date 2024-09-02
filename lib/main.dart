import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'PageAuth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:FirebaseOptions(
        apiKey: "AIzaSyCUmPZsBpfVd3dTXu_3PpsfI9wZUdV8Kgg",
        appId: "1:662699573533:android:6c1eed5060c171ad8c61f4",
        messagingSenderId: "662699573533",
        projectId: "gestion-taches-bf201",
        storageBucket: "gestion-taches-bf201.appspot.com",
    )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des taches',
      home: PageAuth(),
    );
  }
}

