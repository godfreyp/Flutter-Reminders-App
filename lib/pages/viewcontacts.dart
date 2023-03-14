import 'package:flutter/material.dart';
import '../entities/contact.dart';

class ViewContactsPage extends StatefulWidget {
  final List<Contact> contacts;

  const ViewContactsPage({Key? key, required this.contacts}) : super(key: key);

  @override
  ViewContactsPageState createState() => ViewContactsPageState();
}

class ViewContactsPageState extends State<ViewContactsPage> {
  Future<void> _chooseContactDialog(index) async {
    var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content:
              Text('''Do you want to tag ${widget.contacts[index].firstName} 
              ${widget.contacts[index].middleName} 
              ${widget.contacts[index].lastName}?'''),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(widget.contacts[index]),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
    if (mounted && response != null) {
      Navigator.of(context).pop(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: SingleChildScrollView(
          child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: widget.contacts.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text('''${widget.contacts[index].firstName} 
                  ${widget.contacts[index].middleName} 
                  ${widget.contacts[index].lastName}'''),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        _chooseContactDialog(index);
                      },
                    ),
                  ],
                ),
              ));
        },
      )),
    );
  }
}
