import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/backend_responses.dart';
import '../../data/material_dialog_content.dart';
import '../../data/meta_data.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../add-new-vehicle/add_update_vehicle_screen.dart';
import '../common/empty_list_item_widget.dart';
import '../common/single_error_try_again_widget.dart';
import 'manage_vehicle_bloc.dart';


class ManageVehicleScreen extends StatelessWidget {
  static const String route = 'manage_vehicle_screen_route';

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final bool isFromSelection;

  ManageVehicleScreen({required this.isFromSelection});

  void _deleteVehicle(ManageVehicleBloc bloc, var vehicleId, BuildContext context) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.DELETING_VEHICLE);
    final responseMessage = await bloc.deleteVehicle(vehicleId);
    _dialogHelper.dismissProgress();

    if (responseMessage == null) {
      _dialogHelper.showMaterialDialogWithContent(MaterialDialogContent.networkError(), () => _deleteVehicle(bloc, vehicleId, context));
      return;
    }

    if (responseMessage.isNotEmpty) {
      SnackbarHelper.instance
        ..injectContext(context)
        ..showSnackbar(snackbar: SnackbarMessage.error(message: responseMessage));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ManageVehicleBloc>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: const Text(
          AppText.MANAGE_VEHICLE,
          style: TextStyle(color: Constants.COLOR_ON_PRIMARY, fontFamily: Constants.GILROY_BOLD, fontSize: 17),
        ),
        centerTitle: false,
        leading: IconButton(
            icon: const BackButtonIcon(), onPressed: () => Navigator.pop(context), splashRadius: 25, color: Constants.COLOR_ON_PRIMARY),
      ),
      body: BlocBuilder<ManageVehicleBloc, DataEvent>(builder: (context, dataEvent) {
        if (dataEvent is Initial)
          return const SizedBox();
        else if (dataEvent is Loading)
          return Center(child: CircularProgressIndicator());
        else if (dataEvent is Empty)
          return EmptyListItemWidget(size: size, title: dataEvent.message);
          else if (dataEvent is Data) {
            final data = dataEvent.data as List<Vehicle>;
          return ListView.separated(
              itemBuilder: (context, index) {
                final vehicle = data[index];
                return _ManageVehicleSingleItemWidget(
                    manageVehicleModel: data[index],
                    callback: () {
                      if (isFromSelection) Navigator.pop(context, vehicle);
                    },
                    editCallback: () {
                      print("yes.. $vehicle");
                      Navigator.pushNamed(context, AddUpdateVehicleScreen.route, arguments: vehicle.copyWith());
                    },
                    deleteCallback: () => _deleteVehicle(bloc, vehicle.id, context));
              },
              separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Divider(thickness: 0.5, height: 0.5),
                  ),
              itemCount: data.length);
        } else
          return SingleErrorTryAgainWidget(onClick: () => bloc.requestVehicles());
      }),
      floatingActionButton: Container(
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AddUpdateVehicleScreen.route),
          child: const Text(
            AppText.ADD,
            style: TextStyle(color: Constants.COLOR_ON_SECONDARY, fontSize: 13, fontFamily: Constants.GILROY_REGULAR),
          ),
        ),
      ),
    );
  }
}

class _ManageVehicleSingleItemWidget extends StatelessWidget {
  final Vehicle manageVehicleModel;
  final VoidCallback callback;
  final VoidCallback editCallback;
  final VoidCallback deleteCallback;

  _ManageVehicleSingleItemWidget(
      {required this.manageVehicleModel, required this.callback, required this.editCallback, required this.deleteCallback});

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
                style: TextStyle(color: Constants.COLOR_ON_ERROR, fontFamily: Constants.GILROY_REGULAR, fontSize: 14)),
            color: Constants.COLOR_ERROR),
        SlideAction(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              editCallback.call();
            },
            child: Text(AppText.EDIT.toUpperCase(),
                style: TextStyle(color: Constants.COLOR_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 14)),
            color: Colors.green),
      ],
      key: ValueKey(manageVehicleModel.id),
      child: InkWell(
        onTap: callback,
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: manageVehicleModel.image == null
                    ? Image.asset('assets/car.png', width: 100)
                    : ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          imageUrl: manageVehicleModel.image!,
                          width: 100,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        ),
                      )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${manageVehicleModel.make} - ${manageVehicleModel.year.toString()}',
                        maxLines: 2,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(color: Constants.COLOR_SECONDARY, fontFamily: Constants.GILROY_BOLD)),
                    const SizedBox(height: 8),
                    Text('Type: ${manageVehicleModel.make} ${manageVehicleModel.vehicleType.toString()}',
                        style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_LIGHT)),
                    const SizedBox(height: 8),
                    Text('Model: ${manageVehicleModel.vehicleModel}',
                        style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_LIGHT)),
                    const SizedBox(height: 8),
                    Text(manageVehicleModel.color.toString(),
                        style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_LIGHT)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
