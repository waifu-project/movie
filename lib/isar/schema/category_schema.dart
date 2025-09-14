import 'package:isar_community/isar.dart';
import 'package:xi/interface.dart';

part 'category_schema.g.dart';

@embedded
class Category {
  late String name;
  late String id;
  SourceSpiderQueryCategory toRealCategory() {
    return SourceSpiderQueryCategory(name, id);
  }
}

@Collection()
class CategoryIsarModel {
  CategoryIsarModel({
    required this.sid,
    required this.categories,
  });

  Id id = Isar.autoIncrement;

  @Index()
  String sid;

  late List<Category> categories;

  List<SourceSpiderQueryCategory> toRealCategories() {
    return categories.map((e) => e.toRealCategory()).toList();
  }
}
