// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CautionDto {

 String get ingredient; String get concern; String? get severity; String? get percentage; String? get chemicalFormula; String? get scientificName;
/// Create a copy of CautionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CautionDtoCopyWith<CautionDto> get copyWith => _$CautionDtoCopyWithImpl<CautionDto>(this as CautionDto, _$identity);

  /// Serializes this CautionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CautionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CautionDto&&(identical(other.ingredient, _this.ingredient) || other.ingredient == _this.ingredient)&&(identical(other.concern, _this.concern) || other.concern == _this.concern)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.percentage, _this.percentage) || other.percentage == _this.percentage)&&(identical(other.chemicalFormula, _this.chemicalFormula) || other.chemicalFormula == _this.chemicalFormula)&&(identical(other.scientificName, _this.scientificName) || other.scientificName == _this.scientificName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CautionDto;
  return Object.hash(runtimeType,_this.ingredient,_this.concern,_this.severity,_this.percentage,_this.chemicalFormula,_this.scientificName);
}

@override
String toString() {
  final _this = this as CautionDto;
  return 'CautionDto(ingredient: ${_this.ingredient}, concern: ${_this.concern}, severity: ${_this.severity}, percentage: ${_this.percentage}, chemicalFormula: ${_this.chemicalFormula}, scientificName: ${_this.scientificName})';
}


}

/// @nodoc
abstract mixin class $CautionDtoCopyWith<$Res>  {
  factory $CautionDtoCopyWith(CautionDto value, $Res Function(CautionDto) _then) = _$CautionDtoCopyWithImpl;
@useResult
$Res call({
 String ingredient, String concern, String? severity, String? percentage, String? chemicalFormula, String? scientificName
});




}
/// @nodoc
class _$CautionDtoCopyWithImpl<$Res>
    implements $CautionDtoCopyWith<$Res> {
  _$CautionDtoCopyWithImpl(this._self, this._then);

  final CautionDto _self;
  final $Res Function(CautionDto) _then;

/// Create a copy of CautionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredient = null,Object? concern = null,Object? severity = freezed,Object? percentage = freezed,Object? chemicalFormula = freezed,Object? scientificName = freezed,}) {
  return _then(CautionDto(
ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as String,concern: null == concern ? _self.concern : concern // ignore: cast_nullable_to_non_nullable
as String,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as String?,chemicalFormula: freezed == chemicalFormula ? _self.chemicalFormula : chemicalFormula // ignore: cast_nullable_to_non_nullable
as String?,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CautionDto].
extension CautionDtoPatterns on CautionDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CautionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CautionDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CautionDto value)  $default,){
final _that = this;
switch (_that) {
case _CautionDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CautionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CautionDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredient,  String concern,  String? severity,  String? percentage,  String? chemicalFormula,  String? scientificName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CautionDto() when $default != null:
return $default(_that.ingredient,_that.concern,_that.severity,_that.percentage,_that.chemicalFormula,_that.scientificName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredient,  String concern,  String? severity,  String? percentage,  String? chemicalFormula,  String? scientificName)  $default,) {final _that = this;
switch (_that) {
case _CautionDto():
return $default(_that.ingredient,_that.concern,_that.severity,_that.percentage,_that.chemicalFormula,_that.scientificName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredient,  String concern,  String? severity,  String? percentage,  String? chemicalFormula,  String? scientificName)?  $default,) {final _that = this;
switch (_that) {
case _CautionDto() when $default != null:
return $default(_that.ingredient,_that.concern,_that.severity,_that.percentage,_that.chemicalFormula,_that.scientificName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CautionDto implements CautionDto {
  const _CautionDto({this.ingredient = '', this.concern = '', this.severity, this.percentage, this.chemicalFormula, this.scientificName});
  factory _CautionDto.fromJson(Map<String, dynamic> json) => _$CautionDtoFromJson(json);

@override@JsonKey() final  String ingredient;
@override@JsonKey() final  String concern;
@override final  String? severity;
@override final  String? percentage;
@override final  String? chemicalFormula;
@override final  String? scientificName;

/// Create a copy of CautionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CautionDtoCopyWith<_CautionDto> get copyWith => __$CautionDtoCopyWithImpl<_CautionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CautionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CautionDto&&(identical(other.ingredient, ingredient) || other.ingredient == ingredient)&&(identical(other.concern, concern) || other.concern == concern)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.chemicalFormula, chemicalFormula) || other.chemicalFormula == chemicalFormula)&&(identical(other.scientificName, scientificName) || other.scientificName == scientificName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ingredient,concern,severity,percentage,chemicalFormula,scientificName);
}

@override
String toString() {
    return 'CautionDto(ingredient: $ingredient, concern: $concern, severity: $severity, percentage: $percentage, chemicalFormula: $chemicalFormula, scientificName: $scientificName)';
}


}

/// @nodoc
abstract mixin class _$CautionDtoCopyWith<$Res> implements $CautionDtoCopyWith<$Res> {
  factory _$CautionDtoCopyWith(_CautionDto value, $Res Function(_CautionDto) _then) = __$CautionDtoCopyWithImpl;
@override @useResult
$Res call({
 String ingredient, String concern, String? severity, String? percentage, String? chemicalFormula, String? scientificName
});




}
/// @nodoc
class __$CautionDtoCopyWithImpl<$Res>
    implements _$CautionDtoCopyWith<$Res> {
  __$CautionDtoCopyWithImpl(this._self, this._then);

  final _CautionDto _self;
  final $Res Function(_CautionDto) _then;

/// Create a copy of CautionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredient = null,Object? concern = null,Object? severity = freezed,Object? percentage = freezed,Object? chemicalFormula = freezed,Object? scientificName = freezed,}) {
  return _then(_CautionDto(
ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as String,concern: null == concern ? _self.concern : concern // ignore: cast_nullable_to_non_nullable
as String,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as String?,chemicalFormula: freezed == chemicalFormula ? _self.chemicalFormula : chemicalFormula // ignore: cast_nullable_to_non_nullable
as String?,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionTipDto {

 String get safeDaily; String get limit; String get source;
/// Create a copy of ConsumptionTipDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionTipDtoCopyWith<ConsumptionTipDto> get copyWith => _$ConsumptionTipDtoCopyWithImpl<ConsumptionTipDto>(this as ConsumptionTipDto, _$identity);

  /// Serializes this ConsumptionTipDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionTipDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionTipDto&&(identical(other.safeDaily, _this.safeDaily) || other.safeDaily == _this.safeDaily)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionTipDto;
  return Object.hash(runtimeType,_this.safeDaily,_this.limit,_this.source);
}

@override
String toString() {
  final _this = this as ConsumptionTipDto;
  return 'ConsumptionTipDto(safeDaily: ${_this.safeDaily}, limit: ${_this.limit}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $ConsumptionTipDtoCopyWith<$Res>  {
  factory $ConsumptionTipDtoCopyWith(ConsumptionTipDto value, $Res Function(ConsumptionTipDto) _then) = _$ConsumptionTipDtoCopyWithImpl;
@useResult
$Res call({
 String safeDaily, String limit, String source
});




}
/// @nodoc
class _$ConsumptionTipDtoCopyWithImpl<$Res>
    implements $ConsumptionTipDtoCopyWith<$Res> {
  _$ConsumptionTipDtoCopyWithImpl(this._self, this._then);

  final ConsumptionTipDto _self;
  final $Res Function(ConsumptionTipDto) _then;

/// Create a copy of ConsumptionTipDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? safeDaily = null,Object? limit = null,Object? source = null,}) {
  return _then(ConsumptionTipDto(
safeDaily: null == safeDaily ? _self.safeDaily : safeDaily // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionTipDto].
extension ConsumptionTipDtoPatterns on ConsumptionTipDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionTipDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionTipDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionTipDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionTipDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionTipDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionTipDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String safeDaily,  String limit,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionTipDto() when $default != null:
return $default(_that.safeDaily,_that.limit,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String safeDaily,  String limit,  String source)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionTipDto():
return $default(_that.safeDaily,_that.limit,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String safeDaily,  String limit,  String source)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionTipDto() when $default != null:
return $default(_that.safeDaily,_that.limit,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionTipDto implements ConsumptionTipDto {
  const _ConsumptionTipDto({this.safeDaily = '', this.limit = '', this.source = ''});
  factory _ConsumptionTipDto.fromJson(Map<String, dynamic> json) => _$ConsumptionTipDtoFromJson(json);

@override@JsonKey() final  String safeDaily;
@override@JsonKey() final  String limit;
@override@JsonKey() final  String source;

/// Create a copy of ConsumptionTipDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionTipDtoCopyWith<_ConsumptionTipDto> get copyWith => __$ConsumptionTipDtoCopyWithImpl<_ConsumptionTipDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionTipDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionTipDto&&(identical(other.safeDaily, safeDaily) || other.safeDaily == safeDaily)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,safeDaily,limit,source);
}

@override
String toString() {
    return 'ConsumptionTipDto(safeDaily: $safeDaily, limit: $limit, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionTipDtoCopyWith<$Res> implements $ConsumptionTipDtoCopyWith<$Res> {
  factory _$ConsumptionTipDtoCopyWith(_ConsumptionTipDto value, $Res Function(_ConsumptionTipDto) _then) = __$ConsumptionTipDtoCopyWithImpl;
@override @useResult
$Res call({
 String safeDaily, String limit, String source
});




}
/// @nodoc
class __$ConsumptionTipDtoCopyWithImpl<$Res>
    implements _$ConsumptionTipDtoCopyWith<$Res> {
  __$ConsumptionTipDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionTipDto _self;
  final $Res Function(_ConsumptionTipDto) _then;

/// Create a copy of ConsumptionTipDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? safeDaily = null,Object? limit = null,Object? source = null,}) {
  return _then(_ConsumptionTipDto(
safeDaily: null == safeDaily ? _self.safeDaily : safeDaily // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RiskProfileDto {

 List<String> get illnesses; List<String> get addictions; List<String> get chronicDamage; List<String> get temporaryEffects; List<String> get organDamage;
/// Create a copy of RiskProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiskProfileDtoCopyWith<RiskProfileDto> get copyWith => _$RiskProfileDtoCopyWithImpl<RiskProfileDto>(this as RiskProfileDto, _$identity);

  /// Serializes this RiskProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RiskProfileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiskProfileDto&&const DeepCollectionEquality().equals(other.illnesses, _this.illnesses)&&const DeepCollectionEquality().equals(other.addictions, _this.addictions)&&const DeepCollectionEquality().equals(other.chronicDamage, _this.chronicDamage)&&const DeepCollectionEquality().equals(other.temporaryEffects, _this.temporaryEffects)&&const DeepCollectionEquality().equals(other.organDamage, _this.organDamage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RiskProfileDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.illnesses),const DeepCollectionEquality().hash(_this.addictions),const DeepCollectionEquality().hash(_this.chronicDamage),const DeepCollectionEquality().hash(_this.temporaryEffects),const DeepCollectionEquality().hash(_this.organDamage));
}

@override
String toString() {
  final _this = this as RiskProfileDto;
  return 'RiskProfileDto(illnesses: ${_this.illnesses}, addictions: ${_this.addictions}, chronicDamage: ${_this.chronicDamage}, temporaryEffects: ${_this.temporaryEffects}, organDamage: ${_this.organDamage})';
}


}

/// @nodoc
abstract mixin class $RiskProfileDtoCopyWith<$Res>  {
  factory $RiskProfileDtoCopyWith(RiskProfileDto value, $Res Function(RiskProfileDto) _then) = _$RiskProfileDtoCopyWithImpl;
@useResult
$Res call({
 List<String> illnesses, List<String> addictions, List<String> chronicDamage, List<String> temporaryEffects, List<String> organDamage
});




}
/// @nodoc
class _$RiskProfileDtoCopyWithImpl<$Res>
    implements $RiskProfileDtoCopyWith<$Res> {
  _$RiskProfileDtoCopyWithImpl(this._self, this._then);

  final RiskProfileDto _self;
  final $Res Function(RiskProfileDto) _then;

/// Create a copy of RiskProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? illnesses = null,Object? addictions = null,Object? chronicDamage = null,Object? temporaryEffects = null,Object? organDamage = null,}) {
  return _then(RiskProfileDto(
illnesses: null == illnesses ? _self.illnesses : illnesses // ignore: cast_nullable_to_non_nullable
as List<String>,addictions: null == addictions ? _self.addictions : addictions // ignore: cast_nullable_to_non_nullable
as List<String>,chronicDamage: null == chronicDamage ? _self.chronicDamage : chronicDamage // ignore: cast_nullable_to_non_nullable
as List<String>,temporaryEffects: null == temporaryEffects ? _self.temporaryEffects : temporaryEffects // ignore: cast_nullable_to_non_nullable
as List<String>,organDamage: null == organDamage ? _self.organDamage : organDamage // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RiskProfileDto].
extension RiskProfileDtoPatterns on RiskProfileDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiskProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiskProfileDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiskProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _RiskProfileDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiskProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _RiskProfileDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> illnesses,  List<String> addictions,  List<String> chronicDamage,  List<String> temporaryEffects,  List<String> organDamage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiskProfileDto() when $default != null:
return $default(_that.illnesses,_that.addictions,_that.chronicDamage,_that.temporaryEffects,_that.organDamage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> illnesses,  List<String> addictions,  List<String> chronicDamage,  List<String> temporaryEffects,  List<String> organDamage)  $default,) {final _that = this;
switch (_that) {
case _RiskProfileDto():
return $default(_that.illnesses,_that.addictions,_that.chronicDamage,_that.temporaryEffects,_that.organDamage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> illnesses,  List<String> addictions,  List<String> chronicDamage,  List<String> temporaryEffects,  List<String> organDamage)?  $default,) {final _that = this;
switch (_that) {
case _RiskProfileDto() when $default != null:
return $default(_that.illnesses,_that.addictions,_that.chronicDamage,_that.temporaryEffects,_that.organDamage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiskProfileDto implements RiskProfileDto {
  const _RiskProfileDto({ List<String> illnesses = const [],  List<String> addictions = const [],  List<String> chronicDamage = const [],  List<String> temporaryEffects = const [],  List<String> organDamage = const []}): _illnesses = illnesses,_addictions = addictions,_chronicDamage = chronicDamage,_temporaryEffects = temporaryEffects,_organDamage = organDamage;
  factory _RiskProfileDto.fromJson(Map<String, dynamic> json) => _$RiskProfileDtoFromJson(json);

 final  List<String> _illnesses;
@override@JsonKey() List<String> get illnesses {
  if (_illnesses is EqualUnmodifiableListView) return _illnesses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_illnesses);
}

 final  List<String> _addictions;
@override@JsonKey() List<String> get addictions {
  if (_addictions is EqualUnmodifiableListView) return _addictions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addictions);
}

 final  List<String> _chronicDamage;
@override@JsonKey() List<String> get chronicDamage {
  if (_chronicDamage is EqualUnmodifiableListView) return _chronicDamage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chronicDamage);
}

 final  List<String> _temporaryEffects;
@override@JsonKey() List<String> get temporaryEffects {
  if (_temporaryEffects is EqualUnmodifiableListView) return _temporaryEffects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_temporaryEffects);
}

 final  List<String> _organDamage;
@override@JsonKey() List<String> get organDamage {
  if (_organDamage is EqualUnmodifiableListView) return _organDamage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_organDamage);
}


/// Create a copy of RiskProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiskProfileDtoCopyWith<_RiskProfileDto> get copyWith => __$RiskProfileDtoCopyWithImpl<_RiskProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiskProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiskProfileDto&&const DeepCollectionEquality().equals(other.illnesses, _illnesses)&&const DeepCollectionEquality().equals(other.addictions, _addictions)&&const DeepCollectionEquality().equals(other.chronicDamage, _chronicDamage)&&const DeepCollectionEquality().equals(other.temporaryEffects, _temporaryEffects)&&const DeepCollectionEquality().equals(other.organDamage, _organDamage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_illnesses),const DeepCollectionEquality().hash(_addictions),const DeepCollectionEquality().hash(_chronicDamage),const DeepCollectionEquality().hash(_temporaryEffects),const DeepCollectionEquality().hash(_organDamage));
}

@override
String toString() {
    return 'RiskProfileDto(illnesses: $illnesses, addictions: $addictions, chronicDamage: $chronicDamage, temporaryEffects: $temporaryEffects, organDamage: $organDamage)';
}


}

/// @nodoc
abstract mixin class _$RiskProfileDtoCopyWith<$Res> implements $RiskProfileDtoCopyWith<$Res> {
  factory _$RiskProfileDtoCopyWith(_RiskProfileDto value, $Res Function(_RiskProfileDto) _then) = __$RiskProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 List<String> illnesses, List<String> addictions, List<String> chronicDamage, List<String> temporaryEffects, List<String> organDamage
});




}
/// @nodoc
class __$RiskProfileDtoCopyWithImpl<$Res>
    implements _$RiskProfileDtoCopyWith<$Res> {
  __$RiskProfileDtoCopyWithImpl(this._self, this._then);

  final _RiskProfileDto _self;
  final $Res Function(_RiskProfileDto) _then;

/// Create a copy of RiskProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? illnesses = null,Object? addictions = null,Object? chronicDamage = null,Object? temporaryEffects = null,Object? organDamage = null,}) {
  return _then(_RiskProfileDto(
illnesses: null == illnesses ? _self._illnesses : illnesses // ignore: cast_nullable_to_non_nullable
as List<String>,addictions: null == addictions ? _self._addictions : addictions // ignore: cast_nullable_to_non_nullable
as List<String>,chronicDamage: null == chronicDamage ? _self._chronicDamage : chronicDamage // ignore: cast_nullable_to_non_nullable
as List<String>,temporaryEffects: null == temporaryEffects ? _self._temporaryEffects : temporaryEffects // ignore: cast_nullable_to_non_nullable
as List<String>,organDamage: null == organDamage ? _self._organDamage : organDamage // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$BodyMarkerDto {

 String get part; String? get severity; String get reason; String? get trigger;
/// Create a copy of BodyMarkerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyMarkerDtoCopyWith<BodyMarkerDto> get copyWith => _$BodyMarkerDtoCopyWithImpl<BodyMarkerDto>(this as BodyMarkerDto, _$identity);

  /// Serializes this BodyMarkerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BodyMarkerDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyMarkerDto&&(identical(other.part, _this.part) || other.part == _this.part)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.trigger, _this.trigger) || other.trigger == _this.trigger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BodyMarkerDto;
  return Object.hash(runtimeType,_this.part,_this.severity,_this.reason,_this.trigger);
}

@override
String toString() {
  final _this = this as BodyMarkerDto;
  return 'BodyMarkerDto(part: ${_this.part}, severity: ${_this.severity}, reason: ${_this.reason}, trigger: ${_this.trigger})';
}


}

/// @nodoc
abstract mixin class $BodyMarkerDtoCopyWith<$Res>  {
  factory $BodyMarkerDtoCopyWith(BodyMarkerDto value, $Res Function(BodyMarkerDto) _then) = _$BodyMarkerDtoCopyWithImpl;
@useResult
$Res call({
 String part, String? severity, String reason, String? trigger
});




}
/// @nodoc
class _$BodyMarkerDtoCopyWithImpl<$Res>
    implements $BodyMarkerDtoCopyWith<$Res> {
  _$BodyMarkerDtoCopyWithImpl(this._self, this._then);

  final BodyMarkerDto _self;
  final $Res Function(BodyMarkerDto) _then;

/// Create a copy of BodyMarkerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? part = null,Object? severity = freezed,Object? reason = null,Object? trigger = freezed,}) {
  return _then(BodyMarkerDto(
part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyMarkerDto].
extension BodyMarkerDtoPatterns on BodyMarkerDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyMarkerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyMarkerDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyMarkerDto value)  $default,){
final _that = this;
switch (_that) {
case _BodyMarkerDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyMarkerDto value)?  $default,){
final _that = this;
switch (_that) {
case _BodyMarkerDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String part,  String? severity,  String reason,  String? trigger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyMarkerDto() when $default != null:
return $default(_that.part,_that.severity,_that.reason,_that.trigger);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String part,  String? severity,  String reason,  String? trigger)  $default,) {final _that = this;
switch (_that) {
case _BodyMarkerDto():
return $default(_that.part,_that.severity,_that.reason,_that.trigger);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String part,  String? severity,  String reason,  String? trigger)?  $default,) {final _that = this;
switch (_that) {
case _BodyMarkerDto() when $default != null:
return $default(_that.part,_that.severity,_that.reason,_that.trigger);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyMarkerDto implements BodyMarkerDto {
  const _BodyMarkerDto({this.part = '', this.severity, this.reason = '', this.trigger});
  factory _BodyMarkerDto.fromJson(Map<String, dynamic> json) => _$BodyMarkerDtoFromJson(json);

@override@JsonKey() final  String part;
@override final  String? severity;
@override@JsonKey() final  String reason;
@override final  String? trigger;

/// Create a copy of BodyMarkerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyMarkerDtoCopyWith<_BodyMarkerDto> get copyWith => __$BodyMarkerDtoCopyWithImpl<_BodyMarkerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyMarkerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyMarkerDto&&(identical(other.part, part) || other.part == part)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.trigger, trigger) || other.trigger == trigger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,part,severity,reason,trigger);
}

@override
String toString() {
    return 'BodyMarkerDto(part: $part, severity: $severity, reason: $reason, trigger: $trigger)';
}


}

/// @nodoc
abstract mixin class _$BodyMarkerDtoCopyWith<$Res> implements $BodyMarkerDtoCopyWith<$Res> {
  factory _$BodyMarkerDtoCopyWith(_BodyMarkerDto value, $Res Function(_BodyMarkerDto) _then) = __$BodyMarkerDtoCopyWithImpl;
@override @useResult
$Res call({
 String part, String? severity, String reason, String? trigger
});




}
/// @nodoc
class __$BodyMarkerDtoCopyWithImpl<$Res>
    implements _$BodyMarkerDtoCopyWith<$Res> {
  __$BodyMarkerDtoCopyWithImpl(this._self, this._then);

  final _BodyMarkerDto _self;
  final $Res Function(_BodyMarkerDto) _then;

/// Create a copy of BodyMarkerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? part = null,Object? severity = freezed,Object? reason = null,Object? trigger = freezed,}) {
  return _then(_BodyMarkerDto(
part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScanResultDto {

 String get productName; String? get brand; String? get parentCompany; String? get category; String? get rating; num? get healthScore; num? get caloriesKcal; String get summary; List<String> get advantages; List<String> get disadvantages; List<CautionDto> get cautions; String? get personalAdvice; ConsumptionTipDto? get consumptionTip; RiskProfileDto? get riskProfile; List<BodyMarkerDto> get bodyDamage; List<BodyMarkerDto> get bodyBenefit; String? get dietaryType; String? get dietaryReason;
/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<ScanResultDto> get copyWith => _$ScanResultDtoCopyWithImpl<ScanResultDto>(this as ScanResultDto, _$identity);

  /// Serializes this ScanResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScanResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanResultDto&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.parentCompany, _this.parentCompany) || other.parentCompany == _this.parentCompany)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.healthScore, _this.healthScore) || other.healthScore == _this.healthScore)&&(identical(other.caloriesKcal, _this.caloriesKcal) || other.caloriesKcal == _this.caloriesKcal)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.advantages, _this.advantages)&&const DeepCollectionEquality().equals(other.disadvantages, _this.disadvantages)&&const DeepCollectionEquality().equals(other.cautions, _this.cautions)&&(identical(other.personalAdvice, _this.personalAdvice) || other.personalAdvice == _this.personalAdvice)&&(identical(other.consumptionTip, _this.consumptionTip) || other.consumptionTip == _this.consumptionTip)&&(identical(other.riskProfile, _this.riskProfile) || other.riskProfile == _this.riskProfile)&&const DeepCollectionEquality().equals(other.bodyDamage, _this.bodyDamage)&&const DeepCollectionEquality().equals(other.bodyBenefit, _this.bodyBenefit)&&(identical(other.dietaryType, _this.dietaryType) || other.dietaryType == _this.dietaryType)&&(identical(other.dietaryReason, _this.dietaryReason) || other.dietaryReason == _this.dietaryReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScanResultDto;
  return Object.hash(runtimeType,_this.productName,_this.brand,_this.parentCompany,_this.category,_this.rating,_this.healthScore,_this.caloriesKcal,_this.summary,const DeepCollectionEquality().hash(_this.advantages),const DeepCollectionEquality().hash(_this.disadvantages),const DeepCollectionEquality().hash(_this.cautions),_this.personalAdvice,_this.consumptionTip,_this.riskProfile,const DeepCollectionEquality().hash(_this.bodyDamage),const DeepCollectionEquality().hash(_this.bodyBenefit),_this.dietaryType,_this.dietaryReason);
}

@override
String toString() {
  final _this = this as ScanResultDto;
  return 'ScanResultDto(productName: ${_this.productName}, brand: ${_this.brand}, parentCompany: ${_this.parentCompany}, category: ${_this.category}, rating: ${_this.rating}, healthScore: ${_this.healthScore}, caloriesKcal: ${_this.caloriesKcal}, summary: ${_this.summary}, advantages: ${_this.advantages}, disadvantages: ${_this.disadvantages}, cautions: ${_this.cautions}, personalAdvice: ${_this.personalAdvice}, consumptionTip: ${_this.consumptionTip}, riskProfile: ${_this.riskProfile}, bodyDamage: ${_this.bodyDamage}, bodyBenefit: ${_this.bodyBenefit}, dietaryType: ${_this.dietaryType}, dietaryReason: ${_this.dietaryReason})';
}


}

/// @nodoc
abstract mixin class $ScanResultDtoCopyWith<$Res>  {
  factory $ScanResultDtoCopyWith(ScanResultDto value, $Res Function(ScanResultDto) _then) = _$ScanResultDtoCopyWithImpl;
@useResult
$Res call({
 String productName, String? brand, String? parentCompany, String? category, String? rating, num? healthScore, num? caloriesKcal, String summary, List<String> advantages, List<String> disadvantages, List<CautionDto> cautions, String? personalAdvice, ConsumptionTipDto? consumptionTip, RiskProfileDto? riskProfile, List<BodyMarkerDto> bodyDamage, List<BodyMarkerDto> bodyBenefit, String? dietaryType, String? dietaryReason
});


$ConsumptionTipDtoCopyWith<$Res>? get consumptionTip;$RiskProfileDtoCopyWith<$Res>? get riskProfile;

}
/// @nodoc
class _$ScanResultDtoCopyWithImpl<$Res>
    implements $ScanResultDtoCopyWith<$Res> {
  _$ScanResultDtoCopyWithImpl(this._self, this._then);

  final ScanResultDto _self;
  final $Res Function(ScanResultDto) _then;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? brand = freezed,Object? parentCompany = freezed,Object? category = freezed,Object? rating = freezed,Object? healthScore = freezed,Object? caloriesKcal = freezed,Object? summary = null,Object? advantages = null,Object? disadvantages = null,Object? cautions = null,Object? personalAdvice = freezed,Object? consumptionTip = freezed,Object? riskProfile = freezed,Object? bodyDamage = null,Object? bodyBenefit = null,Object? dietaryType = freezed,Object? dietaryReason = freezed,}) {
  return _then(ScanResultDto(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,parentCompany: freezed == parentCompany ? _self.parentCompany : parentCompany // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as num?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as num?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,advantages: null == advantages ? _self.advantages : advantages // ignore: cast_nullable_to_non_nullable
as List<String>,disadvantages: null == disadvantages ? _self.disadvantages : disadvantages // ignore: cast_nullable_to_non_nullable
as List<String>,cautions: null == cautions ? _self.cautions : cautions // ignore: cast_nullable_to_non_nullable
as List<CautionDto>,personalAdvice: freezed == personalAdvice ? _self.personalAdvice : personalAdvice // ignore: cast_nullable_to_non_nullable
as String?,consumptionTip: freezed == consumptionTip ? _self.consumptionTip : consumptionTip // ignore: cast_nullable_to_non_nullable
as ConsumptionTipDto?,riskProfile: freezed == riskProfile ? _self.riskProfile : riskProfile // ignore: cast_nullable_to_non_nullable
as RiskProfileDto?,bodyDamage: null == bodyDamage ? _self.bodyDamage : bodyDamage // ignore: cast_nullable_to_non_nullable
as List<BodyMarkerDto>,bodyBenefit: null == bodyBenefit ? _self.bodyBenefit : bodyBenefit // ignore: cast_nullable_to_non_nullable
as List<BodyMarkerDto>,dietaryType: freezed == dietaryType ? _self.dietaryType : dietaryType // ignore: cast_nullable_to_non_nullable
as String?,dietaryReason: freezed == dietaryReason ? _self.dietaryReason : dietaryReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsumptionTipDtoCopyWith<$Res>? get consumptionTip {
    if (_self.consumptionTip == null) {
    return null;
  }

  return $ConsumptionTipDtoCopyWith<$Res>(_self.consumptionTip!, (value) {
    return _then(_self.copyWith(consumptionTip: value));
  });
}/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiskProfileDtoCopyWith<$Res>? get riskProfile {
    if (_self.riskProfile == null) {
    return null;
  }

  return $RiskProfileDtoCopyWith<$Res>(_self.riskProfile!, (value) {
    return _then(_self.copyWith(riskProfile: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanResultDto].
extension ScanResultDtoPatterns on ScanResultDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanResultDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  String? brand,  String? parentCompany,  String? category,  String? rating,  num? healthScore,  num? caloriesKcal,  String summary,  List<String> advantages,  List<String> disadvantages,  List<CautionDto> cautions,  String? personalAdvice,  ConsumptionTipDto? consumptionTip,  RiskProfileDto? riskProfile,  List<BodyMarkerDto> bodyDamage,  List<BodyMarkerDto> bodyBenefit,  String? dietaryType,  String? dietaryReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that.productName,_that.brand,_that.parentCompany,_that.category,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.advantages,_that.disadvantages,_that.cautions,_that.personalAdvice,_that.consumptionTip,_that.riskProfile,_that.bodyDamage,_that.bodyBenefit,_that.dietaryType,_that.dietaryReason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  String? brand,  String? parentCompany,  String? category,  String? rating,  num? healthScore,  num? caloriesKcal,  String summary,  List<String> advantages,  List<String> disadvantages,  List<CautionDto> cautions,  String? personalAdvice,  ConsumptionTipDto? consumptionTip,  RiskProfileDto? riskProfile,  List<BodyMarkerDto> bodyDamage,  List<BodyMarkerDto> bodyBenefit,  String? dietaryType,  String? dietaryReason)  $default,) {final _that = this;
switch (_that) {
case _ScanResultDto():
return $default(_that.productName,_that.brand,_that.parentCompany,_that.category,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.advantages,_that.disadvantages,_that.cautions,_that.personalAdvice,_that.consumptionTip,_that.riskProfile,_that.bodyDamage,_that.bodyBenefit,_that.dietaryType,_that.dietaryReason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  String? brand,  String? parentCompany,  String? category,  String? rating,  num? healthScore,  num? caloriesKcal,  String summary,  List<String> advantages,  List<String> disadvantages,  List<CautionDto> cautions,  String? personalAdvice,  ConsumptionTipDto? consumptionTip,  RiskProfileDto? riskProfile,  List<BodyMarkerDto> bodyDamage,  List<BodyMarkerDto> bodyBenefit,  String? dietaryType,  String? dietaryReason)?  $default,) {final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that.productName,_that.brand,_that.parentCompany,_that.category,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.advantages,_that.disadvantages,_that.cautions,_that.personalAdvice,_that.consumptionTip,_that.riskProfile,_that.bodyDamage,_that.bodyBenefit,_that.dietaryType,_that.dietaryReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanResultDto implements ScanResultDto {
  const _ScanResultDto({this.productName = '', this.brand, this.parentCompany, this.category, this.rating, this.healthScore, this.caloriesKcal, this.summary = '',  List<String> advantages = const [],  List<String> disadvantages = const [],  List<CautionDto> cautions = const [], this.personalAdvice, this.consumptionTip, this.riskProfile,  List<BodyMarkerDto> bodyDamage = const [],  List<BodyMarkerDto> bodyBenefit = const [], this.dietaryType, this.dietaryReason}): _advantages = advantages,_disadvantages = disadvantages,_cautions = cautions,_bodyDamage = bodyDamage,_bodyBenefit = bodyBenefit;
  factory _ScanResultDto.fromJson(Map<String, dynamic> json) => _$ScanResultDtoFromJson(json);

@override@JsonKey() final  String productName;
@override final  String? brand;
@override final  String? parentCompany;
@override final  String? category;
@override final  String? rating;
@override final  num? healthScore;
@override final  num? caloriesKcal;
@override@JsonKey() final  String summary;
 final  List<String> _advantages;
@override@JsonKey() List<String> get advantages {
  if (_advantages is EqualUnmodifiableListView) return _advantages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_advantages);
}

 final  List<String> _disadvantages;
@override@JsonKey() List<String> get disadvantages {
  if (_disadvantages is EqualUnmodifiableListView) return _disadvantages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disadvantages);
}

 final  List<CautionDto> _cautions;
@override@JsonKey() List<CautionDto> get cautions {
  if (_cautions is EqualUnmodifiableListView) return _cautions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cautions);
}

@override final  String? personalAdvice;
@override final  ConsumptionTipDto? consumptionTip;
@override final  RiskProfileDto? riskProfile;
 final  List<BodyMarkerDto> _bodyDamage;
@override@JsonKey() List<BodyMarkerDto> get bodyDamage {
  if (_bodyDamage is EqualUnmodifiableListView) return _bodyDamage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bodyDamage);
}

 final  List<BodyMarkerDto> _bodyBenefit;
@override@JsonKey() List<BodyMarkerDto> get bodyBenefit {
  if (_bodyBenefit is EqualUnmodifiableListView) return _bodyBenefit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bodyBenefit);
}

@override final  String? dietaryType;
@override final  String? dietaryReason;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanResultDtoCopyWith<_ScanResultDto> get copyWith => __$ScanResultDtoCopyWithImpl<_ScanResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanResultDto&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.parentCompany, parentCompany) || other.parentCompany == parentCompany)&&(identical(other.category, category) || other.category == category)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.advantages, _advantages)&&const DeepCollectionEquality().equals(other.disadvantages, _disadvantages)&&const DeepCollectionEquality().equals(other.cautions, _cautions)&&(identical(other.personalAdvice, personalAdvice) || other.personalAdvice == personalAdvice)&&(identical(other.consumptionTip, consumptionTip) || other.consumptionTip == consumptionTip)&&(identical(other.riskProfile, riskProfile) || other.riskProfile == riskProfile)&&const DeepCollectionEquality().equals(other.bodyDamage, _bodyDamage)&&const DeepCollectionEquality().equals(other.bodyBenefit, _bodyBenefit)&&(identical(other.dietaryType, dietaryType) || other.dietaryType == dietaryType)&&(identical(other.dietaryReason, dietaryReason) || other.dietaryReason == dietaryReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productName,brand,parentCompany,category,rating,healthScore,caloriesKcal,summary,const DeepCollectionEquality().hash(_advantages),const DeepCollectionEquality().hash(_disadvantages),const DeepCollectionEquality().hash(_cautions),personalAdvice,consumptionTip,riskProfile,const DeepCollectionEquality().hash(_bodyDamage),const DeepCollectionEquality().hash(_bodyBenefit),dietaryType,dietaryReason);
}

@override
String toString() {
    return 'ScanResultDto(productName: $productName, brand: $brand, parentCompany: $parentCompany, category: $category, rating: $rating, healthScore: $healthScore, caloriesKcal: $caloriesKcal, summary: $summary, advantages: $advantages, disadvantages: $disadvantages, cautions: $cautions, personalAdvice: $personalAdvice, consumptionTip: $consumptionTip, riskProfile: $riskProfile, bodyDamage: $bodyDamage, bodyBenefit: $bodyBenefit, dietaryType: $dietaryType, dietaryReason: $dietaryReason)';
}


}

/// @nodoc
abstract mixin class _$ScanResultDtoCopyWith<$Res> implements $ScanResultDtoCopyWith<$Res> {
  factory _$ScanResultDtoCopyWith(_ScanResultDto value, $Res Function(_ScanResultDto) _then) = __$ScanResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String productName, String? brand, String? parentCompany, String? category, String? rating, num? healthScore, num? caloriesKcal, String summary, List<String> advantages, List<String> disadvantages, List<CautionDto> cautions, String? personalAdvice, ConsumptionTipDto? consumptionTip, RiskProfileDto? riskProfile, List<BodyMarkerDto> bodyDamage, List<BodyMarkerDto> bodyBenefit, String? dietaryType, String? dietaryReason
});


@override $ConsumptionTipDtoCopyWith<$Res>? get consumptionTip;@override $RiskProfileDtoCopyWith<$Res>? get riskProfile;

}
/// @nodoc
class __$ScanResultDtoCopyWithImpl<$Res>
    implements _$ScanResultDtoCopyWith<$Res> {
  __$ScanResultDtoCopyWithImpl(this._self, this._then);

  final _ScanResultDto _self;
  final $Res Function(_ScanResultDto) _then;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? brand = freezed,Object? parentCompany = freezed,Object? category = freezed,Object? rating = freezed,Object? healthScore = freezed,Object? caloriesKcal = freezed,Object? summary = null,Object? advantages = null,Object? disadvantages = null,Object? cautions = null,Object? personalAdvice = freezed,Object? consumptionTip = freezed,Object? riskProfile = freezed,Object? bodyDamage = null,Object? bodyBenefit = null,Object? dietaryType = freezed,Object? dietaryReason = freezed,}) {
  return _then(_ScanResultDto(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,parentCompany: freezed == parentCompany ? _self.parentCompany : parentCompany // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as num?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as num?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,advantages: null == advantages ? _self._advantages : advantages // ignore: cast_nullable_to_non_nullable
as List<String>,disadvantages: null == disadvantages ? _self._disadvantages : disadvantages // ignore: cast_nullable_to_non_nullable
as List<String>,cautions: null == cautions ? _self._cautions : cautions // ignore: cast_nullable_to_non_nullable
as List<CautionDto>,personalAdvice: freezed == personalAdvice ? _self.personalAdvice : personalAdvice // ignore: cast_nullable_to_non_nullable
as String?,consumptionTip: freezed == consumptionTip ? _self.consumptionTip : consumptionTip // ignore: cast_nullable_to_non_nullable
as ConsumptionTipDto?,riskProfile: freezed == riskProfile ? _self.riskProfile : riskProfile // ignore: cast_nullable_to_non_nullable
as RiskProfileDto?,bodyDamage: null == bodyDamage ? _self._bodyDamage : bodyDamage // ignore: cast_nullable_to_non_nullable
as List<BodyMarkerDto>,bodyBenefit: null == bodyBenefit ? _self._bodyBenefit : bodyBenefit // ignore: cast_nullable_to_non_nullable
as List<BodyMarkerDto>,dietaryType: freezed == dietaryType ? _self.dietaryType : dietaryType // ignore: cast_nullable_to_non_nullable
as String?,dietaryReason: freezed == dietaryReason ? _self.dietaryReason : dietaryReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsumptionTipDtoCopyWith<$Res>? get consumptionTip {
    if (_self.consumptionTip == null) {
    return null;
  }

  return $ConsumptionTipDtoCopyWith<$Res>(_self.consumptionTip!, (value) {
    return _then(_self.copyWith(consumptionTip: value));
  });
}/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiskProfileDtoCopyWith<$Res>? get riskProfile {
    if (_self.riskProfile == null) {
    return null;
  }

  return $RiskProfileDtoCopyWith<$Res>(_self.riskProfile!, (value) {
    return _then(_self.copyWith(riskProfile: value));
  });
}
}


/// @nodoc
mixin _$ScanEnvelopeDto {

 ScanResultDto get result; String? get scanId; int get remaining; int get scanLimit; String get plan; String get planLabel; bool get isUnlimited; String? get source; bool get cached; String? get barcode;
/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanEnvelopeDtoCopyWith<ScanEnvelopeDto> get copyWith => _$ScanEnvelopeDtoCopyWithImpl<ScanEnvelopeDto>(this as ScanEnvelopeDto, _$identity);

  /// Serializes this ScanEnvelopeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScanEnvelopeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanEnvelopeDto&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.scanId, _this.scanId) || other.scanId == _this.scanId)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.scanLimit, _this.scanLimit) || other.scanLimit == _this.scanLimit)&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.planLabel, _this.planLabel) || other.planLabel == _this.planLabel)&&(identical(other.isUnlimited, _this.isUnlimited) || other.isUnlimited == _this.isUnlimited)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.cached, _this.cached) || other.cached == _this.cached)&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScanEnvelopeDto;
  return Object.hash(runtimeType,_this.result,_this.scanId,_this.remaining,_this.scanLimit,_this.plan,_this.planLabel,_this.isUnlimited,_this.source,_this.cached,_this.barcode);
}

@override
String toString() {
  final _this = this as ScanEnvelopeDto;
  return 'ScanEnvelopeDto(result: ${_this.result}, scanId: ${_this.scanId}, remaining: ${_this.remaining}, scanLimit: ${_this.scanLimit}, plan: ${_this.plan}, planLabel: ${_this.planLabel}, isUnlimited: ${_this.isUnlimited}, source: ${_this.source}, cached: ${_this.cached}, barcode: ${_this.barcode})';
}


}

/// @nodoc
abstract mixin class $ScanEnvelopeDtoCopyWith<$Res>  {
  factory $ScanEnvelopeDtoCopyWith(ScanEnvelopeDto value, $Res Function(ScanEnvelopeDto) _then) = _$ScanEnvelopeDtoCopyWithImpl;
@useResult
$Res call({
 ScanResultDto result, String? scanId, int remaining, int scanLimit, String plan, String planLabel, bool isUnlimited, String? source, bool cached, String? barcode
});


$ScanResultDtoCopyWith<$Res> get result;

}
/// @nodoc
class _$ScanEnvelopeDtoCopyWithImpl<$Res>
    implements $ScanEnvelopeDtoCopyWith<$Res> {
  _$ScanEnvelopeDtoCopyWithImpl(this._self, this._then);

  final ScanEnvelopeDto _self;
  final $Res Function(ScanEnvelopeDto) _then;

/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = null,Object? scanId = freezed,Object? remaining = null,Object? scanLimit = null,Object? plan = null,Object? planLabel = null,Object? isUnlimited = null,Object? source = freezed,Object? cached = null,Object? barcode = freezed,}) {
  return _then(ScanEnvelopeDto(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScanResultDto,scanId: freezed == scanId ? _self.scanId : scanId // ignore: cast_nullable_to_non_nullable
as String?,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,scanLimit: null == scanLimit ? _self.scanLimit : scanLimit // ignore: cast_nullable_to_non_nullable
as int,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,isUnlimited: null == isUnlimited ? _self.isUnlimited : isUnlimited // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<$Res> get result {
  
  return $ScanResultDtoCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanEnvelopeDto].
extension ScanEnvelopeDtoPatterns on ScanEnvelopeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanEnvelopeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanEnvelopeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanEnvelopeDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanEnvelopeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanEnvelopeDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanEnvelopeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScanResultDto result,  String? scanId,  int remaining,  int scanLimit,  String plan,  String planLabel,  bool isUnlimited,  String? source,  bool cached,  String? barcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanEnvelopeDto() when $default != null:
return $default(_that.result,_that.scanId,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.source,_that.cached,_that.barcode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScanResultDto result,  String? scanId,  int remaining,  int scanLimit,  String plan,  String planLabel,  bool isUnlimited,  String? source,  bool cached,  String? barcode)  $default,) {final _that = this;
switch (_that) {
case _ScanEnvelopeDto():
return $default(_that.result,_that.scanId,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.source,_that.cached,_that.barcode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScanResultDto result,  String? scanId,  int remaining,  int scanLimit,  String plan,  String planLabel,  bool isUnlimited,  String? source,  bool cached,  String? barcode)?  $default,) {final _that = this;
switch (_that) {
case _ScanEnvelopeDto() when $default != null:
return $default(_that.result,_that.scanId,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.source,_that.cached,_that.barcode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanEnvelopeDto implements ScanEnvelopeDto {
  const _ScanEnvelopeDto({required this.result, this.scanId, this.remaining = 0, this.scanLimit = 0, this.plan = 'free', this.planLabel = 'Free', this.isUnlimited = false, this.source, this.cached = false, this.barcode});
  factory _ScanEnvelopeDto.fromJson(Map<String, dynamic> json) => _$ScanEnvelopeDtoFromJson(json);

@override final  ScanResultDto result;
@override final  String? scanId;
@override@JsonKey() final  int remaining;
@override@JsonKey() final  int scanLimit;
@override@JsonKey() final  String plan;
@override@JsonKey() final  String planLabel;
@override@JsonKey() final  bool isUnlimited;
@override final  String? source;
@override@JsonKey() final  bool cached;
@override final  String? barcode;

/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanEnvelopeDtoCopyWith<_ScanEnvelopeDto> get copyWith => __$ScanEnvelopeDtoCopyWithImpl<_ScanEnvelopeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanEnvelopeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanEnvelopeDto&&(identical(other.result, result) || other.result == result)&&(identical(other.scanId, scanId) || other.scanId == scanId)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.scanLimit, scanLimit) || other.scanLimit == scanLimit)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.isUnlimited, isUnlimited) || other.isUnlimited == isUnlimited)&&(identical(other.source, source) || other.source == source)&&(identical(other.cached, cached) || other.cached == cached)&&(identical(other.barcode, barcode) || other.barcode == barcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,result,scanId,remaining,scanLimit,plan,planLabel,isUnlimited,source,cached,barcode);
}

@override
String toString() {
    return 'ScanEnvelopeDto(result: $result, scanId: $scanId, remaining: $remaining, scanLimit: $scanLimit, plan: $plan, planLabel: $planLabel, isUnlimited: $isUnlimited, source: $source, cached: $cached, barcode: $barcode)';
}


}

/// @nodoc
abstract mixin class _$ScanEnvelopeDtoCopyWith<$Res> implements $ScanEnvelopeDtoCopyWith<$Res> {
  factory _$ScanEnvelopeDtoCopyWith(_ScanEnvelopeDto value, $Res Function(_ScanEnvelopeDto) _then) = __$ScanEnvelopeDtoCopyWithImpl;
@override @useResult
$Res call({
 ScanResultDto result, String? scanId, int remaining, int scanLimit, String plan, String planLabel, bool isUnlimited, String? source, bool cached, String? barcode
});


@override $ScanResultDtoCopyWith<$Res> get result;

}
/// @nodoc
class __$ScanEnvelopeDtoCopyWithImpl<$Res>
    implements _$ScanEnvelopeDtoCopyWith<$Res> {
  __$ScanEnvelopeDtoCopyWithImpl(this._self, this._then);

  final _ScanEnvelopeDto _self;
  final $Res Function(_ScanEnvelopeDto) _then;

/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = null,Object? scanId = freezed,Object? remaining = null,Object? scanLimit = null,Object? plan = null,Object? planLabel = null,Object? isUnlimited = null,Object? source = freezed,Object? cached = null,Object? barcode = freezed,}) {
  return _then(_ScanEnvelopeDto(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScanResultDto,scanId: freezed == scanId ? _self.scanId : scanId // ignore: cast_nullable_to_non_nullable
as String?,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,scanLimit: null == scanLimit ? _self.scanLimit : scanLimit // ignore: cast_nullable_to_non_nullable
as int,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,isUnlimited: null == isUnlimited ? _self.isUnlimited : isUnlimited // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ScanEnvelopeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<$Res> get result {
  
  return $ScanResultDtoCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// @nodoc
mixin _$ScanErrorDto {

 String get error; String? get message; int? get remaining; int? get scanLimit; String? get plan; String? get planLabel; bool? get isUnlimited; String? get localBarcode;
/// Create a copy of ScanErrorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanErrorDtoCopyWith<ScanErrorDto> get copyWith => _$ScanErrorDtoCopyWithImpl<ScanErrorDto>(this as ScanErrorDto, _$identity);

  /// Serializes this ScanErrorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScanErrorDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanErrorDto&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.scanLimit, _this.scanLimit) || other.scanLimit == _this.scanLimit)&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.planLabel, _this.planLabel) || other.planLabel == _this.planLabel)&&(identical(other.isUnlimited, _this.isUnlimited) || other.isUnlimited == _this.isUnlimited)&&(identical(other.localBarcode, _this.localBarcode) || other.localBarcode == _this.localBarcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScanErrorDto;
  return Object.hash(runtimeType,_this.error,_this.message,_this.remaining,_this.scanLimit,_this.plan,_this.planLabel,_this.isUnlimited,_this.localBarcode);
}

@override
String toString() {
  final _this = this as ScanErrorDto;
  return 'ScanErrorDto(error: ${_this.error}, message: ${_this.message}, remaining: ${_this.remaining}, scanLimit: ${_this.scanLimit}, plan: ${_this.plan}, planLabel: ${_this.planLabel}, isUnlimited: ${_this.isUnlimited}, localBarcode: ${_this.localBarcode})';
}


}

/// @nodoc
abstract mixin class $ScanErrorDtoCopyWith<$Res>  {
  factory $ScanErrorDtoCopyWith(ScanErrorDto value, $Res Function(ScanErrorDto) _then) = _$ScanErrorDtoCopyWithImpl;
@useResult
$Res call({
 String error, String? message, int? remaining, int? scanLimit, String? plan, String? planLabel, bool? isUnlimited, String? localBarcode
});




}
/// @nodoc
class _$ScanErrorDtoCopyWithImpl<$Res>
    implements $ScanErrorDtoCopyWith<$Res> {
  _$ScanErrorDtoCopyWithImpl(this._self, this._then);

  final ScanErrorDto _self;
  final $Res Function(ScanErrorDto) _then;

/// Create a copy of ScanErrorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,Object? message = freezed,Object? remaining = freezed,Object? scanLimit = freezed,Object? plan = freezed,Object? planLabel = freezed,Object? isUnlimited = freezed,Object? localBarcode = freezed,}) {
  return _then(ScanErrorDto(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,scanLimit: freezed == scanLimit ? _self.scanLimit : scanLimit // ignore: cast_nullable_to_non_nullable
as int?,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String?,planLabel: freezed == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String?,isUnlimited: freezed == isUnlimited ? _self.isUnlimited : isUnlimited // ignore: cast_nullable_to_non_nullable
as bool?,localBarcode: freezed == localBarcode ? _self.localBarcode : localBarcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanErrorDto].
extension ScanErrorDtoPatterns on ScanErrorDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanErrorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanErrorDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanErrorDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanErrorDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanErrorDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanErrorDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String error,  String? message,  int? remaining,  int? scanLimit,  String? plan,  String? planLabel,  bool? isUnlimited,  String? localBarcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanErrorDto() when $default != null:
return $default(_that.error,_that.message,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.localBarcode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String error,  String? message,  int? remaining,  int? scanLimit,  String? plan,  String? planLabel,  bool? isUnlimited,  String? localBarcode)  $default,) {final _that = this;
switch (_that) {
case _ScanErrorDto():
return $default(_that.error,_that.message,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.localBarcode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String error,  String? message,  int? remaining,  int? scanLimit,  String? plan,  String? planLabel,  bool? isUnlimited,  String? localBarcode)?  $default,) {final _that = this;
switch (_that) {
case _ScanErrorDto() when $default != null:
return $default(_that.error,_that.message,_that.remaining,_that.scanLimit,_that.plan,_that.planLabel,_that.isUnlimited,_that.localBarcode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanErrorDto implements ScanErrorDto {
  const _ScanErrorDto({required this.error, this.message, this.remaining, this.scanLimit, this.plan, this.planLabel, this.isUnlimited, this.localBarcode});
  factory _ScanErrorDto.fromJson(Map<String, dynamic> json) => _$ScanErrorDtoFromJson(json);

@override final  String error;
@override final  String? message;
@override final  int? remaining;
@override final  int? scanLimit;
@override final  String? plan;
@override final  String? planLabel;
@override final  bool? isUnlimited;
@override final  String? localBarcode;

/// Create a copy of ScanErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanErrorDtoCopyWith<_ScanErrorDto> get copyWith => __$ScanErrorDtoCopyWithImpl<_ScanErrorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanErrorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanErrorDto&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.scanLimit, scanLimit) || other.scanLimit == scanLimit)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.isUnlimited, isUnlimited) || other.isUnlimited == isUnlimited)&&(identical(other.localBarcode, localBarcode) || other.localBarcode == localBarcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,error,message,remaining,scanLimit,plan,planLabel,isUnlimited,localBarcode);
}

@override
String toString() {
    return 'ScanErrorDto(error: $error, message: $message, remaining: $remaining, scanLimit: $scanLimit, plan: $plan, planLabel: $planLabel, isUnlimited: $isUnlimited, localBarcode: $localBarcode)';
}


}

/// @nodoc
abstract mixin class _$ScanErrorDtoCopyWith<$Res> implements $ScanErrorDtoCopyWith<$Res> {
  factory _$ScanErrorDtoCopyWith(_ScanErrorDto value, $Res Function(_ScanErrorDto) _then) = __$ScanErrorDtoCopyWithImpl;
@override @useResult
$Res call({
 String error, String? message, int? remaining, int? scanLimit, String? plan, String? planLabel, bool? isUnlimited, String? localBarcode
});




}
/// @nodoc
class __$ScanErrorDtoCopyWithImpl<$Res>
    implements _$ScanErrorDtoCopyWith<$Res> {
  __$ScanErrorDtoCopyWithImpl(this._self, this._then);

  final _ScanErrorDto _self;
  final $Res Function(_ScanErrorDto) _then;

/// Create a copy of ScanErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,Object? message = freezed,Object? remaining = freezed,Object? scanLimit = freezed,Object? plan = freezed,Object? planLabel = freezed,Object? isUnlimited = freezed,Object? localBarcode = freezed,}) {
  return _then(_ScanErrorDto(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,scanLimit: freezed == scanLimit ? _self.scanLimit : scanLimit // ignore: cast_nullable_to_non_nullable
as int?,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String?,planLabel: freezed == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String?,isUnlimited: freezed == isUnlimited ? _self.isUnlimited : isUnlimited // ignore: cast_nullable_to_non_nullable
as bool?,localBarcode: freezed == localBarcode ? _self.localBarcode : localBarcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScanRowDto {

 String get id;@JsonKey(name: 'product_name') String? get productName;@JsonKey(name: 'scan_type') String get scanType; String? get rating;@JsonKey(name: 'health_score') num? get healthScore;@JsonKey(name: 'calories_kcal') num? get caloriesKcal; String? get summary;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of ScanRowDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanRowDtoCopyWith<ScanRowDto> get copyWith => _$ScanRowDtoCopyWithImpl<ScanRowDto>(this as ScanRowDto, _$identity);

  /// Serializes this ScanRowDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScanRowDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanRowDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.scanType, _this.scanType) || other.scanType == _this.scanType)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.healthScore, _this.healthScore) || other.healthScore == _this.healthScore)&&(identical(other.caloriesKcal, _this.caloriesKcal) || other.caloriesKcal == _this.caloriesKcal)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScanRowDto;
  return Object.hash(runtimeType,_this.id,_this.productName,_this.scanType,_this.rating,_this.healthScore,_this.caloriesKcal,_this.summary,_this.createdAt);
}

@override
String toString() {
  final _this = this as ScanRowDto;
  return 'ScanRowDto(id: ${_this.id}, productName: ${_this.productName}, scanType: ${_this.scanType}, rating: ${_this.rating}, healthScore: ${_this.healthScore}, caloriesKcal: ${_this.caloriesKcal}, summary: ${_this.summary}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ScanRowDtoCopyWith<$Res>  {
  factory $ScanRowDtoCopyWith(ScanRowDto value, $Res Function(ScanRowDto) _then) = _$ScanRowDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'scan_type') String scanType, String? rating,@JsonKey(name: 'health_score') num? healthScore,@JsonKey(name: 'calories_kcal') num? caloriesKcal, String? summary,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$ScanRowDtoCopyWithImpl<$Res>
    implements $ScanRowDtoCopyWith<$Res> {
  _$ScanRowDtoCopyWithImpl(this._self, this._then);

  final ScanRowDto _self;
  final $Res Function(ScanRowDto) _then;

/// Create a copy of ScanRowDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productName = freezed,Object? scanType = null,Object? rating = freezed,Object? healthScore = freezed,Object? caloriesKcal = freezed,Object? summary = freezed,Object? createdAt = null,}) {
  return _then(ScanRowDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,scanType: null == scanType ? _self.scanType : scanType // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as num?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as num?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanRowDto].
extension ScanRowDtoPatterns on ScanRowDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanRowDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanRowDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanRowDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanRowDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanRowDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanRowDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'scan_type')  String scanType,  String? rating, @JsonKey(name: 'health_score')  num? healthScore, @JsonKey(name: 'calories_kcal')  num? caloriesKcal,  String? summary, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanRowDto() when $default != null:
return $default(_that.id,_that.productName,_that.scanType,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'scan_type')  String scanType,  String? rating, @JsonKey(name: 'health_score')  num? healthScore, @JsonKey(name: 'calories_kcal')  num? caloriesKcal,  String? summary, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _ScanRowDto():
return $default(_that.id,_that.productName,_that.scanType,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'scan_type')  String scanType,  String? rating, @JsonKey(name: 'health_score')  num? healthScore, @JsonKey(name: 'calories_kcal')  num? caloriesKcal,  String? summary, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ScanRowDto() when $default != null:
return $default(_that.id,_that.productName,_that.scanType,_that.rating,_that.healthScore,_that.caloriesKcal,_that.summary,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanRowDto implements ScanRowDto {
  const _ScanRowDto({required this.id, @JsonKey(name: 'product_name') this.productName, @JsonKey(name: 'scan_type') this.scanType = 'ingredients', this.rating, @JsonKey(name: 'health_score') this.healthScore, @JsonKey(name: 'calories_kcal') this.caloriesKcal, this.summary, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ScanRowDto.fromJson(Map<String, dynamic> json) => _$ScanRowDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'product_name') final  String? productName;
@override@JsonKey(name: 'scan_type') final  String scanType;
@override final  String? rating;
@override@JsonKey(name: 'health_score') final  num? healthScore;
@override@JsonKey(name: 'calories_kcal') final  num? caloriesKcal;
@override final  String? summary;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of ScanRowDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanRowDtoCopyWith<_ScanRowDto> get copyWith => __$ScanRowDtoCopyWithImpl<_ScanRowDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanRowDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanRowDto&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.scanType, scanType) || other.scanType == scanType)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productName,scanType,rating,healthScore,caloriesKcal,summary,createdAt);
}

@override
String toString() {
    return 'ScanRowDto(id: $id, productName: $productName, scanType: $scanType, rating: $rating, healthScore: $healthScore, caloriesKcal: $caloriesKcal, summary: $summary, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ScanRowDtoCopyWith<$Res> implements $ScanRowDtoCopyWith<$Res> {
  factory _$ScanRowDtoCopyWith(_ScanRowDto value, $Res Function(_ScanRowDto) _then) = __$ScanRowDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'scan_type') String scanType, String? rating,@JsonKey(name: 'health_score') num? healthScore,@JsonKey(name: 'calories_kcal') num? caloriesKcal, String? summary,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$ScanRowDtoCopyWithImpl<$Res>
    implements _$ScanRowDtoCopyWith<$Res> {
  __$ScanRowDtoCopyWithImpl(this._self, this._then);

  final _ScanRowDto _self;
  final $Res Function(_ScanRowDto) _then;

/// Create a copy of ScanRowDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productName = freezed,Object? scanType = null,Object? rating = freezed,Object? healthScore = freezed,Object? caloriesKcal = freezed,Object? summary = freezed,Object? createdAt = null,}) {
  return _then(_ScanRowDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,scanType: null == scanType ? _self.scanType : scanType // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as num?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as num?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ScanDetailRowDto {

 String get id;@JsonKey(name: 'scan_type') String get scanType;@JsonKey(name: 'created_at') String get createdAt; ScanResultDto get result;
/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanDetailRowDtoCopyWith<ScanDetailRowDto> get copyWith => _$ScanDetailRowDtoCopyWithImpl<ScanDetailRowDto>(this as ScanDetailRowDto, _$identity);

  /// Serializes this ScanDetailRowDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScanDetailRowDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanDetailRowDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scanType, _this.scanType) || other.scanType == _this.scanType)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.result, _this.result) || other.result == _this.result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScanDetailRowDto;
  return Object.hash(runtimeType,_this.id,_this.scanType,_this.createdAt,_this.result);
}

@override
String toString() {
  final _this = this as ScanDetailRowDto;
  return 'ScanDetailRowDto(id: ${_this.id}, scanType: ${_this.scanType}, createdAt: ${_this.createdAt}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $ScanDetailRowDtoCopyWith<$Res>  {
  factory $ScanDetailRowDtoCopyWith(ScanDetailRowDto value, $Res Function(ScanDetailRowDto) _then) = _$ScanDetailRowDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'scan_type') String scanType,@JsonKey(name: 'created_at') String createdAt, ScanResultDto result
});


$ScanResultDtoCopyWith<$Res> get result;

}
/// @nodoc
class _$ScanDetailRowDtoCopyWithImpl<$Res>
    implements $ScanDetailRowDtoCopyWith<$Res> {
  _$ScanDetailRowDtoCopyWithImpl(this._self, this._then);

  final ScanDetailRowDto _self;
  final $Res Function(ScanDetailRowDto) _then;

/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scanType = null,Object? createdAt = null,Object? result = null,}) {
  return _then(ScanDetailRowDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scanType: null == scanType ? _self.scanType : scanType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScanResultDto,
  ));
}
/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<$Res> get result {
  
  return $ScanResultDtoCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanDetailRowDto].
extension ScanDetailRowDtoPatterns on ScanDetailRowDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanDetailRowDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanDetailRowDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanDetailRowDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanDetailRowDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanDetailRowDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanDetailRowDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scan_type')  String scanType, @JsonKey(name: 'created_at')  String createdAt,  ScanResultDto result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanDetailRowDto() when $default != null:
return $default(_that.id,_that.scanType,_that.createdAt,_that.result);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scan_type')  String scanType, @JsonKey(name: 'created_at')  String createdAt,  ScanResultDto result)  $default,) {final _that = this;
switch (_that) {
case _ScanDetailRowDto():
return $default(_that.id,_that.scanType,_that.createdAt,_that.result);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'scan_type')  String scanType, @JsonKey(name: 'created_at')  String createdAt,  ScanResultDto result)?  $default,) {final _that = this;
switch (_that) {
case _ScanDetailRowDto() when $default != null:
return $default(_that.id,_that.scanType,_that.createdAt,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanDetailRowDto implements ScanDetailRowDto {
  const _ScanDetailRowDto({required this.id, @JsonKey(name: 'scan_type') this.scanType = 'ingredients', @JsonKey(name: 'created_at') required this.createdAt, required this.result});
  factory _ScanDetailRowDto.fromJson(Map<String, dynamic> json) => _$ScanDetailRowDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'scan_type') final  String scanType;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override final  ScanResultDto result;

/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanDetailRowDtoCopyWith<_ScanDetailRowDto> get copyWith => __$ScanDetailRowDtoCopyWithImpl<_ScanDetailRowDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanDetailRowDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanDetailRowDto&&(identical(other.id, id) || other.id == id)&&(identical(other.scanType, scanType) || other.scanType == scanType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,scanType,createdAt,result);
}

@override
String toString() {
    return 'ScanDetailRowDto(id: $id, scanType: $scanType, createdAt: $createdAt, result: $result)';
}


}

/// @nodoc
abstract mixin class _$ScanDetailRowDtoCopyWith<$Res> implements $ScanDetailRowDtoCopyWith<$Res> {
  factory _$ScanDetailRowDtoCopyWith(_ScanDetailRowDto value, $Res Function(_ScanDetailRowDto) _then) = __$ScanDetailRowDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'scan_type') String scanType,@JsonKey(name: 'created_at') String createdAt, ScanResultDto result
});


@override $ScanResultDtoCopyWith<$Res> get result;

}
/// @nodoc
class __$ScanDetailRowDtoCopyWithImpl<$Res>
    implements _$ScanDetailRowDtoCopyWith<$Res> {
  __$ScanDetailRowDtoCopyWithImpl(this._self, this._then);

  final _ScanDetailRowDto _self;
  final $Res Function(_ScanDetailRowDto) _then;

/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scanType = null,Object? createdAt = null,Object? result = null,}) {
  return _then(_ScanDetailRowDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scanType: null == scanType ? _self.scanType : scanType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScanResultDto,
  ));
}

/// Create a copy of ScanDetailRowDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<$Res> get result {
  
  return $ScanResultDtoCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
