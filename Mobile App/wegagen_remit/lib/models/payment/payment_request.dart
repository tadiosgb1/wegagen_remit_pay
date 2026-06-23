import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'transientToken')
  final String transientToken;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'toAccount')
  final String toAccount;

  @JsonKey(name: 'toAccountHolder')
  final String toAccountHolder;

  @JsonKey(name: 'remark')
  final String remark;
  
  @JsonKey(name: 'firstName')
  final String firstName;
  
  @JsonKey(name: 'lastName')
  final String lastName;
  
  @JsonKey(name: 'address1')
  final String address1;
  
  @JsonKey(name: 'locality')
  final String locality;
  
  @JsonKey(name: 'administrativeArea')
  final String administrativeArea;
  
  @JsonKey(name: 'postalCode')
  final String postalCode;
  
  @JsonKey(name: 'country')
  final String country;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'exchange_rate')
  final double exchangeRate;

  const PaymentRequest({
    required this.transientToken,
    required this.amount,
    required this.toAccount,
    required this.toAccountHolder,
    required this.remark,
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.locality,
    required this.administrativeArea,
    required this.postalCode,
    required this.country,
    required this.email,
    required this.exchangeRate,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}