import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/add_space/pages/space_address_page.dart';
import 'package:rent2park/ui/add_space/pages/space_detail_page.dart';
import 'package:rent2park/ui/add_space/pages/space_location_page.dart';
import 'package:rent2park/ui/add_space/pages/space_photo_page.dart';

import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/shared_pref_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/app_button.dart';
import '../common/bottom_curve_clipper.dart';
import '../common/light_app_bar.dart';
import '../main/home/home_navigation_screen_bloc.dart';
import '../main/manage-my-space/manage_my_space_screen_bloc.dart';
import '../space_success_screen.dart';
import 'add_space_screen_bloc.dart';
import 'add_space_screen_state.dart';

class AddSpaceScreen extends StatefulWidget {
  static const String route = 'add_space_screen_route';

  const AddSpaceScreen();

  @override
  _AddSpaceScreenState createState() => _AddSpaceScreenState();
}

class _AddSpaceScreenState extends State<AddSpaceScreen> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  static const _spaceAddressNavigationKey =
      PageStorageKey('space_address_navigation_key');
  static const _spaceLocationNavigationKey =
      PageStorageKey('space_location_navigation_key');
  static const _spacePhotoNavigationKey =
      PageStorageKey('space_photo_navigation_key');
  static const _spaceDetailNavigationKey =
      PageStorageKey('space_detail_navigation_key');

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;
  final Map<PageStorageKey<String>, Widget> _pageMap = {};

  void _addSpace() async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_SPACE);
    final bloc = context.read<AddSpaceScreenBloc>();
    _snackbarHelper.injectContext(context);

    // final bankAccount = await bloc.getBankAccount();
    // if (bankAccount == null) {
    // _dialogHelper.dismissProgress();
    // _snackbarHelper.showSnackbar(snackbar: SnackbarMessage.error(message: AppText.YOU_NEED_TO_FIRST_ATTACH_YOUR_BANK_ACCOUNT));
    // return;
    // }
    // if (!bankAccount.isPayoutEnable) {
    // _dialogHelper.dismissProgress();
    // _snackbarHelper.showSnackbar(
    // snackbar: SnackbarMessage.error(message: AppText.PLEASE_UPLOAD_REMAING_DOCUMENT_FIRST_FOR_BANK_ACCOUNT, isLongDuration: true));
    // return;
    // }

    final response = await bloc.addParkingSpace();
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _addSpace());
      return;
    }
    if (response.isNotEmpty) {
      _snackbarHelper.injectContext(context);
      _snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response));
      return;
    }
    BlocProvider.of<ManageMySpaceScreenBloc>(context)
        .requestHostSpaces(isNeedHotReload: true);
    int count = 0;
    Navigator.pushNamedAndRemoveUntil(
        context, SpaceAddedSuccessfullyScreen.route, (route) => count++ == 2,
        arguments: true);
  }

  void _updateSpace() async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.UPDATING_SPACE);
    final bloc = context.read<AddSpaceScreenBloc>();
    final response = await bloc.updateParkingSpace();
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _updateSpace());
      return;
    }
    _snackbarHelper.injectContext(context);
    if (response.isNotEmpty) {
      _snackbarHelper.injectContext(context);
      _snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response));
      return;
    }
    BlocProvider.of<ManageMySpaceScreenBloc>(context)
        .requestHostSpaces(isNeedHotReload: true);
    int count = 0;
    Navigator.pushNamedAndRemoveUntil(
        context, SpaceAddedSuccessfullyScreen.route, (route) => count++ == 2,
        arguments: false);
  }

  @override
  void initState() {
    _pageMap[_spaceAddressNavigationKey] =
        SpaceAddressPage(key: _spaceAddressNavigationKey);
    _pageMap[_spaceLocationNavigationKey] = const SizedBox();
    _pageMap[_spacePhotoNavigationKey] = const SizedBox();
    _pageMap[_spaceDetailNavigationKey] = const SizedBox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeNavigationScreenBloc>();
    final size = MediaQuery.of(context).size;
    final bloc = context.read<AddSpaceScreenBloc>();
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
          bottom: false,
          child: WillPopScope(
            onWillPop: () async {
              final pageIndex = bloc.state.pageIndex;
              if (pageIndex == 0) return true;
              bloc.updatePageIndex(pageIndex - 1);
              return false;
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  ClipPath(
                      clipper: const BottomCurveClipper(),
                      child: Container(
                        width: size.width,
                        height: kToolbarHeight * 2 + 30,
                        color: Constants.COLOR_PRIMARY,
                      )),
                  IconButton(
                      icon: const BackButtonIcon(),
                      onPressed: () {
                        final pageIndex = bloc.state.pageIndex;
                        if (pageIndex == 0)
                          Navigator.pop(context);
                        else
                          bloc.updatePageIndex(pageIndex - 1);
                      },
                      splashRadius: 25,
                      color: Constants.COLOR_ON_PRIMARY),
                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                        buildWhen: (previous, current) =>
                            previous.title != current.title,
                        builder: (_, state) => Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(state.title,
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 17)),
                            )),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: kToolbarHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<AddSpaceScreenBloc,
                                          AddSpaceScreenState>(
                                      buildWhen: (previous, current) =>
                                          previous.pageIndex !=
                                          current.pageIndex,
                                      builder: (_, state) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _TickSelectionWidget(
                                                  isSelected: const [
                                                1,
                                                2,
                                                3
                                              ].contains(state.pageIndex)),
                                              const SizedBox(height: 5),
                                              Text(
                                                  AppText
                                                      .ADDRESS_FIFTEEN_SECONDS,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Constants
                                                          .GILROY_LIGHT,
                                                      color: state.pageIndex ==
                                                              0
                                                          ? Constants
                                                              .COLOR_ON_PRIMARY
                                                          : Constants
                                                              .COLOR_ON_PRIMARY
                                                              .withOpacity(
                                                                  0.5)))
                                            ],
                                          )),
                                  Expanded(
                                      child: Divider(
                                          thickness: 1,
                                          color: Constants.COLOR_SURFACE,
                                          height: 25)),
                                  BlocBuilder<AddSpaceScreenBloc,
                                          AddSpaceScreenState>(
                                      buildWhen: (previous, current) =>
                                          previous.pageIndex !=
                                          current.pageIndex,
                                      builder: (_, state) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _TickSelectionWidget(
                                                  isSelected: const [
                                                2,
                                                3
                                              ].contains(state.pageIndex)),
                                              const SizedBox(height: 5),
                                              Text(
                                                  AppText
                                                      .LOCATION_FIFTEEN_SECONDS,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Constants
                                                          .GILROY_LIGHT,
                                                      color: state.pageIndex ==
                                                              1
                                                          ? Constants
                                                              .COLOR_ON_PRIMARY
                                                          : Constants
                                                              .COLOR_ON_PRIMARY
                                                              .withOpacity(
                                                                  0.5)))
                                            ],
                                          )),
                                  Expanded(
                                      child: Divider(
                                          thickness: 1,
                                          color: Constants.COLOR_SURFACE,
                                          height: 25)),
                                  BlocBuilder<AddSpaceScreenBloc,
                                          AddSpaceScreenState>(
                                      buildWhen: (previous, current) =>
                                          previous.pageIndex !=
                                          current.pageIndex,
                                      builder: (_, state) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _TickSelectionWidget(
                                                  isSelected:
                                                      state.pageIndex == 3),
                                              const SizedBox(height: 5),
                                              Text(AppText.PHOTOS_ONE_MINUTE,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Constants
                                                          .GILROY_LIGHT,
                                                      color: state.pageIndex ==
                                                              2
                                                          ? Constants
                                                              .COLOR_ON_PRIMARY
                                                          : Constants
                                                              .COLOR_ON_PRIMARY
                                                              .withOpacity(
                                                                  0.5)))
                                            ],
                                          )),
                                  Expanded(
                                      child: Divider(
                                          thickness: 1,
                                          color: Constants.COLOR_SURFACE,
                                          height: 25)),
                                  BlocBuilder<AddSpaceScreenBloc,
                                          AddSpaceScreenState>(
                                      buildWhen: (previous, current) =>
                                          previous.pageIndex !=
                                          current.pageIndex,
                                      builder: (_, state) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _TickSelectionWidget(
                                                  isSelected:
                                                      state.pageIndex == 4),
                                              const SizedBox(height: 5),
                                              Text(AppText.DETAILS_TWO_MINUTES,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Constants
                                                          .GILROY_LIGHT,
                                                      color: state.pageIndex ==
                                                              3
                                                          ? Constants
                                                              .COLOR_ON_PRIMARY
                                                          : Constants
                                                              .COLOR_ON_PRIMARY
                                                              .withOpacity(
                                                                  0.5)))
                                            ],
                                          )),
                                ],
                              ),
                            ],
                          )))
                ]),
                BlocListener<AddSpaceScreenBloc, AddSpaceScreenState>(
                  listener: (_, __) {
                    print('Calllleeddd...');
                    _pageMap[_spaceLocationNavigationKey] = const SizedBox();
                  },
                  listenWhen: (previous, current) =>
                      previous.address.lat != current.address.lat,
                  child: Expanded(
                      child:
                          BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                    buildWhen: (previous, current) =>
                        previous.pageIndex != current.pageIndex,
                    builder: (_, state) => IndexedStack(
                        index: state.pageIndex,
                        children: _pageMap.values.toList()),
                  )),
                ),
                SizedBox(
                    height: Platform.isAndroid ? 45 : 60,
                    child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                      buildWhen: (previous, current) =>
                          previous.pageIndex != current.pageIndex,
                      builder: (_, state) => AppButton(
                          fillColor: Constants.COLOR_PRIMARY,
                          text: state.pageIndex == 3
                              ? AppText.SUBMIT
                              : AppText.CONTINUE,
                          onClick: () {
                            if (state.pageIndex == 3) {
                              _sharedPrefHelper.updateParkingSpaceEdited(true);
                              _sharedPrefHelper.updateParkingSpaceEditedHost(true);
                              _sharedPrefHelper.updateParkingSpaceEditedDriver(true);

                              FocusScope.of(context).unfocus();
                              final result = bloc.validateDetailPageData();
                              if (result) {
                                if (bloc.parkingSpaceDetail == null)
                                  _addSpace();
                                else
                                  _updateSpace();
                              }
                              return;
                            }
                            final currentPageIndex = bloc.state.pageIndex;
                            final newPageIndex = currentPageIndex + 1;
                            final pageStorageKey =
                                _pageMap.keys.elementAt(newPageIndex);
                            final pageItem = _pageMap[pageStorageKey];
                            if (pageItem == null || pageItem is SizedBox) {
                              final newPageWidget = _pageWidget(newPageIndex);
                              _pageMap[pageStorageKey] = newPageWidget;
                            }
                            bloc.updatePageIndex(newPageIndex);
                          },
                          cornerRadius: Platform.isAndroid ? 8 : 0),
                    )),
              ],
            ),
          )),
    );
  }

  Widget _pageWidget(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return const SpaceAddressPage(key: _spaceAddressNavigationKey);
      case 1:
        return const SpaceLocationPage(key: _spaceLocationNavigationKey);
      case 2:
        return const SpacePhotoPage(key: _spacePhotoNavigationKey);
      case 3:
        return const SpaceDetailPage(key: _spaceDetailNavigationKey);
      default:
        return const SizedBox();
    }
  }
}

class _TickSelectionWidget extends StatelessWidget {
  final bool isSelected;

  const _TickSelectionWidget({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
          color: isSelected
              ? Constants.COLOR_SECONDARY
              : Constants.COLOR_ON_PRIMARY,
          shape: BoxShape.circle),
      padding: const EdgeInsets.all(5),
      child: Icon(Icons.done,
          size: 16,
          color:
              isSelected ? Constants.COLOR_SURFACE : Constants.COLOR_PRIMARY),
    );
  }
}
