import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rent2park/ui/main/home/search_filter.dart';

import '../../../data/EventSearchApiModel.dart';
import '../../../data/location_sheet_selection.dart';
import '../../../data/meta_data.dart';
import 'package:google_maps_webservice/places.dart' as places;

class HomeNavigationScreenState extends Equatable {
  final LocationData locationData;
  int lastConnectorIndex;
  final SearchFilter searchFilter;
  bool isShowEvSpaces;
  bool evSwitch;
  bool isSpaceEdited;
  bool isSpaceUpdatedDriverChecked;
  bool isSpaceUpdatedHostChecked;
  bool showSuggestions;
  bool showDateTimeView;
  String startTime;
  String endTime;
  bool isFilterShow;
  List<places.PlacesSearchResult> searchResults;
  List<places.PlacesSearchResult> airports;
  List<EventsResults> events;
  final LocationSheetSelection sheetSelection;
  final bool isNeedReloadMap;
  final bool showSpaceList;
  final DataEvent dataEvent;
  final String parkingTapId;
  String parkingSpaceStartDateTime;
  String parkingSpaceEndDateTime;
  bool parkingEndSlot;
  bool parkingSlotNextClicked;
  bool hourlySelected;
  String packageSelected;

  HomeNavigationScreenState({
    required this.locationData,
    required this.lastConnectorIndex,
    required this.searchFilter,
    required this.isSpaceEdited,
    required this.isSpaceUpdatedDriverChecked,
    required this.isSpaceUpdatedHostChecked,
    required this.isShowEvSpaces,
    required this.sheetSelection,
    required this.showSuggestions,
    required this.evSwitch,
    required this.isNeedReloadMap,
    required this.isFilterShow,
    required this.startTime,
    required this.endTime,
    required this.showSpaceList,
    required this.showDateTimeView,
    required this.dataEvent,
    required this.airports,
    required this.events,
    required this.parkingSpaceStartDateTime,
    required this.parkingSpaceEndDateTime,
    required this.searchResults,
    required this.parkingTapId,
    required this.parkingEndSlot,
    required this.parkingSlotNextClicked,
    required this.hourlySelected,
    required this.packageSelected,
  });

  HomeNavigationScreenState.initial(CameraPosition cameraPosition)
      : this(
    locationData:
    LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0}),
    lastConnectorIndex: 0,
    searchFilter: SearchFilter.initial(),
    isSpaceEdited: false,
    isSpaceUpdatedDriverChecked: false,
    isSpaceUpdatedHostChecked: false,
    isShowEvSpaces: false,
    showSuggestions: false,
    evSwitch: false,
    showSpaceList: false,
    sheetSelection: LocationSheetSelection.initial(),
    dataEvent: Initial(),
    isNeedReloadMap: false,
    startTime: "",
    endTime: "",
    searchResults: [],
    airports: [],
    events: [],
    showDateTimeView: false,
    parkingSpaceStartDateTime: "",
    parkingSpaceEndDateTime: "",
    isFilterShow: false,
    parkingTapId: '',
    parkingEndSlot: false,
    parkingSlotNextClicked: false,
    hourlySelected: false,
    packageSelected: "",
  );

  HomeNavigationScreenState copyWith({
    LocationData? locationData,
    int? lastConnectorIndex,
    SearchFilter? searchFilter,
    bool? isSpaceEdited,
    bool? isSpaceUpdatedDriverChecked,
    bool? isSpaceUpdatedHostChecked,
    bool? isShowEvSpaces,
    bool? evSwitch,
    bool? showSuggestions,
    LocationSheetSelection? sheetSelection,
    bool? isNeedReloadMap,
    bool? isFilterShow,
    bool? showSpaceList,
    String? startTime,
    String? endTime,
    String? parkingSpaceStartDateTime,
    String? parkingSpaceEndDateTime,
    bool? showDateTimeView,
    List<places.PlacesSearchResult>? searchResults,
    List<places.PlacesSearchResult>? airports,
    List<EventsResults>? events,
    DataEvent? dataEvent,
    String? parkingTapId,
    bool? parkingEndSlot,
    bool? parkingSlotNextClicked,
    bool? hourlySelected,
    String? packageSelected,
  }) {
    return HomeNavigationScreenState(
        locationData: locationData ?? this.locationData,
        lastConnectorIndex: lastConnectorIndex ?? this.lastConnectorIndex,
        searchFilter: searchFilter ?? this.searchFilter,
        isSpaceEdited: isSpaceEdited ?? this.isSpaceEdited,
        isSpaceUpdatedDriverChecked: isSpaceUpdatedDriverChecked ??
            this.isSpaceUpdatedDriverChecked,
        isSpaceUpdatedHostChecked: isSpaceUpdatedHostChecked ??
            this.isSpaceUpdatedHostChecked,
        isShowEvSpaces: isShowEvSpaces ?? this.isShowEvSpaces,
        sheetSelection: sheetSelection ?? this.sheetSelection,
        isNeedReloadMap: isNeedReloadMap ?? this.isNeedReloadMap,
        evSwitch: evSwitch ?? this.evSwitch,
        dataEvent: dataEvent ?? this.dataEvent,
        showSpaceList: showSpaceList ?? this.showSpaceList,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        searchResults: searchResults ?? this.searchResults,
        airports: airports ?? this.airports,
        events: events ?? this.events,
        parkingSpaceStartDateTime:
        parkingSpaceStartDateTime ?? this.parkingSpaceStartDateTime,
        parkingSpaceEndDateTime:
        parkingSpaceEndDateTime ?? this.parkingSpaceEndDateTime,
        showSuggestions: showSuggestions ?? this.showSuggestions,
        showDateTimeView: showDateTimeView ?? this.showDateTimeView,
        isFilterShow: isFilterShow ?? this.isFilterShow,
        parkingTapId: parkingTapId ?? this.parkingTapId,
        parkingEndSlot: parkingEndSlot ?? this.parkingEndSlot,
        hourlySelected: hourlySelected ?? this.hourlySelected,
        parkingSlotNextClicked:
        parkingSlotNextClicked ?? this.parkingSlotNextClicked,
        packageSelected: packageSelected ?? this.packageSelected);
  }

  @override
  List<Object?> get props =>
      [
        locationData.latitude,
        locationData.longitude,
        lastConnectorIndex,
        searchFilter.props,
        isSpaceEdited,
        isSpaceUpdatedDriverChecked,
        isSpaceUpdatedHostChecked,
        isShowEvSpaces,
        sheetSelection.props,
        isNeedReloadMap,
        dataEvent,
        showSpaceList,
        isFilterShow,
        startTime,
        endTime,
        airports,
        events,
        parkingSpaceStartDateTime,
        parkingSpaceEndDateTime,
        showSuggestions,
        searchResults,
        showDateTimeView,
        parkingTapId,
        parkingEndSlot,
        hourlySelected,
        parkingSlotNextClicked,
        packageSelected,
        evSwitch
      ];

  @override
  bool get stringify => true;
}
