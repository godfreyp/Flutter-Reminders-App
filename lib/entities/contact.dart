class Contact {
  final String firstName;
  final String middleName;
  final String lastName;
  final String contactID;

  Contact(this.contactID,
      [this.firstName = "", this.middleName = "", this.lastName = ""]);

  Contact.fromJson(Map<String, dynamic> json)
      : firstName = json['f_name'],
        middleName = json['m_name'],
        lastName = json['l_name'],
        contactID = json['contact_id'];
}
