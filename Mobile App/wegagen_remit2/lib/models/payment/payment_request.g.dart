// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      transientToken: json['transientToken'] as String,
      amount: (json['amount'] as num).toDouble(),
      toAccount: json['toAccount'] as String,
      toAccountHolder: json['toAccountHolder'] as String,
      remark: json['remark'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      address1: json['address1'] as String,
      locality: json['locality'] as String,
      administrativeArea: json['administrativeArea'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      email: json['email'] as String,
      exchangeRate: (json['exchange_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'transientToken': instance.transientToken,
      'amount': instance.amount,
      'toAccount': instance.toAccount,
      'toAccountHolder': instance.toAccountHolder,
      'remark': instance.remark,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'address1': instance.address1,
      'locality': instance.locality,
      'administrativeArea': instance.administrativeArea,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'email': instance.email,
      'exchange_rate': instance.exchangeRate,
    }; 
