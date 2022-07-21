import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/state.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key, required this.title});

  final String title;

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late final StateController<String> provider = ref.read(searchTagTitleStateProvider.notifier);
  late final TextEditingController controller = TextEditingController(text: provider.state);

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchTagTitleStateProvider, (_, String next) {
      if (controller.text != next) {
        controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length, affinity: TextAffinity.upstream),
        );
      }
    });

    return CupertinoTextField(
      controller: controller,
      clearButtonMode: OverlayVisibilityMode.editing,
      placeholder: '${context.l10n.searchCaption} ${widget.title}',
      onChanged: (String value) => provider.state = value,
    );
  }
}
