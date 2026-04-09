import 'package:isar_community/isar.dart';

part 'category_collection.g.dart';

@collection
class CategoryCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  late String name;
  String? description;
  String? iconEmoji;

  @Index()
  late int sortOrder;

  @Index()
  late bool isActive;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}

