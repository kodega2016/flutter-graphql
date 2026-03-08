import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'auth_payload_model.freezed.dart';
part 'auth_payload_model.g.dart';

@freezed
class AuthPayloadModel with _$AuthPayloadModel {
  const factory AuthPayloadModel({
    required String accessToken,
    required UserModel user,
  }) = _AuthPayloadModel;

  factory AuthPayloadModel.fromJson(Map<String, dynamic> json) =>
      _$AuthPayloadModelFromJson(json);
}
