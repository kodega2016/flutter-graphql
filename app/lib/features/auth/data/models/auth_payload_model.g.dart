// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_payload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthPayloadModelImpl _$$AuthPayloadModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthPayloadModelImpl(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthPayloadModelImplToJson(
        _$AuthPayloadModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'user': instance.user,
    };
