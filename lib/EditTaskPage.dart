
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Tache.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  late String _selectedPriority;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _updateTask() async {
    Navigator.pop(context);
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      await _firestore.collection('Taches').doc(widget.task.id).update({
        'title': _titleController.text,
        'content': _contentController.text,
        'dateTime': _selectedDate,
        'priority': _selectedPriority,
      });
      //Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _contentController = TextEditingController(text: widget.task.content);
    _selectedDate = widget.task.dateTime;
    _selectedPriority = widget.task.priority;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifié tache',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                        child: Container(
                            height: 35,
                            width: 35,
                            color: Colors.black,
                            child: Icon(Icons.title,color: Colors.white)),
                      ),
                      border: InputBorder.none,
                      labelText: "Titre",
                      labelStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),

                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 20,top: 8.0,right: 8,bottom: 8),
                        child: Container(
                            height: 35,
                            width: 35,
                            color: Colors.black,
                            child: Icon(Icons.content_paste,color: Colors.white)),
                      ),
                      border: InputBorder.none,
                      labelText: "Contenu",
                      labelStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.normal,color: Colors.black),

                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le contenu';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: ListTile(
                    title: Text('Date et Heure'),
                    subtitle: Text(DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDate)),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0,right: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      items: ['basse', 'moyenne', 'élevée'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Priorité',border: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateTask,
                  child: Text('Mettre à jour',style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}