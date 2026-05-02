import 'package:isar_community/isar.dart';

part 'menu_item_collection.g.dart';

@collection
class MenuItemCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String categoryId; // syncId of parent

  late String name;
  String? description;
  late double basePrice;
  String? imageUrl;

  @Index()
  late bool isAvailable;

  @Index()
  late bool isFavorite;

  @Index()
  late bool trackInventory;

  double? stockQuantity;
  double? lowStockThreshold;
  late int sortOrder;

  List<String> variantsJson = [];
  List<String> modifiersJson = [];

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}

