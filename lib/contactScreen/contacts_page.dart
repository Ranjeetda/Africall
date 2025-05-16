import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../call_screen/call_screen.dart';

class ContactsPage extends StatefulWidget {
  final Function(String) onContactSelected;

  ContactsPage({required this.onContactSelected});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact>? _cachedContacts;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  String? getNameFromNumber(String number) {
    if (_cachedContacts == null) return null;
    String cleanedInput = number.replaceAll(RegExp(r'\D'), '');

    for (var contact in _cachedContacts!) {
      for (var phone in contact.phones) {
        String cleanedPhone = phone.number.replaceAll(RegExp(r'\D'), '');
        if (cleanedPhone.endsWith(cleanedInput) ||
            cleanedInput.endsWith(cleanedPhone)) {
          return contact.displayName;
        }
      }
    }
    return null;
  }

  void loadContactName(String mNumber) async {
    String? name = getNameFromNumber(mNumber);
    String displayName = name ?? "Unknown";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(mNumber, displayName),
      ),
    );
  }

  Future<void> _checkAndRequestPermissions() async {
    if (await Permission.contacts.isGranted) {
      _fetchContacts();
    } else {
      final status = await Permission.contacts.request();

      if (status.isGranted) {
        _fetchContacts();
      } else if (status.isDenied) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Contact permission is required to continue.")),
        );
      } else if (status.isPermanentlyDenied) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission permanently denied. Please enable it from settings."),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true, // improves compatibility with Samsung
      );

      print("Fetched ${contacts.length} contacts");

      setState(() {
        Utils.contacts = contacts.toList();
        _contacts = Utils.contacts;
        _filteredContacts = _contacts;
        _cachedContacts = _contacts;
        _isLoading = false;
      });
    } catch (e) {
      //setState(() => _isLoading = false);
      print("Error fetching contacts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load contacts: $e")),
      );
    }
  }

  List<Contact> getSIPContacts(String search) {
    search = search.toLowerCase();
    List<Contact> searchContactsBegin = [];
    List<Contact> searchContactsContain = [];

    for (var contact in Utils.contacts) {
      final fullName = contact.displayName;
      if (fullName != null) {
        final lowerFullName = fullName.toLowerCase();
        if (lowerFullName.startsWith(search)) {
          searchContactsBegin.add(contact);
        } else if (lowerFullName.contains(search)) {
          searchContactsContain.add(contact);
        }
      }
    }

    searchContactsBegin.addAll(searchContactsContain);
    return searchContactsBegin;
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _contacts);
      return;
    }

    final nameQuery = query.trim().toLowerCase();
    final cleanedQuery = query.replaceAll(RegExp(r'\D'), '').toLowerCase();

    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = (contact.displayName ?? '').toLowerCase();

        final nameMatch = name.contains(nameQuery);

        final phoneMatch = contact.phones.any((phone) {
          final cleanedPhone = phone.number.replaceAll(RegExp(r'\D'), '').toLowerCase();
          return cleanedPhone.contains(cleanedQuery);
        });

        return nameMatch || phoneMatch;
      }).toList();
    });
  }

  bool startsWithNumber(String value) {
    if (value.isEmpty) return false;
    return '0123456789'.contains(value[0]);
  }

  bool startsWithLetter(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'[a-zA-Z]').hasMatch(value[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name or number',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (startsWithNumber(value)) {
                    _filterContacts(value);
                  } else {
                    setState(() {
                      _filteredContacts = getSIPContacts(value);
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: _filteredContacts.isEmpty
                  ? Center(child: Text("No contacts found"))
                  : ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  Contact contact = _filteredContacts[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          final phone = contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : null;
                          if (phone != null && phone.isNotEmpty) {
                            widget.onContactSelected(phone.replaceAll("+", ""));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("No phone number available")),
                            );
                          }
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(contact.displayName ?? 'No name'),
                          subtitle: contact.phones.isNotEmpty
                              ? Text(contact.phones.first.number)
                              : Text('No phone number'),
                          trailing: IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () {
                              final phone = contact.phones.isNotEmpty
                                  ? contact.phones.first.number
                                  : null;
                              if (phone != null && phone.isNotEmpty) {
                                widget.onContactSelected(phone.replaceAll("+", ""));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("No phone number available")),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Divider(height: 1),
                    ],
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
