import 'package:flutter/material.dart';

class TeamTask {
  final int id;
  final String title;
  final String description;
  final String deadline;
  final String taskStatus;
  final int taskPriority;
  final String assigneeMemberName;

  TeamTask({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.taskStatus,
    required this.taskPriority,
    required this.assigneeMemberName
  });

  factory TeamTask.fromJson(Map<String, dynamic> json) {
    return TeamTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'],
      taskStatus: json['taskStatus'],
      taskPriority: json['taskPriority'],
      assigneeMemberName: json['assigneeMemberName'] ?? '-'
    );
  }

  Color getPriorityColor() {
    switch (taskPriority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
