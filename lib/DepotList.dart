import 'dart:convert';
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/PersonDetail.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
//import 'Login.dart';
import 'SO_LR_Data.dart';

class Search {
  final String DepoCode;
  final String DepoName;
  final String DepoID;

  Search(
    this.DepoCode,
    this.DepoName,
    this.DepoID,
  );
}

class DepotList extends StatefulWidget {
  final String MobileNo;
  const DepotList({Key? key, required this.MobileNo});

  @override
  State<DepotList> createState() => _DepotListState();
}

class _DepotListState extends State<DepotList> {
  List Loaddata = [];

  final TextEditingController _searchController = TextEditingController();
  List<Search> _contacts = [];
  List<Search> _filteredContacts = [];

  void _fetchDepoList() async {
    String _MobileNo = widget.MobileNo;
    try {
      var API_URL = '$API/GRADepo/$_MobileNo';
      final String _accessToken = accessToken;

      final response = await http
          .get(Uri.parse(API_URL), headers: {"Auth_Key": _accessToken});

      if (response.statusCode == 200) {
        final data = await json.decode(response.body);
        setState(
          () {
            for (final contactData in data['response']) {
              Loaddata = data['response'];
              final contact = Search(contactData['GD_CODE'],
                  contactData['GD_NAME'], contactData['GD_ID']);
              _contacts.add(contact);
            }
          },
        );
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
    _fetchDepoList();
    _filteredContacts = _contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

/*  bool isVisible = true;

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        //centerTitle: true,
        title: Text(
          'Depot List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 24,
          ),
        ),
        actions: [
          /*IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print("1");
              //isVisible = true;
              setState(() {
                toggleVisibility();
              });

//              showSearch(
              //              context: context,
              //            delegate: CustomSearchDelegate(),
              //        );
            },
          ),*/
          /* Visibility(
            visible: isVisible,
            child: Container(
              padding: const EdgeInsets.all(18.0),
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(50), // Sets circular border
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _filteredContacts = _contacts
                        .where((contact) =>
                            contact.DepoCode.toLowerCase()
                                .contains(value.toLowerCase()) ||
                            contact.DepoName.toLowerCase()
                                .contains(value.toLowerCase()) ||
                            contact.DepoID.toLowerCase()
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
          ),*/
          IconButton(
            icon: Image.asset('asset/images/Person.png'),
            color: Colors.red,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (conetxt) =>
                          PersonDetail(MobileNo: widget.MobileNo)));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18.0),
//            width: 400,
            //          height: 50,
//            decoration: BoxDecoration(
            //            //color: Colors.blue,
            //          border: Border.all(
            //          color: Colors.black,
            //        width: 1,
            //    ),
//              borderRadius: BorderRadius.circular(50), // Sets circular border
            //          ),
            child: TextField(
              controller: _searchController,

              onChanged: (value) {
                setState(() {
                  _filteredContacts = _contacts
                      .where((contact) =>
                          contact.DepoCode.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.DepoName.toLowerCase()
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
          Expanded(
            child: ListView.builder(
              //itemCount: Loaddata.length,
              itemCount: _filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                //print("Index : " + index.toString());
                final contact = _filteredContacts[index];
                return Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          //Loaddata[index]['GD_NAME'],
                          contact.DepoName,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
//                          "Code: " + Loaddata[index]['GD_CODE'],
                          "Code: " + contact.DepoCode,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SaleOfficerLRData(
                                  //ID: Loaddata[index]['GD_ID'])),
                                  ID: contact.DepoID)),
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
