import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'toAccountHolder')
  final String toAccountHolder;
  
  @JsonKey(name: 'toAccount')
  final String toAccount;
  
  @JsonKey(name: 'amount')
  final double amount;
  
  @JsonKey(name: 'currency')
  final String currency;
  
  @JsonKey(name: 'remark')
  final String remark;
  
  @JsonKey(name: 'exchange_rate')
  final double exchangeRate;
  
  @JsonKey(name: 'payment_token')
  final String paymentToken;
  
  @JsonKey(name: 'channel')
  final String channel;

  const PaymentRequest({
    required this.toAccountHolder,
    required this.toAccount,
    required this.amount,
    required this.currency,
    required this.remark,
    required this.exchangeRate,
    required this.paymentToken,
    this.channel = 'MOBILE_APP',
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}