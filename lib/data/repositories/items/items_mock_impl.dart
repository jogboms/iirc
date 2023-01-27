import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth_mock_impl.dart';
import '../extensions.dart';
import '../tags/tags_mock_impl.dart';

class ItemsMockImpl extends ItemsRepository {
  static ItemEntity generateItem({String? id, TagEntity? tag, DateTime? date}) =>
      generateNormalizedItem(id: id, tag: tag, date: date).denormalize;

  static NormalizedItemEntity generateNormalizedItem({String? id, TagEntity? tag, DateTime? date}) {
    id ??= faker.guid.guid();
    return NormalizedItemEntity(
      id: id,
      path: '/items/${AuthMockImpl.id}/$id',
      description: faker.lorem.sentence(),
      date: date ?? faker.randomGenerator.dateTime,
      tag: tag ?? TagsMockImpl.tags.values.random(),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, ItemEntity> items = (faker.randomGenerator.amount((_) => generateItem(), 250, min: 50)
        ..sort((ItemEntity a, ItemEntity b) => b.date.compareTo(a.date)))
      .foldToMap((ItemEntity element) => element.id);

  final BehaviorSubject<Map<String, ItemEntity>> _items$ = BehaviorSubject<Map<String, ItemEntity>>.seeded(items);

  @override
  Future<String> create(String userId, CreateItemData item) async {
    final String id = faker.guid.guid();
    final ItemEntity newItem = ItemEntity(
      id: id,
      path: '/items/$userId/$id',
      description: item.description,
      date: item.date,
      tag: TagReferenceEntity(id: item.tagId, path: item.tagPath),
      createdAt: clock.now(),
      updatedAt: null,
    );
    _items$.add(items..putIfAbsent(id, () => newItem));
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = items.values.firstWhere((ItemEntity element) => element.path == path).id;
    _items$.add(items..remove(id));
    return true;
  }

  @override
  Future<bool> update(UpdateItemData item) async {
    _items$.add(items..update(item.id, (ItemEntity prev) => prev.update(item)));
    return true;
  }

  @override
  Stream<ItemEntityList> fetch(String userId) =>
      _items$.stream.map((Map<String, ItemEntity> event) => event.values.toList());
}

extension on ItemEntity {
  ItemEntity update(UpdateItemData update) => ItemEntity(
        id: id,
        path: path,
        description: update.description,
        date: update.date,
        tag: TagReferenceEntity(id: update.tagId, path: update.tagPath),
        createdAt: createdAt,
        updatedAt: clock.now(),
      );
}

extension on NormalizedItemEntity {
  ItemEntity get denormalize => ItemEntity(
        id: id,
        path: path,
        description: description,
        date: date,
        tag: tag.reference,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
