import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent2park/extension/primitive_extension.dart';

import '../../../util/constants.dart';
import 'map_marker.dart';


/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.

class MapHelper {
  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.

  static Future<BitmapDescriptor> _getClusterMarker(
      int clusterSize, Color clusterColor, Color textColor, Size size) async {
    int imageWidth = size.width ~/ 2.4;
    if(Platform.isIOS){
      imageWidth = size.width ~/ 1.4;
    }else if(Platform.isAndroid){
      imageWidth = size.width ~/ 2.4;
    }


    // clusterSize=clusterSize-1;

    TextPainter tp = new TextPainter(
        text: TextSpan(),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.text = TextSpan(
        text: '${clusterSize > 9 ? '9+' : clusterSize}',
        style: TextStyle(
            fontSize: Platform.isIOS?38:size.width * 0.07,
            color: Constants.COLOR_ON_PRIMARY,
            height: 1,
            fontFamily: Constants.GILROY_BOLD),
        children: [

          TextSpan(
              text: '\nSpaces\n',
              style: TextStyle(
                  fontSize: Platform.isIOS?24:size.width * 0.038,
                  fontFamily: Constants.GILROY_MEDIUM,
                  color: Constants.COLOR_ON_PRIMARY))
        ])

        /*TextSpan(
        text: '${clusterSize > 9 ? '9+' : clusterSize}\n',
        style: TextStyle(
            fontSize: (imageWidth ~/ 5).toDouble(),
            color: Constants.COLOR_ON_PRIMARY,
            letterSpacing: 1.0,
            fontFamily: Constants.GILROY_BOLD),
        children: [

          TextSpan(
              text: 'Spaces',
              style: TextStyle(
                  fontSize: imageWidth / 8.5,
                  fontFamily: Constants.GILROY_SEMI_BOLD,
                  color: Constants.COLOR_ON_PRIMARY))
        ])*/;
// 123456
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    final paint = Paint();
    final image =
        await 'assets/pin_nav.png'.imageFromAsset(imageWidth);
    c.drawImage(image, Offset(0, 0), paint);

    tp.layout();
    double textLayoutOffsetX = 0.0;
    double textLayoutOffsetY = 0.0;

    if(Platform.isIOS){
       textLayoutOffsetX = (imageWidth - tp.width) / 2;
       textLayoutOffsetY = (imageWidth - tp.height) / 2.6;
    }else if(Platform.isAndroid){
       textLayoutOffsetX = (imageWidth - tp.width) / 2;
       textLayoutOffsetY = (imageWidth - tp.height) / 2.9;
    }


    tp.paint(c, new Offset(textLayoutOffsetX, textLayoutOffsetY));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    Picture p = recorder.endRecording();
    ByteData? pngBytes = await (await p.toImage(imageWidth, imageWidth))
        .toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes!.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  /// Init's the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.

  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
    
      createCluster: (BaseCluster? cluster, double? lng, double? lat) =>
          MapMarker(
        id: cluster!.id.toString(),
        position: LatLng(lat!, lng!),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
        
      ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].

  static Future<List<Marker>> getClusterMarkers(
      Fluster<MapMarker>? clusterManager,
      double currentZoom,
      Color clusterColor,
      Color clusterTextColor,
      Size size,
      Function(double, double) onTap) {
    if (clusterManager == null) return Future.value([]);


    return Future.wait(clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom.toInt(),
    ).map((mapMarker) async {
      if (mapMarker.isCluster!) {
        mapMarker.icon = await _getClusterMarker(
            mapMarker.pointsSize!, clusterColor, clusterTextColor, size);
        return mapMarker.toMarker(onTap);
      }

      return mapMarker.toMarker(null);
    }).toList());
  }
}
