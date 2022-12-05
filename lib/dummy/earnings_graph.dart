import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:rent2park/util/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EarningData {
  final num earning;
  final num loss;
  final String month;

  const EarningData(this.earning, this.loss, this.month);
}

class EarningsGraph extends StatefulWidget {
  const EarningsGraph({Key? key}) : super(key: key);

  @override
  State<EarningsGraph> createState() => _EarningsGraphState();
}

class _EarningsGraphState extends State<EarningsGraph> {
  late List<EarningData> _chartData;

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior =  TooltipBehavior(enable: true);
    super.initState();
  }

  List<EarningData> getChartData() {
    const List<EarningData> chartData = [
      EarningData(0, 400, "Sept "),
      EarningData(0, 400, "Sept W2"),
      EarningData(0, 400, "Sept W3"),
      EarningData(0, 400, "Sept W4"),

      EarningData(0, 400, "Oct "),
      EarningData(0, 400, "Oct W2"),
      EarningData(0, 400, "Oct W3"),
      EarningData(0, 400, "Oct W4"),

      EarningData(0, 400, "Nov "),
      EarningData(0, 400, "Nov W2"),
      EarningData(0, 400, "Nov W3"),
      EarningData(0, 400, "Nov W4"),
    ];
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SfCartesianChart(
         tooltipBehavior: _tooltipBehavior,
        plotAreaBorderWidth: 0,
        primaryYAxis: NumericAxis(
            maximum: 400,
            majorTickLines: const MajorTickLines(width: 0),
            minorTickLines: const MinorTickLines(width: 0),
            labelStyle:TextStyle(
                color: Constants.COLOR_GREY,
                fontFamily: Constants.GILROY_MEDIUM,
                fontSize: 12),
            axisLine: const AxisLine(width: 0),
            numberFormat: NumberFormat.simpleCurrency(),
            plotBands: <PlotBand>[
              PlotBand(
                  isVisible: true,
                  start: 200,
                  end: 200,
                  borderWidth: 0.6,
                  borderColor: Colors.grey)
            ],
            majorGridLines: const MajorGridLines(width: 0),
            opposedPosition: true),
        primaryXAxis: CategoryAxis(
            interval: 4,
            majorGridLines: const MajorGridLines(width: 0.0),
            majorTickLines: const MajorTickLines(width: 0),
            minorTickLines: const MinorTickLines(width: 0),
            labelStyle: TextStyle(
                color: Constants.COLOR_BLACK,
                fontFamily: Constants.GILROY_MEDIUM,
                fontSize: 14)),
        series: <ChartSeries>[
          StackedColumnSeries<EarningData, String>(
            animationDuration: 4000,
              enableTooltip: true,

              dataSource: _chartData,
              width: 0.5,
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Constants.COLOR_SECONDARY, Constants.COLOR_PRIMARY]),
              xValueMapper: (exp, _) => exp.month.toString(),
              yValueMapper: (exp, _) => exp.earning),
          StackedColumnSeries<EarningData, String>(
              enableTooltip: true,
              width: 0.5,
              animationDuration: 4000,
              color: Colors.grey.shade300,
              dataSource: _chartData,
              xValueMapper: (exp, _) => exp.month.toString(),
              yValueMapper: (exp, _) => exp.loss),
        ],
      ),
    );
  }
}
