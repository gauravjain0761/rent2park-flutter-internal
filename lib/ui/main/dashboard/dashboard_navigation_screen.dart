import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rent2park/extension/collection_extension.dart';

import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../checkout-earning/checkout_earnings_screen.dart';
import '../../common/single_error_try_again_widget.dart';
import '../../common/single_review_item_widget.dart';
import '../main_screen_bloc.dart';
import 'dashboard_navigation_bloc.dart';

class DashboardNavigationScreen extends StatelessWidget {
  final PageStorageKey key;

  const DashboardNavigationScreen({required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _bookingAndEarningTextStyle = TextStyle(
        color: Constants.COLOR_ON_PRIMARY,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 15);
    final scaffoldState = Scaffold.of(context);
    final bloc = context.read<DashboardNavigationBloc>();
    bloc.dashboardDetails();
    final size = MediaQuery.of(context).size;
    return WillPopScope(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Constants.COLOR_PRIMARY,
              height: kToolbarHeight,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          scaffoldState.openDrawer();
                        },
                        icon: const Icon(Icons.menu_rounded),
                        color: Constants.COLOR_ON_PRIMARY),
                  ),
                  const Align(
                      alignment: Alignment.center,
                      child: Text(AppText.DASHBOARD,
                          style: TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 17))),
                ],
              ),
            ),

            Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<DashboardNavigationBloc, DataEvent>(
                            builder: (_, dataEvent) {
                          if (dataEvent is Initial)
                            return const SizedBox();
                          else if (dataEvent is Loading)
                            return Padding(
                                padding: EdgeInsets.only(
                                    top: (size.height / 2) - kToolbarHeight),
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
                          final response = (dataEvent as Data).data as DashboardDetailsResponse;
                          final totalRatings = response.reviews.count<Reviews>((element) => element.rating) / response.reviews.length;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 30,
                                      height: 10,
                                      color: Constants.COLOR_SECONDARY),
                                  const SizedBox(width: 3),
                                  const Text(AppText.TOTAL_EARNING,
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_SURFACE,
                                          fontFamily: Constants.GILROY_LIGHT,
                                          fontSize: 12))
                                ],
                              ),

                              const SizedBox(height: 10),
                              response.monthlyDataList.isNotEmpty
                                  ? SizedBox(
                                      width: size.width - 15,
                                      height: 200,
                                      child: LineChart(yearlySampleData(
                                          response.monthlyDataList,
                                          response.earning.toDouble())))
                                  : const SizedBox(),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                      width: size.width / 2,
                                      color: Constants.COLOR_PRIMARY,
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Text(response.bookings.toString(),
                                              style: _bookingAndEarningTextStyle),
                                          const Text(AppText.MY_BOOKINGS,
                                              style: _bookingAndEarningTextStyle),
                                        ],
                                      )),
                                  Container(
                                    width: size.width / 2,
                                    color: Constants.COLOR_SECONDARY,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Text(
                                            '\$${response.earning.toStringAsFixed(2)}',
                                            style: _bookingAndEarningTextStyle),
                                        const Text(AppText.MY_EARNINGS,
                                            style: _bookingAndEarningTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(AppText.REVIEWS,
                                            style: TextStyle(
                                                color:
                                                    Constants.COLOR_ON_SURFACE,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                fontSize: 15)),
                                        Row(children: [
                                          RatingBar.builder(
                                              initialRating: totalRatings,
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              itemSize: 20,
                                              ignoreGestures: true,
                                              unratedColor:
                                                  Constants.colorDivider,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemBuilder: (context, index) =>
                                                  const Icon(Icons.star,
                                                      color: Constants
                                                          .COLOR_SECONDARY,
                                                      size: 20),
                                              onRatingUpdate: (rate) {}),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8.0),
                                              child: Text('$totalRatings',
                                                  style: TextStyle(
                                                      color:
                                                          Constants.COLOR_GREY,
                                                      fontFamily: Constants
                                                          .GILROY_REGULAR,
                                                      fontSize: 14)))
                                        ])
                                      ])),
                              const SizedBox(height: 10),
                              response.reviews.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: response.reviews.length,
                                          itemBuilder: (context, index) {
                                            return SingleReviewListTileWidget(
                                                review:
                                                    response.reviews[index]);
                                          }),
                                    )
                                  : Center(
                                      child: const Text(
                                        'NO REVIEWS YET!',
                                        style: TextStyle(
                                            fontFamily: Constants.GILROY_BOLD),
                                      ),
                                    )
                            ],
                          );
                        })
                      ],
                    ))),

            BlocBuilder<DashboardNavigationBloc, DataEvent>(
              builder: (_, dataEvent) => dataEvent is Data
                  ? SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: RawMaterialButton(
                          onPressed: () => Navigator.pushNamed(context, CheckoutEarningsScreen.route),
                          fillColor: Constants.COLOR_PRIMARY,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Image(
                                  image: AssetImage('assets/wallet.png'),
                                  color: Constants.COLOR_ON_PRIMARY,
                                  height: 20,
                                  width: 20),
                              SizedBox(width: 5),
                              Text(
                                AppText.CASH_OUT,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_LIGHT,
                                    fontSize: 14),
                              )
                            ],
                          )),
                    )
                  : const SizedBox(),
            )
          ],
        ),
        onWillPop: () async {
          scaffoldState.isDrawerOpen
              ? Navigator.pop(context)
              : BlocProvider.of<MainScreenBloc>(context).updatePageIndex(0);
          return false;
        });
  }

  LineChartData yearlySampleData(
      List<MonthlyData> monthlyDataList, double earnings) {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingVerticalLine: (_) => FlLine(strokeWidth: 0.3),
          getDrawingHorizontalLine: (_) => FlLine(strokeWidth: 0.3)),
      titlesData: FlTitlesData(
          topTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value, _) => const TextStyle(
                  color: Constants.COLOR_BLACK,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 10),
              margin: 10,
              getTitles: (double index) =>
                  monthlyDataList[index.toInt()].month),
          leftTitles: SideTitles(
              getTitles: (value) => '\$ ${value.toInt()}',
              interval: (earnings + 100) / 10,
              showTitles: true,
              getTextStyles: (value, _) => const TextStyle(
                  color: Constants.COLOR_BLACK,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 8),
              margin: 10)),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: const BorderSide(color: Constants.COLOR_BLACK, width: 0.5),
            left: const BorderSide(color: Constants.COLOR_BLACK, width: 0.5),
            top: const BorderSide(color: Constants.COLOR_BLACK, width: 0.5),
            right: const BorderSide(color: Constants.COLOR_BLACK, width: 0.5),
          )),
      minY: 0,
      maxY: monthlyDataList.map((e) => e.earning.toDouble()).reduce(max) + 100,
      lineBarsData: monthlyGraphData(monthlyDataList),
    );
  }
}

List<LineChartBarData> monthlyGraphData(List<MonthlyData> monthlyDataList) {
  return [
    LineChartBarData(
      spots: mapIndexed(monthlyDataList, (index, item) {
        return FlSpot(
            index.toDouble(), (item as MonthlyData).earning.toDouble());
      }).toList(),
      colors: const [Constants.COLOR_SECONDARY],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    ),
  ];
}
