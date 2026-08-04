// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_timeline_details.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTimelineDetailsCollection on Isar {
  IsarCollection<IsarTimelineDetails> get isarTimelineDetails =>
      this.collection();
}

const IsarTimelineDetailsSchema = CollectionSchema(
  name: r'IsarTimelineDetails',
  id: 6157164892234762292,
  properties: {
    r'detailsJson': PropertySchema(
      id: 0,
      name: r'detailsJson',
      type: IsarType.string,
    ),
    r'incidentId': PropertySchema(
      id: 1,
      name: r'incidentId',
      type: IsarType.string,
    ),
  },

  estimateSize: _isarTimelineDetailsEstimateSize,
  serialize: _isarTimelineDetailsSerialize,
  deserialize: _isarTimelineDetailsDeserialize,
  deserializeProp: _isarTimelineDetailsDeserializeProp,
  idName: r'isarAutoId',
  indexes: {
    r'incidentId': IndexSchema(
      id: 8421601180046468367,
      name: r'incidentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'incidentId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _isarTimelineDetailsGetId,
  getLinks: _isarTimelineDetailsGetLinks,
  attach: _isarTimelineDetailsAttach,
  version: '3.3.2',
);

int _isarTimelineDetailsEstimateSize(
  IsarTimelineDetails object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.detailsJson.length * 3;
  bytesCount += 3 + object.incidentId.length * 3;
  return bytesCount;
}

void _isarTimelineDetailsSerialize(
  IsarTimelineDetails object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.detailsJson);
  writer.writeString(offsets[1], object.incidentId);
}

IsarTimelineDetails _isarTimelineDetailsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTimelineDetails();
  object.detailsJson = reader.readString(offsets[0]);
  object.incidentId = reader.readString(offsets[1]);
  object.isarAutoId = id;
  return object;
}

P _isarTimelineDetailsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTimelineDetailsGetId(IsarTimelineDetails object) {
  return object.isarAutoId;
}

List<IsarLinkBase<dynamic>> _isarTimelineDetailsGetLinks(
  IsarTimelineDetails object,
) {
  return [];
}

void _isarTimelineDetailsAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarTimelineDetails object,
) {
  object.isarAutoId = id;
}

extension IsarTimelineDetailsByIndex on IsarCollection<IsarTimelineDetails> {
  Future<IsarTimelineDetails?> getByIncidentId(String incidentId) {
    return getByIndex(r'incidentId', [incidentId]);
  }

  IsarTimelineDetails? getByIncidentIdSync(String incidentId) {
    return getByIndexSync(r'incidentId', [incidentId]);
  }

  Future<bool> deleteByIncidentId(String incidentId) {
    return deleteByIndex(r'incidentId', [incidentId]);
  }

  bool deleteByIncidentIdSync(String incidentId) {
    return deleteByIndexSync(r'incidentId', [incidentId]);
  }

  Future<List<IsarTimelineDetails?>> getAllByIncidentId(
    List<String> incidentIdValues,
  ) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'incidentId', values);
  }

  List<IsarTimelineDetails?> getAllByIncidentIdSync(
    List<String> incidentIdValues,
  ) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'incidentId', values);
  }

  Future<int> deleteAllByIncidentId(List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'incidentId', values);
  }

  int deleteAllByIncidentIdSync(List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'incidentId', values);
  }

  Future<Id> putByIncidentId(IsarTimelineDetails object) {
    return putByIndex(r'incidentId', object);
  }

  Id putByIncidentIdSync(IsarTimelineDetails object, {bool saveLinks = true}) {
    return putByIndexSync(r'incidentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIncidentId(List<IsarTimelineDetails> objects) {
    return putAllByIndex(r'incidentId', objects);
  }

  List<Id> putAllByIncidentIdSync(
    List<IsarTimelineDetails> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'incidentId', objects, saveLinks: saveLinks);
  }
}

extension IsarTimelineDetailsQueryWhereSort
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QWhere> {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhere>
  anyIsarAutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTimelineDetailsQueryWhere
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QWhereClause> {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  isarAutoIdEqualTo(Id isarAutoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarAutoId, upper: isarAutoId),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  isarAutoIdNotEqualTo(Id isarAutoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarAutoId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarAutoId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarAutoId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarAutoId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  isarAutoIdGreaterThan(Id isarAutoId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarAutoId, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  isarAutoIdLessThan(Id isarAutoId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarAutoId, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  isarAutoIdBetween(
    Id lowerIsarAutoId,
    Id upperIsarAutoId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarAutoId,
          includeLower: includeLower,
          upper: upperIsarAutoId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  incidentIdEqualTo(String incidentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'incidentId', value: [incidentId]),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterWhereClause>
  incidentIdNotEqualTo(String incidentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'incidentId',
                lower: [],
                upper: [incidentId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'incidentId',
                lower: [incidentId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'incidentId',
                lower: [incidentId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'incidentId',
                lower: [],
                upper: [incidentId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarTimelineDetailsQueryFilter
    on
        QueryBuilder<
          IsarTimelineDetails,
          IsarTimelineDetails,
          QFilterCondition
        > {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'detailsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'detailsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'detailsJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  detailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'detailsJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'incidentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'incidentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'incidentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'incidentId', value: ''),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  incidentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'incidentId', value: ''),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  isarAutoIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarAutoId', value: value),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  isarAutoIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarAutoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  isarAutoIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarAutoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterFilterCondition>
  isarAutoIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarAutoId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarTimelineDetailsQueryObject
    on
        QueryBuilder<
          IsarTimelineDetails,
          IsarTimelineDetails,
          QFilterCondition
        > {}

extension IsarTimelineDetailsQueryLinks
    on
        QueryBuilder<
          IsarTimelineDetails,
          IsarTimelineDetails,
          QFilterCondition
        > {}

extension IsarTimelineDetailsQuerySortBy
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QSortBy> {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  sortByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  sortByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  sortByIncidentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  sortByIncidentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.desc);
    });
  }
}

extension IsarTimelineDetailsQuerySortThenBy
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QSortThenBy> {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByIncidentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByIncidentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByIsarAutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarAutoId', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QAfterSortBy>
  thenByIsarAutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarAutoId', Sort.desc);
    });
  }
}

extension IsarTimelineDetailsQueryWhereDistinct
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QDistinct> {
  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QDistinct>
  distinctByDetailsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detailsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QDistinct>
  distinctByIncidentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incidentId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarTimelineDetailsQueryProperty
    on QueryBuilder<IsarTimelineDetails, IsarTimelineDetails, QQueryProperty> {
  QueryBuilder<IsarTimelineDetails, int, QQueryOperations>
  isarAutoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarAutoId');
    });
  }

  QueryBuilder<IsarTimelineDetails, String, QQueryOperations>
  detailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detailsJson');
    });
  }

  QueryBuilder<IsarTimelineDetails, String, QQueryOperations>
  incidentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incidentId');
    });
  }
}
