// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      status: json['status'] as String,
      data: json['data'] == null
          ? null
          : PaymentData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'message': instance.message,
      'error': instance.error,
    };

PaymentData _$PaymentDataFromJson(Map<String, dynamic> json) => PaymentData(
      transactionRef: json['transaction_ref'] as String,
      paymentId: json['payment_id'] as String?,
      status: json['status'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PaymentDataToJson(PaymentData instance) =>
    <String, dynamic>{
      'transaction_ref': instance.transactionRef,
      'payment_id': instance.paymentId,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'created_at': instance.createdAt,
    };