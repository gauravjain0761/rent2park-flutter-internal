import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/data/backend_responses.dart';
import 'package:rent2park/data/exception.dart';
import 'package:rent2park/ui/wallet/wallet_state.dart';
import 'package:rent2park/util/Resource.dart';
import '../../backend/stripe_web_service.dart';
import '../../helper/shared_pref_helper.dart';

class WalletBloc extends Cubit<WalletState> {
  final StripeWebService _stripeWebService = StripeWebService.instance();
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  WalletBloc() : super(WalletState()){
    getBankAccount();
    myCards();
  }


  Future<void> myCards() async {
    emit(state.copyWith(status: Resource.initial));
    final user = await _sharedPrefHelper.user();

    if (user == null) {

      emit(state.copyWith(status: Resource.error));
      return;
    }
    var customerId = user.customerId.toString();
    if (customerId.isEmpty || customerId.length < 2) {
      emit(state.copyWith(status: Resource.success));
      emit(state.copyWith(myCards: []));
      return;
    }

    try {
      final paymentCards = await _stripeWebService.retrieveCards(customerId);
      emit(state.copyWith(status: Resource.success));
      emit(state.copyWith(myCards: paymentCards));
    } catch (_) {
      emit(state.copyWith(status: Resource.error));
    }
  }

  Future<void> getBankAccount() async {
    emit(state.copyWith(bankAccountStatus: Resource.initial));
    final user = await _sharedPrefHelper.user();
    if (user == null) {
      emit(state.copyWith(bankAccountStatus: Resource.error));
      return;
    }
    final customerId = user.customerId;
    try {
      final bankAccount = await _stripeWebService.getBankAccount(customerId!);
      emit(state.copyWith(bankAccountStatus: Resource.success));
      emit(state.copyWith(bankAccount: bankAccount));
    }on NoBankAccountException{
      emit(state.copyWith(bankAccountStatus: Resource.noBankAccounts));
    } catch (_) {
      emit(state.copyWith(bankAccountStatus: Resource.error));
    }
  }

  void updateCardSelection(List<PaymentCard>? cardsData){
    emit(state.copyWith(myCards: cardsData));
  }
}
