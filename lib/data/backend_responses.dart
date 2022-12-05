import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';


const String _LOGICAL_ERROR = 'Exception occurred please try later';

abstract class Response {
  final String message;
  final bool status;

  Response({required this.message, required this.status});
}

abstract class BaseResponse {
  final String message;
  final bool status;

  BaseResponse({required this.message, required this.status});
}

class StatusMessageResponse extends BaseResponse {
  StatusMessageResponse(bool status, String message)
      : super(status: status, message: message);

  factory StatusMessageResponse.formJson(Map<String, dynamic> json) {
    final bool status = json.containsKey('status') ? json['status'] : false;
    final String message =
        json.containsKey('message') ? json['message'] : _LOGICAL_ERROR;
    return StatusMessageResponse(status, message);
  }

  @override
  String toString() {
    return 'StatusMessageResponse{status: $status, message: $message}';
  }
}

class AuthenticationResponse extends BaseResponse {
  final User? user;

  AuthenticationResponse(bool status, String message, {required this.user})
      : super(message: message, status: status);

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    final bool status = json.containsKey('status') ? json['status'] : false;
    final String message =
        json.containsKey('message') ? json['message'] : _LOGICAL_ERROR;
    final User? user = json.containsKey('data')
        ? User.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    return AuthenticationResponse(status, message, user: user);
  }

  @override
  String toString() {
    return 'AuthenticationResponse{state: ${super.status}, message: ${super.message}, user: $user}';
  }
}

class User {
  // static const String _IMAGE_BASE_URL = 'https://business.rent2park.com/images/users/';
  static const String _IMAGE_BASE_URL = 'https://dev.rent2park.com/';

  final String firstName;
  final String lastName;
  final String email;
  final String dob;
  final int id;
  final String phoneNumber;
  final String? image;
  final String? referralCode;
  final bool isPhoneVerify;
  final bool isEmailVerify;
  final String? customerId;
  final String? connectAccountId;
  final String? accessToken;

  String get fullname => '$firstName $lastName';

  User(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.id,
      required this.dob,
      required this.image,
      required this.referralCode,
      required this.phoneNumber,
      required this.isPhoneVerify,
      required this.isEmailVerify,
      required this.customerId,
      required this.connectAccountId,
      required this.accessToken});

  factory User.fromJson(Map<String, dynamic> json) {
    final String? firstName =
        json.containsKey('firstName') ? json['firstName'] : '';
    final String? lastName =
        json.containsKey('lastName') ? json['lastName'] : '';
    final String? email = json.containsKey('email') ? json['email'] : '';
    final int id = json['id'];
    final String? phoneNumber = json['phoneNumber'];
    final String? image = json.containsKey('image') ? json['image'] : null;
    final String? referralCode =
        json.containsKey('referralCode') ? json['referralCode'] : '';
    final String? dob = json.containsKey('dob') ? json['dob'] : '';
    String? tempImage;
    if (image != null) {
      if (image.startsWith('http'))
        tempImage = image;
      else
        tempImage = _IMAGE_BASE_URL + image;
    }

    final customerId =
        json.containsKey('customerId') ? json['customerId'] : null;
    final connectAccountId =
        json.containsKey('connectAccountId') ? json['connectAccountId'] : null;

    final bool isPhoneVerify = json.containsKey('isPhoneVerify')
        ? json['isPhoneVerify'] == "true"
        : false;
    final bool isEmailVerify = json.containsKey('isEmailVerify')
        ? json['isEmailVerify'] == "true"
        : false;

    final accessToken =
        json.containsKey('accessToken') ? json['accessToken'] : null;

    return User(
        id: id,
        phoneNumber: phoneNumber ?? '#########',
        image: tempImage,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        referralCode: referralCode,
        customerId: customerId,
        isPhoneVerify: isPhoneVerify,
        isEmailVerify: isEmailVerify,
        connectAccountId: connectAccountId,
        email: email ?? '',
        dob: dob ?? '',
        accessToken: accessToken);
  }

  User copyWith(
          {String? phoneNumber,
          String? email,
          bool? isPhoneVerify,
          bool? isEmailVerify,
          String? customerId,
          String? connectAccountId}) =>
      User(
          firstName: firstName,
          lastName: lastName,
          email: email ?? this.email,
          id: id,
          customerId: customerId ?? this.customerId,
          image: image,
          dob: dob,
          referralCode: referralCode,
          connectAccountId: connectAccountId,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          isPhoneVerify: isPhoneVerify ?? this.isPhoneVerify,
          isEmailVerify: isEmailVerify ?? this.isEmailVerify,
          accessToken: accessToken);

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'customerId': customerId,
        'email': email,
        'connectAccountId': connectAccountId,
        'id': id,
        'dob': dob,
        'isPhoneVerify': isPhoneVerify ? "true" : "false",
        'isEmailVerify': isEmailVerify ? "true" : "false",
        'referralCode': referralCode,
        'phoneNumber': phoneNumber,
        'image': image,
        'accessToken': accessToken
      };

  @override
  String toString() {
    return 'User{firstName: $firstName, lastName: $lastName, email: $email, id: $id, phoneNumber: $phoneNumber, image: $image, referralCode: $referralCode, isPhoneVerify: $isPhoneVerify, isEmailVerify: $isEmailVerify, customerId: $customerId, connectAccountId: $connectAccountId, accessToken: $accessToken dob: $dob}';
  }
}

class HomeResponse extends BaseResponse {
  final List<ParkingSpace> parkingSpaces;
  final int inProgressBookings;

  HomeResponse(bool status, String message,
      {required this.parkingSpaces, required this.inProgressBookings})
      : super(status: status, message: message);

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final bool status = json.containsKey('status') ? json['status'] : false;
    final String message =
        json.containsKey('message') ? json['message'] : _LOGICAL_ERROR;

    final List<ParkingSpace>? parkingSpaces = json.containsKey('parkingSpaces')
        ? (json['parkingSpaces'] as List<dynamic>?)
            ?.map((dynamic e) => e as Map<String, dynamic>)
            .map((Map<String, dynamic> e) => ParkingSpace.fromJson(e))
            .toList()
        : null;

    final int inProgressBookings =     json.containsKey('inProgressBookings') ? json['inProgressBookings'] : 0;


    return HomeResponse(status, message,
        parkingSpaces: parkingSpaces ?? [],
        inProgressBookings: inProgressBookings);
  }

  @override
  String toString() {
    return 'HomeResponse{parkingSpaces: $parkingSpaces}';
  }
}

class ParkingSpace {
  final String id;
  final double latitude;
  final double longitude;
  final bool isAutomated;
  final num hourlyPrice;
  final num dailyPrice;
  final num weeklyPrice;
  final num monthlyPrice;
  bool markerTaped;
  final bool isEv;
  bool isSpaceBooked;

  ParkingSpace(
      {required this.id,
      required this.latitude,
      required this.longitude,
      required this.isAutomated,
      required this.hourlyPrice,
      required this.dailyPrice,
      required this.weeklyPrice,
      required this.markerTaped,
      required this.isEv,
      required this.isSpaceBooked,
      required this.monthlyPrice});

  String hostPrice() {
    if (isAutomated)
      return hourlyPrice.toStringAsFixed(2);
    else {
      late num pricePerHour;
      if (hourlyPrice != 0.0)
        pricePerHour = hourlyPrice;
      else if (dailyPrice != 0.0)
        pricePerHour = dailyPrice / 24;
      else if (weeklyPrice != 0.0)
        pricePerHour = weeklyPrice / 168;
      else
        pricePerHour = monthlyPrice / 720;
      return pricePerHour.toStringAsFixed(2);
    }
  }

  String getCalculatedPrice(DateTime parkingUntil, DateTime parkingFrom) {
    if (isAutomated) {
      final difference = parkingUntil.difference(parkingFrom);
      if (difference.inHours < 24)
        return (difference.inHours * hourlyPrice).toStringAsFixed(2);
      else if (difference.inDays <= 7) {
        final days = difference.inHours ~/ 24;
        final remainingHours = difference.inHours % 24;
        return ((days * dailyPrice) +
                (remainingHours != 0 ? remainingHours * hourlyPrice : 0))
            .toStringAsFixed(2);
      } else if (difference.inDays > 7 && difference.inDays < 30) {
        int hours = difference.inHours;
        final weeks = hours ~/ 168;
        final remainingHoursAfterWeek = hours - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays = hours - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((weeks * weeklyPrice) +
                (days * dailyPrice) +
                (remainingHours * hourlyPrice))
            .toStringAsFixed(2);
      } else {
        int hours = difference.inHours;
        final months = hours ~/ 720;
        final remainingHoursAfterMonth = hours - (months * 720);
        final weeks = remainingHoursAfterMonth ~/ 168;
        final remainingHoursAfterWeek = hours - (months * 720) - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays =
            hours - (months * 720) - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((months * monthlyPrice) +
                (weeks * weeklyPrice) +
                (days * dailyPrice) +
                (remainingHours * hourlyPrice))
            .toStringAsFixed(2);
      }
    } else {
      late num pricePerHour;
      if (hourlyPrice != 0.0)
        pricePerHour = hourlyPrice;
      else if (dailyPrice != 0.0)
        pricePerHour = dailyPrice / 24;
      else if (weeklyPrice != 0.0)
        pricePerHour = weeklyPrice / 168;
      else
        pricePerHour = monthlyPrice / 720;
      final difference = parkingUntil.difference(parkingFrom);
      return (difference.inHours * pricePerHour).toStringAsFixed(2);
    }
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    final String id = json.containsKey('id') ? json['id'].toString() : '';
    final double latitude = json.containsKey('latitude') ? double.parse(json['latitude']) : 0.0;
    final double longitude = json.containsKey('longitude') ? double.parse(json['longitude']) : 0.0;
    final bool isAutomated = json['isAutomated'] as int == 1;
    final num hourlyPrice = double.parse(json['hourlyPrice']);
    final num dailyPrice = double.parse(json['dailyPrice']);
    final num weeklyPrice = double.parse(json['weeklyPrice']);
    final num monthlyPrice = double.parse(json['monthlyPrice']);
    final bool markerTaped = false;
    final bool isEv = json.containsKey('isEv') ? json['isEv']==1:false;
    final bool isSpaceBooked = false;
    return ParkingSpace(
        id: id,
        latitude: latitude,
        longitude: longitude,
        isAutomated: isAutomated,
        hourlyPrice: hourlyPrice,
        dailyPrice: dailyPrice,
        weeklyPrice: weeklyPrice,
        markerTaped: markerTaped,
        isEv: isEv,
        isSpaceBooked: isSpaceBooked,
        monthlyPrice: monthlyPrice);
  }

  @override
  String toString() {
    return 'ParkingSpace{id: $id, latitude: $latitude, longitude: $longitude, isAutomated: $isAutomated, hourlyPrice: $hourlyPrice, dailyPrice: $dailyPrice, weeklyPrice: $weeklyPrice, monthlyPrice: $monthlyPrice,markerTaped: $markerTaped,isEv:$isEv,isSpaceBooked:$isSpaceBooked}';
  }
}

class ParkingSpaceDetailResponse extends BaseResponse {
  final ParkingSpaceDetail? spaceDetail;

  ParkingSpaceDetailResponse(bool status, String message,
      {required this.spaceDetail})
      : super(status: status, message: message);

  factory ParkingSpaceDetailResponse.fromJson(Map<String, dynamic> json) {
    final statusMessage = StatusMessageResponse.formJson(json);


    final spaceDetail = json.containsKey('parkingSpaces')
        ? ParkingSpaceDetail.fromJson(json['parkingSpaces'] as Map<String, dynamic>)
        : null;

    return ParkingSpaceDetailResponse(
        statusMessage.status, statusMessage.message,
        spaceDetail: spaceDetail);
  }
}

class ParkingSpaceDetail {
  // static const String _IMAGE_BASE_URL = 'https://business.rent2park.com/images/parking/';
  static const String _IMAGE_BASE_URL = 'https://dev.rent2park.com/parking_space/';

  final String id;
  final String country;
  final String address;
  final String countryCode;
  final num latitude;
  final num longitude;
  final int numberOfSpaces;
  final bool isReservable;
  final String parkingType;
  final String vehicleSize;
  final bool hasHeightLimits;
  final bool isRequiredPermit;
  final bool isRequiredKey;
  final String spaceInformation;
  final String spaceInstruction;
  final List<String> locationOffers;
  final bool isAutomated;
  final num hourlyPrice;
  final num dailyPrice;
  final num weeklyPrice;
  final num monthlyPrice;
  final bool isMaximumBookingPrice;
  final List<String> parkingSpacePhotos;
  final User? appUser;
  final int totalBookings;
  final List<ParkingSpaceSlot> slots;
  final String evTypes;
  final List<Reviews> reviews;
  final int active;

  bool get isActive => active == 1;

  String getCalculatedPrice(DateTime parkingUntil, DateTime parkingFrom) {
    if (isAutomated) {
      final difference = parkingUntil.difference(parkingFrom);
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        final minutePrice = hourlyPrice / 60;
        if (hours == 0) {
          if (isMaximumBookingPrice) return hourlyPrice.toStringAsFixed(2);
          return (minutePrice * difference.inMinutes).toStringAsFixed(2);
        }
        return ((difference.inHours * hourlyPrice) +
                ((difference.inMinutes - (difference.inHours * 60)) *
                    minutePrice))
            .toStringAsFixed(2);
      } else if (difference.inDays <= 7) {
        final days = difference.inHours ~/ 24;
        final remainingHours = difference.inHours % 24;
        return ((days * dailyPrice) +
                (remainingHours != 0 ? remainingHours * hourlyPrice : 0))
            .toStringAsFixed(2);
      } else if (difference.inDays > 7 && difference.inDays < 30) {
        int hours = difference.inHours;
        final weeks = hours ~/ 168;
        final remainingHoursAfterWeek = hours - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays = hours - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((weeks * weeklyPrice) +
                (days * dailyPrice) +
                (remainingHours * hourlyPrice))
            .toStringAsFixed(2);
      } else {
        int hours = difference.inHours;
        final months = hours ~/ 720;
        final remainingHoursAfterMonth = hours - (months * 720);
        final weeks = remainingHoursAfterMonth ~/ 168;
        final remainingHoursAfterWeek = hours - (months * 720) - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays =
            hours - (months * 720) - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((months * monthlyPrice) +
                (weeks * weeklyPrice) +
                (days * dailyPrice) +
                (remainingHours * hourlyPrice))
            .toStringAsFixed(2);
      }
    } else {
      late num pricePerHour;
      if (hourlyPrice != 0.0)
        pricePerHour = hourlyPrice;
      else if (dailyPrice != 0.0)
        pricePerHour = dailyPrice / 24;
      else if (weeklyPrice != 0.0)
        pricePerHour = weeklyPrice / 168;
      else
        pricePerHour = monthlyPrice / 720;
      final difference = parkingUntil.difference(parkingFrom);
      final minutePrice = pricePerHour / 60;
      if (difference.inHours == 0) {
        if (isMaximumBookingPrice) return pricePerHour.toStringAsFixed(2);
        return (minutePrice * difference.inMinutes).toStringAsFixed(2);
      }
      return ((difference.inHours * pricePerHour) +
              ((difference.inMinutes - (difference.inHours * 60)) *
                  minutePrice))
          .toStringAsFixed(2);
    }
  }

  ParkingSpaceDetail(
      {required this.id,
      required this.country,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.numberOfSpaces,
      required this.isReservable,
      required this.parkingType,
      required this.vehicleSize,
      required this.hasHeightLimits,
      required this.isRequiredPermit,
      required this.isRequiredKey,
      required this.spaceInformation,
      required this.spaceInstruction,
      required this.locationOffers,
      required this.isAutomated,
      required this.hourlyPrice,
      required this.dailyPrice,
      required this.weeklyPrice,
      required this.monthlyPrice,
      required this.isMaximumBookingPrice,
      required this.parkingSpacePhotos,
      required this.slots,
      required this.appUser,
      required this.totalBookings,
      required this.countryCode,
      required this.evTypes,
      required this.reviews,
      required this.active});

  factory ParkingSpaceDetail.fromJson(Map<String, dynamic> json) {

    final String id = json['id'].toString();
    final String country = json['country'];
    final String address = json['address'];
    final num latitude = double.parse(json['latitude']);
    final num longitude = double.parse(json['longitude']);
    final int numberOfSpaces = json['numberOfSpaces'];
    final bool isReservable = json['isReservable'] as int == 1;
    final String parkingType = json['parkingType'].toString();
    final String? vehicleSize = json['vehicleSize'];
    final bool hasHeightLimits = json['hasHeightLimits'] as int == 1;
    final bool isRequiredPermit = json['isRequiredPermit'] as int == 1;
    final bool isRequiredKey = json['isRequiredKey'] as int == 1;
    final String spaceInformation = json['spaceInformation'];

    String spaceInstruction="";
    if(json['spaceInstruction']!=null){
      spaceInstruction = json['spaceInstruction'];
    }

    // final String tempLocationOffers = json['locationOffers'];
    var locationOffersArray = json['location_offers'];
    String tempLocationOffers = "";
    for(int i =0; i<locationOffersArray.length;i++){
      if(tempLocationOffers.isEmpty){
        tempLocationOffers = locationOffersArray[i]["name"];
      }else{
        tempLocationOffers = "$tempLocationOffers,${locationOffersArray[i]["name"]}";
      }
    }

    print("locationOffers $tempLocationOffers  ");


    final bool isAutomated = json['isAutomated'] as int == 1;
    final num hourlyPrice = double.parse(json['hourlyPrice']);
    final num dailyPrice = double.parse(json['dailyPrice']);
    final num weeklyPrice = double.parse(json['weeklyPrice']);
    final num monthlyPrice = double.parse(json['monthlyPrice']);
    final bool isMaximumBookingPrice = json['isMaximumBookingPrice'] as int == 1;


    /*final List<String>? parkingSpacePhotos =
        json.containsKey('parkingSpacePhotos')
            ? (json['parkingSpacePhotos'] as List<dynamic>?)
                ?.map((dynamic e) => e as Map<String, dynamic>?)
                .map((Map<String, dynamic>? e) => _IMAGE_BASE_URL + e?['photo'])
                .toList(growable: false)
            : null;*/

    final List<String>? parkingSpacePhotos =
        (json.containsKey('parkingSpacePhotos')
            ? (json['parkingSpacePhotos'] as List<dynamic>?)
                ?.map((title) => "$_IMAGE_BASE_URL$title")
                .toList()
            : null);

    final List<ParkingSpaceSlot>? parkingSpaceSlots =
        json.containsKey('slots')
            ? (json['slots'] as List<dynamic>?)
                ?.map((dynamic e) => e as Map<String, dynamic>)
                .map((Map<String, dynamic> e) => ParkingSpaceSlot.fromJson(e))
                .toList(growable: false)
            : null;

    final User? appUser = json.containsKey('appUser')
        ? User.fromJson(json['appUser'] as Map<String, dynamic>)
        : null;
    final int totalBookings =
        json.containsKey('totalBookings') ? json['totalBookings'] : 0;
    final String? countryCode =
        json.containsKey('countryCode') ? json['countryCode'] : 'US';

    var evTypesArray = json['ev_types'];

    String evTypes = "";

    for(int i =0; i<evTypesArray.length;i++){
      if(evTypes.isEmpty){
        evTypes = evTypesArray[i]["name"];
      }else{
        evTypes = "$evTypes,${evTypesArray[i]["name"]}";
      }
    }




    final reviews = json.containsKey('reviews')
        ? (json['reviews'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .map((e) => Reviews.fromJson(e))
            .toList()
        : null;
    final active = json.containsKey('isActive') ? json['isActive'] : 1;

    return ParkingSpaceDetail(
        id: id,
        country: country,
        address: address,
        latitude: latitude,
        longitude: longitude,
        numberOfSpaces: numberOfSpaces,
        isReservable: isReservable,
        parkingType: parkingType,
        vehicleSize: vehicleSize ?? '',
        hasHeightLimits: hasHeightLimits,
        isRequiredPermit: isRequiredPermit,
        isRequiredKey: isRequiredKey,
        spaceInformation: spaceInformation,
        spaceInstruction: spaceInstruction,
        locationOffers: tempLocationOffers.isNotEmpty ? tempLocationOffers.split(',') : [],
        isAutomated: isAutomated,
        hourlyPrice: hourlyPrice,
        dailyPrice: dailyPrice,
        weeklyPrice: weeklyPrice,
        monthlyPrice: monthlyPrice,
        isMaximumBookingPrice: isMaximumBookingPrice,
        parkingSpacePhotos: parkingSpacePhotos ?? [],
        slots: parkingSpaceSlots ?? [],
        appUser: appUser,
        totalBookings: totalBookings,
        countryCode: countryCode ?? 'US',
        evTypes: evTypes ?? '',
        reviews: reviews ?? [],
        active: active);
  }

  ParkingSpaceDetail copyWith({int? activate}) => ParkingSpaceDetail(
      id: id,
      country: country,
      address: address,
      latitude: latitude,
      longitude: longitude,
      numberOfSpaces: numberOfSpaces,
      isReservable: isReservable,
      parkingType: parkingType,
      vehicleSize: vehicleSize,
      hasHeightLimits: hasHeightLimits,
      isRequiredPermit: isRequiredPermit,
      isRequiredKey: isRequiredKey,
      spaceInformation: spaceInformation,
      spaceInstruction: spaceInstruction,
      locationOffers: locationOffers,
      isAutomated: isAutomated,
      hourlyPrice: hourlyPrice,
      dailyPrice: dailyPrice,
      weeklyPrice: weeklyPrice,
      monthlyPrice: monthlyPrice,
      isMaximumBookingPrice: isMaximumBookingPrice,
      parkingSpacePhotos: parkingSpacePhotos,
      slots: slots,
      appUser: appUser,
      totalBookings: totalBookings,
      countryCode: countryCode,
      evTypes: evTypes,
      active: activate ?? this.active,
      reviews: reviews);

  @override
  String toString() {
    return 'ParkingSpaceDetail{id: $id, country: $country, address: $address, countryCode: $countryCode, latitude: $latitude, longitude: $longitude, numberOfSpaces: $numberOfSpaces, isReservable: $isReservable, parkingType: $parkingType, vehicleSize: $vehicleSize, hasHeightLimits: $hasHeightLimits, isRequiredPermit: $isRequiredPermit, isRequiredKey: $isRequiredKey, spaceInformation: $spaceInformation, spaceInstruction: $spaceInstruction, locationOffers: $locationOffers, isAutomated: $isAutomated, hourlyPrice: $hourlyPrice, dailyPrice: $dailyPrice, weeklyPrice: $weeklyPrice, monthlyPrice: $monthlyPrice, isMaximumBookingPrice: $isMaximumBookingPrice, parkingSpacePhotos: $parkingSpacePhotos, appUser: $appUser, totalBookings: $totalBookings, slots: $slots, evTypes: $evTypes, reviews: $reviews, active: $active}';
  }
}

class VehicleTypeResponse {
  bool? status;
  int? statusCode;
  String? message;
  List<VehicleTypes>? data;

  VehicleTypeResponse({this.status, this.statusCode, this.message, this.data});

  VehicleTypeResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VehicleTypes>[];
      json['data'].forEach((v) {
        data!.add(new VehicleTypes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleTypes {
  int? id;
  String? title;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  VehicleTypes(
      {this.id, this.title, this.isDeleted, this.createdAt, this.updatedAt});

  VehicleTypes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class ParkingSpaceSlot {
  final String id;
  final String day;
  final String fromTime;
  final String toTime;

  ParkingSpaceSlot(
      {required this.id,
      required this.day,
      required this.fromTime,
      required this.toTime});

  factory ParkingSpaceSlot.fromJson(Map<String, dynamic> json) {
    final String id = json['id'].toString();
    final String day = json['day'];
    final String from = json['fromTime'];
    final String to = json['toTime'];

    return ParkingSpaceSlot(id: id, day: day, fromTime: from, toTime: to);
  }

  @override
  String toString() {
    return 'ParkingSpaceSlot{id: $id, day: $day, fromTime: $fromTime, toTime: $toTime}';
  }
}

class DistanceMatrixResponse {
  final String distanceText;
  final String durationText;

  DistanceMatrixResponse(
      {required this.distanceText, required this.durationText});

  factory DistanceMatrixResponse.fromJson(Map<String, dynamic> json) {
    final rows = json.containsKey('rows') ? json['rows'] as List<dynamic> : [];
    final initialRow = rows.isNotEmpty ? rows[0] : {};
    final elements =
        initialRow.containsKey('elements') ? initialRow['elements'] : [];
    final element =
        elements.isNotEmpty ? elements[0] as Map<String, dynamic> : {};
    final distance = element.containsKey('distance')
        ? element['distance'] as Map<String, dynamic>
        : {};
    final distanceText =
        distance.containsKey('text') ? distance['text'] as String : '';
    final duration = element.containsKey('duration')
        ? element['duration'] as Map<String, dynamic>
        : {};
    final durationText =
        duration.containsKey('text') ? duration['text'] as String : '';

    return DistanceMatrixResponse(
        distanceText: distanceText, durationText: durationText);
  }

  @override
  String toString() {
    return 'DistanceMatrixResponse{distanceText: $distanceText, durationText: $durationText}';
  }
}

class Vehicle {
  // static const String _VEHICLE_BASE_URL = 'https://business.rent2park.com/images/vehicles/';
  // static const String _DRIVING_LICENSE_BASE_URL = 'https://business.rent2park.com/images/licesens/';

  static const String _VEHICLE_BASE_URL = 'https://dev.rent2park.com/';
  static const String _DRIVING_LICENSE_BASE_URL = 'https://dev.rent2park.com/';

  var id;
  var year;
  var make;
  var vehicleModel;
  var color;
  var registerationNum;
  var vehicleType;
  var image;
  var divingLicenseImage;

  Vehicle(
      {required this.id,
      required this.year,
      required this.make,
      required this.vehicleModel,
      required this.color,
      required this.registerationNum,
      required this.vehicleType,
      required this.image,
      required this.divingLicenseImage});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final year = json.containsKey('year') ? json['year'] : null;
    final make = json.containsKey('make') ? json['make'] : null;
    final vehicleModel =
        json.containsKey('vehicleModel') ? json['vehicleModel'] : null;
    final color = json.containsKey('color') ? json['color'] : null;
    var registrationNumber =
        json.containsKey('registerationNum') ? json['registerationNum'] : null;
    final vehicleType =
        json.containsKey('vehicleType') ? json['vehicleType'] : null;
    final String? image = json.containsKey('image') ? json['image'] : null;
    final String? divingLicenseImage = json.containsKey('drivingLicenseImage')
        ? json['drivingLicenseImage']
        : null;
    return Vehicle(
        id: id,
        year: year,
        make: make,
        vehicleModel: vehicleModel,
        color: color,
        registerationNum: registrationNumber,
        vehicleType: vehicleType,
        image: image != null ? _VEHICLE_BASE_URL + image : null,
        divingLicenseImage: divingLicenseImage != null
            ? _DRIVING_LICENSE_BASE_URL + divingLicenseImage
            : null);
  }

  Vehicle copyWith() => Vehicle(
      id: id,
      year: year,
      make: make,
      vehicleModel: vehicleModel,
      color: color,
      registerationNum: registerationNum,
      vehicleType: vehicleType,
      divingLicenseImage: divingLicenseImage,
      image: image);

  @override
  String toString() {
    return 'Vehicle{id: $id, year: $year, make: $make, vehicleModel: $vehicleModel, color: $color, registerationNum: $registerationNum, vehicleType: $vehicleType, image: $image, divingLicenseImage: $divingLicenseImage}';
  }
}

class AllVehicleResponse extends BaseResponse {
  final List<Vehicle> vehicles;

  AllVehicleResponse(bool status, String message, {required this.vehicles})
      : super(status: status, message: message);

  factory AllVehicleResponse.fromJson(Map<String, dynamic> json) {
    final statusMessageResponse = StatusMessageResponse.formJson(json);
    final vehicles = json.containsKey('vehicle')
        ? (json['vehicle'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .map((Map<String, dynamic> e) => Vehicle.fromJson(e))
            .toList()
        : null;
    return AllVehicleResponse(
        statusMessageResponse.status, statusMessageResponse.message,
        vehicles: vehicles ?? []);
  }
}

class AddUpdateVehicleResponse extends BaseResponse {
  final Vehicle? vehicle;

  AddUpdateVehicleResponse(bool status, String message, {required this.vehicle})
      : super(status: status, message: message);

  factory AddUpdateVehicleResponse.fromJson(Map<String, dynamic> json) {
    final statusMessageResponse = StatusMessageResponse.formJson(json);

    final Vehicle? vehicle = json.containsKey('vehicle')
        ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
        : null;
    return AddUpdateVehicleResponse(
        statusMessageResponse.status, statusMessageResponse.message,
        vehicle: vehicle);
  }
}

class SpaceBookingResponse extends BaseResponse {
  final List<SpaceBooking> spaceBookings;

  SpaceBookingResponse(bool status, String message,
      {required this.spaceBookings})
      : super(status: status, message: message);

  factory SpaceBookingResponse.fromJson(Map<String, dynamic> json) {
    final statusMessageResponse = StatusMessageResponse.formJson(json);
    final List<SpaceBooking>? bookings = json.containsKey('bookings')
        ? (json['bookings'] as List<dynamic>?)
            ?.map((dynamic e) => e as Map<String, dynamic>)
            .map((e) => SpaceBooking.fromJson(e))
            .toList()
        : null;

    return SpaceBookingResponse(
        statusMessageResponse.status, statusMessageResponse.message,
        spaceBookings: bookings ?? []);
  }

  @override
  String toString() {
    return 'SpaceBookingResponse{spaceBookings: $spaceBookings}';
  }
}

class SpaceBooking {
  // static const String _IMAGE_BASE_URL = 'https://business.rent2park.com/images/users/';
  static const String _IMAGE_BASE_URL = 'https://dev.rent2park.com/';
  final int id;
  final String address;
  final String arriving;
  final String leaving;
  final num billAmount;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String? userImage;
  final String userId;
  final Vehicle vehicle;
  final ParkingSpaceDetail parkingSpace;
  final bool isCancelled;
  final DateTime parkingEnd;
  final DateTime parkingFrom;
  final DateTime createdAt;

  SpaceBooking(
      {required this.id,
      required this.address,
      required this.arriving,
      required this.leaving,
      required this.billAmount,
      required this.userName,
      required this.userEmail,
      required this.userPhone,
      required this.userImage,
      required this.userId,
      required this.vehicle,
      required this.parkingSpace,
      required this.isCancelled,
      required this.parkingFrom,
      required this.parkingEnd,
      required this.createdAt});

  String getCalculatedPrice() {
    if (parkingFrom.year == 1700) return '0';
    final DateTime parkingUntil = DateTime.now();
    if (parkingSpace.isAutomated) {
      final difference = parkingUntil.difference(parkingFrom);
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        final minutePrice = parkingSpace.hourlyPrice / 60;
        if (hours == 0) {
          if (parkingSpace.isMaximumBookingPrice)
            return parkingSpace.hourlyPrice.toStringAsFixed(2);
          return (minutePrice * difference.inMinutes).toStringAsFixed(2);
        }
        return ((hours * parkingSpace.hourlyPrice) +
                ((difference.inMinutes - (difference.inHours * 60)) *
                    minutePrice))
            .toStringAsFixed(2);
      } else if (difference.inDays <= 7) {
        final days = difference.inHours ~/ 24;
        final remainingHours = difference.inHours % 24;
        return ((days * parkingSpace.dailyPrice) +
                (remainingHours != 0
                    ? remainingHours * parkingSpace.hourlyPrice
                    : 0))
            .toStringAsFixed(2);
      } else if (difference.inDays > 7 && difference.inDays < 30) {
        int hours = difference.inHours;
        final weeks = hours ~/ 168;
        final remainingHoursAfterWeek = hours - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays = hours - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((weeks * parkingSpace.weeklyPrice) +
                (days * parkingSpace.dailyPrice) +
                (remainingHours * parkingSpace.hourlyPrice))
            .toStringAsFixed(2);
      } else {
        int hours = difference.inHours;
        final months = hours ~/ 720;
        final remainingHoursAfterMonth = hours - (months * 720);
        final weeks = remainingHoursAfterMonth ~/ 168;
        final remainingHoursAfterWeek = hours - (months * 720) - (weeks * 168);
        final days = remainingHoursAfterWeek ~/ 24;
        final remainingHoursAfterDays =
            hours - (months * 720) - (weeks * 168) - (days * 24);
        final remainingHours = remainingHoursAfterDays % 24;
        return ((months * parkingSpace.monthlyPrice) +
                (weeks * parkingSpace.weeklyPrice) +
                (days * parkingSpace.dailyPrice) +
                (remainingHours * parkingSpace.hourlyPrice))
            .toStringAsFixed(2);
      }
    } else {
      late num pricePerHour;
      if (parkingSpace.hourlyPrice != 0.0)
        pricePerHour = parkingSpace.hourlyPrice;
      else if (parkingSpace.dailyPrice != 0.0)
        pricePerHour = parkingSpace.dailyPrice / 24;
      else if (parkingSpace.weeklyPrice != 0.0)
        pricePerHour = parkingSpace.weeklyPrice / 168;
      else
        pricePerHour = parkingSpace.monthlyPrice / 720;
      final difference = parkingUntil.difference(parkingFrom);
      final minutePrice = pricePerHour / 60;
      if (difference.inHours == 0) {
        if (parkingSpace.isMaximumBookingPrice)
          return pricePerHour.toStringAsFixed(2);
        return (minutePrice * difference.inMinutes).toStringAsFixed(2);
      }
      return ((difference.inHours * pricePerHour) +
              ((difference.inMinutes - (difference.inHours * 60)) *
                  minutePrice))
          .toStringAsFixed(2);
    }
  }

  factory SpaceBooking.fromJson(Map<String, dynamic> json) {
    final int id = json['id'];
    final String address = json['address'];
    final String arriving = json['arriving'];
    final String leaving = json['leaving'];
    final num billAmount = json['billAmount'];
    final String? userName = json['userName'];
    final String? userEmail = json['userEmail'];
    final String? userPhone = json['userPhone'];
    final String? userImage = json['userImage'];
    final String userId = json['userId'];
    final Vehicle vehicle =
        Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>);
    final ParkingSpaceDetail parkingSpace = ParkingSpaceDetail.fromJson(
        json['parkingSpaces'] as Map<String, dynamic>);
    final bool isCancelled = (json['cancelled'] as int) == 1;
    final String? tempActualArrivalDatetime =
        json.containsKey('actualArriving') ? json['actualArriving'] : null;
    final String? endingDatetime =
        json.containsKey('actualLeaving') ? json['actualLeaving'] : null;
    final String? createdAt =
        json.containsKey('createdAt') ? json['createdAt'] : null;

    late String? tempImage;
    if (userImage != null)
      tempImage = _IMAGE_BASE_URL + userImage;
    else
      tempImage = null;

    return SpaceBooking(
      id: id,
      address: address,
      arriving: arriving,
      leaving: leaving,
      billAmount: billAmount,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userImage: tempImage,
      userId: userId,
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: isCancelled,
      parkingEnd: DateTime.parse(endingDatetime.toString()),
      // parkingEnd: endingDatetime?.parsedDatetime ?? DateTime(1700),
      createdAt: DateTime.parse(createdAt.toString()),
      // createdAt: createdAt?.parsedDatetime ?? DateTime(1700),
      // parkingFrom: tempActualArrivalDatetime?.parsedDatetime ?? DateTime(1700)
      parkingFrom: DateTime.parse(tempActualArrivalDatetime.toString()),
    );
  }

  SpaceBooking copyWith({String? leaving, Vehicle? vehicle}) => SpaceBooking(
      id: id,
      address: address,
      arriving: arriving,
      leaving: leaving ?? this.leaving,
      billAmount: billAmount,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userImage: userImage,
      createdAt: createdAt,
      parkingEnd: parkingEnd,
      userId: userId,
      vehicle: vehicle ?? this.vehicle,
      parkingSpace: parkingSpace,
      isCancelled: isCancelled,
      parkingFrom: parkingFrom);

  @override
  String toString() {
    return 'SpaceBooking{id: $id, address: $address, arriving: $arriving, leaving: $leaving, , parkingEnd: $parkingEnd, parkingFrom: $parkingFrom, createdAt: $createdAt, billAmount: $billAmount, userName: $userName, userPhone: $userPhone, userEmail: $userEmail, userImage: $userImage, userId: $userId, vehicle: $vehicle, parkingSpace: $parkingSpace, isCancelled: $isCancelled}';
  }
}

class HostSpacesResponse extends BaseResponse {
  final List<ParkingSpaceDetail> parkingSpaces;

  HostSpacesResponse(bool status, String message, {required this.parkingSpaces})
      : super(status: status, message: message);

  factory HostSpacesResponse.fromJson(Map<String, dynamic> json) {
    final statusMessage = StatusMessageResponse.formJson(json);
    final parkingSpaces = json.containsKey('parkingSpaces')
        ? (json['parkingSpaces'] as List<dynamic>?)
            ?.map((dynamic e) => e as Map<String, dynamic>)
            .map((e) => ParkingSpaceDetail.fromJson(e))
            .toList()
        : null;
    return HostSpacesResponse(statusMessage.status, statusMessage.message,
        parkingSpaces: parkingSpaces ?? []);
  }
}

class DashboardDetailsResponse extends BaseResponse {
  final int bookings;
  final num earning;
  final List<MonthlyData> monthlyDataList;
  final List<Reviews> reviews;

  DashboardDetailsResponse(StatusMessageResponse statusMessageResponse,
      {required this.bookings,
      required this.earning,
      required this.monthlyDataList,
      required this.reviews})
      : super(
            message: statusMessageResponse.message,
            status: statusMessageResponse.status);

  factory DashboardDetailsResponse.fromJson(Map<String, dynamic> json) {
    final statusMessage = StatusMessageResponse.formJson(json);
    final bookings = json.containsKey('bookings') ? json['bookings'] : 0;
    final earning = json.containsKey('earning') ? json['earning'] : 0.0;
    final monthlyData = json.containsKey('monthlyData')
        ? (json['monthlyData'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .map((e) => MonthlyData.fromJson(e))
            .toList()
        : null;
    final reviews = json.containsKey('reviews')
        ? (json['reviews'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .map((e) => Reviews.fromJson(e))
            .toList()
        : null;
    return DashboardDetailsResponse(statusMessage,
        bookings: bookings,
        earning: earning,
        monthlyDataList: monthlyData ?? [],
        reviews: reviews ?? []);
  }
}

class MonthlyData {
  final String month;
  final num earning;

  MonthlyData(this.month, this.earning);

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    final month = json.containsKey('month') ? json['month'] : '';
    final earning = json.containsKey('earning') ? json['earning'] : 0.0;
    return MonthlyData(month, earning);
  }
}

class Reviews {
  // static const String _IMAGE_BASE_URL = 'https://business.rent2park.com/images/users/';
  static const String _IMAGE_BASE_URL = 'https://dev.rent2park.com/';
  final String date;
  final num rating;
  final String? comment;
  final String userName;
  final String? userImage;

  Reviews(
      {required this.date,
      required this.rating,
      required this.comment,
      required this.userName,
      required this.userImage});

  factory Reviews.fromJson(Map<String, dynamic> json) {
    final date = json.containsKey('date') ? json['date'] : '';
    final rating = json.containsKey('rating') ? json['rating'] : 0.0;
    final String? comment =
        json.containsKey('comment') ? json['comment'] : null;
    final userName = json.containsKey('userName') ? json['userName'] : '';
    final userImage = json.containsKey('userImage') ? json['userImage'] : null;
    String? tempImage;
    if (userImage != null) tempImage = _IMAGE_BASE_URL + userImage;
    return Reviews(
        date: date,
        rating: rating,
        comment: comment,
        userImage: tempImage,
        userName: userName);
  }

  @override
  String toString() {
    return 'Reviews{date: $date, rating: $rating, comment: $comment, userName: $userName, userImage: $userImage}';
  }
}

class AllMessageResponse extends BaseResponse {
  final List<Message> messages;

  AllMessageResponse(bool status, String message, {required this.messages})
      : super(status: status, message: message);

  factory AllMessageResponse.fromJson(Map<String, dynamic> json) {
    final statusMessageResponse = StatusMessageResponse.formJson(json);
    final chats = json.containsKey('result')
        ? (json['result'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .map((Map<String, dynamic> e) => Message.fromJson(e))
            .toList()
        : null;
    return AllMessageResponse(
        statusMessageResponse.status, statusMessageResponse.message,
        messages: chats ?? []);
  }
}

class Message {
  // static const String _IMAGE_URL = "https://business.rent2park.com/images/users/";
  static const String _IMAGE_URL = 'https://dev.rent2park.com/';
  final String name;
  final String? image;
  final String message;
  final String id;
  final String datetime;
  final int unread;

  Message(
      {required this.name,
      required this.image,
      required this.message,
      required this.id,
      required this.datetime,
      required this.unread});

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = json.containsKey('message') ? json['message'] : '';
    final name = json.containsKey('name') ? json['name'] : '';
    final id = json.containsKey('id') ? json['id'] : '';
    final image = json.containsKey('image') ? json['image'] : null;
    final String createdAt = json['created'];
    final List<String> createdAtSplits = createdAt.split('T');
    String datetime = '';
    if (createdAtSplits.isNotEmpty && createdAtSplits.length == 2) {
      final date = createdAtSplits[0];
      final time = createdAtSplits[1];

      final dateSplits = date.split('-');
      final timeSplits = time.split(':');
      final tempDatetime = DateTime(
          int.tryParse(dateSplits[0]) ?? 1970,
          int.tryParse(dateSplits[1]) ?? 1,
          int.tryParse(dateSplits[2]) ?? 1,
          int.tryParse(timeSplits[0]) ?? 1,
          int.tryParse(timeSplits[1]) ?? 0);
      // last had month.name
      datetime =
          '${tempDatetime.hour}:${tempDatetime.minute} ${tempDatetime.day}-${tempDatetime.month}';
    }
    final int unread = json['unread'];

    return Message(
        name: name,
        image: image == null ? null : _IMAGE_URL + image,
        message: message,
        id: id,
        datetime: datetime,
        unread: unread);
  }

  Message copyWith({int? unreadCount}) => Message(
      name: name,
      image: image,
      message: message,
      id: id,
      datetime: datetime,
      unread: unreadCount ?? this.unread);

  @override
  String toString() {
    return 'Message{name: $name, image: $image, message: $message, id: $id, datetime: $datetime, unread: $unread}';
  }
}

class DetailedMessagesResponse extends BaseResponse {
  final List<DetailedMessage> messages;

  DetailedMessagesResponse(bool status, String message,
      {required this.messages})
      : super(status: status, message: message);

  factory DetailedMessagesResponse.fromJson(
      Map<String, dynamic> json, String? myImage) {
    final statusMessageResponse = StatusMessageResponse.formJson(json);
    final messages = json.containsKey('result')
        ? (json['result'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .map((Map<String, dynamic> e) =>
                DetailedMessage.fromJson(e, myImage))
            .toList()
        : null;
    return DetailedMessagesResponse(
        statusMessageResponse.status, statusMessageResponse.message,
        messages: messages ?? []);
  }
}

class DetailedMessage {
  // static const String _IMAGE_URL = "https://business.rent2park.com/images/users/";
  static const String _IMAGE_URL = 'https://dev.rent2park.com/';
  final String id;
  final String messageId;
  final String? image;
  final String message;
  final String dateTime;
  final String? myImage;

  DetailedMessage.initial(String message, String? myImage, int id, String time)
      : this(
            messageId: '',
            image: null,
            message: message,
            dateTime: time,
            myImage: myImage,
            id: '$id');

  DetailedMessage(
      {required this.messageId,
      required this.image,
      required this.message,
      required this.dateTime,
      this.myImage,
      required this.id});

  factory DetailedMessage.fromJson(Map<String, dynamic> json, String? myImage) {
    final message = json.containsKey('message') ? json['message'] : '';
    final messageId = json.containsKey('messageId') ? json['messageId'] : '';
    final id = json.containsKey('id') ? json['id'] : '';
    final dateTime = json.containsKey('dateTime') ? json['dateTime'] : '';
    final image = json.containsKey('image') ? json['image'] : null;

    return DetailedMessage(
        messageId: messageId,
        image: image == null ? null : _IMAGE_URL + image,
        message: message,
        dateTime: dateTime,
        myImage: myImage,
        id: id);
  }

  @override
  String toString() {
    return 'DetailedMessage{id: $id, messageId: $messageId, image: $image, message: $message, dateTime: $dateTime, myImage: $myImage}';
  }
}

class PaymentCard {
  final String id;
  final String name;
  final String email;
  final String brand;
  String expiryMonth;
  final String expiryYear;
  final String last4;
  final String funding;
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String postal_code;
  final String state;
  final DateTime createdAt;
  Color? cardColor;

  PaymentCard({
    required this.id,
    required this.name,
    required this.email,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.last4,
    required this.funding,
    required this.createdAt,
    required this.cardColor,
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postal_code,
    required this.state,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final billingObject = json['billing_details'] as Map<String, dynamic>;
    final name = billingObject['name'] ?? "";
    final email = billingObject['email'];
    final city = json['billing_details']['address']['city'] ?? "";
    final country = json['billing_details']['address']['country'] ?? "";
    final line1 = json['billing_details']['address']['line1'] ?? "";
    final line2 = json['billing_details']['address']['line2'] ?? "";
    final postalCode = json['billing_details']['address']['postal_code'] ?? "";
    final state = json['billing_details']['address']['state'] ?? "";

    final cardObject = json['card'] as Map<String, dynamic>;
    final brand = cardObject['brand'];
    final expiryMonth = cardObject['exp_month'].toString();
    final expiryYear = cardObject['exp_year'].toString();
    final last4 = cardObject['last4'];
    final tempCreatedAt = json['created'];
    final funding = cardObject['funding'];

    final createdAt = DateTime.fromMillisecondsSinceEpoch(tempCreatedAt);

    return PaymentCard(
        id: id,
        name: name,
        email: email,
        brand: brand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        last4: last4,
        createdAt: createdAt,
        funding: funding,
        city: city,
        country: country,
        line1: line1,
        line2: line2,
        postal_code: postalCode,
        state: state,
        cardColor: Color(0xFF000000));
  }

  @override
  String toString() {
    return 'PaymentCard{id: $id, name: $name, email: $email, brand: $brand, expiryMonth: $expiryMonth, expiryYear: $expiryYear, last4: $last4, createdAt: $createdAt, funding: $funding,cardColor: $cardColor,city: $city,country: $country,line1: $line1,line2: $line2,state: $state,city: $city}';
  }
}

class BankAccount {
  final String id;
  final String accountHolderName;
  final String accountHolderType;
  final String country;
  final String bankName;
  final String currency;
  final String last4;
  final String routingNumber;
  final bool isPayoutEnable;

  BankAccount(
      {required this.id,
      required this.accountHolderName,
      required this.accountHolderType,
      required this.country,
      required this.bankName,
      required this.currency,
      required this.isPayoutEnable,
      required this.last4,
      required this.routingNumber});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    final String id = json['id'];
    final Map<String, dynamic> externalAccountJson = json['external_accounts'];
    final accountDataJson = (externalAccountJson['data'] as List<dynamic>)
        .map((e) => e as dynamic)
        .map((e) => e as Map<String, dynamic>)
        .first;

    final String accountHolderName = accountDataJson['account_holder_name'];
    final String accountHolderType = accountDataJson['account_holder_type'];
    final String bankName = accountDataJson['bank_name'];
    final String country = accountDataJson['country'];
    final String currency = accountDataJson['currency'];
    final String last4 = accountDataJson['last4'];
    final String routingNumber = accountDataJson['routing_number'];
    final bool isPayoutEnabled = json['payouts_enabled'];

    return BankAccount(
        id: id,
        accountHolderName: accountHolderName,
        accountHolderType: accountHolderType,
        country: country,
        bankName: bankName,
        currency: currency,
        isPayoutEnable: isPayoutEnabled,
        last4: last4,
        routingNumber: routingNumber);
  }

  @override
  String toString() {
    return 'BankAccount{id: $id, accountHolderName: $accountHolderName, accountHolderType: $accountHolderType, country: $country, bankName: $bankName, currency: $currency, last4: $last4, routingNumber: $routingNumber, isPayoutEnable: $isPayoutEnable}';
  }
}

class BankAccountNew {
  final String id;
  final String accountHolderName;
  final String accountHolderType;
  final String country;
  final String bankName;
  final String currency;
  final String last4;
  final String accountType;
  final String routingNumber;
  final String status;
  final bool isPayoutEnable;

  BankAccountNew(
      {required this.id,
      required this.accountHolderName,
      required this.accountHolderType,
      required this.country,
      required this.bankName,
      required this.accountType,
      required this.currency,
      required this.isPayoutEnable,
      required this.last4,
      required this.status,
      required this.routingNumber});

  factory BankAccountNew.fromJson(Map<String, dynamic> json) {
    final String id = json['id'];

    final String object = json['object'];
    final String accountHolderName = json['account_holder_name'];
    final String accountHolderType = json['account_holder_type'];
    final String accountType = json['account_type'] ?? "";
    final String bankName = json['bank_name'];
    final String country = json['country'];
    final String currency = json['currency'];
    final String customer = json['customer'];
    final String fingerprint = json['fingerprint'];
    final String last4 = json['last4'];
    final String metadata = json['metadata'].toString();
    final String routingNumber = json['routing_number'];
    final String status = json['status'];

    return BankAccountNew(
        id: id,
        accountHolderName: accountHolderName,
        accountHolderType: accountHolderType,
        country: country,
        bankName: bankName,
        currency: currency,
        accountType: accountType,
        isPayoutEnable: false,
        last4: last4,
        status: status,
        routingNumber: routingNumber);
  }

  @override
  String toString() {
    return 'BankAccount{id: $id, accountHolderName: $accountHolderName, accountHolderType: $accountHolderType, country: $country, bankName: $bankName,accountType: $accountType, currency: $currency, last4: $last4,status: $status, routingNumber: $routingNumber, isPayoutEnable: $isPayoutEnable}';
  }
}
