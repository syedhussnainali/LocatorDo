// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../functions/api.dart';
import '../../functions/app_functions.dart';
import '../../models/geofence/geofence.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends HydratedBloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationState()) {
    on<GetLocation>(_onGetLocation);


  }



  void _onGetLocation(GetLocation event, Emitter<LocationState> emit) async {
    if (state.status == LocationStatus.initial) {
      emit(state.copyWith(status: LocationStatus.loading));
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission.name == "denied") {
        LocationPermission permissionRequest =
            await Geolocator.requestPermission();

        if (permissionRequest.name == "denied") {
          emit(state.copyWith(status: LocationStatus.error));
          return;
        }
      }

      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      HydratedBloc.storage.write("geofence_radius", HydratedBloc.storage.read("geofence_radius") ?? "10");

      double originLat = HydratedBloc.storage.read("lat_origin") ?? position.latitude;
      double originLng = HydratedBloc.storage.read("long_origin") ?? position.longitude;
      double maxdistance = double.parse(HydratedBloc.storage.read("geofence_radius").toString());

      double  distance_from_origin = AppFunctions().calculateDistance(
          position.latitude,
          position.longitude,
          originLat,
          originLng);

      try {
        Response response = await Api().updateLocation(
            current_latitude: position.latitude,
            current_longitude: position.longitude,
            user_distance: distance_from_origin == 0.0 ? 1.00 :distance_from_origin,
            max_distance:maxdistance,
            origin_longitude: originLat,
            origin_latitude: originLng);



        if (response.statusCode != 200) {
          emit(state.copyWith(status: LocationStatus.error));
        } else {
          log(response.data.toString());
          Geofence bounds = Geofence.fromJson(response.data["you"]);

          HydratedBloc.storage.write("lat_origin", bounds.origin_latitude);
          HydratedBloc.storage.write("long_origin", bounds.origin_longitude) ;
          HydratedBloc.storage.write("geofence_radius", bounds.max_distance);

          emit(state.copyWith(status: LocationStatus.loaded, devices: response.data["users"], distance_from_origin: distance_from_origin.toString(), latitude: position.latitude.toString(), longitude: position.longitude.toString()));
        }
      } catch (e) {
        emit(state.copyWith(status: LocationStatus.error));
      }


    } catch (e) {
      emit(state.copyWith(status: LocationStatus.error));
    }
  }

  @override
  LocationState fromJson(Map<String, dynamic> data) {
    return LocationState.fromJson(json.encode(data));
  }

  @override
  Map<String, dynamic>? toJson(LocationState state) {
    if (state.status == LocationStatus.loaded) {
      return state.toMap();
    }
    return null;
  }

  @override
  void onChange(Change<LocationState> change) {
    super.onChange(change);
    debugPrint('$change');
  }
}
