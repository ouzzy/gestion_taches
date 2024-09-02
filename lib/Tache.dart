import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String content;
  DateTime dateTime;
  String priority;
  Color color;

  Task({required this.id, required this.title, required this.content, required this.dateTime, required this.priority, required this.color});

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    String priority = data['priority'];
    return Task(
      id: id,
      title: data['title'],
      content: data['content'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      priority: priority,
      color: obtenirColorPrio(priority),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'dateTime': dateTime,
      'priority': priority,
    };
  }

  static Color obtenirColorPrio(String priority) {
    switch (priority) {
      case 'basse':
        return Colors.green;
      case 'moyenne':
        return Colors.orange;
      case 'élevée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static int obtenirOrdrePrio(String priority) {
    switch (priority) {
      case 'élevée':
        return 3;
      case 'moyenne':
        return 2;
      case 'basse':
        return 1;
      default:
        return 0;
    }
  }
}