import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';
import '../../backend/stripe_web_service.dart';
import '../../data/backend_responses.dart';
import '../../data/exception.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';
import 'attach_bank_account_screen_state.dart';


class AttachBankAccountScreenBloc extends Cubit<AttachBankAccountScreenState> {

  final StripeWebService _stripeWebService = StripeWebService.instance();
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPreferenceHelper = SharedPreferenceHelper.instance;

  final BankAccount? bankAccount;

  AttachBankAccountScreenBloc({required this.bankAccount})
      : super(AttachBankAccountScreenState.initial(bankAccount == null ? Initial() : Data(data: bankAccount)));

  void updateAccountHolderNameError(String error) => emit(state.copyWith(accountHolderNameError: error));

  void updateRoutingNumberError(String error) => emit(state.copyWith(routingNumberError: error));

  void updateAccountNumberError(String error) => emit(state.copyWith(accountNumberError: error));

  Future<void> createBankAccount(String accountHolderName, String routingNumber, String accountNumber) async {
    final user = await _sharedPreferenceHelper.user();
    if (user == null) throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final bankAccount = await _stripeWebService.connectAccountId(user.firstName, user.lastName, user.email, accountNumber, routingNumber, accountHolderName);
    // await _sharedWebService.updateConnectAccountId(bankAccount.id, user.id);
    final updatedUser = user.copyWith(connectAccountId: bankAccount.id);
    _sharedPreferenceHelper.insertUser(updatedUser);
    emit(state.copyWith(bankAccountData: Data(data: bankAccount)));
  }

  Future<void> createNewBankAccount(String accountHolderName, String routingNumber, String accountNumber) async {
    final user = await _sharedPreferenceHelper.user();
    if (user == null) throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final bankAccount = await _stripeWebService.createBankAccount(user.customerId.toString(), routingNumber, accountNumber, accountHolderName);
    final updatedUser = user.copyWith(connectAccountId: bankAccount.id);
    _sharedPreferenceHelper.insertUser(updatedUser);
    emit(state.copyWith(bankAccountData: Data(data: bankAccount)));
  }

  Future<String> accountLink([User? user]) async {
    String? connectAccountId = user?.connectAccountId;
    if (connectAccountId == null) {
      final tempUser = await _sharedPreferenceHelper.user();
      if (tempUser == null) throw NoInternetConnectException();
      connectAccountId = tempUser.connectAccountId;
    }
    if (connectAccountId == null) throw NoInternetConnectException();
    return await _stripeWebService.connectAccountLink(connectAccountId);
  }

  Future<BankAccount?> getBankAccount() async {
    final user = await _sharedPreferenceHelper.user();
    if (user == null) throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final connectAccountId = user.connectAccountId;
    if (connectAccountId == null) return null;
    return await _stripeWebService.getConnectAccount(connectAccountId);
  }
}
