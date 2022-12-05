import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/extension/primitive_extension.dart';

import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../helper/network_helper.dart';
import '../../helper/shared_pref_helper.dart';
import 'message_details_screen_state.dart';



class MessageDetailScreenBloc extends Cubit<MessageDetailScreenState> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPreferenceHelper = SharedPreferenceHelper.instance;
  final NetworkHelper _networkHelper = NetworkHelper.instance;

  final String partnerId;

  bool isSendMessageAPIOnGoing = false;
  User? user;
  Timer? timer;

  MessageDetailScreenBloc({required this.partnerId})
      : super(MessageDetailScreenState.initial()) {
    allChats();
    try {
      timer = Timer.periodic(Duration(seconds: 10), (_) async {
        /// if the send message request on-going the we simply wait for the completion the API
        if (isSendMessageAPIOnGoing) return;

        /// initially check if the internet is not available then simply returns.
        final bool isInternetConnected =
            await _networkHelper.isNetworkConnected();
        if (!isInternetConnected) return;

        /// check if the last event state is initial or error then returns. because at this stage the error is showing on screen or
        /// the initial request is not begin hit.
        final currentDataEvent = state.messageEvent;
        if (currentDataEvent is Error || currentDataEvent is Initial) return;

        /// populate the currentMessageList with last data emitted.
        List<DetailedMessage> currentMessageList = [];
        if (currentDataEvent is Data) {
          final mapEntry =
              currentDataEvent.data as MapEntry<User, List<DetailedMessage>>;
          currentMessageList = mapEntry.value;
        }

        final user = this.user ?? await _sharedPreferenceHelper.user();
        if (user == null) return;
        try {
          /// request the updated message list from the server.
          final response = await _sharedWebService.detailedMessages(
              id: user.id, partnerId: partnerId, myImage: user.image);
          final newMessages = response.messages;

          /// now if the remote message list and previous messages are equal then we simply do not push data to screen and
          /// wait for the updated data.
          if (newMessages.length == currentMessageList.length) return;

          emit(state.copyWith(
              messageEvent: Data(data: MapEntry(user, newMessages))));
        } catch (_) {}
      });
    } catch (e, s) {
      print(s);
    }
  }

  void allChats() async {
    final user = this.user ?? await _sharedPreferenceHelper.user();
    if (user == null) return;
    this.user = user;
    emit(state.copyWith(messageEvent: Loading()));
    try {
      final response = await _sharedWebService.detailedMessages(
          id: user.id, partnerId: partnerId, myImage: user.image);
      if (response.messages.isEmpty)
        emit(state.copyWith(messageEvent: Empty(message: '')));
      else {
        final messages = response.messages;
        emit(state.copyWith(
            messageEvent: Data(data: MapEntry(user, messages)),
            isFromAllChat: true));
      }
    } catch (e) {
      emit(state.copyWith(
          messageEvent: Error(exception: Exception(e.toString()))));
    }
  }

  void sendMessage(String message) async {
    final bool isInternetConnected = await _networkHelper.isNetworkConnected();
    if (!isInternetConnected) return;
    final user = this.user ?? await _sharedPreferenceHelper.user();
    if (user == null) return;
    isSendMessageAPIOnGoing = true;
    final previousDataEvent = state.messageEvent;
    final messageDetail = DetailedMessage.initial(
        message, user.image, user.id, _getMessageTime());
    if (previousDataEvent is Empty)
      emit(state.copyWith(
          messageEvent:
              Data(data: MapEntry(user, <DetailedMessage>[messageDetail]))));
    else if (previousDataEvent is Data) {
      final mapEntry =
          previousDataEvent.data as MapEntry<User, List<DetailedMessage>>;
      final messages = mapEntry.value..insert(0, messageDetail);
      emit(state.copyWith(messageEvent: Data(data: MapEntry(user, messages))));
    }
    try {
      await _sharedWebService.sendMessages(
          senderId: user.id, receiverId: partnerId, message: message);
    } catch (_) {}
    isSendMessageAPIOnGoing = false;
  }

  String _getMessageTime() {
    final datetime = DateTime.now();
    return '${datetime.hour}:${datetime.minute} ${datetime.day}-${datetime.month.monthName}';
  }

  @override
  Future<void> close() {
    user = null;
    timer?.cancel();
    return super.close();
  }
}
