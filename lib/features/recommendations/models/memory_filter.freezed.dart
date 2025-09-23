// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemoryFilter _$MemoryFilterFromJson(Map<String, dynamic> json) {
  return _MemoryFilter.fromJson(json);
}

/// @nodoc
mixin _$MemoryFilter {
  List<MemoryType> get allowedTypes => throw _privateConstructorUsedError;
  List<MemoryType> get excludedTypes => throw _privateConstructorUsedError;
  double get minRelevance => throw _privateConstructorUsedError;
  double get maxRelevance => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<String> get requiredTags => throw _privateConstructorUsedError;
  List<String> get excludedTags => throw _privateConstructorUsedError;
  bool get excludeViewed => throw _privateConstructorUsedError;
  bool get excludeBookmarked => throw _privateConstructorUsedError;
  int get maxResults => throw _privateConstructorUsedError;
  MemorySortBy get sortBy => throw _privateConstructorUsedError;
  SortOrder get sortOrder => throw _privateConstructorUsedError;
  bool get enableYesterdayMemories => throw _privateConstructorUsedError;
  bool get enableOneWeekAgoMemories => throw _privateConstructorUsedError;
  bool get enableOneMonthAgoMemories => throw _privateConstructorUsedError;
  bool get enableOneYearAgoMemories => throw _privateConstructorUsedError;
  bool get enablePastTodayMemories => throw _privateConstructorUsedError;
  bool get enableSameTimeMemories => throw _privateConstructorUsedError;
  bool get enableSeasonalMemories => throw _privateConstructorUsedError;
  bool get enableSpecialDateMemories => throw _privateConstructorUsedError;
  bool get enableSimilarTagsMemories => throw _privateConstructorUsedError;

  /// Serializes this MemoryFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryFilterCopyWith<MemoryFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryFilterCopyWith<$Res> {
  factory $MemoryFilterCopyWith(
    MemoryFilter value,
    $Res Function(MemoryFilter) then,
  ) = _$MemoryFilterCopyWithImpl<$Res, MemoryFilter>;
  @useResult
  $Res call({
    List<MemoryType> allowedTypes,
    List<MemoryType> excludedTypes,
    double minRelevance,
    double maxRelevance,
    DateTime? startDate,
    DateTime? endDate,
    List<String> requiredTags,
    List<String> excludedTags,
    bool excludeViewed,
    bool excludeBookmarked,
    int maxResults,
    MemorySortBy sortBy,
    SortOrder sortOrder,
    bool enableYesterdayMemories,
    bool enableOneWeekAgoMemories,
    bool enableOneMonthAgoMemories,
    bool enableOneYearAgoMemories,
    bool enablePastTodayMemories,
    bool enableSameTimeMemories,
    bool enableSeasonalMemories,
    bool enableSpecialDateMemories,
    bool enableSimilarTagsMemories,
  });
}

/// @nodoc
class _$MemoryFilterCopyWithImpl<$Res, $Val extends MemoryFilter>
    implements $MemoryFilterCopyWith<$Res> {
  _$MemoryFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowedTypes = null,
    Object? excludedTypes = null,
    Object? minRelevance = null,
    Object? maxRelevance = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? requiredTags = null,
    Object? excludedTags = null,
    Object? excludeViewed = null,
    Object? excludeBookmarked = null,
    Object? maxResults = null,
    Object? sortBy = null,
    Object? sortOrder = null,
    Object? enableYesterdayMemories = null,
    Object? enableOneWeekAgoMemories = null,
    Object? enableOneMonthAgoMemories = null,
    Object? enableOneYearAgoMemories = null,
    Object? enablePastTodayMemories = null,
    Object? enableSameTimeMemories = null,
    Object? enableSeasonalMemories = null,
    Object? enableSpecialDateMemories = null,
    Object? enableSimilarTagsMemories = null,
  }) {
    return _then(
      _value.copyWith(
            allowedTypes: null == allowedTypes
                ? _value.allowedTypes
                : allowedTypes // ignore: cast_nullable_to_non_nullable
                      as List<MemoryType>,
            excludedTypes: null == excludedTypes
                ? _value.excludedTypes
                : excludedTypes // ignore: cast_nullable_to_non_nullable
                      as List<MemoryType>,
            minRelevance: null == minRelevance
                ? _value.minRelevance
                : minRelevance // ignore: cast_nullable_to_non_nullable
                      as double,
            maxRelevance: null == maxRelevance
                ? _value.maxRelevance
                : maxRelevance // ignore: cast_nullable_to_non_nullable
                      as double,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            requiredTags: null == requiredTags
                ? _value.requiredTags
                : requiredTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            excludedTags: null == excludedTags
                ? _value.excludedTags
                : excludedTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            excludeViewed: null == excludeViewed
                ? _value.excludeViewed
                : excludeViewed // ignore: cast_nullable_to_non_nullable
                      as bool,
            excludeBookmarked: null == excludeBookmarked
                ? _value.excludeBookmarked
                : excludeBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxResults: null == maxResults
                ? _value.maxResults
                : maxResults // ignore: cast_nullable_to_non_nullable
                      as int,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as MemorySortBy,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as SortOrder,
            enableYesterdayMemories: null == enableYesterdayMemories
                ? _value.enableYesterdayMemories
                : enableYesterdayMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneWeekAgoMemories: null == enableOneWeekAgoMemories
                ? _value.enableOneWeekAgoMemories
                : enableOneWeekAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneMonthAgoMemories: null == enableOneMonthAgoMemories
                ? _value.enableOneMonthAgoMemories
                : enableOneMonthAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneYearAgoMemories: null == enableOneYearAgoMemories
                ? _value.enableOneYearAgoMemories
                : enableOneYearAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enablePastTodayMemories: null == enablePastTodayMemories
                ? _value.enablePastTodayMemories
                : enablePastTodayMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSameTimeMemories: null == enableSameTimeMemories
                ? _value.enableSameTimeMemories
                : enableSameTimeMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSeasonalMemories: null == enableSeasonalMemories
                ? _value.enableSeasonalMemories
                : enableSeasonalMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSpecialDateMemories: null == enableSpecialDateMemories
                ? _value.enableSpecialDateMemories
                : enableSpecialDateMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSimilarTagsMemories: null == enableSimilarTagsMemories
                ? _value.enableSimilarTagsMemories
                : enableSimilarTagsMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryFilterImplCopyWith<$Res>
    implements $MemoryFilterCopyWith<$Res> {
  factory _$$MemoryFilterImplCopyWith(
    _$MemoryFilterImpl value,
    $Res Function(_$MemoryFilterImpl) then,
  ) = __$$MemoryFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MemoryType> allowedTypes,
    List<MemoryType> excludedTypes,
    double minRelevance,
    double maxRelevance,
    DateTime? startDate,
    DateTime? endDate,
    List<String> requiredTags,
    List<String> excludedTags,
    bool excludeViewed,
    bool excludeBookmarked,
    int maxResults,
    MemorySortBy sortBy,
    SortOrder sortOrder,
    bool enableYesterdayMemories,
    bool enableOneWeekAgoMemories,
    bool enableOneMonthAgoMemories,
    bool enableOneYearAgoMemories,
    bool enablePastTodayMemories,
    bool enableSameTimeMemories,
    bool enableSeasonalMemories,
    bool enableSpecialDateMemories,
    bool enableSimilarTagsMemories,
  });
}

/// @nodoc
class __$$MemoryFilterImplCopyWithImpl<$Res>
    extends _$MemoryFilterCopyWithImpl<$Res, _$MemoryFilterImpl>
    implements _$$MemoryFilterImplCopyWith<$Res> {
  __$$MemoryFilterImplCopyWithImpl(
    _$MemoryFilterImpl _value,
    $Res Function(_$MemoryFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowedTypes = null,
    Object? excludedTypes = null,
    Object? minRelevance = null,
    Object? maxRelevance = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? requiredTags = null,
    Object? excludedTags = null,
    Object? excludeViewed = null,
    Object? excludeBookmarked = null,
    Object? maxResults = null,
    Object? sortBy = null,
    Object? sortOrder = null,
    Object? enableYesterdayMemories = null,
    Object? enableOneWeekAgoMemories = null,
    Object? enableOneMonthAgoMemories = null,
    Object? enableOneYearAgoMemories = null,
    Object? enablePastTodayMemories = null,
    Object? enableSameTimeMemories = null,
    Object? enableSeasonalMemories = null,
    Object? enableSpecialDateMemories = null,
    Object? enableSimilarTagsMemories = null,
  }) {
    return _then(
      _$MemoryFilterImpl(
        allowedTypes: null == allowedTypes
            ? _value._allowedTypes
            : allowedTypes // ignore: cast_nullable_to_non_nullable
                  as List<MemoryType>,
        excludedTypes: null == excludedTypes
            ? _value._excludedTypes
            : excludedTypes // ignore: cast_nullable_to_non_nullable
                  as List<MemoryType>,
        minRelevance: null == minRelevance
            ? _value.minRelevance
            : minRelevance // ignore: cast_nullable_to_non_nullable
                  as double,
        maxRelevance: null == maxRelevance
            ? _value.maxRelevance
            : maxRelevance // ignore: cast_nullable_to_non_nullable
                  as double,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        requiredTags: null == requiredTags
            ? _value._requiredTags
            : requiredTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        excludedTags: null == excludedTags
            ? _value._excludedTags
            : excludedTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        excludeViewed: null == excludeViewed
            ? _value.excludeViewed
            : excludeViewed // ignore: cast_nullable_to_non_nullable
                  as bool,
        excludeBookmarked: null == excludeBookmarked
            ? _value.excludeBookmarked
            : excludeBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxResults: null == maxResults
            ? _value.maxResults
            : maxResults // ignore: cast_nullable_to_non_nullable
                  as int,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as MemorySortBy,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as SortOrder,
        enableYesterdayMemories: null == enableYesterdayMemories
            ? _value.enableYesterdayMemories
            : enableYesterdayMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneWeekAgoMemories: null == enableOneWeekAgoMemories
            ? _value.enableOneWeekAgoMemories
            : enableOneWeekAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneMonthAgoMemories: null == enableOneMonthAgoMemories
            ? _value.enableOneMonthAgoMemories
            : enableOneMonthAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneYearAgoMemories: null == enableOneYearAgoMemories
            ? _value.enableOneYearAgoMemories
            : enableOneYearAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enablePastTodayMemories: null == enablePastTodayMemories
            ? _value.enablePastTodayMemories
            : enablePastTodayMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSameTimeMemories: null == enableSameTimeMemories
            ? _value.enableSameTimeMemories
            : enableSameTimeMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSeasonalMemories: null == enableSeasonalMemories
            ? _value.enableSeasonalMemories
            : enableSeasonalMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSpecialDateMemories: null == enableSpecialDateMemories
            ? _value.enableSpecialDateMemories
            : enableSpecialDateMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSimilarTagsMemories: null == enableSimilarTagsMemories
            ? _value.enableSimilarTagsMemories
            : enableSimilarTagsMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryFilterImpl implements _MemoryFilter {
  const _$MemoryFilterImpl({
    final List<MemoryType> allowedTypes = const [],
    final List<MemoryType> excludedTypes = const [],
    this.minRelevance = 0.0,
    this.maxRelevance = 1.0,
    this.startDate,
    this.endDate,
    final List<String> requiredTags = const [],
    final List<String> excludedTags = const [],
    this.excludeViewed = false,
    this.excludeBookmarked = false,
    this.maxResults = 10,
    this.sortBy = MemorySortBy.relevance,
    this.sortOrder = SortOrder.descending,
    this.enableYesterdayMemories = true,
    this.enableOneWeekAgoMemories = true,
    this.enableOneMonthAgoMemories = true,
    this.enableOneYearAgoMemories = true,
    this.enablePastTodayMemories = true,
    this.enableSameTimeMemories = true,
    this.enableSeasonalMemories = true,
    this.enableSpecialDateMemories = true,
    this.enableSimilarTagsMemories = true,
  }) : _allowedTypes = allowedTypes,
       _excludedTypes = excludedTypes,
       _requiredTags = requiredTags,
       _excludedTags = excludedTags;

  factory _$MemoryFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryFilterImplFromJson(json);

  final List<MemoryType> _allowedTypes;
  @override
  @JsonKey()
  List<MemoryType> get allowedTypes {
    if (_allowedTypes is EqualUnmodifiableListView) return _allowedTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedTypes);
  }

  final List<MemoryType> _excludedTypes;
  @override
  @JsonKey()
  List<MemoryType> get excludedTypes {
    if (_excludedTypes is EqualUnmodifiableListView) return _excludedTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedTypes);
  }

  @override
  @JsonKey()
  final double minRelevance;
  @override
  @JsonKey()
  final double maxRelevance;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  final List<String> _requiredTags;
  @override
  @JsonKey()
  List<String> get requiredTags {
    if (_requiredTags is EqualUnmodifiableListView) return _requiredTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredTags);
  }

  final List<String> _excludedTags;
  @override
  @JsonKey()
  List<String> get excludedTags {
    if (_excludedTags is EqualUnmodifiableListView) return _excludedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedTags);
  }

  @override
  @JsonKey()
  final bool excludeViewed;
  @override
  @JsonKey()
  final bool excludeBookmarked;
  @override
  @JsonKey()
  final int maxResults;
  @override
  @JsonKey()
  final MemorySortBy sortBy;
  @override
  @JsonKey()
  final SortOrder sortOrder;
  @override
  @JsonKey()
  final bool enableYesterdayMemories;
  @override
  @JsonKey()
  final bool enableOneWeekAgoMemories;
  @override
  @JsonKey()
  final bool enableOneMonthAgoMemories;
  @override
  @JsonKey()
  final bool enableOneYearAgoMemories;
  @override
  @JsonKey()
  final bool enablePastTodayMemories;
  @override
  @JsonKey()
  final bool enableSameTimeMemories;
  @override
  @JsonKey()
  final bool enableSeasonalMemories;
  @override
  @JsonKey()
  final bool enableSpecialDateMemories;
  @override
  @JsonKey()
  final bool enableSimilarTagsMemories;

  @override
  String toString() {
    return 'MemoryFilter(allowedTypes: $allowedTypes, excludedTypes: $excludedTypes, minRelevance: $minRelevance, maxRelevance: $maxRelevance, startDate: $startDate, endDate: $endDate, requiredTags: $requiredTags, excludedTags: $excludedTags, excludeViewed: $excludeViewed, excludeBookmarked: $excludeBookmarked, maxResults: $maxResults, sortBy: $sortBy, sortOrder: $sortOrder, enableYesterdayMemories: $enableYesterdayMemories, enableOneWeekAgoMemories: $enableOneWeekAgoMemories, enableOneMonthAgoMemories: $enableOneMonthAgoMemories, enableOneYearAgoMemories: $enableOneYearAgoMemories, enablePastTodayMemories: $enablePastTodayMemories, enableSameTimeMemories: $enableSameTimeMemories, enableSeasonalMemories: $enableSeasonalMemories, enableSpecialDateMemories: $enableSpecialDateMemories, enableSimilarTagsMemories: $enableSimilarTagsMemories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryFilterImpl &&
            const DeepCollectionEquality().equals(
              other._allowedTypes,
              _allowedTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedTypes,
              _excludedTypes,
            ) &&
            (identical(other.minRelevance, minRelevance) ||
                other.minRelevance == minRelevance) &&
            (identical(other.maxRelevance, maxRelevance) ||
                other.maxRelevance == maxRelevance) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._requiredTags,
              _requiredTags,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedTags,
              _excludedTags,
            ) &&
            (identical(other.excludeViewed, excludeViewed) ||
                other.excludeViewed == excludeViewed) &&
            (identical(other.excludeBookmarked, excludeBookmarked) ||
                other.excludeBookmarked == excludeBookmarked) &&
            (identical(other.maxResults, maxResults) ||
                other.maxResults == maxResults) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(
                  other.enableYesterdayMemories,
                  enableYesterdayMemories,
                ) ||
                other.enableYesterdayMemories == enableYesterdayMemories) &&
            (identical(
                  other.enableOneWeekAgoMemories,
                  enableOneWeekAgoMemories,
                ) ||
                other.enableOneWeekAgoMemories == enableOneWeekAgoMemories) &&
            (identical(
                  other.enableOneMonthAgoMemories,
                  enableOneMonthAgoMemories,
                ) ||
                other.enableOneMonthAgoMemories == enableOneMonthAgoMemories) &&
            (identical(
                  other.enableOneYearAgoMemories,
                  enableOneYearAgoMemories,
                ) ||
                other.enableOneYearAgoMemories == enableOneYearAgoMemories) &&
            (identical(
                  other.enablePastTodayMemories,
                  enablePastTodayMemories,
                ) ||
                other.enablePastTodayMemories == enablePastTodayMemories) &&
            (identical(other.enableSameTimeMemories, enableSameTimeMemories) ||
                other.enableSameTimeMemories == enableSameTimeMemories) &&
            (identical(other.enableSeasonalMemories, enableSeasonalMemories) ||
                other.enableSeasonalMemories == enableSeasonalMemories) &&
            (identical(
                  other.enableSpecialDateMemories,
                  enableSpecialDateMemories,
                ) ||
                other.enableSpecialDateMemories == enableSpecialDateMemories) &&
            (identical(
                  other.enableSimilarTagsMemories,
                  enableSimilarTagsMemories,
                ) ||
                other.enableSimilarTagsMemories == enableSimilarTagsMemories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(_allowedTypes),
    const DeepCollectionEquality().hash(_excludedTypes),
    minRelevance,
    maxRelevance,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_requiredTags),
    const DeepCollectionEquality().hash(_excludedTags),
    excludeViewed,
    excludeBookmarked,
    maxResults,
    sortBy,
    sortOrder,
    enableYesterdayMemories,
    enableOneWeekAgoMemories,
    enableOneMonthAgoMemories,
    enableOneYearAgoMemories,
    enablePastTodayMemories,
    enableSameTimeMemories,
    enableSeasonalMemories,
    enableSpecialDateMemories,
    enableSimilarTagsMemories,
  ]);

  /// Create a copy of MemoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryFilterImplCopyWith<_$MemoryFilterImpl> get copyWith =>
      __$$MemoryFilterImplCopyWithImpl<_$MemoryFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryFilterImplToJson(this);
  }
}

abstract class _MemoryFilter implements MemoryFilter {
  const factory _MemoryFilter({
    final List<MemoryType> allowedTypes,
    final List<MemoryType> excludedTypes,
    final double minRelevance,
    final double maxRelevance,
    final DateTime? startDate,
    final DateTime? endDate,
    final List<String> requiredTags,
    final List<String> excludedTags,
    final bool excludeViewed,
    final bool excludeBookmarked,
    final int maxResults,
    final MemorySortBy sortBy,
    final SortOrder sortOrder,
    final bool enableYesterdayMemories,
    final bool enableOneWeekAgoMemories,
    final bool enableOneMonthAgoMemories,
    final bool enableOneYearAgoMemories,
    final bool enablePastTodayMemories,
    final bool enableSameTimeMemories,
    final bool enableSeasonalMemories,
    final bool enableSpecialDateMemories,
    final bool enableSimilarTagsMemories,
  }) = _$MemoryFilterImpl;

  factory _MemoryFilter.fromJson(Map<String, dynamic> json) =
      _$MemoryFilterImpl.fromJson;

  @override
  List<MemoryType> get allowedTypes;
  @override
  List<MemoryType> get excludedTypes;
  @override
  double get minRelevance;
  @override
  double get maxRelevance;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  List<String> get requiredTags;
  @override
  List<String> get excludedTags;
  @override
  bool get excludeViewed;
  @override
  bool get excludeBookmarked;
  @override
  int get maxResults;
  @override
  MemorySortBy get sortBy;
  @override
  SortOrder get sortOrder;
  @override
  bool get enableYesterdayMemories;
  @override
  bool get enableOneWeekAgoMemories;
  @override
  bool get enableOneMonthAgoMemories;
  @override
  bool get enableOneYearAgoMemories;
  @override
  bool get enablePastTodayMemories;
  @override
  bool get enableSameTimeMemories;
  @override
  bool get enableSeasonalMemories;
  @override
  bool get enableSpecialDateMemories;
  @override
  bool get enableSimilarTagsMemories;

  /// Create a copy of MemoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryFilterImplCopyWith<_$MemoryFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemorySettings _$MemorySettingsFromJson(Map<String, dynamic> json) {
  return _MemorySettings.fromJson(json);
}

/// @nodoc
mixin _$MemorySettings {
  bool get enableYesterdayMemories => throw _privateConstructorUsedError;
  bool get enableOneWeekAgoMemories => throw _privateConstructorUsedError;
  bool get enableOneMonthAgoMemories => throw _privateConstructorUsedError;
  bool get enableOneYearAgoMemories => throw _privateConstructorUsedError;
  bool get enablePastTodayMemories => throw _privateConstructorUsedError;
  bool get enableSameTimeMemories => throw _privateConstructorUsedError;
  bool get enableSeasonalMemories => throw _privateConstructorUsedError;
  bool get enableSpecialDateMemories => throw _privateConstructorUsedError;
  bool get enableSimilarTagsMemories => throw _privateConstructorUsedError;
  int get maxMemoriesPerType => throw _privateConstructorUsedError;
  double get minMemoryRelevance => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  List<int> get notificationHours => throw _privateConstructorUsedError;
  int get maxDaysToLookBack => throw _privateConstructorUsedError;
  int get maxDaysForSameDate => throw _privateConstructorUsedError;

  /// Serializes this MemorySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemorySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemorySettingsCopyWith<MemorySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemorySettingsCopyWith<$Res> {
  factory $MemorySettingsCopyWith(
    MemorySettings value,
    $Res Function(MemorySettings) then,
  ) = _$MemorySettingsCopyWithImpl<$Res, MemorySettings>;
  @useResult
  $Res call({
    bool enableYesterdayMemories,
    bool enableOneWeekAgoMemories,
    bool enableOneMonthAgoMemories,
    bool enableOneYearAgoMemories,
    bool enablePastTodayMemories,
    bool enableSameTimeMemories,
    bool enableSeasonalMemories,
    bool enableSpecialDateMemories,
    bool enableSimilarTagsMemories,
    int maxMemoriesPerType,
    double minMemoryRelevance,
    bool enableNotifications,
    List<int> notificationHours,
    int maxDaysToLookBack,
    int maxDaysForSameDate,
  });
}

/// @nodoc
class _$MemorySettingsCopyWithImpl<$Res, $Val extends MemorySettings>
    implements $MemorySettingsCopyWith<$Res> {
  _$MemorySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemorySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableYesterdayMemories = null,
    Object? enableOneWeekAgoMemories = null,
    Object? enableOneMonthAgoMemories = null,
    Object? enableOneYearAgoMemories = null,
    Object? enablePastTodayMemories = null,
    Object? enableSameTimeMemories = null,
    Object? enableSeasonalMemories = null,
    Object? enableSpecialDateMemories = null,
    Object? enableSimilarTagsMemories = null,
    Object? maxMemoriesPerType = null,
    Object? minMemoryRelevance = null,
    Object? enableNotifications = null,
    Object? notificationHours = null,
    Object? maxDaysToLookBack = null,
    Object? maxDaysForSameDate = null,
  }) {
    return _then(
      _value.copyWith(
            enableYesterdayMemories: null == enableYesterdayMemories
                ? _value.enableYesterdayMemories
                : enableYesterdayMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneWeekAgoMemories: null == enableOneWeekAgoMemories
                ? _value.enableOneWeekAgoMemories
                : enableOneWeekAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneMonthAgoMemories: null == enableOneMonthAgoMemories
                ? _value.enableOneMonthAgoMemories
                : enableOneMonthAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableOneYearAgoMemories: null == enableOneYearAgoMemories
                ? _value.enableOneYearAgoMemories
                : enableOneYearAgoMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enablePastTodayMemories: null == enablePastTodayMemories
                ? _value.enablePastTodayMemories
                : enablePastTodayMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSameTimeMemories: null == enableSameTimeMemories
                ? _value.enableSameTimeMemories
                : enableSameTimeMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSeasonalMemories: null == enableSeasonalMemories
                ? _value.enableSeasonalMemories
                : enableSeasonalMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSpecialDateMemories: null == enableSpecialDateMemories
                ? _value.enableSpecialDateMemories
                : enableSpecialDateMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSimilarTagsMemories: null == enableSimilarTagsMemories
                ? _value.enableSimilarTagsMemories
                : enableSimilarTagsMemories // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxMemoriesPerType: null == maxMemoriesPerType
                ? _value.maxMemoriesPerType
                : maxMemoriesPerType // ignore: cast_nullable_to_non_nullable
                      as int,
            minMemoryRelevance: null == minMemoryRelevance
                ? _value.minMemoryRelevance
                : minMemoryRelevance // ignore: cast_nullable_to_non_nullable
                      as double,
            enableNotifications: null == enableNotifications
                ? _value.enableNotifications
                : enableNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationHours: null == notificationHours
                ? _value.notificationHours
                : notificationHours // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            maxDaysToLookBack: null == maxDaysToLookBack
                ? _value.maxDaysToLookBack
                : maxDaysToLookBack // ignore: cast_nullable_to_non_nullable
                      as int,
            maxDaysForSameDate: null == maxDaysForSameDate
                ? _value.maxDaysForSameDate
                : maxDaysForSameDate // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemorySettingsImplCopyWith<$Res>
    implements $MemorySettingsCopyWith<$Res> {
  factory _$$MemorySettingsImplCopyWith(
    _$MemorySettingsImpl value,
    $Res Function(_$MemorySettingsImpl) then,
  ) = __$$MemorySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enableYesterdayMemories,
    bool enableOneWeekAgoMemories,
    bool enableOneMonthAgoMemories,
    bool enableOneYearAgoMemories,
    bool enablePastTodayMemories,
    bool enableSameTimeMemories,
    bool enableSeasonalMemories,
    bool enableSpecialDateMemories,
    bool enableSimilarTagsMemories,
    int maxMemoriesPerType,
    double minMemoryRelevance,
    bool enableNotifications,
    List<int> notificationHours,
    int maxDaysToLookBack,
    int maxDaysForSameDate,
  });
}

/// @nodoc
class __$$MemorySettingsImplCopyWithImpl<$Res>
    extends _$MemorySettingsCopyWithImpl<$Res, _$MemorySettingsImpl>
    implements _$$MemorySettingsImplCopyWith<$Res> {
  __$$MemorySettingsImplCopyWithImpl(
    _$MemorySettingsImpl _value,
    $Res Function(_$MemorySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemorySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableYesterdayMemories = null,
    Object? enableOneWeekAgoMemories = null,
    Object? enableOneMonthAgoMemories = null,
    Object? enableOneYearAgoMemories = null,
    Object? enablePastTodayMemories = null,
    Object? enableSameTimeMemories = null,
    Object? enableSeasonalMemories = null,
    Object? enableSpecialDateMemories = null,
    Object? enableSimilarTagsMemories = null,
    Object? maxMemoriesPerType = null,
    Object? minMemoryRelevance = null,
    Object? enableNotifications = null,
    Object? notificationHours = null,
    Object? maxDaysToLookBack = null,
    Object? maxDaysForSameDate = null,
  }) {
    return _then(
      _$MemorySettingsImpl(
        enableYesterdayMemories: null == enableYesterdayMemories
            ? _value.enableYesterdayMemories
            : enableYesterdayMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneWeekAgoMemories: null == enableOneWeekAgoMemories
            ? _value.enableOneWeekAgoMemories
            : enableOneWeekAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneMonthAgoMemories: null == enableOneMonthAgoMemories
            ? _value.enableOneMonthAgoMemories
            : enableOneMonthAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableOneYearAgoMemories: null == enableOneYearAgoMemories
            ? _value.enableOneYearAgoMemories
            : enableOneYearAgoMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enablePastTodayMemories: null == enablePastTodayMemories
            ? _value.enablePastTodayMemories
            : enablePastTodayMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSameTimeMemories: null == enableSameTimeMemories
            ? _value.enableSameTimeMemories
            : enableSameTimeMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSeasonalMemories: null == enableSeasonalMemories
            ? _value.enableSeasonalMemories
            : enableSeasonalMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSpecialDateMemories: null == enableSpecialDateMemories
            ? _value.enableSpecialDateMemories
            : enableSpecialDateMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSimilarTagsMemories: null == enableSimilarTagsMemories
            ? _value.enableSimilarTagsMemories
            : enableSimilarTagsMemories // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxMemoriesPerType: null == maxMemoriesPerType
            ? _value.maxMemoriesPerType
            : maxMemoriesPerType // ignore: cast_nullable_to_non_nullable
                  as int,
        minMemoryRelevance: null == minMemoryRelevance
            ? _value.minMemoryRelevance
            : minMemoryRelevance // ignore: cast_nullable_to_non_nullable
                  as double,
        enableNotifications: null == enableNotifications
            ? _value.enableNotifications
            : enableNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationHours: null == notificationHours
            ? _value._notificationHours
            : notificationHours // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        maxDaysToLookBack: null == maxDaysToLookBack
            ? _value.maxDaysToLookBack
            : maxDaysToLookBack // ignore: cast_nullable_to_non_nullable
                  as int,
        maxDaysForSameDate: null == maxDaysForSameDate
            ? _value.maxDaysForSameDate
            : maxDaysForSameDate // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemorySettingsImpl implements _MemorySettings {
  const _$MemorySettingsImpl({
    this.enableYesterdayMemories = true,
    this.enableOneWeekAgoMemories = true,
    this.enableOneMonthAgoMemories = true,
    this.enableOneYearAgoMemories = true,
    this.enablePastTodayMemories = true,
    this.enableSameTimeMemories = true,
    this.enableSeasonalMemories = true,
    this.enableSpecialDateMemories = true,
    this.enableSimilarTagsMemories = true,
    this.maxMemoriesPerType = 10,
    this.minMemoryRelevance = 0.3,
    this.enableNotifications = true,
    final List<int> notificationHours = const [],
    this.maxDaysToLookBack = 7,
    this.maxDaysForSameDate = 365,
  }) : _notificationHours = notificationHours;

  factory _$MemorySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemorySettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enableYesterdayMemories;
  @override
  @JsonKey()
  final bool enableOneWeekAgoMemories;
  @override
  @JsonKey()
  final bool enableOneMonthAgoMemories;
  @override
  @JsonKey()
  final bool enableOneYearAgoMemories;
  @override
  @JsonKey()
  final bool enablePastTodayMemories;
  @override
  @JsonKey()
  final bool enableSameTimeMemories;
  @override
  @JsonKey()
  final bool enableSeasonalMemories;
  @override
  @JsonKey()
  final bool enableSpecialDateMemories;
  @override
  @JsonKey()
  final bool enableSimilarTagsMemories;
  @override
  @JsonKey()
  final int maxMemoriesPerType;
  @override
  @JsonKey()
  final double minMemoryRelevance;
  @override
  @JsonKey()
  final bool enableNotifications;
  final List<int> _notificationHours;
  @override
  @JsonKey()
  List<int> get notificationHours {
    if (_notificationHours is EqualUnmodifiableListView)
      return _notificationHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notificationHours);
  }

  @override
  @JsonKey()
  final int maxDaysToLookBack;
  @override
  @JsonKey()
  final int maxDaysForSameDate;

  @override
  String toString() {
    return 'MemorySettings(enableYesterdayMemories: $enableYesterdayMemories, enableOneWeekAgoMemories: $enableOneWeekAgoMemories, enableOneMonthAgoMemories: $enableOneMonthAgoMemories, enableOneYearAgoMemories: $enableOneYearAgoMemories, enablePastTodayMemories: $enablePastTodayMemories, enableSameTimeMemories: $enableSameTimeMemories, enableSeasonalMemories: $enableSeasonalMemories, enableSpecialDateMemories: $enableSpecialDateMemories, enableSimilarTagsMemories: $enableSimilarTagsMemories, maxMemoriesPerType: $maxMemoriesPerType, minMemoryRelevance: $minMemoryRelevance, enableNotifications: $enableNotifications, notificationHours: $notificationHours, maxDaysToLookBack: $maxDaysToLookBack, maxDaysForSameDate: $maxDaysForSameDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemorySettingsImpl &&
            (identical(
                  other.enableYesterdayMemories,
                  enableYesterdayMemories,
                ) ||
                other.enableYesterdayMemories == enableYesterdayMemories) &&
            (identical(
                  other.enableOneWeekAgoMemories,
                  enableOneWeekAgoMemories,
                ) ||
                other.enableOneWeekAgoMemories == enableOneWeekAgoMemories) &&
            (identical(
                  other.enableOneMonthAgoMemories,
                  enableOneMonthAgoMemories,
                ) ||
                other.enableOneMonthAgoMemories == enableOneMonthAgoMemories) &&
            (identical(
                  other.enableOneYearAgoMemories,
                  enableOneYearAgoMemories,
                ) ||
                other.enableOneYearAgoMemories == enableOneYearAgoMemories) &&
            (identical(
                  other.enablePastTodayMemories,
                  enablePastTodayMemories,
                ) ||
                other.enablePastTodayMemories == enablePastTodayMemories) &&
            (identical(other.enableSameTimeMemories, enableSameTimeMemories) ||
                other.enableSameTimeMemories == enableSameTimeMemories) &&
            (identical(other.enableSeasonalMemories, enableSeasonalMemories) ||
                other.enableSeasonalMemories == enableSeasonalMemories) &&
            (identical(
                  other.enableSpecialDateMemories,
                  enableSpecialDateMemories,
                ) ||
                other.enableSpecialDateMemories == enableSpecialDateMemories) &&
            (identical(
                  other.enableSimilarTagsMemories,
                  enableSimilarTagsMemories,
                ) ||
                other.enableSimilarTagsMemories == enableSimilarTagsMemories) &&
            (identical(other.maxMemoriesPerType, maxMemoriesPerType) ||
                other.maxMemoriesPerType == maxMemoriesPerType) &&
            (identical(other.minMemoryRelevance, minMemoryRelevance) ||
                other.minMemoryRelevance == minMemoryRelevance) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            const DeepCollectionEquality().equals(
              other._notificationHours,
              _notificationHours,
            ) &&
            (identical(other.maxDaysToLookBack, maxDaysToLookBack) ||
                other.maxDaysToLookBack == maxDaysToLookBack) &&
            (identical(other.maxDaysForSameDate, maxDaysForSameDate) ||
                other.maxDaysForSameDate == maxDaysForSameDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enableYesterdayMemories,
    enableOneWeekAgoMemories,
    enableOneMonthAgoMemories,
    enableOneYearAgoMemories,
    enablePastTodayMemories,
    enableSameTimeMemories,
    enableSeasonalMemories,
    enableSpecialDateMemories,
    enableSimilarTagsMemories,
    maxMemoriesPerType,
    minMemoryRelevance,
    enableNotifications,
    const DeepCollectionEquality().hash(_notificationHours),
    maxDaysToLookBack,
    maxDaysForSameDate,
  );

  /// Create a copy of MemorySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemorySettingsImplCopyWith<_$MemorySettingsImpl> get copyWith =>
      __$$MemorySettingsImplCopyWithImpl<_$MemorySettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemorySettingsImplToJson(this);
  }
}

abstract class _MemorySettings implements MemorySettings {
  const factory _MemorySettings({
    final bool enableYesterdayMemories,
    final bool enableOneWeekAgoMemories,
    final bool enableOneMonthAgoMemories,
    final bool enableOneYearAgoMemories,
    final bool enablePastTodayMemories,
    final bool enableSameTimeMemories,
    final bool enableSeasonalMemories,
    final bool enableSpecialDateMemories,
    final bool enableSimilarTagsMemories,
    final int maxMemoriesPerType,
    final double minMemoryRelevance,
    final bool enableNotifications,
    final List<int> notificationHours,
    final int maxDaysToLookBack,
    final int maxDaysForSameDate,
  }) = _$MemorySettingsImpl;

  factory _MemorySettings.fromJson(Map<String, dynamic> json) =
      _$MemorySettingsImpl.fromJson;

  @override
  bool get enableYesterdayMemories;
  @override
  bool get enableOneWeekAgoMemories;
  @override
  bool get enableOneMonthAgoMemories;
  @override
  bool get enableOneYearAgoMemories;
  @override
  bool get enablePastTodayMemories;
  @override
  bool get enableSameTimeMemories;
  @override
  bool get enableSeasonalMemories;
  @override
  bool get enableSpecialDateMemories;
  @override
  bool get enableSimilarTagsMemories;
  @override
  int get maxMemoriesPerType;
  @override
  double get minMemoryRelevance;
  @override
  bool get enableNotifications;
  @override
  List<int> get notificationHours;
  @override
  int get maxDaysToLookBack;
  @override
  int get maxDaysForSameDate;

  /// Create a copy of MemorySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemorySettingsImplCopyWith<_$MemorySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
