import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:rent2park/data/EventSearchApiModel.dart';

import '../data/backend_responses.dart';
import '../data/exception.dart';

class SharedWebService {
  // static const String _BASE_URL = 'http://67.225.212.30:3000/';
  static const String _BASE_URL = 'https://dev.rent2park.com/api/';

  // static const String _BASE_URL = 'https://rent2park.loca.lt/api/';

  static SharedWebService instance = SharedWebService._internal();

  static final HttpWithMiddleware httpClient =
      HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);
  static final HttpClientWithMiddleware _streamedHttpClient =
      HttpClientWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  SharedWebService._internal();

  Future<AuthenticationResponse?> socialLogin(
      String? email,
      String uuid,
      String firstName,
      String lastName,
      String? image,
      String? phoneNumber,
      String provider) async {
    final headers = {'Accept': 'application/json'};
    final body = email != null
        ? {
            'Email': email,
            'FirstName': firstName,
            'LastName': lastName,
            'Uuid': uuid,
            'Provider': provider,
            'userType': '1'
          }
        : {
            'FirstName': firstName,
            'LastName': lastName,
            'Uuid': uuid,
            'Provider': provider,
            'userType': '1'
          };

    if (image != null) body['Image'] = image;
    if (phoneNumber != null) body['PhoneNumber'] = phoneNumber;
    print("params --> $body");
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_BASE_URL + 'account/login'));
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return await compute(parseAuthenticationResponse, responseData);
    } catch (e, st) {
      // throw NoInternetConnectException();
      throw ErrorGettingData(message: e.toString());
    }
  }

  Future<AuthenticationResponse?> login(String email, String password) async {
    Map<String, String> headers = {'Accept': 'application/json'};
    final body = {'email': email, 'password': password};
    try {
      final request = await http.post(
          // Uri.parse(_BASE_URL + 'v1/auth/user/signin'),
          Uri.parse(_BASE_URL + 'login'),
          headers: headers,
          body: body);
      print("resp --> ${request.body}");
      return await compute(parseAuthenticationResponse, request.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<AuthenticationResponse?> signup(
      {required String firstName,
      required String lastName,
      required String email,
      required String phoneNumber,
      required String password,
      required String referralCode}) async {
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};

    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'phone': phoneNumber,
      'email': email,
      'password': password,
      'referralCode': referralCode
    });

    try {
      // final uri = Uri.parse(_BASE_URL + 'v1/auth/user/signup');
      final uri = Uri.parse(_BASE_URL + 'register');
      final request = await http.post(uri, headers: headers, body: body);
      print("${request.statusCode} ${request.body}");
      //request.headers.addAll(headers);
      //request.fields.addAll(body);

      //final response = await request.send();
      //final responseData = await response.stream.bytesToString();
      return await compute(parseAuthenticationResponse, request.body);
      //return request;
    } catch (e) {
      print(e);
      //throw NoInternetConnectException();
    }
    return null;
  }

  Future<HomeResponse> driverHome(
      double lat,
      double lng,
      List<String> availableFeatures,
      List<String> parkingTypes,
      List<String> connectorTypes,
      int key,
      String accessToken,
      String startTime,
      String endTime) async {
    final headers = {
      'key': '$key',
      'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var body;
    if (parkingTypes.isEmpty && availableFeatures.isEmpty) {
      body = {
        'Latitude': lat,
        'Longitude': lng,
        'connectorTypes': connectorTypes,
        'start_time': startTime,
        'end_time': endTime,
        'created': DateTime.now().toString()
      };
    } else if (parkingTypes.isEmpty) {
      body = {
        'features': availableFeatures,
        'Latitude': lat,
        'Longitude': lng,
        'connectorTypes': connectorTypes,
        'start_time': startTime,
        'end_time': endTime,
        'created': DateTime.now().toString()
      };
    } else if (availableFeatures.isEmpty) {
      body = {
        'parkingTypes': parkingTypes,
        'Latitude': lat,
        'Longitude': lng,
        'connectorTypes': connectorTypes,
        'start_time': startTime,
        'end_time': endTime,
        'created': DateTime.now().toString()
      };
    } else {
      body = {
        'features': availableFeatures,
        'parkingTypes': parkingTypes,
        'Latitude': lat,
        'Longitude': lng,
        'connectorTypes': connectorTypes,
        'start_time': startTime,
        'end_time': endTime,
        'created': DateTime.now().toString()
      };
    }

    print("params---> $body");

    try {
      final uri = Uri.parse(_BASE_URL + 'Driver/home');
      final response =
          await http.post(uri, headers: headers, body: json.encode(body));
      print("responmse--> ${response.body}");
      return await compute(parseHomeResponse, response.body);
    } catch (_) {
      print("responmse--> Exce$_");
      throw NoInternetConnectException();
    }
  }

  Future<HomeResponse> hostHome(
      int key, String accessToken, String startTime, String endTime) async {
    final Map<String, String> headers = {
      'key': '$key',
      'Authorization': 'Bearer $accessToken'
    };
    try {
      final uri = Uri.parse(_BASE_URL +
          'Host/home/${DateTime.now().toString()}?start_time=$startTime &end_time=$endTime');
      print("uri---> $uri");
      final response = await http.get(uri, headers: headers);
      print("respinse --- ${response.body}");
      return await compute(parseHomeResponse, response.body);
    } catch (_) {
      print("respinse ---Exce $_");
      throw NoInternetConnectException();
    }
  }

  Future<StatusMessageResponse> updateParkingSpace(
      String accessToken,
      String country,
      String address,
      double latitude,
      double longitude,
      List<dynamic> spaceImages,
      int numberOfSpaces,
      bool isReservable,
      String parkingType,
      String vehicleSize,
      bool isHasHeightLimits,
      bool isRequiredPermit,
      bool isRequiredKey,
      bool isAutomated,
      num hourlyPrice,
      num dailyPrice,
      num weeklyPrice,
      num monthlyPrice,
      String spaceInformation,
      String spaceInstruction,
      List locationOffers,
      bool isMinimumBookingPrice,
      List<Map<String, dynamic>> slots,
      String countryCode,
      String evTypes,
      int key,
      String previousSpaceId) async {
    List<String> tempSpaceImages = [];

    if (spaceImages.isNotEmpty)
      tempSpaceImages =
          await Future.wait(spaceImages.whereType<PickedFile>().map((e) async {
        final imageBytes = await File(e.path).readAsBytes();
        return base64Encode(imageBytes);
      }).toList());

    final Map<String, String> headers = {
      'key': '$key',
      'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    List<String> evTypesArray = [];

    if (evTypes.isNotEmpty) {
      var newEvTypes = evTypes.substring(1);
      evTypesArray = newEvTypes.split(",");
    }

    var body;
    if (evTypesArray.isEmpty) {
      body = json.encode({
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'spaceImages': tempSpaceImages,
        'oldSpaceImages': spaceImages
            .whereType<String>()
            .map((e) => e.split('/').last)
            .toList(),
        'noOfSpaces': numberOfSpaces,
        'isReservable': isReservable ? 1 : 0,
        'parkingType': parkingType,
        'vehicleSize': vehicleSize,
        'heightLimits': isHasHeightLimits ? 1 : 0,
        'isRequiredPermit': isRequiredPermit ? 1 : 0,
        'isRequiredKey': isRequiredKey ? 1 : 0,
        'spaceInformation': spaceInformation,
        'spaceInstruction': spaceInstruction,
        'locationOffers': locationOffers,
        'isAutomated': isAutomated ? 1 : 0,
        'hourlyPrice': hourlyPrice,
        'dailyPrice': dailyPrice,
        'weeklyPrice': weeklyPrice,
        'monthlyPrice': monthlyPrice,
        'maximumBookingPrice': isMinimumBookingPrice ? 1 : 0,
        'slots': slots,
        'spaceId': previousSpaceId,
        'countryCode': countryCode
      });
    } else {
      body = json.encode({
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'spaceImages': tempSpaceImages,
        'oldSpaceImages': spaceImages
            .whereType<String>()
            .map((e) => e.split('/').last)
            .toList(),
        'noOfSpaces': numberOfSpaces,
        'isReservable': isReservable ? 1 : 0,
        'parkingType': parkingType,
        'vehicleSize': vehicleSize,
        'heightLimits': isHasHeightLimits ? 1 : 0,
        'isRequiredPermit': isRequiredPermit ? 1 : 0,
        'isRequiredKey': isRequiredKey ? 1 : 0,
        'spaceInformation': spaceInformation,
        'spaceInstruction': spaceInstruction,
        'locationOffers': locationOffers,
        'isAutomated': isAutomated ? 1 : 0,
        'hourlyPrice': hourlyPrice,
        'dailyPrice': dailyPrice,
        'weeklyPrice': weeklyPrice,
        'monthlyPrice': monthlyPrice,
        'maximumBookingPrice': isMinimumBookingPrice ? 1 : 0,
        'slots': slots,
        'spaceId': previousSpaceId,
        'countryCode': countryCode,
        'evConnectorTypes': evTypesArray
      });
    }

    print("udpate parking space params $body");

    try {
      final response = await http.post(
          Uri.parse(_BASE_URL + 'parkingspace/update'),
          headers: headers,
          body: body);
      print("response---> ${response.body}");
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      print("exception---> $_");
      throw NoInternetConnectException();
    }
  }

  Future<StatusMessageResponse> addParkingSpace(
      token,
      String country,
      String address,
      double latitude,
      double longitude,
      List<dynamic> spaceFiles,
      int numberOfSpaces,
      bool isReservable,
      String parkingType,
      String vehicleSize,
      bool isHasHeightLimits,
      bool isRequiredPermit,
      bool isRequiredKey,
      bool isAutomated,
      num hourlyPrice,
      num dailyPrice,
      num weeklyPrice,
      num monthlyPrice,
      String spaceInformation,
      String spaceInstruction,
      List<String> locationOffers,
      bool isMinimumBookingPrice,
      List<Map<String, dynamic>> slots,
      String countryCode,
      String evTypes,
      String key) async {
    List<String> tempSpaceImages = [];
    if (spaceFiles.isNotEmpty)
      tempSpaceImages =
          await Future.wait(spaceFiles.whereType<PickedFile>().map((e) async {
        final imageBytes = await File(e.path).readAsBytes();
        return base64Encode(imageBytes);
      }).toList());

    List<String> evTypesArray = [];
    if (evTypes.isNotEmpty) {
      var newEvTypes = evTypes.substring(1);
      evTypesArray = newEvTypes.split(",");
    }

    print("evtypes---> $evTypesArray");

    final Map<String, String> headers = {
      'key': '$key',
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body;

    if (evTypesArray.isEmpty) {
      body = json.encode({
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'noOfSpaces': numberOfSpaces,
        'isReservable': isReservable ? 1 : 0,
        'parkingType': parkingType,
        'vehicleSize': vehicleSize,
        'heightLimits': isHasHeightLimits ? 1 : 0,
        'isRequiredPermit': isRequiredPermit ? 1 : 0,
        'isRequiredKey': isRequiredKey ? 1 : 0,
        'spaceInformation': spaceInformation,
        'spaceInstruction': spaceInstruction,
        'locationOffers': locationOffers,
        'isAutomated': isAutomated ? 1 : 0,
        'hourlyPrice': hourlyPrice,
        'dailyPrice': dailyPrice,
        'weeklyPrice': weeklyPrice,
        'monthlyPrice': monthlyPrice,
        'maximumBookingPrice': isMinimumBookingPrice ? 1 : 0,
        'slots': slots,
        'countryCode': countryCode,
        'spaceImages': tempSpaceImages,
      });
    } else {
      body = json.encode({
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'noOfSpaces': numberOfSpaces,
        'isReservable': isReservable ? 1 : 0,
        'parkingType': parkingType,
        'vehicleSize': vehicleSize,
        'heightLimits': isHasHeightLimits ? 1 : 0,
        'isRequiredPermit': isRequiredPermit ? 1 : 0,
        'isRequiredKey': isRequiredKey ? 1 : 0,
        'spaceInformation': spaceInformation,
        'spaceInstruction': spaceInstruction,
        'locationOffers': locationOffers,
        'isAutomated': isAutomated ? 1 : 0,
        'hourlyPrice': hourlyPrice,
        'dailyPrice': dailyPrice,
        'weeklyPrice': weeklyPrice,
        'monthlyPrice': monthlyPrice,
        'maximumBookingPrice': isMinimumBookingPrice ? 1 : 0,
        'slots': slots,
        'countryCode': countryCode,
        'evConnectorTypes': evTypesArray,
        'spaceImages': tempSpaceImages,
      });
    }

    print("--->< $evTypesArray $locationOffers");
    try {
      final response = await http.post(
          Uri.parse(_BASE_URL + 'parkingspace/add'),
          headers: headers,
          body: body);
      print("fro.... ${response.body}");

      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      print("no... $_");

      throw NoInternetConnectException();
    }
  }

  Future<ParkingSpaceDetail> parkingSpace(
      int id, int key, String accessToken) async {
    final headers = {'key': '$key', 'Authorization': 'Bearer $accessToken'};
    try {
      final uri = Uri.parse(_BASE_URL + 'parkingspace/detail/$id');
      final response = await http.get(uri, headers: headers);
      final spaceDetailResponse =
          await compute(parseParkingSpaceDetail, response.body);
      final spaceDetail = spaceDetailResponse.spaceDetail;

      if (spaceDetail == null) throw Exception('No space found');
      return spaceDetail;
    } catch (_) {
      print("exception $_");
      throw NoInternetConnectException();
    }
  }

  Future<DistanceMatrixResponse> calculateDistanceResult(
      double originLat,
      double originLng,
      double destinationLat,
      double destinationLng,
      String key) async {
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originLat,$originLng&destinations=$destinationLat,$destinationLng&key=$key');
      final response = await http.get(uri);
      final responseBody = json.decode(response.body);
      return DistanceMatrixResponse.fromJson(responseBody);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<VehicleTypeResponse> getVehicleType(String? key) async {
    final headers = {'Authorization': 'Bearer $key', 'accept': '*/*'};
    try {
      final uri = Uri.parse(_BASE_URL + 'v1/vehicle-type');
      final response = await http.get(uri, headers: headers);
      final responseBody = json.decode(response.body);
      final vehicleTypeResponse = VehicleTypeResponse.fromJson(responseBody);
      print(vehicleTypeResponse.data![0].title);
      if (vehicleTypeResponse == null) throw Exception('No vehicle type found');
      return vehicleTypeResponse;
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<AddUpdateVehicleResponse> addNewVehicle(
      String token,
      int key,
      String? image,
      String year,
      String make,
      String vehicleModel,
      String color,
      String registrationNumber,
      String vehicleType,
      String drivingLicenseImage) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
      'key': '$key',
      'Authorization': "Bearer $token",
    };
    final Map<String, String> body = {
      'year': year,
      'make': make,
      'vehicleModel': vehicleModel,
      'color': color,
      'registrationNum': registrationNumber,
      'vehicleType': vehicleType
    };
    try {
      final uri = Uri.parse(_BASE_URL + 'vehicle/add');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      final licenseImageFile = await http.MultipartFile.fromPath(
          'drivingLicenseImage', drivingLicenseImage);
      request.files.add(licenseImageFile);

      if (image != null) {
        http.MultipartFile multipartFile =
            await http.MultipartFile.fromPath('image', image);
        request.files.add(multipartFile);
      }

      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return AddUpdateVehicleResponse.fromJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<AddUpdateVehicleResponse> updateVehicle(
      var token,
      int key,
      var image,
      var year,
      var make,
      var vehicleModel,
      var color,
      var registrationNumber,
      var vehicleType,
      var vehicleId,
      var drivingLicenseImage) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
      'key': '$key',
      'Authorization': "Bearer $token",
    };
    final body = {
      'year': year.toString(),
      'make': make.toString(),
      'vehicleModel': vehicleModel.toString(),
      'color': color.toString(),
      'registrationNum': registrationNumber.toString(),
      'vehicleType': vehicleType.toString(),
      'id': vehicleId.toString()
    };

    try {
      final uri = Uri.parse(_BASE_URL + 'vehicle');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      if (image != null) {
        http.MultipartFile multipartFile =
            await http.MultipartFile.fromPath('VehicleImage', image);
        request.files.add(multipartFile);
      }

      if (drivingLicenseImage != null) {
        final licenseImageFile = await http.MultipartFile.fromPath(
            'drivingLicenseImage', drivingLicenseImage);
        request.files.add(licenseImageFile);
      }
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return AddUpdateVehicleResponse.fromJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<AllVehicleResponse> getVehicles(String? token,
      {required int id}) async {
    final headers = {
      'Accept': 'application/json',
      'key': '$id',
      'Authorization': "Bearer $token",
    };
    print(headers);
    try {
      final uri = Uri.parse(_BASE_URL + 'vehicle/all');
      http.Response response = await http.get(uri, headers: headers);
      print("===vehicles ${response.body}");
      return await compute(parseAllVehiclesResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<StatusMessageResponse> deleteVehicle(
      var token, var vehicleId, int key) async {
    final headers = {
      'Accept': 'application/json',
      'key': '$key',
      'Authorization': "Bearer $token"
    };
    final body = {'id': vehicleId.toString()};
    try {
      // final uri = Uri.parse(_BASE_URL + 'vehicle/delete?VehicleId=$vehicleId');
      final uri = Uri.parse(_BASE_URL + 'vehicle/delete');
      final response = await http.post(uri, headers: headers, body: body);

      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (e) {
      throw NoInternetConnectException();
    }
  }

  Future<AuthenticationResponse> updateProfile(
      String token,
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String? image,
      String dob) async {
    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token'
    };
    final Map<String, String> body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dob': dob,
    };

    // final uri = Uri.parse(_BASE_URL + 'v1/profile');
    // final request = http.MultipartRequest('PATCH', uri);

    final uri = Uri.parse(_BASE_URL + 'profile');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);
    try {
      if (image != null) {
        http.MultipartFile multipartFile =
            await http.MultipartFile.fromPath('userImage', image);
        request.files.add(multipartFile);
      }
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      return await compute(parseAuthenticationResponse, responseData);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> changePassword(
      {required String oldPassword,
      required String newPassword,
      required String token
      // required int id
      }) async {
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      // 'confirmPassword': newPassword
    });
    final uri = Uri.parse(_BASE_URL + 'change-password');
    //final request = http.MultipartRequest('POST', uri);
    //request.headers.addAll(headers);
    try {
      final request = await http.post(uri, headers: headers, body: body);
      print(request.body);
      //request.fields.addAll(body);
      //final response = await request.send();
      //final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(request.body));
    } catch (e) {
      print(e);
      throw NoInternetConnectException();
    }
  }

  Future<DashboardDetailsResponse> dashboardDetails(int id) async {
    final headers = {'Accept': 'application/json', 'key': '$id'};
    try {
      final uri = Uri.parse(_BASE_URL + 'host/dashboard');
      final response = await http.get(uri, headers: headers);
      return await compute(parseDashboardDetailsResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> getBalance(int key) async {
    final headers = {'Accept': 'application/json', 'key': '$key'};
    try {
      final uri = Uri.parse(_BASE_URL + 'account/balance');
      final response = await http.get(uri, headers: headers);
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> bookASpace(
      String parkingSpaceId,
      int driverId,
      DateTime arriving,
      DateTime leaving,
      String vehicleId,
      String billAmount,
      String driverName,
      String driverEmail,
      String driverPhone,
      String paymentMethod) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data'
    };

    final body = {
      'ParkingSpaceId': parkingSpaceId,
      'DriverId': driverId.toString(),
      'Arriving': arriving.toString(),
      'created': DateTime.now().toString(),
      'Leaving': leaving.toString(),
      'VehicleId': vehicleId,
      'BillAmount': billAmount,
      'DriverName': driverName,
      'DriverEmail': driverEmail,
      'DriverPhone': driverPhone,
      'paymentMethod': paymentMethod
    };

    final uri = Uri.parse(_BASE_URL + 'booking/booknow');
    final request = http.MultipartRequest('POST', uri);
    try {
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> hostInProgressBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/host/inProgress?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> hostUpcomingBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/host/upcoming?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> hostPastBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/host/past?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> driverInProgressBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/driver/inProgress?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> driverUpcomingBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/driver/upcoming?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<SpaceBookingResponse> driverPastBookings(int id) async {
    final headers = {'key': '$id'};
    final uri = Uri.parse(_BASE_URL +
        'booking/driver/past?current_datetime=${DateTime.now().toString()}');
    try {
      final response = await http.get(uri, headers: headers);
      return await compute(parseBookingResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<HostSpacesResponse> hostParkingSpace(
      int id, String? accessToken) async {
    final headers = {'key': '$id', 'Authorization': 'Bearer $accessToken'};
    print("response--> $headers");

    final uri = Uri.parse(_BASE_URL + 'parkingspace/hostspaces');
    try {
      final response = await http.get(uri, headers: headers);
      print("response--> ${response.body}");
      return await compute(parseHostSpacesResponse, response.body);
    } catch (_) {
      print("responseError--> $_");
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> extendParkingSpace(
      int id, int hour, int bookingId) async {
    final headers = {'key': '$id', 'Content-Type': 'multipart/form-data'};
    final uri = Uri.parse(_BASE_URL + 'booking/extend');
    final body = {'hours': hour.toString(), 'bookingId': bookingId.toString()};
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> deleteParkingSpace(
      var accessToken, String parkingSpaceId, int key) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'key': '$key',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final uri = Uri.parse(_BASE_URL + 'parkingspace/delete/$parkingSpaceId');
      final response = await http.get(uri, headers: headers);
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> cancelSpaceBooking(int bookingId, int key) async {
    final headers = {
      'Accept': 'application/json',
      'key': '$key',
      'Content-Type': 'multipart/form-data'
    };
    final body = {'BookingId': bookingId.toString()};
    try {
      final uri = Uri.parse(_BASE_URL + 'booking/cancel');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> completeReservation(
      int bookingId, int key, String price) async {
    final headers = {
      'Accept': 'application/json',
      'key': '$key',
      'Content-Type': 'multipart/form-data'
    };
    final body = {
      'BookingId': bookingId.toString(),
      'Price': price,
      'current_datetime': DateTime.now().toString()
    };
    try {
      final uri = Uri.parse(_BASE_URL + 'booking/complete');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> updateUpcomingBookingVehicle(
      int bookingId, String vehicleId, int key) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
      'key': '$key'
    };
    final body = {'BookingId': bookingId.toString(), 'VehicleId': vehicleId};
    try {
      final uri = Uri.parse(_BASE_URL + 'booking/vehicle');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<AllMessageResponse> messages({required int id}) async {
    final headers = {'Accept': 'application/json', 'key': '$id'};
    try {
      final uri = Uri.parse(_BASE_URL + 'chat/all');
      final response = await http.get(uri, headers: headers);
      return await compute(parseMessagesResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<DetailedMessagesResponse> detailedMessages(
      {required int id,
      required String partnerId,
      required String? myImage}) async {
    final headers = {'Accept': 'application/json', 'key': '$id'};
    try {
      final uri =
          Uri.parse(_BASE_URL + 'chat?partnerId=$partnerId&skip=0&take=10');
      final response = await http.get(uri, headers: headers);
      return DetailedMessagesResponse.fromJson(
          json.decode(response.body), myImage);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> sendMessages(
      {required String receiverId,
      required int senderId,
      required String message}) async {
    final headers = {
      'Accept': 'application/json',
      'key': '$senderId',
      'Content-Type': 'application/json'
    };
    try {
      final uri = Uri.parse(_BASE_URL + 'chat/sendMessage');
      final senderBody =
          json.encode({'message': message, 'receiverId': receiverId});
      final response = await http.post(uri, headers: headers, body: senderBody);
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<EventSearchApiModel> getNearByEvents(String city) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };
    try {
      final uri = Uri.parse(
          "https://serpapi.com/search?q=events+in+$city&google_domain=google.com&gl=us&hl=en&api_key=5b131f5c29ba8622490ea6c0934ae94322c7a184531782072e818ad1ffb415b1");
      final response = await http.get(uri, headers: headers);
      return EventSearchApiModel.fromJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<void> sendToken(int id, String token) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
      'key': id.toString()
    };

    final senderBody = {'token': token};
    try {
      final uri = Uri.parse(_BASE_URL + 'account/token');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(senderBody);
      final response = await request.send();
      await response.stream.bytesToString();
    } catch (_) {}
  }

  Future<BaseResponse?> hostFeedback(String comment, double rating,
      String bookingId, String driverId, int key) async {
    final headers = {'Accept': 'application/json', 'key': '$key'};
    final body = json.encode({
      'comment': comment,
      'ratings': rating.toString(),
      'bookingId': bookingId,
      'driverId': driverId
    });
    try {
      final uri = Uri.parse(_BASE_URL + 'host/review');
      final response = await http.post(uri, headers: headers, body: body);
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      return null;
    }
  }

  Future<BaseResponse?> driverFeedback(
      {required String comment,
      required double rating,
      required int key,
      required int bookingId}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
      'key': key.toString()
    };
    final senderBody = {
      'comment': comment,
      'ratings': rating.toString(),
      'bookingId': bookingId.toString()
    };
    try {
      final uri = Uri.parse(_BASE_URL + 'review');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(senderBody);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      return null;
    }
  }

  Future<BaseResponse?> verifyPhoneNumber(int key, String phone) async {
    final headers = {'Accept': 'application/json', 'key': key.toString()};
    final senderBody = {'phone': phone};
    try {
      final uri = Uri.parse(_BASE_URL + 'account/verified');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(senderBody);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      return null;
    }
  }

  Future<BaseResponse> deleteChat(int key, String partnerId) async {
    final headers = {'Accept': 'application/json', 'key': '$key'};
    final body = {'partnerId': partnerId};
    try {
      final uri = Uri.parse(_BASE_URL + 'chat/delete');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> spaceActivateDeactivate(
      var accessToken, int key, String spaceId, bool isActivate) async {
    final headers = {
      'Accept': 'application/json',
      'key': "$key",
      'Authorization': "Bearer $accessToken"
    };
    final body = {'isActivate': isActivate ? '1' : '0', 'spaceId': spaceId};
    try {
      final uri = Uri.parse(_BASE_URL + 'parkingspace/activate');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> forgotPassword(String email) async {
    final body = {'email': email};
    try {
      final uri = Uri.parse(_BASE_URL + 'auth/forgot-password');
      final response = await http.post(uri, body: body);
      //final request = http.MultipartRequest('POST', uri);
      //request.fields.addAll(body);
      //final response = await request.send();
      //final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<BaseResponse> chatRead(String otherPersonId, String key) async {
    final body = {'messageId': otherPersonId};
    try {
      final uri = Uri.parse(_BASE_URL + 'chat/read');
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(body);
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return StatusMessageResponse.formJson(json.decode(responseData));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  Future<void> updateCustomerId(String customerId, int key) async {
    final body = {'customerId': customerId};
    final uri = Uri.parse(_BASE_URL + 'account/customerId');
    final request = http.MultipartRequest('POST', uri);
    request.fields.addAll(body);
    request.headers['key'] = '$key';
    await request.send();
  }

  Future<void> updateConnectAccountId(String connectBankId, int key) async {
    final body = {'connectAccountId': connectBankId};
    final uri = Uri.parse(_BASE_URL + 'account/connectAccountId');
    final request = http.MultipartRequest('POST', uri);
    request.fields.addAll(body);
    request.headers['key'] = '$key';
    await request.send();
  }

  Future<void> hostWithdraw(int key) async {
    final uri = Uri.parse(_BASE_URL + 'account/withdraw');
    final response = await http.post(uri, headers: {'key': '$key'});
  }

  //sendOTP to mobile
  Future<BaseResponse> sendOTPMobile(
      String phoneNumber, String? userId, String? accessToken) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': "Bearer $accessToken"
    };
    final body = {'phoneNumber': phoneNumber, 'user_id': userId};
    try {
      final uri = Uri.parse(_BASE_URL + 'send-otp');
      final response = await http.post(uri, body: body, headers: headers);
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  //verify mobile OTP
  Future<AuthenticationResponse> verifyOTPMobile(
      String? userId, String? accessToken, otp) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': "Bearer $accessToken"
    };
    final body = {'otp': otp, 'user_id': userId};
    try {
      final uri = Uri.parse(_BASE_URL + 'verfiy-otp');
      final response = await http.post(uri, body: body, headers: headers);
      print("---->phone  ${response.body}");
      return await compute(parseAuthenticationResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  //sendOTP to email
  Future<BaseResponse> sendOTPEmail(
      {required String email,
      required String? userId,
      required String? accessToken}) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': "Bearer $accessToken"
    };
    final body = {'user_id': userId, 'email': email};
    try {
      final uri = Uri.parse(_BASE_URL + 'email-send-otp');
      final response = await http.post(uri, body: body, headers: headers);
      print("---> ${response.body}");
      return StatusMessageResponse.formJson(json.decode(response.body));
    } catch (_) {
      throw NoInternetConnectException();
    }
  }

  //sendOTP to email
  Future<AuthenticationResponse> verifyEmailOTP(
      {required String otp,
      required String? userId,
      required String? accessToken}) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': "Bearer $accessToken"
    };
    final body = {'user_id': userId, 'otp': otp};
    try {
      final uri = Uri.parse(_BASE_URL + 'email-verify-otp');
      final response = await http.post(uri, body: body, headers: headers);
      return await compute(parseAuthenticationResponse, response.body);
    } catch (_) {
      throw NoInternetConnectException();
    }
  }
}

/// Responses
HostSpacesResponse parseHostSpacesResponse(String responseBody) =>
    HostSpacesResponse.fromJson(json.decode(responseBody));

SpaceBookingResponse parseBookingResponse(String responseBody) =>
    SpaceBookingResponse.fromJson(json.decode(responseBody));

ParkingSpaceDetailResponse parseParkingSpaceDetail(String responseBody) =>
    ParkingSpaceDetailResponse.fromJson(json.decode(responseBody));

AuthenticationResponse parseAuthenticationResponse(String responseBody) =>
    AuthenticationResponse.fromJson(json.decode(responseBody));

VehicleTypeResponse parseVehicleTypeResponse(String responseBody) =>
    VehicleTypeResponse.fromJson(json.decode(responseBody));

HomeResponse parseHomeResponse(String responseBody) =>
    HomeResponse.fromJson(json.decode(responseBody));

AllVehicleResponse parseAllVehiclesResponse(String responseBody) =>
    AllVehicleResponse.fromJson(json.decode(responseBody));

DashboardDetailsResponse parseDashboardDetailsResponse(String responseBody) =>
    DashboardDetailsResponse.fromJson(json.decode(responseBody));

AllMessageResponse parseMessagesResponse(String responseBody) =>
    AllMessageResponse.fromJson(json.decode(responseBody));
