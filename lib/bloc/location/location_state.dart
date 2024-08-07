// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
part of 'location_bloc.dart';

class LocationState extends Equatable {
  String latitude;
  String longitude;
  List devices;
  String distance_from_origin;

  final LocationStatus status;

  LocationState( 
      {this.latitude = "",
        this.distance_from_origin = "",
      this.longitude = "",
      this.devices = const [],
      this.status = LocationStatus.initial});

  @override
  List<Object> get props => [latitude, longitude, status, distance_from_origin];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'status': status.index,
    };
  }

  factory LocationState.fromMap(Map<String, dynamic> map) {
    int index = map['status'];

    return LocationState(
      status: LocationStatus.values[index],
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationState.fromJson(String source) =>
      LocationState.fromMap(json.decode(source) as Map<String, dynamic>);

  LocationState copyWith({
    String? latitude,
    String? longitude,
    List? devices,
    String? distance_from_origin,
    LocationStatus? status,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance_from_origin:  distance_from_origin ?? this.distance_from_origin,
      devices: devices ?? this.devices,
     status: status ?? this.status,
    );
  }
}

enum LocationStatus {
  initial,
  loading,
  loaded,
  error,
  loadingDevices,
  getDevicesError,
  getDevicesSuccess
}
