import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('AccountProvider', () {
    final AccountModel dummyAccount = AuthMockImpl.generateAccount();

    tearDown(mockUseCases.reset);

    test('should get current account', () {
      when(mockUseCases.getAccountUseCase.call).thenAnswer((_) async => dummyAccount);

      final ProviderContainer container = createProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(accountProvider.future),
        completion(dummyAccount),
      );
    });
  });
}
