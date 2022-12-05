import 'package:equatable/equatable.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

class PaymentScreenState extends Equatable {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final bool isShowBack;

  PaymentScreenState(
      {required this.cardHolderName,
      required this.cardNumber,
      required this.expiryDate,
      required this.cvv,
      required this.isShowBack});

  PaymentScreenState.initial() : this(cardHolderName: '', cardNumber: '', expiryDate: '', cvv: '', isShowBack: false);

  PaymentScreenState copyWith(
      {String? cardNumber, String? expiryDate, String? cvv, String? cardHolderName, bool? isShowBack, CardType? cardType}) {
    return PaymentScreenState(
        cardHolderName: cardHolderName ?? this.cardHolderName,
        cardNumber: cardNumber ?? this.cardNumber,
        expiryDate: expiryDate ?? this.expiryDate,
        cvv: cvv ?? this.cvv,
        isShowBack: isShowBack ?? this.isShowBack);
  }

  @override
  List<Object?> get props => [cardNumber, expiryDate, cvv, cardHolderName, isShowBack];

  @override
  bool get stringify => true;
}
