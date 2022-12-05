import 'package:equatable/equatable.dart';

import '../../data/meta_data.dart';


class MessageDetailScreenState extends Equatable {
  final DataEvent messageEvent;
  final bool isFromAllChat;

  const MessageDetailScreenState(
      {required this.messageEvent, required this.isFromAllChat});

  MessageDetailScreenState.initial()
      : this(messageEvent: Initial(), isFromAllChat: false);

  MessageDetailScreenState copyWith(
          {DataEvent? messageEvent, bool? isFromAllChat}) =>
      MessageDetailScreenState(
          messageEvent: messageEvent ?? this.messageEvent,
          isFromAllChat: isFromAllChat ?? this.isFromAllChat);

  @override
  List<Object> get props => [messageEvent, isFromAllChat];

  @override
  bool get stringify => true;
}
