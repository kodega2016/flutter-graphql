// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_payload_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthPayloadModel _$AuthPayloadModelFromJson(Map<String, dynamic> json) {
  return _AuthPayloadModel.fromJson(json);
}

/// @nodoc
mixin _$AuthPayloadModel {
  String get accessToken => throw _privateConstructorUsedError;
  UserModel get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthPayloadModelCopyWith<AuthPayloadModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthPayloadModelCopyWith<$Res> {
  factory $AuthPayloadModelCopyWith(
          AuthPayloadModel value, $Res Function(AuthPayloadModel) then) =
      _$AuthPayloadModelCopyWithImpl<$Res, AuthPayloadModel>;
  @useResult
  $Res call({String accessToken, UserModel user});

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthPayloadModelCopyWithImpl<$Res, $Val extends AuthPayloadModel>
    implements $AuthPayloadModelCopyWith<$Res> {
  _$AuthPayloadModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthPayloadModelImplCopyWith<$Res>
    implements $AuthPayloadModelCopyWith<$Res> {
  factory _$$AuthPayloadModelImplCopyWith(_$AuthPayloadModelImpl value,
          $Res Function(_$AuthPayloadModelImpl) then) =
      __$$AuthPayloadModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, UserModel user});

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthPayloadModelImplCopyWithImpl<$Res>
    extends _$AuthPayloadModelCopyWithImpl<$Res, _$AuthPayloadModelImpl>
    implements _$$AuthPayloadModelImplCopyWith<$Res> {
  __$$AuthPayloadModelImplCopyWithImpl(_$AuthPayloadModelImpl _value,
      $Res Function(_$AuthPayloadModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? user = null,
  }) {
    return _then(_$AuthPayloadModelImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthPayloadModelImpl implements _AuthPayloadModel {
  const _$AuthPayloadModelImpl({required this.accessToken, required this.user});

  factory _$AuthPayloadModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthPayloadModelImplFromJson(json);

  @override
  final String accessToken;
  @override
  final UserModel user;

  @override
  String toString() {
    return 'AuthPayloadModel(accessToken: $accessToken, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthPayloadModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthPayloadModelImplCopyWith<_$AuthPayloadModelImpl> get copyWith =>
      __$$AuthPayloadModelImplCopyWithImpl<_$AuthPayloadModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthPayloadModelImplToJson(
      this,
    );
  }
}

abstract class _AuthPayloadModel implements AuthPayloadModel {
  const factory _AuthPayloadModel(
      {required final String accessToken,
      required final UserModel user}) = _$AuthPayloadModelImpl;

  factory _AuthPayloadModel.fromJson(Map<String, dynamic> json) =
      _$AuthPayloadModelImpl.fromJson;

  @override
  String get accessToken;
  @override
  UserModel get user;
  @override
  @JsonKey(ignore: true)
  _$$AuthPayloadModelImplCopyWith<_$AuthPayloadModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
