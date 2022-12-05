import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:rent2park/extension/primitive_extension.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/single_error_try_again_widget.dart';
import '../payment/payment_screen.dart';
import 'all_cards_screen_bloc.dart';


class AllCardsScreen extends StatelessWidget {

  static const String route = 'all_cards_screen_route';

  const AllCardsScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AllCardsScreenBloc>();
    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            backgroundColor: Constants.COLOR_PRIMARY,
            leading: IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => Navigator.pop(context),
                splashRadius: 25,
                color: Constants.COLOR_ON_PRIMARY),
            title: const Text(AppText.MANAGE_CARDS,
                style: TextStyle(
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18,
                    color: Constants.COLOR_ON_PRIMARY))),
        body: BlocBuilder<AllCardsScreenBloc, DataEvent>(builder: (_, dataEvent) {
          if (dataEvent is Initial || dataEvent is Loading)
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          else if (dataEvent is Error) {
            return Center(
                child:
                    SingleErrorTryAgainWidget(onClick: () => bloc.myCards()));
          } else if (dataEvent is Data) {
            final paymentCards = dataEvent.data as List<dynamic>;
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: paymentCards.length,
                itemBuilder: (_, index) {
                  final paymentCardItem = paymentCards[index];
                  if (paymentCardItem is String)
                    return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                                  context, PaymentScreen.route) as bool? ??
                              false;
                          if (result) bloc.myCards();
                        },
                        child: const _AddNewCardItem());
                  final paymentCard = paymentCardItem as PaymentCard;
                  return bloc.isForSelection
                      ? GestureDetector(
                          onTap: () => Navigator.pop(context, paymentCard),
                          child: _SingleCardItem(
                              isInitialItem: index == 0,
                              paymentCard: paymentCard))
                      : _SingleCardItem(
                          isInitialItem: index == 0, paymentCard: paymentCard);
                });
          }
          return const SizedBox();
        }));
  }
}

class _SingleCardItem extends StatelessWidget {
  final bool isInitialItem;
  final PaymentCard paymentCard;

  const _SingleCardItem({required this.isInitialItem, required this.paymentCard});

  @override
  Widget build(BuildContext context) {
    String cardAsset = 'icons/visa.png';
    cardAsset = CardTypeIconAsset[paymentCard.brand.cardBrand.brandName] ?? 'icons/visa.png';

    return Container(
      margin:
          EdgeInsets.only(top: isInitialItem ? 20 : 15, left: 25, right: 25),
      decoration: BoxDecoration(
          color: Constants.COLOR_SECONDARY,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: const <double>[0.1, 0.4, 0.7, 0.9],
            colors: <Color>[
              Color(0xff1b447b).withOpacity(1),
              Color(0xff1b447b).withOpacity(0.97),
              Color(0xff1b447b).withOpacity(0.90),
              Color(0xff1b447b).withOpacity(0.86)
            ],
          )),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: Image.asset(cardAsset,
                    package: 'flutter_credit_card', width: 36, height: 36)),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.center,
                child: Text('**** **** **** ${paymentCard.last4}',
                    style: const TextStyle(
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 19,
                        color: Constants.COLOR_SURFACE))),
            const SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.CARD_HOLDER.toUpperCase(),
                          style: const TextStyle(
                              color: Constants.COLOR_SURFACE,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(paymentCard.name,
                          style: const TextStyle(
                              color: Constants.COLOR_SURFACE,
                              fontFamily: Constants.GILROY_REGULAR,
                              fontSize: 14)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppText.EXPIRES.toUpperCase(),
                          style: const TextStyle(
                              color: Constants.COLOR_SURFACE,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(
                          '${paymentCard.expiryMonth}/${paymentCard.expiryYear.substring(2)}',
                          style: const TextStyle(
                              color: Constants.COLOR_SURFACE,
                              fontFamily: Constants.GILROY_REGULAR,
                              fontSize: 14)),
                    ],
                  )
                ])
          ]),
    );
  }
}

class _AddNewCardItem extends StatelessWidget {
  const _AddNewCardItem();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 150,
      margin: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 25),
      width: size.width - 50,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 0.8, color: Color(0xffB5B5B6)),
          color: const Color(0xffF4F4F4)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Image(image: AssetImage('assets/add_card_icon.png')),
          Text(AppText.ADD_NEW_CARD,
              style: TextStyle(
                  color: Color(0xffB5B5B6),
                  fontSize: 15,
                  fontFamily: Constants.GILROY_REGULAR))
        ],
      ),
    );
  }
}
