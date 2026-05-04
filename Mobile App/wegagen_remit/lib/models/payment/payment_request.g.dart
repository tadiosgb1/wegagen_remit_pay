// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      toAccountHolder: json['toAccountHolder'] as String,
      toAccount: json['toAccount'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      remark: json['remark'] as String,
      exchangeRate: (json['exchange_rate'] as num).toDouble(),
      paymentToken: json['payment_token'] as String,
      channel: json['channel'] as String? ?? 'MOBILE_APP',
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'toAccountHolder': instance.toAccountHolder,
      'toAccount': instance.toAccount,
      'amount': instance.amount,
      'currency': instance.currency,
      'remark': instance.remark,
      'exchange_rate': instance.exchangeRate,
      'payment_token': instance.paymentToken,
      'channel': instance.channel,
    };