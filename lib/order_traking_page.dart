import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(30.1920, 71.4505);
  static const LatLng destination = LatLng(30.1836, 71.4417);
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;

  LocationData? currentLocation;
  List<LatLng> polyLineCoordinates = [];

  // TODO Get Current Location
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
    });
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!))));
      setState(() {});
    });
  }

  // TODO To Show Direction Line on Map
  void getPolyPoint() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polyLineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track order",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: currentLocation == null
            ? const Center(
                child: Text("Loading"),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 13.0,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: polyLineCoordinates,
                    color: primaryColor,
                    width: 6,
                  )
                },
                markers: {
                  Marker(
                      markerId: const MarkerId("CurrentLocation"),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!)),
                  const Marker(
                      markerId: MarkerId("source"), position: sourceLocation),
                  const Marker(
                    markerId: MarkerId("destination"),
                    position: destination,
                  ),
                },
                onMapCreated: (mapController) {
                  _controller.complete(mapController);
                },
              ));
  }
}
