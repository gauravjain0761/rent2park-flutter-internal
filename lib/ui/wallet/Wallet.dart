import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/data/backend_responses.dart';
import 'package:rent2park/ui/wallet/AddEditDebitCreditCards.dart';
import 'package:rent2park/ui/wallet/RewardsWallet.dart';
import 'package:rent2park/ui/wallet/wallet_bloc.dart';
import 'package:rent2park/ui/wallet/wallet_state.dart';
import 'package:rent2park/util/Resource.dart';
import 'package:rent2park/util/SizeConfig.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import 'AddEditBankAccount.dart';

class WalletScreen extends StatefulWidget {
  static const String route = 'wallet_screen_route';

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  late Size size;

  List<PaymentCard> cardsList = [];

  List<Color> cardColors = [
    Color(0xFF0b634e),
    Color(0xFFd34a5f),
    Color(0xff4a61d3),
    Color(0xFF97ebeb),
    Color(0xff0b3463),
    Color(0xffce4ad3),
    Color(0xff97eba8),
    Color(0xFF000000),
    Color(0xFF0b634e),
    Color(0xFFd34a5f),
    Color(0xffebe497),
    Color(0xFF24A4A4)
  ];

  late WalletBloc bloc;

  bool bankAvailable = false;

  List<PaymentCard>? cardsData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bloc = context.read<WalletBloc>();
    return Scaffold(
        backgroundColor: Constants.COLOR_GREY_100,
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Padding(
            padding: EdgeInsets.only(left: 100.0),
            child: Text(
              AppText.WALLET,
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
        body: Container(
          height: size.height,
          width: size.width,
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color: Constants.COLOR_BACKGROUND,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 14.0, right: 14.0),
            child: ListView(
              // physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Constants.COLOR_PRIMARY,
                        size: 24,
                      ),
                    ),
                    Text("Change Payment Method",
                        style: const TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_SEMI_BOLD,
                            fontSize: 18)),
                    SizedBox()
                  ],
                ),
                BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
                   if(state.status == Resource.success) {
                     for(int i=0;i<state.myCards.length;i++){
                       if(state.myCards[i].cardColor== Color(0xFF000000))
                       state.myCards[i].cardColor = cardColors[i];
                     }
                     return selectedCardView(state.myCards);
                  }else return SizedBox();
                }),
                BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
                  if (state.bankAccountStatus == Resource.initial ||
                      state.bankAccountStatus == Resource.loading) {
                    return loadView();
                  } else if (state.bankAccountStatus == Resource.success &&
                      state.bankAccount is! String) {
                    var bankAccount = state.bankAccount as BankAccountNew;
                    return SizedBox(
                        height: getProportionateScreenHeight(200, size.height),
                        child: bank(bankAccount));
                  } else if (state.bankAccountStatus ==
                          Resource.noBankAccounts ||
                      state.bankAccount is String) {
                    return Container(
                      height: getProportionateScreenHeight(210, size.height),
                      child: Center(
                          child: Text("No Bank Accounts to show..",
                              style: TextStyle(
                                  color: Constants.COLOR_BLACK_200,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 14))),
                    );
                  } else if (state.bankAccountStatus == Resource.error) {
                    return Container(
                      height: getProportionateScreenHeight(180, size.height),
                      child: Text("Err....."),
                    );
                  }
                  return const SizedBox();
                }),
                SizedBox(
                  height: 20,
                ),
                BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
                  cardsData = state.myCards;

                  if (state.status == Resource.initial ||
                      state.status == Resource.loading) {
                    return loadView();
                  } else if (state.status == Resource.success) {
                    if (state.myCards.isEmpty) {
                      return Container(
                        height: getProportionateScreenHeight(240, size.height),
                        child: Column(
                          children: [

                            Align(
                                alignment: Alignment.topLeft,
                                child: Text("Cards:",
                                    style: const TextStyle(
                                        color: Constants.COLOR_BLACK,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 16))),
                            Spacer(),

                            Align(
                              alignment: Alignment.center,
                              child: Text("No Cards Added to show..",
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK_200,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 14)),
                            ),

                            Spacer(),

                            Hero(
                              tag: "bank_cards",
                              child: RawMaterialButton(
                                  elevation: 4,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  constraints: BoxConstraints(
                                      minWidth: size.width - 240,
                                      minHeight: 40),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RewardsWallet()));
                                  },
                                  fillColor: Constants.COLOR_PRIMARY,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(AppText.WALLET_REWARD,
                                        style: const TextStyle(
                                            color: Constants.COLOR_ON_PRIMARY,
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 16)),
                                  )),
                            )
                          ],
                        ),
                      );
                    } else {
                      return cards();
                    }
                  } else if (state.status == Resource.error) {
                    return Container(
                      height: getProportionateScreenHeight(180, size.height),
                      child: Text("Err....."),
                    );
                  }
                  return const SizedBox();
                }),

                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ));
  }


  Widget selectedCardView(List<PaymentCard> cardsData) {
    return Column(
      children: [
        SizedBox(height: 25),
        cardsData.isEmpty
                ? SizedBox(height: 45)
                : Row(
                    children: [
                      Container(
                        height: 45,
                        width: 70,
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          color: cardsData[cardsData.length - 1].cardColor,
                          child: Center(
                            child: Text(
                                cardsData[cardsData.length - 1].funding,
                                style: TextStyle(
                                    color: Constants.COLOR_BACKGROUND,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 15)),
                          ),
                        ),
                      ),

                      SizedBox(width: 10),

                      Text("${cardsData[cardsData.length - 1].brand}",
                          style: const TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 18)),
                      Spacer(),
                      Text("### ${cardsData[cardsData.length - 1].last4}",
                          style: const TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 18)),
                      SizedBox(
                        width: 65,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Icon(
                          Icons.check_circle,
                          color: Constants.COLOR_SECONDARY,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          height: 18,
        ),
        Container(
          height: 1,
          width: size.width,
          color: Constants.COLOR_SECONDARY,
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Bank:",
                style: const TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_MEDIUM,
                    fontSize: 16)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
              child: SvgPicture.asset("assets/info.svg", height: 20),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                showBankAndCardSelection();
              },
              child: Icon(
                Icons.add_circle,
                color: Constants.COLOR_SECONDARY,
                size: 42,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget bank(BankAccountNew bankAccount) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      elevation: 8,
      color: Color(0xFF97ebeb),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  bankAccount.bankName.toString(),
                  style: TextStyle(
                      color: Constants.COLOR_BLACK_200,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                Spacer(),
                Text(
                  "Checking",
                  style: TextStyle(
                      color: Constants.COLOR_BLACK_200,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 14),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            SvgPicture.asset(
              "assets/bank.svg",
              height: 75,
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                Navigator.pushNamed(context, AddEditBankAccount.route,
                    arguments: {
                      "bankAccount": bankAccount,
                      "isNew": false,
                    });
              },
              child: Row(
                children: [
                  Text(
                    "#### ${bankAccount.last4}",
                    style: TextStyle(
                        color: Constants.COLOR_BLACK_200,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                  Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 7.0, right: 4.0),
                    child: SvgPicture.asset(
                      "assets/edit_icon.svg",
                      color: Constants.COLOR_BLACK_200,
                      height: 15,
                    ),
                  ),

                  Text(
                    "Edit",
                    style: TextStyle(
                        color: Constants.COLOR_BLACK_200,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  cards() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text("Cards:",
              style: const TextStyle(
                  color: Constants.COLOR_BLACK,
                  fontFamily: Constants.GILROY_MEDIUM,
                  fontSize: 16)),
        ),

        SizedBox(
          height: 15,
        ),

        Container(
          width: getProportionateScreenWidth(300, size.width),
          height: getProportionateScreenHeight(460, size.height),
          /*height: cardsData!.length < 4
              ? getProportionateScreenHeight(320, size.height)
              : cardsData!.length < 6
              ? getProportionateScreenHeight(370, size.height)
              : getProportionateScreenHeight(460, size.height),*/
          child: SizedBox(
            width: size.width,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(
                cardsData!.length,
                    (index) {
                  if (cardsData![index].cardColor == Color(0xFF000000)){
                    cardsData![index].cardColor = cardColors[index];
                  }

                  return Positioned(
                    top: index * 40,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              cardsData!.insert(cardsData!.length - 1, cardsData!.removeAt(index));
                            });
                            bloc.updateCardSelection(cardsData);
                          },

                          child: cardsData![index].name == "apple"
                              ? Card(
                            elevation: 8,
                            color: Constants.COLOR_BLACK,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            child: Container(
                              width: 320,
                              height: 180,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  cardsData![index].name,
                                  style: TextStyle(
                                      color: Constants.COLOR_BACKGROUND,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 20),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          )
                              : Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            margin: EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                                  color: cardsData![index].cardColor,
                                  border: Border.all(
                                      color: Constants.COLOR_BACKGROUND,
                                      width: 2.0)),
                              width: getProportionateScreenWidth(290, size.width),
                              height: 180,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15.0, top: 8),
                                        child: Text(
                                          cardsData![index].brand.toUpperCase(),
                                          style: TextStyle(
                                            color: Constants.COLOR_BACKGROUND,
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 24,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 32,
                                  ),
                                  Text(
                                    "#### #### #### ${cardsData![index].last4}",
                                    style: TextStyle(
                                        color: Constants.COLOR_BACKGROUND,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 20),
                                    textAlign: TextAlign.start,
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pushNamed(
                                          context, AddEditDebitCreditCards.route,
                                          arguments: {
                                            "paymentCard": cardsData![index],
                                            "isNew": false,
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 7.0, right: 4.0),
                                          child: SvgPicture.asset(
                                            "assets/edit_icon.svg",
                                            color: Constants.COLOR_BACKGROUND,
                                            height: 15,
                                          ),
                                        ),
                                        Text(
                                          "Edit",
                                          style: TextStyle(
                                              color: Constants.COLOR_BACKGROUND,
                                              fontFamily: Constants.GILROY_BOLD,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        cardsData!.length-1 == index?
                        Hero(
                          tag: "bank_cards",
                          child: RawMaterialButton(
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                              constraints: BoxConstraints(
                                  minWidth: size.width - 240, minHeight: 40),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RewardsWallet()));
                              },
                              fillColor: Constants.COLOR_PRIMARY,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(AppText.WALLET_REWARD,
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 16)),
                              )),
                        )
                            :SizedBox()

                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );


  }

  void showBankAndCardSelection() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      elevation: 10,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setModalState) {
          return Container(
            color: Constants.COLOR_BACKGROUND,
            child: Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          Text(
                            "Add to Wallet",
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 14),
                          ),
                          Spacer(),
                          InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.close,
                                color: Constants.COLOR_PRIMARY,
                                size: 20,
                              ))
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, AddEditBankAccount.route,
                            arguments: {
                              "isNew": true,
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 4.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/bank.svg",
                              color: Constants.COLOR_PRIMARY,
                              width: 28,
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Banking",
                              style: TextStyle(
                                  color: Constants.COLOR_BLACK,
                                  fontFamily: Constants.GILROY_MEDIUM,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                            context, AddEditDebitCreditCards.route,
                            arguments: {
                              "paymentCard": null,
                              "isNew": true,
                            });

                        /*Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddEditDebitCreditCards()));*/
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 16.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/cards.svg",
                              color: Constants.COLOR_PRIMARY,
                              width: 28,
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Debit & Credit Cards",
                              style: TextStyle(
                                  color: Constants.COLOR_BLACK,
                                  fontFamily: Constants.GILROY_MEDIUM,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }


  Widget loadView() {
    return Container(
      height: size.height,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: getProportionateScreenHeight(150, size.height),
          ),
        ],
      ),
    );
  }
}
