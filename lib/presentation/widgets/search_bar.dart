import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/search_tag_state_provider.dart';
import '../utils/extensions.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late final StateController<String> queryProvider = ref.read(searchTagQueryStateProvider.notifier);
  late final TextEditingController controller = TextEditingController(text: queryProvider.state);

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchTagQueryStateProvider, (_, String next) {
      if (controller.text != next) {
        controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length, affinity: TextAffinity.upstream),
        );
      }
    });

    return Row(
      children: <Widget>[
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            clearButtonMode: OverlayVisibilityMode.editing,
            placeholder: context.l10n.searchByTagCaption,
            onChanged: (String value) => queryProvider.state = value,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton<SearchTagMode>(
            isDense: true,
            value: ref.watch(searchTagModeStateProvider),
            items: <DropdownMenuItem<SearchTagMode>>[
              for (final SearchTagMode item in SearchTagMode.values)
                DropdownMenuItem<SearchTagMode>(
                  value: item,
                  child: Text(item.name),
                ),
            ],
            onChanged: (SearchTagMode? value) => ref.read(searchTagModeStateProvider.notifier).state = value!,
          ),
        ),
      ],
    );
  }
}
