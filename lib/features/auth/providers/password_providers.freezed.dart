// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PasswordValidationState {
  String get password => throw _privateConstructorUsedError;
  PasswordStrength get strength => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  List<String> get issues => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;

  /// Create a copy of PasswordValidationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordValidationStateCopyWith<PasswordValidationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordValidationStateCopyWith<$Res> {
  factory $PasswordValidationStateCopyWith(
    PasswordValidationState value,
    $Res Function(PasswordValidationState) then,
  ) = _$PasswordValidationStateCopyWithImpl<$Res, PasswordValidationState>;
  @useResult
  $Res call({
    String password,
    PasswordStrength strength,
    int score,
    List<String> issues,
    bool isValid,
    bool isVisible,
  });
}

/// @nodoc
class _$PasswordValidationStateCopyWithImpl<
  $Res,
  $Val extends PasswordValidationState
>
    implements $PasswordValidationStateCopyWith<$Res> {
  _$PasswordValidationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordValidationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? strength = null,
    Object? score = null,
    Object? issues = null,
    Object? isValid = null,
    Object? isVisible = null,
  }) {
    return _then(
      _value.copyWith(
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            strength: null == strength
                ? _value.strength
                : strength // ignore: cast_nullable_to_non_nullable
                      as PasswordStrength,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            issues: null == issues
                ? _value.issues
                : issues // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVisible: null == isVisible
                ? _value.isVisible
                : isVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordValidationStateImplCopyWith<$Res>
    implements $PasswordValidationStateCopyWith<$Res> {
  factory _$$PasswordValidationStateImplCopyWith(
    _$PasswordValidationStateImpl value,
    $Res Function(_$PasswordValidationStateImpl) then,
  ) = __$$PasswordValidationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String password,
    PasswordStrength strength,
    int score,
    List<String> issues,
    bool isValid,
    bool isVisible,
  });
}

/// @nodoc
class __$$PasswordValidationStateImplCopyWithImpl<$Res>
    extends
        _$PasswordValidationStateCopyWithImpl<
          $Res,
          _$PasswordValidationStateImpl
        >
    implements _$$PasswordValidationStateImplCopyWith<$Res> {
  __$$PasswordValidationStateImplCopyWithImpl(
    _$PasswordValidationStateImpl _value,
    $Res Function(_$PasswordValidationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordValidationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? strength = null,
    Object? score = null,
    Object? issues = null,
    Object? isValid = null,
    Object? isVisible = null,
  }) {
    return _then(
      _$PasswordValidationStateImpl(
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        strength: null == strength
            ? _value.strength
            : strength // ignore: cast_nullable_to_non_nullable
                  as PasswordStrength,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        issues: null == issues
            ? _value._issues
            : issues // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVisible: null == isVisible
            ? _value.isVisible
            : isVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PasswordValidationStateImpl extends _PasswordValidationState {
  const _$PasswordValidationStateImpl({
    this.password = '',
    this.strength = PasswordStrength.veryWeak,
    this.score = 0,
    final List<String> issues = const [],
    this.isValid = false,
    this.isVisible = false,
  }) : _issues = issues,
       super._();

  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final PasswordStrength strength;
  @override
  @JsonKey()
  final int score;
  final List<String> _issues;
  @override
  @JsonKey()
  List<String> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  @override
  @JsonKey()
  final bool isValid;
  @override
  @JsonKey()
  final bool isVisible;

  @override
  String toString() {
    return 'PasswordValidationState(password: $password, strength: $strength, score: $score, issues: $issues, isValid: $isValid, isVisible: $isVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordValidationStateImpl &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._issues, _issues) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    password,
    strength,
    score,
    const DeepCollectionEquality().hash(_issues),
    isValid,
    isVisible,
  );

  /// Create a copy of PasswordValidationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordValidationStateImplCopyWith<_$PasswordValidationStateImpl>
  get copyWith =>
      __$$PasswordValidationStateImplCopyWithImpl<
        _$PasswordValidationStateImpl
      >(this, _$identity);
}

abstract class _PasswordValidationState extends PasswordValidationState {
  const factory _PasswordValidationState({
    final String password,
    final PasswordStrength strength,
    final int score,
    final List<String> issues,
    final bool isValid,
    final bool isVisible,
  }) = _$PasswordValidationStateImpl;
  const _PasswordValidationState._() : super._();

  @override
  String get password;
  @override
  PasswordStrength get strength;
  @override
  int get score;
  @override
  List<String> get issues;
  @override
  bool get isValid;
  @override
  bool get isVisible;

  /// Create a copy of PasswordValidationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordValidationStateImplCopyWith<_$PasswordValidationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PasswordChangeState {
  String get currentPassword => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;
  String get confirmPassword => throw _privateConstructorUsedError;
  bool get isCurrentPasswordVisible => throw _privateConstructorUsedError;
  bool get isNewPasswordVisible => throw _privateConstructorUsedError;
  bool get isConfirmPasswordVisible => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  PasswordChangeResult? get validationResult =>
      throw _privateConstructorUsedError;

  /// Create a copy of PasswordChangeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordChangeStateCopyWith<PasswordChangeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordChangeStateCopyWith<$Res> {
  factory $PasswordChangeStateCopyWith(
    PasswordChangeState value,
    $Res Function(PasswordChangeState) then,
  ) = _$PasswordChangeStateCopyWithImpl<$Res, PasswordChangeState>;
  @useResult
  $Res call({
    String currentPassword,
    String newPassword,
    String confirmPassword,
    bool isCurrentPasswordVisible,
    bool isNewPasswordVisible,
    bool isConfirmPasswordVisible,
    bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  });
}

/// @nodoc
class _$PasswordChangeStateCopyWithImpl<$Res, $Val extends PasswordChangeState>
    implements $PasswordChangeStateCopyWith<$Res> {
  _$PasswordChangeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordChangeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
    Object? isCurrentPasswordVisible = null,
    Object? isNewPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? validationResult = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPassword: null == currentPassword
                ? _value.currentPassword
                : currentPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            isCurrentPasswordVisible: null == isCurrentPasswordVisible
                ? _value.isCurrentPasswordVisible
                : isCurrentPasswordVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isNewPasswordVisible: null == isNewPasswordVisible
                ? _value.isNewPasswordVisible
                : isNewPasswordVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isConfirmPasswordVisible: null == isConfirmPasswordVisible
                ? _value.isConfirmPasswordVisible
                : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            validationResult: freezed == validationResult
                ? _value.validationResult
                : validationResult // ignore: cast_nullable_to_non_nullable
                      as PasswordChangeResult?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordChangeStateImplCopyWith<$Res>
    implements $PasswordChangeStateCopyWith<$Res> {
  factory _$$PasswordChangeStateImplCopyWith(
    _$PasswordChangeStateImpl value,
    $Res Function(_$PasswordChangeStateImpl) then,
  ) = __$$PasswordChangeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String currentPassword,
    String newPassword,
    String confirmPassword,
    bool isCurrentPasswordVisible,
    bool isNewPasswordVisible,
    bool isConfirmPasswordVisible,
    bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  });
}

/// @nodoc
class __$$PasswordChangeStateImplCopyWithImpl<$Res>
    extends _$PasswordChangeStateCopyWithImpl<$Res, _$PasswordChangeStateImpl>
    implements _$$PasswordChangeStateImplCopyWith<$Res> {
  __$$PasswordChangeStateImplCopyWithImpl(
    _$PasswordChangeStateImpl _value,
    $Res Function(_$PasswordChangeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordChangeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
    Object? isCurrentPasswordVisible = null,
    Object? isNewPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? validationResult = freezed,
  }) {
    return _then(
      _$PasswordChangeStateImpl(
        currentPassword: null == currentPassword
            ? _value.currentPassword
            : currentPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        isCurrentPasswordVisible: null == isCurrentPasswordVisible
            ? _value.isCurrentPasswordVisible
            : isCurrentPasswordVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isNewPasswordVisible: null == isNewPasswordVisible
            ? _value.isNewPasswordVisible
            : isNewPasswordVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isConfirmPasswordVisible: null == isConfirmPasswordVisible
            ? _value.isConfirmPasswordVisible
            : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        validationResult: freezed == validationResult
            ? _value.validationResult
            : validationResult // ignore: cast_nullable_to_non_nullable
                  as PasswordChangeResult?,
      ),
    );
  }
}

/// @nodoc

class _$PasswordChangeStateImpl implements _PasswordChangeState {
  const _$PasswordChangeStateImpl({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isCurrentPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.error,
    this.validationResult,
  });

  @override
  @JsonKey()
  final String currentPassword;
  @override
  @JsonKey()
  final String newPassword;
  @override
  @JsonKey()
  final String confirmPassword;
  @override
  @JsonKey()
  final bool isCurrentPasswordVisible;
  @override
  @JsonKey()
  final bool isNewPasswordVisible;
  @override
  @JsonKey()
  final bool isConfirmPasswordVisible;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final PasswordChangeResult? validationResult;

  @override
  String toString() {
    return 'PasswordChangeState(currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, isCurrentPasswordVisible: $isCurrentPasswordVisible, isNewPasswordVisible: $isNewPasswordVisible, isConfirmPasswordVisible: $isConfirmPasswordVisible, isLoading: $isLoading, error: $error, validationResult: $validationResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordChangeStateImpl &&
            (identical(other.currentPassword, currentPassword) ||
                other.currentPassword == currentPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(
                  other.isCurrentPasswordVisible,
                  isCurrentPasswordVisible,
                ) ||
                other.isCurrentPasswordVisible == isCurrentPasswordVisible) &&
            (identical(other.isNewPasswordVisible, isNewPasswordVisible) ||
                other.isNewPasswordVisible == isNewPasswordVisible) &&
            (identical(
                  other.isConfirmPasswordVisible,
                  isConfirmPasswordVisible,
                ) ||
                other.isConfirmPasswordVisible == isConfirmPasswordVisible) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.validationResult, validationResult) ||
                other.validationResult == validationResult));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentPassword,
    newPassword,
    confirmPassword,
    isCurrentPasswordVisible,
    isNewPasswordVisible,
    isConfirmPasswordVisible,
    isLoading,
    error,
    validationResult,
  );

  /// Create a copy of PasswordChangeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordChangeStateImplCopyWith<_$PasswordChangeStateImpl> get copyWith =>
      __$$PasswordChangeStateImplCopyWithImpl<_$PasswordChangeStateImpl>(
        this,
        _$identity,
      );
}

abstract class _PasswordChangeState implements PasswordChangeState {
  const factory _PasswordChangeState({
    final String currentPassword,
    final String newPassword,
    final String confirmPassword,
    final bool isCurrentPasswordVisible,
    final bool isNewPasswordVisible,
    final bool isConfirmPasswordVisible,
    final bool isLoading,
    final String? error,
    final PasswordChangeResult? validationResult,
  }) = _$PasswordChangeStateImpl;

  @override
  String get currentPassword;
  @override
  String get newPassword;
  @override
  String get confirmPassword;
  @override
  bool get isCurrentPasswordVisible;
  @override
  bool get isNewPasswordVisible;
  @override
  bool get isConfirmPasswordVisible;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  PasswordChangeResult? get validationResult;

  /// Create a copy of PasswordChangeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordChangeStateImplCopyWith<_$PasswordChangeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PasswordResetState {
  String get token => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;
  String get confirmPassword => throw _privateConstructorUsedError;
  bool get isNewPasswordVisible => throw _privateConstructorUsedError;
  bool get isConfirmPasswordVisible => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  PasswordChangeResult? get validationResult =>
      throw _privateConstructorUsedError;

  /// Create a copy of PasswordResetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordResetStateCopyWith<PasswordResetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordResetStateCopyWith<$Res> {
  factory $PasswordResetStateCopyWith(
    PasswordResetState value,
    $Res Function(PasswordResetState) then,
  ) = _$PasswordResetStateCopyWithImpl<$Res, PasswordResetState>;
  @useResult
  $Res call({
    String token,
    String newPassword,
    String confirmPassword,
    bool isNewPasswordVisible,
    bool isConfirmPasswordVisible,
    bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  });
}

/// @nodoc
class _$PasswordResetStateCopyWithImpl<$Res, $Val extends PasswordResetState>
    implements $PasswordResetStateCopyWith<$Res> {
  _$PasswordResetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordResetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
    Object? isNewPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? validationResult = freezed,
  }) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            isNewPasswordVisible: null == isNewPasswordVisible
                ? _value.isNewPasswordVisible
                : isNewPasswordVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isConfirmPasswordVisible: null == isConfirmPasswordVisible
                ? _value.isConfirmPasswordVisible
                : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            validationResult: freezed == validationResult
                ? _value.validationResult
                : validationResult // ignore: cast_nullable_to_non_nullable
                      as PasswordChangeResult?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordResetStateImplCopyWith<$Res>
    implements $PasswordResetStateCopyWith<$Res> {
  factory _$$PasswordResetStateImplCopyWith(
    _$PasswordResetStateImpl value,
    $Res Function(_$PasswordResetStateImpl) then,
  ) = __$$PasswordResetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String token,
    String newPassword,
    String confirmPassword,
    bool isNewPasswordVisible,
    bool isConfirmPasswordVisible,
    bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  });
}

/// @nodoc
class __$$PasswordResetStateImplCopyWithImpl<$Res>
    extends _$PasswordResetStateCopyWithImpl<$Res, _$PasswordResetStateImpl>
    implements _$$PasswordResetStateImplCopyWith<$Res> {
  __$$PasswordResetStateImplCopyWithImpl(
    _$PasswordResetStateImpl _value,
    $Res Function(_$PasswordResetStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordResetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
    Object? isNewPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? validationResult = freezed,
  }) {
    return _then(
      _$PasswordResetStateImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        isNewPasswordVisible: null == isNewPasswordVisible
            ? _value.isNewPasswordVisible
            : isNewPasswordVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isConfirmPasswordVisible: null == isConfirmPasswordVisible
            ? _value.isConfirmPasswordVisible
            : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        validationResult: freezed == validationResult
            ? _value.validationResult
            : validationResult // ignore: cast_nullable_to_non_nullable
                  as PasswordChangeResult?,
      ),
    );
  }
}

/// @nodoc

class _$PasswordResetStateImpl implements _PasswordResetState {
  const _$PasswordResetStateImpl({
    this.token = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.error,
    this.validationResult,
  });

  @override
  @JsonKey()
  final String token;
  @override
  @JsonKey()
  final String newPassword;
  @override
  @JsonKey()
  final String confirmPassword;
  @override
  @JsonKey()
  final bool isNewPasswordVisible;
  @override
  @JsonKey()
  final bool isConfirmPasswordVisible;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final PasswordChangeResult? validationResult;

  @override
  String toString() {
    return 'PasswordResetState(token: $token, newPassword: $newPassword, confirmPassword: $confirmPassword, isNewPasswordVisible: $isNewPasswordVisible, isConfirmPasswordVisible: $isConfirmPasswordVisible, isLoading: $isLoading, error: $error, validationResult: $validationResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetStateImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(other.isNewPasswordVisible, isNewPasswordVisible) ||
                other.isNewPasswordVisible == isNewPasswordVisible) &&
            (identical(
                  other.isConfirmPasswordVisible,
                  isConfirmPasswordVisible,
                ) ||
                other.isConfirmPasswordVisible == isConfirmPasswordVisible) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.validationResult, validationResult) ||
                other.validationResult == validationResult));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    token,
    newPassword,
    confirmPassword,
    isNewPasswordVisible,
    isConfirmPasswordVisible,
    isLoading,
    error,
    validationResult,
  );

  /// Create a copy of PasswordResetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetStateImplCopyWith<_$PasswordResetStateImpl> get copyWith =>
      __$$PasswordResetStateImplCopyWithImpl<_$PasswordResetStateImpl>(
        this,
        _$identity,
      );
}

abstract class _PasswordResetState implements PasswordResetState {
  const factory _PasswordResetState({
    final String token,
    final String newPassword,
    final String confirmPassword,
    final bool isNewPasswordVisible,
    final bool isConfirmPasswordVisible,
    final bool isLoading,
    final String? error,
    final PasswordChangeResult? validationResult,
  }) = _$PasswordResetStateImpl;

  @override
  String get token;
  @override
  String get newPassword;
  @override
  String get confirmPassword;
  @override
  bool get isNewPasswordVisible;
  @override
  bool get isConfirmPasswordVisible;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  PasswordChangeResult? get validationResult;

  /// Create a copy of PasswordResetState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetStateImplCopyWith<_$PasswordResetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
