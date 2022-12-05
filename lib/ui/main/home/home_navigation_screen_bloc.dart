import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fluster/fluster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice/places.dart' as places;

import 'package:rent2park/data/EventSearchApiModel.dart';
import 'package:rent2park/extension/primitive_extension.dart';
import 'package:rent2park/ui/main/home/map_helper.dart';
import 'package:rent2park/util/SizeConfig.dart';
import 'dart:ui' as ui;

import '../../../backend/shared_web-services.dart';
import '../../../collection/parking_collection.dart';

import '../../../data/backend_responses.dart';
import '../../../data/location_sheet_selection.dart';
import '../../../data/meta_data.dart';
import '../../../data/user_type.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import 'home_navigation_screen_state.dart';
import 'map_marker.dart';

class HomeNavigationScreenBloc extends Cubit<HomeNavigationScreenState> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  // static const String _USER_CURRENT_LOCATION_MARKER_ID = '12121212';
  static const CameraPosition _DEFAULT_CAMERA_POSITION = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792), zoom: 10);
  double _ZOOM_LEVEL = 13;
  static const int MIN_CLUSTER_ZOOM = 0;
  static const int MAX_CLUSTER_ZOOM = 19;

  final Size size;
  final List<String> evTypes = [
    AppText.TESLA_US,
    AppText.TYPE_ONE,
    AppText.TYPE_TWO,
    AppText.CHADEMO,
    AppText.COMBO_ONE,
    AppText.COMBO_TWO
  ];

  // var markerIdVal = MyWayToGenerateId();
  // final MarkerId markerId = MarkerId(markerIdVal);
  Set<Marker> markers = {
    Marker(markerId: MarkerId('Location'), icon: BitmapDescriptor.defaultMarker)
  };
  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('circleId'),
      // center: LatLng(latitude, longitude),
      fillColor: Colors.blue.shade100.withOpacity(0.5),
      strokeColor: Colors.blue.shade100.withOpacity(0.1),
      radius: 3000,
    )
  ]);
  final ParkingSpaceCollection _parkingSpaceCollection =
      ParkingSpaceCollection.instance;

  UserType get userType => _sharedPrefHelper.userType;

  CameraPosition get cameraPosition => state.locationData.latitude == 0.0
      ? _DEFAULT_CAMERA_POSITION
      : CameraPosition(
      target: LatLng(
          state.locationData.latitude!, state.locationData.longitude!),
      zoom: _ZOOM_LEVEL);

  GoogleMapController? _googleMapController;
  HomeResponse? driverResponse;
  HomeResponse? hostResponse;
  Fluster<MapMarker>? _clusterManager;
  double? lastLat, lastLng;
  double currentMapZoomLevel = 0.0;

  HomeNavigationScreenBloc({required this.size})
      : super(HomeNavigationScreenState.initial(_DEFAULT_CAMERA_POSITION));

  void updateMapController(GoogleMapController controller) async {
    if (_googleMapController != null) return;
    final mapStyle =
    await rootBundle.loadString('assets/google_map_style.json');
    await controller.setMapStyle(mapStyle);
    this._googleMapController = controller;
  }

  void updateLocation(GlobalKey globalKey, LocationData locationData,
      VoidCallback onMarkerTap) async {
    final double? lat = locationData.latitude;
    final double? lng = locationData.longitude;
    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) return;
    // final userLocationMarkerBytes = await 'assets/current_location_icon.png'.bytesFromAsset(50);
    // final marker = Marker(
    //     markerId: MarkerId(_USER_CURRENT_LOCATION_MARKER_ID),
    //   y   position: LatLng(lat, lng),
    //     icon: BitmapDescriptor.fromBytes(userLocationMarkerBytes));
    // markers.add(marker);
    emit(state.copyWith(
        locationData: locationData, isNeedReloadMap: !state.isNeedReloadMap));
    // if (_sharedPrefHelper.userType == UserType.driver) {
    // animateCamera(null, null);
    // driverHome(lat, lng);
    // } else if (_sharedPrefHelper.userType == UserType.host)
    if (userType == UserType.host) {
      hostHome(globalKey, () {
        onMarkerTap.call();
      });
    } else {
      // driverHome(globalKey, lat, lng);
    }
  }

  void updateLocationIOS(GlobalKey globalKey, Position positionData,
      VoidCallback onMarkerTap) async {
    final double? lat = positionData.latitude;
    final double? lng = positionData.longitude;
    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) return;
    LocationData locationData;
    locationData = LocationData.fromMap({'latitude': lat, 'longitude': lng});
    emit(state.copyWith(
        locationData: locationData, isNeedReloadMap: !state.isNeedReloadMap));
    if (userType == UserType.host) {
      hostHome(globalKey, () {
        onMarkerTap.call();
      });
    } else {

      // driverHome(globalKey, lat, lng);
    }
  }

  void animateCamera(double? latitude, double? longitude) {
    if (latitude != null && longitude != null) {

      _googleMapController?.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: _ZOOM_LEVEL)));

      /*_googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(latitude, longitude), zoom: _ZOOM_LEVEL)));*/

      _ZOOM_LEVEL = 13.0;

    } else {
      // _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      _googleMapController?.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  void updateLastConnectorIndex(int lastConnectorIndex) =>
      emit(state.copyWith(lastConnectorIndex: lastConnectorIndex));

  void updateSearchFilterRange(RangeValues rangeValue) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(rangeValue: rangeValue)));

  void updateSearchFilterSecurelyGated(bool isSecurelyGated) => emit(
      state.copyWith(
          searchFilter:
          state.searchFilter.copyWith(isSecurelyGated: isSecurelyGated)));

  void updateParkingType(String parkingType) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(parkingType: parkingType)));

  void updatePackageSelected(String packageSelected) =>
      emit(state.copyWith(packageSelected: packageSelected));

  void applyFilters(bool applyFilters) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(applyFilters: applyFilters)));

  void updateSearchFilterCctv(bool isCctv) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isCctv: isCctv)));

  void updateSearchFilterSheltered(bool isSheltered) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isSheltered: isSheltered)));

  void updateSearchFilterWifi(bool wifi) => emit(
      state.copyWith(searchFilter: state.searchFilter.copyWith(isWifi: wifi)));

  void updateSearchFilterDisabledAccess(bool isDisabledAccess) =>
      emit(state.copyWith(
          searchFilter:
          state.searchFilter.copyWith(isDisabledAccess: isDisabledAccess)));

  void updateSearchFilterLighting(bool isLighting) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isLighting: isLighting)));

  void updateParkingSlotClick(bool isNextClicked) =>
      emit(state.copyWith(parkingSlotNextClicked: isNextClicked));

  void updateParkingHourlySelected(bool hourlySelected) =>
      emit(state.copyWith(hourlySelected: hourlySelected));

  void updateSearchFilterElectricVehicle(bool isElectricVehicleCharging) =>
      emit(state.copyWith(
          searchFilter: state.searchFilter
              .copyWith(isElectricVehicleCharging: isElectricVehicleCharging)));

  void updateisEVEnable(bool isEVEnable) =>
      emit(state.copyWith(isShowEvSpaces: isEVEnable));

  void updateSearchFilterAirportTransfers(bool isAirportTransfers) =>
      emit(state.copyWith(
          searchFilter: state.searchFilter
              .copyWith(isAirportTransfers: isAirportTransfers)));

  void updateSearchFilterDriveway(bool isDriveway) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isDriveway: isDriveway)));

  void updateSearchFilterGarage(bool isGarage) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isGarage: isGarage)));

  void updateSearchFilterCarPark(bool isCarPark) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isCarPark: isCarPark)));

  void updateSearchFilterLandGrassParking(bool isLandGrassParking) =>
      emit(state.copyWith(
          searchFilter: state.searchFilter
              .copyWith(isLandGrassParking: isLandGrassParking)));

  void updateSearchFilterOnStreet(bool isOnStreet) => emit(state.copyWith(
      searchFilter: state.searchFilter.copyWith(isOnStreet: isOnStreet)));

  void updateSearchResults(List<places.PlacesSearchResult> searchResults) =>
      emit(state.copyWith(searchResults: searchResults));

  void updateSearchAirports(List<places.PlacesSearchResult> airports) =>
      emit(state.copyWith(airports: airports));

  void updateEvents(List<EventsResults> events) =>
      emit(state.copyWith(events: events));

  void clearAllFilters() {
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isSecurelyGated: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isCctv: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isDisabledAccess: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isLighting: false)));
    emit(state.copyWith(
        searchFilter:
        state.searchFilter.copyWith(isElectricVehicleCharging: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isWifi: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isSheltered: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isAirportTransfers: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isDriveway: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isGarage: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isLandGrassParking: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isOnStreet: false)));
    emit(state.copyWith(
        searchFilter: state.searchFilter.copyWith(isCarPark: false)));
  }

  void showSuggestions(bool showSuggestions) =>
      emit(state.copyWith(showSuggestions: showSuggestions));

  void showDateAndTimeView(bool showDateTimeView) =>
      emit(state.copyWith(showDateTimeView: showDateTimeView));

  void showFilterView(bool showFilterView) =>
      emit(state.copyWith(isFilterShow: showFilterView));

  void updateParkingStartTime(String parkingStartTime) =>
      emit(state.copyWith(parkingSpaceStartDateTime: parkingStartTime));

  void updateParkingEndTime(String parkingEndTime) =>
      emit(state.copyWith(parkingSpaceEndDateTime: parkingEndTime));

  void updateParkingTimings(String parkingStartTime,String parkingEndTime) => emit(state.copyWith(parkingSpaceStartDateTime: parkingStartTime,parkingSpaceEndDateTime: parkingEndTime));

  void updateFormattedParkingTimings(String parkingStartTime,String parkingEndTime) =>
      emit(state.copyWith(startTime: parkingStartTime,endTime: parkingEndTime));

  void updateParkingSlots(bool parkingEndSlot) =>
      emit(state.copyWith(parkingEndSlot: parkingEndSlot));

  void updateEvSpaces(bool isShowEvSpaces) =>
      emit(state.copyWith(isShowEvSpaces: isShowEvSpaces));

  void updateEvSwitch(bool isEVSwitched) {

    emit(state.copyWith(evSwitch: isEVSwitched));
  }

  void updateEvConnectorIndex(int val) =>
      emit(state.copyWith(lastConnectorIndex: val));

  void updateSpaceEdits(bool isSpaceEdited) =>
      emit(state.copyWith(isSpaceEdited: isSpaceEdited));

  void updateSpaceUpdatedCheckedDriver(bool isSpaceChecked) =>
      emit(state.copyWith(isSpaceUpdatedDriverChecked: isSpaceChecked));

  void updateSpaceUpdatedCheckedHost(bool isSpaceChecked) =>
      emit(state.copyWith(isSpaceUpdatedHostChecked: isSpaceChecked));

  void updateSheetSelection(
      GlobalKey globalKey, LocationSheetSelection sheetSelection) {
    lastLat = sheetSelection.lat;
    lastLng = sheetSelection.lng;
    emit(state.copyWith(sheetSelection: sheetSelection));

    animateCamera(sheetSelection.lat, sheetSelection.lng);
    driverHome(
      globalKey,
      sheetSelection.lat,
      sheetSelection.lng,
    );
  }

  void hostHome(GlobalKey globalKey, VoidCallback markerTap) async {
    final User? user = await _sharedPrefHelper.user();
    if (user == null) return;
    emit(state.copyWith(dataEvent: Loading()));
    var startTime =  intl.DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(state.parkingSpaceStartDateTime)).toString();
    var endTime = intl.DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(state.parkingSpaceEndDateTime)).toString();

    try {
      final response = await _sharedWebService.hostHome(user.id, user.accessToken.toString(),startTime,endTime);
      hostResponse = response;
      seUpdateMarkerData(hostResponse!.parkingSpaces, markerTap, globalKey);
    } catch (e) {
      emit(
          state.copyWith(dataEvent: Error(exception: Exception(e.toString()))));
    }
  }

  void driverHome(
      GlobalKey globalKey,
      double latitude,
      double longitude, {
        bool isNewRequest = true,
      }) async {
    final double lat = latitude;
    final double lng = longitude;
    if (lat == 0.0 || lng == 0.0) return;
    final User? user = await _sharedPrefHelper.user();
    if (user == null) return;
    emit(state.copyWith(dataEvent: Loading()));
    try {
      late HomeResponse response;
      var startTime =  intl.DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(state.parkingSpaceStartDateTime)).toString();
      var endTime = intl.DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(state.parkingSpaceEndDateTime)).toString();
      if (isNewRequest || driverResponse == null) {
        final features = <String>[];
        if (state.searchFilter.isSecurelyGated)
          features.add(AppText.SECURELY_GATED);
        if (state.searchFilter.isCctv) features.add(AppText.CCTV);
        if (state.searchFilter.isDisabledAccess)
          features.add(AppText.DISABLED_ACCESS);
        if (state.searchFilter.isLighting) features.add(AppText.LIGHTING);
        if (state.searchFilter.isElectricVehicleCharging)
          features.add(AppText.ELECTRIC_VEHICLE_CHARGING);
        if (state.searchFilter.isAirportTransfers)
          features.add(AppText.AIRPORT_TRANSFERS);

        if (state.searchFilter.isSheltered) features.add(AppText.SHELTERED);
        if (state.searchFilter.isWifi) features.add(AppText.WIFI);
        if (state.searchFilter.isCarPark) features.add(AppText.CAR_PARK_LOT);
        final parkingTypes = <String>[];
        if (state.searchFilter.isDriveway) parkingTypes.add(AppText.DRIVEWAY);
        if (state.searchFilter.isGarage) parkingTypes.add(AppText.GARAGE);
        if (state.searchFilter.isLandGrassParking)
          parkingTypes.add(AppText.LAND_GRASS_PARKING);
        if (state.searchFilter.isOnStreet) parkingTypes.add(AppText.ON_STREET);



        response = await _sharedWebService.driverHome(
            lat,
            lng,
            features,
            parkingTypes,
            state.lastConnectorIndex == 0 ? [] : [evTypes[state.lastConnectorIndex-1]],
            user.id,
            user.accessToken.toString(),startTime,endTime);

        driverResponse = response;
        setDriverMarkers(driverResponse!.parkingSpaces, latitude, longitude, globalKey);
      } else {
        final features = <String>[];
        if (state.searchFilter.isSecurelyGated)
          features.add(AppText.SECURELY_GATED);
        if (state.searchFilter.isCctv) features.add(AppText.CCTV);
        if (state.searchFilter.isDisabledAccess)
          features.add(AppText.DISABLED_ACCESS);
        if (state.searchFilter.isLighting) features.add(AppText.LIGHTING);
        if (state.searchFilter.isElectricVehicleCharging)
          features.add(AppText.ELECTRIC_VEHICLE_CHARGING);
        if (state.searchFilter.isAirportTransfers)
          features.add(AppText.AIRPORT_TRANSFERS);

        if (state.searchFilter.isSheltered) features.add(AppText.SHELTERED);
        if (state.searchFilter.isWifi) features.add(AppText.WIFI);
        if (state.searchFilter.isCarPark) features.add(AppText.CAR_PARK_LOT);
        final parkingTypes = <String>[];
        if (state.searchFilter.isDriveway) parkingTypes.add(AppText.DRIVEWAY);
        if (state.searchFilter.isGarage) parkingTypes.add(AppText.GARAGE);
        if (state.searchFilter.isLandGrassParking)
          parkingTypes.add(AppText.LAND_GRASS_PARKING);
        if (state.searchFilter.isOnStreet) parkingTypes.add(AppText.ON_STREET);
        response = await _sharedWebService.driverHome(
            lat,
            lng,
            features,
            parkingTypes,
            state.lastConnectorIndex == 0
                ? []
                : [evTypes[state.lastConnectorIndex]],
            user.id,
            user.accessToken.toString(),startTime,endTime);
        driverResponse = response;
        setDriverMarkers(
            driverResponse!.parkingSpaces, latitude, longitude, globalKey);

        /*response = driverResponse!;
        driverResponse = response;
        setDriverMarkers(driverResponse!.parkingSpaces, latitude, longitude);*/
      }
    } catch (e) {
      emit(
          state.copyWith(dataEvent: Error(exception: Exception(e.toString()))));
    }
  }

  Future<void> updateMarkerCluster(final double currentZoom,
      {bool isFromBloc = false}) async {
    currentMapZoomLevel = currentZoom;
    final clusterManager = _clusterManager;
    if (clusterManager == null) return;
    if (!isFromBloc)
      emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap));

    final updatedMarkers = await MapHelper.getClusterMarkers(
        clusterManager,
        currentZoom,
        Constants.COLOR_SECONDARY,
        Constants.COLOR_ON_SECONDARY,
        size, (lat, lng) {



      // _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: currentZoom + 4)));
      _googleMapController?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: currentZoom + 4)));
    });

    if (updatedMarkers.map((e) => e.markerId.value).join() ==
        this.markers.map((e) => e.markerId.value).join())
      return;
    else
      this.markers.clear();

    this.markers.addAll(updatedMarkers);
    if (!isFromBloc)
      emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap));
  }



  Future<BitmapDescriptor> _createCustomMarkerBitmap(
      String price,
      bool markerTaped,
      bool isEv,
      bool isSpaceBooked,
      GlobalKey<State<StatefulWidget>> globalKey) async {


    TextPainter tp = new TextPainter(
        text: TextSpan(),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    TextPainter tp2 = new TextPainter(
        text: TextSpan(),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    tp2.text =  TextSpan(
      text: '\$',
      style: TextStyle(
          fontSize: Platform.isIOS?26:16,
          color: Constants.COLOR_ON_PRIMARY,
          letterSpacing: 0.5,
          fontFamily: Constants.GILROY_SEMI_BOLD),
    );

    tp.text = isSpaceBooked
        ? TextSpan(
      text: 'Booked',
      style: TextStyle(
          fontSize: size.width * 0.055,
          color: Constants.COLOR_ON_PRIMARY,
          letterSpacing: 0.5,
          fontFamily: Constants.GILROY_BOLD),
    )
        : TextSpan(
        text: '',
        style: TextStyle(
            fontSize: 24,
            color: Constants.COLOR_ON_PRIMARY,
            height: 0.9,
            fontFamily: Constants.GILROY_SEMI_BOLD),
        children: [
          TextSpan(
              text: price,
              style: TextStyle(
                  fontSize: Platform.isIOS?34:24,
                  fontFeatures: [FontFeature.subscripts()],
                  fontFamily: Constants.GILROY_BOLD,
                  color: Constants.COLOR_ON_PRIMARY)),
          TextSpan(
              text: '\nTotal\n',
              style: TextStyle(
                  fontSize: Platform.isIOS?26:16,
                  fontFamily: Constants.GILROY_MEDIUM,
                  color: Constants.COLOR_ON_PRIMARY))
        ]);



    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    final paint = Paint();
    // int imageWidth = size.width ~/ 2.8;
    // int imageHeight = size.height ~/ 6.4;
    int imageWidth=0;
    int imageHeight=0;

    if(Platform.isIOS){
      imageWidth = getProportionateScreenWidth(215, size.width).toInt();
      imageHeight = getProportionateScreenHeight(210, size.height).toInt();
    }else if(Platform.isAndroid){
      imageWidth = getProportionateScreenWidth(140, size.width).toInt();
      imageHeight = getProportionateScreenHeight(135, size.height).toInt();
    }



    final image;
    if (isSpaceBooked) {
      var markerImage = isEv ? 'assets/marker_ev_booked.png' : 'assets/marker_booked.png';
      // var markerImage = isEv ? 'assets/marker_bolt.png' : 'assets/marker.png';
      image = await markerImage.imageFromAsset(imageWidth, imageHeight);
    } else {
      if (!markerTaped) {
        var markerImage = isEv ? 'assets/marker_bolt.png' : 'assets/marker.png';
        image = await markerImage.imageFromAsset(imageWidth, imageHeight);
      } else {
        var markerImage = isEv
            ? 'assets/marker_selected_bolt.png'
            : 'assets/marker_selected.png';
        image = await markerImage.imageFromAsset(imageWidth, imageHeight);
      }
    }
    c.drawImage(image, Offset(0, 0), paint);

    tp.layout();
    tp2.layout();
    var height = isSpaceBooked ? 2.5 : 2.0;

    double textLayoutOffsetX = 0.0;
    double textLayoutOffsetY = 0.0;

    if(Platform.isIOS){
      textLayoutOffsetX = (imageWidth - tp.width) / 1.9;
      textLayoutOffsetY = ((imageHeight - tp.height) / height+3);
    }else if(Platform.isAndroid){
      textLayoutOffsetX = (imageWidth - tp.width) / 2.0;
      textLayoutOffsetY = ((imageHeight - tp.height) / height);
    }



    double textLayoutOffsetX1 = 0.0;
    double textLayoutOffsetY1 = 0.0;

    if(Platform.isIOS){
      textLayoutOffsetX1 = (imageWidth - tp.width) / 2.35;
      textLayoutOffsetY1 = ((imageHeight - tp.height) / height-6);
    }else if(Platform.isAndroid){
      textLayoutOffsetX1 = (imageWidth - tp.width) / 2.5;
      textLayoutOffsetY1 = ((imageHeight - tp.height) / height-4);
    }

    tp.paint(c, new Offset(textLayoutOffsetX, textLayoutOffsetY));
    tp2.paint(c, new Offset(textLayoutOffsetX1, textLayoutOffsetY1));

    // Do your painting of the custom icon here, including drawing text, shapes, etc.

    Picture p = recorder.endRecording();

    ByteData? pngBytes = await (await p.toImage(size.width ~/ 2, size.height ~/ 6)).toByteData(format: ImageByteFormat.png);
    if(Platform.isIOS){
      pngBytes = await (await p.toImage(size.width.toInt(), size.height.toInt())).toByteData(format: ImageByteFormat.png);
    }else if(Platform.isAndroid){
      pngBytes = await (await p.toImage(size.width ~/ 2, size.height ~/ 6)).toByteData(format: ImageByteFormat.png);
    }




    Uint8List data = Uint8List.view(pngBytes!.buffer);
    return BitmapDescriptor.fromBytes(data);

    /*ui.Image images = await boundary.toImage();
    ByteData? byteData =
        await images.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());*/
  }

  Future<ParkingSpaceDetail?> requestParkingSpace(int id) async {
    final previousParkingSpace = await _parkingSpaceCollection.get('$id');
    if (previousParkingSpace != null) return previousParkingSpace;

    try {
      final User? user = await _sharedPrefHelper.user();
      if (user == null) return null;
      final parkingSpace = await _sharedWebService.parkingSpace(
          id, user.id, user.accessToken.toString());
      _parkingSpaceCollection.insert(parkingSpace);
      debugPrintThrottled(parkingSpace.toString());

      return parkingSpace;
    } catch (e) {
      return null;
    }
  }

  Future<EventSearchApiModel> requestEvents(String city) async {
    try {
      final eventSearch = await _sharedWebService.getNearByEvents(city);
      return eventSearch;
    } catch (e) {
      return EventSearchApiModel.withError("$e");
    }
  }

  @override
  Future<void> close() async {
    _googleMapController?.dispose();
    await _parkingSpaceCollection.clear();
    return super.close();
  }

  void seUpdateMarkerData(
      List<ParkingSpace> parkingSpaces,
      VoidCallback markerTap,
      GlobalKey<State<StatefulWidget>> globalKey) async {


    final markers = await Future.wait(parkingSpaces.map((e) async {
      final bitmapDescriptor = await _createCustomMarkerBitmap(
          e.hostPrice(), e.markerTaped, e.isEv, e.isSpaceBooked, globalKey);

      this.circles.clear();
      this.circles.add(Circle(
        circleId: CircleId('circleId'),
        center: LatLng(e.latitude, e.longitude),
        fillColor: Colors.blue.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
        radius: 2000,
      ));
      return Marker(
          anchor: const Offset(0.5, 0.5),
          consumeTapEvents: true,
          markerId: MarkerId(e.id),
          position: LatLng(e.latitude, e.longitude),
          icon: bitmapDescriptor,
          onTap: () async {
            parkingSpaces.forEach((element) {
              if (element.markerTaped) element.markerTaped = false;
            });
            e.markerTaped = true;

            markerTap.call();
            seUpdateMarkerData(parkingSpaces, markerTap, globalKey);
            emit(state.copyWith(parkingTapId: e.id));
            await Future.delayed(const Duration(milliseconds: 500));
            emit(state.copyWith(parkingTapId: ''));
          },
          zIndex: 90);
    }));

    final markers2 = await Future.wait(parkingSpaces.map((e) async {
      final bitmapDescriptor = await _createCustomMarkerBitmap(
          e.hostPrice(), e.markerTaped, e.isEv, e.isSpaceBooked, globalKey);

      this.circles.clear();
      this.circles.add(Circle(
        circleId: CircleId('circleId'),
        center: LatLng(e.latitude, e.longitude),
        fillColor: Colors.blue.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
        radius: 2000,
      ));
      return MapMarker(
        id: e.id,
        position: LatLng(e.latitude, e.longitude),
        icon: bitmapDescriptor,
        onTap: () async {
          parkingSpaces.forEach((element) {
            if (element.markerTaped) element.markerTaped = false;
          });
          e.markerTaped = true;

          markerTap.call();
          seUpdateMarkerData(parkingSpaces, markerTap, globalKey);
          emit(state.copyWith(parkingTapId: e.id));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(state.copyWith(parkingTapId: ''));
        },
      );
    }));

    /*
      final markers = await Future.wait(response.parkingSpaces.map((e) async {
        final bitmapDescriptor = await _createCustomMarkerBitmap(e.hostPrice());
        this.circles.clear();
        this.circles.add(Circle(
          circleId: CircleId('circleId'),
          center: LatLng(e.latitude, e.longitude),
          fillColor: Colors.blue.shade100.withOpacity(0.5),
          strokeColor: Colors.blue.shade100.withOpacity(0.1),
          radius: 3000,
        ));

        return Marker(
            markerId: MarkerId(e.id),
            position: LatLng(e.latitude, e.longitude),
            icon: bitmapDescriptor,
            zIndex: 90);
      }));*/
    // this.markers.removeWhere((element) => element.markerId != MarkerId(_USER_CURRENT_LOCATION_MARKER_ID));

    this._clusterManager = (await MapHelper.initClusterManager(markers2, MIN_CLUSTER_ZOOM, MAX_CLUSTER_ZOOM));
    await updateMarkerCluster(_ZOOM_LEVEL, isFromBloc: true);
    this.markers.clear();
    this.markers.addAll(markers);

    var firstMarker;
    if (markers.isNotEmpty) {
      firstMarker = markers[0];
    }

    if (markers.isNotEmpty) {
      for (int i = 0; i < parkingSpaces.length; i++) {
        if (parkingSpaces[i].markerTaped) {
          firstMarker = markers[i];
        }
      }


      _googleMapController?.getZoomLevel().then((value) {
        _ZOOM_LEVEL = value;
        animateCamera(firstMarker.position.latitude, firstMarker.position.longitude);
      });

    }

    emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap, dataEvent: Data(data: parkingSpaces)));


  }

  void setDriverMarkers(List<ParkingSpace> parkingSpaces, double latitude,
      double longitude, GlobalKey<State<StatefulWidget>> globalKey) async {


    final markers = await Future.wait(parkingSpaces.map((e) async {
      final bitmapDescriptor = await _createCustomMarkerBitmap(
          e.hostPrice(), e.markerTaped, e.isEv, e.isSpaceBooked, globalKey);

      this.circles.clear();
      this.circles.add(Circle(
        circleId: CircleId('circleId'),
        center: LatLng(e.latitude, e.longitude),
        fillColor: Colors.blue.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
        radius: 2000,
      ));
      return Marker(
        anchor: const Offset(0.5, 0.5),
        consumeTapEvents: true,
        markerId: MarkerId(e.id),
        position: LatLng(e.latitude, e.longitude),
        icon: bitmapDescriptor,
        onTap: () async {
          parkingSpaces.forEach((element) {
            if (element.markerTaped) element.markerTaped = false;
          });
          e.markerTaped = true;

          // markerTap.call();
          setDriverMarkers(parkingSpaces, latitude, longitude, globalKey);

          emit(state.copyWith(parkingTapId: e.id));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(state.copyWith(parkingTapId: ''));
        },
      );
    }));

    final markers2 = await Future.wait(parkingSpaces.map((e) async {
      final bitmapDescriptor = await _createCustomMarkerBitmap(e.hostPrice(), e.markerTaped, e.isEv, e.isSpaceBooked, globalKey);
      this.circles.clear();
      this.circles.add(Circle(
        circleId: CircleId('circleId'),
        center: LatLng(e.latitude, e.longitude),
        fillColor: Colors.blue.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
        radius: 2000,
      ));
      return MapMarker(
        id: e.id,
        position: LatLng(e.latitude, e.longitude),
        icon: bitmapDescriptor,
      );
    }));



    this._clusterManager = (await MapHelper.initClusterManager(markers2, MIN_CLUSTER_ZOOM, MAX_CLUSTER_ZOOM));
    await updateMarkerCluster(_ZOOM_LEVEL, isFromBloc: true);
    this.markers.clear();
    this.markers.addAll(markers);

    var firstMarker;
    if (markers.isNotEmpty) {
      firstMarker = markers[0];
    }

    if (markers.isNotEmpty) {
      for (int i = 0; i < parkingSpaces.length; i++) {
        if (parkingSpaces[i].markerTaped) {
          firstMarker = markers[i];
        }
      }


      _googleMapController?.getZoomLevel().then((value) {
        _ZOOM_LEVEL = value;
        animateCamera(firstMarker.position.latitude, firstMarker.position.longitude);
      });

    }

    emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap, dataEvent: Data(data: parkingSpaces)));



    /* final currentDatetime = Constants.currentDatetime;
    DateTime parkingFrom = currentDatetime.add(Duration(minutes: 15));
    DateTime parkingUntil = parkingFrom.add(Duration(hours: 1));
    final markers = await Future.wait(parkingSpaceList.map((e) async {
      final bitmapDescriptor = await _createCustomMarkerBitmap(
          e.getCalculatedPrice(parkingUntil, parkingFrom),
          e.markerTaped,
          e.isEv,
          e.isSpaceBooked,
          globalKey);
      return MapMarker(
          id: e.id,
          position: LatLng(e.latitude, e.longitude),
          icon: bitmapDescriptor,
          isCluster: false,
          onTap: () async {
            parkingSpaceList.forEach((element) {
              if (element.markerTaped) {
                element.markerTaped = false;
              }
            });

            e.markerTaped = true;

            setDriverMarkers(parkingSpaceList, latitude, longitude, globalKey);

            emit(state.copyWith(parkingTapId: e.id));
            await Future.delayed(const Duration(milliseconds: 500));
            emit(state.copyWith(parkingTapId: ''));
          });
    }));

    var key = UniqueKey();
    this.circles.clear();
    this.circles.add(Circle(
          circleId: CircleId('circleId'),
          center: LatLng(latitude, longitude),
          fillColor: Colors.blue.shade100.withOpacity(0.5),
          strokeColor: Colors.blue.shade100.withOpacity(0.1),
          radius: 3000,
        ));

    markers.add(MapMarker(
      id: key.toString(),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      isCluster: false,
    ));

    if (markers.length == 1) {
      ScaffoldMessenger.of(GlobalVariable.navigatorState.currentContext!)
          .showSnackBar(SnackBar(
        elevation: 2,
        content: RichText(
            text: TextSpan(children: [
          TextSpan(
              text:
                  "Sorry, we don\'t have a space available for you currrently. Please leave your feedback"),
          TextSpan(
              style: TextStyle(color: Colors.blue),
              text: " here ",
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  var url = "https://rent2park.com/contact-us/";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                }),
          TextSpan(
              text: "or check back later as we are always adding new spaces."),
        ])),
        duration: Duration(seconds: 5),
      ));
    }
    this._clusterManager = (await MapHelper.initClusterManager(markers, MIN_CLUSTER_ZOOM, MAX_CLUSTER_ZOOM));
    await updateMarkerCluster(_ZOOM_LEVEL, isFromBloc: true);
    // this.markers.clear();
    // this.markers.addAll(markers);

    var firstMarker;
    if (markers.isNotEmpty) {
      firstMarker = markers[0];
    }

    if (markers.isNotEmpty) {
      for (int i = 0; i < parkingSpaceList.length; i++) {
        if (parkingSpaceList[i].markerTaped) {
          firstMarker = markers[i];
        }
      }

      _googleMapController?.getZoomLevel().then((value) {
        _ZOOM_LEVEL = value;
        animateCamera(firstMarker.position.latitude, firstMarker.position.longitude);
      });


    }

    emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap, dataEvent: Data(data: parkingSpaceList)));
    */
    ///herer
    /*
    this._clusterManager = (await MapHelper.initClusterManager(markers, MIN_CLUSTER_ZOOM, MAX_CLUSTER_ZOOM));
    await updateMarkerCluster(_ZOOM_LEVEL, isFromBloc: true);
    emit(state.copyWith(isNeedReloadMap: !state.isNeedReloadMap, dataEvent: Data(data: '')));

    var lat;
    var long;

    lat = latitude;
    long = longitude;

    parkingSpaceList.forEach((element) {
      if (element.markerTaped) {
        lat = element.latitude;
        long = element.longitude;
      }
    });
    animateCamera(lat, long);*/

    /* _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat, long),
            zoom: currentMapZoomLevel == 0.0 ? 4.0 : currentMapZoomLevel)));*/
  }

// void showParkingSpaces(HomeNavigationScreenBloc bloc, BuildContext context, BottomSheetHelper bottomSheetHelper) {
//   List<ParkingSpaceSlot> parkingSpaceSlot = [];
//   List<Reviews> reviews = [];
//   ParkingSpaceDetail parkingSpace = ParkingSpaceDetail(
//       id: "0",
//       country: "country",
//       address: "address",
//       latitude: 0,
//       longitude: 0,
//       numberOfSpaces: 2,
//       isReservable: true,
//       parkingType: "parkingType",
//       vehicleSize: "vehicleSize",
//       hasHeightLimits: true,
//       isRequiredPermit: true,
//       isRequiredKey: true,
//       spaceInformation: "spaceInformation",
//       spaceInstruction:
//       "You can't get better than this space! Only 5 mins from the The Parker Venue, restaurants & much more",
//       locationOffers: [
//         "Wifi",
//         "Charging",
//       ],
//       isAutomated: true,
//       hourlyPrice: 20,
//       dailyPrice: 200,
//       weeklyPrice: 400,
//       monthlyPrice: 900,
//       isMaximumBookingPrice: false,
//       parkingSpacePhotos: [
//         "https://www.thesun.co.uk/wp-content/uploads/2017/10/nintchdbpict000309102797.jpg?strip=all&w=960"
//       ],
//       slots: parkingSpaceSlot,
//       appUser: null,
//       totalBookings: 2,
//       countryCode: "countryCode",
//       evTypes: "evTypes",
//       reviews: reviews,
//       active: 0);
//   Future.delayed(const Duration(milliseconds: 100)).then((_) {
//     bottomSheetHelper.injectContext(context);
//     bottomSheetHelper.showParkingDetailBottomSheet(
//         parkingSpace, bloc.state.locationData, parkingSpace.reviews);
//   });
// }

}
