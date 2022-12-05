import 'package:flutter/material.dart';
import 'package:rent2park/ui/depositsAndTranfer/DepositDetails.dart';
import 'package:rent2park/ui/depositsAndTranfer/TransferAmount.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';


class DepositData {
  var date;
  var amount;
  var type;
  var year;
  var initiated;
  var deposited;
  var infoMessage;

  DepositData({
    required this.date,
    required this.amount,
    required this.type,
    required this.year,
    required this.initiated,
    required this.deposited,
    required this.infoMessage,
  });
}

List<DepositData> depositDataList = [
  DepositData(date: "Jun 15", amount: "\$450.00", type: "Weekly deposit",year:"2022",initiated: "Jun 13",deposited: "Jun 13 - Jun 15",infoMessage: "You were charged \$1.99 from the amount cashed out using fast pay, the amount shown here is after the fee was taken."),
  DepositData(date: "May 25", amount: "\$158.00", type: "Fast Pay",year:"2022",initiated: "May 25",deposited: "May 25",infoMessage: "You were charged \$1.99 from the amount cashed out using fast pay, the amount shown here is after the fee was taken."),
  DepositData(date: "Mar 31", amount: "\$80.00", type: "Fast Pay",year:"2022",initiated: "May 25",deposited: "May 25",infoMessage: "You were charged \$1.99 from the amount cashed out using fast pay, the amount shown here is after the fee was taken."),
  DepositData(date: "Mar 7", amount: "\$320.00", type: "Weekly deposit",year:"2022",initiated: "Jun 13",deposited: "Jun 13 - Jun 15",infoMessage: "You were charged \$1.99 from the amount cashed out using fast pay, the amount shown here is after the fee was taken."),
];


class DepositAndTransfer extends StatefulWidget {
  const DepositAndTransfer({Key? key}) : super(key: key);

  @override
  State<DepositAndTransfer> createState() => _DepositAndTransferState();
}

class _DepositAndTransferState extends State<DepositAndTransfer> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            AppText.DEPOSIT_TRANSFER,
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
                padding: EdgeInsets.all(15.0),
                color: Constants.COLOR_GREY_100,
                child: depositData(),
              ),
            ),
          ],
        ));
  }

  Widget depositData() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Available balance",
          style: TextStyle(
              fontSize: 16,
              fontFamily: Constants.GILROY_BOLD,
              color: Constants.COLOR_BLACK_200),
        ),
        Text(
          "\$0.00",
          style: TextStyle(
              fontSize: 22,
              fontFamily: Constants.GILROY_BOLD,
              color: Constants.COLOR_BLACK_200),
        ),
        Text(
          "Weekly auto-tranfer will initiate each Tuesday",
          style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.GILROY_MEDIUM,
              color: Constants.COLOR_BLACK_200),
        ),
        SizedBox(
          height: 12,
        ),
          RawMaterialButton(
            elevation: 4,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransferAmount()));
            },
            fillColor: Constants.COLOR_PRIMARY,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              child: Text(AppText.CASH_OUT_FAST_PAY,
                  style: const TextStyle(
                      color: Constants.COLOR_ON_PRIMARY,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 16)),
            )),
          SizedBox(
          height: 42,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppText.DEPOSIT_TO_BANK,
              style: const TextStyle(
                  color: Constants.COLOR_BLACK_200,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 16)),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          height: 1,
          color: Constants.COLOR_GREY,
        ),
        SizedBox(
          height: 6,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: depositDataList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          DepositDetails(
                              depositData: depositDataList[index])));
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(depositDataList[index].date,
                            style: const TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontFamily: Constants.GILROY_MEDIUM,
                                fontSize: 16)),
                        Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(depositDataList[index].amount,
                                style: const TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16)),
                            Text(depositDataList[index].type,
                                style: const TextStyle(
                                    color: Constants.COLOR_PRIMARY,
                                    fontFamily: Constants.GILROY_MEDIUM,
                                    fontSize: 12)),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 20,
                          color: Constants.COLOR_BLACK_200,
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      height: 1,
                      color: Constants.COLOR_GREY,
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }
}
