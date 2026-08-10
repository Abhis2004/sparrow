// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_incident.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarIncidentCollection on Isar {
  IsarCollection<IsarIncident> get isarIncidents => this.collection();
}

const IsarIncidentSchema = CollectionSchema(
  name: r'IsarIncident',
  id: 5229649119602932405,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.string,
    ),
    r'completedDate': PropertySchema(
      id: 2,
      name: r'completedDate',
      type: IsarType.string,
    ),
    r'id': PropertySchema(id: 3, name: r'id', type: IsarType.string),
    r'incidentName': PropertySchema(
      id: 4,
      name: r'incidentName',
      type: IsarType.string,
    ),
    r'lastInteracted': PropertySchema(
      id: 5,
      name: r'lastInteracted',
      type: IsarType.string,
    ),
    r'location': PropertySchema(
      id: 6,
      name: r'location',
      type: IsarType.string,
    ),
    r'observationCount': PropertySchema(
      id: 7,
      name: r'observationCount',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 8,
      name: r'startedAt',
      type: IsarType.string,
    ),
    r'startedDate': PropertySchema(
      id: 9,
      name: r'startedDate',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 10, name: r'status', type: IsarType.string),
    r'suspectCount': PropertySchema(
      id: 11,
      name: r'suspectCount',
      type: IsarType.long,
    ),
    r'victimCount': PropertySchema(
      id: 12,
      name: r'victimCount',
      type: IsarType.long,
    ),
    r'witnessCount': PropertySchema(
      id: 13,
      name: r'witnessCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _isarIncidentEstimateSize,
  serialize: _isarIncidentSerialize,
  deserialize: _isarIncidentDeserialize,
  deserializeProp: _isarIncidentDeserializeProp,
  idName: r'isarAutoId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _isarIncidentGetId,
  getLinks: _isarIncidentGetLinks,
  attach: _isarIncidentAttach,
  version: '3.3.2',
);

int _isarIncidentEstimateSize(
  IsarIncident object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.completedAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.completedDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.incidentName.length * 3;
  {
    final value = object.lastInteracted;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.startedAt.length * 3;
  bytesCount += 3 + object.startedDate.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _isarIncidentSerialize(
  IsarIncident object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.completedAt);
  writer.writeString(offsets[2], object.completedDate);
  writer.writeString(offsets[3], object.id);
  writer.writeString(offsets[4], object.incidentName);
  writer.writeString(offsets[5], object.lastInteracted);
  writer.writeString(offsets[6], object.location);
  writer.writeLong(offsets[7], object.observationCount);
  writer.writeString(offsets[8], object.startedAt);
  writer.writeString(offsets[9], object.startedDate);
  writer.writeString(offsets[10], object.status);
  writer.writeLong(offsets[11], object.suspectCount);
  writer.writeLong(offsets[12], object.victimCount);
  writer.writeLong(offsets[13], object.witnessCount);
}

IsarIncident _isarIncidentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarIncident();
  object.category = reader.readString(offsets[0]);
  object.completedAt = reader.readStringOrNull(offsets[1]);
  object.completedDate = reader.readStringOrNull(offsets[2]);
  object.id = reader.readString(offsets[3]);
  object.incidentName = reader.readString(offsets[4]);
  object.isarAutoId = id;
  object.lastInteracted = reader.readStringOrNull(offsets[5]);
  object.location = reader.readString(offsets[6]);
  object.observationCount = reader.readLong(offsets[7]);
  object.startedAt = reader.readString(offsets[8]);
  object.startedDate = reader.readString(offsets[9]);
  object.status = reader.readString(offsets[10]);
  object.suspectCount = reader.readLong(offsets[11]);
  object.victimCount = reader.readLong(offsets[12]);
  object.witnessCount = reader.readLong(offsets[13]);
  return object;
}

P _isarIncidentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarIncidentGetId(IsarIncident object) {
  return object.isarAutoId;
}

List<IsarLinkBase<dynamic>> _isarIncidentGetLinks(IsarIncident object) {
  return [];
}

void _isarIncidentAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarIncident object,
) {
  object.isarAutoId = id;
}

extension IsarIncidentByIndex on IsarCollection<IsarIncident> {
  Future<IsarIncident?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  IsarIncident? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<IsarIncident?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<IsarIncident?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(IsarIncident object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(IsarIncident object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<IsarIncident> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<IsarIncident> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension IsarIncidentQueryWhereSort
    on QueryBuilder<IsarIncident, IsarIncident, QWhere> {
  QueryBuilder<IsarIncident, IsarIncident, QAfterWhere> anyIsarAutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarIncidentQueryWhere
    on QueryBuilder<IsarIncident, IsarIncident, QWhereClause> {
  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause> isarAutoIdEqualTo(
    Id isarAutoId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarAutoId, upper: isarAutoId),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause>
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

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause>
  isarAutoIdGreaterThan(Id isarAutoId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarAutoId, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause>
  isarAutoIdLessThan(Id isarAutoId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarAutoId, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause> isarAutoIdBetween(
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

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause> idEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'id', value: [id]),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterWhereClause> idNotEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarIncidentQueryFilter
    on QueryBuilder<IsarIncident, IsarIncident, QFilterCondition> {
  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'completedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'completedAt',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'completedAt', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedDate'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedDate'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'completedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'completedDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedDate', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  completedDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'completedDate', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'incidentName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'incidentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'incidentName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'incidentName', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  incidentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'incidentName', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  isarAutoIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarAutoId', value: value),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
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

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
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

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
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

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastInteracted'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastInteracted'),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastInteracted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastInteracted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastInteracted',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastInteracted', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  lastInteractedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastInteracted', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'location',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'location',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'location', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'location', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  observationCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'observationCount', value: value),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  observationCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'observationCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  observationCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'observationCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  observationCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'observationCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startedAt',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startedAt', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startedDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedDate', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  startedDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startedDate', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  suspectCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suspectCount', value: value),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  suspectCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suspectCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  suspectCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suspectCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  suspectCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suspectCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  victimCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'victimCount', value: value),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  victimCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'victimCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  victimCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'victimCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  victimCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'victimCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  witnessCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'witnessCount', value: value),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  witnessCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'witnessCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  witnessCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'witnessCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterFilterCondition>
  witnessCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'witnessCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarIncidentQueryObject
    on QueryBuilder<IsarIncident, IsarIncident, QFilterCondition> {}

extension IsarIncidentQueryLinks
    on QueryBuilder<IsarIncident, IsarIncident, QFilterCondition> {}

extension IsarIncidentQuerySortBy
    on QueryBuilder<IsarIncident, IsarIncident, QSortBy> {
  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByIncidentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentName', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByIncidentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentName', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByLastInteracted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteracted', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByLastInteractedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteracted', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByObservationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByObservationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByStartedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByStartedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortBySuspectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspectCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortBySuspectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspectCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByVictimCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'victimCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByVictimCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'victimCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> sortByWitnessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'witnessCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  sortByWitnessCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'witnessCount', Sort.desc);
    });
  }
}

extension IsarIncidentQuerySortThenBy
    on QueryBuilder<IsarIncident, IsarIncident, QSortThenBy> {
  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByIncidentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentName', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByIncidentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentName', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByIsarAutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarAutoId', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByIsarAutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarAutoId', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByLastInteracted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteracted', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByLastInteractedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteracted', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByObservationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByObservationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByStartedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByStartedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenBySuspectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspectCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenBySuspectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspectCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByVictimCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'victimCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByVictimCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'victimCount', Sort.desc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy> thenByWitnessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'witnessCount', Sort.asc);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QAfterSortBy>
  thenByWitnessCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'witnessCount', Sort.desc);
    });
  }
}

extension IsarIncidentQueryWhereDistinct
    on QueryBuilder<IsarIncident, IsarIncident, QDistinct> {
  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByCompletedAt({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByCompletedDate({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'completedDate',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByIncidentName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incidentName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByLastInteracted({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastInteracted',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByLocation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct>
  distinctByObservationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observationCount');
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByStartedAt({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByStartedDate({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctBySuspectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suspectCount');
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByVictimCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'victimCount');
    });
  }

  QueryBuilder<IsarIncident, IsarIncident, QDistinct> distinctByWitnessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'witnessCount');
    });
  }
}

extension IsarIncidentQueryProperty
    on QueryBuilder<IsarIncident, IsarIncident, QQueryProperty> {
  QueryBuilder<IsarIncident, int, QQueryOperations> isarAutoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarAutoId');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<IsarIncident, String?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<IsarIncident, String?, QQueryOperations>
  completedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedDate');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> incidentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incidentName');
    });
  }

  QueryBuilder<IsarIncident, String?, QQueryOperations>
  lastInteractedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastInteracted');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<IsarIncident, int, QQueryOperations> observationCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observationCount');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> startedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedDate');
    });
  }

  QueryBuilder<IsarIncident, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarIncident, int, QQueryOperations> suspectCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suspectCount');
    });
  }

  QueryBuilder<IsarIncident, int, QQueryOperations> victimCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'victimCount');
    });
  }

  QueryBuilder<IsarIncident, int, QQueryOperations> witnessCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'witnessCount');
    });
  }
}
