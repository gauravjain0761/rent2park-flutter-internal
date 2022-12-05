import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rent2park/extension/collection_extension.dart';
import 'package:rent2park/ui/add_space/space_custom_schedule.dart';
import 'package:uuid/uuid.dart';

import '../../backend/shared_web-services.dart';
import '../../backend/stripe_web_service.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import 'add_space_screen_state.dart';
import 'address_state.dart';

class AddSpaceScreenBloc extends Cubit<AddSpaceScreenState> {
  static const int DRIVEWAY_PARKING_TYPE = 1;
  static const int GARAGE_PARKING_TYPE = 2;
  static const int CAR_PARK_PARKING_TYPE = 3;
  static const int LAND_GRASS_PARKING_TYPE = 4;
  static const int ON_STREET_PARKING_TYPE = 5;

  final GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: Constants.GOOGLE_MAP_PLACES_API_KEY);
  final DateFormat dateFormat = DateFormat('hh:mm a');
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final StripeWebService _stripeWebService = StripeWebService.instance();

  final uuid = Uuid();
  final schedules = List.of([
    SpaceCustomSchedule.initial('Sunday'),
    SpaceCustomSchedule.initial('Monday'),
    SpaceCustomSchedule.initial('Tuesday'),
    SpaceCustomSchedule.initial('Wednesday'),
    SpaceCustomSchedule.initial('Thursday'),
    SpaceCustomSchedule.initial('Friday'),
    SpaceCustomSchedule.initial('Saturday')
  ]);
  static final _parkingTypes = <String>[AppText.DRIVEWAY, AppText.GARAGE, AppText.CAR_PARK, AppText.LAND_GRASS_PARKING, AppText.ON_STREET];
  static final _vehicleSizes = <String>['Small', 'Medium', 'Suv or 4x4', 'Pick Up Trucks', 'Large Vans or Minibuses', 'RV Vans'];
  static const _topTitles = <String>['Address', 'Location', 'Photos', 'Details'];

  String _spaceInformation = '';
  String _spaceInstruction = '';
  num _spaceHourlyPrice = 0.0;
  num _spaceDailyPrice = 0.0;
  num _spaceWeeklyPrice = 0.0;
  num _spaceMonthlyPrice = 0.0;
  num _earningCalculatorPrice = 0.0;

  final ParkingSpaceDetail? parkingSpaceDetail;

  AddSpaceScreenBloc({required this.parkingSpaceDetail})
      : super(AddSpaceScreenState.initial(
            _topTitles[0],
            _getInitialAddress(parkingSpaceDetail),
            parkingSpaceDetail?.parkingSpacePhotos ?? [],
            parkingSpaceDetail?.numberOfSpaces ?? 1,
            !(parkingSpaceDetail?.isReservable ?? true),
            _getInitialParkingType(parkingSpaceDetail?.parkingType),
            _getInitialVehicleSize(parkingSpaceDetail?.vehicleSize),
            parkingSpaceDetail?.hasHeightLimits ?? false,
            parkingSpaceDetail?.isRequiredPermit ?? false,
            parkingSpaceDetail?.isRequiredKey ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.SECURELY_GATED) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.CCTV) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.DISABLED_ACCESS) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.LIGHTING) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.ELECTRIC_VEHICLE_CHARGING) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.AIRPORT_TRANSFERS) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.WIFI) ?? false,
            parkingSpaceDetail?.locationOffers.contains(AppText.SHELTERED) ?? false,
            parkingSpaceDetail?.isAutomated ?? true,
            parkingSpaceDetail?.isMaximumBookingPrice ?? false,
            _getBookingLastValue(parkingSpaceDetail),

            parkingSpaceDetail?.evTypes ?? '',

            '12:00 AM',
            '11:59 PM')) {
    final tempParkingSpaceDetail = parkingSpaceDetail;
    if (tempParkingSpaceDetail == null) return;
    _spaceInformation = tempParkingSpaceDetail.spaceInformation;
    _spaceInstruction = tempParkingSpaceDetail.spaceInstruction;
    _spaceHourlyPrice = tempParkingSpaceDetail.hourlyPrice;
    _spaceDailyPrice = tempParkingSpaceDetail.dailyPrice;
    _spaceWeeklyPrice = tempParkingSpaceDetail.weeklyPrice;
    _spaceMonthlyPrice = tempParkingSpaceDetail.monthlyPrice;

    if (!tempParkingSpaceDetail.isAutomated) {
      if (_spaceHourlyPrice != 0.0)
        _earningCalculatorPrice = _spaceHourlyPrice;
      else if (_spaceDailyPrice != 0.0)
        _earningCalculatorPrice = _spaceDailyPrice;
      else if (_spaceMonthlyPrice != 0.0) _earningCalculatorPrice = _spaceMonthlyPrice;
    }
  }

  static String _getBookingLastValue(ParkingSpaceDetail? previousParkingSpaceDetail) {
    if (previousParkingSpaceDetail == null) return 'hours';
    if (previousParkingSpaceDetail.hourlyPrice != 0.0)
      return 'hours';
    else if (previousParkingSpaceDetail.dailyPrice != 0.0)
      return 'daily';
    else if (previousParkingSpaceDetail.monthlyPrice != 0.0) return 'monthly';
    return 'hours';
  }

  static int _getInitialVehicleSize(String? previousVehicleSize) {
    if (previousVehicleSize == null) return 0;
    try {
      return _vehicleSizes.indexOf(previousVehicleSize);
    } catch (_) {
      return 0;
    }
  }

  static int _getInitialParkingType(String? previousParkingType) {
    if (previousParkingType == null) return DRIVEWAY_PARKING_TYPE;
    try {
      return _parkingTypes.indexOf(previousParkingType)+1;
    } catch (_) {
      return DRIVEWAY_PARKING_TYPE;
    }
  }

  static Address _getInitialAddress(ParkingSpaceDetail? parkingSpaceDetail) {
    final tempParkingSpaceDetail = parkingSpaceDetail;
    late Address address;
    if (tempParkingSpaceDetail != null) {
      address = Address(
          country: tempParkingSpaceDetail.country,
          parkingSpaceData: Data(data: tempParkingSpaceDetail.address),
          countryCode: tempParkingSpaceDetail.countryCode,
          lat: tempParkingSpaceDetail.latitude.toDouble(),
          lng: tempParkingSpaceDetail.longitude.toDouble(),
          parkingSpaceError: '');
    } else
      address = Address.initial('United State');
    return address;
  }

  void updateSpaceInformation(String spaceInformation) => this._spaceInformation = spaceInformation;

  void updateSpaceInstruction(String spaceInstruction) => this._spaceInstruction = spaceInstruction;

  void updateSpaceHourlyPrice(String price) {
    this._spaceHourlyPrice = num.tryParse(price) ?? 0.0;
    if (state.manualPricingError.isNotEmpty && price.isNotEmpty) emit(state.copyWith(manualPricingError: ''));
  }

  void updateSpaceDailyPrice(String price) {
    this._spaceDailyPrice = num.tryParse(price) ?? 0.0;
    if (state.manualPricingError.isNotEmpty && price.isNotEmpty) emit(state.copyWith(manualPricingError: ''));
  }

  void updateSpaceWeeklyPrice(String price) {
    this._spaceWeeklyPrice = num.tryParse(price) ?? 0.0;
    if (state.manualPricingError.isNotEmpty && price.isNotEmpty) emit(state.copyWith(manualPricingError: ''));
  }

  void updateSpaceMonthlyPrice(String price) {
    this._spaceMonthlyPrice = num.tryParse(price) ?? 0.0;
    if (state.manualPricingError.isNotEmpty && price.isNotEmpty) emit(state.copyWith(manualPricingError: ''));
  }

  void updateEarningCalculatorPrice(String price) {
    this._earningCalculatorPrice = num.tryParse(price) ?? 0.0;
    if (state.automatedPricingError.isNotEmpty && price.isNotEmpty) emit(state.copyWith(automatedPricingError: ''));
  }

  bool validateDetailPageData() {
    if (state.isManualPricing) {
      /*if (_spaceHourlyPrice == 0.0 || _spaceDailyPrice == 0.0 || _spaceWeeklyPrice == 0.0 || _spaceMonthlyPrice == 0.0) {
        emit(state.copyWith(manualPricingError: AppText.PLEASE_FILL_OUT_ALL_PRICING_FIELDS));
        return false;
      }*/
      if (_spaceHourlyPrice == 0.0 || _spaceDailyPrice == 0.0) {
        emit(state.copyWith(manualPricingError: AppText.PLEASE_FILL_OUT_ALL_PRICING_FIELDS));
        return false;
      }
    } else {
      emit(state.copyWith(
          automatedPricingError:
              'Automated pricing feature is not available currently. You need to switch back to manual pricing and fill out all details.'));
      return false;

      // if (_earningCalculatorPrice == 0.0) {
      //   emit(state.copyWith(automatedPricingError: AppText.PRICE_FIELD_CANNOT_BE_EMPTY));
      //   return false;
      // }
    }
    return true;
  }

  void updatePageIndex(int pageIndex) {
    final emitClosure = () => emit(state.copyWith(pageIndex: pageIndex, title: _topTitles[pageIndex]));

    int previousPageIndex = state.pageIndex;
    if (previousPageIndex < pageIndex) {
      if (pageIndex == 1 && !(state.address.parkingSpaceData is Data)) {
        emit(state.copyWith(address: state.address.copyWith(parkingSpaceError: AppText.PLEASE_SELECT_ADDRESS_FIRST)));
        return;
      } else if (pageIndex == 3 && state.images.isEmpty) {
        emit(state.copyWith(imageError: AppText.PLEASE_ADD_AT_LEAST_ONE_SPACE_IMAGE));
        return;
      }
    }
    emitClosure.call();
  }

  void updateCountry(String country, String countryCode) =>
      emit(state.copyWith(address: state.address.copyWith(country: country, countryCode: countryCode)));

  void addFile(PickedFile file) {
    List<dynamic> images = List.from(state.images);
    images.add(file);
    emit(state.copyWith(images: images, imageError: ''));
  }

  void removeFile(dynamic file) {
    final image = state.images.firstWhereOrNull((element) => element == file);
    if (image == null) return;
    List<dynamic> images = List.from(state.images);
    images.remove(image);
    emit(state.copyWith(images: images));
  }

  void incrementSpaceCount() => emit(state.copyWith(numberOfSpaces: state.numberOfSpaces + 1));

  void decrementSpaceCount() {
    int previousSpace = state.numberOfSpaces;
    if (previousSpace == 1) return;
    emit(state.copyWith(numberOfSpaces: previousSpace - 1));
  }

  void updateReservableParkingSpace(bool isParkingSpaceReservable) => emit(state.copyWith(isParkingSpaceReservable: isParkingSpaceReservable));

  void updateParkingType(int parkingType) => emit(state.copyWith(parkingType: parkingType));

  void updateVehicleTypePageIndex(int? vehicleTypePageIndex) => emit(state.copyWith(vehicleTypePageIndex: vehicleTypePageIndex));

  void updateSpaceHeightRestrictionValue(bool spaceHeightRestrictionValue) =>
      emit(state.copyWith(spaceHeightRestrictionValue: spaceHeightRestrictionValue));

  void updateSpaceRequiresPermitValue(bool spaceRequiresPermitValue) => emit(state.copyWith(spaceRequiresPermitValue: spaceRequiresPermitValue));

  void updateSpaceRequiresKeyOrSecurityValue(bool spaceRequiresKeyOrSecurityValue) =>
      emit(state.copyWith(spaceRequiresKeyOrSecurityValue: spaceRequiresKeyOrSecurityValue));

  void updateSecurelyGatedValue(bool isSecurelyGated) => emit(state.copyWith(isSecurelyGated: isSecurelyGated));

  void updateCctvValue(bool isCctv) => emit(state.copyWith(isCctv: isCctv));

  void updateDisabledAccessValue(bool isDisabledAccess) => emit(state.copyWith(isDisabledAccess: isDisabledAccess));

  void updateLightingValue(bool isLighting) => emit(state.copyWith(isLighting: isLighting));

  void updateElectricVehicleChargingValue(bool isElectricVehicleCharging) {
    if (isElectricVehicleCharging)
      emit(state.copyWith(isElectricVehicleCharging: isElectricVehicleCharging));
    else
      emit(state.copyWith(isElectricVehicleCharging: isElectricVehicleCharging, evTypes: ''));
  }

  void updateEveTypes(String evTypes) {

    emit(state.copyWith(evTypes: evTypes));
  }

  void updateAirportTransfers(bool isAirportTransfers) => emit(state.copyWith(isAirportTransfers: isAirportTransfers));

  void updateWifi(bool isWifi) => emit(state.copyWith(isWifi: isWifi));

  void updateSheltered(bool isSheltered) => emit(state.copyWith(isSheltered: isSheltered));

  void updateManualPricingValue(bool isManualPricing) =>
      emit(state.copyWith(isManualPricing: isManualPricing, manualPricingError: '', automatedPricingError: ''));

  void updateMinimumBookingPriceValue(bool isSetMinimumBookingPrice) => emit(state.copyWith(isSetMinimumBookingPrice: isSetMinimumBookingPrice));

  void updateBookingSelectionValue(String bookingLastValue) => emit(state.copyWith(bookingLastValue: bookingLastValue));

  void updateSundayCheckValue(bool isEnable) => emit(state.copyWith(isSundayAvailable: isEnable));

  void updateMondayCheckValue(bool isEnable) => emit(state.copyWith(isMondayAvailable: isEnable));

  void updateTuesdayCheckValue(bool isEnable) => emit(state.copyWith(isTuesdayAvailable: isEnable));

  void updateWednesdayCheckValue(bool isEnable) => emit(state.copyWith(isWednesdayAvailable: isEnable));

  void updateThursdayCheckValue(bool isEnable) => emit(state.copyWith(isThursdayAvailable: isEnable));

  void updateFridayCheckValue(bool isEnable) => emit(state.copyWith(isFridayAvailable: isEnable));

  void updateSaturdayCheckValue(bool isEnable) => emit(state.copyWith(isSaturdayAvailable: isEnable));

  void updateTwentyFourHourCheckValue(bool isEnable) => emit(state.copyWith(isTwentyFourCheck: isEnable));

  void updateTwentyFourStartingValue(DateTime? datetime) {
    if (datetime == null) return;
    final formattedTime = dateFormat.format(datetime);
    emit(state.copyWith(twentyHourScheduleStartingValue: formattedTime));
  }

  void updateTwentyFourEndingValue(DateTime? datetime) {
    if (datetime == null) return;
    final formattedTime = dateFormat.format(datetime);
    emit(state.copyWith(twentyHourScheduleEndingValue: formattedTime));
  }

  void handlePredication(Prediction prediction) async {
    final String? mainText = prediction.structuredFormatting?.mainText;
    final String? secondaryText = prediction.structuredFormatting?.secondaryText;
    final String? placeId = prediction.placeId;
    if (mainText == null || secondaryText == null || placeId == null) return;
    emit(state.copyWith(address: state.address.copyWith(parkingSpaceData: Loading(), lat: 0.0, lng: 0.0, parkingSpaceError: '')));
    final place = await places.getDetailsByPlaceId(placeId);
    final geometry = place.result.geometry;
    if (geometry == null)
      return emit(state.copyWith(
          address: state.address.copyWith(parkingSpaceData: Error(exception: Exception('')), lat: 0.0, lng: 0.0, parkingSpaceError: '')));

    final double latitude = geometry.location.lat;
    final double longitude = geometry.location.lng;
    emit(state.copyWith(
        address: state.address
            .copyWith(parkingSpaceData: Data(data: '$mainText, $secondaryText'), lat: latitude, lng: longitude, parkingSpaceError: '')));
  }

  void updateCustomScheduleFlag(bool value) => emit(state.copyWith(isCustomSchedule: value));

  void updateScheduleIsAvailableFlag(SpaceCustomSchedule schedule, bool value) {
    final previousScheduleIndex = schedules.indexWhere((element) => element.weekDayName == schedule.weekDayName);
    if (previousScheduleIndex == -1) return;
    final updateSchedule = schedule.copyWith(isAvailable: value);
    schedules.removeAt(previousScheduleIndex);
    schedules.insert(previousScheduleIndex, updateSchedule);
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  void updateScheduleTwentyFourFlag(SpaceCustomSchedule schedule, bool value) {
    final previousScheduleIndex = schedules.indexWhere((element) => element.weekDayName == schedule.weekDayName);
    if (previousScheduleIndex == -1) return;
    final updateSchedule = schedule.copyWith(is24Hours: value);
    schedules.removeAt(previousScheduleIndex);
    schedules.insert(previousScheduleIndex, updateSchedule);
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  void addSlot(SpaceCustomSchedule schedule) {
    final id = uuid.v1();
    schedule.slots.add(SpaceScheduleSlot.initial(id));
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  void removeSlot(SpaceCustomSchedule schedule, SpaceScheduleSlot slot) {
    schedule.slots.remove(slot);
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  void updateSlotStartDate(SpaceCustomSchedule schedule, SpaceScheduleSlot slot, DateTime datetime) {
    final int previousScheduleIndex = schedules.indexWhere((element) => element.weekDayName == schedule.weekDayName);
    final int previousSlotIndex = schedule.slots.indexWhere((element) => element.id == slot.id);
    if (previousSlotIndex == -1 || previousScheduleIndex == -1) return;
    final updatedSlot = slot.copyWith(start: datetime);
    final previousSlots = schedule.slots;
    previousSlots.removeAt(previousSlotIndex);
    previousSlots.insert(previousSlotIndex, updatedSlot);
    final updatedSchedule = schedule.copyWith(slots: previousSlots);
    schedules.removeAt(previousScheduleIndex);
    schedules.insert(previousScheduleIndex, updatedSchedule);
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  void updateSlotEndDate(SpaceCustomSchedule schedule, SpaceScheduleSlot slot, DateTime datetime) {
    final int previousScheduleIndex = schedules.indexWhere((element) => element.weekDayName == schedule.weekDayName);
    final int previousSlotIndex = schedule.slots.indexWhere((element) => element.id == slot.id);
    if (previousSlotIndex == -1 || previousScheduleIndex == -1) return;
    final updatedSlot = slot.copyWith(end: datetime);
    final previousSlots = schedule.slots;
    previousSlots.removeAt(previousSlotIndex);
    previousSlots.insert(previousSlotIndex, updatedSlot);
    final updatedSchedule = schedule.copyWith(slots: previousSlots);
    schedules.removeAt(previousScheduleIndex);
    schedules.insert(previousScheduleIndex, updatedSchedule);
    emit(state.copyWith(needScheduleUpdate: !state.needScheduleUpdate));
  }

  Future<String?> updateParkingSpace() async {
    print("came heer...1st");
    final tempParkingSpace = parkingSpaceDetail;
    if (tempParkingSpace == null) return null;
    final user = await _sharedPrefHelper.user();
    if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;
    final country = state.address.country;
    final countryCode = state.address.countryCode;
    final addressData = state.address.parkingSpaceData;
    if (!(addressData is Data)) return null;
    final address = addressData.data as String;
    final lat = state.address.lat;
    final lng = state.address.lng;
    if (lat == 0.0 || lng == 0.0) return null;
    final String parkingType = _parkingTypes[state.parkingType-1];
    final evTypes = state.evTypes;



    final vehicleSize = _vehicleSizes[state.vehicleTypePageIndex];
    final List<String> locationOffers = [];

    if (state.isSecurelyGated) locationOffers.add(AppText.SECURELY_GATED);
    if (state.isCctv) locationOffers.add(AppText.CCTV);
    if (state.isDisabledAccess) locationOffers.add(AppText.DISABLED_ACCESS);
    if (state.isLighting) locationOffers.add(AppText.LIGHTING);
    if (state.isElectricVehicleCharging) locationOffers.add(AppText.ELECTRIC_VEHICLE_CHARGING);
    if (state.isAirportTransfers) locationOffers.add(AppText.AIRPORT_TRANSFERS);
    if (state.isWifi) locationOffers.add(AppText.WIFI);
    if (state.isSheltered) locationOffers.add(AppText.SHELTERED);
    num hourlyPrice = 0.0;
    num dailyPrice = 0.0;
    num weeklyPrice = 0.0;
    num monthlyPrice = 0.0;
    bool isMinimumBooking = false;
    if (state.isManualPricing) {
      hourlyPrice = _spaceHourlyPrice;
      dailyPrice = _spaceDailyPrice;
      weeklyPrice = _spaceWeeklyPrice;
      monthlyPrice = _spaceMonthlyPrice;
      isMinimumBooking = state.isSetMinimumBookingPrice;
    } else {
      switch (state.bookingLastValue) {
        case 'hours':
          {
            hourlyPrice = _earningCalculatorPrice;
            break;
          }
        case 'daily':
          {
            dailyPrice = _earningCalculatorPrice;
            break;
          }
        case 'monthly':
          {
            monthlyPrice = _earningCalculatorPrice;
            break;
          }
      }
    }
    final slots = <Map<String, dynamic>>[];
    if (!state.isCustomSchedule) {
      if (state.isTwentyFourCheck) {
        if (state.isSundayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Sunday'});
        if (state.isMondayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Monday'});
        if (state.isTuesdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Tuesday'});
        if (state.isWednesdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Wednesday'});
        if (state.isThursdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Thursday'});
        if (state.isFridayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Friday'});
        if (state.isSaturdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Saturday'});
      } else {
        final fromTime = state.twentyHourScheduleStartingValue;
        final toTime = state.twentyHourScheduleEndingValue;
        if (state.isSundayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Sunday'});
        if (state.isMondayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Monday'});
        if (state.isTuesdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Tuesday'});
        if (state.isWednesdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Wednesday'});
        if (state.isThursdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Thursday'});
        if (state.isFridayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Friday'});
        if (state.isSaturdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Saturday'});
      }
    } else {
      for (SpaceCustomSchedule schedule in schedules) {
        if (schedule.isAvailable) {
          if (schedule.is24Hours)
            slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': schedule.weekDayName});
          else {
            if (schedule.slots.isEmpty) continue;
            final innerSlots = <Map<String, dynamic>>[];
            for (SpaceScheduleSlot slot in schedule.slots)
              innerSlots.add({'fromTime': dateFormat.format(slot.start), 'toTime': dateFormat.format(slot.end)});
            slots.add({'fromTime': '', 'toTime': '', 'day': schedule.weekDayName, 'ParkingSpaceTimeSlots': innerSlots});
          }
        }
      }
    }
    try {
      final response = await _sharedWebService.updateParkingSpace(
          user.accessToken.toString(),
          country,
          address,
          lat,
          lng,
          state.images,
          state.numberOfSpaces,
          !state.isParkingSpaceReservable,
          parkingType,
          vehicleSize,
          state.spaceHeightRestrictionValue,
          state.spaceRequiresPermitValue,
          state.spaceRequiresKeyOrSecurityValue,
          state.isManualPricing,
          hourlyPrice,
          dailyPrice,
          weeklyPrice,
          monthlyPrice,
          _spaceInformation,
          _spaceInstruction,
          locationOffers.isEmpty ? [] : locationOffers,
          isMinimumBooking,
          slots,
          countryCode,
          state.evTypes,
          user.id,
          tempParkingSpace.id);
      if (response.status) return '';
      return response.message;
    } catch (_) {
      return null;
    }
  }

  Future<BankAccount?> getBankAccount() async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final connectAccountId = user.connectAccountId;
    if (connectAccountId == null) return null;
    try {
      return await _stripeWebService.getConnectAccount(connectAccountId);
    } catch (_) {
      return null;
    }
  }

  Future<String?> addParkingSpace() async {

    final user = await _sharedPrefHelper.user();
    if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;

    final country = state.address.country;
    final countryCode = state.address.countryCode;
    final addressData = state.address.parkingSpaceData;
    if (!(addressData is Data)) return null;
    final address = addressData.data as String;
    final lat = state.address.lat;
    final lng = state.address.lng;
    if (lat == 0.0 || lng == 0.0) return null;
    final String parkingType = _parkingTypes[state.parkingType];
    final vehicleSize = _vehicleSizes[state.vehicleTypePageIndex];
    final List<String> locationOffers = [];
    if (state.isSecurelyGated) locationOffers.add(AppText.SECURELY_GATED);
    if (state.isCctv) locationOffers.add(AppText.CCTV);
    if (state.isDisabledAccess) locationOffers.add(AppText.DISABLED_ACCESS);
    if (state.isLighting) locationOffers.add(AppText.LIGHTING);
    if (state.isElectricVehicleCharging) locationOffers.add(AppText.ELECTRIC_VEHICLE_CHARGING);
    if (state.isAirportTransfers) locationOffers.add(AppText.AIRPORT_TRANSFERS);
    if (state.isWifi) locationOffers.add(AppText.WIFI);
    if (state.isSheltered) locationOffers.add(AppText.SHELTERED);
    num hourlyPrice = 0.0;
    num dailyPrice = 0.0;
    num weeklyPrice = 0.0;
    num monthlyPrice = 0.0;
    bool isMinimumBooking = false;
    if (state.isManualPricing) {
      hourlyPrice = _spaceHourlyPrice;
      dailyPrice = _spaceDailyPrice;
      weeklyPrice = _spaceWeeklyPrice;
      monthlyPrice = _spaceMonthlyPrice;
      isMinimumBooking = state.isSetMinimumBookingPrice;
    } else {
      switch (state.bookingLastValue) {
        case 'hours':
          {
            hourlyPrice = _earningCalculatorPrice;
            break;
          }
        case 'daily':
          {
            dailyPrice = _earningCalculatorPrice;
            break;
          }
        case 'monthly':
          {
            monthlyPrice = _earningCalculatorPrice;
            break;
          }
      }
    }
    final slots = <Map<String, dynamic>>[];
    if (!state.isCustomSchedule) {
      if (state.isTwentyFourCheck) {
        if (state.isSundayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Sunday'});
        if (state.isMondayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Monday'});
        if (state.isTuesdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Tuesday'});
        if (state.isWednesdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Wednesday'});
        if (state.isThursdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Thursday'});
        if (state.isFridayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Friday'});
        if (state.isSaturdayAvailable) slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': 'Saturday'});
      } else {
        final fromTime = state.twentyHourScheduleStartingValue;
        final toTime = state.twentyHourScheduleEndingValue;
        if (state.isSundayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Sunday'});
        if (state.isMondayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Monday'});
        if (state.isTuesdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Tuesday'});
        if (state.isWednesdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Wednesday'});
        if (state.isThursdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Thursday'});
        if (state.isFridayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Friday'});
        if (state.isSaturdayAvailable) slots.add({'fromTime': fromTime, 'toTime': toTime, 'day': 'Saturday'});
      }
    } else {
      for (SpaceCustomSchedule schedule in schedules) {
        if (schedule.isAvailable) {
          if (schedule.is24Hours)
            slots.add({'fromTime': '12:00 AM', 'toTime': '12:00 AM', 'day': schedule.weekDayName});
          else {
            if (schedule.slots.isEmpty) continue;
            final innerSlots = <Map<String, dynamic>>[];
            for (SpaceScheduleSlot slot in schedule.slots)
              innerSlots.add({'fromTime': dateFormat.format(slot.start), 'toTime': dateFormat.format(slot.end)});
            slots.add({'fromTime': '', 'toTime': '', 'day': schedule.weekDayName, 'ParkingSpaceTimeSlots': innerSlots});
          }
        }
      }
    }

    try {
      final response = await _sharedWebService.addParkingSpace(
          user.accessToken,
          country,
          address,
          lat,
          lng,
          state.images,
          state.numberOfSpaces,
          !state.isParkingSpaceReservable,
          parkingType,
          vehicleSize,
          state.spaceHeightRestrictionValue,
          state.spaceRequiresPermitValue,
          state.spaceRequiresKeyOrSecurityValue,
          state.isManualPricing,
          hourlyPrice,
          dailyPrice,
          weeklyPrice,
          monthlyPrice,
          _spaceInformation,
          _spaceInstruction,
          locationOffers.isEmpty ? [] : locationOffers,
          isMinimumBooking,
          slots,
          countryCode,
          state.evTypes,
          user.accessToken!);
      if (response.status) return '';
      return response.message;
    } catch (e) {
      return null;
    }
  }
}
// locationOffers.isEmpty ? '' : locationOffers.join(','),