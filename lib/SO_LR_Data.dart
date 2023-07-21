import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Constants.dart';
import 'UnloadIndentDetails.dart';

class Search {
  final String VehicleNo;
  final String LRNo;
  final String LRDate;
  final String LRSysID;

  Search(
    this.VehicleNo,
    this.LRNo,
    this.LRDate,
    this.LRSysID,
  );
}

class SaleOfficerLRData extends StatefulWidget {
  final String ID;
  const SaleOfficerLRData({Key? key, required this.ID});

  @override
  State<SaleOfficerLRData> createState() => _SaleOfficerLRDataState();
}

class _SaleOfficerLRDataState extends State<SaleOfficerLRData> {
  List Loaddata = [];
  String _Destination = "";
  String _LRSysID = "";

  final TextEditingController _searchController = TextEditingController();
  List<Search> _contacts = [];
  List<Search> _filteredContacts = [];

  void _fetchLRData() async {
    String _ID = widget.ID;
    print(_ID);
    try {
      var API_URL = '$API/LRDetail/$_ID';
      final String _accessToken = accessToken;

      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          for (final contactData in data['response']) {
            Loaddata = data['response'];
            _Destination = Loaddata[0]["SEC_DESTINATION"];
            _LRSysID = Loaddata[0]["LH_SYS_ID"];
            final contact = Search(
                contactData['LH_VEHICLE_NO'],
                contactData['LH_DOC_NO'],
                contactData['LH_DOC_DT'],
                contactData['LH_SYS_ID']);
            _contacts.add(contact);
          }
        });
      } else {
        http.Client().close();
        throw Exception('Failed to load Sale Order LR Details');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      http.Client().close();
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
        backgroundColor: Colors.lightBlue,
        //centerTitle: true,
        title: Text(
          'LR Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _filteredContacts = _contacts
                      .where((contact) =>
                          contact.VehicleNo.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.LRNo.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.LRDate.toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: Icon(Icons.search),

                border: OutlineInputBorder(), // Border around the TextField
                filled: true, // Fills the TextField background with color
                fillColor:
                    Colors.grey[200], // Background color of the TextField
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ), // Border when the TextField is enabled
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18.0),
            alignment: Alignment.topLeft,
            child: Text(
              "Depot Name : " + _Destination,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              //itemCount: Loaddata.length,
              itemCount: _filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts[index];
                print("contact : " + contact.toString());
                return Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          //Loaddata[index]["LH_VEHICLE_NO"],
                          contact.VehicleNo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          //"LR No : " + Loaddata[index]["LH_DOC_NO"],
                          "LR No : " + contact.LRNo,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: Text(
                        DateFormat('M/d/yyy').format(
                            DateFormat('dd/MM/yyyy hh:mm:ss a')
                                .parse(contact.LRDate)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UnloadDetails(
                                  SysID: contact.LRSysID,
//                                  VehicleNo: Loaddata[index]["LH_VEHICLE_NO"],
                                  VehicleNo: contact.VehicleNo,
                                  //                                LRNo: Loaddata[index]["LH_DOC_NO"],
                                  LRNo: contact.LRNo,
                                  //                              LRDate: Loaddata[index]["LH_DOC_DT"])),
                                  LRDate: contact.LRDate)),
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
