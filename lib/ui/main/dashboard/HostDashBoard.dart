import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/extension/collection_extension.dart';
import 'package:rent2park/ui/depositsAndTranfer/DepositAndTransfer.dart';
import 'package:rent2park/util/SizeConfig.dart';
import '../../../../dummy/earnings_graph.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../common/single_error_try_again_widget.dart';
import '../../wallet/Wallet.dart';
import 'dashboard_navigation_bloc.dart';

class HostDashBoard extends StatefulWidget {
  @override
  _HostProfile createState() => _HostProfile();
}

class _HostProfile extends State<HostDashBoard> {
  var size;

  User? user;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    final bloc = context.read<DashboardNavigationBloc>();
    bloc.dashboardDetails();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(AppText.HOST_DASHBOARD,
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 17)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Constants.COLOR_ON_PRIMARY),
        actions: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(context, WalletScreen.route);
              // _handleBankAccountManageClick(_profileBloc);
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
            },
            child: Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: SvgPicture.asset(
                  "assets/bank.svg",
                  width: 22,
                )),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: BlocBuilder<DashboardNavigationBloc, DataEvent>(
              builder: (_, dataEvent) {
            if (dataEvent is Initial)
              return const SizedBox();
            else if (dataEvent is Loading)
              return Padding(
                  padding:
                      EdgeInsets.only(top: (size.height / 2) - kToolbarHeight),
                  child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()));
            else if (dataEvent is Error)
              return Padding(
                padding: EdgeInsets.only(
                    top: (size.height / 2) - (kToolbarHeight * 2)),
                child: SingleErrorTryAgainWidget(
                    onClick: () => bloc.dashboardDetails()),
              );
            final response =
                (dataEvent as Data).data as DashboardDetailsResponse;

            final totalRatings =
                response.reviews.count<Reviews>((element) => element.rating) /
                    response.reviews.length;

            return CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: <Widget>[
                  SliverToBoxAdapter(child: headView(totalRatings, response)),
                  SliverToBoxAdapter(
                      child: SizedBox(
                          height: size.height * 0.18, child: EarningsGraph())),
                  SliverToBoxAdapter(child: earningsAndBookingsView()),
                  SliverToBoxAdapter(child: usersList(response.reviews)),
                ]);
          }),
        ),
      ),
    );
  }

  Widget headView(double totalRatings, DashboardDetailsResponse response) {
    var userName = "${user?.firstName[0]}${user?.lastName[0]}";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),

        user!.image.toString().isEmpty ||
                user?.image == "https://dev.rent2park.com/"
            ? Container(
                width: 140,
                height: 140,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Constants.COLOR_SECONDARY, shape: BoxShape.circle),
                child: Text(userName,
                    style: const TextStyle(
                        color: Constants.COLOR_ON_SECONDARY,
                        fontSize: 32,
                        fontFamily: Constants.GILROY_SEMI_BOLD)))
            : ClipOval(
                child: CachedNetworkImage(
                    imageUrl: user!.image!,
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                      width: 140,
                      height: 140,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Constants.COLOR_SECONDARY, shape: BoxShape.circle),
                      child: Text(userName,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_SECONDARY,
                              fontSize: 32,
                              fontFamily: Constants.GILROY_SEMI_BOLD))),
                )),
        /*     Hero(
          tag: "profile_pic",
          child: ClipOval(
            child: Image.asset('assets/man.png',
                width: size.width * .38, fit: BoxFit.fitWidth),
          ),
        ),*/
        SizedBox(
          height: 5,
        ),
        Text("Hello ${user!.firstName}",
            style: TextStyle(
                color: Constants.COLOR_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 32)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RatingBar.builder(
              initialRating:
                  totalRatings.toString() == "NaN" ? 0 : totalRatings,
              direction: Axis.horizontal,
              itemSize: 20,
              unratedColor: Constants.colorDivider,
              allowHalfRating: false,
              itemCount: 5,
              updateOnDrag: false,
              itemBuilder: (context, index) => const Icon(Icons.star,
                  size: 20, color: Constants.COLOR_SECONDARY),
              onRatingUpdate: (rating) {},
            ),
            SizedBox(
              width: 15,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                  totalRatings.toString() == "NaN"
                      ? ""
                      : totalRatings.toString(),
                  style: TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontFamily: Constants.GILROY_MEDIUM,
                      fontSize: 14)),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text("\$${response.earning}",
            style: TextStyle(
                color: Constants.COLOR_ON_SURFACE,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 46)),
        Text(AppText.PENDING_FUND,
            style: TextStyle(
                color: Constants.COLOR_SECONDARY_VARIANT,
                fontFamily: Constants.GILROY_MEDIUM,
                fontSize: 14)),
        SizedBox(
          height: 5,
        ),
        Hero(
          tag: "bank_cards",
          child: RawMaterialButton(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              constraints:
                  BoxConstraints(minWidth: size.width - 120, minHeight: 40),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DepositAndTransfer()));
              },
              fillColor: Constants.COLOR_PRIMARY,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(AppText.DEPOSIT_AND_FUND,
                    style: const TextStyle(
                        color: Constants.COLOR_ON_PRIMARY,
                        fontFamily: Constants.GILROY_MEDIUM,
                        fontSize: 16)),
              )),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget earningsAndBookingsView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: size.width,
              height: size.height * .1,
              decoration: BoxDecoration(
                color: Constants.COLOR_SECONDARY,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Text("\$0.00 / \$0.00",
                      style: const TextStyle(
                          color: Constants.COLOR_BACKGROUND,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 18)),
                  Text("Earnings",
                      style: const TextStyle(
                          color: Constants.COLOR_BLACK,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 14)),
                  Text("(Month/Total)",
                      style: const TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 14)),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
            flex: 1,
            child: Container(
              width: size.width,
              height: size.height * .1,
              decoration: BoxDecoration(
                color: Constants.COLOR_PRIMARY,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Text("0 / 0",
                      style: const TextStyle(
                          color: Constants.COLOR_BACKGROUND,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 18)),
                  Text("Bookings",
                      style: const TextStyle(
                          color: Constants.COLOR_BLACK,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 14)),
                  Text("(Month/Total)",
                      style: const TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 14)),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget usersList(List<Reviews> reviews) {
    return reviews.isEmpty
        ? Container(
            height: getProportionateScreenHeight(150, size.height),
            child: Center(
              child: Text(
                "No Reviews yet",
                style: TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_SEMI_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: reviews.length,
            itemBuilder: (_, index) {
              var reviewData = reviews[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(5),
                child: Container(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 14.0, right: 10),
                              child: ClipOval(
                                child: Image.asset('assets/man.png',
                                    width: size.width * .1,
                                    fit: BoxFit.fitWidth),
                              ),
                            ),
                            Wrap(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reviewData.userName,
                                        style: const TextStyle(
                                            color: Constants.COLOR_PRIMARY,
                                            fontFamily: Constants.GILROY_MEDIUM,
                                            fontSize: 16)),
                                    RatingBar.builder(
                                      initialRating: 4,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      itemSize: 20,
                                      unratedColor: Constants.colorDivider,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemBuilder: (context, index) =>
                                          const Icon(Icons.star,
                                              size: 20,
                                              color: Constants.COLOR_SECONDARY),
                                      onRatingUpdate: (rating) {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Text("13th April, 2021",
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 15)),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                              "In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate",
                              style: const TextStyle(
                                  color: Constants.COLOR_ON_SURFACE,
                                  fontFamily: Constants.GILROY_REGULAR,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
  }

  void getUser() async {
    user = await SharedPreferenceHelper.instance.user();
  }
}
