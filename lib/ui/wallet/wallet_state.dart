import 'package:equatable/equatable.dart';
import 'package:rent2park/data/backend_responses.dart';
import '../../util/Resource.dart';

class WalletState extends Equatable {


  final Object data;
  final Resource status;
  final Resource bankAccountStatus;
  final Object bankAccount;
  final List<PaymentCard> myCards;

  WalletState(
      {Object? data,
        this.status = Resource.initial,
        this.bankAccountStatus = Resource.initial,
        Object? bankAccount,
        List<PaymentCard>? myCards,

      })
      : data = data ?? "",
        bankAccount = bankAccount??"",
        myCards = myCards ?? []
  ;

  WalletState copyWith({
    Resource? status,
    Resource? bankAccountStatus,
    Object? bankAccount,
    List<PaymentCard>? myCards,
  }) {
    return WalletState(

        status: status ?? this.status,
        bankAccountStatus: status ?? this.bankAccountStatus,
        bankAccount: bankAccount ?? this.bankAccount,
        myCards: myCards ?? this.myCards,
    );
  }

  @override
  List<Object> get props => [data, status, bankAccount,myCards];


  @override
  bool get stringify => true;

}


