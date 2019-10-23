// Using location and Google maps: https://github.com/Lyokone/flutterlocation

import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'primary_widgets.dart';
import 'package:flutter_application/config.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

class GPSLocation extends StatefulWidget {
  final Config config;

  GPSLocation({Key key, @required this.config}) : super(key: key);

  @override
  _GPSLocationState createState() => _GPSLocationState();
}

class _GPSLocationState extends State<GPSLocation> {
  Location location = new Location();

  LocationData currentLocation;

  double currentLongitude, currentLatitude;

  String error;

  bool provideLocation = false;

  GoogleMap worldMap;

  Completer<GoogleMapController> controller = Completer();
  static final CameraPosition initialMapCam =
      CameraPosition(target: LatLng(0, 0), zoom: 4);

  CameraPosition currentMapCam;

  Map userLocationMap;

  String stringAddress = "";

  void setupAddresses(Coordinates coord) async
  {
    Geocoder.local.findAddressesFromCoordinates(coord).then((err)
        {
          if(userLocationMap == null) {
            userLocationMap = {
              'City'    : err[0].locality,
              'County'  : err[0].subAdminArea,
              'State'   : err[0].adminArea,
              'Country' : err[0].countryName,
            };

            stringAddress = err[0].locality+", "+err[0].adminArea+", "+err[0].countryName;

            setState(() {

            });
          }
        });
  }


  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  initializeLocation() async {
    //await location.changeSettings(accuracy: LocationAccuracy.HIGH);
    LocationData tempLoc;

    try {

      bool locationStatus = await location.serviceEnabled();
      print("LocationStatus: " + locationStatus.toString());
      if (locationStatus) {
        provideLocation = await location.requestPermission();
        print("Provide Location Inside Location Status: " +
            provideLocation.toString());
        if (provideLocation) {
          tempLoc = await location.getLocation();

          final cords = new Coordinates(tempLoc.latitude, tempLoc.longitude);

          setupAddresses(cords);

          currentMapCam = CameraPosition(
              target: LatLng(tempLoc.latitude, tempLoc.longitude), zoom: 16);

          final GoogleMapController tempController = await controller.future;
          tempController
              .animateCamera(CameraUpdate.newCameraPosition(currentMapCam));

          if (mounted) {
            setState(() {
              currentLocation = tempLoc;
            });
          }
        } else {
          bool locationStatus = await location.serviceEnabled();
          if (locationStatus) {
            initializeLocation();
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      currentLocation = null;
    }
  }

  Widget getView() {
    print("The user provided his Location? " + provideLocation.toString());
    worldMap = GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      initialCameraPosition: initialMapCam,
      onMapCreated: (GoogleMapController con) {
        controller.complete(con);
      },
    );

    String msg = 'Submitting your location data will allow for you to compare ' +
        'your survey results with other anymosuly with other people around you. ' +
        'Do you want to provide your location?';


    String locationMsg = "You are currently located in " + stringAddress;

    //TODO: Add logic for if the user does not enable location handling
    return ListView(
      children: <Widget>[
        new Container(
          height: 250,
          child: worldMap,
        ),
        new Container(
          child: new Text(msg),
        ),
        new Container(
          child: new Text(locationMsg),
        ),
        new Container(
          child: getPaddedButton("Yes", () {
            widget.config.locData = userLocationMap;
            Navigator.popUntil(this.context, ModalRoute.withName("/"));
          }),
        ),
        new Container(
          child: getPaddedButton("No", () {
            widget.config.locData = null;
            Navigator.popUntil(this.context, ModalRoute.withName("/"));
          }),
        )
      ],
    );
  }

  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Location")),
      body: getView(),
    );
  }
}
