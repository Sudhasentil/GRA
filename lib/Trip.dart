import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_number/mobile_number.dart';
import 'package:workmanager/workmanager.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart' as Perm;
import 'Constants.dart';
import 'Login.dart';
import 'package:logger/logger.dart';

class TripMap extends StatefulWidget {
  @override
  State<TripMap> createState() => _TripMapState();

  final String origin;
  final String destination;
  final String LRNo;

  const TripMap(
      {Key? key,
      required this.origin,
      required this.destination,
      required this.LRNo});
}

class _TripMapState extends State<TripMap> {
  bool isLoggedIn = false;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  String _LRNo = "";

  late StreamSubscription<LocationData> _locationStream;

  String _latitude = "", _longitude = "";
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  Location location = Location();
  //String googleAPiKey = "AIzaSyBpyJhrECQ3GkjByikw9MmkjiIDW_BZH4s";
  String googleAPiKey = APIKey;

  LatLng startLocation = //13.0827° N, 80.2707° E. chennai
      LatLng(12.9177, 80.1588); //medavakkam//LatLng(27.6688312, 85.3077329);
  LatLng endLocation =
      LatLng(12.9031, 80.1890); //vengaivasal//LatLng(27.6683619, 85.3101895);

  Timer? _timer;

  BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor NewcurrentLocIcon = BitmapDescriptor.defaultMarker;

  void callbackDispatcher() {
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

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData newLoc) {
      setState(
        () {
          currentLocation = newLoc;
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              //zoom: 17,
              target: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
            ),
          ));
          _latitude = currentLocation!.latitude.toString();
          _longitude = currentLocation!.longitude.toString();
        },
      );
      //_sendWhatsAppMessage();
      //_calculateDistance();
    });
  }

  ////Get latlng from places

  Future<Map<String, double>> getLatLngFromPlaceName() async {
    String _origin = widget.origin;
    String _destination = widget.destination;
    //_LRNo = widget.LRNo;

    double o_lat = 0;
    double o_lng = 0;
    double d_lat = 0;
    double d_lng = 0;

    String O_API_URL =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$_origin&key=$googleAPiKey";

    String D_API_URL =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$_destination&key=$googleAPiKey";

    http.Response o_response = await http.get(Uri.parse(O_API_URL));

    if (o_response.statusCode == 200) {
      Map data = json.decode(o_response.body);
      if (data["status"] == "OK") {
        List<dynamic> results = data["results"];
        if (results.length > 0) {
          Map<String, dynamic> result = results[0];
          Map<String, dynamic> geometry = result["geometry"];
          Map<String, dynamic> location = geometry["location"];
          o_lat = location["lat"];
          o_lng = location["lng"];
          startLocation = //13.0827° N, 80.2707° E. chennai
              LatLng(o_lat, o_lng);
        }
      }
    }

    http.Response d_response = await http.get(Uri.parse(D_API_URL));

    if (d_response.statusCode == 200) {
      Map data = json.decode(d_response.body);
      if (data["status"] == "OK") {
        List<dynamic> results = data["results"];
        if (results.length > 0) {
          Map<String, dynamic> result = results[0];
          Map<String, dynamic> geometry = result["geometry"];
          Map<String, dynamic> location = geometry["location"];
          d_lat = location["lat"];
          d_lng = location["lng"];
          endLocation = LatLng(d_lat, d_lng);
        }
      }
    }
    getPolypoints();
    return {
      'o_latitude': o_lat,
      'o_longitude': o_lng,
      'd_latitude': d_lat,
      'd_longitude': d_lng,
    };
  }

  void getPolypoints() async {
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
        originIcon = icon;
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
            ImageConfiguration.empty, "asset/images/Car.jpg")
        .then(
      (icon) {
        NewcurrentLocIcon = icon;
      },
    );
  }

  ////Http post

  Future<void> _PostData() async {
    try {
      const String API_URL = '$API/GPSDATA';
      //const String API_URL = '$NTPL_API/GPSDATA';
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
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        return json.decode(response.body)['response'];
      } else {
        throw Exception('Failed to load Location Details');
      }
    } finally {}
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
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (mounted) {
      setState(() {
        _mobileNumber = mobileNumber;
      });
    }
  }

  void _calculateDistance() async {
    double _distanceToTarget = 0;
    //double targetLat = 37.4220; // Replace with target location latitude
    //double targetLng = -122.0841; // Replace with target location longitude
    double distanceInMeters = Geolocator.distanceBetween(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        endLocation!.latitude!,
        endLocation!.longitude!);
    print(currentLocation!.latitude!);
    print(currentLocation!.longitude!);
    print(endLocation!.latitude!);
    print(endLocation!.longitude!);

    print(distanceInMeters);
    _distanceToTarget = distanceInMeters / 1000; // Convert to kilometers
    print(_distanceToTarget);
    if (_distanceToTarget <= 5) {
      if (await _isPermissionGranted()) {
        if ((await _supportCustomSim)!) {
          //_sendMessage("9500293181", "hi", simSlot: 1);
          //_sendMessage(
          //    "9500293181", _mobileNumber + "Arriving at destination.");
          sendSmsInBackground();
        } else
          //_sendMessage("9500293181", "Hello");
          sendSmsInBackground();
      } else {
        _getPermission();
      }
    }
    //else {
    //sendSmsInBackground();
    //}
  }

  _getPermission() async => await [
        Perm.Permission.sms,
      ].request();

  Future<bool> _isPermissionGranted() async =>
      await Perm.Permission.sms.status.isGranted;

  _sendMessage(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
    }
  }

  Future<bool?> get _supportCustomSim async =>
      await BackgroundSms.isSupportCustomSim;

//Send Bulk BackgroundSms

  Future<List<dynamic>> getPhoneNumbersFromApi() async {
    _LRNo = widget.LRNo;
    print(_LRNo);
    try {
      String API_URL = '$API/AdminSMS/$_LRNo';
      //String API_URL = '$NTPL_API/AdminSMS/$_LRNo';
      final String _accessToken = accessToken;

      final response = await http.get(Uri.parse(API_URL), headers: {
        "Auth_Key": _accessToken,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      });

      List<String> numbers = [];

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //phoneNumbers = data['response'];

        for (final phoneNumbers in data['response']) {
          final contact = phoneNumbers['MN_MOBILE_NO'];
          numbers.add(contact);
        }

        print(numbers);
      } else {
        //client.close();
        throw Exception('Failed to load Details');
      }
      //return json.decode(response.body)['response'];
      return numbers;
    } catch (e) {
      print(e);
      //client.close();
      return Future.value(['null']);
    }
  }

  /*static Future<void> start() async {
    await Geolocator.requestPermission();
    final positionStream = Geolocator.getPositionStream();
    positionStream.listen((position) async {
      final distance = Geolocator.distanceBetween(position.latitude,
          position.longitude, position.latitude, position.longitude);
      if (distance < 5000) {
        // within 5 km of destination
        await sendSmsInBackground(); // send SMS in background
      }
    });
  }*/

  //static Future<void> sendSmsInBackground() async {
  Future<void> sendSmsInBackground() async {
    final phoneNumbers = await getPhoneNumbersFromApi();
    final message = "Arriving at destination in 5 minutes.";
    for (final phoneNumber in phoneNumbers) {
      var result = await BackgroundSms.sendMessage(
          phoneNumber: phoneNumber, message: message);
      if (result == SmsStatus.sent) {
        print("Sent");
      } else {
        print("Failed");
      }
    }
  }

  @override
  void dispose() {
//    _locationStream.cancel();
    //WidgetsBinding.instance!.removeObserver(this as WidgetsBindingObserver);
    _timer?.cancel();
    super.dispose();
  }

  void _startBackgroundTask() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager().registerPeriodicTask(
      'backgroundTask',
      'backgroundTask',
      frequency: Duration(minutes: 5),
    );
  }

  final logger = Logger();
  int count = 1;

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (Timer t) async {
      count++;
      logger.i('This is an info log message');
      logger.w('This is a warning log message');
      logger.e('This is an error log message');
      logger.i("count : $count");
      logger.i(DateTime.now());

      _PostData();
      _calculateDistance();
    });
  }

  void navigateToLoginScreen() {
    // Perform any necessary cleanup and navigate to the login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> yourSessionCheckMethod() async {
    // Implement your session check logic (e.g., API request, reading from storage, etc.)
    // Return true if the session is valid, false otherwise
    // Example: return await apiClient.checkSession();
    return false;
  }

  Future<void> checkSessionStatus() async {
    // Call an API or perform any necessary check to validate the session status
    bool isSessionValid = await yourSessionCheckMethod();

    if (isSessionValid) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      // Session expired, navigate to the login screen
      navigateToLoginScreen();
    }
  }

  @override
  void initState() {
    super.initState();

    //WidgetsBinding.instance!.addObserver(this);
    // Check session status on app startup
    checkSessionStatus();

    GetCurrentLocation();
    _startTimer();
    //Background Process
    _startBackgroundTask();
    //Mobile No
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
        GetCurrentLocation();
      } else {}
    });

    //GetCurrentLocation();
    initMobileNumberState();
    getLatLngFromPlaceName();
    SetCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Direction"),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            color: Colors.red,
            //   iconSize: 32.0,
            // splashColor: Colors.red,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (conetxt) => LoginPage()));
            },
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
              zoomGesturesEnabled: true,
              //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //target: startLocation,
                target: LatLng(currentLocation!.latitude!,
                    currentLocation!.longitude!), //initial position
                //zoom: 13.0, //initial zoom level
              ),

              polylines: {
                Polyline(
                  polylineId: PolylineId("Route"),
                  points: polylineCoordinates,
                  //points: [location1, location2, location3],
                  color: Colors.blue,
                  width: 5,
                ),
              },

              markers: {
                Marker(
                  markerId: MarkerId("Current Location"),
                  icon: NewcurrentLocIcon,
                  position: startLocation,
                  //position: LatLng(
                  //  currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: MarkerId("Source"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: startLocation,
                ),
                Marker(
                  markerId: MarkerId("Destination"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: endLocation,
                ),
              },
              mapType: MapType.normal,
              onMapCreated: (mapController) {
                _PostData();
                _controller.complete(mapController);
              },
            ),
    );
  }
}
