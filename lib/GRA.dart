import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Constants.dart';
import 'Recoveries.dart';

class Search {
  final String GRANo;
  final String ItemName;
  final String GRSysID;

  Search(
    this.GRANo,
    this.ItemName,
    this.GRSysID,
  );
}

class GRA extends StatefulWidget {
  final String IndentNo;
  final String LRNo;
  final String LRDate;
  final String VehicleNo;
  final String SysID;

  const GRA(
      {Key? key,
      required this.IndentNo,
      required this.LRNo,
      required this.LRDate,
      required this.VehicleNo,
      required this.SysID});

  @override
  State<GRA> createState() => _GRAState();
}

class _GRAState extends State<GRA> {
  List Loaddata = [];
  List LoadRecoverydata = [];

  final TextEditingController _searchController = TextEditingController();
  List<Search> _contacts = [];
  List<Search> _filteredContacts = [];

  String GR_sysID = "";

  void _fetchRecoveryListData() async {
    String _ID = widget.SysID;
    try {
      var API_URL = '$API/GRARecovery/List/$_ID';
      final String _accessToken = accessToken;

      print(API_URL);
      print("Indent:" + widget.IndentNo);
      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Indent_No": widget.IndentNo,
      });

      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          for (final contactData in data['response']) {
            Loaddata = data['response'];
            final contact = Search(contactData['GR_GRA_NO'],
                contactData['ITEM_NAME'], contactData['GR_SYS_ID']);
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
  void dispose() {
    super.dispose();
    http.Client().close();
    _searchController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filteredContacts = _contacts;
    _fetchRecoveryListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        //centerTitle: true,
        title: Text(
          'GRA Details',
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
                          contact.GRANo.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.ItemName.toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
              //textAlign: TextAlign.end,
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
            alignment: Alignment.topLeft,
            child: Text(
              "Indent No : " + widget.IndentNo,
              //textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
            alignment: Alignment.topLeft,
            child: Text(
              "Vehicle No : " + widget.VehicleNo,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  //textAlign: TextAlign.start,
                  "LR No : " + widget.LRNo,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                //SizedBox(width: 50),
                Text(
                  //   "LR Date : " +
                  DateFormat('M/d/yyy').format(
                    DateFormat('dd/MM/yyyy hh:mm:ss a').parse(widget.LRDate),
                  ),
                  //textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                //SizedBox(height: 20.0),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              //itemCount: Loaddata.length,
              itemCount: _filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts[index];
                return Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "GRA No : " + contact.GRANo,
                          //Loaddata[index]['GR_GRA_NO'],
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Item Name : " + contact.ItemName,
                          //Loaddata[index]['ITEM_NAME'],
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Recoveries(
                                    IndentNo: widget.IndentNo,
                                    LRNo: widget.LRNo,
                                    LRDate: widget.LRDate,
                                    VehicleNo: widget.VehicleNo,
                                    SysID: widget.SysID,
                                    GRSysID: contact.GRSysID,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Recoveries(
                      IndentNo: widget.IndentNo,
                      LRNo: widget.LRNo,
                      LRDate: widget.LRDate,
                      VehicleNo: widget.VehicleNo,
                      SysID: widget.SysID,
                      GRSysID: "",
                    )),
          );
//          _fetchRecoveryData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
