import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'Login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  List<SimCard> _simCard = <SimCard>[];
  bool _visibility = false;
  bool _visibility1 = false;

  String _MobileNo = "";
  String _PIN1 = "";
  String _PIN2 = "";

  final PINController = TextEditingController();
  final ConfirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });

    initMobileNumberState();
  }

  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = '';

    try {
      mobileNumber = (await MobileNumber.mobileNumber)!;
      _simCard = (await MobileNumber.getSimCards)!;
      print(_simCard);
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    if (!mounted) return;

    setState(() {
      _MobileNo = mobileNumber.substring(mobileNumber.length - 10);
    });
  }

  Future<void> _UpdateData() async {
    try {
      var API_URL = "$API/MobilePin/$_MobileNo";
      //var API_URL ="$NTPL_API/MobilePin/$_MobileNo";
      print(API_URL);

      final String _accessToken = accessToken;

      final response = await http.put(
        Uri.parse(API_URL),
        headers: {
          "Auth_Key": _accessToken,
          "Connection": "Keep-Alive",
          "Keep-Alive": "timeout=5, max=1000",
          "Accept": "application/json",
        },
        body: {
          "AP_MOBILE_NO": _MobileNo.substring(_MobileNo.length - 10),
          "AP_PIN_NO": _PIN1,
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return json.decode(response.body)['response'];
      } else {
        throw Exception('Cant Update');
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Forgot Password"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: PINController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Enter PIN No',
                      //hintText: 'Enter PIN No',
                    ),
                    obscureText: true,
                    maxLength: 4,
                    //maxLengthEnforcement: MaxLengthEnforcement.none,
                    onChanged: (value) {
                      setState(() {
                        if (int.tryParse(value) != null) {
                          if (value.length == 4) {
                            _visibility1 = false;
                            _visibility = false;
                          } else {
                            _visibility1 = true;
                          }
                        } else {
                          _visibility = true;
                        }
                      });
                    },
                    /* validator: (value) {
                      if (value.length < 5) {
                        return "Input must be at least 5 characters long";
                      }
                      return null;
                    },*/
                  ),
                ),
              ],
            ),
          ),
          //SizedBox(
//            height: 10,
          //        ),
          Container(
            child: Row(
              children: [
                Expanded(
                    child: Visibility(
                  visible: _visibility,
                  child: Text(
                    "Enter Numeric value only",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
                Expanded(
                    child: Visibility(
                  visible: _visibility1,
                  child: Text(
                    "",
                    //"Enter Minimum 4 numbers",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ],
            ),
          ),
//          SizedBox(
          //          height: 10,
          //      ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ConfirmPinController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Enter Confirm PIN',
                      //hintText: 'Enter Confirm PIN',
                    ),
                    maxLength: 4,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                _PIN1 = PINController.text;
                _PIN2 = ConfirmPinController.text;

                if (_visibility == false && _visibility1 == false) {
                  if (_PIN1 == _PIN2) {
                    _UpdateData();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (conetxt) => LoginPage()));
                  } else {
                    showAlertDialog(context);
                  }
                }
              },
              child: Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }
}

//// PIN Mismatch

showAlertDialog(BuildContext context) {
  // Create button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(""),
    content: Text("Pin Not Match"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
