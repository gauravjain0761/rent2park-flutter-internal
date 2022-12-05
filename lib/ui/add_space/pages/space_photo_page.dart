import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/snackbar_message.dart';
import '../../../helper/snackbar_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../add_space_screen_bloc.dart';
import '../add_space_screen_state.dart';


class SpacePhotoPage extends StatelessWidget {
  final PageStorageKey<String> key;

  const SpacePhotoPage({required this.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imagePicker = ImagePicker();
    final snackbarHelper = SnackbarHelper.instance;
    final bloc = context.read<AddSpaceScreenBloc>();
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height - (kToolbarHeight * 2 + 110),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(AppText.SET_YOUR_SPACE_PHOTOS,
                      style: TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 19)),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(AppText.PLEASE_SELECT_YOUR_SPACE_IMAGES,
                      style: TextStyle(
                          color: Constants.colorDivider,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 16)),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                      buildWhen: (previous, current) =>
                          previous.images != current.images,
                      builder: (_, state) => GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.images.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.80,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15),
                          itemBuilder: (_, index) => _PhotoSingleItemWidget(
                              imageEntity: state.images[index],
                              onDelete: bloc.removeFile))),
                )
              ],
            ),
            Positioned(
                left: 40,
                right: 40,
                top: 170,
                child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                  buildWhen: (previous, current) =>
                      previous.imageError != current.imageError,
                  builder: (_, state) => state.imageError.isNotEmpty
                      ? Text(state.imageError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Constants.COLOR_ERROR,
                              fontSize: 18,
                              fontFamily: Constants.GILROY_BOLD))
                      : const SizedBox(),
                )),
            Positioned(
                bottom: Platform.isAndroid ? 10 : 45,
                right: 20,
                child: FloatingActionButton(
                    onPressed: () async {
                      final image = await imagePicker.getImage(
                          source: ImageSource.gallery, imageQuality: 100);
                      if (image == null) {
                        snackbarHelper.injectContext(context);
                        snackbarHelper.showSnackbar(
                            snackbar: SnackbarMessage.error(
                                message: AppText.PLEASE_SELECT_ANOTHER_IMAGE));
                        return;
                      }
                      bloc.addFile(image);
                    },
                    backgroundColor: Constants.COLOR_SECONDARY,
                    child: const Icon(Icons.add_rounded,
                        color: Constants.COLOR_ON_SECONDARY, size: 24)))
          ],
        ),
      ),
    );
  }
}

class _PhotoSingleItemWidget extends StatelessWidget {
  final dynamic imageEntity;
  final Function(dynamic) onDelete;

  _PhotoSingleItemWidget({required this.imageEntity, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageEntity is PickedFile
              ? Image.file(File(imageEntity.path), fit: BoxFit.cover)
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imageEntity as String,
                  placeholder: (_, __) => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
          Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => onDelete.call(imageEntity),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.cancel,
                      color: Constants.COLOR_ON_SURFACE, size: 22),
                ),
              ))
        ],
      ),
    );
  }
}
