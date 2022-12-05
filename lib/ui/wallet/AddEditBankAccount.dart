import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rent2park/data/backend_responses.dart';
import '../../backend/stripe_web_service.dart';
import '../../data/exception.dart';
import '../../data/material_dialog_content.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../attach-bank-account/attach_bank_account_screen_bloc.dart';
import 'Wallet.dart';

class AddEditBankAccount extends StatefulWidget {
  static const String route = 'add_bank_account_screen';
  final isNew;
  final bankAccount;

  const AddEditBankAccount(
      {Key? key, required this.bankAccount, required this.isNew})
      : super(key: key);

  @override
  State<AddEditBankAccount> createState() => _AddEditBankAccountState();
}

class _AddEditBankAccountState extends State<AddEditBankAccount> {
  late Size size;
  TextEditingController routingNumberController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  late AttachBankAccountScreenBloc bloc;
  BankAccountNew? bankAccount;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final StripeWebService _stripeWebService = StripeWebService.instance();

  @override
  void initState() {
    if (widget.isNew) {
      SchedulerBinding.instance.addPostFrameCallback((_) => showAddCard("add"));
      bankAccount = BankAccountNew(
          id: "id",
          status: "new",
          accountType: "",
          accountHolderName: "accountHolderName",
          accountHolderType: "accountHolderType",
          country: "country",
          bankName: "bankName",
          currency: "currency",
          isPayoutEnable: false,
          last4: "last4",
          routingNumber: "routingNumber");
    } else {
      bankAccount = widget.bankAccount as BankAccountNew;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bloc = context.read<AttachBankAccountScreenBloc>();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Text(
              'Banking',
              style: TextStyle(
                  color: Constants.COLOR_ON_PRIMARY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 190,
                    width: 340,
                    color: Colors.white,
                    child: Card(
                      elevation: 8,
                      color: Color(0xFF97ebeb),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                      child: Container(
                        height: 180,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 6.0, left: 16.0, right: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 180,
                                    child: Text(
                                      bankAccount!.bankName,
                                      style: TextStyle(
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "Checking",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              SvgPicture.asset(
                                "assets/bank.svg",
                                height: 85,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "#### ${bankAccount?.last4}",
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK_200,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    showAddCard("edit");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${bankAccount?.bankName}",
                        style: TextStyle(
                            color: Constants.COLOR_BLACK_200,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 18),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: SvgPicture.asset(
                          "assets/edit_icon.svg",
                          color: Constants.COLOR_PRIMARY,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Bank Name",
                    style: TextStyle(
                        color: Constants.COLOR_PRIMARY,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 14)),
                SizedBox(
                  height: 5,
                ),
                Text("${bankAccount?.bankName}. . . .${bankAccount?.last4}",
                    style: TextStyle(
                        color: Constants.COLOR_BLACK_200,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 16)),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 14),
                  height: 1,
                  color: Constants.COLOR_GREY,
                ),
                Row(
                  children: [
                    Text("Account Type",
                        style: TextStyle(
                            color: Constants.COLOR_BLACK_200,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                    Spacer(),
                    Text(
                        bankAccount!.accountType.isEmpty
                            ? "Checking"
                            : bankAccount!.accountType,
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 14),
                  height: 1,
                  color: Constants.COLOR_GREY,
                ),
                Row(
                  children: [
                    Text("Status",
                        style: TextStyle(
                            color: Constants.COLOR_BLACK_200,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                    Spacer(),
                    Text("Confirmed",
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 10),
                  height: 1,
                  color: Constants.COLOR_GREY,
                ),
                InkWell(
                  onTap: () {
                    showAddCard("edit");
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/edit_icon.svg",
                        color: Constants.COLOR_PRIMARY,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Edit",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 10),
                  height: 1,
                  color: Constants.COLOR_GREY,
                ),
                SizedBox(
                  height: 80,
                ),
                InkWell(
                  onTap: () {
                    removeAccount(bankAccount?.id);
                  },
                  child: SizedBox(
                    width: size.width,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/trash_icon.svg",
                          color: Constants.COLOR_PRIMARY,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Remove",
                              style: TextStyle(
                                  color: Constants.COLOR_BLACK_200,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 1,
                  color: Constants.COLOR_GREY,
                ),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: RawMaterialButton(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      constraints: BoxConstraints(
                          minWidth: size.width - 240, minHeight: 40),
                      onPressed: () {},
                      fillColor: Constants.COLOR_PRIMARY,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("Save",
                            style: const TextStyle(
                                color: Constants.COLOR_ON_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      )),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ));
  }

  void showAddCard(String type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/info.svg"),
                            Spacer(),
                            InkWell(
                                onTap: () {
                                  if (widget.isNew) {
                                    int count = 0;
                                    Navigator.of(context)
                                        .popUntil((_) => count++ >= 2);
                                    Navigator.pushNamed(
                                        context, WalletScreen.route);
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Constants.COLOR_PRIMARY,
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: routingNumberController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Constants.COLOR_PRIMARY,
                                size: 24,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "Routing Number",
                              labelStyle: TextStyle(
                                  color: Constants.COLOR_GREY,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: accountNumberController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Constants.COLOR_PRIMARY,
                                size: 24,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "Account Number",
                              labelStyle: TextStyle(
                                  color: Constants.COLOR_GREY,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        RawMaterialButton(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            constraints: BoxConstraints(
                                minWidth: size.width - 240, minHeight: 40),
                            onPressed: () {
                              var accountNumber = accountNumberController.text;
                              var routingNumber = routingNumberController.text;
                              if (accountNumber.isEmpty) {
                                showSnackBar(
                                    "please enter a valid account number",
                                    context,
                                    Colors.black87);
                                return;
                              }
                              if (routingNumber.isEmpty) {
                                showSnackBar(
                                    "please enter a valid routing number",
                                    context,
                                    Colors.black87);
                                return;
                              }
                              _addBankAccount("", routingNumber, accountNumber);
                            },
                            fillColor: Constants.COLOR_PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(type == "add" ? "Add" : "Update",
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16)),
                            )),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }

  void showSnackBar(msg, context, Color color) {
    Flushbar(
      backgroundColor: color,
      message: msg,
      duration: Duration(seconds: 2),
    ).show(context);
  }

  Future<void> _addBankAccount(String accountHolderName, String routingNumber,
      String accountNumber) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_BANK_ACCOUNT);
    try {
      await bloc.createNewBankAccount(
          accountHolderName, routingNumber, accountNumber);
      _dialogHelper.dismissProgress();
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 3);
      Navigator.pushNamed(context, WalletScreen.route);
      showSnackBar(
          AppText.BANK_ACCOUNT_ADDED_SUCCESSFULLY, context, Colors.black87);
    } on InvalidBankAccountNumber catch (_) {
      _dialogHelper.dismissProgress();
      showSnackBar(AppText.INVALID_BANK_ACCOUNT_NUMBER, context, Colors.red);
    } catch (_) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () =>
              _addBankAccount(accountHolderName, routingNumber, accountNumber));
    }
  }

  Future<void> removeAccount(String? bankAccountId) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.REMOVING_BANK_ACCOUNT);
    final user = await _sharedPrefHelper.user();
    final customerId = user?.customerId;
    try {
      var status = await _stripeWebService.removeBankAccount(customerId!, bankAccountId!);

      _dialogHelper.dismissProgress();
      if(status==true){
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
        Navigator.pushNamed(context, WalletScreen.route);
      }

    } on InCorrectCardNumberException {
      _dialogHelper.dismissProgress();
    } catch (e) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => removeAccount(bankAccountId));
    }
  }
}
