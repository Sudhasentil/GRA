import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_in_flutter/ShowMap.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_number/mobile_number.dart';

import 'Constants.dart';

class AdminLRData1 extends StatefulWidget {
  const AdminLRData1({Key? key}) : super(key: key);

  @override
  State<AdminLRData1> createState() => _AdminLRData1State();
}

class _AdminLRData1State extends State<AdminLRData1> {
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  List LoadLRdata = [];
  var client = http.Client(); //EmpPersonal
  List<String> ddlVehicleNo = [];
  String _dropdownValues = "";
  String _origin = "", _destination = "";
  List<String> dropdownItemlist = [];

  Future<List<dynamic>> _fetchLRData() async {
    try {
      const API_URL = '$API/LRGPS/VehicleNo';
      final String _accessToken = accessToken;

      final response = await client.get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        "VehicleNo": _dropdownValues,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          LoadLRdata = data['response'];
          print(LoadLRdata.length);
          int len = LoadLRdata.length;
          for (int item = 0; item < len; item++) {
            ddlVehicleNo.add(LoadLRdata[item]['LG_VEH_NO']);
          }
          //print(ddlVehicleNo);
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

  Future<void> initMobileNumberState() async {
    String mobileNumber = '';
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = (await MobileNumber.mobileNumber)!;
      _simCard = (await MobileNumber.getSimCards)!;
      print(_simCard);
      //print(mobileNumber);
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
  }

  @override
  void initState() {
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });
    initMobileNumberState();
    ddlVehicleNo.add("Select");
    _dropdownValues = "Select";
    super.initState();
    _fetchLRData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("LR Details"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Text(
                  "Select Vehicle No",
                ),
              ),
              Container(
                child: DropdownButton(
                  //    alignment: Alignment.center,
                  //autofocus: true,
                  //isExpanded: true,
                  value: _dropdownValues,
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (value) {
                    setState(
                      () {
                        _dropdownValues = value.toString();
                      },
                    );
                  },

                  items: ddlVehicleNo.map((var items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          //  Container(
//            child: Text("hi"),
//          ),
          //        Container(child: Text("91+919500293181".replaceFirst('91+91', ''))),
          //Container(child: Text(_mobileNumber)),
          Container(
            child: Expanded(
              child: ListView.builder(
                itemCount: LoadLRdata.length,
                itemBuilder: (context, index) {
                  if (LoadLRdata[index]["LG_VEH_NO"] == _dropdownValues) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text('LR No'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_LR_NO"]}',
                            style: TextStyle(color: Colors.blue),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Text('Name'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_DRI_NAME"]}',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Text('Mobile No'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_DRI_MOBNO"]}',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        /*

                        ListTile(
                          leading: Text('Vehicle No'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_VEH_NO"]}',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),*/
                        ListTile(
                          leading: Text('Origin'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_ORGIN"]}',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Text('Destination'),
                          trailing: Text(
                            '${LoadLRdata[index]["LG_DESTINATION"]}',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(
//                                width: 50,
                              //                            ),
                              /*ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowMap(
                                              origin:
                                                  '${LoadLRdata[index]["LG_ORGIN"]}',
                                              destination:
                                                  '${LoadLRdata[index]["LG_DESTINATION"]}',
                                            )),
                                  );
                                },
                                child: Text("Show map"),
                              ),*/
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    //Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowMap(
                                              origin:
                                                  '${LoadLRdata[index]["LG_ORGIN"]}',
                                              destination:
                                                  '${LoadLRdata[index]["LG_DESTINATION"]}',
                                              vehicleNo:
                                                  '${LoadLRdata[index]["LG_VEH_NO"]}',
                                            )),
                                  );
                                },
                                child: Text("Show Map"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  //              }
                  else {
                    //return const CircularProgressIndicator();
                    return Text('');
                  }
                },
              ),
            ),
          ),

          /* Container(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchLRData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //var data = snapshot.data!;
                  return DropdownButton(
                    items: dropdownValues.map((var items) {
                      return DropdownMenuItem(
                          value: items, child: Text(items));
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValues[0] = newValue!;
                      });
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
