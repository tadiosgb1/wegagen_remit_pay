// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_context_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptureContextResponse _$CaptureContextResponseFromJson(
        Map<String, dynamic> json) =>
    CaptureContextResponse(
      status: json['status'] as String,
      data: CaptureContextData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CaptureContextResponseToJson(
        CaptureContextResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'message': instance.message,
    };

CaptureContextData _$CaptureContextDataFromJson(Map<String, dynamic> json) =>
    CaptureContextData(
      captureContext: json['capture_context'] as String,
      sessionId: json['session_id'] as String?,
    );

Map<String, dynamic> _$CaptureContextDataToJson(CaptureContextData instance) =>
    <String, dynamic>{
      'capture_context': instance.captureContext,
      'session_id': instance.sessionId,
    };