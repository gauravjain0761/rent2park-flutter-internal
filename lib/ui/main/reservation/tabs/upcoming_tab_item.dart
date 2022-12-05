import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../data/backend_responses.dart';
import '../../../../data/meta_data.dart';
import '../../../../data/user_type.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../booking_detail_screen.dart';
import '../../../my_space_screen.dart';
import '../../main_screen_bloc.dart';
import '../../main_screen_state.dart';
import '../common/driver_single_booking_item_widget.dart';
import '../common/host_single_booking_item_widget.dart';
import '../common/host_single_booking_new_tem.dart';
import '../reservation_navigation_screen_bloc.dart';
import '../reservation_navigation_screen_state.dart';


class UpcomingTabItemWidget extends StatefulWidget {
  final PageStorageKey<String> key;

  const UpcomingTabItemWidget({required this.key}) : super(key: key);

  @override
  _UpcomingTabItemWidgetState createState() => _UpcomingTabItemWidgetState();
}

class _UpcomingTabItemWidgetState extends State<UpcomingTabItemWidget> {
  final RefreshController _refreshController = RefreshController();
  late MainScreenBloc _mainBloc;
  late ReservationNavigationScreenBloc _reservationBloc;

  @override
  void initState() {
    _mainBloc = context.read<MainScreenBloc>();
    _reservationBloc = context.read<ReservationNavigationScreenBloc>();
    _requestUpcomingBooking(true);
    super.initState();
  }

  void _requestUpcomingBooking(bool flag) {
    if (_mainBloc.state.userType == UserType.driver)
      _reservationBloc.requestDriverUpcomingBooking(flag);
    else
      _reservationBloc.requestHostUpcomingBooking(flag);
  }

  @override
  Widget build(BuildContext context) {

    var vehicle = Vehicle(id: "1",
        year: "2022",
        make: "Gray Explorer",
        vehicleModel: "Ford",
        color: "color",

        registerationNum: "registerationNum",
        vehicleType: "vehicleType",
        image: "https://imageio.forbes.com/specials-images/imageserve/5d35eacaf1176b0008974b54/2020-Chevrolet-Corvette-Stingray/0x0.jpg?format=jpg&crop=4560,2565,x790,y784,safe&width=960",
        divingLicenseImage: "divingLicenseImage");
    List<Reviews> reviews = [];
    List<ParkingSpaceSlot> slots = [];
    List<String> parkingSpacePhotos = [""];
    User user = User(firstName: "Abhi",
        lastName: "P",
        email: "abhishekh@gmail.com",
        id: 1,
        dob: "",
        isEmailVerify: true,
        image: "image",
        referralCode: "referralCode",
        phoneNumber: "phoneNumber",
        isPhoneVerify: true,
        customerId: "customerId",
        connectAccountId: "connectAccountId",
        accessToken: "accessToken");

    List<String> locationOffers= [];
    var parkingSpace = ParkingSpaceDetail(id: "1",
        country: "country",
        address: "601 Northeast 29th 601 Northeast 29th",
        latitude: 0.0,
        longitude: 0.0,
        numberOfSpaces: 1,
        isReservable: true,
        parkingType: "parkingType",
        vehicleSize: "2",
        hasHeightLimits: false,
        isRequiredPermit: false,
        isRequiredKey: false,
        spaceInformation: "spaceInformation",
        spaceInstruction: "The gate code is: 7689#, when you leave there is no need for code.",
        locationOffers: locationOffers,
        isAutomated: true,
        hourlyPrice: 20,
        dailyPrice: 200,
        weeklyPrice: 400,
        monthlyPrice: 700,
        isMaximumBookingPrice: true,
        parkingSpacePhotos: parkingSpacePhotos,
        slots: slots,
        appUser: user,
        totalBookings: 2,
        countryCode: "countryCode",
        evTypes: "evTypes",
        reviews: reviews,
        active: 0);
      var currentDate = DateTime.now();


    var spaceBookings = SpaceBooking(id: 1,
      address: "address",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10.00,
      userName: "Abhi P",
      userEmail: "abhishekh@gmail.com",
      userPhone: "9876543214",
      userImage: "userImage",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime.now());

    var spaceBookings2 = SpaceBooking(id: 1,
      address: "address",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10.00,
      userName: "Abhi P",
      userEmail: "abhishekh@gmail.com",
      userPhone: "9876543214",
      userImage: "userImage",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime.now(),);
    var spaceBookings3 = SpaceBooking(id: 1,
      address: "address",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10.00,
      userName: "Abhi P",
      userEmail: "abhishekh@gmail.com",
      userPhone: "9876543214",
      userImage: "userImage",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime(currentDate.year,currentDate.month+1,currentDate.day,currentDate.hour,currentDate.minute),

      createdAt: DateTime(currentDate.year,currentDate.month+1,currentDate.day),);
    var spaceBookings4 = SpaceBooking(id: 1,
      address: "address",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10.00,
      userName: "Abhi P",
      userEmail: "abhishekh@gmail.com",
      userPhone: "9876543214",
      userImage: "userImage",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime.now(),);

    List<SpaceBooking> spaceBookingList = [];
    spaceBookingList.add(spaceBookings);
    spaceBookingList.add(spaceBookings2);
    spaceBookingList.add(spaceBookings3);
    spaceBookingList.add(spaceBookings4);



    final size = MediaQuery.of(context).size;
    return Scrollbar(
        child: BlocListener<ReservationNavigationScreenBloc, ReservationNavigationScreenState>(
      listener: (_, __) => _refreshController.refreshCompleted(),
      listenWhen: (previous, current) => previous.upcomingSwipeRefreshState != current.upcomingSwipeRefreshState,
      child: SmartRefresher(
          header: MaterialClassicHeader(),
          enablePullDown: true,
          onRefresh: () => _requestUpcomingBooking(false),
          controller: _refreshController,
          child: BlocListener<MainScreenBloc, MainScreenState>(
              listener: (_, state) => _requestUpcomingBooking(true),
              listenWhen: (previous, current) => previous.userType != current.userType,
              child: BlocBuilder<ReservationNavigationScreenBloc, ReservationNavigationScreenState>(
                  buildWhen: (previous, current) => previous.upcomingDataEvent != current.upcomingDataEvent,
                  builder: (_, state) {
                    final dataEvent = state.upcomingDataEvent;
                    if (dataEvent is Initial)
                      return const SizedBox();
                    else if (dataEvent is Loading)
                      return Container(width: size.width, alignment: Alignment.center, child: CircularProgressIndicator());
                    else if (dataEvent is Empty)
                      // return EmptyListItemWidget(size: size, title: dataEvent.message);
                      return dummyUpcomingList(spaceBookingList);
                    else if (dataEvent is Error)
                      return dummyUpcomingList(spaceBookingList);

                    // return SingleErrorTryAgainWidget(onClick: () => _requestUpcomingBooking(true));
                    final data = (dataEvent as Data).data as List<SpaceBooking>;
                    context.read<MainScreenBloc>().updateReservations(data.length);
                    return ListView.separated(
                      padding: EdgeInsets.only(top: 5),
                        itemBuilder: (_, index) {
                          final spaceBooking = data[index];
                          final userType = _mainBloc.state.userType;
                          return userType == UserType.driver
                              ? DriverSingleBookingItemWidget(
                                  userType: userType,
                                  spaceBooking: spaceBooking,
                                  from: "upcoming",
                                  onClick: () {
                                    Navigator.pushNamed(
                                            context, BookingDetailScreen.route,
                                            arguments: {
                                              Constants
                                                  .SPACE_BOOKING: spaceBooking,
                                              Constants
                                                  .SPACE_BOOKING_RESERVATION_TEXT: AppText
                                                  .CANCEL_RESERVATION
                                            });
                                  })
                              : HostSingleBookingItemWidget(
                                  spaceBooking: spaceBooking,
                                  onClick: () =>
                                      Navigator.pushNamed(context, MySpaceScreen.route, arguments: [spaceBooking, false]));
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => SizedBox(),
                        itemCount: data.length);
                  }))),
    ));
  }

  Widget dummyUpcomingList(List<SpaceBooking> spaceBookingList) {
    return ListView.separated(
        padding: EdgeInsets.only(top: 5),
        itemBuilder: (_, index) {
          final spaceBooking = spaceBookingList[index];
          final userType = _mainBloc.state.userType;
          return userType == UserType.driver
              ? DriverSingleBookingItemWidget(
              userType: userType,
              spaceBooking: spaceBooking,
              from: "upcoming",
              onClick: () {
                print("1231234");

                Navigator.pushNamed(
                        context, BookingDetailScreen.route, arguments: {
                      Constants.SPACE_BOOKING: spaceBooking,
                      Constants.SPACE_BOOKING_RESERVATION_TEXT: AppText
                          .CANCEL_BOOKING
                    });
              })
              : HostSingleBookingNewItemWidget(
              spaceBooking: spaceBooking,
              from: "upcoming",
              onClick: () =>
                  Navigator.pushNamed(context, MySpaceScreen.route, arguments: [spaceBooking, false,true]));
        },
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => SizedBox(),
        itemCount: spaceBookingList.length);
  }
}
