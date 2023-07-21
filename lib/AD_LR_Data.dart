import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/ShowMap.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'Login.dart';

class Contact {
  final String VehicleNo;
  final String Origin;
  final String Destination;

  Contact(this.VehicleNo, this.Origin, this.Destination);
}

class AdminLRData extends StatefulWidget {
  const AdminLRData({Key? key}) : super(key: key);

  @override
  State<AdminLRData> createState() => _AdminLRDataState();
}

class _AdminLRDataState extends State<AdminLRData> {
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  var client = http.Client();

  void _fetchLRData() async {
    try {
      const API_URL = '$API/LRGPS/VehicleNo';
      //const API_URL = '$NTPL_API/LRGPS/VehicleNo';
      //final String _accessToken = 'PNHmjvVzGJzPEUdeW7lWqw==';
      final String _accessToken = accessToken;

      final response = await client.get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          for (final contactData in data['response']) {
            final contact = Contact(contactData['LG_VEH_NO'],
                contactData['LG_ORGIN'], contactData['LG_DESTINATION']);
            _contacts.add(contact);
          }
        });
      } else {
        client.close();
        throw Exception('Failed to load Employee Details');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      print(e);
      client.close();
      return Future.value(['null']);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLRData();
    _filteredContacts = _contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            color: Colors.red,
            //   iconSize: 32.0,
            // splashColor: Colors.red,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (conetxt) => LoginPage()));
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _filteredContacts = _contacts
                      .where((contact) =>
                          contact.VehicleNo.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.Origin.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.Destination.toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
              //textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        contact.VehicleNo,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Image.asset("asset/images/Driver.png"),
                      subtitle: Text("Origin : " +
                          contact.Origin +
                          "\n"
                              "Destination : " +
                          contact.Destination),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowMap(
                                    origin: contact.Origin,
                                    destination: contact.Destination,
                                    vehicleNo: contact.VehicleNo,
                                  )),
                        );
                      },
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
