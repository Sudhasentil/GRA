import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_in_flutter/GRA.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Constants.dart';
//import 'SO_LR_Data.dart';

class Search {
  final String IndentNo;
  final String IndentDate;

  Search(
    this.IndentNo,
    this.IndentDate,
  );
}

class UnloadDetails extends StatefulWidget {
  final String SysID;
  final String LRNo;
  final String LRDate;
  final String VehicleNo;
  const UnloadDetails({
    Key? key,
    required this.SysID,
    required this.LRNo,
    required this.LRDate,
    required this.VehicleNo,
  });

  @override
  State<UnloadDetails> createState() => _UnloadDetailsState();
}

class _UnloadDetailsState extends State<UnloadDetails> {
  String _SysID = "";
  String _LRNo = "";
  String _LRDate = "";
  String _VehicleNo = "";

  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    http.Client().close();
  }

  @override
  void initState() {
    super.initState();
    _SysID = widget.SysID;
    print("LRSysid : " + _SysID);
    _LRNo = widget.LRNo;
    _LRDate = widget.LRDate;
    _VehicleNo = widget.VehicleNo;
  }

  //final List<Widget> _tabs = [
  List<Widget> generateTabs() {
    final tabs = [
      FirstTab(
          SysID: _SysID, LRNo: _LRNo, LRDate: _LRDate, VehicleNo: _VehicleNo),
      SecondTab(
          SysID: _SysID, LRNo: _LRNo, LRDate: _LRDate, VehicleNo: _VehicleNo),
    ];
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("asset/images/Unload.png"),
            ),
            label: 'Unload',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("asset/images/Indent.png"),
            ),
            label: 'Indent',
          ),
        ],
      ),
      body: Center(
        //child: _buildCurrentTab(),
        child: generateTabs()[_currentIndex],
      ),
    );
  }
}

class FirstTab extends StatefulWidget {
  final String SysID;
  final String LRNo;
  final String LRDate;
  final String VehicleNo;
  FirstTab({
    Key? key,
    required this.SysID,
    required this.LRNo,
    required this.LRDate,
    required this.VehicleNo,
  });

  @override
  State<FirstTab> createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  List LoadFrieghtdata = [];
  bool isDataSaved = false;

  TextEditingController _ReachedDateController = TextEditingController();
  DateTime _ReachedDate = DateTime.now();

  TextEditingController _UnloadedDateController = TextEditingController();
  DateTime _UnloadedDate = DateTime.now();

  TextEditingController _txtHaltDays = TextEditingController();

  Future<void> ReachedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _ReachedDate) {
      setState(() {
        _ReachedDate = picked;
        _ReachedDateController.text =
            DateFormat('dd/MM/yyyy').format(_ReachedDate);
      });
    }
  }

  Future<void> UnloadedDate(BuildContext context) async {
    final DateTime? picked1 = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked1 != null && picked1 != _UnloadedDate) {
      setState(() {
        _UnloadedDate = picked1;
        _UnloadedDateController.text =
            DateFormat('dd/MM/yyyy').format(_UnloadedDate);
      });
    }
  }

  Future<void> PostFrieghtData() async {
    const API_URL = '$API/GRAFreight';
    final String _accessToken = accessToken;

    final response = await http.post(Uri.parse(API_URL), headers: {
      'Auth_Key': _accessToken
    }, body: {
      "GF_REAHED_DT": _ReachedDateController.text,
      "GF_UNLOADED_DT": _UnloadedDateController.text,
      "GF_HALT_DAYS": _txtHaltDays.text,
      "GF_LR_SYS_ID": widget.SysID,
    });

    final data = json.decode(response.body);
    isDataSaved = true;
    print(data);
  }

  Future<void> UpdateFrieghtData() async {
    String _SysID = widget.SysID;
    var API_URL = '$API/GRAFreight/$_SysID';
    final String _accessToken = accessToken;

    //print("Update");
    //print(API_URL);
    final response = await http.Client().put(Uri.parse(API_URL), headers: {
      'Auth_Key': _accessToken
    }, body: {
      "GF_REAHED_DT": _ReachedDateController.text,
      "GF_UNLOADED_DT": _UnloadedDateController.text,
      "GF_HALT_DAYS": _txtHaltDays.text,
      "GF_LR_SYS_ID": _SysID,
    });
    //print(_txtHaltDays.text);
    //print(response.statusCode);
    //final data = json.decode(response.body);
    //print(data);
  }

  void _fetchFrieghtData() async {
    String FetchSysID = widget.SysID;
    try {
      var API_URL = '$API/GRAFreight/$FetchSysID';
      final String _accessToken = accessToken;

      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          LoadFrieghtdata = data['response'];
          if (LoadFrieghtdata.isNotEmpty) {
            //print(FetchSysID);
            //print(LoadFrieghtdata[0]['GF_LR_SYS_ID']);
            if (FetchSysID == LoadFrieghtdata[0]['GF_LR_SYS_ID']) {
              isDataSaved = true;

              _ReachedDateController.text = LoadFrieghtdata[0]['GF_REAHED_DT'];
              DateTime dateTimeValue = DateFormat('M/d/yyyy hh:mm:ss a')
                  .parse(_ReachedDateController.text);
              DateFormat dateFormat = DateFormat('dd/MM/yyyy');
              _ReachedDateController.text = dateFormat.format(dateTimeValue);

              _UnloadedDateController.text =
                  LoadFrieghtdata[0]['GF_UNLOADED_DT'];
              DateTime dateTimeValue1 = DateFormat('M/d/yyyy hh:mm:ss a')
                  .parse(_UnloadedDateController.text);
              DateFormat dateFormat1 = DateFormat('dd/MM/yyyy');
              _UnloadedDateController.text = dateFormat1.format(dateTimeValue1);
              _txtHaltDays.text = LoadFrieghtdata[0]['GF_HALT_DAYS'];
            } else {
              isDataSaved = false;
            }
          }
        });
      }

      return json.decode(response.body)['response'];
    } catch (e) {
      http.Client().close();
    }
  }

  final _formKey = GlobalKey<FormState>();
  String _ReachedDt = '';
  String _UnloadDt = '';
  String _HaltDays = '';

  @override
  void dispose() {
    super.dispose();
    http.Client().close();
  }

  @override
  void initState() {
    super.initState();
    //print("Start");
    _fetchFrieghtData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        //centerTitle: true,
        title: Text(
          'Unload Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              /*   Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                alignment: Alignment.topLeft,
                child: Text(
                  'Unload Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),*/
              SizedBox(
                height: 0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                alignment: Alignment.topLeft,
                child: Text(
                  widget.VehicleNo,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "LR No : " + widget.LRNo,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    //SizedBox(width: 50),
                    Text(
                      DateFormat('M/d/yyy').format(
                        DateFormat('dd/MM/yyyy hh:mm:ss a')
                            .parse(widget.LRDate),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _ReachedDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                        labelText: 'Reached Date',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            ReachedDate(context);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Reached Date';
                        }
                        return null; // Return null if the input is valid
                      },
                      onSaved: (value) {
                        _ReachedDt = value!;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _UnloadedDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                        labelText: 'Unloaded Date',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            UnloadedDate(context);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Unloaded Date';
                        }
                        return null; // Return null if the input is valid
                      },
                      onSaved: (value) {
                        _UnloadDt = value!;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _txtHaltDays,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(RegExp(r'[-.,]')),
                      ],
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                        labelText: 'Halt Days',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Halt Days';
                        }
                        return null; // Return null if the input is valid
                      },
                      onSaved: (value) {
                        _HaltDays = value!;
                      },
                    ),
                    //SizedBox(height: MediaQuery.of(context).size.height),
                    SizedBox(height: 300),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                      //color: Colors.blueGrey.shade800,
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  //Colors.blueGrey.shade800),
                                  Colors.blue),
                              // Set the desired color
                            ),
                            child: Text('Submit'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, save the input and perform any other actions
                                _formKey.currentState!.save();
                                if (isDataSaved == true) {
                                  UpdateFrieghtData();
                                } else {
                                  PostFrieghtData();
                                }

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Success'),
                                      content: Text(isDataSaved
                                          ? 'Record Updated Successfully.'
                                          : 'Record Saved Successfully.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {}
                            },
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  //Colors.blueGrey.shade800), // Set the desired color
                                  Colors.blue),
                            ),
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondTab extends StatefulWidget {
  final String SysID;
  final String LRNo;
  final String LRDate;
  final String VehicleNo;
  const SecondTab({
    Key? key,
    required this.SysID,
    required this.LRNo,
    required this.LRDate,
    required this.VehicleNo,
  });

  @override
  State<SecondTab> createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  List LoadIndentdata = [];

  String _SysID = "";
  String _LRNo = "";
  String _LRDate = "";
  String _VehicleNo = "";

  final TextEditingController _searchController = TextEditingController();
  List<Search> _contacts = [];
  List<Search> _filteredContacts = [];

  void _fetchIndentData() async {
    print(_SysID);
    try {
      var API_URL1 = '$API/IndentDtl/$_SysID';
      final String _accessToken1 = accessToken;

      print(API_URL1);
      final response1 = await http.Client().get(Uri.parse(API_URL1), headers: {
        "Auth_Key": _accessToken1,
      });
      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        setState(() {
          for (final contactData in data1['response']) {
            LoadIndentdata = data1['response'];
            final contact =
                Search(contactData['LD_INDENT_NO'], contactData['LH_DOC_DT']);
            _contacts.add(contact);
          }
        });
      } else {
        http.Client().close();
        throw Exception('Failed to load Sale Order LR Details');
      }
      return json.decode(response1.body)['response'];
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
    _SysID = widget.SysID;
    _LRNo = widget.LRNo;
    _LRDate = widget.LRDate;
    _VehicleNo = widget.VehicleNo;
    //print("Start");
    _fetchIndentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        //centerTitle: true,
        title: Text(
          'Indent Details',
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
                          contact.IndentNo.toLowerCase()
                              .contains(value.toLowerCase()) ||
                          contact.IndentDate.toLowerCase()
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
              _VehicleNo,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LR No : " + widget.LRNo,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                //SizedBox(width: 50),
                Text(
                  DateFormat('M/d/yyy').format(
                    DateFormat('dd/MM/yyyy hh:mm:ss a').parse(widget.LRDate),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Expanded(
              child: ListView.builder(
                //itemCount: LoadIndentdata.length,
                itemCount: _filteredContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  final contact = _filteredContacts[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Indent No : " + contact.IndentNo,
                            //LoadIndentdata[index]['LD_INDENT_NO'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Indent Date: " +
                                DateFormat('M/d/yyy').format(
                                    DateFormat('dd/MM/yyyy hh:mm:ss a')
                                        .parse(contact.IndentDate)),
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GRA(
                                      IndentNo: contact.IndentNo,
                                      LRNo: widget.LRNo,
                                      LRDate: widget.LRDate,
                                      VehicleNo: widget.VehicleNo,
                                      SysID: widget.SysID,
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
          ),
        ],
      ),
    );
  }
}
