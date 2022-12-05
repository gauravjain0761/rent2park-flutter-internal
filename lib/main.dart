import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent2park/extension/primitive_extension.dart';
import 'package:rent2park/ui/add-new-vehicle/add_update_vehicle_bloc.dart';
import 'package:rent2park/ui/add-new-vehicle/add_update_vehicle_screen.dart';
import 'package:rent2park/ui/add_space/add_space_screen.dart';
import 'package:rent2park/ui/add_space/add_space_screen_bloc.dart';
import 'package:rent2park/ui/all-cards/all_cards_screen.dart';
import 'package:rent2park/ui/all-cards/all_cards_screen_bloc.dart';
import 'package:rent2park/ui/attach-bank-account/attach_bank_account_screen.dart';
import 'package:rent2park/ui/attach-bank-account/attach_bank_account_screen_bloc.dart';
import 'package:rent2park/ui/booking_detail_screen.dart';
import 'package:rent2park/ui/change-password/chage_password_bloc.dart';
import 'package:rent2park/ui/change-password/change_password_screen.dart';
import 'package:rent2park/ui/checkout-earning/checkout_earning_screen_bloc.dart';
import 'package:rent2park/ui/checkout-earning/checkout_earnings_screen.dart';
import 'package:rent2park/ui/custom_date_time_picker/custom_date_time_picker_screen.dart';
import 'package:rent2park/ui/custom_date_time_picker/custom_date_time_picker_screen_bloc.dart';
import 'package:rent2park/ui/forgot_password/forgot_password_bloc.dart';
import 'package:rent2park/ui/forgot_password/forgot_password_screen.dart';
import 'package:rent2park/ui/introduction_screen.dart';
import 'package:rent2park/ui/login/login_bloc.dart';
import 'package:rent2park/ui/login/login_screen.dart';
import 'package:rent2park/ui/main/dashboard/dashboard_navigation_bloc.dart';
import 'package:rent2park/ui/main/help/help_screen.dart';
import 'package:rent2park/ui/main/home/home_navigation_screen_bloc.dart';
import 'package:rent2park/ui/main/home/verify-otp/verify_otp_screen.dart';
import 'package:rent2park/ui/main/home/verify-otp/verify_otp_screen_bloc.dart';
import 'package:rent2park/ui/main/home/verify_email/verifyEmailBloc.dart';
import 'package:rent2park/ui/main/home/verify_email/verifyEmailScreen.dart';
import 'package:rent2park/ui/main/home/verify_phone/verify_phone_screen.dart';
import 'package:rent2park/ui/main/home/verify_phone/verify_phone_screen_bloc.dart';
import 'package:rent2park/ui/main/main_screen.dart';
import 'package:rent2park/ui/main/main_screen_bloc.dart';
import 'package:rent2park/ui/main/manage-my-space/manage_my_space_screen_bloc.dart';
import 'package:rent2park/ui/main/messages/message_navigation_screen_bloc.dart';
import 'package:rent2park/ui/main/profile/profile_bloc.dart';
import 'package:rent2park/ui/main/reservation/reservation_navigation_screen_bloc.dart';
import 'package:rent2park/ui/manage_vehicle/manage_vehicle_bloc.dart';
import 'package:rent2park/ui/manage_vehicle/manage_vehicle_screen.dart';
import 'package:rent2park/ui/message-details/message_details_screen.dart';
import 'package:rent2park/ui/message-details/message_details_screen_bloc.dart';
import 'package:rent2park/ui/my_space_screen.dart';
import 'package:rent2park/ui/payment/payment_screen.dart';
import 'package:rent2park/ui/payment/payment_screen_bloc.dart';
import 'package:rent2park/ui/rate_driver_screen.dart';
import 'package:rent2park/ui/reservation_detail_screen.dart';
import 'package:rent2park/ui/secure_checkout/secure_checkout_screen_bloc.dart';
import 'package:rent2park/ui/sign-up/sign_up_screen.dart';
import 'package:rent2park/ui/sign-up/signup_bloc.dart';
import 'package:rent2park/ui/space_success_screen.dart';
import 'package:rent2park/ui/splash_screen.dart';
import 'package:rent2park/ui/street-view/street_view_screen.dart';
import 'package:rent2park/ui/street-view/street_view_screen_bloc.dart';
import 'package:rent2park/ui/wallet/AddEditBankAccount.dart';
import 'package:rent2park/ui/wallet/AddEditDebitCreditCards.dart';
import 'package:rent2park/ui/wallet/Wallet.dart';
import 'package:rent2park/ui/wallet/wallet_bloc.dart';
import 'package:rent2park/util/SizeConfig.dart';
import 'package:rent2park/util/app_strings.dart';
import 'package:rent2park/util/constants.dart';
import 'data/backend_responses.dart';

import 'helper/notification_helper.dart';
import 'helper/shared_pref_helper.dart';
import 'ui/secure_checkout/secure_checkout_screen.dart';

const _COLOR_SCHEME = ColorScheme(
    primary: Constants.COLOR_PRIMARY,
    secondary: Constants.COLOR_SECONDARY,
    surface: Constants.COLOR_SURFACE,
    background: Constants.COLOR_BACKGROUND,
    error: Constants.COLOR_ERROR,
    onPrimary: Constants.COLOR_ON_PRIMARY,
    onSecondary: Constants.COLOR_ON_SECONDARY,
    onSurface: Constants.COLOR_ON_SURFACE,
    onBackground: Constants.COLOR_ON_BACKGROUND,
    onError: Constants.COLOR_ON_ERROR,
    brightness: Brightness.dark);

final _mySystemTheme = SystemUiOverlayStyle.light
    .copyWith(statusBarIconBrightness: Brightness.light);

ThemeData _buildAppThemeData() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      primaryColor: Constants.COLOR_PRIMARY,
      sliderTheme: SliderThemeData(thumbColor: Constants.COLOR_SECONDARY),
      scaffoldBackgroundColor: Constants.COLOR_SURFACE,
      errorColor: Constants.COLOR_ERROR, colorScheme: _COLOR_SCHEME.copyWith(secondary: Constants.COLOR_SECONDARY));
}

class _AppRouter {
  ManageVehicleBloc? _manageVehicleBloc;
  ReservationNavigationScreenBloc? _reservationNavigationScreenBloc;
  ManageMySpaceScreenBloc? _manageMySpaceScreenBloc;
  MessageNavigationScreenBloc? _messageNavigationScreenBloc;

  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.route:
        {
          final route = SplashScreen();
          return MaterialPageRoute(builder: (_) => route);
        }
      case LoginScreen.route:
        {
          final argumentMap = settings.arguments as Map<String, bool>;
          final bool isFromIntro =
              argumentMap[Constants.IS_FROM_ROUTE_KEY] as bool;
          final route = LoginScreen(isFromIntro: isFromIntro);
          return MaterialPageRoute(
              builder: (_) =>
                  BlocProvider(create: (_) => LoginBloc(), child: route));
        }
      case SignUpScreen.route:
        {
          final argumentMap = settings.arguments as Map<String, bool>;
          final bool isFromIntro =
              argumentMap[Constants.IS_FROM_ROUTE_KEY] as bool;
          final route = SignUpScreen(isFromIntro: isFromIntro);
          return MaterialPageRoute(
              builder: (_) =>
                  BlocProvider(create: (_) => SignUpBloc(), child: route));
        }
      case ForgotPassword.route:
        {
          final route = ForgotPassword();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => ForgotPasswordBloc(), child: route));
        }
      case MainScreen.route:
        {
          final bool isFromSignup = settings.arguments as bool? ?? false;
          final screen = const MainScreen();
          _reservationNavigationScreenBloc = ReservationNavigationScreenBloc();
          _manageMySpaceScreenBloc = ManageMySpaceScreenBloc();
          _messageNavigationScreenBloc = MessageNavigationScreenBloc();
          return MaterialPageRoute(
              builder: (context) => MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (_) => MainScreenBloc(context,
                            isFromSignup: isFromSignup)),
                    BlocProvider(create: (_) {
                      final size = MediaQuery.of(context).size;
                      return HomeNavigationScreenBloc(size: size);
                    }),
                    BlocProvider(create: (_) => ProfileBloc()),
                    BlocProvider(create: (_) => VerifyOtpScreenBloc()),
                    BlocProvider.value(
                        value: _reservationNavigationScreenBloc!),
                    BlocProvider.value(value: _manageMySpaceScreenBloc!),
                    BlocProvider(create: (_) => DashboardNavigationBloc()),
                    BlocProvider.value(value: _messageNavigationScreenBloc!),
                  ], child: screen));
        }
      case BookingDetailScreen.route:
        {
          final argumentMap = settings.arguments as Map<String, dynamic>;
          final spaceBooking =
              argumentMap[Constants.SPACE_BOOKING] as SpaceBooking;
          final reservationText =
              argumentMap[Constants.SPACE_BOOKING_RESERVATION_TEXT] as String;
          final screen = BookingDetailScreen(
              spaceBooking: spaceBooking, reservationText: reservationText);

          return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                  value: _reservationNavigationScreenBloc!, child: screen));
        }
      case ReservationDetailScreen.route:
        {
          final argumentList = settings.arguments as List<dynamic>;
          final spaceBooking = argumentList[0] as SpaceBooking;
          final isFrom = argumentList[1] as String;
          final screen = ReservationDetailScreen(
              spaceBooking: spaceBooking, isFrom: isFrom);
          return MaterialPageRoute(builder: (_) => screen);
        }
      case AddSpaceScreen.route:
        {
          // final spaceDetail = settings.arguments as backend_response.ParkingSpaceDetail?;
          final spaceDetail = settings.arguments as ParkingSpaceDetail?;
          final screen = const AddSpaceScreen();
          return MaterialPageRoute(
              builder: (context) => MultiBlocProvider(providers: [

                    BlocProvider.value(value: _manageMySpaceScreenBloc!),
                    BlocProvider(
                        create: (_) {
                          final size = MediaQuery.of(context).size;
                          return HomeNavigationScreenBloc(size: size);
                        }),
                    BlocProvider(
                        create: (_) =>
                            AddSpaceScreenBloc(parkingSpaceDetail: spaceDetail))
                  ], child: screen));
        }
      case IntroductionScreen.route:
        {
          final screen = const IntroductionScreen();
          return MaterialPageRoute(builder: (_) => screen);
        }
      case ManageVehicleScreen.route:
        {
          final bool isFromSelection = settings.arguments as bool;
          final screen = ManageVehicleScreen(isFromSelection: isFromSelection);
          if (_manageVehicleBloc == null)
            _manageVehicleBloc = ManageVehicleBloc();
          return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                  value: _manageVehicleBloc!, child: screen));
        }
      case SpaceAddedSuccessfullyScreen.route:
        {
          final isFromAdd = settings.arguments as bool? ?? true;
          final screen = SpaceAddedSuccessfullyScreen(isFromAdd: isFromAdd);
          return MaterialPageRoute(builder: (_) => screen);
        }
      case PaymentScreen.route:
        {
          final screen = const PaymentScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => PaymentScreenBloc(), child: screen));
        }

      case AddEditDebitCreditCards.route:
        {
          final argumentMap = settings.arguments as Map<String, dynamic>;
          var paymentCard;
          if(argumentMap["paymentCard"]!=null){
            paymentCard = argumentMap["paymentCard"] as PaymentCard;
          }
          final isNew = argumentMap["isNew"] as bool;
          final screen =
              AddEditDebitCreditCards(paymentCard: paymentCard, isNew: isNew);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => PaymentScreenBloc(), child: screen));
        }

      case AddUpdateVehicleScreen.route:
        {
          final vehicle = settings.arguments as Vehicle?;
          final screen = const AddUpdateVehicleScreen();
          return MaterialPageRoute(
              builder: (_) => MultiBlocProvider(providers: [
                    BlocProvider<AddUpdateVehicleBloc>(
                        create: (_) => AddUpdateVehicleBloc(vehicle: vehicle)),
                    BlocProvider.value(value: _manageVehicleBloc!)
                  ], child: screen));
        }
      case MySpaceScreen.route:
        {
          final argumentList = settings.arguments as List<dynamic>;
          final spaceBooking = argumentList[0] as SpaceBooking;
          final isFromPastBooking = argumentList[1] as bool;
          final isFromUpcomingBooking = argumentList[2] as bool;
          final screen = MySpaceScreen(
              spaceBooking: spaceBooking,
              isFromPastBooking: isFromPastBooking,
              isFromUpcomingBooking: isFromUpcomingBooking);
          return MaterialPageRoute(builder: (_) => screen);
        }
      case SecureCheckoutScreen.route:
        {
          final argumentMap = settings.arguments as Map<String, dynamic>;
          final ParkingSpaceDetail spaceDetail =
              argumentMap[Constants.SPACE_DETAIL];
          final String totalDuration =
              argumentMap[Constants.SPACE_TOTAL_DURATION];
          final String destination = argumentMap[Constants.SPACE_DESTINATION];
          final String totalPrice = argumentMap[Constants.TOTAL_PRICE];
          final DateTime parkingFrom = argumentMap[Constants.PARKING_FROM];
          final DateTime parkingUntil = argumentMap[Constants.PARKING_UNTIL];
          final String parkingSpaceId = argumentMap[Constants.PARKING_SPACE_ID];
          final String driverName = argumentMap[Constants.DRIVER_DETAIL_NAME];
          final String driverEmail = argumentMap[Constants.DRIVER_DETAIL_EMAIL];
          final String driverPhone = argumentMap[Constants.DRIVER_DETAIL_PHONE];
          final screen = SecureCheckoutScreen(
              spaceDetail: spaceDetail,
              totalDuration: totalDuration,
              destination: destination,
              totalPrice: totalPrice,
              parkingFrom: parkingFrom,
              parkingUntil: parkingUntil,
              parkingSpaceId: parkingSpaceId,
              personalName: driverName,
              personalEmail: driverEmail,
              personalPhone: driverPhone);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => SecureCheckoutScreenBloc(), child: screen));
        }
      case ChangePasswordScreen.route:
        {
          final route = ChangePasswordScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider<ChangePasswordBloc>(
                    create: (context) => ChangePasswordBloc(),
                    child: route,
                  ));
        }
      case CheckoutEarningsScreen.route:
        {
          const screen = CheckoutEarningsScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => CheckoutEarningScreenBloc(), child: screen));
        }
      case CustomDateTimePickerScreen.route:
        {
          final parkingDates = settings.arguments as List<DateTime>;
          final parkingFromDatetime = parkingDates[0];
          final maxDatetime = parkingDates[1];
          final screen =
              CustomDateTimePickerScreen(minDatetime: parkingFromDatetime);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => CustomDateTimePickerScreenBloc(
                      minDateTime: parkingFromDatetime,
                      lastSelectionDatetime: maxDatetime),
                  child: screen));
        }
      case StreetViewScreen.route:
        {
          final argumentMapEntry =
              settings.arguments as MapEntry<double, double>;
          final lat = argumentMapEntry.key;
          final lng = argumentMapEntry.value;
          final screen = StreetViewScreen(lat: lat, lng: lng);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => StreetViewScreenBloc(), child: screen));
        }
      case MessageDetailsScreen.route:
        {
          final Map<String, dynamic> map =
              settings.arguments as Map<String, dynamic>;
          final String partnerId = map['id'];
          final screen = MessageDetailsScreen(name: map['name']);
          return MaterialPageRoute(
              builder: (_) => MultiBlocProvider(providers: [
                    BlocProvider(
                        create: (_) =>
                            MessageDetailScreenBloc(partnerId: partnerId)),
                    BlocProvider.value(value: _messageNavigationScreenBloc!)
                  ], child: screen));
        }
      case VerifyPhoneScreen.route:
        {
          final List list = settings.arguments as List;

          final screen = VerifyPhoneScreen(phoneNumber: list[0]);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (context) => VerifyPhoneScreenBloc(), child: screen));
        }
        case VerifyEmailScreen.route:
        {
          final List list = settings.arguments as List;

          final screen = VerifyEmailScreen(email: list[0]);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (context) => VerifyEmailScreenBloc(), child: screen));
        }

      case VerifyOTPScreen.route:
        {
          final List list = settings.arguments as List;
          final route = VerifyOTPScreen(type: list[0], phoneNumberOrEmail: list[1],pinCode: "");
          return MaterialPageRoute(
              builder: (_) => MultiBlocProvider(providers: [
                BlocProvider(
                    create: (_) =>
                        VerifyOtpScreenBloc()),
                BlocProvider(
                    create: (_) =>
                        ProfileBloc()),

              ], child: route));

                  /*BlocProvider(
                  create: (_) => VerifyOtpScreenBloc(), child: route));*/
        }
      case RateDriverScreen.route:
        {
          final map = settings.arguments as Map<String, dynamic>;
          final String spaceId = map[Constants.PARKING_SPACE_ID];
          final String driverId = map[Constants.DRIVER_ID];
          final String driverName = map[Constants.DRIVER_DETAIL_NAME];
          final screen = RateDriverScreen(
              driverName: driverName, driverId: driverId, spaceId: spaceId);
          return MaterialPageRoute(builder: (_) => screen);
        }
      case AllCardsScreen.route:
        {
          final isCardSelection = settings.arguments as bool? ?? false;
          const screen = AllCardsScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) =>
                      AllCardsScreenBloc(isForSelection: isCardSelection),
                  child: screen));
        }

      case WalletScreen.route:
        {
          final isCardSelection = settings.arguments as bool? ?? false;
          var screen = WalletScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) => WalletBloc(),
                  child: screen));
        }
      case AttachBankAccountScreen.route:
        {
          final bankAccount = settings.arguments as BankAccount? ?? null;
          const screen = AttachBankAccountScreen();
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) =>
                      AttachBankAccountScreenBloc(bankAccount: bankAccount),
                  child: screen));
        }

      case AddEditBankAccount.route:
        {
          final argumentMap = settings.arguments as Map<String, dynamic>;
          var bankAccountData;
          if(argumentMap["bankAccount"]!=null){
            bankAccountData = argumentMap["bankAccount"] as BankAccountNew;
          }
          final isNew = argumentMap["isNew"] as bool;

          var screen = AddEditBankAccount(bankAccount: bankAccountData,isNew: isNew);
          return MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (_) =>
                      AttachBankAccountScreenBloc(bankAccount: null),
                  child: screen));
        }

      case TermsAndConditionScreen.route:
        {
          const screen = TermsAndConditionScreen();
          return MaterialPageRoute(builder: (_) => screen);
        }
      default:
        return null;
    }
  }

  void dispose() {
    _manageVehicleBloc?.close();
    _reservationNavigationScreenBloc?.close();
    _manageMySpaceScreenBloc?.close();
    _messageNavigationScreenBloc?.close();
  }
}

class _App extends StatefulWidget {
  const _App();

  @override
  __AppState createState() => __AppState();
}

class __AppState extends State<_App> {
  final _router = _AppRouter();

  @override
  void initState() {
    SharedPreferenceHelper.initializeSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: GlobalVariable.navigatorState,
        title: AppText.APP_NAME,
        debugShowCheckedModeBanner: false,
        theme: _buildAppThemeData(),
        onGenerateRoute: _router.onGenerateRoute);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

}

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(_mySystemTheme);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF35c7c7),
  ));
  runApp(const _App());
  /*runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapSample(),
    ),
  );*/
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getToken();
  final notificationHelper = NotificationHelper.instance;
  final data = message.data;
  final String driverName =
      data.containsKey('driverName') ? data['driverName'] : '';
  final String driverId = data.containsKey('driverId') ? data['driverId'] : '';
  final String spaceId = data.containsKey('spaceId') ? data['spaceId'] : '';
  final String spaceAddress =
      data.containsKey('spaceAddress') ? data['spaceAddress'] : '';
  if (driverId.isEmpty || spaceId.isEmpty || spaceAddress.isEmpty) return;
  notificationHelper.showNotification('Space Booking Completed',
      'Your space located at $spaceAddress is completed with $driverName. In order to rate the driver click me!',
      payload: json.encode(data));
}

class GlobalVariable {
  /// This global key is used in material app for navigation through firebase notifications.
  static final GlobalKey<NavigatorState> navigatorState =
      GlobalKey<NavigatorState>();
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late ClusterManager _manager;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = Set();

  final CameraPosition _parisCameraPosition =
  CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);

  List<Place> items = [
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Place $i',
          latLng: LatLng(48.848200 + i * 0.001, 2.319124 + i * 0.001)),
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Restaurant $i',

          latLng: LatLng(48.858265 - i * 0.001, 2.350107 + i * 0.001)),
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Bar $i',
          latLng: LatLng(48.858265 + i * 0.01, 2.350107 - i * 0.01)),
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Hotel $i',
          latLng: LatLng(48.858265 - i * 0.1, 2.350107 - i * 0.01)),
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Test $i',
          latLng: LatLng(66.160507 + i * 0.1, -153.369141 + i * 0.1)),
    for (int i = 0; i < 10; i++)
      Place(
          name: 'Test2 $i',
          latLng: LatLng(-36.848461 + i * 1, 169.763336 + i * 1)),
  ];
  late Size size;
  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return new Scaffold(
      body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _parisCameraPosition,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            _manager.setMapId(controller.mapId);
          },
          onCameraMove: _manager.onCameraMove,
          onCameraIdle: _manager.updateMap),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _manager.setItems(<Place>[
            for (int i = 0; i < 30; i++)
              Place(
                  name: 'New Place ${DateTime.now()} $i',
                  latLng: LatLng(48.858265 + i * 0.01, 2.350107))
          ]);
        },
        child: Icon(Icons.update),
      ),
    );
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
          (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print('---- ${cluster.getId()}');
            cluster.items.forEach((p) => print(p));
          },
          icon: await _getMarkerBitmap(size,cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(Size screenSize,int size, {String? text} ) async {
    var  isEv = false;
    var  isSpaceBooked = false;
    var  markerTaped = false;

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
          fontSize: screenSize.width * 0.055,
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
              text: "2.0",
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
      imageWidth = getProportionateScreenWidth(215, screenSize.width).toInt();
      imageHeight = getProportionateScreenHeight(210, screenSize.height).toInt();
    }else if(Platform.isAndroid){
      imageWidth = getProportionateScreenWidth(140, screenSize.width).toInt();
      imageHeight = getProportionateScreenHeight(135, screenSize.height).toInt();
    }



    final image;
    if(size>1){
      var markerImage = 'assets/pin_nav.png';
      image = await markerImage.imageFromAsset(imageWidth, imageHeight);
    }else if (isSpaceBooked) {
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
    var height =  2.0;

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

    ByteData? pngBytes = await (await p.toImage(screenSize.width ~/ 2, screenSize.height ~/ 6)).toByteData(format: ImageByteFormat.png);
    if(Platform.isIOS){
      pngBytes = await (await p.toImage(screenSize.width.toInt(), screenSize.height.toInt())).toByteData(format: ImageByteFormat.png);
    }else if(Platform.isAndroid){
      pngBytes = await (await p.toImage(screenSize.width ~/ 2, screenSize.height ~/ 6)).toByteData(format: ImageByteFormat.png);
    }




    Uint8List data = Uint8List.view(pngBytes!.buffer);
    return BitmapDescriptor.fromBytes(data);

  }
}

class Place with ClusterItem {
  final String name;
  final LatLng latLng;

  Place({required this.name, required this.latLng});

  @override
  LatLng get location => latLng;
}