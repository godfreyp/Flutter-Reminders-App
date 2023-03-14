import 'dart:ffi';

class Reminder {
  final String? id;
  final String? name;
  final String? email;
  final String? description;
  final String? deadline;
  final String? contact_name;
  final String? contact_id;

  Reminder(this.id, this.name, this.email, this.description, this.deadline,
      this.contact_name, this.contact_id);

  Reminder.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        description = json['description'],
        deadline = json['deadline'],
        contact_name = json['contact_name'],
        contact_id = json['contact_id'];
}
