import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}

class MockItemsRepository extends Mock implements ItemsRepository {}

class MockTagsRepository extends Mock implements TagsRepository {}
