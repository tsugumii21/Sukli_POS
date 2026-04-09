import 'package:isar_community/isar.dart';

part 'inventory_log_collection.g.dart';

@collection
class InventoryLogCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String menuItemId;
  late String menuItemName;

  late double previousQuantity;
  late double adjustmentQuantity;
  late double newQuantity;

  @Index()
  late String reason;
  String? notes;

  late String performedById;
  late String performedByName;

  @Index()
  late DateTime performedAt;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}

