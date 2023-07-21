import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
//import 'package:mobile_number/mobile_number.dart';
//import 'package:workmanager/workmanager.dart';

class ShowMap extends StatefulWidget {
  @override
  State<ShowMap> createState() => _ShowMapState();

  final String origin;
  final String destination;
  final String vehicleNo;

  const ShowMap(
      {Key? key,
      required this.origin,
      required this.destination,
      required this.vehicleNo});
}

class _ShowMapState extends State<ShowMap> {
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  //String _mobileNumber = '';
  //List<SimCard> _simCard = <SimCard>[];
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  Location location = Location();
  String googleAPiKey = APIKey;

  LatLng startLocation = //13.0827° N, 80.2707° E. chennai
      LatLng(12.9177, 80.1588); //medavakkam//LatLng(27.6688312, 85.3077329);
  LatLng endLocation =
      LatLng(12.9031, 80.1890); //vengaivasal//LatLng(27.6683619, 85.3101895);

  late double _latitude = startLocation.latitude,
      _longitude = startLocation.longitude;

  BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor NewcurrentLocIcon = BitmapDescriptor.defaultMarker;

//  void callbackDispatcher() {
//    Workmanager().executeTask((task, inputData) {
//      GetCurrentLocation();
//      return Future.value(true);
//    });
//  }

  Future<List<dynamic>> _fetchData() async {
    String _vehicleNo = widget.vehicleNo;
    List Loaddata = [];

    try {
      var API_URL = "$API/GPSDATA/VehicleNo/$_vehicleNo";
      //"$NTPL_API/GPSDATA/VehicleNo/$_vehicleNo";
      print(API_URL);
      final String _accessToken = accessToken;

      final response = await http.Client().get(
        Uri.parse(API_URL),
        headers: {
          "Auth_Key": _accessToken,
          "Connection": "Keep-Alive",
          "Keep-Alive": "timeout=5, max=1000",
          "Accept": "application/json",
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          Loaddata = data['response'];

          _latitude = Loaddata[0]['GPS_LAT'];
          _longitude = Loaddata[0]['GPS_LON'];

          if (_latitude == null) {
            _latitude = startLocation!.latitude;
          }
          if (_longitude == null) {
            _longitude = startLocation!.longitude;
          }
        });
      } else {
        http.Client().close();
        throw Exception('Failed to login');
      }
      return json.decode(response.body)['response'];
    } catch (e) {
      print(e);
      http.Client().close();
      return Future.value(['null']);
    }
  }

  Future<void> GetCurrentLocation() async {
    //String _origin = widget.origin;
    //String _destination = widget.destination;

    //print(_origin);
    //print(_destination);

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

    GoogleMapController googleMapController = await _controller.future;

    //_latitude = currentLocation!.latitude.toString();
    //_longitude = currentLocation!.longitude.toString();

    location.onLocationChanged.listen((LocationData newLoc) {
      setState(
        () {
          currentLocation = newLoc;
          print(currentLocation);
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              //target: LatLng(double.parse(_latitude), double.parse(_longitude)),
              target: LatLng(_latitude, _longitude),
            ),
          ));
          //_latitude = currentLocation!.latitude.toString();
          //_longitude = currentLocation!.longitude.toString();
        },
      );
    });
  }

  ////Get latlng from places

  Future<Map<String, double>> getLatLngFromPlaceName() async {
    String _origin = widget.origin;
    String _destination = widget.destination;

    print(_origin);
    print(_destination);

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
    String googleAPiKey = "AIzaSyBpyJhrECQ3GkjByikw9MmkjiIDW_BZH4s";

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
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

  /*Future<void> initMobileNumberState() async {
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

    if (mounted) {
      setState(() {
        _mobileNumber = mobileNumber;
      });
    }
  }*/

  //Background process

  //void dispose() {
//    super.dispose();
//  }

  @override
  void initState() {
    super.initState();
    GetCurrentLocation();
    _fetchData();

    //Background Process

//    Workmanager().initialize(
//      isInDebugMode: true,
//      callbackDispatcher,
//    );

//    const fetchBackground = "fetchBackground";

//    Workmanager().registerPeriodicTask(
//      "1",
//      fetchBackground,
//      frequency: Duration(minutes: 5),
//    );

    //Current Location

//    GetCurrentLocation();
    getLatLngFromPlaceName();
    SetCustomMarkerIcon();

    //Mobile No

//    MobileNumber.listenPhonePermission((isPermissionGranted) {
//      if (isPermissionGranted) {
//        initMobileNumberState();
//      } else {}
//    });

//    initMobileNumberState();
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
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //target: startLocation,
                target: LatLng(_latitude, _longitude), //initial position

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
                  icon: NewcurrentLocIcon,
                  position: LatLng(_latitude, _longitude),
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

              mapType: MapType.normal, //map type

              onMapCreated: (mapController) {
                GetCurrentLocation();
                _fetchData();
                _controller.complete(mapController);
              },
            ),
    );
  }
}
