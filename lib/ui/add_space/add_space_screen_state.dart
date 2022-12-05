import 'package:equatable/equatable.dart';

import 'address_state.dart';


class AddSpaceScreenState extends Equatable {
  final int pageIndex;
  final String title;
  final Address address;
  final List<dynamic> images;
  final int numberOfSpaces;
  final bool isParkingSpaceReservable;
  final int parkingType;
  final int vehicleTypePageIndex;
  final bool spaceHeightRestrictionValue;
  final bool spaceRequiresPermitValue;
  final bool spaceRequiresKeyOrSecurityValue;
  final bool isSecurelyGated;
  final bool isCctv;
  final bool isDisabledAccess;
  final bool isLighting;
  final bool isElectricVehicleCharging;
  final bool isAirportTransfers;
  final bool isWifi;
  final bool isSheltered;
  final bool isManualPricing;
  final bool isSetMinimumBookingPrice;
  final String bookingLastValue;
  final bool isSundayAvailable;
  final bool isMondayAvailable;
  final bool isTuesdayAvailable;
  final bool isWednesdayAvailable;
  final bool isThursdayAvailable;
  final bool isFridayAvailable;
  final bool isSaturdayAvailable;
  final bool isTwentyFourCheck;
  final String twentyHourScheduleStartingValue;
  final String twentyHourScheduleEndingValue;
  final String imageError;
  final String manualPricingError;
  final String automatedPricingError;
  final bool isCustomSchedule;
  final bool needScheduleUpdate;
  final String evTypes;

  AddSpaceScreenState(
      {required this.title,
      required this.pageIndex,
      required this.address,
      required this.images,
      required this.numberOfSpaces,
      required this.isParkingSpaceReservable,
      required this.parkingType,
      required this.vehicleTypePageIndex,
      required this.spaceHeightRestrictionValue,
      required this.spaceRequiresPermitValue,
      required this.spaceRequiresKeyOrSecurityValue,
      required this.isSecurelyGated,
      required this.isCctv,
      required this.isDisabledAccess,
      required this.isLighting,
      required this.isElectricVehicleCharging,
      required this.isAirportTransfers,
      required this.isWifi,
      required this.isSheltered,
      required this.isManualPricing,
      required this.isSetMinimumBookingPrice,
      required this.bookingLastValue,
      required this.isSundayAvailable,
      required this.isMondayAvailable,
      required this.isTuesdayAvailable,
      required this.isWednesdayAvailable,
      required this.isThursdayAvailable,
      required this.isFridayAvailable,
      required this.isSaturdayAvailable,
      required this.isTwentyFourCheck,
      required this.twentyHourScheduleStartingValue,
      required this.twentyHourScheduleEndingValue,
      required this.imageError,
      required this.manualPricingError,
      required this.isCustomSchedule,
      required this.needScheduleUpdate,
      required this.automatedPricingError,
      required this.evTypes});

  AddSpaceScreenState.initial(
      String title,
      Address address,
      List<String> images,
      int numberOfSpaces,
      bool isParkingSpaceReservable,
      int parkingType,
      int vehicleTypePageIndex,
      bool hasSpaceHeightRestriction,
      bool isSpaceRequiredPermit,
      bool isSpaceRequiredKey,
      bool isSecurelyGated,
      bool isCctv,
      bool isDisabledAccess,
      bool isLighting,
      bool isElectricVehicleCharging,
      bool isAirportTransfers,
      bool isWifi,
      bool isSheltered,
      bool isManualPricing,
      bool isMinimumBookingPrice,
      String bookingLastValue,
      String evTypes,
      String twentyHourScheduleStartingValue,
      String twentyHourScheduleEndingValue)
      : this(
            title: 'Address',
            pageIndex: 0,
            address: address,
            images: images,
            numberOfSpaces: numberOfSpaces,
            isParkingSpaceReservable: isParkingSpaceReservable,
            parkingType: parkingType,
            vehicleTypePageIndex: vehicleTypePageIndex,
            spaceHeightRestrictionValue: hasSpaceHeightRestriction,
            spaceRequiresPermitValue: isSpaceRequiredPermit,
            spaceRequiresKeyOrSecurityValue: isSpaceRequiredKey,
            isSecurelyGated: isSecurelyGated,
            isCctv: isCctv,
            isDisabledAccess: isDisabledAccess,
            isLighting: isLighting,
            isElectricVehicleCharging: isElectricVehicleCharging,
            isAirportTransfers: isAirportTransfers,
            isWifi: isWifi,
            isSheltered: isSheltered,
            isManualPricing: isManualPricing,
            isSetMinimumBookingPrice: isMinimumBookingPrice,
            bookingLastValue: bookingLastValue,
            isSundayAvailable: true,
            isMondayAvailable: true,
            isTuesdayAvailable: true,
            isWednesdayAvailable: true,
            isThursdayAvailable: true,
            isFridayAvailable: true,
            isSaturdayAvailable: true,
            isTwentyFourCheck: true,
            twentyHourScheduleStartingValue: twentyHourScheduleStartingValue,
            twentyHourScheduleEndingValue: twentyHourScheduleEndingValue,
            imageError: '',
            manualPricingError: '',
            isCustomSchedule: false,
            needScheduleUpdate: false,
            automatedPricingError: '',
            evTypes: evTypes);

  AddSpaceScreenState copyWith(
      {int? pageIndex,
      String? title,
      Address? address,
      List<dynamic>? images,
      int? numberOfSpaces,
      bool? isParkingSpaceReservable,
      int? parkingType,
      int? vehicleTypePageIndex,
      bool? spaceHeightRestrictionValue,
      bool? spaceRequiresPermitValue,
      bool? spaceRequiresKeyOrSecurityValue,
      bool? isSecurelyGated,
      bool? isCctv,
      bool? isDisabledAccess,
      bool? isLighting,
      bool? isElectricVehicleCharging,
      bool? isAirportTransfers,
      bool? isWifi,
      bool? isSheltered,
      bool? isManualPricing,
      bool? isSetMinimumBookingPrice,
      String? bookingLastValue,
      bool? isSundayAvailable,
      bool? isMondayAvailable,
      bool? isTuesdayAvailable,
      bool? isWednesdayAvailable,
      bool? isThursdayAvailable,
      bool? isFridayAvailable,
      bool? isSaturdayAvailable,
      bool? isTwentyFourCheck,
      String? twentyHourScheduleStartingValue,
      String? twentyHourScheduleEndingValue,
      String? imageError,
      String? manualPricingError,
      bool? isCustomSchedule,
      String? automatedPricingError,
      bool? needScheduleUpdate,
      String? evTypes}) {
    return AddSpaceScreenState(
        title: title ?? this.title,
        pageIndex: pageIndex ?? this.pageIndex,
        address: address ?? this.address,
        images: images ?? this.images,
        numberOfSpaces: numberOfSpaces ?? this.numberOfSpaces,
        isParkingSpaceReservable:
        isParkingSpaceReservable ?? this.isParkingSpaceReservable,
        parkingType: parkingType ?? this.parkingType,
        vehicleTypePageIndex: vehicleTypePageIndex ?? this.vehicleTypePageIndex,
        spaceHeightRestrictionValue:
            spaceHeightRestrictionValue ?? this.spaceHeightRestrictionValue,
        spaceRequiresPermitValue:
            spaceRequiresPermitValue ?? this.spaceRequiresPermitValue,
        spaceRequiresKeyOrSecurityValue: spaceRequiresKeyOrSecurityValue ??
            this.spaceRequiresKeyOrSecurityValue,
        isSecurelyGated: isSecurelyGated ?? this.isSecurelyGated,
        isCctv: isCctv ?? this.isCctv,
        isDisabledAccess: isDisabledAccess ?? this.isDisabledAccess,
        isLighting: isLighting ?? this.isLighting,
        isElectricVehicleCharging:
            isElectricVehicleCharging ?? this.isElectricVehicleCharging,
        isAirportTransfers: isAirportTransfers ?? this.isAirportTransfers,
        isWifi: isWifi ?? this.isWifi,
        isSheltered: isSheltered ?? this.isSheltered,
        isManualPricing: isManualPricing ?? this.isManualPricing,
        isSetMinimumBookingPrice:
            isSetMinimumBookingPrice ?? this.isSetMinimumBookingPrice,
        bookingLastValue: bookingLastValue ?? this.bookingLastValue,
        isSundayAvailable: isSundayAvailable ?? this.isSundayAvailable,
        isMondayAvailable: isMondayAvailable ?? this.isMondayAvailable,
        isTuesdayAvailable: isTuesdayAvailable ?? this.isTuesdayAvailable,
        isWednesdayAvailable: isWednesdayAvailable ?? this.isWednesdayAvailable,
        isThursdayAvailable: isThursdayAvailable ?? this.isThursdayAvailable,
        isFridayAvailable: isFridayAvailable ?? this.isFridayAvailable,
        isSaturdayAvailable: isSaturdayAvailable ?? this.isSaturdayAvailable,
        isTwentyFourCheck: isTwentyFourCheck ?? this.isTwentyFourCheck,
        twentyHourScheduleStartingValue: twentyHourScheduleStartingValue ??
            this.twentyHourScheduleStartingValue,
        twentyHourScheduleEndingValue:
            twentyHourScheduleEndingValue ?? this.twentyHourScheduleEndingValue,
        imageError: imageError ?? this.imageError,
        manualPricingError: manualPricingError ?? this.manualPricingError,
        isCustomSchedule: isCustomSchedule ?? this.isCustomSchedule,
        needScheduleUpdate: needScheduleUpdate ?? this.needScheduleUpdate,
        automatedPricingError:
            automatedPricingError ?? this.automatedPricingError,
        evTypes: evTypes ?? this.evTypes);
  }

  @override
  List<Object> get props => [
        title,
        pageIndex,
        address.props,
        images,
        numberOfSpaces,
        isParkingSpaceReservable,
        parkingType,
        vehicleTypePageIndex,
        spaceHeightRestrictionValue,
        spaceRequiresPermitValue,
        spaceRequiresKeyOrSecurityValue,
        isSecurelyGated,
        isCctv,
        isDisabledAccess,
        isLighting,
        isElectricVehicleCharging,
        isAirportTransfers,
        isWifi,
        isSheltered,
        isManualPricing,
        isSetMinimumBookingPrice,
        bookingLastValue,
        isSundayAvailable,
        isMondayAvailable,
        isTuesdayAvailable,
        isWednesdayAvailable,
        isThursdayAvailable,
        isFridayAvailable,
        isSaturdayAvailable,
        isTwentyFourCheck,
        twentyHourScheduleStartingValue,
        twentyHourScheduleEndingValue,
        imageError,
        manualPricingError,
        isCustomSchedule,
        needScheduleUpdate,
        automatedPricingError,
        evTypes
      ];
}
