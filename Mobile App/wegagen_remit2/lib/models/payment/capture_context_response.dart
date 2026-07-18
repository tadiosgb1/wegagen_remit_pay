import 'package:json_annotation/json_annotation.dart';

part 'capture_context_response.g.dart';

@JsonSerializable()
class CaptureContextResponse {
  final String status;
  final CaptureContextData data;
  final String? message;

  const CaptureContextResponse({
    required this.status,
    required this.data,
    this.message,
  });

  factory CaptureContextResponse.fromJson(Map<String, dynamic> json) =>
      _$CaptureContextResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CaptureContextResponseToJson(this);
}

@JsonSerializable()
class CaptureContextData {
  @JsonKey(name: 'capture_context')
  final String captureContext;
  
  @JsonKey(name: 'session_id')
  final String? sessionId;

  const CaptureContextData({
    required this.captureContext,
    this.sessionId,
  });

  factory CaptureContextData.fromJson(Map<String, dynamic> json) =>
      _$CaptureContextDataFromJson(json);

  Map<String, dynamic> toJson() => _$CaptureContextDataToJson(this);
}