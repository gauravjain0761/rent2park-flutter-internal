import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import 'DepositAndTransfer.dart';

class DepositDetails extends StatefulWidget {
  final DepositData depositData;

  const DepositDetails({Key? key, required this.depositData}) : super(key: key);

  @override
  State<DepositDetails> createState() => _DepositDetailsState();
}

class _DepositDetailsState extends State<DepositDetails> {
  late Size size;
  late DepositData depositData;

  GlobalKey key = new GlobalKey();

  @override
  void initState() {
    depositData = widget.depositData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            "${depositData.date}, ${depositData.year}",
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
            SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height,
                padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
                color: Constants.COLOR_GREY_100,
                child: depositDataWidget(),
              ),
            ),
          ],
        ));
  }

  Widget depositDataWidget() {
    return Stack(
      children: [

        Visibility(
          visible: depositData.type == "Fast Pay",
          child: Positioned(
            key: key,
              top: 10,right: 5,child: InkWell(
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
              child: SvgPicture.asset('assets/info.svg')),
          ),
        ),

        Column(
          children: [
            SizedBox(
              height: 25,
            ),
            Text(
              depositData.amount,
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: Constants.GILROY_BOLD,
                  color: Constants.COLOR_BLACK_200),
            ),
            Text(
              depositData.type,
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: Constants.GILROY_MEDIUM,
                  color: Constants.COLOR_BLACK_200),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Constants.COLOR_PRIMARY,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Initiated by Rent2Park",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: Constants.GILROY_BOLD,
                            color: Constants.COLOR_BLACK_200),
                      ),
                      Text(
                        depositData.initiated,
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: Constants.GILROY_MEDIUM,
                            color: Constants.COLOR_BLACK_200),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 80,),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Constants.COLOR_PRIMARY,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deposited to Bank",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: Constants.GILROY_BOLD,
                            color: Constants.COLOR_BLACK_200),
                      ),
                      Text(
                        depositData.deposited,
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: Constants.GILROY_MEDIUM,
                            color: Constants.COLOR_BLACK_200),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 15,),
            Container(color: Constants.COLOR_GREY,height: 1,width: size.width,margin: EdgeInsets.symmetric(vertical: 12),),
            Row(
              children: [
                Text(
                  "Earning From",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: Constants.GILROY_MEDIUM,
                      color: Constants.COLOR_BLACK_200),
                ),
                Spacer(),
                Text(
                  "May 18 - Jun 25",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: Constants.GILROY_BOLD,
                      color: Constants.COLOR_BLACK_200),
                ),
              ],
            ),
            Container(color: Constants.COLOR_GREY,height: 1,width: size.width,margin: EdgeInsets.symmetric(vertical: 12),)
          ],
        ),
        Positioned(
            top: 128,left: 29,child: Container(height: 100,width: 3,color: Constants.COLOR_PRIMARY,)),

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
                  depositData.infoMessage,
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
