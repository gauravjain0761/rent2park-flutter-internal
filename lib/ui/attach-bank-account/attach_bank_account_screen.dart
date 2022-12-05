import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../data/backend_responses.dart';
import '../../data/exception.dart';
import '../../data/material_dialog_content.dart';
import '../../data/meta_data.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../../util/text_upper_case_formatter.dart';
import '../common/app_button.dart';
import '../common/light_app_bar.dart';
import 'attach_bank_account_screen_bloc.dart';
import 'attach_bank_account_screen_state.dart';

class AttachBankAccountScreen extends StatefulWidget {
  static const String route = 'attach_bank_account_screen_route';

  const AttachBankAccountScreen();

  @override
  _AttachBankAccountScreenState createState() => _AttachBankAccountScreenState();
}

class _AttachBankAccountScreenState extends State<AttachBankAccountScreen> {
  late TextEditingController _routingNumberTextController;
  late TextEditingController _accountHolderNameTextController;
  late TextEditingController _accountNumberTextController;

  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;

  @override
  void initState() {
    final bloc = context.read<AttachBankAccountScreenBloc>();
    _routingNumberTextController = TextEditingController(text: bloc.bankAccount?.routingNumber ?? '');
    _accountHolderNameTextController = TextEditingController(text: bloc.bankAccount?.accountHolderName ?? '');
    String last4 = '';
    if (bloc.bankAccount != null) last4 = '**** **** ${bloc.bankAccount?.last4}';
    _accountNumberTextController = TextEditingController(text: last4);
    super.initState();

  }

  Future<void> _addBankAccount(
      String accountHolderName, String routingNumber, String accountNumber, AttachBankAccountScreenBloc bloc) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_BANK_ACCOUNT);
    try {
      await bloc.createBankAccount(accountHolderName, routingNumber, accountNumber);
      _dialogHelper.dismissProgress();
      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(snackbar: SnackbarMessage.success(message: AppText.BANK_ACCOUNT_ADDED_SUCCESSFULLY));
    } on InvalidBankAccountNumber catch (_) {
      _dialogHelper.dismissProgress();
      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(snackbar: SnackbarMessage.error(message: AppText.INVALID_BANK_ACCOUNT_NUMBER));
    } catch (_) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _addBankAccount(accountHolderName, routingNumber, accountNumber, bloc));
    }
  }

  Future<void> _openAccountLink(AttachBankAccountScreenBloc bloc) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.FETCHING_ACCOUNT_LINK);
    try {
      final String accountLink = await bloc.accountLink();
      _dialogHelper.dismissProgress();
      Navigator.pop(context, accountLink);
    } catch (_) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(MaterialDialogContent.networkError(), () => _openAccountLink(bloc));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttachBankAccountScreenBloc>();
    return Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.clear_rounded),
                      color: Constants.COLOR_ON_SURFACE,
                      splashRadius: 25,
                      padding: const EdgeInsets.only(left: 4, top: 10, right: 4, bottom: 10)),
                  const Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
                      child: Text(AppText.EDIT_DIRECT_DEPOSIT,
                          style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_BOLD, fontSize: 22))),
                  _DirectDepositTextField(
                      inputFormatters: [UpperCaseTextFormatter()],
                      iconData: CupertinoIcons.person_alt,
                      textEditingController: _accountHolderNameTextController,
                      hint: AppText.ONE_ACCOUNT_HOLDER_NAME,
                      inputType: TextInputType.name,
                      onChange: (String name) {
                        if (name.isNotEmpty && bloc.state.accountHolderNameError.isNotEmpty)
                          bloc.updateAccountHolderNameError('');
                      },
                      inputAction: TextInputAction.next),
                  BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                      buildWhen: (previous, current) => previous.accountHolderNameError != current.accountHolderNameError,
                      builder: (_, state) => state.accountHolderNameError.isNotEmpty
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 12, top: 2),
                                  child: Text(state.accountHolderNameError,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR, fontFamily: Constants.GILROY_REGULAR, fontSize: 12))))
                          : const SizedBox()),
                  const SizedBox(height: 12),
                  BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                      buildWhen: (previous, current) => previous.bankAccountData != current.bankAccountData,
                      builder: (_, state) => _DirectDepositTextField(
                          isEnable: state.bankAccountData is! Data,
                          iconData: CupertinoIcons.lock_fill,
                          textEditingController: _routingNumberTextController,
                          hint: AppText.TWO_ROUTING_NUMBER,
                          inputType: TextInputType.text,
                          onChange: (String routingNumber) {
                            if (routingNumber.isNotEmpty && bloc.state.routingNumberError.isNotEmpty)
                              bloc.updateRoutingNumberError('');
                          },
                          inputAction: TextInputAction.next)),
                  BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                      buildWhen: (previous, current) => previous.routingNumberError != current.routingNumberError,
                      builder: (_, state) => state.routingNumberError.isNotEmpty
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 12, top: 2),
                                  child: Text(state.routingNumberError,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR, fontFamily: Constants.GILROY_REGULAR, fontSize: 12))))
                          : const SizedBox()),
                  const SizedBox(height: 12),
                  BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                      buildWhen: (previous, current) => previous.bankAccountData != current.bankAccountData,
                      builder: (_, state) => _DirectDepositTextField(
                          isEnable: state.bankAccountData is! Data,
                          iconData: CupertinoIcons.lock_fill,
                          textEditingController: _accountNumberTextController,
                          hint: AppText.THREE_ACCOUNT_NUMBER,
                          inputType: TextInputType.text,
                          onChange: (String accountNumber) {
                            if (accountNumber.isNotEmpty && bloc.state.accountNumberError.isNotEmpty) {
                              bloc.updateAccountNumberError('');
                            }
                          },
                          inputAction: TextInputAction.done)),
                  BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                      buildWhen: (previous, current) => previous.accountNumberError != current.accountNumberError,
                      builder: (_, state) => state.accountNumberError.isNotEmpty
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 12, top: 2),
                                  child: Text(state.accountNumberError,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR, fontFamily: Constants.GILROY_REGULAR, fontSize: 12))))
                          : const SizedBox()),
                  const SizedBox(height: 30),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      child: RichText(
                        text: TextSpan(
                            text: AppText.STRIPE_AGREEMENT_CONTENT,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 15),
                            children: [
                              WidgetSpan(
                                  child: GestureDetector(
                                      onTap: () => launch('https://stripe.com/legal'),
                                      child: const Text(AppText.VIEW_AGREEMENT,
                                          style: TextStyle(
                                              color: Constants.COLOR_SECONDARY,
                                              fontFamily: Constants.GILROY_REGULAR,
                                              fontSize: 15))))
                            ]),
                      )),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                      child: Align(alignment: Alignment.center, child: Image(image: AssetImage('assets/basic_bank_info.png'))))
                ],
              ),
            )),
            BlocBuilder<AttachBankAccountScreenBloc, AttachBankAccountScreenState>(
                buildWhen: (previous, current) => previous.bankAccountData != current.bankAccountData,
                builder: (_, state) {
                  final buttonText = _getButtonText(state.bankAccountData);
                  if (buttonText.isEmpty) return const SizedBox();
                  return Material(
                    color: Colors.white,
                    elevation: 15,
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 30, top: 10, left: 20, right: 20),
                        child: SizedBox(
                            height: 40,
                            child: AppButton(
                                text: buttonText,
                                onClick: () {
                                  final accountHolderName = _accountHolderNameTextController.text;
                                  if (accountHolderName.isEmpty) {
                                    bloc.updateAccountHolderNameError(AppText.ACCOUNT_HOLDER_NAME_CANNOT_BE_EMPTY);
                                    return;
                                  }

                                  final routingNumber = _routingNumberTextController.text;
                                  if (routingNumber.isEmpty) {
                                    bloc.updateRoutingNumberError(AppText.ROUTING_NUMBER_CANNOT_BE_EMPTY);
                                    return;
                                  }
                                  final accountNumber = _accountNumberTextController.text;
                                  if (accountNumber.isEmpty) {
                                    bloc.updateAccountNumberError(AppText.ACCOUNT_NUMBER_CANNOT_BE_EMPTY);
                                    return;
                                  }
                                  FocusScope.of(context).unfocus();
                                  buttonText == AppText.SAVE
                                      ? _addBankAccount(accountHolderName, routingNumber, accountNumber, bloc)
                                      : _openAccountLink(bloc);
                                },
                                fillColor: Constants.COLOR_PRIMARY,
                                cornerRadius: 10))),
                  );
                })
          ],
        ));
  }

  String _getButtonText(DataEvent dataEvent) {
    if (dataEvent is Initial) return AppText.SAVE;
    final bankAccount = (dataEvent as Data).data as BankAccount;
    if (!bankAccount.isPayoutEnable) return AppText.UPLOAD_DOCUMENT;
    return '';
  }

  @override
  void dispose() {
    _accountNumberTextController.dispose();
    _accountHolderNameTextController.dispose();
    _routingNumberTextController.dispose();
    super.dispose();
  }
}

class _DirectDepositTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final IconData iconData;
  final bool isEnable;
  final Function(String text) onChange;
  final List<TextInputFormatter>? inputFormatters;

  const _DirectDepositTextField(
      {required this.iconData,
      required this.textEditingController,
      required this.hint,
      required this.inputType,
      required this.inputAction,
      required this.onChange,
      this.isEnable = true,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.COLOR_ON_SURFACE.withOpacity(0.7), width: 0.8),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, color: Constants.COLOR_ON_SURFACE, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: TextField(
            inputFormatters: inputFormatters,
            enabled: isEnable,
            onChanged: (String? text) {
              if (text == null) return;
              onChange.call(text);
            },
            textInputAction: inputAction,
            keyboardType: inputType,
            style: const TextStyle(fontSize: 13, fontFamily: Constants.GILROY_REGULAR, color: Constants.COLOR_ON_SURFACE),
            controller: textEditingController,
            decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, fontFamily: Constants.GILROY_REGULAR, color: Constants.COLOR_GREY)),
          )),
        ],
      ),
    );
  }
}
