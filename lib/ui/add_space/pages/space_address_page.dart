import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/directions.dart';

import '../../../data/meta_data.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../add_space_screen_bloc.dart';


class SpaceAddressPage extends StatelessWidget {
  final PageStorageKey<String> key;

  const SpaceAddressPage({required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = context.read<AddSpaceScreenBloc>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(AppText.WHERE_IS_YOUR_PARKING_SPACE_QUESTION_MARK,
              style: TextStyle(
                  color: Constants.COLOR_ON_SURFACE,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 19)),
          const SizedBox(height: 5),
          Text(AppText.COUNTRY,
              style: TextStyle(
                  color: Constants.colorDivider,
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 16)),
          const SizedBox(height: 15),
          InkWell(
            onTap: () => showCountryPicker(
                context: context,
                onSelect: (country) =>
                    bloc.updateCountry(country.name, country.countryCode),
                countryListTheme: CountryListThemeData(
                    inputDecoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search Country...',
                        hintStyle: TextStyle(
                            color: Constants.COLOR_ON_SURFACE.withOpacity(0.4),
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 14)),
                    backgroundColor: Constants.COLOR_SURFACE,
                    textStyle: TextStyle(color: Constants.COLOR_ON_SURFACE))),
            child: Container(
              width: size.width - 40,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border:
                      Border.all(color: Constants.colorDivider, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<AddSpaceScreenBloc, dynamic>(
                  // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                      buildWhen: (previous, current) =>
                          previous.address.country != current.address.country,
                      builder: (_, state) => Text(state.address.country,
                          style: TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontFamily: Constants.GILROY_REGULAR,
                              fontSize: 17))),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: Constants.COLOR_ON_SURFACE, size: 20)
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(AppText.WHAT_IS_THE_ADDRESS_OF_YOUR_PARKING_SPACE,
              style: TextStyle(
                  color: Constants.COLOR_ON_SURFACE,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 19)),
          const SizedBox(height: 5),
          Text(AppText.ONLY_SHOWN_WHEN_DRIVERS_BOOK_YOUR_WORK_SPACE,
              style: TextStyle(
                  color: Constants.colorDivider,
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 16)),
          const SizedBox(height: 15),
          InkWell(
            onTap: () async {
              final predication = await PlacesAutocomplete.show(

                 decoration: new InputDecoration(
                fillColor: Constants.COLOR_BLACK_200,
                border: InputBorder.none,
                hintStyle: TextStyle(fontFamily: Constants.GILROY_MEDIUM,color: Constants.COLOR_BACKGROUND),
                hintText: "Search Space",
                filled: true,
              ),
                  context: context,
                  apiKey: Constants.GOOGLE_MAP_PLACES_API_KEY,
                  mode: Mode.fullscreen,
                  language: 'en',
                  types: [],
                  radius: 10000000,
                  strictbounds: false,


                  components: [
                    Component(Component.country, bloc.state.address.countryCode)
                  ]);
              if (predication == null) return;
              bloc.handlePredication(predication);
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
                alignment: Alignment.centerLeft,
                height: 45,
                width: size.width - 40,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border:
                        Border.all(color: Constants.colorDivider, width: 0.5)),
                child: BlocBuilder<AddSpaceScreenBloc, dynamic>(
                    // child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                  builder: (_, state) {
                    final addressEvent = state.address.parkingSpaceData;
                    if (addressEvent is Initial || addressEvent is Error)
                      return const Text(AppText.ADDRESS_DOT_DOT,
                          style: TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontFamily: Constants.GILROY_REGULAR,
                              fontSize: 14));
                    else if (addressEvent is Loading)
                      return Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Constants.COLOR_PRIMARY)));
                    final data = (addressEvent as Data).data;
                    return Text(data as String,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_SURFACE,
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 14));
                  },
                )),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<AddSpaceScreenBloc, dynamic>(
                  // child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                  buildWhen: (previous, current) =>
                      previous.address.parkingSpaceError !=
                      current.address.parkingSpaceError,
                  builder: (_, state) =>
                      state.address.parkingSpaceError.isNotEmpty
                          ? Text(state.address.parkingSpaceError,
                              style: const TextStyle(
                                  color: Constants.COLOR_ERROR,
                                  fontFamily: Constants.GILROY_LIGHT,
                                  fontSize: 11))
                          : const SizedBox())),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}
