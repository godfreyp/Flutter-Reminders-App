import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'handshake.dart';
import 'viewreminder.dart';
import '../entities/user.dart';
import '../entities/reminder.dart';
import '../entities/contact.dart';

class ReminderHome extends StatefulWidget {
  final User user;

  const ReminderHome({Key? key, required this.user}) : super(key: key);

  @override
  ReminderHomeState createState() => ReminderHomeState();
}

class ReminderHomeState extends State<ReminderHome> {
  late Uri getRemindersUrl;
  late Uri getContactsUrl;
  late Uri deleteReminderUrl;
  late List<Reminder> reminders;
  late List<Contact> contacts;
  late final Future reminderFuture;
  late final Future contactFuture;

  void _showMessage(String message) {
    final toDisplay = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(toDisplay);
  }

  void sortReminders() {
    reminders.sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }

  Future<void> _getReminders(Uri url) async {
    final response = await http.post(url,
        body: jsonEncode(<String, String>{'email': widget.user.email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Timed out');
    });
    if (response.statusCode == 200) {
      final retrievedReminders = jsonDecode(response.body) as List;
      setState(() {
        reminders = retrievedReminders
            .map((reminder) => Reminder.fromJson(reminder))
            .toList();
        sortReminders();
      });
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<void> _getContacts(Uri url) async {
    final response = await http.post(url,
        body: jsonEncode(<String, String>{'r_user_id': widget.user.userID}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Timed out');
    });
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body) as Map;
      final retrievedContacts = decodedJson['contacts'] as List;
      setState(() {
        contacts = retrievedContacts
            .map((contact) => Contact.fromJson(contact))
            .toList();
      });
    } else if (response.statusCode == 404) {
      final decodedJson = jsonDecode(response.body) as Map;
      _showMessage(decodedJson['message']);
      _showMessage(
          'Click the handshake icon in the top right for more information');
      setState(() {
        contacts = [];
      });
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<void> _navigateCreateReminder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewReminderPage(user: widget.user, contacts: contacts)),
    );
    if (result != null) {
      setState(() {
        reminders.add(result);
        sortReminders();
      });
    }
  }

  Future<void> _navigateEditReminder(BuildContext context, index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewReminderPage(
              user: widget.user,
              reminder: reminders[index],
              contacts: contacts)),
    );
    if (result != null) {
      setState(() {
        reminders[index] = result;
        sortReminders();
      });
    }
  }

  Future<void> _deleteDialogueBuilder(BuildContext context, index) async {
    var response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  const Text('Are you sure you want to delete this reminder?'),
              actions: [
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ]);
        });

    if (response == true && mounted) {
      _deleteReminder(context, index);
    }
  }

  Future<void> _deleteReminder(BuildContext context, index) async {
    final response = await http.delete(deleteReminderUrl,
        body: jsonEncode(<String, String>{
          'id': reminders[index].id!,
          'email': widget.user.email,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      _showMessage('Reminder deleted successfully');
      setState(() {
        reminders.removeAt(index);
      });
    } else {
      _showMessage('Failed to delete reminder');
      throw Exception('Failed to delete reminder');
    }
  }

  void pushHandshakePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HandshakePage(
                user: widget.user,
              )),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      setState(() {
        getContactsUrl = Uri.parse('http://localhost:8002/getcontacts');
        getRemindersUrl = Uri.parse('http://localhost:8000/getreminders');
        deleteReminderUrl = Uri.parse('http://localhost:8000/deletereminder');
      });
    } else {
      setState(() {
        getContactsUrl = Uri.parse('http://10.0.2.2:8002/getcontacts');
        getRemindersUrl = Uri.parse('http://10.0.2.2:8000/getreminders');
        deleteReminderUrl = Uri.parse('http://10.0.2.2:8000/deletereminder');
      });
    }

    // Learned from stackoverflow response
    // https://stackoverflow.com/a/57793517
    reminderFuture = _getReminders(getRemindersUrl);
    contactFuture = _getContacts(getContactsUrl);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 50.0),
          child: IconButton(
            icon: const Icon(Icons.handshake),
            tooltip: 'Handshake with Contacts App',
            onPressed: () {
              pushHandshakePage(context);
            },
          ),
        ),
      ]),
      body: FutureBuilder(
        future: Future.wait([reminderFuture, contactFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                      title: Text(reminders[index].name!),
                      subtitle: Text(
                          'Deadline: ${DateTime.parse(reminders[index].deadline!).toLocal()}'),
                      trailing: SizedBox(
                          width: 125,
                          child: Row(children: [
                            ReminderCheckBox(reminder: reminders[index]),
                            IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Reminder',
                                onPressed: () async {
                                  _navigateEditReminder(context, index);
                                }),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete Reminder',
                              onPressed: () async {
                                _deleteDialogueBuilder(context, index);
                              },
                            ),
                          ]))),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateCreateReminder(context);
        },
        tooltip: 'Add Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Flutter code for checkbox class modified from
// https://api.flutter.dev/flutter/material/Checkbox-class.html
// accessed: 2023-03-10
class ReminderCheckBox extends StatefulWidget {
  final Reminder reminder;
  const ReminderCheckBox({super.key, required this.reminder});

  @override
  State<ReminderCheckBox> createState() => ReminderCheckBoxState();
}

class ReminderCheckBoxState extends State<ReminderCheckBox> {
  late bool isChecked;

  void _showMessage(String message) {
    final toDisplay = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(toDisplay);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
    }

    return Expanded(
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
          });
        },
      ),
    );
  }
}
