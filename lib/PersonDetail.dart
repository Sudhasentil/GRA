import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/Login.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';

class PersonDetail extends StatefulWidget {
  final String MobileNo;
  const PersonDetail({Key? key, required this.MobileNo});

  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  List Loaddata = [];
  String _Username = "";

  void _fetchUserName() async {
    String _MobileNo = widget.MobileNo;
    try {
      var API_URL = '$API/Userdtl/$_MobileNo';
      final String _accessToken = accessToken;

      final response = await http
          .get(Uri.parse(API_URL), headers: {"Auth_Key": _accessToken});

      if (response.statusCode == 200) {
        final data = await json.decode(response.body);
        setState(
          () {
            Loaddata = data['response'];
            _Username = Loaddata[0]["AP_USER_NAME"];
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
    _fetchUserName();
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
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Container(
                alignment: Alignment.topRight,
                child: SizedBox(
                  //width: 30, // Set the desired width
                  //height: 30, // Set the desired height
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    label: Text(''),
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(BorderSide
                          .none), // Set the side to BorderSide.none to remove the outline
                    ),
                  ),
                )),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(15),
              child: CircleAvatar(
                backgroundImage: AssetImage('asset/images/Person.png'),
              ),
            ),
            //SizedBox(height: 20),
            Container(
              child: Text(
                _Username,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textScaleFactor: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Text(
                widget.MobileNo,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textScaleFactor: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(300, 40), // Set the width and height
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  backgroundColor: Colors.blue,
                ),
                child: Text("Logout"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (conetxt) => LoginPage()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
