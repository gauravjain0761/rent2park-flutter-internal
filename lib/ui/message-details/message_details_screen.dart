import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';

import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/light_app_bar.dart';
import '../common/single_error_try_again_widget.dart';
import '../main/messages/message_navigation_screen_bloc.dart';
import 'message_details_screen_bloc.dart';
import 'message_details_screen_state.dart';

class MessageDetailsScreen extends StatefulWidget {
  static const route = 'message_details_screen_route';
  final String name;

  const MessageDetailsScreen({required this.name});

  @override
  _MessageDetailsScreenState createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = context.read<MessageDetailScreenBloc>();
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: CustomAppBar(),
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocListener<MessageDetailScreenBloc, MessageDetailScreenState>(
                    listener: (_, state) {
                      if (!state.isFromAllChat) return;
                      context
                          .read<MessageNavigationScreenBloc>()
                          .makeChatReadable(bloc.partnerId);
                    },
                    listenWhen: (previous, current) =>
                        previous.isFromAllChat != current.isFromAllChat,
                    child: Container(
                        color: Constants.COLOR_PRIMARY,
                        width: size.width,
                        height: kToolbarHeight,
                        child: Stack(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                                icon: const BackButtonIcon(),
                                onPressed: () => Navigator.pop(context),
                                splashRadius: 25,
                                color: Constants.COLOR_ON_PRIMARY),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(widget.name,
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 17)),
                              )),
                        ]))),
                Expanded(
                  child: BlocBuilder<MessageDetailScreenBloc,
                      MessageDetailScreenState>(builder: (_, state) {
                    final dataEvent = state.messageEvent;
                    if (dataEvent is Initial || dataEvent is Loading)
                      return Center(
                          child:
                              const CircularProgressIndicator(strokeWidth: 2));
                    else if (dataEvent is Error)
                      return SingleErrorTryAgainWidget(
                          onClick: () => bloc.allChats());
                    else if (dataEvent is Data) {
                      final mapEntry = dataEvent.data
                          as MapEntry<User, List<DetailedMessage>>;
                      final user = mapEntry.key;
                      final messages = mapEntry.value;
                      return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (_, index) {
                            final message = messages[index];
                            return message.id == user.id
                                ? SentMessage(message: message)
                                : ReceivedMessage(message: message);
                          },
                          itemCount: messages.length,
                          scrollDirection: Axis.vertical);
                    }
                    return const SizedBox();
                  }),
                ),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      style: const TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 14),
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Constants.COLOR_ON_PRIMARY,
                        hintText: AppText.TYPE_MESSAGE,
                        hintStyle: TextStyle(
                            fontFamily: Constants.GILROY_REGULAR,
                            color: Constants.colorDivider,
                            fontSize: 14),
                      ),
                    )),
                    GestureDetector(
                        onTap: () {
                          final String message = _messageController.text;
                          if (message.isEmpty) return;
                          bloc.sendMessage(message);
                          _messageController.text = '';
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            width: 60,
                            child: const Icon(Icons.send_rounded,
                                color: Constants.COLOR_ON_PRIMARY),
                            color: Constants.COLOR_PRIMARY)),
                  ],
                )
              ]),
        ));
  }
}

class ReceivedMessage extends StatelessWidget {
  final DetailedMessage message;

  const ReceivedMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              message.image != null
                  ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(message.image!),
                              fit: BoxFit.cover)))
                  : Image(
                      image: AssetImage('assets/man.png'),
                      width: 50,
                      height: 50),
              const SizedBox(height: 2),
              Text(message.dateTime,
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: Constants.GILROY_REGULAR,
                      color: Constants.colorDivider))
            ],
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ChatBubble(
              alignment: Alignment.centerLeft,
              backGroundColor: Constants.COLOR_SURFACE,
              elevation: 5,
              clipper: ChatBubbleClipper2(type: BubbleType.receiverBubble),
              child: Text(message.message,
                  style: const TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontFamily: Constants.GILROY_REGULAR,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class SentMessage extends StatelessWidget {
  final DetailedMessage message;

  const SentMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ChatBubble(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.only(
                  right: 25, left: 10, top: 10, bottom: 10),
              alignment: Alignment.centerRight,
              backGroundColor: Constants.COLOR_PRIMARY,
              elevation: 5,
              clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
              child: Text(message.message,
                  style: const TextStyle(
                      color: Constants.COLOR_ON_PRIMARY,
                      fontFamily: Constants.GILROY_REGULAR,
                      fontSize: 14)),
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                message.myImage != null
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    message.myImage!),
                                fit: BoxFit.cover)))
                    : Image(
                        image: AssetImage('assets/man.png'),
                        width: 50,
                        height: 50),
                Text(message.dateTime,
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.GILROY_REGULAR,
                        color: Constants.colorDivider))
              ])
        ],
      ),
    );
  }
}
