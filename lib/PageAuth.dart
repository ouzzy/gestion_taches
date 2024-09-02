import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'PageConnexion.dart';
import 'PageListeTaches.dart';
import 'main.dart';
String email='';
String uid='';
class PageAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
              email=snapshot.data!.email!;
              uid=snapshot.data!.uid;
              print("eeeeeeeeeeeeeeeeeeeeeeeeee"+email);
              print(snapshot.data);
            return PageListeTaches();
          }
          return PageConnexion();
        },
      ),
    );
  }
}