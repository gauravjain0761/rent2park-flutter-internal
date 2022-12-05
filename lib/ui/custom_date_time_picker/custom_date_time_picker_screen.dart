import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/light_app_bar.dart';
import 'custom_date_time_picker_screen_bloc.dart';
import 'custom_date_timer_picker_screen_state.dart';

class CustomDateTimePickerScreen extends StatelessWidget {
  static const String route = 'custom_date_time_picker_screen_route';

  final DateTime minDatetime;

  const CustomDateTimePickerScreen({required this.minDatetime});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd hh:mm a');
    final timeFormatter = DateFormat('hh:mm a');
    final size = MediaQuery.of(context).size;
    final bloc = context.read<CustomDateTimePickerScreenBloc>();
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
          bottom: !Platform.isIOS,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Constants.COLOR_PRIMARY,
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: BlocBuilder<CustomDateTimePickerScreenBloc, CustomDateTimePickerScreenState>(
                  buildWhen: (previous, current) => previous.currentDateTime != current.currentDateTime,
                  builder: (_, state) => Text(dateFormatter.format(state.currentDateTime),
                      style: TextStyle(color: Constants.COLOR_ON_PRIMARY, fontFamily: Constants.GILROY_REGULAR, fontSize: 18)),
                ),
              ),
              Expanded(
                  child:
                      Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: size.height * 0.6,
                  child: SfDateRangePickerTheme(
                    data: SfDateRangePickerThemeData(
                        todayHighlightColor: Constants.COLOR_PRIMARY,
                        selectionTextStyle:
                            const TextStyle(color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_REGULAR, fontSize: 15),
                        selectionColor: Colors.transparent,
                        viewHeaderTextStyle:
                            const TextStyle(color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_REGULAR, fontSize: 15),
                        viewHeaderBackgroundColor: Constants.COLOR_SURFACE),
                    child: BlocBuilder<CustomDateTimePickerScreenBloc, CustomDateTimePickerScreenState>(
                      buildWhen: (previous, current) => previous.currentDateTime != current.currentDateTime,
                      builder: (_, state) => SfDateRangePicker(
                          monthViewSettings: const DateRangePickerMonthViewSettings(dayFormat: 'EEE'),
                          monthFormat: 'MMMM',
                          onSelectionChanged: (args) {
                            if (args.value is DateTime && !_isPreviousDate(args.value as DateTime, minDatetime))
                              bloc.handleDateSelection(args.value as DateTime);
                          },
                          initialDisplayDate: minDatetime,
                          selectionTextStyle: TextStyle(color: Colors.black),
                          cellBuilder: (context, cellDetails) {
                            late TextStyle textStyle;
                            if (_isPreviousDate(cellDetails.date, minDatetime)) {
                              textStyle =
                                  const TextStyle(color: Color(0xffAAAAAA), fontFamily: Constants.GILROY_REGULAR, fontSize: 16);
                            } else if (_isSelectedDay(cellDetails.date, state.currentDateTime))
                              textStyle = const TextStyle(
                                  color: Constants.COLOR_ON_SECONDARY, fontSize: 16, fontFamily: Constants.GILROY_REGULAR);
                            else
                              textStyle = const TextStyle(
                                  color: Constants.COLOR_ON_SURFACE, fontSize: 16, fontFamily: Constants.GILROY_REGULAR);
                            return Container(
                                alignment: Alignment.center,
                                child: Text(cellDetails.date.day.toString(), style: textStyle),
                                decoration: _isSelectedDay(cellDetails.date, state.currentDateTime)
                                    ? const BoxDecoration(shape: BoxShape.circle, color: Constants.COLOR_SECONDARY)
                                    : null);
                          },
                          allowViewNavigation: false,
                          view: DateRangePickerView.month,
                          selectionMode: DateRangePickerSelectionMode.single,
                          headerStyle: const DateRangePickerHeaderStyle(
                              backgroundColor: Constants.COLOR_SURFACE,
                              textStyle:
                                  TextStyle(color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_BOLD, fontSize: 25),
                              textAlign: TextAlign.center),
                          showNavigationArrow: true),
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(AppText.TIME,
                      style: const TextStyle(color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_REGULAR, fontSize: 20)),
                  const SizedBox(width: 25),
                  BlocBuilder<CustomDateTimePickerScreenBloc, CustomDateTimePickerScreenState>(builder: (_, state) {
                    return GestureDetector(
                      onTap: () async {
                        DatePicker.showTime12hPicker(context, currentTime: bloc.lastSelectionDatetime,
                            onConfirm: (DateTime? datetime) {
                          if (datetime == null) return;
                          bloc.handleTimeSelection(datetime);
                        },
                            theme: DatePickerTheme(
                                itemStyle: const TextStyle(
                                    color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 15),
                                doneStyle: const TextStyle(
                                    color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_BOLD, fontSize: 15),
                                cancelStyle: const TextStyle(
                                    color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_BOLD, fontSize: 15)));
                      },
                      child: Text(timeFormatter.format(state.currentDateTime),
                          style: const TextStyle(
                              color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_REGULAR, fontSize: 20)),
                    );
                  })
                ])
              ])),
              Container(
                decoration:
                    BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Constants.COLOR_GREY, width: 0.5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            alignment: Alignment.center,
                            color: Constants.COLOR_GREY.withOpacity(0.1),
                            padding: EdgeInsets.symmetric(vertical: Platform.isIOS ? 21 : 13),
                            child: Text(AppText.CANCEL.toUpperCase(),
                                style:
                                    TextStyle(color: Constants.COLOR_PRIMARY, fontFamily: Constants.GILROY_LIGHT, fontSize: 17)),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, bloc.state.currentDateTime),
                          child: Container(
                            alignment: Alignment.center,
                            color: Constants.COLOR_PRIMARY,
                            padding: EdgeInsets.symmetric(vertical: Platform.isIOS ? 21 : 13),
                            child: Text(AppText.SELECT.toUpperCase(),
                                style: TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY, fontFamily: Constants.GILROY_LIGHT, fontSize: 17)),
                          ),
                        ))
                  ],
                ),
              )
            ],
          )),
    );
  }

  bool _isPreviousDate(DateTime datetime, DateTime otherDatetime) {
    final newDatetime = DateTime(datetime.year, datetime.month, datetime.day);
    final newOtherDatetime = DateTime(otherDatetime.year, otherDatetime.month, otherDatetime.day);
    return newDatetime.compareTo(newOtherDatetime) == -1;
  }

  bool _isSelectedDay(DateTime datetime, DateTime otherDatetime) =>
      datetime.day == otherDatetime.day && datetime.month == otherDatetime.month && datetime.year == otherDatetime.year;
}
