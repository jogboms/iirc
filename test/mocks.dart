import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}

class MockItemsRepository extends Mock implements ItemsRepository {}

class MockTagsRepository extends Mock implements TagsRepository {}

class MockFetchItemsUseCase extends Mock implements FetchItemsUseCase {}

class MockFetchTagsUseCase extends Mock implements FetchTagsUseCase {}

class MockGetAccountUseCase extends Mock implements GetAccountUseCase {}

class MockCreateItemUseCase extends Mock implements CreateItemUseCase {}

class MockCreateTagUseCase extends Mock implements CreateTagUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

class MockUpdateItemUseCase extends Mock implements UpdateItemUseCase {}

class MockDeleteItemUseCase extends Mock implements DeleteItemUseCase {}

class MockDeleteTagUseCase extends Mock implements DeleteTagUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockCreateUserUseCase extends Mock implements CreateUserUseCase {}

class MockFetchUserUseCase extends Mock implements FetchUserUseCase {}

class FakeUpdateUserData extends Fake implements UpdateUserData {}
