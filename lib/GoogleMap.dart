import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_number/mobile_number.dart';
import 'package:workmanager/workmanager.dart';
import 'Constants.dart';
import 'package:logger/logger.dart';

class GooleMap extends StatefulWidget {
  @override
  State<GooleMap> createState() => _GooleMapState();
}

class _GooleMapState extends State<GooleMap> {
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];

  String _latitude = "", _longitude = "";

  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  Location location = Location();

  LatLng startLocation =
      LatLng(12.9177, 80.1588); //medavakkam//LatLng(27.6688312, 85.3077329);
  LatLng endLocation =
      LatLng(12.9031, 80.1890); //vengaivasal//LatLng(27.6683619, 85.3101895);

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocIcon = BitmapDescriptor.defaultMarker;

  void callbackDispatcher() {
    //print(DateTime.now());
    Workmanager().executeTask((task, inputData) {
      GetCurrentLocation();
      return Future.value(true);
    });
  }

  Future<void> GetCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    currentLocation = await location.getLocation();
    setState(() {
      currentLocation = currentLocation;
    });

    _latitude = currentLocation!.latitude.toString();
    _longitude = currentLocation!.longitude.toString();
    //print(_latitude);
    //print(_longitude);

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData newLoc) {
      setState(
        () {
          currentLocation = newLoc;
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
            ),
          ));
          print(currentLocation!.latitude);
          _latitude = currentLocation!.latitude.toString();
          print(currentLocation!.longitude);
          _longitude = currentLocation!.longitude.toString();
          print(_mobileNumber);
          //print(_date);
          //_PostData();
        },
      );
    });
  }

  List<LatLng> polylineCoordinates = [];

  void getPolypoints() async {
    String googleAPiKey = APIKey;

    ///String googleAPiKey = "AIzaSyCaK_BqwuuDb-pVDdtx7q4gubwmzNWXTJQ";
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      //PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    setState(() {});
  }

  void SetCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "asset/images/currentLoc1.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "asset/images/currentLoc1.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );

    BitmapDescriptor.fromAssetImage(
            //ImageConfiguration.empty, "asset/images/Arr.png")
            ImageConfiguration.empty,
            "asset/images/Truck1.jpeg")
        .then(
      (icon) {
        currentLocIcon = icon;
      },
    );
  }

  ///HTTP Post

  /* Future<http.Response> postWithTimeout(String url,
      {required Map<String, String> headers,
      body,
      Duration timeout = const Duration(minutes: 5)}) {
    const API_URL = 'http://122.165.198.198/HCM_API/API/GPSDATA';
    final String _accessToken = 'PNHmjvVzGJzPEUdeW7lWqw==';

    //print("1");
    return http.post(
      Uri.parse(API_URL),
      headers: {
        "Auth_Key": _accessToken,
      },
      body: {
        "GPS_LAT": _latitude,
        "GPS_LON": _longitude,
        "GPS_MOB_NO": _mobileNumber,
      },
    ).timeout(timeout);
  }
*/

  Future<void> _PostData() async {
//    print("aaaaaaaaa");
    try {
      const API_URL = '$API/GPSDATA';
      //const API_URL = '$NTPL_API/GPSDATA';
      final String _accessToken = accessToken;

      final response = await http.post(
        Uri.parse(API_URL),
        headers: {
          "Auth_Key": _accessToken,
        },
        body: {
          "GPS_LAT": _latitude,
          "GPS_LON": _longitude,
          "GPS_MOB_NO": _mobileNumber,
        },
//        timeout: Duration(minutes: 5),
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        return json.decode(response.body)['response'];
      } else {
        throw Exception('Failed to load Location Details');
      }
    } finally {}
    //});
  }

  /*Future<void> _PostData() async {
    try {
      const String API_URL = 'http://122.165.198.198/HCM_API/API/GPSDATA';
      final String _accessToken = 'PNHmjvVzGJzPEUdeW7lWqw==';

      final response = await postWithTimeout(
        API_URL,
        headers: {
          "Auth_Key": _accessToken,
        },
        body: {
          "GPS_LAT": _latitude,
          "GPS_LON": _longitude,
          "GPS_MOB_NO": _mobileNumber,
        },
        timeout: Duration(minutes: 5),
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);

        // wait for the specified time interval before posting again
        //await Future.delayed(Duration(minutes: 5));

        return json.decode(response.body)['response'];
      } else {
        throw Exception('Failed to load Location Details');
      }
    } finally {}
  }
*/

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

    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber.substring(mobileNumber.length - 10);
    });
  }

  final logger = Logger();
  int count = 1;

  @override
  void initState() {
    GetCurrentLocation();

    Timer.periodic(Duration(minutes: 5), (Timer t) async {
      count++;
      //logger.i('This is an info log message');
      //logger.w('This is a warning log message');
      //logger.e('This is an error log message');
      logger.i("count : $count");
      logger.i(DateTime.now());

      ////_PostData();
    });

    super.initState();

    //Background Process

    Workmanager().initialize(
      isInDebugMode: true,
      callbackDispatcher,
    );

    const fetchBackground = "fetchBackground";

    Workmanager().registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 5),
    );

    //Mobile No

    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
        GetCurrentLocation();
      } else {}
    });

    //
    GetCurrentLocation();
    initMobileNumberState();
    SetCustomMarkerIcon();
    getPolypoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Route Direction in Google Map"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
              //zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //target: startLocation,
                target: LatLng(currentLocation!.latitude!,
                    currentLocation!.longitude!), //initial position
                zoom: 13.0, //initial zoom level
              ),
              polylines: {
                Polyline(
                  polylineId: PolylineId("Route"),
                  points: polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
              },

              markers: {
                Marker(
                  markerId: MarkerId("Current Location"),
                  icon: currentLocIcon,
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: MarkerId("Source"),
                  //icon: sourceIcon,
                  position: startLocation,
                ),
                Marker(
                  markerId: MarkerId("Destination"),
                  //icon: DestinationIcon,
                  position: endLocation,
                ),
              },

              mapType: MapType.normal, //map type

              onMapCreated: (mapController) {
                //print(DateTime.now());
                //print("hi");
                //GetCurrentLocation();
                print("Lat : " + _latitude);
                print("Long : " + _longitude);
                //_PostData();

                logger.i('This is an info log message');
                logger.w('This is a warning log message');
                logger.e('This is an error log message');
                logger.i("count : $count");
                logger.i(DateTime.now());

                _controller.complete(mapController);
              },
            ),
      /* floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
          Workmanager().registerPeriodicTask(
            "1",
            "update_location",
            frequency: Duration(minutes: 30),
          );
          Workmanager().initialize(
            callbackDispatcher,
            isInDebugMode: true,
          );
        },
      ),*/
    );
  }
}
