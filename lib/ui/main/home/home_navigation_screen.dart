import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:intl/intl.dart';

import 'package:location/location.dart';
import 'package:rent2park/data/location_sheet_selection.dart';
import 'package:rent2park/ui/events/EventsDetails.dart';
import 'package:rent2park/ui/favourites/FavouritesSpaces.dart';
import 'package:rent2park/util/SizeConfig.dart';

import '../../../data/EventSearchApiModel.dart';
import '../../../data/backend_responses.dart';
import '../../../data/material_dialog_content.dart';
import '../../../data/meta_data.dart';
import '../../../data/snackbar_message.dart';
import '../../../data/user_type.dart';
import '../../../helper/bottom_sheet_helper.dart';
import '../../../helper/material_dialog_helper.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../helper/snackbar_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../../util/extensions.dart';
import '../../../util/text_upper_case_formatter.dart';
import '../main_screen_bloc.dart';
import '../main_screen_state.dart';
import 'home_navigation_screen_bloc.dart';
import 'home_navigation_screen_state.dart';

class HomeNavigationScreen extends StatefulWidget {
  final PageStorageKey<String> key;

  const HomeNavigationScreen({required this.key}) : super(key: key);

  @override
  _HomeNavigationScreenState createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  late VoidCallback onMarkerTap;
  late HomeNavigationScreenBloc bloc;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  var formattedEndTime = "";
  var currentYear = "";

  var selectedDateTime = getAdditionOfTime(DateTime.now(), 15);
  var selectedEndDateTime = DateTime.now();

  var parkingSlotTimePicker = getAdditionOfTime(DateTime.now(), 15);
  var parkingSlotStartTime = TextEditingController();
  var parkingSlotEndTime = TextEditingController();
  var dateSelection = TextEditingController();

  final BottomSheetHelper _bottomSheetHelper = BottomSheetHelper.instance;
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;
  final Location _location = Location();

  final TextEditingController searchEditingController = TextEditingController();

  CancelableOperation<places.PlacesSearchResponse>? placesOperation;
  Function tempStateSetter = () {};
  String type = '';
  List<Widget> items = [];
  final places.GoogleMapsPlaces mapsPlaces =
      places.GoogleMapsPlaces(apiKey: Constants.GOOGLE_MAP_PLACES_API_KEY);

  PersistentBottomSheetController? _persistedBottomSheetController;
  Function searchFieldStateSetter = () {};
  TextField? searchTextField;

  bool showMoreEvents = false;

  bool showMoreAirports = false;

  bool requestedNearByData = false;

  String parkingSlotEndTimeSelected = "";

  bool parkingSlotClicked = false;

  var mapZoomFirstTime = true;

  final GlobalKey globalKey = GlobalKey();

  bool showEvTypeClicked = false;

  var currentLat = 0.0;
  var currentLng = 0.0;

  void _requestParkingSpace(int id) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.REQUESTING_PARKING_DETAIL);
    final bloc = context.read<HomeNavigationScreenBloc>();
    final parkingSpace = await bloc.requestParkingSpace(id);
    _dialogHelper.dismissProgress();
    if (parkingSpace == null) {
      // _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _requestParkingSpace(id));
      return;
    } else {
      // _dialogHelper.dismissProgress();
      showParkingSpaces(bloc, parkingSpace);
    }
  }

  void _requestEvents(String city) async {
    requestedNearByData = true;
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog("Getting Near By Details");
    final eventNearBy = await bloc.requestEvents(city);
    _dialogHelper.dismissProgress();
    if (eventNearBy == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _requestEvents(city));
      return;
    } else {
      type = 'Airports';
      placesOperation?.cancel();
      placesOperation = CancelableOperation.fromFuture(
          mapsPlaces.searchByText(type, radius: 10000, type: type));
      final placesResponse = await placesOperation?.value;
      if (placesResponse == null) return;
      bloc.updateSearchAirports(placesResponse.results);
      bloc.updateEvents(eventNearBy.events);
    }
  }

  void _handleEnableLocationScenarios() async {
    final requestServiceRequestValue = await _location.requestService();
    if (!requestServiceRequestValue) {
      final locationPermissionContent = MaterialDialogContent(
          title: AppText.ENABLE_LOCATION,
          message: AppText.ENABLE_LOCATION_CONTENT,
          positiveText: AppText.TRY_AGAIN);
      _dialogHelper
        ..injectContext(context)
        ..showMaterialDialogWithContent(
            locationPermissionContent, () => _handleEnableLocationScenarios());
    } else {
      if (Platform.isAndroid) {
        final locationData = await _location.getLocation();
        context
            .read<HomeNavigationScreenBloc>()
            .updateLocation(globalKey, locationData, () {});
        getNearByData(locationData.latitude, locationData.longitude);
      } else if (Platform.isIOS) {
        var position = await Geolocator.getCurrentPosition();
        var lastPosition = await Geolocator.getLastKnownPosition();
        getNearByData(lastPosition?.latitude, lastPosition?.longitude);
        context
            .read<HomeNavigationScreenBloc>()
            .updateLocationIOS(globalKey, lastPosition!, () {});
      }
    }
  }

  void _handleDeniedLocationPermissionScenarios() async {
    final permissionRequestStatus = await _location.requestPermission();
    if (permissionRequestStatus == PermissionStatus.denied) {
      final locationPermissionContent = MaterialDialogContent(
          title: AppText.LOCATION_PERMISSION_REQUIRED,
          message: AppText.LOCATION_PERMISSION_REQUIRED_CONTENT,
          positiveText: AppText.TRY_AGAIN);
      _dialogHelper
        ..injectContext(context)
        ..showMaterialDialogWithContent(locationPermissionContent,
            () => _handleDeniedLocationPermissionScenarios());
    } else if (permissionRequestStatus == PermissionStatus.granted ||
        permissionRequestStatus == PermissionStatus.grantedLimited) {
      final isLocationServiceEnabled = await _location.serviceEnabled();

      if (!isLocationServiceEnabled)
        _handleEnableLocationScenarios();
      else {
        if (Platform.isAndroid) {
          final locationData = await _location.getLocation();
          context
              .read<HomeNavigationScreenBloc>()
              .updateLocation(globalKey, locationData, () {});
          getNearByData(locationData.latitude, locationData.longitude);
        } else if (Platform.isIOS) {
          var position = await Geolocator.getCurrentPosition();
          var lastPosition = await Geolocator.getLastKnownPosition();
          getNearByData(lastPosition?.latitude, lastPosition?.longitude);
          context
              .read<HomeNavigationScreenBloc>()
              .updateLocationIOS(globalKey, lastPosition!, () {});
        }
      }
    } else
      _showLocationDeniedForeverSnackbar();
  }

  void _showLocationDeniedForeverSnackbar() {
    _snackbarHelper
      ..injectContext(context)
      ..showSnackbar(
          snackbar: SnackbarMessage.error(
              message:
                  AppText.ENABLE_APP_LOCATION_PERMISSION_FROM_THE_SETTINGS));
  }

  @override
  void initState() {
    currentYear = DateFormat('yyyy').format(DateTime.now());
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      final permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied)
        _handleDeniedLocationPermissionScenarios();
      else if (permissionStatus == PermissionStatus.deniedForever)
        _showLocationDeniedForeverSnackbar();
      else {
        final isLocationServiceEnabled = await _location.serviceEnabled();

        if (!isLocationServiceEnabled)
          _handleEnableLocationScenarios();
        else {
          if (Platform.isAndroid) {
            final locationData = await _location.getLocation();
            context
                .read<HomeNavigationScreenBloc>()
                .updateLocation(globalKey, locationData, () {});
            getNearByData(locationData.latitude, locationData.longitude);
          } else if (Platform.isIOS) {
            var position = await Geolocator.getCurrentPosition();
            var lastPosition = await Geolocator.getLastKnownPosition();
            getNearByData(lastPosition?.latitude, lastPosition?.longitude);
            context
                .read<HomeNavigationScreenBloc>()
                .updateLocationIOS(globalKey, lastPosition!, () {});
          }
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bloc = context.read<HomeNavigationScreenBloc>();
    var mainScreenBloc = context.read<MainScreenBloc>();
    final blocMain = context.read<MainScreenBloc>();
    final scaffoldState = Scaffold.of(context);
    setSpaceTimes();
    final locationData = bloc.state.locationData;
    final lat = bloc.lastLat ?? locationData.latitude;
    final lng = bloc.lastLng ?? locationData.longitude;


    if (_sharedPrefHelper.isSpaceEditedHost() == true) {
      _sharedPrefHelper.updateParkingSpaceEditedHost(false);
      bloc.updateSpaceUpdatedCheckedHost(true);
      bloc.hostHome(globalKey, () {});
    }

    items = searchEditingController.text.isEmpty
        ? [
            /*    ListTile(
                onTap: () {
                  // Navigator.pop(
                  //     context);
                  final currentLocation = bloc.state.locationData;
                  final double? lat = currentLocation.latitude;
                  final double? lng = currentLocation.longitude;
                  bloc.markers = {
                    Marker(
                        markerId: MarkerId('Location'),
                        infoWindow: InfoWindow(title: 'Current Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                        position: LatLng(lat!, lng!))
                  };
                  if (lat == null || lng == null || lat == 0.0 || lng == 0.0)
                    return;
                  bloc.updateSheetSelection.call(LocationSheetSelection(
                      name: AppText.CURRENT_LOCATION, lat: lat, lng: lng));
                },
                dense: true,
                horizontalTitleGap: 6,
                minVerticalPadding: 15,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                leading: const Image(
                    image: AssetImage('assets/green_current_location_icon.png'),
                    width: 22,
                    height: 22),
                title: const Text(AppText.CURRENT_LOCATION,
                    style: TextStyle(
                        color: Constants.COLOR_ON_SURFACE,
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 15)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 20, color: Constants.colorDivider)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                    thickness: 0.5,
                    color: Constants.colorDivider,
                    height: 0.5)),
            // Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Divider(thickness: 0.5, color: Constants.colorDivider, height: 0.5)),
            // ListTile(
            //   onTap: () {
            //     type = 'Events';
            //     searchFieldStateSetter(() => searchEditingController.text = 'Events');
            //     if (searchTextField != null) searchTextField?.onChanged?.call('Events');
            //   },
            //   dense: true,
            //   horizontalTitleGap: 10,
            //   contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            //   leading: const Image(image: AssetImage('assets/green_event_ticked_icon.png'), width: 24, height: 24),
            //   title: const Text(AppText.EVENTS_NEARBY, style: textStyle),
            //   trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Constants.colorDivider),
            // ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                    thickness: 0.5, color: Constants.colorDivider, height: 0.5))*/
          ]
        : [];

    return WillPopScope(
      onWillPop: () async {

        if (bloc.state.showSuggestions) {
          if (showMoreEvents) {
            showMoreEvents = false;
          } else if (showMoreAirports) {
            showMoreAirports = false;
          } else if (requestedNearByData) {
            requestedNearByData = false;
          } else {
            bloc.state.showSuggestions = false;
          }
          setState(() {});
        } else {
          bloc.showFilterView(false);
          Navigator.of(context).pop();
        }

        return false;
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
            buildWhen: (previous, current) {
              return previous.isNeedReloadMap != current.isNeedReloadMap;
            },
            builder: (_, state) {
              if (state.showSpaceList) {
                // showParkingSpaces(bloc);
              }
              return GoogleMap(
                  initialCameraPosition: bloc.cameraPosition,
                  mapToolbarEnabled: false,
                  buildingsEnabled: false,
                  compassEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: bloc.markers,
                  circles: bloc.circles,
                  zoomControlsEnabled: false,
                  onCameraMove: (position) {
                    bloc.updateMarkerCluster(position.zoom);
                  },
                  onMapCreated: (controller) =>
                      bloc.updateMapController(controller));
            },
          ),
          BlocListener<MainScreenBloc, MainScreenState>(
              listener: (_, state) {
                bloc.state.lastConnectorIndex = 0;
                bloc.updateEvSwitch(false);
                final locationData = bloc.state.locationData;
                final lat = bloc.lastLat ?? locationData.latitude;
                final lng = bloc.lastLng ?? locationData.longitude;
                bloc.markers = {
                  Marker(
                      markerId: MarkerId('Location'),
                      infoWindow: InfoWindow(title: 'Current Location'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRose),
                      position: LatLng(lat!, lng!))
                };
                if (lat == 0.0 || lng == 0.0) return;

                if (state.userType == UserType.driver) {
                  bloc.animateCamera(lat, lng);
                  bloc.seUpdateMarkerData([], () {}, globalKey);
                  // bloc.driverHome(globalKey, lat, lng, isNewRequest: false);
                } else if (state.userType == UserType.host)
                  bloc.hostHome(globalKey, () {});
              },
              listenWhen: (previous, current) =>
                  previous.userType != current.userType,
              child: BlocBuilder<HomeNavigationScreenBloc,
                  HomeNavigationScreenState>(
                builder: (_, stateIndex) => stateIndex.showSuggestions ||
                        stateIndex.isFilterShow ||
                        stateIndex.showDateTimeView
                    ? Positioned(
                        left: 28,
                        top: bloc.state.showSuggestions ||
                                bloc.state.isFilterShow ||
                                stateIndex.showDateTimeView
                            ? 45
                            : 75,
                        child: GestureDetector(
                          onTap: () async {
                            searchEditingController.text = "";
                            bloc.updateSearchResults([]);
                            bloc.showSuggestions(false);
                            if (stateIndex.isFilterShow) {
                              bloc.showFilterView(false);
                              Navigator.of(context).pop();
                            }

                            showMoreEvents = false;
                            showMoreAirports = false;
                          },
                          child: PhysicalModel(
                            color: Constants.COLOR_SURFACE,
                            shadowColor: Constants.COLOR_PRIMARY,
                            shape: BoxShape.circle,
                            elevation: 10,
                            child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Constants.COLOR_BACKGROUND),
                                padding: const EdgeInsets.all(4),
                                child: ClipOval(
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: SvgPicture.asset(
                                          "assets/search_close_icon.svg",
                                          height: 20,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                      )
                    : Positioned(
                        left: 28,
                        top: bloc.state.showSuggestions ||
                                bloc.state.isFilterShow ||
                                stateIndex.showDateTimeView
                            ? 45
                            : 75,
                        child: GestureDetector(
                          onTap: () async {
                            if (_persistedBottomSheetController != null) {
                              _persistedBottomSheetController?.close();
                              _persistedBottomSheetController = null;
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                            }
                            FocusScope.of(context).unfocus();
                            scaffoldState.openDrawer();
                          },
                          child: PhysicalModel(
                            color: Constants.COLOR_SURFACE,
                            shadowColor: Constants.COLOR_PRIMARY,
                            shape: BoxShape.circle,
                            elevation: 10,
                            child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Constants.COLOR_SURFACE),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.settings_rounded,
                                    color: Constants.COLOR_PRIMARY, size: 22)),
                          ),
                        ),
                      ),
              )),
          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
              builder: (_, stateIndex) {
                return Positioned(
                    right: 15,
                    top: stateIndex.showSuggestions ||
                            stateIndex.isFilterShow ||
                            stateIndex.showDateTimeView
                        ? 165
                        : 20,
                    child: Visibility(
                      visible: !stateIndex.showSuggestions,
                      child: GestureDetector(
                        onTap: () async {

                         /* if (bloc.state.isShowEvSpaces) {
                            bloc.state.lastConnectorIndex = 0;
                            bloc.state.isShowEvSpaces = false;
                            return;
                          }*/


                    _bottomSheetHelper.injectContext(context);
                          if (!stateIndex.evSwitch) {
                            _persistedBottomSheetController = _bottomSheetHelper
                                .showConnectorTypeBottomSheet(bloc, (val) {
                              showEvTypeClicked = true;
                              blocMain.changeColor(val);
                              final lat = bloc.lastLat ??
                                  bloc.state.locationData.latitude;
                              final lng = bloc.lastLng ??
                                  bloc.state.locationData.longitude;
                              if (lat == null ||
                                  lng == null ||
                                  lat == 0.0 ||
                                  lng == 0.0) return;
                              currentLat = lat;
                              currentLng = lng;
                              if(blocMain.state.userType==UserType.driver){
                              bloc.driverHome(globalKey, lat, lng);
                              }
                            });
                          } else if(stateIndex.evSwitch&&showEvTypeClicked){
                            showEvTypeClicked =false;
                            bloc.state.lastConnectorIndex = 0;
                            blocMain.changeColor(0);
                            if(blocMain.state.userType==UserType.driver){
                            bloc.driverHome(globalKey, currentLat, currentLng);
                            }
                          } else if(stateIndex.evSwitch){

                            Navigator.of(context).pop();
                          }else{
                            bloc.state.lastConnectorIndex = 0;
                            blocMain.changeColor(0);
                            bloc.driverHome(globalKey, currentLat, currentLng);
                          }

                          bloc.updateEvSwitch(!stateIndex.evSwitch);

                          _persistedBottomSheetController?.closed.whenComplete(() {
                            showEvTypeClicked = true;
                            // bloc.updateEvSwitch(false);
                            return _persistedBottomSheetController = null;
                          });



                        /*  if (!showEvTypeClosed) {
                            Navigator.of(context).pop();
                          }
                          bloc.state.lastConnectorIndex = 0;
                          bloc.driverHome(globalKey,currentLat, currentLng);
                          bloc.state.isShowEvSpaces = false;
                          bloc.updateEvSwitch(false);
                          setState(() {});
*/

                          /*if (bloc.state.isShowEvSpaces) {
                            bloc.state.lastConnectorIndex = 0;
                            bloc.state.isShowEvSpaces = false;
                            return;
                          }

                          if (_persistedBottomSheetController !=
                              null) return;
                          _bottomSheetHelper
                              .injectContext(context);

                          if (bloc.state.lastConnectorIndex ==
                              0) {
                            showEvTypeClosed = false;
                            _persistedBottomSheetController =
                                _bottomSheetHelper
                                    .showConnectorTypeBottomSheet(
                                    bloc, (val) {
                                  blocMain.changeColor(val);
                                  final lat = bloc.lastLat ??
                                      bloc.state.locationData
                                          .latitude;

                                  final lng = bloc.lastLng ??
                                      bloc.state.locationData
                                          .longitude;

                                  if (lat == null ||
                                      lng == null ||
                                      lat == 0.0 ||
                                      lng == 0.0) return;
                                  currentLat = lat;
                                  currentLng = lng;
                                  bloc.driverHome(
                                      globalKey, lat, lng);
                                });
                          } else if (bloc
                              .state.lastConnectorIndex !=
                              0) {
                            bloc.state.lastConnectorIndex = 0;

                            blocMain.changeColor(0);
                          }
                          _persistedBottomSheetController
                              ?.closed
                              .whenComplete(() {
                            showEvTypeClosed = true;
                            return _persistedBottomSheetController =
                            null;
                          });
                          state.isShowEvSpaces = true;
                          bloc.updateEvSwitch(true);
                          setState(() {});*/
                        },
                        child: BlocBuilder<HomeNavigationScreenBloc,
                            HomeNavigationScreenState>(
                          builder: (_, state) => PhysicalModel(
                            elevation: 10,
                            color: Constants.COLOR_SURFACE,
                            shadowColor: Constants.COLOR_PRIMARY,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Constants.COLOR_SURFACE,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/switch_icon.png',
                                    width: 22,
                                    height: 22,
                                    color: Constants.COLOR_PRIMARY,
                                  ),
                                  SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(AppText.EV,
                                        style: TextStyle(
                                            color: Constants.COLOR_PRIMARY,
                                            fontSize: 18,
                                            fontFamily:
                                                Constants.GILROY_MEDIUM)),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  state.evSwitch
                                      ? SvgPicture.asset("assets/ev_on.svg", height: 20)
                                      : Image.asset(
                                        "assets/ev_off.png",
                                        height: 20,
                                      )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
              }),

          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
            builder: (_, stateIndex) => Visibility(
                visible: stateIndex.showSuggestions ||
                    stateIndex.isFilterShow ||
                    stateIndex.showDateTimeView,
                child: Positioned(
                  left: 75,
                  right: 15,
                  top: stateIndex.showSuggestions ||
                          stateIndex.isFilterShow ||
                          stateIndex.showDateTimeView
                      ? 45
                      : 75,
                  child: PhysicalModel(
                    color: Constants.COLOR_SURFACE,
                    elevation: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: searchBarParkingSlotsView(bloc, stateIndex),
                  ),
                )),
          ),

          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
            builder: (_, stateIndex) {
              if (stateIndex.showSuggestions) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: PhysicalModel(
                    color: Constants.COLOR_GREY_200,
                    elevation: 10,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: showSuggestionsSheet(bloc, stateIndex),
                  ),
                );
              } else
                return SizedBox();
            },
          ),
          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
              builder: (_, state) => Positioned(
                    left: 75,
                    right: 15,
                    top: state.showSuggestions ||
                            state.isFilterShow ||
                            state.showDateTimeView
                        ? 45
                        : 75,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: PhysicalModel(
                            color: Constants.COLOR_SURFACE,
                            elevation: 10,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                            child: Container(
                              height: 38,
                              decoration: const BoxDecoration(
                                  color: Constants.COLOR_SURFACE,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  shape: BoxShape.rectangle),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('assets/search_icon.png',
                                      color: Constants.COLOR_PRIMARY,
                                      width: 22,
                                      height: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        bloc.showSuggestions(true);
                                        searchEditingController.text = "";
                                        selectedDateTime =
                                            nearestQuarter(DateTime.now());
                                        parkingSlotStartTime.text =
                                            getParkingSpaceFormattedDateTime(
                                                selectedDateTime);
                                        dateSelection.text =
                                            "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

                                        /*  if (state.packageSelected == "2") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 120);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "4") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 240);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "6") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 360);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "monthly") {
                                          parkingSlotStartTime.text = DateFormat('dd MMM').format(selectedDateTime);
                                          parkingSlotEndTime.text = "Monthly";
                                        } */

                                        if (state.packageSelected == "monthly") {
                                          parkingSlotStartTime.text = DateFormat(
                                                  'dd MMM')
                                              .format(DateTime.parse(state.parkingSpaceStartDateTime))
                                              .toString();
                                          parkingSlotEndTime.text = "Monthly";
                                        } else {
                                          var timeDifference = 0;

                                          if (state.parkingSpaceEndDateTime
                                              .isNotEmpty) {
                                            timeDifference = DateTime.parse(state
                                                    .parkingSpaceEndDateTime)
                                                .difference(selectedDateTime)
                                                .inMinutes;
                                          }
                                          if (timeDifference > 59) {
                                            selectedEndDateTime =
                                                DateTime.parse(state
                                                    .parkingSpaceEndDateTime);
                                            parkingSlotEndTime.text =
                                                getParkingSpaceFormattedDateTime(
                                                    selectedEndDateTime);
                                          } else {
                                            selectedEndDateTime =
                                                getAdditionOfTime(
                                                    selectedDateTime, 60);
                                            parkingSlotEndTime.text =
                                                getParkingSpaceFormattedDateTime(
                                                    selectedEndDateTime);
                                          }
                                        }
                                        bloc.updateParkingTimings(
                                            selectedDateTime.toString(),
                                            selectedEndDateTime.toString());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 1),
                                        child: BlocBuilder<
                                            HomeNavigationScreenBloc,
                                            HomeNavigationScreenState>(
                                          buildWhen: (previous, current) =>
                                              previous.showSuggestions !=
                                              current.showSuggestions,
                                          builder: (_, state) {
                                            return StatefulBuilder(
                                              builder: (_, stateSetter) {
                                                searchFieldStateSetter =
                                                    stateSetter;
                                                searchTextField = TextField(
                                                  enabled:
                                                      state.showSuggestions,
                                                  controller:
                                                      searchEditingController,
                                                  inputFormatters: [
                                                    UpperCaseTextFormatter()
                                                  ],
                                                  onChanged:
                                                      (String query) async {
                                                    placesOperation?.cancel();
                                                    placesOperation =
                                                        CancelableOperation
                                                            .fromFuture(mapsPlaces
                                                                .searchByText(
                                                                    query,
                                                                    radius:
                                                                        10000,
                                                                    type:
                                                                        type));
                                                    final placesResponse =
                                                        await placesOperation
                                                            ?.value;
                                                    if (placesResponse == null)
                                                      return;
                                                    bloc.updateSearchResults(
                                                        placesResponse.results);

                                                    /*if (query.isEmpty) {
                                                    placesOperation?.cancel();
                                                    tempStateSetter(
                                                        () => items = [
                                                              ListTile(
                                                              onTap: () {
                                                                // Navigator.pop(
                                                                //     context);
                                                                final currentLocation =
                                                                    bloc.state
                                                                        .locationData;
                                                                final double?
                                                                    lat =
                                                                    currentLocation
                                                                        .latitude;
                                                                final double?
                                                                    lng =
                                                                    currentLocation
                                                                        .longitude;
                                                                bloc.markers = {
                                                                  Marker(
                                                                      markerId:
                                                                          MarkerId(
                                                                              'Location'),
                                                                      infoWindow:
                                                                          InfoWindow(
                                                                              title:
                                                                                  'Current Location'),
                                                                      icon: BitmapDescriptor.defaultMarkerWithHue(
                                                                          BitmapDescriptor
                                                                              .hueRed),
                                                                      position:
                                                                          LatLng(
                                                                              lat!,
                                                                              lng!))
                                                                };
                                                                if (lat == null ||
                                                                    lng == null ||
                                                                    lat == 0.0 ||
                                                                    lng == 0.0)
                                                                  return;
                                                                bloc.updateSheetSelection.call(
                                                                    LocationSheetSelection(
                                                                        name: AppText
                                                                            .CURRENT_LOCATION,
                                                                        lat: lat,
                                                                        lng:
                                                                            lng));
                                                              },
                                                              dense: true,
                                                              horizontalTitleGap:
                                                                  6,
                                                              minVerticalPadding:
                                                                  15,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          6),
                                                              leading: const Image(
                                                                  image: AssetImage(
                                                                        'assets/green_current_location_icon.png'),
                                                                  width: 22,
                                                                  height: 22),
                                                              title: const Text(
                                                                  AppText
                                                                      .CURRENT_LOCATION,
                                                                  style: TextStyle(
                                                                      color: Constants
                                                                          .COLOR_ON_SURFACE,
                                                                      fontFamily:
                                                                          Constants
                                                                              .GILROY_REGULAR,
                                                                      fontSize:
                                                                          15)),
                                                              trailing: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_rounded,
                                                                  size: 22,
                                                                  color: Constants
                                                                      .colorDivider)),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Divider(
                                                                  thickness: 0.5,
                                                                  color: Constants
                                                                      .colorDivider,
                                                                  height: 0.5)),
                                                          ListTile(
                                                              onTap: () {
                                                                type = 'Venues';
                                                                searchEditingController
                                                                        .text =
                                                                    'Venues';
                                                                if (searchTextField !=
                                                                    null)
                                                                  searchTextField
                                                                      ?.onChanged
                                                                      ?.call(
                                                                          'Venues');
                                                                bloc.markers = {
                                                                  Marker(
                                                                    markerId:
                                                                        MarkerId(
                                                                            'Venues'),
                                                                    infoWindow:
                                                                        InfoWindow(
                                                                            title:
                                                                                'Current Location'),
                                                                    icon: BitmapDescriptor
                                                                        .defaultMarkerWithHue(
                                                                            BitmapDescriptor
                                                                                .hueRed),
                                                                    // position: LatLng(lat!, lng!)
                                                                  )
                                                                };
                                                              },
                                                              dense: true,
                                                              horizontalTitleGap:
                                                                  8,
                                                              contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 15,
                                                                  vertical: 6),
                                                              leading: const Image(
                                                                  image: AssetImage(
                                                                      'assets/star_icon.png'),
                                                                  width: 24,
                                                                  height: 24,
                                                                  color: Constants
                                                                      .COLOR_SECONDARY),
                                                              title: Text(
                                                                  AppText
                                                                      .VENUS_NEARBY,
                                                                  style: TextStyle(
                                                                      color:
                                                                          Constants
                                                                              .COLOR_ON_SURFACE,
                                                                      fontFamily:
                                                                          Constants
                                                                              .GILROY_REGULAR,
                                                                      fontSize:
                                                                          15)),
                                                              trailing: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_rounded,
                                                                  size: 20,
                                                                  color: Constants
                                                                      .colorDivider)),
                                                              // Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Divider(thickness: 0.5, color: Constants.colorDivider, height: 0.5)),
                                                              // ListTile(
                                                              //   onTap: () {
                                                              //     type = 'Events';
                                                              //     searchFieldStateSetter(() => searchEditingController.text = 'Events');
                                                              //     if (searchTextField != null) searchTextField?.onChanged?.call('Events');
                                                              //   },
                                                              //   dense: true,
                                                              //   horizontalTitleGap: 10,
                                                              //   contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                                              //   leading: const Image(image: AssetImage('assets/green_event_ticked_icon.png'), width: 24, height: 24),
                                                              //   title: const Text(AppText.EVENTS_NEARBY, style: textStyle),
                                                              //   trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Constants.colorDivider),
                                                              // ),
                                                              Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Divider(
                                                                  thickness: 0.5,
                                                                  color: Constants
                                                                      .colorDivider,
                                                                  height: 0.5)),
                                                          ListTile(
                                                              onTap: () {
                                                                type = 'Airports';
                                                                searchEditingController
                                                                        .text =
                                                                    'Airports';
                                                                if (searchTextField !=
                                                                    null)
                                                                  searchTextField
                                                                      ?.onChanged
                                                                      ?.call(
                                                                          'Airports');
                                                              },
                                                              dense: true,
                                                              horizontalTitleGap:
                                                                  10,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          6),
                                                              leading: const Image(
                                                                  image: AssetImage(
                                                                      'assets/green_airports_icon.png'),
                                                                  width: 24,
                                                                  height: 24),
                                                              title: const Text(
                                                                  AppText
                                                                      .AIRPORT_NEARBY,
                                                                  style: TextStyle(
                                                                      color: Constants
                                                                          .COLOR_ON_SURFACE,
                                                                      fontFamily:
                                                                          Constants
                                                                              .GILROY_REGULAR,
                                                                      fontSize:
                                                                          15)),
                                                              trailing: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_rounded,
                                                                  size: 20,
                                                                  color: Constants
                                                                      .colorDivider)),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Divider(
                                                                  thickness: 0.5,
                                                                  color: Constants
                                                                      .colorDivider,
                                                                  height: 0.5))
                                                            ]);
                                                  }
                                                  else {

                                                    placesOperation?.cancel();
                                                    placesOperation =
                                                        CancelableOperation.fromFuture(mapsPlaces.searchByText(query, radius: 10000, type: type));
                                                    final placesResponse =
                                                        await placesOperation
                                                            ?.value;
                                                    if (placesResponse == null)
                                                      return;


                                                    final tempPlaces = placesResponse.results


                                                        .map((e) => ListTile(
                                                            dense: true,
                                                            onTap: () {
                                                              // searchEditingController
                                                              //     .clear();
                                                              bloc.state.showSuggestions = true;

                                                              searchEditingController.text = e.name;
                                                              FocusScope.of(context).unfocus();
                                                              double? lat = e.geometry?.location.lat;
                                                              double? lng = e.geometry?.location.lng;

                                                              if (lat == null || lng == null) return;

                                                              bloc.updateSheetSelection.call(LocationSheetSelection(name: e.formattedAddress ?? e.name, lat: lat, lng: lng));
                                                              tempStateSetter(() => items = []);

                                                            },
                                                            horizontalTitleGap:
                                                                10,
                                                            title: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(e.name,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold)),
                                                                Text(
                                                                  '${e.formattedAddress}',
                                                                  style: TextStyle(
                                                                      color: Constants
                                                                          .COLOR_ON_SURFACE,
                                                                      fontFamily:
                                                                          Constants
                                                                              .GILROY_REGULAR,
                                                                      fontSize:
                                                                          15),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                            trailing: Icon(
                                                                Icons
                                                                    .arrow_forward_ios_rounded,
                                                                size: 20,
                                                                color: Constants
                                                                    .colorDivider)))
                                                        .toList();
                                                    tempStateSetter(
                                                        () => items = tempPlaces);
                                                  }*/
                                                  },
                                                  style: const TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SURFACE,
                                                      fontSize: 14,
                                                      fontFamily: Constants
                                                          .GILROY_REGULAR),
                                                  decoration: InputDecoration(
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      hintText: AppText
                                                          .WHERE_ARE_YOU_GOING_QUESTION_MARK,
                                                      border: InputBorder.none,
                                                      hintStyle: TextStyle(
                                                          color: Constants
                                                              .colorDivider,
                                                          fontFamily: Constants
                                                              .GILROY_REGULAR,
                                                          fontSize: 14)),
                                                  maxLines: 1,
                                                );
                                                return searchTextField!;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                      onTap: () {
                                        bloc.showSuggestions(false);
                                        bloc.showFilterView(true);

                                        searchEditingController.text = "";
                                        selectedDateTime = getAdditionOfTime(
                                            DateTime.now(), 15);
                                        parkingSlotStartTime.text =
                                            getParkingSpaceFormattedDateTime(
                                                selectedDateTime);
                                        dateSelection.text =
                                            "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

                                        if (state.packageSelected == "2") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 120);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "4") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 240);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "6") {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 360);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        } else if (state.packageSelected ==
                                            "monthly") {
                                          parkingSlotStartTime.text =
                                              DateFormat('dd MMM')
                                                  .format(selectedDateTime);
                                          parkingSlotEndTime.text = "Monthly";
                                        } else {
                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  selectedDateTime, 60);
                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                        }

                                        if (_persistedBottomSheetController !=
                                            null) return;
                                        _bottomSheetHelper
                                            .injectContext(context);
                                        _persistedBottomSheetController =
                                            _bottomSheetHelper
                                                .showSearchFilterBottomSheet(
                                                    bloc, () {
                                          if (bloc
                                              .state.packageSelected.isEmpty) {
                                            selectedDateTime =
                                                getAdditionOfTime(
                                                    DateTime.now(), 15);

                                            parkingSlotStartTime.text =
                                                getParkingSpaceFormattedDateTime(
                                                    selectedDateTime);

                                            dateSelection.text =
                                                "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

                                            selectedEndDateTime =
                                                getAdditionOfTime(
                                                    selectedDateTime, 60);

                                            parkingSlotEndTime.text =
                                                getParkingSpaceFormattedDateTime(
                                                    selectedEndDateTime);
                                          } else if (bloc
                                                  .state.packageSelected ==
                                              "monthly") {
                                            parkingSlotEndTime.text = "Monthly";
                                            parkingSlotStartTime.text =
                                                DateFormat('dd MMM')
                                                    .format(selectedDateTime);
                                          }

                                          if (bloc.state.searchFilter
                                              .applyFilters) {
                                            final lat = bloc.lastLat ??
                                                bloc.state.locationData
                                                    .latitude;
                                            final lng = bloc.lastLng ??
                                                bloc.state.locationData
                                                    .longitude;
                                            if (lat == null ||
                                                lng == null ||
                                                lat == 0.0 ||
                                                lng == 0.0) return;
                                            currentLat = lat;
                                            currentLng = lng;
                                            bloc.driverHome(
                                                globalKey, lat, lng);
                                            bloc.state.isFilterShow = false;
                                          }
                                        });

                                        _persistedBottomSheetController?.closed
                                            .whenComplete(() => {
                                                  _persistedBottomSheetController =
                                                      null
                                                });
                                      },
                                      child: SvgPicture.asset(
                                        "assets/search_filter_icon.svg",
                                        width: 16,
                                        height: 16,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),
                        // if (items.isNotEmpty)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: StatefulBuilder(builder: (_, stateSetter) {
                            tempStateSetter = stateSetter;
                            return SingleChildScrollView(
                                child: Container(
                                    color: Colors.white,
                                    child: Column(children: items)));
                          }),
                        )
                      ],
                    ),
                  )),

          BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
              builder: (_, state) {
            double? lat = state.locationData.latitude;
            double? lng = state.locationData.longitude;
            if (lat == null || lng == null || lat == 0.0 || lng == 0.0)
              return const SizedBox();
            return state.showSuggestions || state.showDateTimeView || state.isFilterShow
                ? SizedBox()
                : Positioned(
                    bottom: 35,
                    right: 25,
                    child: GestureDetector(
                      onTap: () {
                        // showParkingSpaces(bloc);

                        bloc.animateCamera(null, null);
                      },
                      child: PhysicalModel(
                          color: Constants.COLOR_SURFACE,
                          shadowColor: Constants.COLOR_PRIMARY,
                          elevation: 10,
                          shape: BoxShape.circle,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Constants.COLOR_SURFACE,
                                shape: BoxShape.circle),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.my_location_rounded,
                                color: Constants.COLOR_PRIMARY, size: 22),
                          )),
                    ));
          }),
          BlocListener<HomeNavigationScreenBloc, HomeNavigationScreenState>(
            listener: (_, state) {
              if (state.parkingTapId.isEmpty) return;
              _requestParkingSpace(int.parse(state.parkingTapId));
            },
            listenWhen: (previous, current) =>
                previous.parkingTapId != current.parkingTapId,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<HomeNavigationScreenBloc,
                        HomeNavigationScreenState>(
                    buildWhen: (previous, current) =>
                        previous.dataEvent != current.dataEvent,
                    builder: (_, state) {
                      final dataEvent = state.dataEvent;
                      if (dataEvent is Initial || dataEvent is Data)
                        return const SizedBox();
                      else if (dataEvent is Loading)
                        return Container(
                            margin: const EdgeInsets.only(bottom: 35),
                            decoration: BoxDecoration(
                                color: Constants.COLOR_SURFACE,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Constants.COLOR_PRIMARY, width: 1)),
                            padding: const EdgeInsets.all(12),
                            child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Constants.COLOR_PRIMARY)));
                      return const SizedBox();
                    })),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _persistedBottomSheetController = null;
    _bottomSheetHelper.dispose();
    _dialogHelper.dispose();
    _snackbarHelper.dispose();
    super.dispose();
  }

  Widget searchBarParkingSlotsView(
      HomeNavigationScreenBloc bloc, HomeNavigationScreenState state) {
    return Container(
        child: Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                    parkingSlotTimePicker = selectedDateTime;
                    bloc.updateParkingSlotClick(false);
                    bloc.updatePackageSelected("");
                    bloc.updateParkingHourlySelected(true);

                    if (state.isFilterShow) {
                      Navigator.of(context).pop();
                      bloc.showFilterView(false);
                    }
                    bloc.showSuggestions(false);
                    bloc.showDateAndTimeView(true);
                    if (parkingSlotEndTime.text == "Monthly") {
                      bloc.updatePackageSelected("monthly");
                    }
                    showBottomDateTimePicker(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Starts:",
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 14),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                          height: 12,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            enabled: false,
                            controller: parkingSlotStartTime,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              isDense: true,
                            ),
                            style: TextStyle(
                                color: Constants.COLOR_BLACK,
                                fontFamily: Constants.GILROY_MEDIUM,
                                fontSize: 14),
                            maxLines: 1,
                          )),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                width: 2,
                height: 30,
                color: Constants.COLOR_PRIMARY,
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    bloc.updateParkingHourlySelected(true);
                    parkingSlotTimePicker = selectedEndDateTime;
                    bloc.updateParkingSlotClick(true);
                    bloc.updatePackageSelected("");

                    if (state.isFilterShow) {
                      Navigator.of(context).pop();
                      bloc.showFilterView(false);
                    }
                    bloc.showSuggestions(false);
                    bloc.showDateAndTimeView(true);
                    bloc.updateParkingSlotClick(true);
                    parkingSlotClicked = true;

                    if (parkingSlotEndTime.text == "Monthly") {
                      bloc.updatePackageSelected("monthly");
                    }
                    showBottomDateTimePicker(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        "Ends:",
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 15),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                          height: 12,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            enabled: false,
                            controller: parkingSlotEndTime,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              isDense: true,
                            ),
                            style: TextStyle(
                                color: Constants.COLOR_BLACK,
                                fontFamily: Constants.GILROY_MEDIUM,
                                fontSize: 14),
                            maxLines: 1,
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    ));
  }

  Widget showSuggestionsSheet(
      HomeNavigationScreenBloc bloc, HomeNavigationScreenState stateIndex) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height - 220,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              showSearchResult(stateIndex.searchResults),
              showMoreEvents
                  ? showAllEvents(stateIndex.events)
                  : showMoreAirports
                      ? showAllAirports(bloc)
                      : Visibility(
                          visible: stateIndex.searchResults.isEmpty,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  bloc.showSuggestions(false);
                                  searchEditingController.text =
                                      "Current Location";
                                  final currentLocation =
                                      bloc.state.locationData;
                                  final double? lat = currentLocation.latitude;
                                  final double? lng = currentLocation.longitude;
                                  bloc.markers = {
                                    Marker(
                                        markerId: MarkerId('Location'),
                                        infoWindow: InfoWindow(
                                            title: 'Current Location'),
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                                BitmapDescriptor.hueRed),
                                        position: LatLng(lat!, lng!))
                                  };
                                  if (lat == null || lat == 0.0 || lng == 0.0)
                                    return;
                                  bloc.updateSheetSelection.call(
                                      globalKey,
                                      LocationSheetSelection(
                                          name: AppText.CURRENT_LOCATION,
                                          lat: lat,
                                          lng: lng));

                                  // setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Constants.COLOR_ON_SURFACE,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0,
                                              left: 8.0,
                                              right: 12.0,
                                              bottom: 8.0),
                                          child: SvgPicture.asset(
                                            "assets/search_current_location.svg",
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      AppText.CURRENT_LOCATION,
                                      style: TextStyle(
                                          color: Constants.COLOR_BLACK,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              eventsSuggestion(
                                  stateIndex.searchResults, stateIndex.events),
                              SizedBox(
                                height: 15,
                              ),
                              BlocBuilder<HomeNavigationScreenBloc,
                                  HomeNavigationScreenState>(
                                buildWhen: (previous, current) =>
                                    current.airports.isNotEmpty,
                                builder: (_, stateIndex) {
                                  return PhysicalModel(
                                    color: Constants.COLOR_GREY_200,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15)),
                                    child: airportsSuggestion(
                                        bloc, stateIndex.airports),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              favouritesSuggestion()
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showSearchResult(List<places.PlacesSearchResult> searchResults) {
    return Visibility(
      visible: searchResults.isNotEmpty,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Constants.COLOR_SURFACE,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    bloc.showSuggestions(false);
                    searchEditingController.text = searchResults[index].name;
                    final currentLocation = bloc.state.locationData;
                    final double? lat =
                        searchResults[index].geometry?.location.lat;
                    final double? lng =
                        searchResults[index].geometry?.location.lng;
                    bloc.markers = {
                      Marker(
                          markerId: MarkerId('Location'),
                          infoWindow:
                              InfoWindow(title: searchResults[index].name),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                          position: LatLng(lat!, lng!))
                    };
                    if (lat == 0.0 || lng == 0.0) return;
                    bloc.updateSheetSelection.call(
                        globalKey,
                        LocationSheetSelection(
                            name: AppText.CURRENT_LOCATION,
                            lat: lat,
                            lng: lng));
                    searchResults.clear();
                    setState(() {});
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 120,
                                    child: Text(
                                      searchResults[index].name,
                                      style: TextStyle(
                                          color: Constants.COLOR_BLACK,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    child: Text(
                                      searchResults[index]
                                          .formattedAddress
                                          .toString(),
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_SURFACE,
                                          fontFamily: Constants.GILROY_REGULAR,
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        index == searchResults.length - 1
                            ? Container()
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                height: 1,
                                width: MediaQuery.of(context).size.width - 20,
                                color: Constants.COLOR_GREY,
                              )
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget eventsSuggestion(List<places.PlacesSearchResult> searchResults,
      List<EventsResults> events) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Constants.COLOR_ON_SURFACE,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  "assets/search_events.svg",
                  height: 22,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              AppText.EVENTS,
              style: TextStyle(
                  color: Constants.COLOR_BLACK,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 15),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                showMoreEvents = true;
                setState(() {});
              },
              child: Text(
                AppText.MORE,
                style: TextStyle(
                    color: Constants.COLOR_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 15),
              ),
            ),
            SizedBox(
              width: 35,
            ),
          ],
        ),
        SizedBox(height: searchResults.isNotEmpty ? 0 : 10),
        Visibility(
          visible: searchResults.isEmpty,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Constants.COLOR_SURFACE,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchResults.isNotEmpty
                      ? 0
                      : events.length >= 4
                          ? 4
                          : events.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EventDetails(
                                  events: events[index],
                                )));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                120,
                                        child: Text(
                                          events[index].title,
                                          style: TextStyle(
                                              color: Constants.COLOR_BLACK,
                                              fontFamily: Constants.GILROY_BOLD,
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100,
                                        child: Text(
                                          "${events[index].date.startDate}, $currentYear at ${events[index].address[0]}",
                                          style: TextStyle(
                                              color: Constants.COLOR_ON_SURFACE,
                                              fontFamily:
                                                  Constants.GILROY_REGULAR,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Constants.COLOR_BLACK,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                )
                              ],
                            ),
                            index == 2
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    height: 1,
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    color: Constants.COLOR_GREY,
                                  ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget airportsSuggestion(
      HomeNavigationScreenBloc bloc, List<places.PlacesSearchResult> airports) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Constants.COLOR_ON_SURFACE,
                shape: BoxShape.circle,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    "assets/search_plane_icon.svg",
                    height: 18,
                  )),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              AppText.AIRPORTS,
              style: TextStyle(
                  color: Constants.COLOR_BLACK,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 15),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                showMoreAirports = true;
                setState(() {});
              },
              child: Text(
                AppText.MORE,
                style: TextStyle(
                    color: Constants.COLOR_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 15),
              ),
            ),
            SizedBox(
              width: 35,
            ),
          ],
        ),
        Visibility(
          visible: airports.isNotEmpty,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Constants.COLOR_SURFACE,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: airports.length > 3 ? 3 : airports.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        bloc.state.showSuggestions = false;
                        searchEditingController.text = airports[index].name;
                        FocusScope.of(context).unfocus();
                        double? lat = airports[index].geometry?.location.lat;
                        double? lng = airports[index].geometry?.location.lng;

                        if (lat == null || lng == null) return;

                        bloc.updateSheetSelection.call(
                            globalKey,
                            LocationSheetSelection(
                                name: airports[index].formattedAddress ??
                                    airports[index].name,
                                lat: lat,
                                lng: lng));
                        if (showMoreEvents) {
                          showMoreEvents = false;
                        } else if (showMoreAirports) {
                          showMoreAirports = false;
                        } else if (requestedNearByData) {
                          requestedNearByData = false;
                        } else {
                          bloc.state.showSuggestions = false;
                        }
                        currentLat = lat;
                        currentLng = lng;
                        bloc.driverHome(globalKey, lat, lng,
                            isNewRequest: false);

                        // setState(() {});
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 22.0, right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        airports[index].name,
                                        style: TextStyle(
                                            color: Constants.COLOR_BLACK,
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                        child: Text(
                                          airports[index]
                                              .formattedAddress
                                              .toString(),
                                          style: TextStyle(
                                              color: Constants.COLOR_ON_SURFACE,
                                              fontFamily:
                                                  Constants.GILROY_REGULAR,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            index == 2
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    height: 1,
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    color: Constants.COLOR_GREY,
                                  ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget favouritesSuggestion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Constants.COLOR_ON_SURFACE,
            shape: BoxShape.circle,
          ),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                "assets/search_heart_icon_.svg",
                height: 18,
              )),
        ),
        SizedBox(
          width: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            AppText.FAVOURITES,
            style: TextStyle(
                color: Constants.COLOR_BLACK,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 15),
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FavouriteSpaces()));
          },
          child: Text(
            AppText.MORE,
            style: TextStyle(
                color: Constants.COLOR_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 15),
          ),
        ),
        SizedBox(
          width: 35,
        ),
      ],
    );
  }

  void showBottomDateTimePicker(BuildContext mContext) {
    showModalBottomSheet(
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.white,
      elevation: 10,
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return BlocProvider.value(
          value: BlocProvider.of<HomeNavigationScreenBloc>(mContext),
          child:
              BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
                  builder: (_, state) {
            if (state.packageSelected.isEmpty) {
              state.packageSelected = parkingSlotEndTimeSelected;
            }
            state.parkingSlotNextClicked = parkingSlotClicked;
            return Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        state.parkingSlotNextClicked
                            ? AppText.DatePickerEndTitle
                            : AppText.DatePickerTitle,
                        style: TextStyle(
                            color: Constants.COLOR_BLACK,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                        height: 12,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          enabled: false,
                          controller: dateSelection,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            isDense: true,
                          ),
                          style: TextStyle(
                              color: Constants.COLOR_GREY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 12),
                          maxLines: 1,
                        )),
                    Visibility(
                        visible: state.parkingSlotNextClicked,
                        child: packageSelection(state)),
                    state.packageSelected == "monthly" &&
                            state.parkingSlotNextClicked
                        ? Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: size.height * 0.24,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/piggy_bank.svg",
                                  height: 60,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Never worry with Monthly",
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                    "After you made your booking, you are all set,\n no need to renew as we do it for you on a rolling monthly basis,",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK,
                                        fontFamily: Constants.GILROY_REGULAR,
                                        fontSize: 12),
                                    textAlign: TextAlign.center),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "(Cancel Anytime)",
                                  style: TextStyle(
                                    color: Constants.COLOR_PRIMARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : !state.hourlySelected
                            ? SizedBox(
                                height: size.height * 0.23,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : CupertinoTheme(
                                data: CupertinoThemeData(
                                  textTheme: CupertinoTextThemeData(
                                    dateTimePickerTextStyle: TextStyle(
                                        color: Constants.COLOR_BLACK,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 16),
                                  ),
                                ),
                                child: Container(
                                  height: size.height * 0.23,
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: CupertinoDatePicker(
                                    key: UniqueKey(),
                                    mode: CupertinoDatePickerMode.dateAndTime,
                                    minimumDate: state.parkingSlotNextClicked
                                        ? getAdditionOfTime(
                                            selectedDateTime, 60)
                                        : selectedDateTime,
                                    minuteInterval: 15,
                                    initialDateTime: DateTime(
                                        parkingSlotTimePicker.year,
                                        parkingSlotTimePicker.month,
                                        parkingSlotTimePicker.day,
                                        parkingSlotTimePicker.hour,
                                        parkingSlotTimePicker.minute),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      if (mounted) {
                                        if (state.parkingSlotNextClicked) {
                                          selectedEndDateTime = newDateTime;
                                          // var endDateTime = (newDateTime).add(new Duration(minutes: 60));
                                          var endDateTime = newDateTime;
                                          String endDate = DateFormat('dd MMM')
                                              .format(endDateTime);
                                          String endTime = DateFormat('hh:mma')
                                              .format(endDateTime)
                                              .toString()
                                              .toLowerCase();

                                          formattedEndTime =
                                              "$endDate at $endTime";
                                          parkingSlotEndTime.text =
                                              formattedEndTime;
                                          parkingSlotTimePicker = newDateTime;

                                          bloc.updateParkingHourlySelected(
                                              true);
                                        } else {
                                          selectedDateTime = newDateTime;

                                          dateSelection.text =
                                              "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";
                                          parkingSlotStartTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedDateTime);

                                          selectedEndDateTime =
                                              getAdditionOfTime(
                                                  newDateTime, 60);

                                          parkingSlotEndTime.text =
                                              getParkingSpaceFormattedDateTime(
                                                  selectedEndDateTime);
                                          parkingSlotTimePicker = newDateTime;
                                          bloc.updatePackageSelected("");
                                          parkingSlotEndTimeSelected = "";
                                        }
                                        bloc.updateParkingTimings(
                                            selectedDateTime.toString(),
                                            selectedEndDateTime.toString());
                                      }
                                    },
                                  ),
                                ),
                              ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                primary: Constants.COLOR_BACKGROUND,
                                onPrimary: Constants.COLOR_BLACK,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: () {
                                if (!state.parkingSlotNextClicked)
                                  Navigator.of(context).pop();
                                parkingSlotTimePicker = selectedDateTime;
                                parkingSlotClicked = false;
                                bloc.updateParkingSlotClick(false);
                                // setModalState(() {});
                              },
                              child: Text(
                                'Back',
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontFamily: Constants.GILROY_MEDIUM,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 25),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 24.0, right: 24.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Constants.COLOR_PRIMARY,
                                onPrimary: Constants.COLOR_BACKGROUND,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: () {
                                if (state.parkingSlotNextClicked) {
                                  setParkingSlotTime(
                                      bloc.state.packageSelected);
                                  Navigator.of(context).pop();
                                } else {
                                  parkingSlotClicked = true;
                                  bloc.updateParkingSlotClick(true);
                                  bloc.updateParkingHourlySelected(false);
                                  parkingSlotTimePicker = selectedEndDateTime;

                                  Future.delayed(
                                          const Duration(milliseconds: 500))
                                      .then((_) {
                                    bloc.updateParkingHourlySelected(true);
                                  });
                                }
                              },
                              child: Text(
                                  state.parkingSlotNextClicked
                                      ? "Search"
                                      : "Next",
                                  style: TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontFamily: Constants.GILROY_MEDIUM,
                                      fontSize: 14)),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    ).whenComplete(() => {closedDateTimePicker()});
  }

  void closedDateTimePicker() {
    bloc.showDateAndTimeView(false);
    bloc.showSuggestions(false);
    bloc.showFilterView(false);
    bloc.updateParkingSlotClick(false);
    parkingSlotClicked = false;
  }

  Widget packageSelection(HomeNavigationScreenState state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Constants.COLOR_GREY_200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Fast select duration options:",
                style: TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_MEDIUM,
                    fontSize: 12)),
            SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    setParkingSlotTime("2");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: state.packageSelected == "2"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("2 hr",
                          style: TextStyle(
                              color: state.packageSelected == "2"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setParkingSlotTime("4");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: state.packageSelected == "4"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("4 hr",
                          style: TextStyle(
                              color: state.packageSelected == "4"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setParkingSlotTime("6");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: state.packageSelected == "6"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("6 hr",
                          style: TextStyle(
                              color: state.packageSelected == "6"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setParkingSlotTime("monthly");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: state.packageSelected == "monthly"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 2.0),
                      child: Text("Monthly",
                          style: TextStyle(
                              color: state.packageSelected == "monthly"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget showAllEvents(List<EventsResults> events) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            showMoreEvents = false;
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Constants.COLOR_SURFACE,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDetails(
                                events: events[index],
                              )));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          120,
                                      child: Text(
                                        events[index].title,
                                        style: TextStyle(
                                            color: Constants.COLOR_BLACK,
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Text(
                                        "${events[index].date.startDate}, $currentYear at ${events[index].address[0]}",
                                        style: TextStyle(
                                            color: Constants.COLOR_ON_SURFACE,
                                            fontFamily:
                                                Constants.GILROY_REGULAR,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Constants.COLOR_BLACK,
                                size: 20,
                              ),
                              SizedBox(width: 5)
                            ],
                          ),
                          index == events.length - 1
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height: 1,
                                  width: MediaQuery.of(context).size.width - 20,
                                  color: Constants.COLOR_GREY,
                                ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget showAllAirports(HomeNavigationScreenBloc bloc) {
    return BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
      buildWhen: (previous, current) => current.airports.isNotEmpty,
      builder: (_, stateIndex) {
        var airports = stateIndex.airports;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showMoreAirports = false;
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.arrow_back_ios),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Constants.COLOR_SURFACE,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: airports.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          bloc.state.showSuggestions = false;

                          searchEditingController.text = airports[index].name;
                          FocusScope.of(context).unfocus();
                          double? lat = airports[index].geometry?.location.lat;
                          double? lng = airports[index].geometry?.location.lng;

                          if (lat == null || lng == null) return;

                          bloc.updateSheetSelection.call(
                              globalKey,
                              LocationSheetSelection(
                                  name: airports[index].formattedAddress ??
                                      airports[index].name,
                                  lat: lat,
                                  lng: lng));

                          if (showMoreEvents) {
                            showMoreEvents = false;
                          } else if (showMoreAirports) {
                            showMoreAirports = false;
                          } else if (requestedNearByData) {
                            requestedNearByData = false;
                          } else {
                            bloc.state.showSuggestions = false;
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 22.0, right: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          airports[index].name,
                                          style: TextStyle(
                                              color: Constants.COLOR_BLACK,
                                              fontFamily: Constants.GILROY_BOLD,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          child: Text(
                                            airports[index]
                                                .formattedAddress
                                                .toString(),
                                            style: TextStyle(
                                                color:
                                                    Constants.COLOR_ON_SURFACE,
                                                fontFamily:
                                                    Constants.GILROY_REGULAR,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              index == airports.length - 1
                                  ? Container()
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      height: 1,
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      color: Constants.COLOR_GREY,
                                    ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  void getNearByData(double? lat, double? long) async {
    var fetchGeocoder = await Geocoder2.getDataFromCoordinates(
        latitude: lat!,
        longitude: long!,
        googleMapApiKey: "AIzaSyA6772hSqFxxDAYS-bysElYNr9FvkRZ6GI");
    print("---<> ${fetchGeocoder.state} ${fetchGeocoder.city}");
    _requestEvents(fetchGeocoder.city);
  }

  void showParkingSpaces(
      HomeNavigationScreenBloc bloc, ParkingSpaceDetail parkingSpace) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _bottomSheetHelper.injectContext(context);
      _bottomSheetHelper.showParkingDetailBottomSheet(parkingSpace,
          bloc.state.locationData, parkingSpace.reviews, 0.15, bloc, context,"");
    });
  }

  void setParkingSlotTime(String packageSelected) {
    parkingSlotStartTime.text =
        getParkingSpaceFormattedDateTime(selectedDateTime);
    bloc.updatePackageSelected(packageSelected);
    if (packageSelected == "2") {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 120));
      parkingSlotEndTime.text =
          getParkingSpaceFormattedDateTime(selectedEndDateTime);
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "4") {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 240));
      parkingSlotEndTime.text =
          getParkingSpaceFormattedDateTime(selectedEndDateTime);
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "6") {
      selectedEndDateTime = selectedDateTime.add(
        Duration(minutes: 360),
      );
      parkingSlotEndTime.text =
          getParkingSpaceFormattedDateTime(selectedEndDateTime);
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "monthly") {
      parkingSlotStartTime.text =
          DateFormat('dd MMM  ').format(selectedDateTime);
      parkingSlotEndTime.text = "Monthly";
    } else {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 60));
      parkingSlotEndTime.text =
          getParkingSpaceFormattedDateTime(selectedEndDateTime);
      parkingSlotTimePicker = selectedEndDateTime;
    }
    parkingSlotEndTimeSelected = packageSelected;
    bloc.updatePackageSelected(packageSelected);
    bloc.updateParkingHourlySelected(false);
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      bloc.updateParkingHourlySelected(true);
    });
  }

  int initialMinute(int minute) {
    if (minute <= 15) {
      return 15;
    } else if (minute <= 30) {
      return 30;
    } else if (minute <= 45) {
      return 45;
    } else {
      return 60;
    }
  }

  void setSpaceTimes() {
    selectedDateTime = nearestQuarter(DateTime.now());
    parkingSlotStartTime.text =
        getParkingSpaceFormattedDateTime(selectedDateTime);
    dateSelection.text =
        "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

    if (bloc.state.packageSelected == "monthly") {
      parkingSlotStartTime.text = DateFormat('dd MMM')
          .format(DateTime.parse(bloc.state.parkingSpaceStartDateTime))
          .toString();
      parkingSlotEndTime.text = "Monthly";
    } else {
      var timeDifference = 0;

      if (bloc.state.parkingSpaceEndDateTime.isNotEmpty) {
        timeDifference = DateTime.parse(bloc.state.parkingSpaceEndDateTime)
            .difference(selectedDateTime)
            .inMinutes;
      }
      if (timeDifference > 59) {
        selectedEndDateTime =
            DateTime.parse(bloc.state.parkingSpaceEndDateTime);
        parkingSlotEndTime.text =
            getParkingSpaceFormattedDateTime(selectedEndDateTime);
      } else {
        selectedEndDateTime = getAdditionOfTime(selectedDateTime, 60);
        parkingSlotEndTime.text =
            getParkingSpaceFormattedDateTime(selectedEndDateTime);
      }
    }
    bloc.updateParkingTimings(
        selectedDateTime.toString(), selectedEndDateTime.toString());
  }
}
