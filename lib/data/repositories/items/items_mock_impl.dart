import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth_mock_impl.dart';
import '../extensions.dart';
import '../tags/tags_mock_impl.dart';

class ItemsMockImpl extends ItemsRepository {
  static ItemModel generateItem({TagModel? tag, DateTime? date}) {
    final String id = faker.guid.guid();
    return ItemModel(
      id: id,
      path: '/items/${AuthMockImpl.id}/$id',
      description: faker.lorem.sentence(),
      date: date ?? faker.randomGenerator.dateTime,
      tag: tag ?? TagsMockImpl.tags.values.random(),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, ItemModel> items =
      faker.randomGenerator.amount((_) => generateItem(), 100, min: 50).foldToMap((ItemModel element) => element.id);

  final BehaviorSubject<Map<String, ItemModel>> _items$ = BehaviorSubject<Map<String, ItemModel>>.seeded(items);

  @override
  Future<ItemModel> create(String userId, CreateItemData item) async => items.values.first;

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
  Stream<ItemModelList> fetch() => _items$.stream.map((Map<String, ItemModel> event) => event.values.toList());
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
