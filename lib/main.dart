import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/Login.dart';
import 'package:flutter/services.dart';
import 'DepotList.dart';
import 'background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  BackgroundService.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: GooleMap(),
      //home: AdminLRData(),
      //home: LoginPage(),
      home: DepotList(MobileNo: "9500293181"),
      //home: SaleOfficerLRData(ID: "4"),
      //home: SendSMS(),
      //home: ItemDetails(LRSysID: "1"),
      //    home: Recoveries(
      //    LRSysID: '1329',
      //  SubSysID: '1',
      //),
    );
  }
}
