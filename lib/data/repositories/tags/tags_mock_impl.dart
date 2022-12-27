import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth_mock_impl.dart';
import '../extensions.dart';

class TagsMockImpl extends TagsRepository {
  static TagEntity generateTag({String? id, String? userId}) {
    id ??= faker.guid.guid();
    return TagEntity(
      id: id,
      path: '/tags/${userId ?? AuthMockImpl.id}/$id',
      title: faker.lorem.words(1).join(' '),
      description: faker.lorem.sentence(),
      color: faker.randomGenerator.integer(1000000) * 0xfffff,
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, TagEntity> tags = (faker.randomGenerator.amount((_) => generateTag(), 10, min: 5)
        ..sort((TagEntity a, TagEntity b) => b.createdAt.compareTo(a.createdAt)))
      .foldToMap((TagEntity element) => element.id);

  final BehaviorSubject<Map<String, TagEntity>> _tags$ = BehaviorSubject<Map<String, TagEntity>>.seeded(tags);

  @override
  Future<String> create(String userId, CreateTagData tag) async {
    final String id = faker.guid.guid();
    final TagEntity newTag = TagEntity(
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
    _tags$.add(tags..update(tag.id, (TagEntity prev) => prev.update(tag)));
    return true;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = tags.values.firstWhere((TagEntity element) => element.path == path).id;
    _tags$.add(tags..remove(id));
    return true;
  }

  @override
  Stream<TagEntityList> fetch(String userId) =>
      _tags$.stream.map((Map<String, TagEntity> event) => event.values.toList());
}

extension on TagEntity {
  TagEntity update(UpdateTagData update) => TagEntity(
        id: id,
        path: path,
        title: update.title,
        description: update.description,
        color: update.color,
        createdAt: createdAt,
        updatedAt: clock.now(),
      );
}
