import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/data/user_type.dart';
import 'package:rent2park/demo/SlotsBooking.dart';
import 'package:rent2park/ui/main/help/HelpScreen.dart';
import 'package:rent2park/ui/main/profile/profile_bloc.dart';
import 'package:rent2park/ui/main/profile/profile_navigation_screen.dart';
import 'package:rent2park/ui/main/reservation/reservation_navigation_screen.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/notification_helper.dart';
import '../../helper/shared_pref_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/light_app_bar.dart';
import '../invite_friends_screen.dart';
import '../login/login_screen.dart';
import 'dashboard/HostDashBoard.dart';
import 'dashboard/dashboard_navigation_bloc.dart';
import 'dashboard/dashboard_navigation_screen.dart';
import 'help/help_screen.dart';
import 'home/home_navigation_screen.dart';
import 'main_screen_bloc.dart';
import 'main_screen_state.dart';
import 'manage-my-space/manage_my_space_screen.dart';
import 'messages/message_navigation_screen.dart';

class MainScreen extends StatefulWidget {
  static const String route = 'main_screen_route';

  const MainScreen();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  static const _homeNavigationKey =
      PageStorageKey('home_navigation_screen_key');
  static const _reservationNavigationKey =
      PageStorageKey('reservation_navigation_screen_key');
  static const _messagesNavigationKey =
      PageStorageKey('messages_navigation_screen_key');
  static const _profileNavigationKey =
      PageStorageKey('profile_navigation_screen_key');
  static const _helpNavigationKey =
      PageStorageKey('help_navigation_screen_key');
  static const _inviteNavigationKey =
      PageStorageKey('invite_navigation_screen_key');
  static const _manageYourSpaceNavigationKey =
      PageStorageKey('manage_your_space_navigation_key');
  static const _dashboardNavigationKey =
      PageStorageKey('dashboard_navigation_key');

  final _drawerMap = <PageStorageKey<String>, Widget>{};
  var userType;

  @override
  void initState() {
    _drawerMap[_homeNavigationKey] = HomeNavigationScreen(key: _homeNavigationKey);
    // _drawerMap[_homeNavigationKey] = SlotsBooking(key: _homeNavigationKey);
    _drawerMap[_dashboardNavigationKey] = const SizedBox();
    _drawerMap[_reservationNavigationKey] = const SizedBox();
    _drawerMap[_manageYourSpaceNavigationKey] = const SizedBox();
    _drawerMap[_messagesNavigationKey] = const SizedBox();
    _drawerMap[_inviteNavigationKey] = const SizedBox();
    _drawerMap[_helpNavigationKey] = const SizedBox();
    _drawerMap[_profileNavigationKey] = const SizedBox();

    WidgetsBinding.instance.addObserver(this);

    if (Platform.isIOS)
      Future.value(AppTrackingTransparency.trackingAuthorizationStatus)
          .then((value) {
        if (value == TrackingStatus.notDetermined)
          Future.delayed(const Duration(seconds: 2)).then((_) {
            AppTrackingTransparency.requestTrackingAuthorization();
          });
      });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      NotificationHelper.instance.getLastPayload().then((value) {});
    }
  }
  late DateTime currentBackPressTime;



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(),
        drawer: _MainDrawerWidget(
            key: Key('main_screen_drawer_key'),
            itemClick: (int index) {
              final pageStorageKey = _drawerMap.keys.elementAt(index);
              final drawerItem = _drawerMap[pageStorageKey];
              if (drawerItem == null || drawerItem is SizedBox) {
                final newDrawerWidget = _getNavigationWidget(index);
                _drawerMap[pageStorageKey] = newDrawerWidget;
              }
              context.read<MainScreenBloc>().updatePageIndex(index);
            }),
        body: SafeArea(
            maintainBottomViewPadding: false,
            bottom: false,
            child: BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.pageIndex != current.pageIndex,
                builder: (_, state) => IndexedStack(
                    index: state.pageIndex,
                    children: _drawerMap.values.toList()))),
      ),
    );
  }

  Widget _getNavigationWidget(int index) {
    switch (index) {
      case 0:
        return const HomeNavigationScreen(key: _homeNavigationKey);
      case 1:
        // return HostDashBoard();
      return  const DashboardNavigationScreen(key: _dashboardNavigationKey);
      case 2:
        return const ReservationNavigationScreen(
            key: _reservationNavigationKey);
      case 3:
        return const ManageMySpaceScreen(key: _manageYourSpaceNavigationKey);
      case 4:
        return const MessageNavigationScreen(key: _messagesNavigationKey);
      case 5:
        return const InviteFriendsScreen(key: _inviteNavigationKey);
      case 6:
        return const TermsAndConditionScreen();
      case 7:
        return const ProfileNavigationScreen(key: _profileNavigationKey);

      default:
        return const SizedBox();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _MainDrawerWidget extends StatelessWidget {
  final Function(int) itemClick;

  _MainDrawerWidget({required Key key, required this.itemClick})
      : super(key: key);
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbar = SnackbarHelper.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  void logout({required BuildContext context}) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.LOGGING_OUT);
    await _sharedPrefHelper.clearData();
    await firebase_auth.FirebaseAuth.instance.signOut();
    _dialogHelper.dismissProgress();

    _snackbar
      ..injectContext(context)
      ..showSnackbar(
          snackbar: SnackbarMessage.success(
              message: AppText.ACCOUNT_HAS_BEEN_LOGOUT_SUCCESSFULLY));
    Future.delayed(
        const Duration(milliseconds: 800),
        () => Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.route, (route) => false,
            arguments: {Constants.IS_FROM_ROUTE_KEY: true}));
  }

  @override
  Widget build(BuildContext context) {
    final _profileBloc = context.read<ProfileBloc>();
    final bloc = context.read<MainScreenBloc>();
    final _userTypeExpandableController =
        ExpandableController(initialExpanded: false);
    const drawerTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_MEDIUM,
        fontSize: 16);
    return Drawer(
        child: Stack(alignment: Alignment.topLeft, children: [
      Positioned(
        top: 50,
        left: 5,
        child: Image(
          image: AssetImage('assets/drawer_logo.png'),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 45),
            Row(
              children: [
                const SizedBox(
                  height: 60,
                  width: 60,
                ),
                Flexible(
                  flex: 1,
                  child: BlocBuilder<MainScreenBloc, MainScreenState>(
                      buildWhen: (previous, current) {
                        return previous.userType != current.userType;
                      },
                      builder: (_, state) => InkWell(
                            onTap: () {
                              if (bloc.state.userType == UserType.driver)
                                return;
                              bloc.updateType(UserType.driver);
                              _userTypeExpandableController.toggle();
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: bloc.state.userType == UserType.driver
                                      ? Constants.COLOR_PRIMARY
                                      : Constants.COLOR_GREY_300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/driver.svg"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text("Driver",
                                        style: TextStyle(
                                            color: Constants.COLOR_ON_SECONDARY,
                                            fontFamily: Constants.GILROY_MEDIUM,
                                            fontSize: 15)),
                                  ),
                                ],
                              ),
                            ),
                          )),
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  flex: 1,
                  child: BlocBuilder<MainScreenBloc, MainScreenState>(
                      buildWhen: (previous, current) {
                        print('previous user $previous');
                        print('current user $current');
                        return previous.userType != current.userType;
                      },
                      builder: (_, state) => InkWell(
                            onTap: () {
                              if (bloc.state.userType == UserType.host) return;
                              bloc.updateType(UserType.host);
                              _userTypeExpandableController.toggle();
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: bloc.state.userType == UserType.host
                                      ? Constants.COLOR_PRIMARY
                                      : Constants.COLOR_GREY_300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/home_host.svg"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: Text("Host",
                                        style: TextStyle(
                                            color: Constants.COLOR_ON_SECONDARY,
                                            fontFamily: Constants.GILROY_MEDIUM,
                                            fontSize: 15)),
                                  ),
                                ],
                              ),
                            ),
                          )),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),

            /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(AppText.USER_TYPE, style: drawerTextStyle),
                    RawMaterialButton(
                        constraints: BoxConstraints(
                            maxHeight: 25,
                            minHeight: 25,
                            maxWidth: 70,
                            minWidth: 70),
                        splashColor: Color(0xff92d38d),
                        onPressed: () => _userTypeExpandableController.toggle(),
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BlocBuilder<MainScreenBloc, MainScreenState>(
                                buildWhen: (previous, current) {
                                  print('previous user $previous');
                                  print('current user $current');
                                  return previous.userType != current.userType;
                                },
                                builder: (_, state) => Text(
                                    state.userType.humanReadableName,
                                    style: const TextStyle(
                                        color: Color(0xff92d38d),
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 15))),
                            const Icon(Icons.arrow_drop_down_rounded,
                                color: Constants.COLOR_PRIMARY, size: 24)
                          ],
                        )),
                  ],
                )),
            ExpandableNotifier(
                controller: _userTypeExpandableController,
                child: Expandable(
                    collapsed: const SizedBox(),
                    expanded: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            onTap: () {
                              if (bloc.state.userType == UserType.driver) return;
                              bloc.updateType(UserType.driver);
                              _userTypeExpandableController.toggle();
                            },
                            leading: const Image(
                                image:
                                    AssetImage('assets/driver_sterring_icon.png'),
                                width: 26,
                                height: 26),
                            dense: true,
                            minVerticalPadding: 0,
                            horizontalTitleGap: 0,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            title: Text(UserType.driver.humanReadableName,
                                style: drawerTextStyle),
                            trailing:
                                BlocBuilder<MainScreenBloc, MainScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.userType != current.userType,
                                    builder: (_, state) =>
                                        state.userType == UserType.driver
                                            ? const Icon(Icons.done,
                                                color: Constants.COLOR_PRIMARY,
                                                size: 20)
                                            : const SizedBox()),
                          ),
                          ListTile(
                            onTap: () {
                              if (bloc.state.userType == UserType.host) return;
                              bloc.updateType(UserType.host);
                              _userTypeExpandableController.toggle();
                            },
                            leading: const Image(
                                image: AssetImage('assets/home_filled_icon.png'),
                                width: 24,
                                height: 24),
                            dense: true,
                            minVerticalPadding: 0,
                            horizontalTitleGap: 0,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            title: Text(UserType.host.humanReadableName,
                                style: drawerTextStyle),
                            trailing:
                                BlocBuilder<MainScreenBloc, MainScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.userType != current.userType,
                                    builder: (_, state) =>
                                        state.userType == UserType.host
                                            ? const Icon(Icons.done,
                                                color: Constants.COLOR_PRIMARY,
                                                size: 20)
                                            : const SizedBox()),
                          )
                        ]))),
*/
            BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.userType != current.userType,
                builder: (_, state) => state.userType == UserType.host
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          horizontalTitleGap: 0,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          onTap: () async {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => BlocProvider(
                                create: (context) => DashboardNavigationBloc(),
                                child: HostDashBoard())));
                            // if (bloc.state.pageIndex == 1) return;
                            // await Future.delayed(const Duration(milliseconds: 300));
                            // itemClick.call(1);
                          },
                          title: const Text(AppText.DASHBOARD,
                              style: drawerTextStyle),
                        )
                      ])
                    : const SizedBox()),
            ListTile(
              dense: true,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                Navigator.pop(context);
                if (bloc.state.pageIndex == 0) return;
                await Future.delayed(const Duration(milliseconds: 300));
                itemClick.call(0);
              },
              title: const Text(AppText.SEARCH, style: drawerTextStyle),
            ),
            ListTile(
              dense: true,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                Navigator.pop(context);
                if (bloc.state.pageIndex == 2) return;
                await Future.delayed(const Duration(milliseconds: 300));
                itemClick.call(2);
              },
              title: BlocBuilder<MainScreenBloc, MainScreenState>(
                  buildWhen: (previous, current) =>
                      previous.userType != current.userType,
                  builder: (_, state) => Text(
                      state.userType == UserType.host
                          ? AppText.MY_BOOKINGS
                          : AppText.MY_RESERVATION,
                      style: drawerTextStyle)),
              trailing: BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.reservations != current.reservations,
                builder: (_, state) => state.reservations != 0
                    ? Container(
                        decoration: const BoxDecoration(
                            color: Constants.COLOR_SECONDARY,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(state.reservations.toString(),
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SECONDARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 11)),
                      )
                    : const SizedBox(),
              ),
            ),
            BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.userType != current.userType,
                builder: (_, state) => state.userType == UserType.host
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          horizontalTitleGap: 0,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          onTap: () async {
                            Navigator.pop(context);
                            if (bloc.state.pageIndex == 3) return;
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            itemClick.call(3);
                          },
                          title: const Text(AppText.MANAGE_MY_SPACE,
                              style: drawerTextStyle),
                        )
                      ])
                    : const SizedBox()),
            ListTile(
              dense: true,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                if (bloc.state.pageIndex == 4) return;
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 300));
                itemClick.call(4);
              },
              title: Text(AppText.MESSAGES, style: drawerTextStyle),
              trailing: BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.messageCount != current.messageCount,
                builder: (_, state) => state.messageCount > 0
                    ? Container(
                        decoration: const BoxDecoration(
                            color: Constants.COLOR_SECONDARY,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(state.messageCount.toString(),
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SECONDARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 11)),
                      )
                    : const SizedBox(),
              ),
            ),
            ListTile(
                dense: true,
                minVerticalPadding: 0,
                horizontalTitleGap: 0,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: () async {
                  Navigator.pop(context);
                  if (bloc.state.pageIndex == 5) return;
                  await Future.delayed(const Duration(milliseconds: 300));
                  itemClick.call(5);
                },
                title:
                    const Text(AppText.INVITE_FRIEND, style: drawerTextStyle)),
            ListTile(
              dense: true,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                Navigator.pop(context);
                if (bloc.state.pageIndex == 6) return;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HelpScreen()));
                // await Future.delayed(const Duration(milliseconds: 300));

                // launch('https://rent2park.com');
              },
              title: const Text(AppText.HELP, style: drawerTextStyle),
            ),

            /*ListTile(
              dense: true,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                Navigator.pop(context);
                if (bloc.state.pageIndex == 6) return;
                await Future.delayed(const Duration(milliseconds: 300));
                launch('https://rent2park.com/privacy-policy/');
              },
              title: const Text(AppText.LEGAL, style: drawerTextStyle),
            ),*/

            BlocBuilder<MainScreenBloc, MainScreenState>(
                buildWhen: (previous, current) =>
                    previous.userEvent != current.userEvent,
                builder: (_, state) {
                  final userEvent = state.userEvent;

                  return ListTile(
                    dense: true,
                    minVerticalPadding: 0,
                    horizontalTitleGap: 0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    onTap: () => !(userEvent is Data)
                        ? Future.delayed(
                            const Duration(milliseconds: 800),
                            () => Navigator.pushNamedAndRemoveUntil(
                                context, LoginScreen.route, (route) => false,
                                arguments: {Constants.IS_FROM_ROUTE_KEY: true}))
                        : print('login'),
                    title: Text(userEvent is Data ? "" : AppText.LOGIN,
                        style: drawerTextStyle),
                  );
                }),
          ],
        ),
      ),
      Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                if (bloc.state.pageIndex == 7) return;
                await Future.delayed(const Duration(milliseconds: 300));
                itemClick.call(7);
              },
              child: Hero(
                tag: "profile_pic",
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BlocBuilder<MainScreenBloc, MainScreenState>(
                              builder: (_, state) {
                            final userEvent = state.userEvent;
                            if (!(userEvent is Data)) return const SizedBox();
                            final user = userEvent.data as User;
                            var username = "${user.firstName.isEmpty? "":user.firstName[0]}${user.lastName.isEmpty? "":user.lastName[0]}";
                            if (user.image != null)
                              return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Constants.COLOR_SECONDARY,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              user.image!),
                                          fit: BoxFit.cover)),
                                child: user.image == "https://dev.rent2park.com/"?Center(child: Text(username,style: TextStyle(
                                    fontSize: 18,
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD),)):SizedBox(),
                              );

                            return Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Constants.COLOR_SECONDARY,
                                  shape: BoxShape.circle),
                              child: Text(
                                  user.firstName.isNotEmpty &&
                                          user.lastName.isNotEmpty
                                      ? '${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}'
                                      : '',
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontSize: 18,
                                      fontFamily: Constants.GILROY_REGULAR)),
                            );
                          }),

                          const SizedBox(width: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BlocBuilder<MainScreenBloc,
                                            MainScreenState>(
                                        buildWhen: (previous, current) =>
                                            previous.userEvent !=
                                            current.userEvent,
                                        builder: (_, state) {
                                          final userEvent = state.userEvent;
                                          if (!(userEvent is Data))
                                            return const SizedBox();
                                          final user = userEvent.data as User;
                                          return Text(
                                              '${user.firstName} ${user.lastName}',
                                              style: const TextStyle(
                                                  color: Constants
                                                      .COLOR_ON_SURFACE,
                                                  fontFamily:
                                                      Constants.GILROY_REGULAR,
                                                  fontSize: 14));
                                        }),
                                    const Text(AppText.MY_ACCOUNT,
                                        style: TextStyle(
                                            color: Constants
                                                .COLOR_SECONDARY_VARIANT,
                                            fontFamily: Constants.GILROY_LIGHT,
                                            fontSize: 12))
                                  ]),
                              SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset("assets/exclamatory_mark.svg")
                            ],
                          )
                        ])),
              )))
    ]));
  }
}
