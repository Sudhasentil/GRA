import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Constants.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Recoveries extends StatefulWidget {
  final String IndentNo;
  final String LRNo;
  final String LRDate;
  final String VehicleNo;
  final String SysID;
  final String GRSysID;
  const Recoveries(
      {Key? key,
      required this.IndentNo,
      required this.LRNo,
      required this.LRDate,
      required this.VehicleNo,
      required this.SysID,
      required this.GRSysID});

  @override
  State<Recoveries> createState() => _RecoveriesState();
}

class _RecoveriesState extends State<Recoveries> {
  @override
  TextEditingController _txtGRAno = TextEditingController();
  TextEditingController _txtMRPrate = TextEditingController();
  TextEditingController _txtOpenQty = TextEditingController();
  TextEditingController _txtShortQty = TextEditingController();
  TextEditingController _txtDamageQty = TextEditingController();

  List LoaddataRecovery = [];

  List<String> dropdownItem = [];
  String? _selectedItem;
  TextEditingController _textEditingControllerItem = TextEditingController();

  bool isDataSaved = false;

  Future<void> PostRecoveryData() async {
    const API_URL = '$API/GRARecovery';
    final String _accessToken = accessToken;
    List<String> splitList = _textEditingControllerItem.text.split("-");
    String firstWord = splitList[0];
    final response = await http.post(Uri.parse(API_URL), headers: {
      'Auth_Key': _accessToken
    }, body: {
      "GR_GRA_NO": _txtGRAno.text,
      "GR_ITEM_ID": firstWord,
      "GR_INTEND_NO": widget.IndentNo,
      "GR_RATE": _txtMRPrate.text,
      "GR_OPEN_QTY": _txtOpenQty.text,
      "GR_SHORT_QTY": _txtShortQty.text,
      "GR_DAMAGE_QTY": _txtDamageQty.text,
      "GR_LR_SYS_ID": widget.SysID,
    });

    final data = json.decode(response.body);
    print(data);
    //showPopup();
  }

  Future<void> UpdateRecoveryData() async {
    String _GRSysID = widget.GRSysID;
    print("Update");
    var API_URL = '$API/GRARecovery/$_GRSysID';
    final String _accessToken = accessToken;

    print(API_URL);
    List<String> splitList = _textEditingControllerItem.text.split("-");
    String firstWord = splitList[0];
    final response = await http.put(Uri.parse(API_URL), headers: {
      'Auth_Key': _accessToken
    }, body: {
      "GR_GRA_NO": _txtGRAno.text,
      "GR_ITEM_ID": firstWord,
      "GR_INTEND_NO": widget.IndentNo,
      "GR_RATE": _txtMRPrate.text,
      "GR_OPEN_QTY": _txtOpenQty.text,
      "GR_SHORT_QTY": _txtShortQty.text,
      "GR_DAMAGE_QTY": _txtDamageQty.text,
      "GR_LR_SYS_ID": widget.SysID,
      "GR_SYS_ID": widget.GRSysID,
    });
    final data = json.decode(response.body);
    print(data);
    //showPopup();
  }

  void _fetchRecoveryData() async {
    String FetchSysID = widget.SysID;
    String FetchSubsysID = widget.GRSysID;

    try {
      var API_URL = '$API/GRARecovery/Find/$FetchSubsysID';
      final String _accessToken = accessToken;

      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        "Indent_No": widget.IndentNo,
      });

      print("Recovery");
      print(API_URL);
      print(response.statusCode);
      print(FetchSysID);
      print(FetchSubsysID);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          LoaddataRecovery = data['response'];

          if (FetchSysID == LoaddataRecovery[0]['GR_LR_SYS_ID'] &&
              FetchSubsysID == LoaddataRecovery[0]['GR_SYS_ID']) {
            isDataSaved = true;
          } else {
            isDataSaved = false;
          }
          _txtGRAno.text = LoaddataRecovery[0]['GR_GRA_NO'];
          fetchDropdownItems();

          _textEditingControllerItem.text = LoaddataRecovery[0]['ITEM_CODE'] +
              "-" +
              LoaddataRecovery[0]['ITEM_NAME'];

          _txtMRPrate.text = LoaddataRecovery[0]['GR_RATE'];
          _txtOpenQty.text = LoaddataRecovery[0]['GR_OPEN_QTY'];
          _txtShortQty.text = LoaddataRecovery[0]['GR_SHORT_QTY'];
          _txtDamageQty.text = LoaddataRecovery[0]['GR_DAMAGE_QTY'];
        });
      } else {
        http.Client().close();
        throw Exception('Failed to load Recovery Details');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      http.Client().close();
      return Future.value(['null']);
    }
  }

  Future<void> fetchDropdownItems() async {
    try {
      const API_URL1 = '$API/GRAItem';
      final String _accessToken1 = accessToken;

      final response1 = await http.get(Uri.parse(API_URL1), headers: {
        "Auth_Key": _accessToken1,
      });
//      print("Item");
      //    print(API_URL1);
      //  print(response1.statusCode);
      if (response1.statusCode == 200) {
        final data1 = jsonDecode(response1.body);
        List LoaddataItem = [];
        setState(() {
          LoaddataItem = data1['response'];
          dropdownItem = LoaddataItem.map<String>((item) =>
              (item['ITEM_CODE'] as String) +
              "-" +
              (item['ITEM_NAME'] as String)).toList();
        });
      } else {
        throw Exception('Failed to load Item values');
      }
    } catch (e) {}
  }

  List LoadMRPdata = [];
  void _fetchMRPRate() async {
    List<String> splitList1 = _textEditingControllerItem.text.split("-");
    String firstWord1 = splitList1[0];
    print(_textEditingControllerItem.text);

    try {
      var API_URL = '$API/GRAPrice/$firstWord1';
      final String _accessToken = accessToken;

      print(API_URL);
      final response = await http.get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
      });

      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          LoadMRPdata = data['response'];
          _txtMRPrate.text = LoadMRPdata[0]["PLI_MRP"];
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

  int v_Count = 0;

  void initState() {
    _textEditingControllerItem.addListener(_handleTextChange);
    super.initState();

    //String FetchSysID = widget.SysID;
    String FetchSubsysID = widget.GRSysID;
    print(FetchSubsysID);
    if (FetchSubsysID == "") {
      fetchDropdownItems();
    } else {
      _fetchRecoveryData();
    }
  }

  final _formKey = GlobalKey<FormState>();

  String _Item = '';
  String _GRA = '';
  String _OpenQt = '';
  String _ShortQt = '';
  String _DamageQt = '';

  @override
  void dispose() {
    _textEditingControllerItem.removeListener(_handleTextChange);
    _textEditingControllerItem.dispose();
    super.dispose();
  }

  bool isPopupShown = false;

  void showPopup() {
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
                Navigator.of(context).pop(); // Close the dialog
                isPopupShown = false;

//                Navigator.push(
                //                  context,
                //                MaterialPageRoute(
                //                  builder: (conetxt) =>
                //                    ItemDetails(LRSysID: widget.LRSysID)));

                _txtGRAno.text = "";
                _textEditingControllerItem.text = "";
                _txtMRPrate.text = "";
                _txtOpenQty.text = "";
                _txtShortQty.text = "";
                _txtDamageQty.text = "";
                isDataSaved = false;
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    )..then((_) {
        // Dialog is dismissed or closed
        isPopupShown = false;
      });
  }

  void _handleTextChange() {
    String enteredText = _textEditingControllerItem.text;
    // Handle the text change here
    _fetchMRPRate();
    print('Input value changed: $enteredText');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isPopupShown) {
          Navigator.of(context).pop(); // Dismiss the pop-up if shown
          isPopupShown = false; // Reset the flag
          return false; // Prevent navigating back
        }
        return true; // Allow navigating back
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          //centerTitle: true,
          title: Text(
            'Item Recoveries',
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
              children: [
                /*Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Item Recoveries',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),*/
//              SizedBox(
                //              height: 20,
                //          ),
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
                      fontSize: 16,
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
                        //"LR Date : " +
                        DateFormat('M/d/yyy').format(
                          DateFormat('dd/MM/yyyy hh:mm:ss a')
                              .parse(widget.LRDate),
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
                Container(
//                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                  child: TypeAheadFormField<String?>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _textEditingControllerItem,
                      decoration: InputDecoration(
                        labelText: 'Select or Enter Item',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                      ),
//                    onChanged: (value) {
                      // Handle the text change here
                      //                    print('Input value changed: $value');
                      //                  _fetchMRPRate();
                      //              },
                    ),
                    suggestionsCallback: (pattern) {
                      //            _fetchMRPRate();
                      return dropdownItem.where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion ?? ''),
                      );
                    },
                    onSuggestionSelected: (String? suggestion) {
                      setState(() {
                        _selectedItem = suggestion;
                        _textEditingControllerItem.text = suggestion ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Select or Enter Item';
                      }
                      return null; // Return null if the input is valid
                    },
                    onSaved: (value) {
                      _Item = value!;
                    },
                  ),
                ),
                SizedBox(width: 20.0),
                Container(
                  //              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                  child: TextFormField(
                    controller: _txtGRAno,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.deny(RegExp(r'[-.,]')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      labelText: 'GRA No',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter GRA No';
                      }
                      return null; // Return null if the input is valid
                    },
                    onSaved: (value) {
                      _GRA = value!;
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  enabled: false,
                  controller: _txtMRPrate,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    labelText: 'MRP Rate',
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _txtOpenQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r'[-.,]')),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    labelText: 'Open Qty',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Open qty';
                    }
                    return null; // Return null if the input is valid
                  },
                  onSaved: (value) {
                    _OpenQt = value!;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _txtShortQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r'[-.,]')),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    labelText: 'Short Qty',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Short Qty';
                    }
                    return null; // Return null if the input is valid
                  },
                  onSaved: (value) {
                    _ShortQt = value!;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _txtDamageQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r'[-.,]')),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    labelText: 'Damage Qty',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Damage Qty';
                    }
                    return null; // Return null if the input is valid
                  },
                  onSaved: (value) {
                    _DamageQt = value!;
                  },
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
                  //color: Colors.blueGrey.shade800,
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              //Colors.blueGrey.shade800), // Set the desired color
                              Colors.blue),
                        ),
                        child: Text('Submit'),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, save the input and perform any other actions
                              _formKey.currentState!.save();

                              isPopupShown = true;
                              isDataSaved
                                  ? UpdateRecoveryData()
                                  : PostRecoveryData();
                              showPopup();
                            } else {}
                          });
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              //            Colors.blueGrey.shade800), // Set the desired color
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
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
