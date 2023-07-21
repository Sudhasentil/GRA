import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';

import 'Constants.dart';

class GD extends StatefulWidget {
  @override
  _GDState createState() => _GDState();
}

class _GDState extends State<GD> {
  late GoogleMapController mapController;
  LatLng selectedLocation = LatLng(12.9177, 80.1588);
  String address = "";

  final _geocoding = GoogleMapsGeocoding(apiKey: APIKey);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Selector',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Location Selector'),
        ),
        body: Container(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(12.9177, 80.1588),
                  zoom: 14,
                ),
                markers: Set<Marker>.of(
                  <Marker>[
                    Marker(
                      markerId: MarkerId('selected_location'),
                      position: selectedLocation ??
                          LatLng(37.42796133580664, -122.085749655962),
                      draggable: true,
                      onDragEnd: (LatLng newPosition) {
                        setState(() {
                          selectedLocation = newPosition;
                          getAddress(selectedLocation);
                        });
                      },
                    ),
                  ],
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),
              //if (address != null)

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    address,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getAddress(LatLng position) async {
    final response = await _geocoding.searchByLocation(Location(
      lat: position.latitude,
      lng: position.longitude,
    ));

    if (response.status == "OK") {
      final result = response.results.first;
      final formattedAddress = result.formattedAddress;
      setState(() {
        address = formattedAddress!;
      });
    }
  }
}
