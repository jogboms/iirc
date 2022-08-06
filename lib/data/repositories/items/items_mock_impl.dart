import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth_mock_impl.dart';
import '../extensions.dart';
import '../tags/tags_mock_impl.dart';

class ItemsMockImpl extends ItemsRepository {
  static ItemModel generateItem({String? id, TagModel? tag, DateTime? date}) =>
      generateNormalizedItem(id: id, tag: tag, date: date).denormalize;

  static NormalizedItemModel generateNormalizedItem({String? id, TagModel? tag, DateTime? date}) {
    id ??= faker.guid.guid();
    return NormalizedItemModel(
      id: id,
      path: '/items/${AuthMockImpl.id}/$id',
      description: faker.lorem.sentence(),
      date: date ?? faker.randomGenerator.dateTime,
      tag: (tag ?? TagsMockImpl.tags.values.random()),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, ItemModel> items =
      faker.randomGenerator.amount((_) => generateItem(), 250, min: 50).foldToMap((ItemModel element) => element.id);

  final BehaviorSubject<Map<String, ItemModel>> _items$ = BehaviorSubject<Map<String, ItemModel>>.seeded(items);

  @override
  Future<String> create(String userId, CreateItemData item) async {
    final String id = faker.guid.guid();
    final ItemModel newItem = ItemModel(
      id: id,
      path: '/items/$userId/$id',
      description: item.description,
      date: item.date,
      tag: item.tag,
      createdAt: clock.now(),
      updatedAt: null,
    );
    _items$.add(items..putIfAbsent(id, () => newItem));
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = items.values.firstWhere((ItemModel element) => element.path == path).id;
    _items$.add(items..remove(id));
    return true;
  }

  @override
  Future<bool> update(UpdateItemData item) async {
    _items$.add(items..update(item.id, (ItemModel prev) => prev.update(item)));
    return true;
  }

  @override
  Stream<ItemModelList> fetch(String userId) =>
      _items$.stream.map((Map<String, ItemModel> event) => event.values.toList());
}

extension on ItemModel {
  ItemModel update(UpdateItemData update) => ItemModel(
        id: id,
        path: path,
        description: update.description,
        date: update.date,
        tag: update.tag,
        createdAt: createdAt,
        updatedAt: clock.now(),
      );
}

extension on NormalizedItemModel {
  ItemModel get denormalize => ItemModel(
        id: id,
        path: path,
        description: description,
        date: date,
        tag: tag.reference,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
