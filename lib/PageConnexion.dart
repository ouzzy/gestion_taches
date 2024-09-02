
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class PageConnexion extends StatefulWidget {
  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool signIn=true;

  Future<void> connexion() async {
    if(_formKey.currentState!.validate()){
      try {
        await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('La connexion a échoué. Vérifiez vos informations et réessayez'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> inscription() async {
    if(_formKey.currentState!.validate()){
      try {
        // Créer l'utilisateur avec Firebase Authentication
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Récupérer l'ID de l'utilisateur créé
        User? user = userCredential.user;
        if (user != null) {
          // Ajouter l'utilisateur à la collection 'users' dans Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': nameController.text,
            'phone':phoneController.text,
            'createdAt': Timestamp.now(),
            'image':imageUrl,
            'uid': user.uid,
            // Ajoutez d'autres champs nécessaires ici, comme 'name', 'phoneNumber', etc.
          });
        }

        // Si tout s'est bien passé, rediriger ou afficher un message de succès
        print('User signed up and added to Firestore');
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('L\'incsription à échoué. Vérifiez vos informations '),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        // Gérer les erreurs ici, comme afficher un message d'erreur à l'utilisateur
      }
    }
  }

  Future<void> inscription2() async {
    if(_formKey.currentState!.validate()){
      try {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('L\'incsription à échoué. '),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();


  bool isLoading=false;
  Future<void> getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        textImage = 'Enregistrement en cours..';
      });
      await uploadFile(pickedFile);
    }
  }
  String imageUrl='';
  String textImage='Choisir une photo de profil';
  Future<void> uploadFile(XFile file) async {
    print(file.path);
    print(file.name);
    print(file.lastModified().toString());
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpg', customMetadata: {'picked-file-path': file.path});
      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot = await reference.putData(await file.readAsBytes(), metadata);
      } else {
        snapshot = await reference.putFile(File(file.path), metadata);
      }


      final urlImage = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl=urlImage;
        textImage='Photo enrégistrée';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      //Fluttertoast.showToast(msg: "Error! Try again!");
      print("""""""""""""""""""""""""""""""object""""""""""""""""""""""""""""""");
      print(e);
      print("""""""""""""""""""""""""""""""object""""""""""""""""""""""""""""""");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        //title: Text('Gestion des taches',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.black,
        child: Column(

          children: [
            Expanded(
              child: Container(
                //width: double.infinity,
                //height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green,
                        Colors.black
                      ]),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(signIn==false?"Inscription":"Connexion",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                          SizedBox(height: 40,),
                          signIn==false?
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)
                            ),
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      color: Colors.black,
                                      child: Icon(Icons.person,color: Colors.white)),
                                ),
                                border: InputBorder.none,
                                labelText: "Nom Complet",
                                labelStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),

                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),
                          ):SizedBox(),
                          signIn==false?SizedBox(height: 30):SizedBox(),
                          signIn==false?
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)
                            ),
                            child: TextFormField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      color: Colors.black,
                                      child: Icon(Icons.phone,color: Colors.white)),
                                ),
                                border: InputBorder.none,
                                labelText: "Téléphone",
                                labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty || value.length<7) {
                                  return 'Veuillez un numéro de téléphone valide';
                                }
                                return null;
                              }
                            ),
                          ):SizedBox(),
                          SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)
                            ),
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    color: Colors.black,
                                      child: Icon(Icons.email_outlined,color: Colors.white)),
                                ),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Veuillez entrer un email valide';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)
                            ),
                            child: TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    color: Colors.black,
                                    child: Icon(Icons.password,color: Colors.white,),
                                  ),
                                ),
                                labelText: "Mot de passe",
                                labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),
                              ),
                              //style: Theme.of(context).textTheme.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty || value.length<6) {
                                  return 'Le mot de passe doit avoir au moins 6 caractères';
                                }
                                return null;
                              },
                              obscureText: true,
                            ),
                          ),
                          signIn==false?SizedBox(height: 20):SizedBox(),
                          signIn==false?
                          InkWell(
                            onTap: (){
                              getImage();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1.0),
                                  child: Icon(Icons.image,color: Colors.black,),
                                  color: Colors.white,
                                ),
                                Text(textImage,style: TextStyle(color: Colors.white),)
                              ],
                            ),
                          ):SizedBox(),
                          SizedBox(height: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              signIn==true?
                              ElevatedButton(
                                onPressed: connexion,
                                child: Text('Se Connecter',style: TextStyle(color: Colors.black),),
                              ):
                              ElevatedButton(
                                onPressed: inscription,
                                child: Text('S\'inscrire',style: TextStyle(color: Colors.black),),
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 30)),
                              Divider(),
                              Padding(padding: EdgeInsets.only(bottom: 30)),
                              signIn==false?
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    signIn=!signIn;
                                  });
                                },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('j\'ai un compte',style: TextStyle(color: Colors.white),),
                                      Text('   Me connecter =>',style: TextStyle(color:Colors.blue),),
                                    ],
                                  )):
                              InkWell(
                                  onTap: (){
                                    setState(() {
                                      signIn=!signIn;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('j\'ai pas de compte',style: TextStyle(color: Colors.white),),
                                      Text('  Créer un compte=>',style: TextStyle(color:Colors.blue),),
                                    ],
                                  )),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.black,
              height: 20,
              child: Text(" OG - FN",style: TextStyle(color: Colors.blueGrey),),
            )
          ],
        ),
      ),
    );
  }
}