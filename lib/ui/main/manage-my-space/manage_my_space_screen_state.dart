import 'package:equatable/equatable.dart';

import '../../../data/meta_data.dart';


class ManageMySpaceScreenState extends Equatable {
  final DataEvent spaceDataEvent;

  ManageMySpaceScreenState({required this.spaceDataEvent});

  ManageMySpaceScreenState.initial() : this(spaceDataEvent: Initial());

  ManageMySpaceScreenState copyWith({DataEvent? spaceDataEvent}) =>
      ManageMySpaceScreenState(
          spaceDataEvent: spaceDataEvent ?? this.spaceDataEvent);

  @override
  List<Object> get props => [spaceDataEvent];
}
