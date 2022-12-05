import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';

class TransferAmount extends StatefulWidget {
  const TransferAmount({Key? key}) : super(key: key);

  @override
  State<TransferAmount> createState() => _TransferAmountState();
}

class _TransferAmountState extends State<TransferAmount> {

  late Size size;

  var infoText = "Fast cash payments use your debit card on file to send available earrings, we charge a \$1.99 fee to send Fast Pay payments.\n\n Alternately you can wait for our weekly payout scheduled every Tuesdays, which take anywhere from 3-7 days to clear.";

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            "",
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 18),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              padding: EdgeInsets.all(15.0),
              color: Constants.COLOR_GREY_100,
              child: transferAmountWidget(),
            ),
            Positioned(
                top: 20,right: 25,child: InkWell(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 16,
                      child: showTextMessage(),
                    );
                  },
                );
              },
                child: SvgPicture.asset('assets/info.svg'))),
          ],

        ));
  }

  Widget transferAmountWidget() {
    return Column(
      children: [
        SizedBox(height: 15,),
      Text(
      "Available for Fast Pay",
      style: TextStyle(
          color: Constants.COLOR_BLACK_200,
          fontFamily: Constants.GILROY_BOLD,
          fontSize: 16)),
        Text(
      "\$0.00",
      style: TextStyle(
          color: Constants.COLOR_BLACK_200,
          fontFamily: Constants.GILROY_BOLD,
          fontSize: 22)),

        Spacer(),
        Text(
            "You don't have funds to transfer.",
            style: TextStyle(
                color: Constants.COLOR_BLACK_200,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 14)),
        SizedBox(height: 5,),
        RawMaterialButton(
            elevation: 4,
            constraints: BoxConstraints(
            minWidth: size.width - 45, minHeight: 40),

            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransferAmount()));
            },

            fillColor: Constants.COLOR_PACKAGE_UNSELECTED,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              child: Text("Transfer \$0.00",
                  style: const TextStyle(
                      color: Constants.COLOR_ON_PRIMARY,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 16)),
            )),
        SizedBox(height: 8,),
      ],
    );
  }

  Widget showTextMessage() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: InkWell(onTap: ()=>Navigator.of(context).pop(),child: Icon(Icons.clear,color: Constants.COLOR_PRIMARY,))),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  infoText,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: Constants.GILROY_BOLD,
                    color: Constants.COLOR_BLACK_200,),textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20,),
              RawMaterialButton(
                  elevation: 4,
                  constraints: BoxConstraints(
                      minWidth: size.width*0.50, minHeight: 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    child: Text(AppText.OK_GOT_IT,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                  )),
              SizedBox(height: 25,),

            ],
          ),
        ),
      ],
    );
  }
}
