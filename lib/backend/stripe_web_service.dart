import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../data/backend_responses.dart';
import '../data/exception.dart';

class StripeWebService {
  static const String _BASE_URL = 'https://api.stripe.com/v1/';

  // static const String _TESTING_SECRET_KEY =
  //     'sk_test_51JPC88LxddZMdp9zHaqi2FY08SXE25SszoLPihDIM3vUHCjsbp8Msj9AD6rXcF96zxfUwmEQJ8QnUmjrxC65QNkd003ajRcecT';
  static const String _TESTING_SECRET_KEY =
      'sk_test_51JPC88LxddZMdp9zHaqi2FY08SXE25SszoLPihDIM3vUHCjsbp8Msj9AD6rXcF96zxfUwmEQJ8QnUmjrxC65QNkd003ajRcecT';

  static StripeWebService? _instance;

  StripeWebService._();

  static StripeWebService instance() {
    _instance ??= StripeWebService._();
    return _instance!;
  }

  final HttpClient _httpClient = HttpClient();

  Future<String> createCustomer(String name, String email,
      [String? phone]) async {
    final request =
        await _httpClient.postUrl(Uri.parse(_BASE_URL + 'customers'));
    final bodyRequest = phone == null
        ? utf8.encode('name=${Uri.encodeQueryComponent(name)}&email=${Uri.encodeQueryComponent(email)}')
        : utf8.encode('name=${Uri.encodeQueryComponent(name)}&email=${Uri.encodeQueryComponent(email)}&phone=${Uri.encodeQueryComponent(phone)}');

    request.headers.set('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.headers.set('Content-Length', bodyRequest.length.toString());
    request.followRedirects = true;

    request.add(bodyRequest);
    final response = await request.close();
    final responseBody = json.decode(await response.transform(utf8.decoder).join());
    return responseBody['id'];
  }

  Future<void> addCard(
      String email,
      String cardHolderName,
      String customerId,
      String cardNumber,
      int expiryYear,
      int expiryMonth,
      int cvc,
      String address,
      String apartment,
      String city,
      String state,
      String zip) async {
    final request =
        await _httpClient.postUrl(Uri.parse(_BASE_URL + 'payment_methods'));
    final bodyRequest = utf8.encode(

        'type=${Uri.encodeQueryComponent('card')}&card[number]=${Uri.encodeQueryComponent(cardNumber)}&card[exp_month]=${Uri.encodeQueryComponent(expiryMonth.toString())}&card[exp_year]=${Uri.encodeQueryComponent(expiryYear.toString())}&card[cvc]=${Uri.encodeQueryComponent(cvc.toString())}&billing_details[email]=${Uri.encodeQueryComponent(email)}&billing_details[name]=${Uri.encodeQueryComponent(cardHolderName)}&billing_details[address][city]=${Uri.encodeQueryComponent(city)}&billing_details[address][line1]=${Uri.encodeQueryComponent(address)}&billing_details[address][line2]=${Uri.encodeQueryComponent(apartment)}&billing_details[address][postal_code]=${Uri.encodeQueryComponent(zip)}&billing_details[address][postal_code]=${Uri.encodeQueryComponent(zip)}&billing_details[address][state]=${Uri.encodeQueryComponent(state)}'
    );
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(bodyRequest);
    final response = await request.close();
    final paymentMethodResponse = await json.decode(await response.transform(utf8.decoder).join());
    if (paymentMethodResponse.containsKey('error')) {
      final errorObj = paymentMethodResponse['error'] as Map<String, dynamic>;
      if (errorObj['code'] == 'incorrect_number')
        throw InCorrectCardNumberException(
            message: errorObj.containsKey('message')
                ? errorObj['message']
                : 'Your card number is incorrect.');
    }

    await _attachPaymentMethodToCustomer(
        paymentMethodResponse['id'], customerId);
  }



  Future<bool> updateCard(String paymentId, String address, String apartment, String city, String state, String zip, int expireMonth, int expireYear) async {
    final request =
        await _httpClient.postUrl(Uri.parse(_BASE_URL + 'payment_methods/$paymentId'));
    final bodyRequest = utf8.encode(

        'card[exp_year]=${Uri.encodeQueryComponent(expireYear.toString())}&card[exp_month]=${Uri.encodeQueryComponent(expireMonth.toString())}&billing_details[address][line1]=${Uri.encodeQueryComponent(address)}&billing_details[address][line2]=${Uri.encodeQueryComponent(apartment)}&billing_details[address][city]=${Uri.encodeQueryComponent(city)}&billing_details[address][state]=${Uri.encodeQueryComponent(state)}&billing_details[address][postal_code]=${Uri.encodeQueryComponent(zip)}'
    );
    request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(bodyRequest);
    final response = await request.close();
    final paymentMethodResponse = await json.decode(await response.transform(utf8.decoder).join());
    if (paymentMethodResponse.containsKey('error')) {
      final errorObj = paymentMethodResponse['error'] as Map<String, dynamic>;
      if (errorObj['code'] == 'incorrect_number')
        throw InCorrectCardNumberException(
            message: errorObj.containsKey('message')
                ? errorObj['message']
                : 'Your card number is incorrect.');
    }
    return response.statusCode==200;
  }


  Future<bool> removeCard(String customerId,String paymentId) async {
    // Future<List<backend_response.PaymentCard>> retrieveCards(String customerId) async {
    print(customerId);
    final request =
    await _httpClient.postUrl(Uri.parse(_BASE_URL + 'payment_methods/$paymentId/detach'));
    request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return response.statusCode==200;
  }


  Future<void> _attachPaymentMethodToCustomer(
      String paymentId, String customerId) async {
    final request = await _httpClient
        .postUrl(Uri.parse(_BASE_URL + 'payment_methods/$paymentId/attach'));
    final bodyRequest =
        utf8.encode('customer=${Uri.encodeQueryComponent(customerId)}');
    request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(bodyRequest);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    responseBody;
  }

  Future<List<PaymentCard>> retrieveCards(String customerId) async {
    // Future<List<backend_response.PaymentCard>> retrieveCards(String customerId) async {
    print(customerId);
    final request =
        await _httpClient.getUrl(Uri.parse(_BASE_URL + 'payment_methods'));
    final bodyRequest = utf8.encode(
        'type=${Uri.encodeQueryComponent('card')}&customer=${Uri.encodeQueryComponent(customerId)}');
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Content-Length', bodyRequest.length.toString());
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(bodyRequest);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    return compute(parsePaymentMethods, responseBody);
    // return compute(parsePaymentMethods(responseBody), responseBody);
  }

  Future<BankAccountNew> createBankAccount(String customerId, String routingNumber,
      String accountNumber, String accountHolderName) async {
    final request = await _httpClient
        .postUrl(Uri.parse(_BASE_URL + 'customers/$customerId/sources'));
    final bodyRequest = utf8.encode(
        'source[object]=${Uri.encodeQueryComponent('bank_account')}&source[country]=${Uri.encodeQueryComponent('US')}&source[currency]=${Uri.encodeQueryComponent('usd')}&source[account_holder_name]=${Uri.encodeQueryComponent(accountHolderName)}&source[account_holder_type]=${Uri.encodeQueryComponent('individual')}&source[routing_number]=${Uri.encodeQueryComponent(routingNumber)}&source[account_number]=${Uri.encodeQueryComponent(accountNumber)}');
    print("=====${utf8.decode(bodyRequest)}");
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Content-Length', bodyRequest.length.toString());
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(bodyRequest);
    final response = await request.close();
    final responseBody = json.decode(await response.transform(utf8.decoder).join());
    if (responseBody.containsKey('error')) throw InvalidBankAccountNumber();
    return BankAccountNew.fromJson(responseBody);
  }

  Future<BankAccountNew> getBankAccount(String customerId) async {
    // Future<backend_response.BankAccount> getBankAccount(String customerId) async {
    final request = await _httpClient
        .getUrl(Uri.parse(_BASE_URL + 'customers/$customerId/sources'));
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    final response = await request.close();
    final responseBody =
        json.decode(await response.transform(utf8.decoder).join());
    if (responseBody.containsKey('error')) throw NoBankAccountException();
    if (!responseBody.containsKey('data')) throw NoBankAccountException();
    final dataList = responseBody['data'] as List<dynamic>;
    print(dataList);
    if (dataList.isEmpty) throw Exception("No bank");

    return dataList.map((e) => BankAccountNew.fromJson(e)).toList().first;
  }

  Future<bool> removeBankAccount(String customerId,String accountId) async {
    final request = await _httpClient.deleteUrl(Uri.parse(_BASE_URL + 'customers/$customerId/sources/$accountId'));
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    final response = await request.close();
    final responseBody = json.decode(await response.transform(utf8.decoder).join());
    if (responseBody.containsKey('error')) throw NoBankAccountException();
    if (!responseBody.containsKey('deleted')) throw NoBankAccountException();
    final deleteStatus = responseBody['deleted'];
    return deleteStatus as bool;
  }

  Future<BankAccount> getConnectAccount(String connectAccountId) async {
    // Future<backend_response.BankAccount> getConnectAccount(String connectAccountId) async {
    final request = await _httpClient
        .getUrl(Uri.parse(_BASE_URL + 'accounts/$connectAccountId'));
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    final response = await request.close();
    final responseBody =
        json.decode(await response.transform(utf8.decoder).join());
    if (!responseBody.containsKey('id')) throw NoBankAccountException();
    // return backend_response.BankAccount.fromJson(responseBody);
    return BankAccount.fromJson(responseBody);
  }

  Future<BankAccount> connectAccountId(
      String firstName,
      String lastName,
      String email,
      String accountNumber,
      // Future<backend_response.BankAccount> connectAccountId(String firstName, String lastName, String email, String accountNumber,
      String routingNumber,
      String accountHolderName) async {
    final request =
        await _httpClient.postUrl(Uri.parse(_BASE_URL + 'accounts'));
    final bodyRequest = 'type='
        '${Uri.encodeQueryComponent('express')}&'
        'country='
        '${Uri.encodeQueryComponent('US')}&'
        'email='
        '${Uri.encodeQueryComponent(email)}&'
        'default_currency='
        '${Uri.encodeQueryComponent('usd')}&'
        'external_account[object]='
        '${Uri.encodeQueryComponent('bank_account')}&'
        'external_account[country]='
        '${Uri.encodeQueryComponent('US')}&'
        'external_account[currency]='
        '${Uri.encodeQueryComponent('usd')}&'
        'external_account[account_holder_name]='
        '${Uri.encodeQueryComponent(accountHolderName)}&'
        'external_account[account_holder_type]='
        '${Uri.encodeQueryComponent('individual')}&'
        'external_account[routing_number]='
        '${Uri.encodeQueryComponent(routingNumber)}&'
        'external_account[account_number]='
        '${Uri.encodeQueryComponent(accountNumber)}&'
        'business_type='
        '${Uri.encodeQueryComponent('individual')}&'
        'capabilities[card_payments][requested]='
        '${Uri.encodeQueryComponent('true')}&'
        'capabilities[transfers][requested]='
        '${Uri.encodeQueryComponent('true')}&'
        'individual[email]='
        '${Uri.encodeQueryComponent(email)}&'
        'individual[first_name]='
        '${Uri.encodeQueryComponent(firstName)}&'
        'individual[last_name]='
        '${Uri.encodeQueryComponent(lastName)}&'
        'business_profile[url]='
        '${Uri.encodeQueryComponent('https://www.business.rent2park.com')}';

    final encodedBodyRequest = utf8.encode(bodyRequest);
    print("==> $bodyRequest");
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Content-Length', encodedBodyRequest.length.toString());
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(encodedBodyRequest);
    final response = await request.close();
    final responseBody =
        json.decode(await response.transform(utf8.decoder).join());
    // return backend_response.BankAccount.fromJson(responseBody);
    return BankAccount.fromJson(responseBody);
  }

  Future<String> connectAccountLink(String connectAccountId) async {
    final request =
        await _httpClient.postUrl(Uri.parse(_BASE_URL + 'account_links'));
    final bodyRequest = 'account='
        '${Uri.encodeQueryComponent(connectAccountId)}&'
        'refresh_url='
        '${Uri.encodeQueryComponent('https://business.rent2park.com/Account/refreshMessage')}&'
        'return_url='
        '${Uri.encodeQueryComponent('https://business.rent2park.com/Account/SuccessMessage')}&'
        'type='
        '${Uri.encodeQueryComponent('account_onboarding')}';
    final encodedBodyRequest = utf8.encode(bodyRequest);
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Content-Length', encodedBodyRequest.length.toString());
    request.headers.add('Authorization', 'Bearer $_TESTING_SECRET_KEY');
    request.add(encodedBodyRequest);
    final response = await request.close();
    final responseBody =
        json.decode(await response.transform(utf8.decoder).join());
    return responseBody['url'];
  }
}

List<PaymentCard> parsePaymentMethods(String responseBody) {
// List<backend_response.PaymentCard> parsePaymentMethods(String responseBody) {
  final jsonMap = json.decode(responseBody);
  return (jsonMap['data'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      // .map((e) => backend_response.PaymentCard.fromJson(e))
      .map((e) => PaymentCard.fromJson(e))
      .toList();
}
