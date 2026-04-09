// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryLogCollectionCollection on Isar {
  IsarCollection<InventoryLogCollection> get inventoryLogCollections =>
      this.collection();
}

const InventoryLogCollectionSchema = CollectionSchema(
  name: r'InventoryLogCollection',
  id: -1697616899808705061,
  properties: {
    r'adjustmentQuantity': PropertySchema(
      id: 0,
      name: r'adjustmentQuantity',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isDeleted': PropertySchema(
      id: 2,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'menuItemId': PropertySchema(
      id: 4,
      name: r'menuItemId',
      type: IsarType.string,
    ),
    r'menuItemName': PropertySchema(
      id: 5,
      name: r'menuItemName',
      type: IsarType.string,
    ),
    r'newQuantity': PropertySchema(
      id: 6,
      name: r'newQuantity',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'performedAt': PropertySchema(
      id: 8,
      name: r'performedAt',
      type: IsarType.dateTime,
    ),
    r'performedById': PropertySchema(
      id: 9,
      name: r'performedById',
      type: IsarType.string,
    ),
    r'performedByName': PropertySchema(
      id: 10,
      name: r'performedByName',
      type: IsarType.string,
    ),
    r'previousQuantity': PropertySchema(
      id: 11,
      name: r'previousQuantity',
      type: IsarType.double,
    ),
    r'reason': PropertySchema(
      id: 12,
      name: r'reason',
      type: IsarType.string,
    ),
    r'syncId': PropertySchema(
      id: 13,
      name: r'syncId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _inventoryLogCollectionEstimateSize,
  serialize: _inventoryLogCollectionSerialize,
  deserialize: _inventoryLogCollectionDeserialize,
  deserializeProp: _inventoryLogCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncId': IndexSchema(
      id: 7538593479801827566,
      name: r'syncId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'syncId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'menuItemId': IndexSchema(
      id: -3759300833910669158,
      name: r'menuItemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'menuItemId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'reason': IndexSchema(
      id: 116689466196427997,
      name: r'reason',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reason',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'performedAt': IndexSchema(
      id: 261083574192956769,
      name: r'performedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'performedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventoryLogCollectionGetId,
  getLinks: _inventoryLogCollectionGetLinks,
  attach: _inventoryLogCollectionAttach,
  version: '3.3.2',
);

int _inventoryLogCollectionEstimateSize(
  InventoryLogCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.menuItemId.length * 3;
  bytesCount += 3 + object.menuItemName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.performedById.length * 3;
  bytesCount += 3 + object.performedByName.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.syncId.length * 3;
  return bytesCount;
}

void _inventoryLogCollectionSerialize(
  InventoryLogCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.adjustmentQuantity);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isDeleted);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.menuItemId);
  writer.writeString(offsets[5], object.menuItemName);
  writer.writeDouble(offsets[6], object.newQuantity);
  writer.writeString(offsets[7], object.notes);
  writer.writeDateTime(offsets[8], object.performedAt);
  writer.writeString(offsets[9], object.performedById);
  writer.writeString(offsets[10], object.performedByName);
  writer.writeDouble(offsets[11], object.previousQuantity);
  writer.writeString(offsets[12], object.reason);
  writer.writeString(offsets[13], object.syncId);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

InventoryLogCollection _inventoryLogCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryLogCollection();
  object.adjustmentQuantity = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[2]);
  object.isSynced = reader.readBool(offsets[3]);
  object.menuItemId = reader.readString(offsets[4]);
  object.menuItemName = reader.readString(offsets[5]);
  object.newQuantity = reader.readDouble(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.performedAt = reader.readDateTime(offsets[8]);
  object.performedById = reader.readString(offsets[9]);
  object.performedByName = reader.readString(offsets[10]);
  object.previousQuantity = reader.readDouble(offsets[11]);
  object.reason = reader.readString(offsets[12]);
  object.syncId = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  return object;
}

P _inventoryLogCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryLogCollectionGetId(InventoryLogCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryLogCollectionGetLinks(
    InventoryLogCollection object) {
  return [];
}

void _inventoryLogCollectionAttach(
    IsarCollection<dynamic> col, Id id, InventoryLogCollection object) {
  object.id = id;
}

extension InventoryLogCollectionByIndex
    on IsarCollection<InventoryLogCollection> {
  Future<InventoryLogCollection?> getBySyncId(String syncId) {
    return getByIndex(r'syncId', [syncId]);
  }

  InventoryLogCollection? getBySyncIdSync(String syncId) {
    return getByIndexSync(r'syncId', [syncId]);
  }

  Future<bool> deleteBySyncId(String syncId) {
    return deleteByIndex(r'syncId', [syncId]);
  }

  bool deleteBySyncIdSync(String syncId) {
    return deleteByIndexSync(r'syncId', [syncId]);
  }

  Future<List<InventoryLogCollection?>> getAllBySyncId(
      List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncId', values);
  }

  List<InventoryLogCollection?> getAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncId', values);
  }

  Future<int> deleteAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncId', values);
  }

  int deleteAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncId', values);
  }

  Future<Id> putBySyncId(InventoryLogCollection object) {
    return putByIndex(r'syncId', object);
  }

  Id putBySyncIdSync(InventoryLogCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncId(List<InventoryLogCollection> objects) {
    return putAllByIndex(r'syncId', objects);
  }

  List<Id> putAllBySyncIdSync(List<InventoryLogCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncId', objects, saveLinks: saveLinks);
  }
}

extension InventoryLogCollectionQueryWhereSort
    on QueryBuilder<InventoryLogCollection, InventoryLogCollection, QWhere> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterWhere>
      anyPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'performedAt'),
      );
    });
  }
}

extension InventoryLogCollectionQueryWhere on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QWhereClause> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> syncIdEqualTo(String syncId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncId',
        value: [syncId],
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> syncIdNotEqualTo(String syncId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> menuItemIdEqualTo(String menuItemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'menuItemId',
        value: [menuItemId],
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> menuItemIdNotEqualTo(String menuItemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'menuItemId',
              lower: [],
              upper: [menuItemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'menuItemId',
              lower: [menuItemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'menuItemId',
              lower: [menuItemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'menuItemId',
              lower: [],
              upper: [menuItemId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> reasonEqualTo(String reason) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reason',
        value: [reason],
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> reasonNotEqualTo(String reason) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reason',
              lower: [],
              upper: [reason],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reason',
              lower: [reason],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reason',
              lower: [reason],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reason',
              lower: [],
              upper: [reason],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> performedAtEqualTo(DateTime performedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'performedAt',
        value: [performedAt],
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> performedAtNotEqualTo(DateTime performedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'performedAt',
              lower: [],
              upper: [performedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'performedAt',
              lower: [performedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'performedAt',
              lower: [performedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'performedAt',
              lower: [],
              upper: [performedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> performedAtGreaterThan(
    DateTime performedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'performedAt',
        lower: [performedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> performedAtLessThan(
    DateTime performedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'performedAt',
        lower: [],
        upper: [performedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterWhereClause> performedAtBetween(
    DateTime lowerPerformedAt,
    DateTime upperPerformedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'performedAt',
        lower: [lowerPerformedAt],
        includeLower: includeLower,
        upper: [upperPerformedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InventoryLogCollectionQueryFilter on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QFilterCondition> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> adjustmentQuantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adjustmentQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> adjustmentQuantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adjustmentQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> adjustmentQuantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adjustmentQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> adjustmentQuantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adjustmentQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'menuItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      menuItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'menuItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      menuItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'menuItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'menuItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'menuItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'menuItemName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      menuItemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'menuItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      menuItemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'menuItemName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'menuItemName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> menuItemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'menuItemName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> newQuantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> newQuantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> newQuantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> newQuantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      performedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'performedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      performedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'performedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedById',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'performedById',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      performedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'performedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      performedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'performedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> performedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'performedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> previousQuantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> previousQuantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> previousQuantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> previousQuantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      syncIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
          QAfterFilterCondition>
      syncIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> syncIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InventoryLogCollectionQueryObject on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QFilterCondition> {}

extension InventoryLogCollectionQueryLinks on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QFilterCondition> {}

extension InventoryLogCollectionQuerySortBy
    on QueryBuilder<InventoryLogCollection, InventoryLogCollection, QSortBy> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByAdjustmentQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByAdjustmentQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByMenuItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByMenuItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByMenuItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByMenuItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByNewQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByNewQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedById', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedById', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedByName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPerformedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedByName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPreviousQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByPreviousQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryLogCollectionQuerySortThenBy on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QSortThenBy> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByAdjustmentQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByAdjustmentQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByMenuItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByMenuItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByMenuItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByMenuItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'menuItemName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByNewQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByNewQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedById', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedById', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedByName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPerformedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedByName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPreviousQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousQuantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByPreviousQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousQuantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryLogCollectionQueryWhereDistinct
    on QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct> {
  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByAdjustmentQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adjustmentQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByMenuItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'menuItemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByMenuItemName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'menuItemName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByNewQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedAt');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByPerformedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedById',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByPerformedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByPreviousQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctBySyncId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLogCollection, InventoryLogCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension InventoryLogCollectionQueryProperty on QueryBuilder<
    InventoryLogCollection, InventoryLogCollection, QQueryProperty> {
  QueryBuilder<InventoryLogCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryLogCollection, double, QQueryOperations>
      adjustmentQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adjustmentQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InventoryLogCollection, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<InventoryLogCollection, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      menuItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'menuItemId');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      menuItemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'menuItemName');
    });
  }

  QueryBuilder<InventoryLogCollection, double, QQueryOperations>
      newQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<InventoryLogCollection, DateTime, QQueryOperations>
      performedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedAt');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      performedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedById');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      performedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedByName');
    });
  }

  QueryBuilder<InventoryLogCollection, double, QQueryOperations>
      previousQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousQuantity');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<InventoryLogCollection, String, QQueryOperations>
      syncIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncId');
    });
  }

  QueryBuilder<InventoryLogCollection, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
