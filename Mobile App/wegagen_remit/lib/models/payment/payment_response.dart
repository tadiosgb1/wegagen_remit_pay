import 'package:json_annotation/json_annotation.dart';

part 'payment_response.g.dart';

@JsonSerializable()
class PaymentResponse {
  final String status;
  final PaymentData? data;
  final String? message;
  final String? error;

  const PaymentResponse({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed' || status == 'error';

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}

@JsonSerializable()
class PaymentData {
  @JsonKey(name: 'transaction_ref')
  final String transactionRef;
  
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  
  @JsonKey(name: 'status')
  final String? status;
  
  @JsonKey(name: 'amount')
  final double? amount;
  
  @JsonKey(name: 'currency')
  final String? currency;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const PaymentData({
    required this.transactionRef,
    this.paymentId,
    this.status,
    this.amount,
    this.currency,
    this.createdAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDataToJson(this);
}