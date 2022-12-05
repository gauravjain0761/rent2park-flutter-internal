import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/backend_responses.dart';
import '../../data/exception.dart';
import '../../data/material_dialog_content.dart';
import '../../data/meta_data.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/app_button.dart';
import '../common/empty_list_item_widget.dart';
import '../common/single_error_try_again_widget.dart';
import 'checkout_earning_screen_bloc.dart';


class CheckoutEarningsScreen extends StatelessWidget {
  static const String route = 'checkout_earnings_screen_route';

  const CheckoutEarningsScreen();

  Future<void> _withdraw(MaterialDialogHelper dialogHelper, CheckoutEarningScreenBloc bloc, BuildContext context,
      SnackbarHelper snackbarHelper) async {
    dialogHelper.showProgressDialog(AppText.WITHDRAWING_AMOUNT_TO_YOUR_BANK_ACCOUNT);
    try {
      final bankAccount = await bloc.getBankAccount();
      if (bankAccount == null) {
        dialogHelper.dismissProgress();
        snackbarHelper.showSnackbar(snackbar: SnackbarMessage.error(message: AppText.YOU_NEED_TO_FIRST_ATTACH_YOUR_BANK_ACCOUNT));
        return;
      }

      if (!bankAccount.isPayoutEnable) {
        dialogHelper.dismissProgress();
        snackbarHelper.showSnackbar(
            snackbar: SnackbarMessage.error(
                message: AppText.PLEASE_UPLOAD_REMAING_DOCUMENT_FIRST_FOR_BANK_ACCOUNT, isLongDuration: true));
        return;
      }

      await bloc.withdraw();
      dialogHelper.dismissProgress();

      snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.success(
              message: 'The payment will be available to your bank account with 7 working days.', isLongDuration: true));
    } catch (_) {
      dialogHelper.dismissProgress();
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _withdraw(dialogHelper, bloc, context, snackbarHelper));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CheckoutEarningScreenBloc>();
    final size = MediaQuery.of(context).size;
    final dialogHelper = MaterialDialogHelper.instance;
    final snackbarHelper = SnackbarHelper.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.COLOR_PRIMARY,
        title: const Text(AppText.CHECKOUT_YOUR_EARNINGS,
            style: TextStyle(color: Constants.COLOR_ON_PRIMARY, fontSize: 17, fontFamily: Constants.GILROY_BOLD)),
        elevation: 0.0,
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.pop(context), color: Constants.COLOR_ON_PRIMARY),
      ),
      body: BlocBuilder<CheckoutEarningScreenBloc, DataEvent>(
        buildWhen: (previous, current) => previous != current,
        builder: (_, dataEvent) {
          if (dataEvent is Initial || dataEvent is Loading)
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          else if (dataEvent is Error) {
            if (dataEvent.exception is NoInternetConnectException)
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleErrorTryAgainWidget(onClick: () => bloc.getCurrentBalance())));
            else
              return EmptyListItemWidget(size: size, title: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
          } else if (dataEvent is Data) {
            final response = dataEvent.data as BaseResponse;
            String earning = response.message;
            if (earning.contains('.')) {
              final earningSplits = earning.split('.');
              earning =
                  earningSplits[0] + '.' + (earningSplits[1].length > 3 ? earningSplits[1].substring(0, 2) : earningSplits[1]);
            }

            return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                color: Constants.COLOR_SECONDARY,
                alignment: Alignment.center,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: '\$$earning\n',
                          style: const TextStyle(
                              color: Constants.COLOR_ON_SECONDARY, fontSize: 22, fontFamily: Constants.GILROY_BOLD)),
                      const TextSpan(
                          text: AppText.YOUR_BALANCE,
                          style:
                              TextStyle(color: Constants.COLOR_ON_SECONDARY, fontSize: 18, fontFamily: Constants.GILROY_REGULAR)),
                    ])),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                          height: 50,
                          width: size.width - 40,
                          child: AppButton(
                              cornerRadius: 4,
                              text: AppText.WITHDRAW,
                              onClick: () {
                                if (response.message == '0' || response.message == '0.0' || response.message == '0.00') {
                                  snackbarHelper.injectContext(context);
                                  snackbarHelper.showSnackbar(
                                      snackbar: SnackbarMessage.error(message: AppText.INSUFFICIENT_BALANCE));
                                  return;
                                }
                                if ((num.tryParse(response.message) ?? int.tryParse(response.message) ?? 0) < 10) {
                                  snackbarHelper.injectContext(context);
                                  snackbarHelper.showSnackbar(
                                      snackbar: SnackbarMessage.error(message: AppText.MINIMUM_WITHDRAW_LIMIT_10_DOLLARS));
                                  return;
                                }
                                dialogHelper.injectContext(context);
                                snackbarHelper.injectContext(context);
                                _withdraw(dialogHelper, bloc, context, snackbarHelper);
                              })))),
              const SizedBox(height: 20)
            ]);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
