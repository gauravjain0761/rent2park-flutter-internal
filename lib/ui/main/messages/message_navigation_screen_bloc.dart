import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../backend/shared_web-services.dart';
import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../helper/network_helper.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../util/app_strings.dart';


class MessageNavigationScreenBloc extends Cubit<DataEvent> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final NetworkHelper _networkHelper = NetworkHelper.instance;

  MessageNavigationScreenBloc() : super(Initial()) {
    requestChats();
  }

  void requestChats() async {
    if (state is Data) return;
    emit(Loading());

    try {
      final user = await _sharedPrefHelper.user();
      if (user == null) return;

      final response = await _sharedWebService.messages(id: user.id);

      if (response.messages.isEmpty) {
        emit(Empty(message: AppText.NO_CHAT_FOUND));
        return;
      }

      emit(Data(data: response.messages));
    } catch (e) {
      emit(Error(exception: Exception(e.toString())));
    }
  }

  Future<String?> deleteChat(String partnerId) async {
    final isInternetConnected = await _networkHelper.isNetworkConnected();
    if (!isInternetConnected) return null;

    final user = await _sharedPrefHelper.user();
    if (user == null) return null;

    try {
      final response = await _sharedWebService.deleteChat(user.id, partnerId);
      if (!response.status) return response.message;
      final dataEvent = state;
      if (dataEvent is Data) {
        final allMessages = dataEvent.data as List<Message>;
        final deleteChatIndex =
            allMessages.indexWhere((element) => element.id == partnerId);
        if (deleteChatIndex != -1) {
          allMessages.removeAt(deleteChatIndex);
          if (allMessages.isEmpty)
            emit(Empty(message: AppText.NO_CHAT_FOUND));
          else
            emit(Data(data: allMessages));
        }
      }
      return '';
    } catch (_) {
      return null;
    }
  }

  Future<void> makeChatReadable(String partnerId) async {
    if (!(state is Data)) return;
    final messages = (state as Data).data as List<Message>;
    final messageIndex =
        messages.indexWhere((element) => element.id == partnerId);
    if (messageIndex == -1) return;
    final previousMessage = messages[messageIndex];
    final updatedMessage = previousMessage.copyWith(unreadCount: 0);
    messages.removeAt(messageIndex);
    messages.insert(messageIndex, updatedMessage);
    emit(Data(data: messages));
  }
}
