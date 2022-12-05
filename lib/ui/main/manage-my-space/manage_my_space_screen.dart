import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rent2park/ui/main/home/home_navigation_screen_bloc.dart';

import '../../../data/backend_responses.dart';
import '../../../data/material_dialog_content.dart';
import '../../../data/meta_data.dart';
import '../../../data/snackbar_message.dart';
import '../../../helper/material_dialog_helper.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../helper/snackbar_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../add_space/add_space_screen.dart';
import '../../common/empty_list_item_widget.dart';
import '../../common/single_error_try_again_widget.dart';
import '../main_screen_bloc.dart';
import 'manage_my_space_screen_bloc.dart';
import 'manage_my_space_screen_state.dart';


class ManageMySpaceScreen extends StatefulWidget {
  final PageStorageKey key;

  const ManageMySpaceScreen({required this.key});

  @override
  _ManageMySpaceScreenState createState() => _ManageMySpaceScreenState();
}

class _ManageMySpaceScreenState extends State<ManageMySpaceScreen> {
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  void _deleteSpace(ManageMySpaceScreenBloc bloc, String spaceId) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog('Deleting space....');
    final responseMessage = await bloc.deleteSpace(spaceId);
    _dialogHelper.dismissProgress();
    if (responseMessage == null) {
      _dialogHelper.showMaterialDialogWithContent(MaterialDialogContent.networkError(), () => _deleteSpace(bloc, spaceId));
      return;
    }
    if (responseMessage.isNotEmpty) {
      SnackbarHelper.instance
        ..injectContext(context)
        ..showSnackbar(snackbar: SnackbarMessage.error(message: responseMessage));
      return;
    }
  }

  void _activateDeactivateSpace(ManageMySpaceScreenBloc bloc, String spaceId, bool isActivate) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(isActivate ? AppText.ACTIVATING_SPACE : AppText.DEACTIVATING_SPACE);
    final responseMessage = await bloc.activateDeactivateSpace(spaceId, isActivate);
    _dialogHelper.dismissProgress();
    if (responseMessage == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _activateDeactivateSpace(bloc, spaceId, isActivate));
      return;
    }
    final snackbarHelper = SnackbarHelper.instance..injectContext(context);
    if (responseMessage.isNotEmpty) {
      snackbarHelper.showSnackbar(snackbar: SnackbarMessage.error(message: responseMessage));
      return;
    }
    final String message = isActivate ? AppText.SPACE_ACTIVATED_SUCCESSFULLY : AppText.SPACE_DEACTIVATED_SUCCESSFULLY;
    snackbarHelper.showSnackbar(snackbar: SnackbarMessage.success(message: message));
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    final bloc = context.read<ManageMySpaceScreenBloc>();
    bloc.requestHostSpaces();
    final size = MediaQuery
        .of(context)
        .size;
    final focusNode = FocusNode();
    return WillPopScope(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Constants.COLOR_PRIMARY,
                  height: kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: IconButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(focusNode);
                              scaffoldState.openDrawer();
                            },
                            icon: const Icon(Icons.menu_rounded),
                            color: Constants.COLOR_ON_PRIMARY),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(AppText.MANAGE_MY_SPACE,
                              style: const TextStyle(
                                  color: Constants.COLOR_ON_PRIMARY, fontFamily: Constants.GILROY_BOLD, fontSize: 17))),
                    ],
                  ),
                ),
                const _SearchBar(),
                Expanded(child: BlocBuilder<ManageMySpaceScreenBloc, ManageMySpaceScreenState>(builder: (_, state) {
                  final dataEvent = state.spaceDataEvent;
                  if (dataEvent is Initial)
                    return const SizedBox();
                  else if (dataEvent is Loading)
                    return Center(child: CircularProgressIndicator());
                  else if (dataEvent is Empty)
                    return EmptyListItemWidget(size: size, title: dataEvent.message);
                  else if (dataEvent is Error) return SingleErrorTryAgainWidget(onClick: () => bloc.requestHostSpaces());
                  final data = (dataEvent as Data).data as List<ParkingSpaceDetail>;
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        final space = data[index];
                        return _SingleManageMySpaceWidget(
                            spaceDetail: space,
                            deleteCallback: () {
                              _sharedPrefHelper.updateParkingSpaceEdited(true);
                              _sharedPrefHelper.updateParkingSpaceEditedHost(true);
                              _sharedPrefHelper.updateParkingSpaceEditedDriver(true);
                              FocusScope.of(context).requestFocus(focusNode);
                              _deleteSpace(bloc, space.id);
                            },
                            editCallback: () {
                              _sharedPrefHelper.updateParkingSpaceEdited(true);
                              _sharedPrefHelper.updateParkingSpaceEditedHost(true);
                              _sharedPrefHelper.updateParkingSpaceEditedDriver(true);
                              FocusScope.of(context).requestFocus(focusNode);
                              Navigator.pushNamed(context, AddSpaceScreen.route, arguments: space.copyWith());
                            },
                            activateDeactivateCallback: () {
                              FocusScope.of(context).requestFocus(focusNode);
                              _activateDeactivateSpace(bloc, space.id, !space.isActive);
                            });
                      },
                      separatorBuilder: (__, _) =>
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Divider(thickness: 0.5, height: 0.5),
                          ),
                      shrinkWrap: true,
                      itemCount: data.length);
                }))
              ],
            ),
            Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pushNamed(context, AddSpaceScreen.route),
                    child: const Icon(Icons.add),
                  ),
                ))
          ],
        ),
        onWillPop: () async {
          scaffoldState.isDrawerOpen ? Navigator.pop(context) : BlocProvider.of<MainScreenBloc>(context).updatePageIndex(0);
          return false;
        });
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ManageMySpaceScreenBloc>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          Expanded(
            child: TextField(
              onChanged: bloc.search,
              decoration: InputDecoration(
                  hintText: 'Filter by location...',
                  hintStyle: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR),
                  border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }
}

class _SingleManageMySpaceWidget extends StatelessWidget {
  final ParkingSpaceDetail spaceDetail;
  final VoidCallback deleteCallback;
  final VoidCallback editCallback;
  final VoidCallback activateDeactivateCallback;

  _SingleManageMySpaceWidget({required this.spaceDetail,
    required this.deleteCallback,
    required this.editCallback,
    required this.activateDeactivateCallback});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: [

        SlideAction(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              deleteCallback.call();
            },

            child: Text(AppText.DELETE.toUpperCase(),
                style: const TextStyle(color: Constants.COLOR_ON_ERROR, fontFamily: Constants.GILROY_REGULAR, fontSize: 14)),
            color: Constants.COLOR_ERROR),

        SlideAction(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              editCallback.call();
            },
            child: Text(AppText.EDIT.toUpperCase(), style: const TextStyle(color: Constants.COLOR_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 14)),
            color: Colors.green),

        SlideAction(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              activateDeactivateCallback.call();
            },

            color: Constants.COLOR_PRIMARY,
            child: Text(spaceDetail.isActive ? AppText.DEACTIVATE : AppText.ACTIVATE,
                style: const TextStyle(color: Constants.COLOR_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 14)))
      ],

      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              child: CachedNetworkImage(
                  width: 100,
                  height: 90,
                  fit: BoxFit.fitWidth,
                  imageUrl: spaceDetail.parkingSpacePhotos.isEmpty ? '' : spaceDetail.parkingSpacePhotos[0],
                  placeholder: (_, __) =>
                  const SizedBox(
                      height: 250,
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spaceDetail.address,
                    style: const TextStyle(color: Constants.COLOR_SECONDARY, fontFamily: Constants.GILROY_BOLD, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text('Total Space: ${spaceDetail.numberOfSpaces}',
                      style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR)),
                  const SizedBox(height: 5),
                  Text('Vehicle Type: ${spaceDetail.vehicleSize}',
                      style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR)),
                ],
              ))
        ],
      ),
    );
  }
}
