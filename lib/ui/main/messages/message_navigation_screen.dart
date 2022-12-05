import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../data/backend_responses.dart';
import '../../../data/material_dialog_content.dart';
import '../../../data/meta_data.dart';
import '../../../data/snackbar_message.dart';
import '../../../helper/material_dialog_helper.dart';
import '../../../helper/snackbar_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../common/empty_list_item_widget.dart';
import '../../common/single_error_try_again_widget.dart';
import '../../message-details/message_details_screen.dart';
import '../main_screen_bloc.dart';
import 'message_navigation_screen_bloc.dart';


class MessageNavigationScreen extends StatelessWidget {
  final PageStorageKey<String> key;

  const MessageNavigationScreen({required this.key}) : super(key: key);

  void _deleteChat(MaterialDialogHelper dialogHelper, BuildContext context,
      MessageNavigationScreenBloc bloc, String partnerId) async {
    dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.DELETING_CHAT);

    final message = await bloc.deleteChat(partnerId);
    dialogHelper.dismissProgress();
    final snackbar = SnackbarHelper.instance..injectContext(context);
    if (message == null || message.isNotEmpty) {
      snackbar.showSnackbar(
          snackbar: SnackbarMessage.error(
              message: message == null
                  ? AppText.LIMITED_NETWORK_CONNECTION
                  : message));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MessageNavigationScreenBloc>();
    final scaffoldState = Scaffold.of(context);
    final size = MediaQuery.of(context).size;
    final dialogHelper = MaterialDialogHelper.instance;
    return WillPopScope(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Constants.COLOR_PRIMARY,
              height: kToolbarHeight,
              child: Stack(alignment: Alignment.topLeft, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        scaffoldState.openDrawer();
                      },
                      icon: const Icon(Icons.menu_rounded),
                      color: Constants.COLOR_ON_PRIMARY),
                ),
                const Align(
                    alignment: Alignment.center,
                    child: Text(AppText.MESSAGES,
                        style: TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 17))),
              ]),
            ),
            Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(0),
                    child: BlocBuilder<MessageNavigationScreenBloc, DataEvent>(
                        builder: (_, dataEvent) {
                      if (dataEvent is Initial || dataEvent is Loading)
                        return Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: size.height / 2 - 50),
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ));
                      else if (dataEvent is Error)
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 170),
                          child: SingleErrorTryAgainWidget(
                              onClick: () => bloc.requestChats()),
                        ));
                      else if (dataEvent is Empty)
                        return Center(
                            child: EmptyListItemWidget(
                                size: size, title: dataEvent.message));
                      final messages =
                          (dataEvent as Data).data as List<Message>;
                      int count = 0;
                      messages.forEach((element) {
                        if (element.unread != 0) count += 1;
                      });
                      final mainBloc = context.read<MainScreenBloc>();
                      mainBloc.updateMessageCount(count);

                      return ListView.separated(
                        itemBuilder: (_, index) {
                          final message = messages[index];
                          return _MessageSingleItemWidget(
                              bloc: mainBloc,
                              message: message,
                              deleteChat: () => dialogHelper
                                ..injectContext(context)
                                ..showMaterialDialogWithContent(
                                    MaterialDialogContent(
                                        title: AppText.CONFIRM,
                                        message: AppText
                                            .DO_YOU_REALLY_WANT_TO_DELETE_THIS_MESSAGE,
                                        positiveText: AppText.OKAY,
                                        negativeText: AppText.CANCEL),
                                    () => _deleteChat(dialogHelper, context,
                                        bloc, message.id)));
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: messages.length,
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (_, __) => Divider(
                            color: Constants.colorDivider,
                            thickness: 1,
                            height: 1),
                      );
                    }))),
          ],
        ),
        onWillPop: () async {
          scaffoldState.isDrawerOpen
              ? Navigator.pop(context)
              : BlocProvider.of<MainScreenBloc>(context).updatePageIndex(0);
          return false;
        });
  }
}

class _MessageSingleItemWidget extends StatelessWidget {
  final Message message;
  final VoidCallback deleteChat;
  final MainScreenBloc bloc;

  const _MessageSingleItemWidget(
      {required this.message, required this.deleteChat, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, MessageDetailsScreen.route,
          arguments: {'id': message.id, 'name': message.name}),
      child: Container(
        color:
            message.unread > 0 ? Constants.COLOR_SECONDARY : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.image == null
                ? const Image(
                    image: AssetImage('assets/man.png'),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 55)
                : Container(
                    width: 50,
                    height: 55,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(message.image!),
                            fit: BoxFit.cover))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(message.name,
                      style: TextStyle(
                          color: message.unread > 0
                              ? Constants.COLOR_PRIMARY
                              : Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(message.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: message.unread > 0
                              ? Constants.COLOR_ON_SECONDARY
                              : Constants.COLOR_ON_SURFACE.withOpacity(0.7),
                          fontFamily: Constants.GILROY_LIGHT,
                          fontSize: 13)),
                ])),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(message.datetime,
                    style: TextStyle(
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 12,
                        color: message.unread > 0
                            ? Constants.COLOR_ON_SECONDARY
                            : Constants.COLOR_ON_SURFACE)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: deleteChat,
                  child: Icon(FontAwesomeIcons.trashAlt,
                      color: message.unread > 0
                          ? Constants.COLOR_ON_SECONDARY
                          : Constants.COLOR_SECONDARY,
                      size: 22),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
