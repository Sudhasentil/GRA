import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_number/mobile_number.dart';
import 'AD_LR_Data.dart';
import 'Constants.dart';
import 'DepotList.dart';
import 'ForgotPassword.dart';
import 'LR_Data.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topRight,
          ),
        ),
        child: OtpScreen(),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List Loaddata = [];
  List<SimCard> _simCard = <SimCard>[];
  String _MobileNo = "";
  //String _MobileNo = "";
  int _Count = 0;
  String _RoleCode = "";

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
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    if (!mounted) return;

    setState(() {
      _MobileNo = mobileNumber.substring(mobileNumber.length - 10);
      //_MobileNo = '9500293181';
    });
  }

  List<String> currentpin = ["", "", "", ""];

  TextEditingController pinOneController = TextEditingController();
  TextEditingController pinTwoController = TextEditingController();
  TextEditingController pinThreeController = TextEditingController();
  TextEditingController pinFourController = TextEditingController();

  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.transparent),
  );

  int pinIndex = 0;

  Future<List<dynamic>> _fetchData() async {
    List Loaddata = [];

    try {
      var API_URL = "$API/MobilePin";
      //var API_URL = "$NTPL_API/MobilePin";
      final String _accessToken = accessToken;

      print(API_URL);
      final response = await http.Client().get(
        Uri.parse(API_URL),
        headers: {
          "Auth_Key": _accessToken,
          "Connection": "Keep-Alive",
          "Keep-Alive": "timeout=5, max=1000",
          //"Mobile_No": _MobileNo.substring(_MobileNo.length - 10),
          "Mobile_No": _MobileNo,
          //"Mobile_No": "9500293181",
          "Pin_No": currentpin.join(""),
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          Loaddata = data['response'];
          print(Loaddata);
          _Count = int.parse(Loaddata[0]['CNT']);
          _RoleCode = Loaddata[0]['AP_ROLE_CODE'];

          print(_Count);
          print(Loaddata[0]['AP_ROLE_CODE']);
          print("!");
          if (_Count > 0 && int.parse(_RoleCode) == 01) {
            //01-Driver
            Navigator.push(
                context, MaterialPageRoute(builder: (conetxt) => LRData()));
          } else if (_Count > 0 && int.parse(_RoleCode) == 02) {
            //02-Admin
            Navigator.push(context,
                MaterialPageRoute(builder: (conetxt) => AdminLRData()));
          } else if (_Count > 0 && int.parse(_RoleCode) == 03) {
            //03-Sale Officer
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (conetxt) => DepotList(MobileNo: _MobileNo)));
          } else {
            //_Count = 0;
            //_RoleCode = "";
            showAlertDialog(context);
            pinOneController.text = "";
            pinTwoController.text = "";
            pinThreeController.text = "";
            pinFourController.text = "";
            pinIndex = 0;
            currentpin[0] = "";
            currentpin[1] = "";
            currentpin[2] = "";
            currentpin[3] = "";
          }
        });
      } else {
        http.Client().close();
        throw Exception('Failed to login');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      http.Client().close();
      return Future.value(['null']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to the login screen when already on the login screen
        if (ModalRoute.of(context)!.isFirst) {
          return true; // Allow system back navigation
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return false; // Block system back navigation
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment(0, 0.5),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      buildLogo(),
                      SizedBox(
                        height: 30,
                      ),
                      buildPinRow(),
                      SizedBox(
                        height: 30,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              text: "Forgot Password",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (conetxt) =>
                                            ForgotPassword())),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      buildNumberPad(),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //buildNumberPad(),
          ],
        ),
      ),
    );
  }

  buildLogo() {
    return Image.asset("asset/images/Conquer.png", fit: BoxFit.cover);
  }

  buildPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinOneController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinTwoController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinThreeController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinFourController,
        ),
      ],
    );
  }

  buildNumberPad() {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KeyboardNumber(
                  n: 1,
                  onPressed: () {
                    pinIndexSetup("1");
                  },
                ),
                KeyboardNumber(
                  n: 2,
                  onPressed: () {
                    pinIndexSetup("2");
                  },
                ),
                KeyboardNumber(
                  n: 3,
                  onPressed: () {
                    pinIndexSetup("3");
                  },
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KeyboardNumber(
                  n: 4,
                  onPressed: () {
                    pinIndexSetup("4");
                  },
                ),
                KeyboardNumber(
                  n: 5,
                  onPressed: () {
                    pinIndexSetup("5");
                  },
                ),
                KeyboardNumber(
                  n: 6,
                  onPressed: () {
                    pinIndexSetup("6");
                  },
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KeyboardNumber(
                  n: 7,
                  onPressed: () {
                    pinIndexSetup("7");
                  },
                ),
                KeyboardNumber(
                  n: 8,
                  onPressed: () {
                    pinIndexSetup("8");
                  },
                ),
                KeyboardNumber(
                  n: 9,
                  onPressed: () {
                    pinIndexSetup("9");
                  },
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      ClearPin();
                    },
                    child: Icon(
                      Icons.backspace,
                      color: Colors.black,
                    ),
                  ),
                ),
                KeyboardNumber(
                  n: 0,
                  onPressed: () {
                    pinIndexSetup("0");
                  },
                ),
                Container(
                  width: 50.0,
                  child: MaterialButton(
                    //height: 60.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    onPressed: () {
                      _fetchData();
                    },
                    child: Icon(
                      Icons.arrow_forward,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ClearPin() {
    if (pinIndex == 0)
      pinIndex = 0;
    else if (pinIndex == 4) {
      setPin(pinIndex, "");
      currentpin[pinIndex - 1] = "";
      pinIndex--;
    } else {
      setPin(pinIndex, "");
      currentpin[pinIndex - 1] = "";
      pinIndex--;
    }
  }

  pinIndexSetup(String text) {
    if (pinIndex == 0)
      pinIndex = 1;
    else if (pinIndex < 4) pinIndex++;
    setPin(pinIndex, text);
    currentpin[pinIndex - 1] = text;
    String strPin = "";
    currentpin.forEach((e) {
      strPin + e;
    });
    if (pinIndex == 4) print(strPin);
  }

  setPin(int n, String text) {
    switch (n) {
      case 1:
        pinOneController.text = text;
        break;
      case 2:
        pinTwoController.text = text;
        break;
      case 3:
        pinThreeController.text = text;
        break;
      case 4:
        pinFourController.text = text;
        break;
    }
  }
}

class PINNumber extends StatelessWidget {
//    PINNumber({Key? key}) : super(key: key);

  final TextEditingController textEditingController;
  final OutlineInputBorder outlineInputBorder;

  PINNumber(
      {required this.textEditingController, required this.outlineInputBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      child: TextField(
        controller: textEditingController,
        enabled: false,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          border: outlineInputBorder,
          filled: true,
          fillColor: Colors.lightBlueAccent.withOpacity(0.4),
        ),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}

class KeyboardNumber extends StatelessWidget {
  final int n;
  final Function() onPressed;

  KeyboardNumber({required this.n, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.lightBlueAccent.withOpacity(0.4),
      ),
      child: MaterialButton(
        padding: EdgeInsets.all(8.0),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60.0),
        ),
        height: 30.0,
        child: Text(
          "$n",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20 * MediaQuery.of(context).textScaleFactor,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//// Invalid Pin

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
    content: Text("Invalid Pin"),
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
