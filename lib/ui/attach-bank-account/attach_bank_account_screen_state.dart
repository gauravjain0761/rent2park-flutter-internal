import 'package:equatable/equatable.dart';


import '../../data/meta_data.dart';

class AttachBankAccountScreenState extends Equatable {
  final String accountHolderNameError;
  final String routingNumberError;
  final DataEvent bankAccountData;
  final String accountNumberError;

  const AttachBankAccountScreenState(
      {required this.accountHolderNameError, required this.routingNumberError, required this.accountNumberError, required this.bankAccountData});

  AttachBankAccountScreenState.initial(DataEvent dataEvent)
      : this(accountHolderNameError: '', routingNumberError: '', accountNumberError: '', bankAccountData: dataEvent);

  AttachBankAccountScreenState copyWith(
          {String? accountHolderNameError, String? routingNumberError, String? accountNumberError, DataEvent? bankAccountData}) =>
      AttachBankAccountScreenState(
          accountHolderNameError: accountHolderNameError ?? this.accountHolderNameError,
          routingNumberError: routingNumberError ?? this.routingNumberError,
          accountNumberError: accountNumberError ?? this.accountNumberError,
          bankAccountData: bankAccountData ?? this.bankAccountData);

  @override
  List<Object> get props => [accountHolderNameError, accountNumberError, routingNumberError, bankAccountData];

  @override
  bool get stringify => true;
}
