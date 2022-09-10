import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockValueChangedCallback<T> extends Mock {
  void call(T data);
}

class MockAsyncCallback<T> extends Mock {
  Future<T> call();
}

class FakeCreateItemData extends Fake implements CreateItemData {}

class FakeUpdateItemData extends Fake implements UpdateItemData {}

class FakeCreateTagData extends Fake implements CreateTagData {}

class FakeUpdateTagData extends Fake implements UpdateTagData {}

class FakeUpdateUserData extends Fake implements UpdateUserData {}

class FakeAccountModel extends Fake implements AccountModel {}

class FakeItemModel extends Fake implements ItemModel {}

class FakeTagModel extends Fake implements TagModel {}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeStackTrace extends Fake implements StackTrace {}

class FakeFlutterErrorDetails extends Fake implements FlutterErrorDetails {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return toDiagnosticsNode(style: DiagnosticsTreeStyle.error).toStringDeep(minLevel: minLevel);
  }
}
