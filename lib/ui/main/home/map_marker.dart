import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final VoidCallback? onTap;
  BitmapDescriptor? icon;

  MapMarker({
    required this.id,
    required this.position,
    this.icon,
    this.onTap,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );


  Marker toMarker(Function(double, double)? onTap) => Marker(
        anchor: const Offset(0.5, 0.5),
        consumeTapEvents: true,
        markerId: MarkerId(isCluster! ? 'cl_$id' : id),
        onTap: () {

          if (onTap == null){
            this.onTap?.call();}
          else {
            onTap.call(position.latitude, position.longitude);
          }
        },
        position: LatLng(position.latitude, position.longitude),
        icon: icon!,
      );
}
