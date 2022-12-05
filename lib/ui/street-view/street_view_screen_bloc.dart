import 'package:flutter_bloc/flutter_bloc.dart';

class StreetViewScreenBloc extends Cubit<bool> {
  StreetViewScreenBloc() : super(true);

  void hideProgress() => emit(false);
}
