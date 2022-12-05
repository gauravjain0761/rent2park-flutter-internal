import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:rent2park/ui/payment/payment_screen_bloc.dart';
import 'package:rent2park/ui/payment/payment_screen_dart.dart';

import '../../data/exception.dart';
import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';


class PaymentScreen extends StatefulWidget {
  static const String route = 'payment_screen_route';

  const PaymentScreen();

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;

  Future<void> _addCard(PaymentScreenBloc bloc) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_CARD_DETAIL);
    try {
      await bloc.addCard("","","","","");
      _dialogHelper.dismissProgress();
      Navigator.pop(context, true);
    } on InCorrectCardNumberException catch (e) {
      _dialogHelper.dismissProgress();
      _snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: e.message));
    } catch (e, stack) {
      print('Error --> $stack');
      print('Error --> $e');
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _addCard(bloc));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PaymentScreenBloc>();
    final snackbarHelper = SnackbarHelper.instance..injectContext(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          backgroundColor: Constants.COLOR_PRIMARY,
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
          title: const Text(AppText.PAYMENT,
              style: TextStyle(
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 18,
                  color: Constants.COLOR_ON_PRIMARY))),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<PaymentScreenBloc, PaymentScreenState>(
                  builder: (_, state) => CreditCardWidget(
                    onCreditCardWidgetChange: (_) {},
                    labelExpiredDate: 'mm/yy',
                    cardNumber: state.cardNumber,
                    expiryDate: state.expiryDate,
                    cardHolderName: state.cardHolderName,
                    cvvCode: state.cvv,
                    showBackView: state.isShowBack,
                    obscureCardCvv: false,
                    obscureCardNumber: false,
                    animationDuration: const Duration(milliseconds: 800),
                    labelCardHolder: 'Cardholder name',
                    textStyle: TextStyle(
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 16,
                        color: Constants
                            .COLOR_SURFACE), //true when you want to show cvv(back) view
                  ),
                ),
                CreditCardForm(
                    cardNumber: '',
                    expiryDate: '',
                    cardHolderName: '',
                    cvvCode: '',
                    onCreditCardModelChange: bloc.updateCardState,
                    themeColor: Constants.COLOR_PRIMARY,
                    formKey: _formKey),
                const SizedBox(height: 50),
                Center(
                  child: RawMaterialButton(
                      fillColor: Constants.COLOR_PRIMARY,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      onPressed: () {
                        final state = bloc.state;
                        if (state.cardHolderName.isEmpty) {
                          snackbarHelper.showSnackbar(
                              snackbar: SnackbarMessage.error(
                                  message:
                                      AppText.CARD_NUMBER_CANNOT_BE_EMPTY));
                          return;
                        }
                        if (state.expiryDate.isEmpty) {
                          snackbarHelper.showSnackbar(
                              snackbar: SnackbarMessage.error(
                                  message: AppText.CARD_DATE_CANNOT_BE_EMPTY));
                          return;
                        }
                        if (state.cvv.isEmpty) {
                          snackbarHelper.showSnackbar(
                              snackbar: SnackbarMessage.error(
                                  message: AppText.CARD_CVV_CANNOT_BE_EMPTY));
                          return;
                        }
                        if (state.cardHolderName.isEmpty) {
                          snackbarHelper.showSnackbar(
                              snackbar: SnackbarMessage.error(
                                  message:
                                      AppText.CARD_HOLDER_CANNOT_BE_EMPTY));
                          return;
                        }
                        final isValidate = _formKey.currentState?.validate();
                        print('isValidate --> $isValidate');
                        if (isValidate == null || !isValidate) {
                          snackbarHelper.showSnackbar(
                              snackbar: SnackbarMessage.error(
                                  message: AppText.CARD_DETAIL_ARE_INVALID));
                          return;
                        }

                        FocusScope.of(context).unfocus();
                        _addCard(bloc);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 13, bottom: 12, left: 60, right: 60),
                          child: Text(AppText.DONE,
                              style: TextStyle(
                                  letterSpacing: 2,
                                  color: Constants.COLOR_ON_SECONDARY,
                                  fontFamily: Constants.GILROY_REGULAR,
                                  fontSize: 16)))),
                ),
                const SizedBox(height: 30)
              ],
            ),
          )),
    );
  }
}
