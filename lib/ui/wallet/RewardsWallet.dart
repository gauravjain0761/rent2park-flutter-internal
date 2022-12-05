import 'package:flutter/material.dart';
import '../../util/LineSeparator.dart';
import '../../util/constants.dart';

class RewardsWallet extends StatefulWidget {
  const RewardsWallet({Key? key}) : super(key: key);

  @override
  State<RewardsWallet> createState() => _RewardsWalletState();
}

class _RewardsWalletState extends State<RewardsWallet>
    with SingleTickerProviderStateMixin {
  late Size size;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Text(
              "Rewards Wallet",
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
        body: Wrap(
          children: [
            Container(
              color: Constants.COLOR_GREY_100,
              width: size.width,
              height: size.height - 80,
              child: currentPointsCard(),
            )
          ],
        ));
  }

  Widget currentPointsCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          height: size.height * 0.20,
          width: size.width - 90,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Constants.COLOR_PRIMARY,
                    Constants.COLOR_SECONDARY
                  ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 6,
              ),
              Text(
                "Current Points",
                style: TextStyle(
                    color: Constants.COLOR_ON_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 24),
              ),
              Text(
                "130",
                style: TextStyle(
                    color: Constants.COLOR_ON_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 34),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "20 points till your next reward",
                style: TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 12),
              ),
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProgressBar(
                  current: 0.7,
                  max: 1,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: size.height * 0.20,
          width: size.width - 40,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              color: Constants.COLOR_ON_SECONDARY),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Share and get points",
                style: TextStyle(
                    color: Constants.COLOR_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "When your friends use your code you\n and them both get 50 points",
                style: TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_MEDIUM,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              RawMaterialButton(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  constraints:
                      BoxConstraints(minWidth: size.width - 200, minHeight: 40),
                  onPressed: () {},
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Text("Share invite code",
                      style: const TextStyle(
                          color: Constants.COLOR_ON_PRIMARY,
                          fontFamily: Constants.GILROY_MEDIUM,
                          fontSize: 16)))
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 42, left: 10, right: 10),
              width: size.width,
              height: 2.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Constants.COLOR_GREY),
            ),
            Container(
              height: 45,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Constants.COLOR_PRIMARY,
                indicator: UnderlineTabIndicator(
                  borderSide:
                      BorderSide(color: Constants.COLOR_PRIMARY, width: 4.0),
                  insets: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                ),
                labelColor: Constants.COLOR_BLACK_200,
                labelStyle: TextStyle(
                    color: Constants.COLOR_ON_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 16),
                unselectedLabelColor: Constants.COLOR_BLACK_200,
                tabs: [
                  Tab(
                    text: 'Rewards',
                  ),
                  Tab(
                    text: 'History',
                  ),
                ],
              ),
            ),
          ],
        ),
        // tab bar view here
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // first tab bar view widget
              ListView.builder(
                padding: EdgeInsets.only(top: 5),
                  shrinkWrap: true,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Image(
                            image: AssetImage('assets/coupon_bg.png'),
                            height: 162,
                            width: size.width,
                            fit : BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 40,right: 40,top: 25),
                          child: Column(
                            children: [

                              Text(
                                index==1?"20% off":"10% off",
                                style: TextStyle(
                                    color: index==1?Constants.COLOR_SECONDARY:Constants.COLOR_PRIMARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 34),
                              ),
                              Text(
                                index==1?"Rent2Park Christmas Special":"Earned from friends Referral",
                                style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: LineSeparator(),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  RawMaterialButton(
                                      elevation: 4,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      constraints: BoxConstraints(
                                          minWidth: 110, minHeight: 30),
                                      onPressed: () {},
                                      fillColor: Constants.COLOR_PRIMARY,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text("Redeem",
                                            style: const TextStyle(
                                                color:
                                                Constants.COLOR_ON_PRIMARY,
                                                fontFamily:
                                                Constants.GILROY_BOLD,
                                                fontSize: 14)),
                                      )),
                                  Spacer(),
                                  Text(
                                    "Expiry: Oct 23, 2022",
                                    style: TextStyle(
                                        color: Constants.COLOR_PRIMARY,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    );


                  }),

              // second tab bar view widget
              ListView.builder(
                padding: EdgeInsets.only(top: 5),
                  shrinkWrap: true,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Image(
                            image: AssetImage('assets/coupon_bg.png'),
                            height: 162,
                            width: size.width,
                            fit : BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 40,right: 40,top: 30),
                          child: Column(
                            children: [
                              Text(
                                index%2==0?"10% Off":"Friend Referral Points",
                                style: TextStyle(
                                    color: Constants.COLOR_PRIMARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 28),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              Text(
                                "Added on Jul 30, 2022",
                                style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: LineSeparator(),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible: index%2==0,
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "Coupon Id: 7869004",
                                        style: TextStyle(
                                            color: Constants.COLOR_BLACK_200,
                                            fontFamily: Constants.GILROY_REGULAR,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          index%2==0?"- 50":"+ 50",
                                          style: TextStyle(
                                              color: index%2==0?Constants
                                                  .COLOR_ERROR:Constants
                                                  .COLOR_SECONDARY_VARIANT,
                                              fontFamily:
                                              Constants.GILROY_BOLD,
                                              fontSize: 22),
                                        ),

                                        Text(
                                          index%2==0?"No Expiration Date":"Expires: Oct 23, 2022",
                                          style: TextStyle(
                                              color: Constants.COLOR_BLACK_200,
                                              fontFamily:
                                              Constants.GILROY_REGULAR,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    );


                  }),
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double max;
  final double current;
  final Color color;

  const ProgressBar(
      {Key? key,
      required this.max,
      required this.current,
      this.color = Constants.COLOR_ON_SECONDARY})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        var x = boxConstraints.maxWidth;
        var percent = (current / max) * x;
        return Stack(
          children: [
            Container(
              width: x,
              height: 14,
              decoration: BoxDecoration(
                color: Color(0xFF93ac98),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: percent,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ],
        );
      },
    );
  }
}
