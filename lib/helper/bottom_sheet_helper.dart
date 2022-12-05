import 'package:another_flushbar/flushbar.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/extension/duration_extension.dart';
import 'package:rent2park/helper/shared_pref_helper.dart';
import 'package:rent2park/util/SizeConfig.dart';

import 'package:url_launcher/url_launcher.dart';

import '../backend/shared_web-services.dart';
import '../data/backend_responses.dart';
import '../data/location_sheet_selection.dart';
import '../data/user_type.dart';
import '../extension/collection_extension.dart';
import '../page-transformer/transformer_page_view.dart';
import '../page-transformer/zoom_in_page_transformer.dart';
import '../ui/common/app_button.dart';
import '../ui/common/single_review_item_widget.dart';
import '../ui/custom_date_time_picker/custom_date_time_picker_screen.dart';
import '../ui/main/home/home_navigation_screen_bloc.dart';
import '../ui/main/home/home_navigation_screen_state.dart';
import '../ui/secure_checkout/secure_checkout_screen.dart';
import '../ui/street-view/street_view_screen.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';
import '../util/extensions.dart';
import '../util/text_upper_case_formatter.dart';

class BottomSheetHelper {
  static final BottomSheetHelper instance = BottomSheetHelper._internal();
  static const ShapeBorder _sheetBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)));
  final GoogleMapsPlaces mapsPlaces =
      GoogleMapsPlaces(apiKey: Constants.GOOGLE_MAP_PLACES_API_KEY);
  final SharedWebService _sharedWebService = SharedWebService.instance;

  BuildContext? _context;

  BottomSheetHelper._internal();

  void injectContext(BuildContext context) => this._context = context;

  void dispose() => this._context = null;

  PersistentBottomSheetController? showSearchLocationBottomSheet(
      HomeNavigationScreenBloc bloc,
      Function(LocationSheetSelection) selection) {
    final context = _context;
    if (context == null) return null;
    const textStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    final TextEditingController searchEditingController =
        TextEditingController();

    String type = '';
    Function searchFieldStateSetter = () {};
    TextField? searchTextField;

    final staticTiles = [
      ListTile(
          onTap: () {
            Navigator.pop(context);
            final currentLocation = bloc.state.locationData;
            final double? lat = currentLocation.latitude;
            final double? lng = currentLocation.longitude;
            bloc.markers = {
              Marker(
                  markerId: MarkerId('Location'),
                  infoWindow: InfoWindow(title: 'Current Lcoation'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  position: LatLng(lat!, lng!))
            };
            if (lat == 0.0 || lng == 0.0) return;
            selection.call(LocationSheetSelection(
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
          title: const Text(AppText.CURRENT_LOCATION, style: textStyle),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 20, color: Constants.colorDivider)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
              thickness: 0.5, color: Constants.colorDivider, height: 0.5)),
      ListTile(
          onTap: () {
            type = 'Venues';
            searchFieldStateSetter(
                () => searchEditingController.text = 'Venues');
            if (searchTextField != null)
              searchTextField?.onChanged?.call('Venues');
            bloc.markers = {
              Marker(
                markerId: MarkerId('Venues'),
                infoWindow: InfoWindow(title: 'Current Lcoation'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                // position: LatLng(lat!, lng!)
              )
            };
          },
          dense: true,
          horizontalTitleGap: 8,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          leading: const Image(
              image: AssetImage('assets/star_icon.png'),
              width: 24,
              height: 24,
              color: Constants.COLOR_SECONDARY),
          title: Text(AppText.VENUS_NEARBY, style: textStyle),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 20, color: Constants.colorDivider)),
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
              thickness: 0.5, color: Constants.colorDivider, height: 0.5)),
      ListTile(
          onTap: () {
            type = 'Airports';
            searchFieldStateSetter(
                () => searchEditingController.text = 'Airports');
            if (searchTextField != null)
              searchTextField?.onChanged?.call('Airports');
          },
          dense: true,
          horizontalTitleGap: 10,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          leading: const Image(
              image: AssetImage('assets/green_airports_icon.png'),
              width: 24,
              height: 24),
          title: const Text(AppText.AIRPORT_NEARBY, style: textStyle),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 20, color: Constants.colorDivider)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
              thickness: 0.5, color: Constants.colorDivider, height: 0.5))
    ];

    CancelableOperation<PlacesSearchResponse>? placesOperation;
    Function tempStateSetter = () {};
    List<Widget> items = staticTiles;

    return Scaffold.of(context).showBottomSheet(
        (_) => DraggableScrollableSheet(
            builder: (_, scrollController) => SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.clear,
                              color: Constants.COLOR_PRIMARY)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: StatefulBuilder(
                          builder: (_, stateSetter) {
                            searchFieldStateSetter = stateSetter;
                            searchTextField = TextField(
                              controller: searchEditingController,
                              inputFormatters: [UpperCaseTextFormatter()],
                              onChanged: (String query) async {
                                if (query.isEmpty) {
                                  placesOperation?.cancel();
                                  tempStateSetter(() => items = staticTiles);
                                } else {
                                  placesOperation?.cancel();
                                  placesOperation =
                                      CancelableOperation.fromFuture(
                                          mapsPlaces.searchByText(query,
                                              radius: 10000, type: type));
                                  final placesResponse =
                                      await placesOperation?.value;
                                  if (placesResponse == null) return;
                                  final tempPlaces = placesResponse.results
                                      .map((e) => ListTile(
                                          dense: true,
                                          onTap: () {
                                            Navigator.pop(context);
                                            double? lat =
                                                e.geometry?.location.lat;
                                            double? lng =
                                                e.geometry?.location.lng;
                                            if (lat == null || lng == null)
                                              return;
                                            selection.call(
                                                LocationSheetSelection(
                                                    name: e.formattedAddress ??
                                                        e.name,
                                                    lat: lat,
                                                    lng: lng));
                                          },
                                          horizontalTitleGap: 10,
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(e.name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                '${e.formattedAddress}',
                                                style: textStyle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 20,
                                              color: Constants.colorDivider)))
                                      .toList();
                                  tempStateSetter(() => items = tempPlaces);
                                }
                              },
                              style: const TextStyle(
                                  color: Constants.COLOR_ON_SURFACE,
                                  fontSize: 14,
                                  fontFamily: Constants.GILROY_REGULAR),
                              decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText:
                                      AppText.WHERE_ARE_YOU_GOING_QUESTION_MARK,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Constants.colorDivider,
                                      fontFamily: Constants.GILROY_REGULAR,
                                      fontSize: 14)),
                            );
                            return searchTextField!;
                          },
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(
                              thickness: 0.5,
                              color: Constants.colorDivider,
                              height: 0.5)),
                      const SizedBox(height: 15),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(AppText.SUGGESTED,
                              style: TextStyle(
                                  color: Constants.COLOR_ON_SURFACE,
                                  fontFamily: Constants.GILROY_REGULAR,
                                  fontSize: 15))),
                      const SizedBox(height: 25),
                      StatefulBuilder(builder: (_, stateSetter) {
                        tempStateSetter = stateSetter;
                        return Column(children: items);
                      })
                    ],
                  ),
                ),
            initialChildSize: 0.8,
            maxChildSize: 0.8,
            expand: false),
        elevation: 20,
        shape: _sheetBorder);
  }

  PersistentBottomSheetController? showSearchFilterBottomSheet(
      HomeNavigationScreenBloc bloc, VoidCallback onApplyFilter) {
    final context = _context;
    if (context == null) return null;
    final size = MediaQuery.of(context).size;

    /// filter updation value
    RangeValues rangeValue = bloc.state.searchFilter.rangeValue;
    bool isSecurelyGated = bloc.state.searchFilter.isSecurelyGated;
    bool isCctv = bloc.state.searchFilter.isCctv;
    bool isDisabledAccess = bloc.state.searchFilter.isDisabledAccess;
    bool isLighting = bloc.state.searchFilter.isLighting;
    bool isElectricVehicleCharging =
        bloc.state.searchFilter.isElectricVehicleCharging;
    bool isWifi = bloc.state.searchFilter.isWifi;
    bool isSheltered = bloc.state.searchFilter.isSheltered;
    bool isAirportTransfers = bloc.state.searchFilter.isAirportTransfers;
    bool isDriveway = bloc.state.searchFilter.isDriveway;
    bool isGarage = bloc.state.searchFilter.isGarage;
    bool isLandGrassParking = bloc.state.searchFilter.isLandGrassParking;
    bool isOnStreet = bloc.state.searchFilter.isOnStreet;
    bool isCarPark = bloc.state.searchFilter.isCarPark;

    const textStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontSize: 16,
        fontFamily: Constants.GILROY_BOLD);

    const switchTextStyle = TextStyle(
        color: Constants.COLOR_BLACK_200,
        fontSize: 16,
        fontFamily: Constants.GILROY_MEDIUM);

    showModalBottomSheet(
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      elevation: 10,
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Wrap(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text(AppText.FILTERS, style: textStyle),
                    ),
                    const Text(AppText.PARKING_TYPE_QUESTION,
                        style: TextStyle(
                            color: Constants.COLOR_BLACK,
                            fontSize: 16,
                            fontFamily: Constants.GILROY_MEDIUM)),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                bloc.applyFilters(false);
                                bloc.updatePackageSelected("");
                                onApplyFilter.call();

                                setState(() {});
                              },
                              child: Container(
                                width: size.width * 0.38,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: bloc.state.packageSelected != "monthly"
                                      ? Constants.COLOR_PRIMARY
                                      : Constants.COLOR_GREY_300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text("Short Term",
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_SECONDARY,
                                          fontSize: 16,
                                          fontFamily: Constants.GILROY_BOLD)),
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              bloc.applyFilters(false);
                              bloc.updatePackageSelected("monthly");
                              onApplyFilter.call();
                              setState(() {});
                            },
                            child: Container(
                              width: size.width * 0.38,
                              height: 35,
                              decoration: BoxDecoration(
                                color: bloc.state.packageSelected == "monthly"
                                    ? Constants.COLOR_PRIMARY
                                    : Constants.COLOR_GREY_300,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Text("Monthly",
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SECONDARY,
                                        fontSize: 16,
                                        fontFamily: Constants.GILROY_BOLD)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.colorDivider,
                        height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(AppText.FEATURES_COLON, style: textStyle),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(AppText.SECURELY_GATED,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(AppText.CCTV.toUpperCase(),
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.DISABLED_ACCESS,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.LIGHTING,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(AppText.AIRPORT_TRANSFERS,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.WIFI,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.SHELTERED,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isSecurelyGated =
                                                  !isSecurelyGated;
                                              bloc.updateSearchFilterSecurelyGated(
                                                  isSecurelyGated);
                                              setState(() {});
                                            },
                                            child: isSecurelyGated
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isCctv = !isCctv;
                                              bloc.updateSearchFilterCctv(
                                                  isCctv);
                                              setState(() {});
                                            },
                                            child: isCctv
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isDisabledAccess =
                                                  !isDisabledAccess;
                                              bloc.updateSearchFilterDisabledAccess(
                                                  isDisabledAccess);
                                              stateSetter(() {});
                                            },
                                            child: isDisabledAccess
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isLighting = !isLighting;
                                              bloc.updateSearchFilterLighting(
                                                  isLighting);
                                              stateSetter(() {});
                                            },
                                            child: isLighting
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isAirportTransfers =
                                                  !isAirportTransfers;
                                              bloc.updateSearchFilterAirportTransfers(
                                                  isAirportTransfers);
                                              stateSetter(() {});
                                            },
                                            child: isAirportTransfers
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isWifi = !isWifi;
                                              bloc.updateSearchFilterWifi(
                                                  isWifi);
                                              stateSetter(() {});
                                            },
                                            child: isWifi
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isSheltered = !isSheltered;
                                              bloc.updateSearchFilterSheltered(
                                                  isSheltered);
                                              stateSetter(() {});
                                            },
                                            child: isSheltered
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: Constants.colorDivider,
                          width: 1,
                          height: size.height * 0.35,
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(AppText.PARKING_TYPES, style: textStyle),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(AppText.DRIVEWAY,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.GARAGE,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.LAND_GRASS_PARKING,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.CAR_PARK_LOT,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        const Text(AppText.ON_STREET,
                                            style: switchTextStyle),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isDriveway = !isDriveway;
                                              bloc.updateSearchFilterDriveway(
                                                  isDriveway);
                                              stateSetter(() {});
                                            },
                                            child: isDriveway
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isGarage = !isGarage;
                                              bloc.updateSearchFilterGarage(
                                                  isGarage);
                                              stateSetter(() {});
                                            },
                                            child: isGarage
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isLandGrassParking =
                                                  !isLandGrassParking;
                                              stateSetter(() {});
                                              bloc.updateSearchFilterLandGrassParking(
                                                  isLandGrassParking);
                                            },
                                            child: isLandGrassParking
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isCarPark = !isCarPark;
                                              bloc.updateSearchFilterCarPark(
                                                  isCarPark);
                                              stateSetter(() {});
                                            },
                                            child: isCarPark
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                        StatefulBuilder(
                                          builder: (_, stateSetter) => InkWell(
                                            onTap: () async {
                                              isOnStreet = !isOnStreet;
                                              bloc.updateSearchFilterOnStreet(
                                                  isOnStreet);
                                              stateSetter(() {});
                                            },
                                            child: isOnStreet
                                                ? SvgPicture.asset(
                                                    "assets/ev_on.svg",
                                                    height: 20)
                                                : Image.asset(
                                                    "assets/ev_off.png",
                                                    height: 20,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 19,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 5),
                          child: RawMaterialButton(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              constraints: BoxConstraints(minHeight: 40),
                              onPressed: () {
                                Navigator.pop(context);
                                bloc.applyFilters(true);
                                onApplyFilter.call();
                              },
                              fillColor: Constants.COLOR_PRIMARY,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, left: 18, right: 18),
                                child: Text(
                                    AppText.APPLY_TO_SEARCH.toUpperCase(),
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 16)),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20, left: 5),
                          child: RawMaterialButton(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              constraints: BoxConstraints(minHeight: 40),
                              onPressed: () {
                                // Navigator.pop(context);
                                // bloc.applyFilters(true);
                                // onApplyFilter.call();

                                isSecurelyGated = false;
                                isCctv = false;
                                isDisabledAccess = false;
                                isLighting = false;
                                isElectricVehicleCharging = false;
                                isWifi = false;
                                isSheltered = false;
                                isAirportTransfers = false;
                                isDriveway = false;
                                isGarage = false;
                                isLandGrassParking = false;
                                isOnStreet = false;
                                isCarPark = false;
                                bloc.clearAllFilters();
                                setState(() {});
                              },
                              fillColor: Constants.COLOR_ON_PRIMARY,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, left: 20, right: 20),
                                child: Text(AppText.CLEAR_FILTERS.toUpperCase(),
                                    style: const TextStyle(
                                        color: Constants.COLOR_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 16)),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ],
          );
        });
      },
    ).whenComplete(() {
      bloc.showFilterView(false);
    });

    /*return Scaffold.of(context).showBottomSheet(
        (_) => DraggableScrollableSheet(
              builder: (_, ScrollController scrollController) {
                return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(AppText.FILTERS, style: textStyle),
                      ),
                      const Text(AppText.PARKING_TYPE_QUESTION,
                          style: TextStyle(
                              color: Constants.COLOR_BLACK,
                              fontSize: 16,
                              fontFamily: Constants.GILROY_MEDIUM)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  bloc.applyFilters(false);
                                  bloc.updatePackageSelected("");
                                  onApplyFilter.call();
                                  setState(() {});
                                },
                                child: Container(
                                  width: size.width * 0.38,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: bloc.state.packageSelected != "monthly"
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_GREY_300,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Text("Short Term",
                                        style: TextStyle(
                                            color: Constants.COLOR_ON_SECONDARY,
                                            fontSize: 16,
                                            fontFamily: Constants.GILROY_BOLD)),
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                bloc.applyFilters(false);
                                bloc.updatePackageSelected("monthly");
                                onApplyFilter.call();
                                setState(() {});
                              },
                              child: Container(
                                width: size.width * 0.38,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: bloc.state.packageSelected == "monthly"
                                      ? Constants.COLOR_PRIMARY
                                      : Constants.COLOR_GREY_300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text("Monthly",
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_SECONDARY,
                                          fontSize: 16,
                                          fontFamily: Constants.GILROY_BOLD)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          color: Constants.colorDivider,
                          height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Text(AppText.FEATURES_COLON,
                                      style: textStyle),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(AppText.SECURELY_GATED,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(AppText.CCTV.toUpperCase(),
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.DISABLED_ACCESS,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.LIGHTING,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(AppText.AIRPORT_TRANSFERS,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.WIFI,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.SHELTERED,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isSecurelyGated =
                                                    !isSecurelyGated;
                                                bloc.updateSearchFilterSecurelyGated(
                                                    !isSecurelyGated);
                                                setState(() {});
                                              },
                                              child: isSecurelyGated
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isCctv = !isCctv;
                                                bloc.updateSearchFilterCctv(
                                                    isCctv);
                                                setState(() {});
                                              },
                                              child: isCctv
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isDisabledAccess =
                                                    !isDisabledAccess;
                                                bloc.updateSearchFilterCctv(
                                                    isDisabledAccess);
                                                stateSetter(() {});
                                              },
                                              child: isDisabledAccess
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isLighting = !isLighting;
                                                bloc.updateSearchFilterLighting(
                                                    isLighting);
                                                stateSetter(() {});
                                              },
                                              child: isLighting
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isAirportTransfers =
                                                    !isAirportTransfers;
                                                bloc.updateSearchFilterAirportTransfers(
                                                    isAirportTransfers);
                                                stateSetter(() {});
                                              },
                                              child: isAirportTransfers
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isWifi = !isWifi;
                                                bloc.updateSearchFilterWifi(
                                                    isWifi);
                                                stateSetter(() {});
                                              },
                                              child: isWifi
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isSheltered = !isSheltered;
                                                bloc.updateSearchFilterSheltered(
                                                    isSheltered);
                                                stateSetter(() {});
                                              },
                                              child: isSheltered
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: Constants.colorDivider,
                            width: 1,
                            height: size.height * 0.35,
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Text(AppText.PARKING_TYPES, style: textStyle),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(AppText.DRIVEWAY,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.GARAGE,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.LAND_GRASS_PARKING,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.CAR_PARK_LOT,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const Text(AppText.ON_STREET,
                                              style: switchTextStyle),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isDriveway = !isDriveway;
                                                bloc.updateSearchFilterDriveway(
                                                    isDriveway);
                                                stateSetter(() {});
                                              },
                                              child: isDriveway
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isGarage = !isGarage;
                                                bloc.updateSearchFilterGarage(
                                                    isGarage);
                                                stateSetter(() {});
                                              },
                                              child: isGarage
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isLandGrassParking =
                                                    !isLandGrassParking;
                                                stateSetter(() {});
                                                bloc.updateSearchFilterLandGrassParking(
                                                    isLandGrassParking);
                                              },
                                              child: isLandGrassParking
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isCarPark = !isCarPark;
                                                bloc.updateSearchFilterCarPark(
                                                    isCarPark);
                                                stateSetter(() {});
                                              },
                                              child: isCarPark
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                          StatefulBuilder(
                                            builder: (_, stateSetter) =>
                                                InkWell(
                                              onTap: () async {
                                                isOnStreet = !isOnStreet;
                                                bloc.updateSearchFilterOnStreet(
                                                    isOnStreet);
                                                stateSetter(() {});
                                              },
                                              child: isOnStreet
                                                  ? SvgPicture.asset(
                                                      "assets/ev_on.svg",
                                                      height: 20)
                                                  : Image.asset(
                                                      "assets/ev_off.png",
                                                      height: 20,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 19,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RawMaterialButton(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            constraints: BoxConstraints(
                                minWidth: size.width - 90, minHeight: 40),
                            onPressed: () {
                              Navigator.pop(context);
                              bloc.applyFilters(true);
                              onApplyFilter.call();
                            },
                            fillColor: Constants.COLOR_PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(AppText.APPLY_TO_SEARCH.toUpperCase(),
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16)),
                            )),
                      ),
                    ],
                  ),
                );
              });
              },
              maxChildSize: 0.75,
              initialChildSize: 0.75,

              expand: false,
            ),
        backgroundColor: Constants.COLOR_SURFACE,
        elevation: 20,
        shape: _sheetBorder);*/
  }

  void showListSelectSheet(
      List<String> items, String selectedItem, Function(String) onSelection) {
    final context = _context;
    if (context == null) return null;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (_) => Wrap(
              children: mapIndexed(
                  items,
                  (index, item) => InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onSelection.call(item as String);
                      },
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        child: Text(item as String,
                            style: TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: item == selectedItem
                                    ? Constants.GILROY_BOLD
                                    : Constants.GILROY_REGULAR,
                                fontSize: 16)),
                      ))).toList(),
            ));
  }

  PersistentBottomSheetController? showConnectorTypeBottomSheet(
      HomeNavigationScreenBloc bloc, Function(int? index) onDone) {
    final context = _context;
    if (context == null) return null;
    const textStyle = TextStyle(
        color: Constants.COLOR_SURFACE,
        fontFamily: Constants.GILROY_LIGHT,
        fontSize: 15);
    int initialStateType = bloc.state.lastConnectorIndex;
    return Scaffold.of(context).showBottomSheet((context) {
      return Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          StatefulBuilder(
            builder: (_, stateSetter) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: SvgPicture.asset(
                      "assets/arrow_down_green.svg",
                    )),
                const Text(AppText.SELECT_YOUR_CONNECTOR_TYPE,
                    style: TextStyle(
                        color: Constants.COLOR_PRIMARY,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 1) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 1);
                            bloc.updateLastConnectorIndex(1);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_one_icon.png'),
                                  height: 50),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 1
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.TESLA_US, style: textStyle))
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 4) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 4);
                            bloc.updateLastConnectorIndex(4);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_fourth_icon.png'),
                                  height: 50),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 4
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.CHADEMO, style: textStyle))
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 2) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 2);
                            bloc.updateLastConnectorIndex(2);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_two_icon.png'),
                                  height: 50,
                                  fit: BoxFit.fill),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 2
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.TYPE_ONE, style: textStyle))
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 5) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 5);
                            bloc.updateLastConnectorIndex(5);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_five_icon.png'),
                                  height: 50,
                                  fit: BoxFit.fill),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 5
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.COMBO_ONE, style: textStyle))
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 3) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 3);
                            bloc.updateLastConnectorIndex(3);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_three_icon.png'),
                                  height: 50,
                                  fit: BoxFit.fill),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 3
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.TYPE_TWO, style: textStyle))
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (initialStateType == 6) {
                              stateSetter(() => initialStateType = 0);
                              bloc.updateLastConnectorIndex(0);
                              return;
                            }
                            stateSetter(() => initialStateType = 6);
                            bloc.updateLastConnectorIndex(6);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: AssetImage(
                                      'assets/ev_sheet_type_six_icon.png'),
                                  height: 50,
                                  fit: BoxFit.fill),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: initialStateType == 6
                                          ? Constants.COLOR_SECONDARY
                                          : Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.5),
                                      shape: BoxShape.rectangle),
                                  child:
                                      Text(AppText.COMBO_TWO, style: textStyle))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 0.8,
                  width: MediaQuery.of(context).size.width - 50,
                  color: Constants.COLOR_GREY,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppText.SHOW_EV_SPACES_ONLY,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontSize: 16,
                              fontFamily: Constants.GILROY_REGULAR)),
                      SizedBox(
                        width: 5,
                      ),
                      Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                              activeColor: Constants.COLOR_PRIMARY,
                              value: bloc.state.evSwitch,
                              onChanged: (bool? newValue) {
                                if (newValue == null) return;
                                // bloc.updateEvSwitch(newValue);
                                // bloc.updateisEVEnable(newValue);
                                stateSetter(() {});
                              })),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 46,
                    child: RawMaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        onPressed: () {
                          Navigator.pop(context);
                          onDone(initialStateType);
                        },
                        fillColor: Constants.COLOR_PRIMARY,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                                image: AssetImage(
                                    'assets/location_switch_icon.png')),
                            Text(
                                AppText.SHOW_ME_EV_PARKING_SPACES.toUpperCase(),
                                style: TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontSize: 14,
                                    fontFamily: Constants.GILROY_REGULAR)),
                          ],
                        )),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ],
      );
    },
        backgroundColor: Constants.COLOR_SURFACE,
        elevation: 20,
        shape: _sheetBorder);
  }

  var selectedDateTime;
  var selectedEndDateTime;
  var parkingSlotTimePicker = getAdditionOfTime(DateTime.now(), 15);
  bool parkingSlotClicked = false;
  var dateSelection = TextEditingController();
  var parkingSlotStartTime = TextEditingController();
  var parkingSlotEndTime = TextEditingController();
  var formattedEndTime;
  var parkingSlotEndTimeSelected;

  String totalDuration = "";
  String totalPrice = "";

  Function priceButtonStateSetter = () {};
  Function totalDurationStateSetter = () {};
  Function totalPriceStateSetter = () {};
  Function tabControllerStateSetter = () {};
  Function parkingErrorStateSetter = () {};

  void showParkingDetailBottomSheet(
      ParkingSpaceDetail spaceDetail,
      LocationData currentLocation,
      List<Reviews> reviews,
      double initialSize,
      HomeNavigationScreenBloc bloc,
      BuildContext context,
      String duration) async {
    final userType = SharedPreferenceHelper.instance.userType;

    Future<void> share() async {
      await FlutterShare.share(
          title: 'Example share',
          text: 'Example share text',
          linkUrl: 'https://flutter.dev/',
          chooserTitle: 'Example Chooser Title');
    }

    // setSpaceTimings...
    selectedDateTime = nearestQuarter(DateTime.now());

    if (bloc.state.parkingSpaceStartDateTime.isNotEmpty) {
      selectedEndDateTime = DateTime.parse(bloc.state.parkingSpaceEndDateTime);
    } else {
      selectedEndDateTime = getAdditionOfTime(selectedDateTime, 60);
    }

    bloc.updateParkingTimings(
        selectedDateTime.toString(), selectedEndDateTime.toString());
    // setSpaceTimings end...

    final tempContext = _context;
    if (tempContext == null) return;
    final reservableAddressTextSpanChildren = <InlineSpan>[];

    /*if (spaceDetail.isReservable) {
      reservableAddressTextSpanChildren.add(TextSpan(
          text: '${AppText.RESERVABLE} ',
          style: const TextStyle(
              color: Constants.COLOR_PRIMARY,
              fontFamily: Constants.GILROY_BOLD,
              fontSize: 14)));
    }*/

    final addressSplits = spaceDetail.address.split(',');
    late String address;
    if (addressSplits.length <= 3)
      address = addressSplits.map((e) => e.trimLeft().trimRight()).join(' ');
    else {
      try {
        final lastHalfParts = addressSplits.reversed
            .toList()
            .sublist(0, 3)
            .reversed
            .map((e) => e.trimLeft().trimRight());
        address = lastHalfParts.join(' ');
      } catch (_) {
        address = spaceDetail.address;
      }
    }

    reservableAddressTextSpanChildren.add(TextSpan(
        text: '${spaceDetail.parkingType} ',
        style: TextStyle(
          fontSize: 16,
          fontFamily: Constants.GILROY_MEDIUM,
          color: Constants.COLOR_BLACK,
        )));

    reservableAddressTextSpanChildren.add(TextSpan(
      text: "   $address",
      style: TextStyle(
          fontSize: 16,
          fontFamily: Constants.GILROY_MEDIUM,
          color: Constants.COLOR_BLACK_200,
          overflow: TextOverflow.ellipsis),
    ));

    final rating =
        spaceDetail.reviews.count<Reviews>((element) => element.rating) /
            spaceDetail.reviews.length;

    final ratingTextSpanChildren = <InlineSpan>[];

    ratingTextSpanChildren.add(WidgetSpan(
        child: RatingBar.builder(
            initialRating: rating.isNaN ? 0 : rating,
            minRating: 4,
            ignoreGestures: true,
            direction: Axis.horizontal,
            itemSize: 20,
            unratedColor: Constants.colorDivider,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, index) => const Icon(Icons.star,
                size: 20, color: Constants.COLOR_SECONDARY),
            onRatingUpdate: (rating) {})));

    ratingTextSpanChildren.add(TextSpan(
        text: ' (${spaceDetail.reviews.length}) ',
        style: const TextStyle(
            color: Constants.COLOR_GREY,
            fontFamily: Constants.GILROY_REGULAR,
            fontSize: 13)));
    ratingTextSpanChildren.add(TextSpan(
        text: '${spaceDetail.totalBookings} booking this month',
        style: TextStyle(
            color: Constants.COLOR_ON_SURFACE,
            fontFamily: Constants.GILROY_REGULAR,
            fontSize: 13)));

    Widget destinationWidget = const SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: Constants.COLOR_ON_PRIMARY));

    final dateFormat = new DateFormat('dd MMM');
    final timeFormat = new DateFormat('hh:mma');
    final List<Function> distanceMatrixStateSetter = [];

    TextEditingController destinationText = TextEditingController();

    String parkingTimeError = '';
    final currentDatetime = DateTime.now();
    DateTime parkingFrom = currentDatetime.add(Duration(minutes: 15));
    DateTime parkingUntil = parkingFrom.add(Duration(hours: 1));
    var fav = false;

    if (duration.isEmpty) {
      _sharedWebService
          .calculateDistanceResult(
              currentLocation.latitude!,
              currentLocation.longitude!,
              spaceDetail.latitude.toDouble(),
              spaceDetail.longitude.toDouble(),
              Constants.GOOGLE_DISTANCE_MATRIX_API_KEY)
          .then((value) {
        destinationText.text = value.durationText;

        distanceMatrixStateSetter.forEach((e) => e.call(() {}));
      }).catchError((_, __) {
        destinationWidget = const Text('------',
            style: const TextStyle(
                fontSize: 12,
                fontFamily: Constants.GILROY_BOLD,
                color: Constants.COLOR_ERROR));
        distanceMatrixStateSetter.forEach((e) => e.call(() {}));
      });
    } else {
      destinationText.text = duration;
    }

    totalDuration = parkingUntil.difference(parkingFrom).formattedDuration;
    totalPrice = spaceDetail.getCalculatedPrice(parkingUntil, parkingFrom);

    /*Function priceButtonStateSetter = () {};
    Function totalDurationStateSetter = () {};
    Function totalPriceStateSetter = () {};
    Function tabControllerStateSetter = () {};
    Function parkingErrorStateSetter = () {};*/
    var currentScrollState = initialSize;

    int currentIndex = 0;
    showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: tempContext,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        builder: (BuildContext bc) {
          return BlocProvider.value(
              value: BlocProvider.of<HomeNavigationScreenBloc>(context),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                var size = MediaQuery.of(context).size;
                return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      print("${notification.extent}");
                      currentScrollState = notification.extent;
                      setState(() {});
                      return false;
                    },
                    child: DraggableScrollableActuator(
                      child: DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: initialSize,
                        minChildSize: 0.15,
                        maxChildSize: 0.91,
                        builder: (BuildContext context, controller) {
                          return ListView(
                            controller: controller,
                            children: [
                              GestureDetector(
                                  onTap: () => Navigator.pop(tempContext),
                                  child: Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (currentScrollState < 0.6) {
                                            initialSize = 0.91;
                                            currentScrollState = 0.91;
                                            Navigator.of(context).pop();
                                            showParkingDetailBottomSheet(
                                                spaceDetail,
                                                currentLocation,
                                                reviews,
                                                initialSize,
                                                bloc,
                                                context,
                                                destinationText.text);
                                            // setState(() {});

                                          } else if (currentScrollState > 0.6) {
                                            initialSize = 0.15;
                                            currentScrollState = 0.15;
                                            Navigator.of(context).pop();
                                            showParkingDetailBottomSheet(
                                                spaceDetail,
                                                currentLocation,
                                                reviews,
                                                initialSize,
                                                bloc,
                                                context,
                                                destinationText.text);
                                            // setState(() {});
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Center(
                                              child: SvgPicture.asset(
                                            currentScrollState > 0.6
                                                ? "assets/pull_icon_bottomsheet.svg"
                                                : "assets/pull_up_arrow.svg",
                                            height: 14,
                                          )),
                                        ),
                                      ),
                                      Positioned(
                                          top: 14,
                                          right: 45,
                                          child: InkWell(
                                            onTap: () {
                                              fav = !fav;
                                              setState(() {});
                                            },
                                            child: SvgPicture.asset(
                                              "assets/search_heart_icon_.svg",
                                              height: 18,
                                              color: fav
                                                  ? Constants.COLOR_ERROR
                                                  : Constants.COLOR_GREY,
                                            ),
                                          )),
                                      Positioned(
                                          top: 12,
                                          right: 14,
                                          child: InkWell(
                                            onTap: () {
                                              share();
                                            },
                                            child: SvgPicture.asset(
                                              "assets/share_icon.svg",
                                              height: 20,
                                            ),
                                          )),
                                    ],
                                  )),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  spaceDetail.isReservable
                                      ? RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: SvgPicture.asset(
                                                  "assets/reserve_icon.svg",
                                                  height: 20,
                                                  color:
                                                      Constants.COLOR_PRIMARY,
                                                ),
                                              ),
                                              TextSpan(
                                                text: " RESERVABLE",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  color:
                                                      Constants.COLOR_PRIMARY,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: getProportionateScreenWidth(
                                        230, size.width),
                                    child: RichText(
                                      text: TextSpan(
                                          children:
                                              reservableAddressTextSpanChildren),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 22.0),
                                    child: RatingBar.builder(
                                        initialRating:
                                            rating.isNaN ? 0 : rating,
                                        ignoreGestures: true,
                                        direction: Axis.horizontal,
                                        itemSize: 20,
                                        unratedColor: Constants.colorDivider,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemBuilder: (context, index) =>
                                            const Icon(Icons.star,
                                                size: 20,
                                                color:
                                                    Constants.COLOR_SECONDARY),
                                        onRatingUpdate: (rating) {}),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "(${spaceDetail.reviews.length})",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "${spaceDetail.totalBookings} BOOKINGS THIS MONTH",
                                    style: TextStyle(
                                        color: Constants.COLOR_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              currentScrollState > 0.2
                                  ? SizedBox()
                                  : StatefulBuilder(builder: (_, stateSetter) {
                                      distanceMatrixStateSetter
                                          .add(stateSetter);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/walking_symbol.svg",
                                                height: 20,
                                                color: Constants.COLOR_PRIMARY,
                                              ),
                                              const SizedBox(width: 6),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Text(
                                                    destinationText.text,
                                                    //totalDuration
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: Constants
                                                            .GILROY_BOLD,
                                                        color: Constants
                                                            .COLOR_BLACK_200)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0, left: 6.0),
                                                child: Text("to destination",
                                                    //totalDuration
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: Constants
                                                            .GILROY_REGULAR,
                                                        color: Constants
                                                            .COLOR_BLACK_200)),
                                              ),
                                            ]),
                                      );
                                    }),
                              const SizedBox(height: 12),
                              Container(
                                width: MediaQuery.of(tempContext).size.width,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                color: Constants.COLOR_PRIMARY,
                                child: IntrinsicHeight(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Column(children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Text(AppText.TOTAL_DURATION,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.GILROY_MEDIUM,
                                              color:
                                                  Constants.COLOR_ON_PRIMARY)),
                                      const SizedBox(height: 6),
                                      StatefulBuilder(
                                          builder: (_, stateSetter) {
                                        totalDurationStateSetter = stateSetter;
                                        return Text(totalDuration,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                color: Constants
                                                    .COLOR_ON_SECONDARY));
                                      }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ])),
                                    VerticalDivider(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        width: 0.8,
                                        thickness: 2.5),
                                    Expanded(
                                        child: Column(children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(AppText.PRICE,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.GILROY_MEDIUM,
                                              color: Constants
                                                  .COLOR_ON_SECONDARY)),
                                      const SizedBox(height: 6),
                                      StatefulBuilder(
                                          builder: (_, stateSetter) {
                                        totalPriceStateSetter = stateSetter;
                                        return Text(
                                            totalPrice.startsWith('--')
                                                ? totalPrice
                                                : '\$$totalPrice',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                color: Constants
                                                    .COLOR_ON_SECONDARY));
                                      }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ])),
                                    VerticalDivider(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        width: 0.8,
                                        thickness: 2.5),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          const Text(AppText.TO_DESTINATION,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constants.GILROY_MEDIUM,
                                                  color: Constants
                                                      .COLOR_ON_SECONDARY)),
                                          const SizedBox(height: 0),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .directions_walk_outlined,
                                                    color: Constants
                                                        .COLOR_BACKGROUND,
                                                    size: 24),
                                                const SizedBox(width: 2),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                      destinationText.text,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: Constants
                                                              .GILROY_BOLD,
                                                          color: Constants
                                                              .COLOR_BACKGROUND)),
                                                )
                                              ]),

                                          /*StatefulBuilder(builder: (_, stateSetter) {
                                        distanceMatrixStateSetter
                                            .add(stateSetter);
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/walking_symbol.svg",
                                                height: 20,
                                              ),
                                              const SizedBox(width: 2),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Text(totalDuration,

                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            Constants.GILROY_BOLD,
                                                        color: Constants
                                                            .COLOR_ON_SECONDARY)),
                                              )
                                            ]);
                                      }),*/
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ]))
                                  ],
                                )),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("${AppText.STARTS}:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily:
                                                    Constants.GILROY_MEDIUM,
                                                color:
                                                    Constants.COLOR_PRIMARY)),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        StatefulBuilder(
                                            builder: (context, stateSetter) =>
                                                InkWell(
                                                  onTap: () async {
                                                    parkingSlotClicked = false;
                                                    bloc.state.hourlySelected =
                                                        true;
                                                    dateSelection.text =
                                                        "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

                                                    showBottomDateTimePicker(
                                                        context,
                                                        bloc,
                                                        spaceDetail);

                                                    /*  final date =
                                                    await Navigator.pushNamed(
                                                        context,
                                                        CustomDateTimePickerScreen
                                                            .route,
                                                        arguments: [
                                                      parkingFrom,
                                                      parkingFrom
                                                    ]);
                                                if (date == null) return;
                                                date as DateTime;
                                                stateSetter(
                                                    () => parkingFrom = date);
                                                if (parkingUntil.year != 1700 &&
                                                    parkingUntil
                                                        .isAfter(date)) {
                                                  totalPriceStateSetter(() =>
                                                      totalPrice = spaceDetail
                                                          .getCalculatedPrice(
                                                              parkingUntil,
                                                              parkingFrom));
                                                  tabControllerStateSetter
                                                      .call(() {});
                                                  priceButtonStateSetter
                                                      .call(() {});
                                                  totalDurationStateSetter(() =>
                                                      totalDuration = parkingUntil
                                                          .difference(
                                                              parkingFrom)
                                                          .formattedDuration);
                                                }
                                                parkingErrorStateSetter(() =>
                                                    parkingTimeError = '');*/
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Text(
                                                        parkingFrom.year == 1700
                                                            ? AppText.SELECT
                                                            : "${dateFormat.format(DateTime.parse(bloc.state.parkingSpaceStartDateTime))} at ${timeFormat.format(DateTime.parse(bloc.state.parkingSpaceStartDateTime))}",
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontFamily: Constants
                                                                .GILROY_BOLD,
                                                            color: Constants
                                                                .COLOR_BLACK_200)),
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      color: Constants.COLOR_ON_SURFACE),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("${AppText.ENDS}:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily:
                                                    Constants.GILROY_MEDIUM,
                                                color:
                                                    Constants.COLOR_PRIMARY)),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        StatefulBuilder(
                                            builder: (context, stateSetter) =>
                                                InkWell(
                                                  onTap: () async {
                                                    parkingSlotClicked = true;
                                                    bloc.state.hourlySelected =
                                                        true;
                                                    dateSelection.text =
                                                        "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";

                                                    showBottomDateTimePicker(
                                                        context,
                                                        bloc,
                                                        spaceDetail);

                                                    BlocListener<
                                                        HomeNavigationScreenBloc,
                                                        HomeNavigationScreenState>(
                                                      /*listenWhen: (previous,
                                                              current) =>
                                                          previous.parkingSpaceStartDateTime !=
                                                              current
                                                                  .parkingSpaceStartDateTime ||
                                                          previous.parkingSpaceEndDateTime !=
                                                              current
                                                                  .parkingSpaceEndDateTime,*/
                                                      listener: (_, state) {
                                                        print("yes.....");
                                                        totalPriceStateSetter(() =>
                                                            totalPrice = spaceDetail
                                                                .getCalculatedPrice(
                                                                    parkingUntil,
                                                                    parkingFrom));

                                                        tabControllerStateSetter
                                                            .call(() {});

                                                        priceButtonStateSetter
                                                            .call(() {});

                                                        totalDurationStateSetter(
                                                            () => totalDuration =
                                                                parkingUntil
                                                                    .difference(
                                                                        parkingFrom)
                                                                    .formattedDuration);
                                                      },
                                                    );

                                                    /*  final date =
                                                    await Navigator.pushNamed(
                                                        context,
                                                        CustomDateTimePickerScreen
                                                            .route,
                                                        arguments: [
                                                      parkingFrom,
                                                      parkingUntil
                                                    ]);

                                                if (date == null) return;
                                                date as DateTime;
                                                stateSetter(
                                                    () => parkingUntil = date);
                                                if (parkingFrom.year != 1700 &&
                                                    parkingFrom
                                                        .isBefore(date)) {
                                                  totalPriceStateSetter(() =>
                                                      totalPrice = spaceDetail
                                                          .getCalculatedPrice(
                                                              parkingUntil,
                                                              parkingFrom));
                                                  priceButtonStateSetter
                                                      .call(() {});
                                                  tabControllerStateSetter
                                                      .call(() {});
                                                  totalDurationStateSetter(() =>
                                                      totalDuration = parkingUntil
                                                          .difference(
                                                              parkingFrom)
                                                          .formattedDuration);
                                                }
                                                parkingErrorStateSetter(() =>
                                                    parkingTimeError = '');*/
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Text(
                                                        parkingUntil.year ==
                                                                1700
                                                            ? AppText.SELECT
                                                            : bloc.state.packageSelected ==
                                                                    "monthly"
                                                                ? "Monthly"
                                                                : "${dateFormat.format(DateTime.parse(bloc.state.parkingSpaceEndDateTime))} at ${timeFormat.format(DateTime.parse(bloc.state.parkingSpaceEndDateTime))}",
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontFamily: Constants
                                                                .GILROY_BOLD,
                                                            color: Constants
                                                                .COLOR_BLACK_200)),
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                height: 1,
                                width: MediaQuery.of(tempContext).size.width,
                                color: Constants.COLOR_GREY,
                              ),
                              StatefulBuilder(builder: (_, stateSetter) {
                                parkingErrorStateSetter = stateSetter;
                                if (parkingTimeError.isEmpty)
                                  return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(parkingTimeError,
                                          style: TextStyle(
                                              color: Constants.COLOR_ERROR,
                                              fontFamily:
                                                  Constants.GILROY_LIGHT,
                                              fontSize: 11))),
                                );
                              }),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 45,
                                child: DefaultTabController(
                                  length: 3,
                                  child: TabBar(
                                    onTap: (int index) {
                                      if (currentIndex == index) return;
                                      tabControllerStateSetter(
                                          () => currentIndex = index);
                                    },
                                    indicatorColor: Constants.COLOR_PRIMARY,
                                    indicator: UnderlineTabIndicator(
                                      borderSide: BorderSide(
                                          color: Constants.COLOR_PRIMARY,
                                          width: 4.0),
                                      insets: EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, 0.0),
                                    ),
                                    labelColor: Constants.COLOR_BLACK_200,
                                    labelStyle: TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 16),
                                    unselectedLabelColor: Constants.COLOR_GREY,
                                    tabs: [
                                      const Tab(
                                          child: Text(AppText.INFORMATION,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD))),
                                      const Tab(
                                          child: Text(AppText.REVIEWS,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD))),
                                      const Tab(
                                          child: Text(AppText.HOW_IT_WORKS,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD)))
                                    ],
                                  ),
                                ),
                              ),
                              StatefulBuilder(builder: (_, stateSetter) {
                                tabControllerStateSetter = stateSetter;
                                if (currentIndex == 0)
                                  return _InformationTab(
                                      spaceDetail: spaceDetail);
                                else if (currentIndex == 1)
                                  return _ReviewsTab(reviews: reviews);
                                else if (currentIndex == 2)
                                  return const HowItWorksTab();
                                else
                                  return const SizedBox();
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child:
                                    StatefulBuilder(builder: (_, stateSetter) {
                                  priceButtonStateSetter = stateSetter;
                                  return RawMaterialButton(
                                      elevation:
                                          userType == UserType.host ? 0 : 4,
                                      constraints: BoxConstraints(
                                          minWidth: MediaQuery.of(tempContext)
                                                  .size
                                                  .width -
                                              30,
                                          minHeight: 45),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      onPressed: () async {
                                        if (userType == UserType.host) return;

                                        final VoidCallback buttonCallback =
                                            () async {
                                          if (parkingFrom.year == 1700) {
                                            parkingErrorStateSetter(() =>
                                                parkingTimeError = AppText
                                                    .PLEASE_SELECT_PARKING_FROM_FIRST);
                                            totalPriceStateSetter(
                                                () => totalPrice = '----');
                                            return;
                                          }
                                          if (parkingUntil.year == 1700) {
                                            parkingErrorStateSetter(() =>
                                                parkingTimeError = AppText
                                                    .PLEASE_SELECT_PARKING_UNTIL_FIRST);
                                            totalPriceStateSetter(
                                                () => totalPrice = '----');
                                            return;
                                          }
                                          if (parkingFrom
                                              .isAfter(parkingUntil)) {
                                            parkingErrorStateSetter(() =>
                                                parkingTimeError = AppText
                                                    .PARKING_FROM_NEEDS_TO_BE_LESS_THAN_PARKING_UNTIL);
                                            totalPriceStateSetter(
                                                () => totalPrice = '----');
                                            return;
                                          }
                                          final user =
                                              await SharedPreferenceHelper
                                                  .instance
                                                  .user();

                                          Navigator.pushNamed(tempContext,
                                              SecureCheckoutScreen.route,
                                              arguments: {
                                                Constants.SPACE_DETAIL:
                                                    spaceDetail,
                                                Constants.SPACE_TOTAL_DURATION:
                                                    totalDuration,
                                                Constants.SPACE_DESTINATION:
                                                    destinationText.text,
                                                Constants.TOTAL_PRICE:
                                                    totalPrice,
                                                Constants.PARKING_FROM:
                                                    parkingFrom,
                                                Constants.PARKING_UNTIL:
                                                    parkingUntil,
                                                Constants.PARKING_SPACE_ID:
                                                    spaceDetail.id,
                                                Constants.DRIVER_DETAIL_NAME:
                                                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                                                Constants.DRIVER_DETAIL_EMAIL:
                                                    user?.email ?? '',
                                                Constants.DRIVER_DETAIL_PHONE:
                                                    user?.phoneNumber ?? ''
                                              });
                                        };
                                        // buttonCallback.call();

                                        Flushbar(
                                          backgroundColor: Colors.black,
                                          message: "Under Construction",
                                          duration: Duration(seconds: 2),
                                        ).show(context);
                                      },
                                      fillColor: userType == UserType.host
                                          ? Constants.COLOR_PRIMARY
                                              .withOpacity(0.4)
                                          : Constants.COLOR_PRIMARY,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 12),
                                        child: Text(
                                            "Book for ${totalPrice.startsWith('---') ? totalPrice : '\$$totalPrice'}",
                                            style: const TextStyle(
                                                color:
                                                    Constants.COLOR_ON_PRIMARY,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                fontSize: 16)),
                                      ));

                                  AppButton(
                                    text:
                                        'Book for ${totalPrice.startsWith('---') ? totalPrice : '\$$totalPrice'}',
                                    cornerRadius: 10,
                                    onClick: () {},
                                    fillColor: Constants.COLOR_PRIMARY,
                                  );
                                }),
                              ),
                              const SizedBox(height: 15)
                            ],
                          );
                        },
                      ),
                    ));

                DraggableScrollableSheet(
                  expand: false,
                  maxChildSize: 0.9,
                  initialChildSize: 0.19,
                  minChildSize: 0.1,
                  builder: (_, controller) => Column(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(tempContext),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Center(
                                    child: SvgPicture.asset(
                                  "assets/pull_icon_bottomsheet.svg",
                                  height: 14,
                                )),
                              ),
                              Positioned(
                                  top: 14,
                                  right: 45,
                                  child: InkWell(
                                    onTap: () {
                                      fav = !fav;
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(
                                      "assets/search_heart_icon_.svg",
                                      height: 18,
                                      color: fav
                                          ? Constants.COLOR_ERROR
                                          : Constants.COLOR_GREY,
                                    ),
                                  )),
                              Positioned(
                                  top: 12,
                                  right: 14,
                                  child: InkWell(
                                    onTap: () {},
                                    child: SvgPicture.asset(
                                      "assets/share_icon.svg",
                                      height: 20,
                                    ),
                                  )),
                            ],
                          )),
                      Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  spaceDetail.isReservable
                                      ? RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: SvgPicture.asset(
                                                  "assets/reserve_icon.svg",
                                                  height: 20,
                                                  color:
                                                      Constants.COLOR_PRIMARY,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "  RESERVABLE",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  color:
                                                      Constants.COLOR_PRIMARY,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Driveway",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: Constants.GILROY_MEDIUM,
                                      color: Constants.COLOR_BLACK,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 165,
                                    child: Text(
                                      "$address $address $address $address $address $address ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: Constants.GILROY_MEDIUM,
                                          color: Constants.COLOR_BLACK_200,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 22.0),
                                    child: RatingBar.builder(
                                        initialRating:
                                            rating.isNaN ? 0 : rating,
                                        ignoreGestures: true,
                                        direction: Axis.horizontal,
                                        itemSize: 20,
                                        unratedColor: Constants.colorDivider,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemBuilder: (context, index) =>
                                            const Icon(Icons.star,
                                                size: 20,
                                                color:
                                                    Constants.COLOR_SECONDARY),
                                        onRatingUpdate: (rating) {}),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "(${spaceDetail.reviews.length})",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "${spaceDetail.totalBookings} BOOKINGS THIS MONTH",
                                    style: TextStyle(
                                        color: Constants.COLOR_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: MediaQuery.of(tempContext).size.width,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                color: Constants.COLOR_PRIMARY,
                                child: IntrinsicHeight(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Column(children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Text(AppText.TOTAL_DURATION,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.GILROY_MEDIUM,
                                              color:
                                                  Constants.COLOR_ON_PRIMARY)),
                                      const SizedBox(height: 6),
                                      StatefulBuilder(
                                          builder: (_, stateSetter) {
                                        totalDurationStateSetter = stateSetter;
                                        return Text(totalDuration,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                color: Constants
                                                    .COLOR_ON_SECONDARY));
                                      }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ])),
                                    VerticalDivider(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        width: 0.8,
                                        thickness: 2.5),
                                    Expanded(
                                        child: Column(children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(AppText.PRICE,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.GILROY_MEDIUM,
                                              color: Constants
                                                  .COLOR_ON_SECONDARY)),
                                      const SizedBox(height: 6),
                                      StatefulBuilder(
                                          builder: (_, stateSetter) {
                                        totalPriceStateSetter = stateSetter;
                                        return Text(
                                            totalPrice.startsWith('--')
                                                ? totalPrice
                                                : '\$$totalPrice',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                color: Constants
                                                    .COLOR_ON_SECONDARY));
                                      }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ])),
                                    VerticalDivider(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        width: 0.8,
                                        thickness: 2.5),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          const Text(AppText.TO_DESTINATION,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constants.GILROY_MEDIUM,
                                                  color: Constants
                                                      .COLOR_ON_SECONDARY)),
                                          const SizedBox(height: 0),
                                          StatefulBuilder(
                                              builder: (_, stateSetter) {
                                            distanceMatrixStateSetter
                                                .add(stateSetter);
                                            return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/walking_symbol.svg",
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6.0),
                                                    child: Text("4 mins",
                                                        //totalDuration
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontFamily: Constants
                                                                .GILROY_BOLD,
                                                            color: Constants
                                                                .COLOR_ON_SECONDARY)),
                                                  )
                                                ]);
                                          }),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ]))
                                  ],
                                )),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text("${AppText.STARTS}:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                        Constants.GILROY_MEDIUM,
                                                    color: Constants
                                                        .COLOR_PRIMARY)),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            StatefulBuilder(
                                                builder: (context,
                                                        stateSetter) =>
                                                    InkWell(
                                                      onTap: () async {
                                                        final date = await Navigator
                                                            .pushNamed(
                                                                context,
                                                                CustomDateTimePickerScreen
                                                                    .route,
                                                                arguments: [
                                                              parkingFrom,
                                                              parkingFrom
                                                            ]);
                                                        if (date == null)
                                                          return;
                                                        date as DateTime;
                                                        stateSetter(() =>
                                                            parkingFrom = date);
                                                        if (parkingUntil.year !=
                                                                1700 &&
                                                            parkingUntil
                                                                .isAfter(
                                                                    date)) {
                                                          totalPriceStateSetter(
                                                              () => totalPrice =
                                                                  spaceDetail.getCalculatedPrice(
                                                                      parkingUntil,
                                                                      parkingFrom));
                                                          tabControllerStateSetter
                                                              .call(() {});
                                                          priceButtonStateSetter
                                                              .call(() {});
                                                          totalDurationStateSetter(
                                                              () => totalDuration =
                                                                  parkingUntil
                                                                      .difference(
                                                                          parkingFrom)
                                                                      .formattedDuration);
                                                        }
                                                        parkingErrorStateSetter(
                                                            () =>
                                                                parkingTimeError =
                                                                    '');
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 3),
                                                        child: Text(
                                                            parkingFrom.year ==
                                                                    1700
                                                                ? AppText.SELECT
                                                                : "${dateFormat.format(parkingFrom)} at ${timeFormat.format(parkingFrom)}",
                                                            style: const TextStyle(
                                                                fontSize: 14.0,
                                                                fontFamily:
                                                                    Constants
                                                                        .GILROY_BOLD,
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                      ),
                                                    )),
                                          ],
                                        ),
                                      )),
                                  const Icon(Icons.arrow_forward,
                                      color: Constants.COLOR_ON_SURFACE),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text("${AppText.ENDS}:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                        Constants.GILROY_MEDIUM,
                                                    color: Constants
                                                        .COLOR_PRIMARY)),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            StatefulBuilder(
                                                builder: (context,
                                                        stateSetter) =>
                                                    InkWell(
                                                      onTap: () async {
                                                        final date = await Navigator
                                                            .pushNamed(
                                                                context,
                                                                CustomDateTimePickerScreen
                                                                    .route,
                                                                arguments: [
                                                              parkingFrom,
                                                              parkingUntil
                                                            ]);
                                                        if (date == null)
                                                          return;
                                                        date as DateTime;
                                                        stateSetter(() =>
                                                            parkingUntil =
                                                                date);
                                                        if (parkingFrom.year !=
                                                                1700 &&
                                                            parkingFrom
                                                                .isBefore(
                                                                    date)) {
                                                          totalPriceStateSetter(
                                                              () => totalPrice =
                                                                  spaceDetail.getCalculatedPrice(
                                                                      parkingUntil,
                                                                      parkingFrom));
                                                          priceButtonStateSetter
                                                              .call(() {});
                                                          tabControllerStateSetter
                                                              .call(() {});
                                                          totalDurationStateSetter(
                                                              () => totalDuration =
                                                                  parkingUntil
                                                                      .difference(
                                                                          parkingFrom)
                                                                      .formattedDuration);
                                                        }
                                                        parkingErrorStateSetter(
                                                            () =>
                                                                parkingTimeError =
                                                                    '');
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 3),
                                                        child: Text(
                                                            parkingUntil.year ==
                                                                    1700
                                                                ? AppText.SELECT
                                                                : "${dateFormat.format(parkingUntil)} at ${timeFormat.format(parkingUntil)}",
                                                            style: const TextStyle(
                                                                fontSize: 14.0,
                                                                fontFamily:
                                                                    Constants
                                                                        .GILROY_BOLD,
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                      ),
                                                    )),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    width: 15,
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                height: 1,
                                width: MediaQuery.of(tempContext).size.width,
                                color: Constants.COLOR_GREY,
                              ),
                              StatefulBuilder(builder: (_, stateSetter) {
                                parkingErrorStateSetter = stateSetter;
                                if (parkingTimeError.isEmpty)
                                  return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(parkingTimeError,
                                          style: TextStyle(
                                              color: Constants.COLOR_ERROR,
                                              fontFamily:
                                                  Constants.GILROY_LIGHT,
                                              fontSize: 11))),
                                );
                              }),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 45,
                                child: DefaultTabController(
                                  length: 3,
                                  child: TabBar(
                                    onTap: (int index) {
                                      if (currentIndex == index) return;
                                      tabControllerStateSetter(
                                          () => currentIndex = index);
                                    },
                                    indicatorColor: Constants.COLOR_PRIMARY,
                                    indicator: UnderlineTabIndicator(
                                      borderSide: BorderSide(
                                          color: Constants.COLOR_PRIMARY,
                                          width: 4.0),
                                      insets: EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, 0.0),
                                    ),
                                    labelColor: Constants.COLOR_BLACK_200,
                                    labelStyle: TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 16),
                                    unselectedLabelColor: Constants.COLOR_GREY,
                                    tabs: [
                                      const Tab(
                                          child: Text(AppText.INFORMATION,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD))),
                                      const Tab(
                                          child: Text(AppText.REVIEWS,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD))),
                                      const Tab(
                                          child: Text(AppText.HOW_IT_WORKS,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD)))
                                    ],
                                  ),
                                ),
                              ),

                              /*Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: DefaultTabController(
                                    length: 3,
                                    child: TabBar(
                                      padding: const EdgeInsets.all(0),
                                      onTap: (int index) {
                                        if (currentIndex == index) return;
                                        tabControllerStateSetter(
                                            () => currentIndex = index);
                                      },
                                      labelPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      indicatorPadding:
                                          const EdgeInsets.only(top: 0),
                                      indicatorWeight: 3,
                                      indicatorColor: Constants.COLOR_SECONDARY,
                                      labelColor: Constants.COLOR_BLACK,
                                      isScrollable: false,
                                      unselectedLabelStyle: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD),
                                      indicatorSize: TabBarIndicatorSize.label,
                                      unselectedLabelColor: Constants.colorDivider,
                                      labelStyle: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD),
                                      tabs: <Widget>[
                                        const Tab(
                                            child: Text(AppText.INFORMATION,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        Constants.GILROY_BOLD))),
                                        const Tab(
                                            child: Text(AppText.REVIEWS,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        Constants.GILROY_BOLD))),
                                        const Tab(
                                            child: Text(AppText.HOW_IT_WORKS,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        Constants.GILROY_BOLD)))
                                      ],
                                    ),
                                  ),
                                ),*/

                              StatefulBuilder(builder: (_, stateSetter) {
                                tabControllerStateSetter = stateSetter;
                                if (currentIndex == 0)
                                  return _InformationTab(
                                      spaceDetail: spaceDetail);
                                else if (currentIndex == 1)
                                  return _ReviewsTab(reviews: reviews);
                                else if (currentIndex == 2)
                                  return const HowItWorksTab();
                                else
                                  return const SizedBox();
                              })
                            ])),
                      ),
                      StatefulBuilder(builder: (_, stateSetter) {
                        priceButtonStateSetter = stateSetter;
                        return RawMaterialButton(
                            elevation: 4,
                            constraints: BoxConstraints(
                                minWidth:
                                    MediaQuery.of(tempContext).size.width - 30,
                                minHeight: 45),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            onPressed: () {
                              final VoidCallback buttonCallback = () async {
                                if (parkingFrom.year == 1700) {
                                  parkingErrorStateSetter(() =>
                                      parkingTimeError = AppText
                                          .PLEASE_SELECT_PARKING_FROM_FIRST);
                                  totalPriceStateSetter(
                                      () => totalPrice = '----');
                                  return;
                                }
                                if (parkingUntil.year == 1700) {
                                  parkingErrorStateSetter(() =>
                                      parkingTimeError = AppText
                                          .PLEASE_SELECT_PARKING_UNTIL_FIRST);
                                  totalPriceStateSetter(
                                      () => totalPrice = '----');
                                  return;
                                }
                                if (parkingFrom.isAfter(parkingUntil)) {
                                  parkingErrorStateSetter(() =>
                                      parkingTimeError = AppText
                                          .PARKING_FROM_NEEDS_TO_BE_LESS_THAN_PARKING_UNTIL);
                                  totalPriceStateSetter(
                                      () => totalPrice = '----');
                                  return;
                                }
                                final user = await SharedPreferenceHelper
                                    .instance
                                    .user();
                                Navigator.pushNamed(
                                    tempContext, SecureCheckoutScreen.route,
                                    arguments: {
                                      Constants.SPACE_DETAIL: spaceDetail,
                                      Constants.SPACE_TOTAL_DURATION:
                                          totalDuration,
                                      Constants.SPACE_DESTINATION:
                                          destinationText,
                                      Constants.TOTAL_PRICE: totalPrice,
                                      Constants.PARKING_FROM: parkingFrom,
                                      Constants.PARKING_UNTIL: parkingUntil,
                                      Constants.PARKING_SPACE_ID:
                                          spaceDetail.id,
                                      Constants.DRIVER_DETAIL_NAME:
                                          '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                                      Constants.DRIVER_DETAIL_EMAIL:
                                          user?.email ?? '',
                                      Constants.DRIVER_DETAIL_PHONE:
                                          user?.phoneNumber ?? ''
                                    });
                              };
                              buttonCallback.call();
                            },
                            fillColor: Constants.COLOR_PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              child: Text(
                                  "Book for ${totalPrice.startsWith('---') ? totalPrice : '\$$totalPrice'}",
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16)),
                            ));

                        AppButton(
                          text:
                              'Book for ${totalPrice.startsWith('---') ? totalPrice : '\$$totalPrice'}',
                          cornerRadius: 10,
                          onClick: () {},
                          fillColor: Constants.COLOR_PRIMARY,
                        );
                      }),
                      const SizedBox(height: 15)
                    ],
                  ),
                );
              }));
        }).whenComplete(() => print("yes... done"));
  }

  void showMapSelectionSheet(
      List<AvailableMap> availableMaps, Function(AvailableMap) onSelection) {
    final context = _context;
    if (context == null) return null;
    final mapsList = availableMaps
        .map((e) => ListTile(
              onTap: () {
                Navigator.pop(context);
                onSelection.call(e);
              },
              title: Text(e.mapName,
                  style: TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontFamily: Constants.GILROY_REGULAR,
                      fontSize: 16)),
              leading: SvgPicture.asset(e.icon, width: 30, height: 30),
            ))
        .toList();
    showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(child: Wrap(children: mapsList)));
  }

  void showBottomDateTimePicker(BuildContext context,
      HomeNavigationScreenBloc bloc, ParkingSpaceDetail spaceDetail) {
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
      builder: (BuildContext bc) {
        final size = MediaQuery.of(context).size;
        return BlocProvider.value(
          value: BlocProvider.of<HomeNavigationScreenBloc>(context),
          child:
              BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
                  builder: (_, state) {
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
                        child: packageSelection(
                            state, context, bloc, spaceDetail)),
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
                                            DateTime.parse(state
                                                .parkingSpaceStartDateTime),
                                            60)
                                        : DateTime.now(),
                                    minuteInterval: 15,
                                    initialDateTime: state
                                            .parkingSlotNextClicked
                                        ? DateTime.parse(
                                            state.parkingSpaceEndDateTime)
                                        : DateTime.parse(
                                            state.parkingSpaceStartDateTime),
                                    onDateTimeChanged:
                                        (DateTime newDateTime) async {
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

                                        bloc.updateParkingHourlySelected(true);

                                        totalPriceStateSetter(() => totalPrice =
                                            spaceDetail.getCalculatedPrice(
                                                DateTime.parse(state
                                                    .parkingSpaceEndDateTime),
                                                DateTime.parse(state
                                                    .parkingSpaceStartDateTime)));
                                        tabControllerStateSetter.call(() {});
                                        print("jaa $totalPrice");

                                        priceButtonStateSetter.call(() {});

                                        totalDurationStateSetter(() =>
                                            totalDuration = DateTime.parse(state
                                                    .parkingSpaceEndDateTime)
                                                .difference(DateTime.parse(state
                                                    .parkingSpaceStartDateTime))
                                                .formattedDuration);

                                        /* final date = await Navigator.pushNamed(context, CustomDateTimePickerScreen.route, arguments: [parkingFrom, parkingFrom]);
                                                if (date == null) return;
                                                date as DateTime;
                                                stateSetter(() => parkingFrom = date);
                                                if (parkingUntil.year != 1700 &&
                                                    parkingUntil.isAfter(date)) {
                                                  totalPriceStateSetter(() =>
                                                      totalPrice = spaceDetail.getCalculatedPrice(
                                                              parkingUntil,
                                                              parkingFrom));
                                                  tabControllerStateSetter
                                                      .call(() {});
                                                  priceButtonStateSetter
                                                      .call(() {});
                                                  totalDurationStateSetter(() =>
                                                      totalDuration = parkingUntil
                                                          .difference(
                                                              parkingFrom)
                                                          .formattedDuration);
                                                }
                                                parkingErrorStateSetter(() => parkingTimeError = '');*/
                                      } else {
                                        selectedDateTime = newDateTime;

                                        dateSelection.text =
                                            "Starting on ${getParkingSpaceFormattedDateTime(selectedDateTime)}";
                                        parkingSlotStartTime.text =
                                            getParkingSpaceFormattedDateTime(
                                                selectedDateTime);

                                        selectedEndDateTime =
                                            getAdditionOfTime(newDateTime, 60);

                                        parkingSlotTimePicker = newDateTime;
                                        bloc.updatePackageSelected("");
                                      }
                                      bloc.updateParkingTimings(
                                          selectedDateTime.toString(),
                                          selectedEndDateTime.toString());

                                      totalPriceStateSetter(() => totalPrice =
                                          spaceDetail.getCalculatedPrice(
                                              DateTime.parse(state
                                                  .parkingSpaceEndDateTime),
                                              DateTime.parse(state
                                                  .parkingSpaceStartDateTime)));
                                      tabControllerStateSetter.call(() {});

                                      priceButtonStateSetter.call(() {});

                                      totalDurationStateSetter(() =>
                                          totalDuration = DateTime.parse(
                                                  state.parkingSpaceEndDateTime)
                                              .difference(DateTime.parse(state
                                                  .parkingSpaceStartDateTime))
                                              .formattedDuration);

                                      print("jaa $totalPrice");
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
                                  setParkingSlotTime(bloc.state.packageSelected,
                                      bloc, spaceDetail);
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
    ).whenComplete(() => {
          bloc.state.packageSelected = "",
        });
  }

  Widget packageSelection(HomeNavigationScreenState state, BuildContext context,
      HomeNavigationScreenBloc bloc, ParkingSpaceDetail spaceDetail) {
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
                    setParkingSlotTime("2", bloc, spaceDetail);
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
                    setParkingSlotTime("4", bloc, spaceDetail);
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
                    setParkingSlotTime("6", bloc, spaceDetail);
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
                    setParkingSlotTime("monthly", bloc, spaceDetail);
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

  void setParkingSlotTime(String packageSelected, HomeNavigationScreenBloc bloc,
      ParkingSpaceDetail spaceDetail) {
    // parkingSlotStartTime.text = getParkingSpaceFormattedDateTime(selectedDateTime);
    bloc.updatePackageSelected(packageSelected);
    if (packageSelected == "2") {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 120));
      // parkingSlotEndTime.text = getParkingSpaceFormattedDateTime(selectedEndDateTime);
      bloc.updateParkingEndTime(selectedEndDateTime.toString());
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "4") {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 240));
      // parkingSlotEndTime.text = getParkingSpaceFormattedDateTime(selectedEndDateTime);
      bloc.updateParkingEndTime(selectedEndDateTime.toString());
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "6") {
      selectedEndDateTime = selectedDateTime.add(
        Duration(minutes: 360),
      );
      // parkingSlotEndTime.text = getParkingSpaceFormattedDateTime(selectedEndDateTime);
      bloc.updateParkingEndTime(selectedEndDateTime.toString());
      parkingSlotTimePicker = selectedEndDateTime;
    } else if (packageSelected == "monthly") {
      parkingSlotStartTime.text =
          DateFormat('dd MMM  ').format(selectedDateTime);
      parkingSlotEndTime.text = "Monthly";
    } else {
      selectedEndDateTime = selectedDateTime.add(Duration(minutes: 60));
      parkingSlotEndTime.text =
          getParkingSpaceFormattedDateTime(selectedEndDateTime);
    }
    // parkingSlotEndTimeSelected = packageSelected;
    totalPriceStateSetter(() => totalPrice = spaceDetail.getCalculatedPrice(
        DateTime.parse(bloc.state.parkingSpaceEndDateTime),
        DateTime.parse(bloc.state.parkingSpaceStartDateTime)));
    tabControllerStateSetter.call(() {});

    priceButtonStateSetter.call(() {});

    totalDurationStateSetter(() => totalDuration =
        DateTime.parse(bloc.state.parkingSpaceEndDateTime)
            .difference(DateTime.parse(bloc.state.parkingSpaceStartDateTime))
            .formattedDuration);

    bloc.updatePackageSelected(packageSelected);
    bloc.updateParkingHourlySelected(false);

    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      bloc.updateParkingHourlySelected(true);
    });
  }
}

class _InformationTab extends StatefulWidget {
  final ParkingSpaceDetail spaceDetail;

  _InformationTab({required this.spaceDetail});

  @override
  __InformationTabState createState() => __InformationTabState();
}

class __InformationTabState extends State<_InformationTab> {
  int currentIndex = 0;
  Function? stateSetter;

  @override
  void initState() {
    super.initState();
  }

  String locationContent(String offer) {
    switch (offer) {
      case AppText.SECURELY_GATED:
        return 'Secure';
      case AppText.CHARGING:
        return 'Charging';
      case AppText.SHELTERED:
        return 'Sheltered';
      case AppText.CCTV:
        return 'CCTV';
      case AppText.DISABLED_ACCESS:
        return 'Disabled';
      case AppText.LIGHTING:
        return 'Lighting';
      case AppText.ELECTRIC_VEHICLE_CHARGING:
        return 'Charging';
      case AppText.AIRPORT_TRANSFERS:
        return 'Airport';
      default:
        return 'Wifi';
    }
  }

  String locationAssetPath(String offer) {
    switch (offer) {
      case AppText.SECURELY_GATED:
        return 'assets/green_sheltered_icon.png';
      case AppText.CHARGING:
        return 'assets/charger.png';
      case AppText.SHELTERED:
        return 'assets/home.png';
      case AppText.WIFI:
        return 'assets/wifi.png';
      case AppText.CCTV:
        return 'assets/cctv.png';
      case AppText.DISABLED_ACCESS:
        return 'assets/disabled_person_icon.png';
      case AppText.LIGHTING:
        return 'assets/light_blub_icon.png';
      case AppText.ELECTRIC_VEHICLE_CHARGING:
        return 'assets/charger.png';
      case AppText.AIRPORT_TRANSFERS:
        return 'assets/green_airports_icon.png';
      default:
        return 'assets/wifi.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spaceImages = widget.spaceDetail.parkingSpacePhotos
        .map((e) => ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: CachedNetworkImage(
                  imageUrl: e,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => const SizedBox(
                      height: 450,
                      child: Center(child: CircularProgressIndicator()))),
            ))
        .toList();

    final size = MediaQuery.of(context).size;
    final double runSpacing = 5;
    final double spacing = 5;
    final int listSize = widget.spaceDetail.locationOffers.length;
    final columns = 5;
    final w = (MediaQuery.of(context).size.width - runSpacing * (columns - 1)) /
        columns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: widget.spaceDetail.locationOffers.isNotEmpty ? 25 : 0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            child: Wrap(
              runSpacing: runSpacing,
              spacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(listSize, (index) {
                return Container(
                  width: w,
                  height: w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                          locationAssetPath(
                              widget.spaceDetail.locationOffers[index]),
                          height: 40,
                          width: 40,
                          color: Constants.COLOR_SECONDARY),
                      const SizedBox(height: 5),
                      Text(
                          locationContent(
                              widget.spaceDetail.locationOffers[index]),
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: Constants.GILROY_MEDIUM,
                              color: Constants.COLOR_BLACK_200))
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: widget.spaceDetail.locationOffers.isNotEmpty ? 25 : 0),
        Container(
          width: MediaQuery.of(context).size.width - 80,
          child: Text(widget.spaceDetail.spaceInformation,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontFamily: Constants.GILROY_MEDIUM,
                  fontSize: 16,
                  color: Constants.COLOR_BLACK)),
        ),
        const SizedBox(height: 15),
        SizedBox(
            height: 45,
            width: MediaQuery.of(context).size.width - 40,
            child: AppButtonWithImage(
                fillColor: Constants.COLOR_PRIMARY,
                cornerRadius: 16,
                text: AppText.VIEW_STREET_VIEW,
                widget: const Image(
                    image: AssetImage('assets/street-view.png'),
                    color: Constants.COLOR_ON_PRIMARY,
                    height: 20,
                    width: 20),
                onClick: () => Navigator.pushNamed(
                    context, StreetViewScreen.route,
                    arguments: MapEntry(widget.spaceDetail.latitude.toDouble(),
                        widget.spaceDetail.longitude.toDouble())))),
        const SizedBox(height: 10),
        SizedBox(
            width: size.width - 40,
            height: 200,
            child: Stack(
              children: [
                TransformerPageView(
                    onPageChanged: (int? index) {
                      if (index == null) return;
                      stateSetter?.call(() => currentIndex = index);
                    },
                    itemBuilder: (context, index) => spaceImages[index],
                    transformer: ZoomOutPageTransformer(),
                    scrollDirection: Axis.horizontal,
                    itemCount: spaceImages.length),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: StatefulBuilder(builder: (_, stateSetter) {
                    this.stateSetter = stateSetter;
                    return DotsIndicator(
                        dotsCount: spaceImages.length,
                        position: currentIndex.toDouble(),
                        decorator: DotsDecorator(
                            activeColor: Constants.COLOR_SECONDARY,
                            size: Size(7, 7),
                            color:
                                Constants.COLOR_ON_SURFACE.withOpacity(0.3)));
                  }),
                )
              ],
            )),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _LocationOffersSingleWidget extends StatelessWidget {
  final String locationOffer;
  final int offerSize;

  const _LocationOffersSingleWidget(
      {required this.locationOffer, required this.offerSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(locationAssetPath(locationOffer),
            height: 40, width: 40, color: Constants.COLOR_SECONDARY),
        const SizedBox(height: 5),
        Text(locationContent(locationOffer),
            style: TextStyle(
                fontSize: 14,
                fontFamily: Constants.GILROY_MEDIUM,
                color: Constants.COLOR_BLACK_200))
      ],
    );
  }

  String locationContent(String offer) {
    switch (offer) {
      case AppText.SECURELY_GATED:
        return 'Secure';
      case AppText.CHARGING:
        return 'Charging';
      case AppText.SHELTERED:
        return 'Sheltered';
      case AppText.CCTV:
        return 'CCTV';
      case AppText.DISABLED_ACCESS:
        return 'Disabled';
      case AppText.LIGHTING:
        return 'Lighting';
      case AppText.ELECTRIC_VEHICLE_CHARGING:
        return 'Charging';
      case AppText.AIRPORT_TRANSFERS:
        return 'Airport';
      default:
        return 'Wifi';
    }
  }

  String locationAssetPath(String offer) {
    switch (offer) {
      case AppText.SECURELY_GATED:
        return 'assets/green_sheltered_icon.png';
      case AppText.CHARGING:
        return 'assets/charger.png';
      case AppText.SHELTERED:
        return 'assets/home.png';
      case AppText.WIFI:
        return 'assets/wifi.png';
      case AppText.CCTV:
        return 'assets/cctv.png';
      case AppText.DISABLED_ACCESS:
        return 'assets/disabled_person_icon.png';
      case AppText.LIGHTING:
        return 'assets/light_blub_icon.png';
      case AppText.ELECTRIC_VEHICLE_CHARGING:
        return 'assets/charger.png';
      case AppText.AIRPORT_TRANSFERS:
        return 'assets/green_airports_icon.png';
      default:
        return 'assets/wifi.png';
    }
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<Reviews> reviews;

  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: reviews.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) =>
                  SingleReviewListTileWidget(review: reviews[index]))
          : const Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text('No Reviews Yet!',
                      style: TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontSize: 17,
                          fontFamily: Constants.GILROY_MEDIUM)))),
    );
  }
}

class HowItWorksTab extends StatelessWidget {
  const HowItWorksTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.only(left: 60),
              child: const Text(AppText.ONCE_YOU_HAVE_PAID,
                  style: TextStyle(
                      color: Constants.COLOR_SECONDARY,
                      fontFamily: Constants.GILROY_REGULAR,
                      fontSize: 15))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Image(
                      image: AssetImage('assets/pay.png'),
                      color: Constants.COLOR_DARK_GREEN,
                      height: 20,
                      width: 20),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2, color: Constants.COLOR_DARK_GREEN)),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                        AppText
                            .YOU_WILL_RECEIVE_THE_DIRECTIONS_OF_HOW_TO_ACCESS_THE_SPACE,
                        style: TextStyle(
                            fontFamily: Constants.GILROY_REGULAR,
                            color: Constants.COLOR_ON_SURFACE,
                            fontSize: 14)),
                  ),
                )
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 29),
              alignment: Alignment.topLeft,
              height: 30,
              child: const VerticalDivider(
                  thickness: 1, color: Constants.COLOR_PRIMARY, width: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.notifications_active,
                    size: 20,
                    color: Constants.COLOR_DARK_GREEN,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2.0, color: Constants.COLOR_DARK_GREEN)),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                        AppText
                            .THE_SPACE_OWNER_CAR_PARK_IS_NOTIFIED_OF_YOUR_BOOKING,
                        style: TextStyle(
                            fontFamily: Constants.GILROY_REGULAR,
                            color: Constants.COLOR_ON_SURFACE,
                            fontSize: 14)),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 29),
              alignment: Alignment.topLeft,
              height: 30,
              child: const VerticalDivider(
                  thickness: 1, color: Constants.COLOR_PRIMARY, width: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Image(
                      image: AssetImage('assets/parked-car.png'),
                      color: Constants.COLOR_DARK_GREEN,
                      height: 20,
                      width: 20),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2.0, color: Constants.COLOR_DARK_GREEN)),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                        AppText
                            .JUST_TURN_UP_PARK_YOUR_VEHICLE_AND_GET_ON_WITH_YOUR_DAY,
                        style: TextStyle(
                            fontFamily: Constants.GILROY_REGULAR,
                            color: Constants.COLOR_ON_SURFACE,
                            fontSize: 14)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(AppText.NEED_HELP_QUESTION_MARK,
                style: TextStyle(
                    fontSize: 17,
                    fontFamily: Constants.GILROY_BOLD,
                    color: Constants.COLOR_ON_SURFACE)),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: RichText(
                text: TextSpan(
                    text: '${AppText.YOU_CAN_READ_OUR}',
                    style: TextStyle(
                        fontSize: 15,
                        color: Constants.COLOR_ON_SURFACE.withOpacity(0.6),
                        fontFamily: Constants.GILROY_REGULAR),
                    children: [
                      WidgetSpan(
                          child: GestureDetector(
                              onTap: () => launch('https://rent2park.com'),
                              child: const Text(
                                  ' ${AppText.FREQUENTLY_ASKED_QUESTION}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: Constants.GILROY_BOLD,
                                      color: Constants.COLOR_SECONDARY))))
                    ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              text: TextSpan(
                  text: AppText
                      .IF_YOUR_QUESTION_REMAIN_UNSAVED_YOU_CAN_CALL_OUR_MESSAGE_OUR_CUSTOMER_SUPPORT_TEAM_FROM_THE,
                  style: TextStyle(
                      color: Constants.COLOR_ON_SURFACE.withOpacity(0.6),
                      fontSize: 15,
                      fontFamily: Constants.GILROY_REGULAR),
                  children: [
                    WidgetSpan(
                        child: GestureDetector(
                            onTap: () => launch('https://rent2park.com'),
                            child: const Text(' ${AppText.HELP_SCREEN}.',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: Constants.GILROY_REGULAR,
                                    color: Constants.COLOR_SECONDARY))))
                  ]),
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
