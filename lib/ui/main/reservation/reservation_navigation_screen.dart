import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rent2park/ui/favourites/FavouritesSpaces.dart';
import 'package:rent2park/ui/main/reservation/reservation_navigation_screen_bloc.dart';
import 'package:rent2park/ui/main/reservation/reservation_navigation_screen_state.dart';
import 'package:rent2park/ui/main/reservation/tabs/past_tab_item.dart';
import 'package:rent2park/ui/main/reservation/tabs/progress_tab_item.dart';
import 'package:rent2park/ui/main/reservation/tabs/upcoming_tab_item.dart';

import '../../../data/user_type.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../main_screen_bloc.dart';
import '../main_screen_state.dart';

class ReservationNavigationScreen extends StatefulWidget {
  final PageStorageKey<String> key;

  const ReservationNavigationScreen({required this.key}) : super(key: key);

  @override
  _ReservationNavigationScreenState createState() =>
      _ReservationNavigationScreenState();
}

class _ReservationNavigationScreenState
    extends State<ReservationNavigationScreen>
    with SingleTickerProviderStateMixin {
  static const _progressTabNavigationKey =
      PageStorageKey('reservation_navigation_progress_tab');
  static const _upcomingTabNavigationKey =
      PageStorageKey('reservation_navigation_upcoming_tab');
  static const _pastTabNavigationKey =
      PageStorageKey('reservation_navigation_past_tab');

  final tabs = <Tab>[
    Tab(text: AppText.IN_PROGRESS),
    Tab(text: AppText.UPCOMING),
    Tab(text: AppText.PAST)
  ];
  final _tabMap = <PageStorageKey<String>, Widget>{};
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    _tabMap[_progressTabNavigationKey] =
        ProgressTabItemWidget(key: _progressTabNavigationKey);
    _tabMap[_upcomingTabNavigationKey] = const SizedBox();
    _tabMap[_pastTabNavigationKey] = const SizedBox();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    final bloc = context.read<ReservationNavigationScreenBloc>();
    return WillPopScope(
      onWillPop: () async {
        scaffoldState.isDrawerOpen
            ? Navigator.pop(context)
            : BlocProvider.of<MainScreenBloc>(context).updatePageIndex(0);
        return false;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                color: Constants.COLOR_PRIMARY,
                height: kToolbarHeight,
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          scaffoldState.openDrawer();
                        },
                        icon: const Icon(Icons.menu_rounded),
                        color: Constants.COLOR_ON_PRIMARY),
                    Align(
                        alignment: Alignment.center,
                        child: BlocBuilder<MainScreenBloc, MainScreenState>(
                          buildWhen: (previous, current) =>
                              previous.userType != current.userType,
                          builder: (_, state) => Text(
                              state.userType == UserType.driver
                                  ? AppText.MY_RESERVATIONS
                                  : AppText.MY_BOOKINGS,
                              style: const TextStyle(
                                  color: Constants.COLOR_ON_PRIMARY,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 18)),
                        )),
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: BlocBuilder<MainScreenBloc, MainScreenState>(
                            buildWhen: (previous, current) =>
                                previous.userType != current.userType,
                            builder: (_, state) => Visibility(
                                visible:state.userType == UserType.driver,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>FavouriteSpaces()));
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/search_heart_icon_.svg",
                                    height: 16,
                                  ),
                                  color: Constants.COLOR_ON_PRIMARY),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                height: kToolbarHeight,
                color: Constants.COLOR_SECONDARY,
                child: TabBar(
                    onTap: (int index) {
                      if (index == bloc.state.tabIndex) return;
                      final pageStorageKey = _tabMap.keys.elementAt(index);
                      final tabItem = _tabMap[pageStorageKey];
                      if (tabItem == null || tabItem is SizedBox) {
                        final newDrawerWidget = _getTabItemWidget(index);
                        _tabMap[pageStorageKey] = newDrawerWidget;
                      }
                      bloc.updateTabIndex(index);
                    },
                    controller: _tabController,
                    tabs: tabs,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Constants.COLOR_PRIMARY,
                    labelStyle: TextStyle(
                        color: Constants.COLOR_ON_PRIMARY,
                        fontSize: 16,
                        fontFamily: Constants.GILROY_MEDIUM),
                    unselectedLabelStyle: TextStyle(
                        color: Constants.COLOR_ON_PRIMARY,
                        fontSize: 16,
                        fontFamily: Constants.GILROY_MEDIUM)),
              )
            ],
          ),
          Expanded(
            child: BlocBuilder<ReservationNavigationScreenBloc,
                    ReservationNavigationScreenState>(
                buildWhen: (previous, current) =>
                    previous.tabIndex != current.tabIndex,
                builder: (_, state) => IndexedStack(
                    index: state.tabIndex, children: _tabMap.values.toList())),
          )
        ],
      ),
    );
  }

  Widget _getTabItemWidget(int index) {
    switch (index) {
      case 0:
        return const ProgressTabItemWidget(key: _progressTabNavigationKey);
      case 1:
        return const UpcomingTabItemWidget(key: _upcomingTabNavigationKey);
      case 2:
        return const PastTabItemWidget(key: _pastTabNavigationKey);
      default:
        return const SizedBox();
    }
  }
}
