import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'Login.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({Key? key}) : super(key: key);

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  List<SimCard> _simCard = <SimCard>[];

  String _MobileNo = "";
  String _PIN = "";
  String _RollCode = "";

  final PINController = TextEditingController();
  final RollCodeController = TextEditingController();

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
    // Platform messages may fail, so we use a try/catch PlatformException.
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

  Future<void> _PostData() async {
    try {
      //const API_URL = 'http://122.165.198.198/HCM_API/API/MobilePin';
      const API_URL = 'http://122.165.210.5:2021/NTPL_API/API/MobilePin';
      final String _accessToken = 'PNHmjvVzGJzPEUdeW7lWqw==';
      final response = await http.post(
        Uri.parse(API_URL),
        headers: {
          "Auth_Key": _accessToken,
        },
        body: {
          "AP_MOBILE_NO": _MobileNo.substring(_MobileNo.length - 10),
          "AP_PIN_NO": _PIN,
          "AP_ROLE_CODE": _RollCode,
        },
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        return json.decode(response.body)['response'];
      } else {
        throw Exception('Failed to load Employee Details');
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("New User Registration"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "   Mobile No",
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: _MobileNo,
                      //hintText: 'Enter Mobile No'
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "   Enter PIN No",
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: PINController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        //labelText: 'Enter Mobile No',
                        hintText: 'Enter PIN No'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "   Enter Roll Code",
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: RollCodeController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        //labelText: 'Enter Mobile No',
                        hintText: 'Enter Role Code'),
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
                _PIN = PINController.text;
                _RollCode = RollCodeController.text;
                _PostData();
                Navigator.push(context,
                    MaterialPageRoute(builder: (conetxt) => LoginPage()));
              },
              child: Text("Register"),
            ),
          ),
        ],
      ),
    );
  }
}
