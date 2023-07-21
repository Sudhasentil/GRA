import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/Constants.dart';
import 'package:intl/intl.dart';
import 'Recoveries.dart';
import 'package:http/http.dart' as http;
import 'SO_LR_Data.dart';

class ItemDetails extends StatefulWidget {
  final String LRSysID;
  const ItemDetails({Key? key, required this.LRSysID});

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
//    print("Frieght");
//    print(widget.LRSysID);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        title: Text("Item Details"),
        //      centerTitle: true,
        toolbarHeight: 10,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Frieght'),
            Tab(text: 'Recovery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for Tab 1
          Tab1Content(widget.LRSysID),
          // Content for Tab 2
          Tab2Content(widget.LRSysID),
        ],
      ),
    );
  }
}

class Tab1Content extends StatefulWidget {
  final String SysID;
  Tab1Content(this.SysID);

  @override
  _Tab1ContentState createState() => _Tab1ContentState();
}

class _Tab1ContentState extends State<Tab1Content>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  TextEditingController _ReachedDateController = TextEditingController();
  DateTime _ReachedDate = DateTime.now();

  TextEditingController _UnloadedDateController = TextEditingController();
  DateTime _UnloadedDate = DateTime.now();

  TextEditingController _txtHaltDays = TextEditingController();
  TextEditingController _txtHaltRate = TextEditingController();
  TextEditingController _txtHaltCharges = TextEditingController();
  TextEditingController _txtTotalCase = TextEditingController();
  TextEditingController _txtPremiumQty = TextEditingController();
  TextEditingController _txtPremiumRate = TextEditingController();
  TextEditingController _txtOrdinaryQty = TextEditingController();
  TextEditingController _txtOrdinaryRate = TextEditingController();
  TextEditingController _txtBeerQty = TextEditingController();
  TextEditingController _txtBeerRate = TextEditingController();
  TextEditingController _txtHamaliCharge = TextEditingController();
  TextEditingController _txtFrieghtCharge = TextEditingController();
  TextEditingController _txtTransferFrieght = TextEditingController();
  TextEditingController _txttotalFrieght = TextEditingController();
  TextEditingController _txtOtherDeductions = TextEditingController();

  List LoadFrieghtdata = [];
  bool isDataSaved = false;

  void _fetchFrieghtData() async {
    String FetchSysID = widget.SysID;
    //  print("Fetch");
//    print(FetchSysID);
    try {
      var API_URL = '$API/GRAFreight/$FetchSysID';
      //const API_URL = '$NTPL_API/LRGPS/VehicleNo';
      final String _accessToken = accessToken;

      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      });

      //    print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          LoadFrieghtdata = data['response'];
          //print(LoadFrieghtdata[0]['GF_LR_SYS_ID']);
          if (LoadFrieghtdata.isNotEmpty) {
            //        print("1");
            if (FetchSysID == LoadFrieghtdata[0]['GF_LR_SYS_ID']) {
              isDataSaved = true;
            } else {
              isDataSaved = false;
            }

            _ReachedDateController.text = LoadFrieghtdata[0]['GF_REAHED_DT'];
            DateTime dateTimeValue = DateFormat('M/d/yyyy hh:mm:ss a')
                .parse(_ReachedDateController.text);
            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
            _ReachedDateController.text = dateFormat.format(dateTimeValue);

            _UnloadedDateController.text = LoadFrieghtdata[0]['GF_UNLOADED_DT'];
            DateTime dateTimeValue1 = DateFormat('M/d/yyyy hh:mm:ss a')
                .parse(_UnloadedDateController.text);
            DateFormat dateFormat1 = DateFormat('dd/MM/yyyy');
            _UnloadedDateController.text = dateFormat1.format(dateTimeValue1);

            //_UnloadedDate = DateTime.parse(LoadFrieghtdata[0]['GF_UNLOADED_DT']);
            //_UnloadedDateController.text =
            //  DateFormat('dd/MM/yyyy').format(_UnloadedDate);

            _txtHaltDays.text = LoadFrieghtdata[0]['GF_HALT_DAYS'];
            _txtHaltRate.text = LoadFrieghtdata[0]['GF_HALT_RATE'];
            _txtHaltCharges.text = LoadFrieghtdata[0]['GF_HALT_CHARGE'];
            _txtTotalCase.text = LoadFrieghtdata[0]['GF_TOT_CASES'];
            _txtPremiumQty.text = LoadFrieghtdata[0]['GF_PREMIUM_QTY'];
            _txtPremiumRate.text = LoadFrieghtdata[0]['GF_PREMIUM_RATE'];
            _txtOrdinaryQty.text = LoadFrieghtdata[0]['GF_ORDINARY_QTY'];
            _txtOrdinaryRate.text = LoadFrieghtdata[0]['GF_ORDINARY_RATE'];
            _txtBeerQty.text = LoadFrieghtdata[0]['GF_BEER_QTY'];
            _txtBeerRate.text = LoadFrieghtdata[0]['GF_BEER_RATE'];
            _txtHamaliCharge.text = LoadFrieghtdata[0]['GF_HAMALI_CHARGE'];
            _txtFrieghtCharge.text = LoadFrieghtdata[0]['GF_FREIGHT_CHARGE'];
            _txtTransferFrieght.text =
                LoadFrieghtdata[0]['GF_TRANSFER_FREIGHT'];
            _txttotalFrieght.text = LoadFrieghtdata[0]['GF_TOT_FREIGHT'];
            _txtOtherDeductions.text = LoadFrieghtdata[0]['GF_OTHER_DED'];
          }
        });
      } else {
        http.Client().close();
        throw Exception('Failed to load Frieght Details');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
//      print(e);
      http.Client().close();
      return Future.value(['null']);
    }
  }

  Future<void> PostFrieghtData() async {
    const API_URL = '$API/GRAFreight';
    final String _accessToken = accessToken;

    //print(API_URL);
    final response = await http.post(Uri.parse(API_URL), headers: {
      'Auth_Key': _accessToken
    }, body: {
      "GF_REAHED_DT": _ReachedDateController.text,
      "GF_UNLOADED_DT": _UnloadedDateController.text,
      "GF_HALT_DAYS": _txtHaltDays.text,
      "GF_HALT_RATE": _txtHaltRate.text,
      "GF_HALT_CHARGE": _txtHaltCharges.text,
      "GF_TOT_CASES": _txtTotalCase.text,
      "GF_PREMIUM_QTY": _txtPremiumQty.text,
      "GF_PREMIUM_RATE": _txtPremiumRate.text,
      "GF_ORDINARY_QTY": _txtOrdinaryQty.text,
      "GF_ORDINARY_RATE": _txtOrdinaryRate.text,
      "GF_BEER_QTY": _txtBeerQty.text,
      "GF_BEER_RATE": _txtBeerRate.text,
      "GF_HAMALI_CHARGE": _txtHamaliCharge.text,
      "GF_FREIGHT_CHARGE": _txtFrieghtCharge.text,
      "GF_TRANSFER_FREIGHT": _txtTransferFrieght.text,
      "GF_TOT_FREIGHT": _txttotalFrieght.text,
      "GF_OTHER_DED": _txtOtherDeductions.text,
      "GF_LR_SYS_ID": widget.SysID,
      //"GF_SYS_ID": "1",
    });

    final data = json.decode(response.body);
    //print(data);
  }

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
    //print(widget.SysID);
    _fetchFrieghtData();
  }

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

  final _formKey = GlobalKey<FormState>();
  String _numericValue = "";
  String _numericValue1 = "";
  String _numericValue2 = "";
  String _numericValue3 = "";
  String _numericValue4 = "";
  String _numericValue5 = "";
  String _numericValue6 = "";
  String _numericValue7 = "";
  String _numericValue8 = "";
  String _numericValue9 = "";
  String _numericValue10 = "";
  String _numericValue11 = "";
  String _numericValue12 = "";
  String _numericValue13 = "";
  String _numericValue14 = "";

  @override
  void dispose() {
    _subTabController.dispose();
    _ReachedDateController.dispose();
    _UnloadedDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _subTabController,
            indicatorColor: Colors
                .white, // Set the indicator color to match the active tab color
            labelColor: Colors.blue, // Set the label color of the active tab
            unselectedLabelColor:
                Colors.black, // Set the label color of inactive tabs
            tabs: [
              Tab(
                child: Text(
                  'Halt Details',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Case Details',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Other Charges',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _subTabController,
              children: [
                // Content for Sub Tab 1
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _ReachedDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Reached Date',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                ReachedDate(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _UnloadedDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Unloaded Date',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                UnloadedDate(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtHaltDays,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            //border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Halt Days',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtHaltRate,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            //border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Halt Rate',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtHaltCharges,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            //border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Halt Charges',
                          ),
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),

                // Content for Sub Tab 2

                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _txtTotalCase,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Total Cases',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtPremiumQty,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Premium Qty',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtPremiumRate,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Premium Rate',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtOrdinaryQty,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Ordinary Qty',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtOrdinaryRate,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Ordinary Rate',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtBeerQty,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Beer Qty',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _txtBeerRate,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Beer Rate',
                          ),
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),

                // Content for Sub Tab 3

                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _txtHamaliCharge,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Hamali Charge',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtFrieghtCharge,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Frieght Charge',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtTransferFrieght,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Transfer Frieght',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txttotalFrieght,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Total Frieght',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _txtOtherDeductions,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            labelText: 'Other Deductions',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          //child: Text('Save'),
                          child: Text(isDataSaved ? 'Update' : 'Save'),
                          onPressed: () {
                            PostFrieghtData();
                            isDataSaved = true;
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
                                        // Close the pop-up window
                                        //Navigator.of(context).pop();
//                                        Navigator.push(
                                        //                                          context,
                                        //                                        MaterialPageRoute(
                                        //                                          builder: (conetxt) =>
                                        //                                            SaleOfficerLRData()));
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Tab2

class Tab2Content extends StatefulWidget {
  final String SysID;
  Tab2Content(this.SysID);
  @override
  _Tab2ContentState createState() => _Tab2ContentState();
}

class _Tab2ContentState extends State<Tab2Content>
    with SingleTickerProviderStateMixin {
  List LoadRecoverydata = [];
  String _SubSysID = "";

  Future<List<dynamic>> _fetchRecoveryData() async {
    String LRSysid = widget.SysID;
    //print(LRSysid);
    try {
      String API_URL = '$API/GRARecovery/List/$LRSysid';
      //String API_URL = '$NTPL_API/LRGPS/Mobile';
      final String _accessToken = accessToken;

      final response = await http.Client().get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        //"HEADER_ID": LRSysid,
      });

      print(response.statusCode);
      //print(API_URL);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          LoadRecoverydata = data['response'];
        });
      } else {
        http.Client().close();
        throw Exception('Failed to load recovery details');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      print(e);
      http.Client().close();
      return Future.value(['null']);
    }
  }

  @override
  void initState() {
    super.initState();
    print("Recovery");
    _fetchRecoveryData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: LoadRecoverydata.length,
                  itemBuilder: (context, index) {
                    _SubSysID = LoadRecoverydata[index]["GR_SYS_ID"];
                    //print(_SubSysID);
                    return Column(
                      children: <Widget>[
                        ListTile(
                          //contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                          leading: Container(
                            height: 130,
                            child: Text(
                              "GRA No : " +
                                  '${LoadRecoverydata[index]["GR_GRA_NO"]}' +
                                  "\n"
                                      "Indent No : " +
                                  '${LoadRecoverydata[index]["GR_INTEND_NO"]}'
                                      "\n"
                                      "Item Name : " +
                                  '${LoadRecoverydata[index]["ITEM_NAME"]}' +
                                  "\n",
                            ),
                          ),
                          onTap: () {
                            _SubSysID = LoadRecoverydata[index]["GR_SYS_ID"];
                            //print("Click Listview");
                            //print(_SubSysID);
                            //                Navigator.pushReplacement(
                            //                  context,
                            //                MaterialPageRoute(
                            //                  builder: (conetxt) => Recoveries(
                            //                    LRSysID: widget.SysID,
                            //                  SubSysID: _SubSysID)));
                          },
                        ),
                        //SizedBox(height: 20),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _SubSysID = "";
          // Add your action here
          ///          Navigator.pushReplacement(
          //           context,
          //         MaterialPageRoute(
          //           builder: (conetxt) =>
          //             Recoveries(LRSysID: widget.SysID, SubSysID: _SubSysID)));
          _fetchRecoveryData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
