import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rent2park/ui/main/reservation/common/host_single_booking_new_tem.dart';

import '../../../../data/backend_responses.dart';
import '../../../../data/meta_data.dart';
import '../../../../data/user_type.dart';
import '../../../my_space_screen.dart';
import '../../../reservation_detail_screen.dart';
import '../../main_screen_bloc.dart';
import '../../main_screen_state.dart';
import '../common/driver_single_booking_item_widget.dart';
import '../common/host_single_booking_item_widget.dart';
import '../reservation_navigation_screen_bloc.dart';
import '../reservation_navigation_screen_state.dart';

class PastTabItemWidget extends StatefulWidget {
  final PageStorageKey<String> key;

  const PastTabItemWidget({required this.key}) : super(key: key);

  @override
  _PastTabItemWidgetState createState() => _PastTabItemWidgetState();
}

class _PastTabItemWidgetState extends State<PastTabItemWidget> {
  final RefreshController _refreshController = RefreshController();
  late MainScreenBloc _mainBloc;
  late ReservationNavigationScreenBloc _reservationBloc;

  @override
  void initState() {
    _mainBloc = context.read<MainScreenBloc>();
    _reservationBloc = context.read<ReservationNavigationScreenBloc>();
    _requestPastBooking(true);
    super.initState();
  }

  void _requestPastBooking(bool flag) {
    if (_mainBloc.state.userType == UserType.driver)
      _reservationBloc.requestDriverPastBooking(flag);
    else
      _reservationBloc.requestHostPastBooking(flag);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scrollbar(
        child: BlocListener<ReservationNavigationScreenBloc,
            ReservationNavigationScreenState>(
      listener: (_, __) => _refreshController.refreshCompleted(),
      listenWhen: (previous, current) =>
          previous.pastSwipeRefreshState != current.pastSwipeRefreshState,
      child: SmartRefresher(
          header: MaterialClassicHeader(),
          enablePullDown: true,
          onRefresh: () => _requestPastBooking(false),
          controller: _refreshController,
          child: BlocListener<MainScreenBloc, MainScreenState>(
              listener: (_, state) => _requestPastBooking(true),
              listenWhen: (previous, current) =>
                  previous.userType != current.userType,
              child: BlocBuilder<ReservationNavigationScreenBloc,
                      ReservationNavigationScreenState>(
                  buildWhen: (previous, current) =>
                      previous.pastDataEvent != current.pastDataEvent,
                  builder: (_, state) {
                    final dataEvent = state.pastDataEvent;
                    if (dataEvent is Initial)
                      return const SizedBox();
                    else if (dataEvent is Loading)
                      return Container(
                          width: size.width,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    else if (dataEvent is Empty)
                      return showDummyList(_mainBloc.state.userEvent);

                    // EmptyListItemWidget(size: size, title: dataEvent.message);
                    else if (dataEvent is Error)
                      return showDummyList(_mainBloc.state.userEvent);

                    /* return SingleErrorTryAgainWidget(
                          onClick: () => _requestPastBooking(true));*/

                    final data = (dataEvent as Data).data as List<SpaceBooking>;

                    return Container(
                      margin: EdgeInsets.only(top: 5),
                      child: ListView.separated(
                          itemBuilder: (_, index) {
                            final spaceBooking = data[index];
                            final userType = _mainBloc.state.userType;
                            return userType == UserType.driver
                                ? DriverSingleBookingItemWidget(
                                    spaceBooking: spaceBooking,
                                    from: "past",
                                    userType: userType,
                                    onClick: () => Navigator.pushNamed(
                                        context, ReservationDetailScreen.route,
                                        arguments: [spaceBooking, true]
                                        // arguments: {
                                        //   Constants.SPACE_BOOKING:
                                        //       spaceBooking,
                                        //   Constants
                                        //       .SPACE_BOOKING_RESERVATION_TEXT: ''
                                        // }
                                        ))
                                : HostSingleBookingItemWidget(
                                    spaceBooking: spaceBooking,
                                    onClick: () => Navigator.pushNamed(
                                        context, MySpaceScreen.route,
                                        arguments: [spaceBooking, true]));
                          },
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              Divider(thickness: 0.5, height: 0.5),
                          itemCount: data.length),
                    );
                  }))),
    ));
  }

  Widget showDummyList(DataEvent userEvent) {
    var vehicle = Vehicle(
        id: "1",
        year: "2022",
        make: "Gray Explorer",
        vehicleModel: "Ford",
        color: "color",
        registerationNum: "registerationNum",
        vehicleType: "vehicleType",
        image:
            "https://imageio.forbes.com/specials-images/imageserve/5d35eacaf1176b0008974b54/2020-Chevrolet-Corvette-Stingray/0x0.jpg?format=jpg&crop=4560,2565,x790,y784,safe&width=960",
        divingLicenseImage: "divingLicenseImage");
    List<Reviews> reviews = [];
    List<ParkingSpaceSlot> slots = [];
    List<String> parkingSpacePhotos = [""];
    User user = User(
        firstName: "Abhi",
        lastName: "P",
        email: "abhishekh@gmail.com",
        id: 1,
        dob: "",
        image: "image",
        referralCode: "referralCode",
        phoneNumber: "phoneNumber",
        isPhoneVerify: true,
        isEmailVerify: true,
        customerId: "customerId",
        connectAccountId: "connectAccountId",
        accessToken: "accessToken");

    List<String> locationOffers = [];
    var parkingSpace = ParkingSpaceDetail(
        id: "1",
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
        spaceInstruction:
            "The gate code is: 7689#, when you leave there is no need for code.",
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

    var spaceBookings = SpaceBooking(
      id: 1,
      address: "645 NE 27th Dr, Wilton Manors, FL USA",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10,
      userName: "Abhi P",
      userEmail: "abhishek@gmail.com",
      userPhone: "9876543214",
      userImage:
          "https://st1.bollywoodlife.com/wp-content/uploads/2022/07/Allu-23.png",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime(currentDate.year, currentDate.month, currentDate.day),
    );
    var spaceBookings2 = SpaceBooking(
      id: 2,
      address: "645 NE 27th Dr, Wilton Manors, FL USA",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10,
      userName: "Abhi P",
      userEmail: "abhishek@gmail.com",
      userPhone: "9876543214",
      userImage:
          "https://st1.bollywoodlife.com/wp-content/uploads/2022/07/Allu-23.png",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: true,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime.now(),
    );
    var spaceBookings3 = SpaceBooking(
      id: 3,
      address: "645 NE 27th Dr, Wilton Manors, FL USA",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10,
      userName: "Abhi P",
      userEmail: "abhishek@gmail.com",
      userPhone: "9876543214",
      userImage:
          "https://st1.bollywoodlife.com/wp-content/uploads/2022/07/Allu-23.png",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime(currentDate.year, currentDate.month + 1,
          currentDate.day, currentDate.hour, currentDate.minute),
      createdAt: DateTime.now(),
    );
    var spaceBookings4 = SpaceBooking(
      id: 4,
      address: "645 NE 27th Dr, Wilton Manors, FL USA",
      arriving: "30th Dec at 4:00am",
      leaving: "31st Dec at 01:00am",
      billAmount: 10,
      userName: "Abhi P",
      userEmail: "abhishek@gmail.com",
      userPhone: "9876543214",
      userImage: "https://st1.bollywoodlife.com/wp-content/uploads/2022/07/Allu-23.png",
      userId: "userId",
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      isCancelled: false,
      parkingFrom: DateTime.now(),
      parkingEnd: DateTime.now().add(Duration(days: 1)),
      createdAt: DateTime.now(),
    );

    List<SpaceBooking> spaceBookingList = [];
    spaceBookingList.add(spaceBookings);
    spaceBookingList.add(spaceBookings2);
    spaceBookingList.add(spaceBookings3);
    spaceBookingList.add(spaceBookings4);

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.separated(
          itemBuilder: (_, index) {
            final userType = _mainBloc.state.userType;

            return userType == UserType.driver
                ? DriverSingleBookingItemWidget(
                    spaceBooking: spaceBookingList[index],
                    userType: userType,
                    from: "past",
                    onClick: () => Navigator.pushNamed(
                        context, ReservationDetailScreen.route,
                        arguments: [spaceBookingList[index], "past"]
                        // arguments: {
                        //   Constants.SPACE_BOOKING:
                        //       spaceBooking,
                        //   Constants
                        //       .SPACE_BOOKING_RESERVATION_TEXT: ''
                        // }
                        ))
                : HostSingleBookingNewItemWidget(
                    spaceBooking: spaceBookingList[index],
                    from: "past",
                    onClick: () => Navigator.pushNamed(
                        context, MySpaceScreen.route,
                        arguments: [spaceBookingList[index], true, false]));
          },
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => SizedBox(),
          itemCount: spaceBookingList.length),
    );
  }
}
