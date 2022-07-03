import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _Provider itemsProvider = _Provider((StreamProviderRef<ItemModelList> ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call();
});

typedef _Provider = StreamProvider<ItemModelList>;
