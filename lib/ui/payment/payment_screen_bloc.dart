import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:rent2park/ui/payment/payment_screen_dart.dart';

import '../../backend/shared_web-services.dart';
import '../../backend/stripe_web_service.dart';
import '../../data/exception.dart';
import '../../helper/shared_pref_helper.dart';

class PaymentScreenBloc extends Cubit<PaymentScreenState> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final StripeWebService _stripeWebService = StripeWebService.instance();
  final SharedWebService _sharedWebService = SharedWebService.instance;

  PaymentScreenBloc() : super(PaymentScreenState.initial());

  void updateCardState(CreditCardModel card) => emit(state.copyWith(
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cvv: card.cvvCode,
      isShowBack: card.isCvvFocused,
      cardNumber: card.cardNumber));

  Future<void> addCard(String address, String apartment, String city,
      String addressState, String zip) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw NoInternetConnectException();
    String? customerId = user.customerId;
    if (customerId == null||customerId.length<2) {
      final tempCustomerId = await _stripeWebService.createCustomer(
          user.fullname, user.email, user.phoneNumber);
      _sharedWebService.updateCustomerId(tempCustomerId, user.id);
      final updatedUser = user.copyWith(customerId: tempCustomerId);
      await _sharedPrefHelper.insertUser(updatedUser);
      customerId = tempCustomerId;
    }

    final expiryDate = state.expiryDate;
    final expiryDateSplits = expiryDate.split('/');
    await _stripeWebService.addCard(
        user.email,
        state.cardHolderName,
        customerId,
        state.cardNumber,
        int.parse('20${expiryDateSplits[1].toString()}'),
        int.parse(expiryDateSplits[0]),
        int.tryParse(state.cvv) ?? 111,
        address,apartment,city,addressState,zip

    );
  }

  Future<void> removeCard(String paymentId) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw NoInternetConnectException();
    String? customerId = user.customerId;
    if (customerId == null) {
      final tempCustomerId = await _stripeWebService.createCustomer(
          user.fullname, user.email, user.phoneNumber);
      _sharedWebService.updateCustomerId(tempCustomerId, user.id);
      final updatedUser = user.copyWith(customerId: tempCustomerId);
      await _sharedPrefHelper.insertUser(updatedUser);
      customerId = tempCustomerId;
    }
    await _stripeWebService.removeCard(customerId, paymentId);
  }

  Future<void> updateCardDetails(String paymentId, String address, String apartment, String city, String state, String zip, int expireMonth, int expireYear) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw NoInternetConnectException();
    String? customerId = user.customerId;
    if (customerId == null) {
      final tempCustomerId = await _stripeWebService.createCustomer(
          user.fullname, user.email, user.phoneNumber);
      _sharedWebService.updateCustomerId(tempCustomerId, user.id);
      final updatedUser = user.copyWith(customerId: tempCustomerId);
      await _sharedPrefHelper.insertUser(updatedUser);
      customerId = tempCustomerId;
    }
    await _stripeWebService.updateCard(paymentId, address, apartment, city, state, zip,expireMonth,expireYear);

  }
}
