import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth_mock_impl.dart';
import '../extensions.dart';

class TagsMockImpl extends TagsRepository {
  static TagModel generateTag({String? id}) {
    id ??= faker.guid.guid();
    return TagModel(
      id: id,
      path: '/tags/${AuthMockImpl.id}/$id',
      title: faker.lorem.words(1).join(' '),
      description: faker.lorem.sentence(),
      color: faker.randomGenerator.integer(1000000) * 0xfffff,
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, TagModel> tags =
      faker.randomGenerator.amount((_) => generateTag(), 10, min: 5).foldToMap((TagModel element) => element.id);

  final BehaviorSubject<Map<String, TagModel>> _tags$ = BehaviorSubject<Map<String, TagModel>>.seeded(tags);

  @override
  Future<String> create(String userId, CreateTagData tag) async {
    final String id = faker.guid.guid();
    final TagModel newTag = TagModel(
      id: id,
      path: '/tags/$userId/$id',
      title: tag.title,
      description: tag.description,
      color: tag.color,
      createdAt: clock.now(),
      updatedAt: null,
    );
    _tags$.add(tags..putIfAbsent(id, () => newTag));
    return id;
  }

  @override
  Future<bool> update(UpdateTagData tag) async {
    _tags$.add(tags..update(tag.id, (TagModel prev) => prev.update(tag)));
    return true;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = tags.values.firstWhere((TagModel element) => element.path == path).id;
    _tags$.add(tags..remove(id));
    return true;
  }

  @override
  Stream<TagModelList> fetch(String userId) =>
      _tags$.stream.map((Map<String, TagModel> event) => event.values.toList());
}

extension on TagModel {
  TagModel update(UpdateTagData update) => TagModel(
        id: id,
        path: path,
        title: update.title,
        description: update.description,
        color: update.color,
        createdAt: createdAt,
        updatedAt: clock.now(),
      );
}
