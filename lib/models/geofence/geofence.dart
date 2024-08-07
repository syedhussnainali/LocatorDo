
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
class Geofence {
    double origin_latitude;
    double origin_longitude;
    String max_distance;
    Geofence({
    required this.origin_latitude,
    required this.origin_longitude,
    required this.max_distance,
  });


  factory Geofence.fromJson(Map<String, dynamic> map) {

    return Geofence(
      origin_latitude: double.parse(map['origin_latitude'].toString()),
      origin_longitude: double.parse(map['origin_longitude'].toString()),
      max_distance: map['max_distance'].toString(),

    );
  }
}

