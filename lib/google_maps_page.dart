// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_locator/bloc/location/location_bloc.dart';
import 'package:flutter_locator/functions/constants.dart';
import 'package:flutter_locator/models/devices/devices.dart';

import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:hydrated_bloc/hydrated_bloc.dart';
import "package:provider/provider.dart";

import 'Profile/profile.dart';
import 'bloc/Devices/devices_bloc.dart';
import 'functions/app_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController controller;

  get create => null;
  String dropdownValue = HydratedBloc.storage.read("id").toString();

  Timer? timer;
  late BitmapDescriptor markerbitmap;

  void createOrigincon() async {
    markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/home.png",
    );
  }

  @override
  void initState() {
    super.initState();
   // is_user_admin;
  }
  late bool is_user_admin;
  late double lat_origin;
  late double long_origin;
  double geofenceRadius = 10.0;
  late String distance_from_origin;

  List<Devices> devicesList = [];
  List<Marker> markers = [];

  late LocationBloc _locationBloc;

  String current_lat = "0.00";
  String current_lng = "0.00";

  @override
  Widget build(BuildContext context) {
    is_user_admin = HydratedBloc.storage.read("is_admin") ?? false;
    return BlocProvider(
      create: (context) => LocationBloc()..add(GetLocation()),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.locator),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile(timer,)),
                  );
                },
                icon: Icon(Icons.person),
                iconSize: 30,
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: !is_user_admin
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  setGeolocationDistance(context);
                },
                label: Text(AppLocalizations.of(context)!.add_origin),
                icon: Icon(Icons.add),
              ),
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            _locationBloc = context.read<LocationBloc>();
            if (timer == null) {
              timer = Timer.periodic(Duration(seconds: 20),
                  (Timer t) => _locationBloc.add(GetLocation()));
            }

            switch (state.status) {
              case LocationStatus.loading:
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case LocationStatus.error:
                if (state.latitude == "") {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
                return _googlemap(double.parse(state.latitude),
                    double.parse(state.longitude));

              case LocationStatus.loaded:
                if (state.latitude == "") {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                current_lng = state.longitude;
                current_lat = state.latitude;
                distance_from_origin = state.distance_from_origin;


                devicesList.clear();
                devicesList =
                    state.devices.map((e) => Devices.fromJson(e)).toList();
                for (Devices device in devicesList) {
                  markers.add(
                    Marker(
                        markerId: MarkerId(device.first_name.toString()),
                        infoWindow: InfoWindow(
                            title: "${device.first_name} ${device.middle_name}",
                            snippet: "${device.email} "),
                        position: LatLng(
                            device.current_latitude, device.current_longitude),
                        draggable: true,
                        onDragEnd: (value) {},
                        icon: BitmapDescriptor.defaultMarker),
                  );
                }

                return _googlemap(
                    double.parse(current_lat), double.parse(current_lng));

              default:
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
            }
          },
        ),
      ),
    );
  }

  Widget _googlemap(double latitude, double longitude) {
    double originLat = HydratedBloc.storage.read("lat_origin") ?? latitude;
    double originLng = HydratedBloc.storage.read("long_origin") ?? longitude;
    double maxdistance =
        double.parse(HydratedBloc.storage.read("geofence_radius").toString());

    BitmapDescriptor _homeIcon;

    markers.add(
      Marker(
        markerId: const MarkerId("marker1"),
        infoWindow: InfoWindow(title: "my origin location"),
        position: LatLng(originLat, originLng),
        draggable: true,
        onDragEnd: (value) {},
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    markers.add(
      Marker(
          markerId: const MarkerId("marker2"),
          infoWindow: InfoWindow(snippet: "My Location", title: "my location"),
          position: LatLng(latitude, longitude),
          draggable: true,
          onDragEnd: (value) {},
          icon: BitmapDescriptor.defaultMarker),
    );

    return Stack(
      children: [
        GoogleMap(
          circles: {
            Circle(
              circleId: CircleId("radius"),
              center: LatLng(originLat, originLng),
              radius: maxdistance * 1000,
              // in meters
              fillColor: Colors.blue.withOpacity(0.5),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          },
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(latitude, longitude), zoom: 10),
          markers: Set<Marker>.of(markers),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (location) {
            is_user_admin ? setLocationLimits(location) : null;
          },
          onMapCreated: (GoogleMapController controller) {
            controller = controller;
          },
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          color: Colors.redAccent,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.geofence_radius}: ${HydratedBloc.storage.read("geofence_radius") ?? 10} Kms",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  " ${AppLocalizations.of(context)!.your_distance_from_the_origin}: ${double.parse(distance_from_origin).toStringAsFixed(3)}  Kms",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void setGeolocationDistance(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => DevicesBloc(),
            child: BlocConsumer<DevicesBloc, DevicesState>(
              listener: (context, state) async {
                if (state.status == DevicesStatus.loaded) {
                  AppFunctions().snackbar(context, state.message, Colors.green);
                  await FirebaseMessaging.instance
                      .subscribeToTopic(dropdownValue);
                  Navigator.of(context).pop();
                  _locationBloc.add(GetLocation());
                } else if (state.status == DevicesStatus.error) {
                  AppFunctions().snackbar(context, state.message, Colors.red);
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text("Add Geofence Radius"),
                  content: Container(
                    height: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Select a device you want to geofence distance for?"),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Column(
                              children: [
                                DropdownButton<Devices>(
                                  hint: Text(
                                    "-- select device user-- ",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  iconSize: 40,
                                  style: TextStyle(fontSize: 25),
                                  onChanged: (Devices? value) {
                                    setState(() {
                                      dropdownValue = value!.user_id.toString();
                                    });
                                    log("dropdown value ------------------->" +
                                        dropdownValue);
                                  },
                                  items: devicesList
                                      .map<DropdownMenuItem<Devices>>(
                                        (e) => DropdownMenuItem<Devices>(
                                          value: e,
                                          child: Text(
                                            "${e.first_name} ${e.middle_name}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Selected device ID: $dropdownValue",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            );
                          },
                        ),
                        Container(
                          height: 40,
                          // width: MediaQuery.of(context).size.width * 0.35,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              decoration: InputDecoration(
                                hintText: "Geofence Radius (kms)",
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                fillColor: Colors.black,
                              ),
                              onChanged: (value) {
                                geofenceRadius = double.parse(value);
                              },
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    state.status == DevicesStatus.loading
                        ? CircularProgressIndicator.adaptive()
                        : MaterialButton(
                            onPressed: () {
                              context.read<DevicesBloc>().add(SetDeviceLocation(
                                  max_distance: geofenceRadius,
                                  user_id: dropdownValue,
                                  origin_longitude: 0,
                                  origin_latitude: 0));
                            },
                            child: Text("Submit"))
                  ],
                );
              },
            ),
          );
        });
  }

  void setLocationLimits(LatLng _location) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Set Origin Point"),
            content: Container(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select a device you want to set origin point for?"),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          children: [
                            DropdownButton<Devices>(
                              hint: Text(
                                "-- select device user-- ",
                                style: TextStyle(fontSize: 15),
                              ),
                              iconSize: 40,
                              style: TextStyle(fontSize: 25),
                              onChanged: (Devices? value) {
                                setState(() {
                                  dropdownValue = value!.user_id.toString();
                                });
                                log("dropdown value ------------------->" +
                                    dropdownValue);
                              },
                              items: devicesList
                                  .map<DropdownMenuItem<Devices>>(
                                    (e) => DropdownMenuItem<Devices>(
                                      value: e,
                                      child: Text(
                                        "${e.first_name} ${e.middle_name}",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Selected device ID: $dropdownValue",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        );
                      },
                    ),
                    Container(
                      height: 40,
                      // width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          decoration: InputDecoration(
                            hintText: "Geofence Radius (kms)",
                            labelStyle: TextStyle(color: Colors.black),
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            fillColor: Colors.black,
                          ),
                          onChanged: (value) {
                            geofenceRadius = double.parse(value);
                          },
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
              BlocProvider(
                create: (context) => DevicesBloc(),
                child: BlocConsumer<DevicesBloc, DevicesState>(
                  listener: (context, state) async {
                    if (state.status == DevicesStatus.loaded) {
                      AppFunctions()
                          .snackbar(context, state.message, Colors.green);
                      await FirebaseMessaging.instance
                          .subscribeToTopic(dropdownValue);
                      Navigator.of(context).pop();
                         _locationBloc.add(GetLocation());
                    } else if (state.status == DevicesStatus.error) {
                      AppFunctions()
                          .snackbar(context, state.message, Colors.red);
                      Navigator.of(context).pop();
                    }
                  },
                  builder: (context, state) {
                    if (state.status == DevicesStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    log("----------------------------------------" +
                        dropdownValue.toString());
                    return MaterialButton(
                      onPressed: () {
                        context.read<DevicesBloc>().add(SetDeviceLocation(
                            max_distance: geofenceRadius,
                            user_id: dropdownValue,
                            origin_longitude: _location.longitude,
                            origin_latitude: _location.latitude));
                      },
                      child: Text("Yes"),
                    );
                  },
                ),
              )
            ],
          );
        });
  }
}
