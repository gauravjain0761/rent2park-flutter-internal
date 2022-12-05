import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_scanner_latest/flutter_card_scanner_latest.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rent2park/data/backend_responses.dart';

import '../../data/exception.dart';
import '../../data/material_dialog_content.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/CreditCardFields.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../payment/payment_screen_bloc.dart';
import 'Wallet.dart';



class AddEditDebitCreditCards extends StatefulWidget {
  static const String route = 'add_Edit_DebitCredit_Cards';
  final paymentCard;
  final bool isNew;

  const AddEditDebitCreditCards(
      {Key? key, required this.paymentCard, required this.isNew})
      : super(key: key);

  @override
  State<AddEditDebitCreditCards> createState() =>
      _AddEditDebitCreditCardsState();
}

class _AddEditDebitCreditCardsState extends State<AddEditDebitCreditCards> {
  late Size size;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiresNumberController = TextEditingController();
  TextEditingController securityCodeController = TextEditingController();

  TextEditingController addressEdtController = TextEditingController();
  TextEditingController apartmentEdtController = TextEditingController();
  TextEditingController cityEdtController = TextEditingController();
  TextEditingController stateEdtController = TextEditingController();
  TextEditingController zipEdtController = TextEditingController();

  late PaymentScreenBloc bloc;
  late PaymentCard paymentCard;
  var cardUpdated = false;



  @override
  void initState() {
    super.initState();

    if (widget.paymentCard != null) {
      paymentCard = widget.paymentCard as PaymentCard;
      addressEdtController.text = paymentCard.line1;
      apartmentEdtController.text = paymentCard.line2;
      stateEdtController.text = paymentCard.state;
      cityEdtController.text = paymentCard.city;
      zipEdtController.text = paymentCard.postal_code;
      if(paymentCard.expiryMonth.length==1){
        if(int.parse(paymentCard.expiryMonth)>1 &&int.parse(paymentCard.expiryMonth)<10){
          paymentCard.expiryMonth = "0${paymentCard.expiryMonth}";
        }
      }
      expiresNumberController.text = "${paymentCard.expiryMonth}/${paymentCard.expiryYear.toString().substring(2, 4)}";
    } else {
      paymentCard = PaymentCard(
          id: "id",
          name: "name",
          email: "email",
          brand: "brand",
          expiryMonth: "expiryMonth",
          expiryYear: "expiryYear",
          last4: "last4",
          funding: "VISA",
          createdAt: DateTime.now(),
          cardColor: Color(0xFFd34a5f),
          city: "city",
          country: "country",
          line1: "line1",
          line2: "line2",
          postal_code: "postal_code",
          state: "state");
    }

    if (widget.isNew) {
      SchedulerBinding.instance.addPostFrameCallback((_) => showAddCard("add"));
    }
  }




  Future<void> scanCard() async {
    String scanResponse='';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String response = await FlutterCardScannerLatest.scanCard;

      /* //Parsing the response
      final CardScanResponse cardScanResponse =
      CardScanResponse.fromJSON(json.decode(response));
      //Reading the response and rendering it on the screen
      if (cardScanResponse.result == Constant.success) {
        scanResponse = cardScanResponse.responseText +
            '\n' +
            'Cardholder\'s Name : ' +
            cardScanResponse.body.cardholderName + '\n' +
            'Expiry : ' +
            cardScanResponse.body.expiry;
      } else {
        scanResponse = cardScanResponse.responseText;
      }*/
    } on PlatformException catch (e) {
      scanResponse = "Failed to scan the card ::: '${e.message}'.";
    }

    print("yesh... $scanResponse");
    setState(() {
      // cardScanResponse = scanResponse;
    });

 /*   List<RecognizerResult> results;

    Recognizer recognizer = BlinkCardRecognizer();
    OverlaySettings settings = BlinkCardOverlaySettings();

    var license;
    // set your license

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      var license = "";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = "sRwAAAAVY29tLm1pY3JvYmxpbmsuc2FtcGxlU9kJdb5ZkGlTu623PARDZ2y3bw/2FMh5N8Ns88iVHtrPi9+/nWa1Jfjuaio9sNqvjMT6OtkQ6mJBjE58IcmwG5+mm6WUi+Jy6MYfmGIzIoMFQvkqfYUo2Q/WFqsbYjo57kuic4Q5BWQbqavo1wF7llPipW1ABXqrTLnoewhyHJrJCMyXSOvK6ensoeNbd2iJtgi2L6myHxmekGcmW2ZnKr9otoMUy0YqZ5AjqMxjDw==";
    }

    try {
      // perform scan and gather results
      results = await MicroblinkScanner.scanWithCamera(RecognizerCollection([recognizer]), settings, license);
      print("cardData got yeah... ${results}");

    } on PlatformException {
      // handle exception
    }*/


  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bloc = context.read<PaymentScreenBloc>();



    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Padding(
            padding: EdgeInsets.only(left: size.width * 0.1),
            child: Text(
              'Debit & Credit Cards',
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
              onPressed: () {
                if(cardUpdated){
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  Navigator.pushNamed(context, WalletScreen.route);
                }else{
                  Navigator.pop(context);
                }
              },
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: WillPopScope(
          onWillPop: () async {
            if(cardUpdated){
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
              Navigator.pushNamed(context, WalletScreen.route);
            }else{
              Navigator.pop(context);
            }
            return false;
          },
          child: SingleChildScrollView(
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
                      height: 180,
                      width: 320,
                      color: Colors.white,
                      child: Card(
                        elevation: 8,
                        color: paymentCard.cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                        child: Container(
                          height: 180,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 16.0, right: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "",
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_PRIMARY,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18),
                                      textAlign: TextAlign.start,
                                    ),
                                    Spacer(),
                                    Text(
                                      paymentCard.funding,
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_PRIMARY,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 60,
                                ),
                                Text(
                                  "#### #### #### ${paymentCard.last4}",
                                  style: TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 18),
                                  textAlign: TextAlign.start,
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
                          paymentCard.brand,
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
                  Text("Card Name",
                      style: TextStyle(
                          color: Constants.COLOR_PRIMARY,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 14)),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      "${paymentCard.brand}\n${paymentCard.funding}......${paymentCard.last4}",
                      style: TextStyle(
                          color: Constants.COLOR_BLACK_200,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 16)),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 1,
                    color: Constants.COLOR_GREY,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Text("Expires on",
                          style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),
                      Spacer(),
                      Text("${paymentCard.expiryMonth}/${paymentCard.expiryYear}",
                          style: TextStyle(
                              color: Constants.COLOR_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    height: 1,
                    color: Constants.COLOR_GREY,
                  ),
                  Text("Billing Address",
                      style: TextStyle(
                          color: Constants.COLOR_PRIMARY,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 14)),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                          "${paymentCard.line1}\n${paymentCard.line2}\n${paymentCard.state}, ${paymentCard.city}, ${paymentCard.postal_code}",
                          style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          // showEditAddressDialog();
                          showAddCard("edit");
                        },
                        child: SvgPicture.asset(
                          "assets/edit_icon.svg",
                          color: Constants.COLOR_PRIMARY,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 20,
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
                    child: Container(
                      width: size.width,
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
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 10),
                    height: 1,
                    color: Constants.COLOR_GREY,
                  ),
                  InkWell(
                    onTap: () {
                      _removeCard(bloc, paymentCard.id);
                    },
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
          ),
        ));
  }

  void showAddCard(String type) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
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
                                if (type == "add") {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                      type == "add"
                          ? Container(
                              margin: EdgeInsets.only(
                                  left: 25, right: 25, bottom: 15),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: cardNumberController,
                                decoration: InputDecoration(
                                  /*prefixIcon: InkWell(
                                      onTap: () {
                                        scanCard();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 7.0, right: 7.0, bottom: 2.0),
                                        child: Image.asset(
                                            "assets/scan_camera.png"),
                                      )),
                                  prefixIconConstraints: BoxConstraints(
                                      maxHeight: 40, maxWidth: 40),*/
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Enter Card Number",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Flexible(
                              child: ExpirationFormField(
                                controller: expiresNumberController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Expires",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: type == "add" ? 10 : 0,
                            ),
                            type == "add"
                                ? Flexible(
                                    child: TextFormField(
                                      maxLength: 3,
                                      keyboardType: TextInputType.number,
                                      controller: securityCodeController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        labelText: "CVV",
                                        counterText: "",
                                        labelStyle: TextStyle(
                                            color: Constants.COLOR_GREY,
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: addressEdtController,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: "Address",
                            labelStyle: TextStyle(
                                color: Constants.COLOR_GREY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: apartmentEdtController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Apt/Ste",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: cityEdtController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "City",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        child: Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: stateEdtController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "State",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: zipEdtController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Zip",
                                  labelStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      RawMaterialButton(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          constraints: BoxConstraints(
                              minWidth: size.width - 240, minHeight: 40),
                          onPressed: () {
                            var expireMonth = int.parse(expiresNumberController
                                .text
                                .toString()
                                .substring(0, 2));

                            var currentYear = int.parse(DateTime.now()
                                .year
                                .toString()
                                .substring(2, 4)
                                .toString());
                            var expireYear = int.parse(expiresNumberController
                                .text
                                .toString()
                                .substring(3, 5));

                            var address = addressEdtController.text;
                            var apartment = apartmentEdtController.text;
                            var city = cityEdtController.text;
                            var state = stateEdtController.text;
                            var zip = zipEdtController.text;

                            if (type == "add") {
                              if (cardNumberController.text.length < 16) {
                                showSnackBar("please enter a valid card number",
                                    context);
                                return;
                              }

                              if (securityCodeController.text.length < 3) {
                                showSnackBar(
                                    "please enter a valid CVV Code", context);
                                return;
                              }

                            }
                            if (expireMonth > 12 || expireMonth < 1) {
                              showSnackBar(
                                  "please enter a valid expiry date", context);
                              return;
                            }

                            if (expireYear < currentYear) {
                              showSnackBar(
                                  "please enter a valid expiry date", context);
                              return;
                            }



                            if (address.isEmpty) {
                              showSnackBar(
                                  "please enter a valid address", context);
                              return;
                            }

                            if (city.isEmpty) {
                              showSnackBar(
                                  "please enter a valid city", context);
                              return;
                            }

                            if (state.isEmpty) {
                              showSnackBar("please enter a valid state", context);
                              return;
                            }

                            if (zip.isEmpty) {
                              showSnackBar("please enter a valid zip code", context);
                              return;
                            }

                            var creditCardModel = CreditCardModel(
                              cardNumberController.text,
                              expiresNumberController.text,
                              "",
                              securityCodeController.text,
                              false,
                            );

                            bloc.updateCardState(creditCardModel);
                            if (type == "add") {
                              _addCard(
                                  bloc, address, apartment, city, state, zip);
                            } else {
                              updateCardDetails(bloc, address, apartment, city,
                                  state, zip, expireMonth, expireYear);
                            }
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
            ),
          );
        });
  }

  void showSnackBar(msg, context) {
    Flushbar(
      backgroundColor: Colors.red,
      message: msg,
      duration: Duration(seconds: 2),
    ).show(context);
  }

  void showEditAddressDialog() {
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
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.close,
                                color: Constants.COLOR_PRIMARY,
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: TextFormField(
                            maxLines: null,
                            keyboardType: TextInputType.number,
                            controller: addressEdtController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              labelText: "address",
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
                        RawMaterialButton(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            constraints: BoxConstraints(
                                minWidth: size.width - 240, minHeight: 40),
                            onPressed: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            fillColor: Constants.COLOR_PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text("Update",
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

  Future<void> _addCard(PaymentScreenBloc bloc, String address,
      String apartment, String city, String state, String zip) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_CARD_DETAIL);
    try {
      await bloc.addCard(address, apartment, city, state, zip);
      _dialogHelper.dismissProgress();
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 3);
      Navigator.pushNamed(context, WalletScreen.route);

    } on InCorrectCardNumberException catch (e) {
      _dialogHelper.dismissProgress();
      showSnackBar(e.message, context);
    } catch (e) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _addCard(bloc, address, apartment, city, state, zip));
    }
  }

  Future<void> _removeCard(PaymentScreenBloc bloc, String paymentId) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.REMOVING_CARD_DETAIL);
    try {
      await bloc.removeCard(paymentId);
      _dialogHelper.dismissProgress();
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 3);
      Navigator.pushNamed(context, WalletScreen.route);
    } on InCorrectCardNumberException catch (e) {
      _dialogHelper.dismissProgress();
      showSnackBar(e.message, context);
    } catch (e) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _removeCard(bloc, paymentId));
    }
  }

  Future<void> updateCardDetails(
      PaymentScreenBloc bloc,
      String address,
      String apartment,
      String city,
      String state,
      String zip,
      int expireMonth,
      int expireYear) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.UPDATING_CARD_DETAIL);
    try {
      await bloc.updateCardDetails(paymentCard.id, address, apartment, city,
          state, zip, expireMonth, expireYear);
      _dialogHelper.dismissProgress();
      cardUpdated = true;
      Navigator.pop(context);
      setState(() {
        paymentCard = PaymentCard(
            id: paymentCard.id,
            name: paymentCard.name,
            email: paymentCard.email,
            brand: paymentCard.brand,
            expiryMonth: expireMonth.toString(),
            expiryYear: expireYear.toString(),
            last4: paymentCard.last4,
            funding: paymentCard.funding,
            createdAt: paymentCard.createdAt,
            cardColor: paymentCard.cardColor,
            city: city,
            country: "",
            line1: address,
            line2: apartment,
            postal_code: zip,
            state: state);
      });
    } on InCorrectCardNumberException catch (e) {
      _dialogHelper.dismissProgress();
      showSnackBar(e.message, context);
    } catch (e) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => updateCardDetails(bloc, address, apartment, city, state, zip,
              expireMonth, expireYear));
    }
  }
}
