import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_taches/EditProfil.dart';
import 'package:intl/intl.dart';

import 'EditTaskPage.dart';
import 'PageAjoutTaches.dart';
import 'PageAuth.dart';
import 'Tache.dart';
import 'main.dart';
String userName='',userPhone='',userImage='';
class PageListeTaches extends StatefulWidget {
  @override
  State<PageListeTaches> createState() => _PageListeTachesState();
}

class _PageListeTachesState extends State<PageListeTaches> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchValue='';
  @override
  void initState() {
    super.initState();
    final docRef = FirebaseFirestore.instance.collection("users").doc(uid);
    docRef.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState((){
          userName=data['name'];
          userPhone=data['phone'];
          userImage=data['image'];
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () async {
            print(userImage);
            print(userPhone);
            print(userName);
            //var user= await FirebaseFirestore.instance.collection('users').doc(uid).get();
            //print("object");
            //print(user.data());
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfil()));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(image: NetworkImage(userImage),fit: BoxFit.fill,onError: (exception, stackTrace) {
                  Material(
                    child: Image.asset(
                      "assets/img_not_available.jpeg",
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  );
                },

                )
              ),
              /*child: Image.network(userImage, fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, object, stackTrace) {
                  return Material(
                    child: Image.asset(
                      "assets/img_not_available.jpeg",
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  );
                }),*/

            ),
          ),
        ),
        title: Text(email,style: TextStyle(color: Colors.black,fontSize: 18),),
        actions: [
          Row(
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAjoutTaches()),
                  );
                },
                  child: Text('ajouter',style: TextStyle(color: Colors.black),)),
              IconButton(
                icon: Icon(Icons.add,color: Colors.black,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAjoutTaches()),
                  );
                },
              ),
            ],
          ),
        ],
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.green,
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await auth.signOut();
        },
        child: Text('Déconnecter',style: TextStyle(color: Colors.black),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,),
              child: TextFormField(
                initialValue: searchValue,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Rechercher ',
                ),
                /*decoration: textInputDecoration.copyWith(hintText: 'Motivation'),*/
                onChanged: (value) {
                  setState(() {
                    searchValue = value.toString().toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Taches').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Convertir les documents en objets Task
                  List<Task> tasks = snapshot.data!.docs.map((doc) {
                    return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  // Trier les tâches par ordre de priorité
                  tasks.sort((a, b) => Task.obtenirOrdrePrio(b.priority).compareTo(Task.obtenirOrdrePrio(a.priority)));

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return searchValue==''?Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditTaskPage(task: tasks[index])),
                              );
                            },
                            child: Container(
                              //color: tasks[index].color,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.category,color: tasks[index].color,),
                                            Container(child: Text('  '+tasks[index].title,style: TextStyle(fontSize: 20),)),
                                          ],
                                        ),
                                        Container(child: Text(DateFormat('yyyy-MM-dd – HH:mm').format(tasks[index].dateTime))),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      /*IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditTaskPage(task: tasks[index])),
                                          );
                                        },
                                      ),*/
                                      IconButton(
                                          onPressed: ()  {
                                            _firestore.collection('Taches').doc(tasks[index].id).delete();
                                          },
                                          icon: Icon(Icons.delete_forever,color: Colors.red,))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider()
                        ],
                      )
                      :tasks[index].title.toString()
                          .toLowerCase()
                          .contains(searchValue.toLowerCase())?Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditTaskPage(task: tasks[index])),
                              );
                            },
                            child: Container(
                              //color: tasks[index].color,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.category,color: tasks[index].color,),
                                            Container(child: Text('  '+tasks[index].title,style: TextStyle(fontSize: 20),)),
                                          ],
                                        ),
                                        Container(child: Text(DateFormat('yyyy-MM-dd – HH:mm').format(tasks[index].dateTime))),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      /*IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditTaskPage(task: tasks[index])),
                                          );
                                        },
                                      ),*/
                                      IconButton(
                                          onPressed: ()  {
                                            _firestore.collection('Taches').doc(tasks[index].id).delete();
                                          },
                                          icon: Icon(Icons.delete_forever,color: Colors.red,))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider()
                        ],
                      ):SizedBox();
                      /*return ListTile(
                        title: Container(child: Text(tasks[index].title)),
                        subtitle: Container(child: Text(DateFormat('yyyy-MM-dd – HH:mm').format(tasks[index].dateTime))),
                        trailing: Container(
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditTaskPage(task: tasks[index])),
                                  );
                                },
                              ),
                              IconButton(
                                  onPressed: ()  {
                                    _firestore.collection('Taches').doc(tasks[index].id).delete();
                                  },
                                  icon: Icon(Icons.delete_forever))
                            ],
                          ),
                        ),
                        tileColor: tasks[index].color,
                      );*/
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}