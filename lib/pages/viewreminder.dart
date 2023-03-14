import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import '../entities/user.dart';
import '../entities/reminder.dart';
import '../entities/contact.dart';
import 'viewcontacts.dart';

class ViewReminderPage extends StatefulWidget {
  final User user;
  final Reminder? reminder;
  final List<Contact> contacts;
  const ViewReminderPage(
      {Key? key, required this.user, required this.contacts, this.reminder})
      : super(key: key);
  @override
  ViewReminderPageState createState() => ViewReminderPageState();
}

class ViewReminderPageState extends State<ViewReminderPage> {
  late final Uri createReminderUrl;
  late final Uri updateReminderUrl;
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController deadlineController;
  late final TextEditingController contactName;
  late final TextEditingController contactID;
  late final bool isUpdate;
  bool isLoading = false;
  DateTime setDate = DateTime.now();

  void _showMessage(String message) {
    final toDisplay = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(toDisplay);
  }

  Future<Reminder> _createReminder() async {
    toggleLoading(true);
    final response = await http.post(createReminderUrl,
        body: jsonEncode(<String, String>{
          'name': nameController.text,
          'email': widget.user.email,
          'description': descriptionController.text,
          'deadline': deadlineController.text,
          'contact_name': contactName.text,
          'contact_id': contactID.text
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      toggleLoading(false);
      throw Exception('Timed out');
    });
    toggleLoading(false);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      _showMessage('Reminder created');
      return Reminder(
          decodedJson['id'].toString(),
          nameController.text.toString(),
          widget.user.email,
          descriptionController.text.toString(),
          deadlineController.text.toString(),
          contactName.text.toString(),
          contactID.text.toString());
    } else {
      throw Exception('Failed to create reminder');
    }
  }

  Future<Reminder> _updateReminder() async {
    toggleLoading(true);
    final response = await http.put(updateReminderUrl,
        body: jsonEncode(<String, dynamic>{
          'id': widget.reminder!.id!,
          'new_reminder': {
            'name': nameController.text,
            'email': widget.user.email,
            'description': descriptionController.text,
            'deadline': deadlineController.text,
            'contact_name': contactName.text,
            'contact_id': contactID.text
          },
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      toggleLoading(false);
      throw Exception('Timed out');
    });
    toggleLoading(false);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      _showMessage('Reminder updated');
      return Reminder(
          decodedJson['id'].toString(),
          nameController.text.toString(),
          widget.user.email,
          descriptionController.text.toString(),
          deadlineController.text.toString(),
          contactName.text.toString(),
          contactID.text.toString());
    } else {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> _navigateAddContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewContactsPage(contacts: widget.contacts)),
    );
    if (result == null) {
      return;
    }
    var fullName = '';
    if (result.middleName == '') {
      fullName = '${result.firstName} ${result.lastName}';
    } else {
      fullName = '${result.firstName} ${result.middleName} ${result.lastName}';
    }
    setState(() {
      contactName.text = fullName;
      contactID.text = result.contactID;
    });
  }

  Future pickDateTime() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: setDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date == null) {
      return;
    }
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute)
        .toLocal();
  }

  void toggleLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.reminder == null) {
      nameController = TextEditingController();
      descriptionController = TextEditingController();
      deadlineController = TextEditingController();
      contactName = TextEditingController();
      contactID = TextEditingController();
      if (Platform.isWindows) {
        createReminderUrl = Uri.parse('http://localhost:8000/createreminder');
        updateReminderUrl = Uri.parse('http://localhost:8000/updatereminder');
      } else {
        createReminderUrl = Uri.parse('http://10.0.2.2:8000/createreminder');
        updateReminderUrl = Uri.parse('http://10.0.2.2:8000/updatereminder');
      }
      isUpdate = false;
      setDate = DateTime.now().toLocal();
    } else {
      nameController = TextEditingController(text: widget.reminder?.name);
      descriptionController =
          TextEditingController(text: widget.reminder?.description);
      deadlineController =
          TextEditingController(text: widget.reminder?.deadline);
      contactName = TextEditingController(text: widget.reminder?.contact_name);
      contactID = TextEditingController(text: widget.reminder?.contact_id);
      isUpdate = true;
      if (Platform.isWindows) {
        createReminderUrl = Uri.parse('http://localhost:8000/createreminder');
        updateReminderUrl = Uri.parse('http://localhost:8000/updatereminder');
      } else {
        createReminderUrl = Uri.parse('http://10.0.2.2:8000/createreminder');
        updateReminderUrl = Uri.parse('http://10.0.2.2:8000/updatereminder');
      }
      setDate = DateTime.parse(widget.reminder!.deadline!).toLocal();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    contactName.dispose();
    contactID.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = setDate.hour.toString().padLeft(2, '0');
    final minutes = setDate.minute.toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Reminder'),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scrollbar(
              child: ListView(
            children: [
              ListTile(
                title: const Text('Reminder Name'),
                subtitle: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter reminder name (Required)',
                  ),
                ),
              ),
              ListTile(
                title: const Text('Description'),
                subtitle: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter description (Required)',
                  ),
                ),
              ),
              ListTile(
                title: const Text('Deadline'),
                subtitle: Text(
                    '${setDate.year}-${setDate.month}-${setDate.day} $hours:$minutes'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final pickedDateTime = await pickDateTime();
                    if (pickedDateTime == null) {
                      return;
                    }
                    setState(() {
                      setDate = pickedDateTime;
                      deadlineController.text =
                          pickedDateTime.toUtc().toString();
                    });
                  },
                ),
              ),
              ListTile(
                  title: const Text('Add Contact (Optional)'),
                  subtitle: TextField(
                    controller: contactName,
                    enabled: false,
                  ),
                  trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (widget.contacts.isEmpty) {
                          _showMessage(
                              'No contacts found, sync or add contacts in the contacts app');
                          return;
                        }
                        await _navigateAddContact();
                      })),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            descriptionController.text.isEmpty ||
                            deadlineController.text.isEmpty) {
                          _showMessage('Please fill in all required fields');
                          return;
                        }

                        if (isUpdate == true) {
                          var response = await _updateReminder();
                          if (mounted) {
                            Navigator.pop(context, response);
                          }
                        } else {
                          var response = await _createReminder();
                          if (mounted) {
                            Navigator.pop(context, response);
                          }
                        }
                      },
                      child: const Text('Add Reminder'),
                    )
            ],
          )),
        );
      }),
    );
  }
}
