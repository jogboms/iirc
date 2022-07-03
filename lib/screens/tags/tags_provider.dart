import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _Provider tagsProvider = _Provider((StreamProviderRef<TagModelList> ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchTagsUseCase>().call();
});

typedef _Provider = StreamProvider<TagModelList>;
