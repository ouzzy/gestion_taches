
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_taches/PageAuth.dart';
import 'package:gestion_taches/PageListeTaches.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'Tache.dart';

class EditProfil extends StatefulWidget {

  @override
  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  late  TextEditingController nameController = TextEditingController();
  late  TextEditingController phoneController = TextEditingController();
  late  TextEditingController imageUrlController = TextEditingController();
  String imageUrl='';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _updateTask() async {
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'image': imageUrl!=''?imageUrl:userImage
      });
    }
    setState((){
      userName=nameController.text;
      userPhone=phoneController.text;
      userImage=imageUrl!=''?imageUrl:userImage;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userName);
    phoneController = TextEditingController(text: userPhone);
  }

  bool isLoading=false;
  String textImage='Choisir une photo de profil';
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
        textImage='Image de profil enregistré';
      });
      /*setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });*/
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
        title: Text('Modifier Profil'),
        backgroundColor: Colors.green,
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black12,
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
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black12,
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
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: (){
                  getImage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(Icons.image,color: Colors.white,),
                      color: Colors.black,
                    ),
                    Text(textImage,style: TextStyle(color: Colors.black),)
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Mettre à jour',style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}