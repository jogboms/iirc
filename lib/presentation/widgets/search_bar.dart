import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state.dart';
import '../theme.dart';
import '../utils.dart';

class AppSearchBar extends ConsumerStatefulWidget {
  const AppSearchBar({super.key});

  @override
  ConsumerState<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends ConsumerState<AppSearchBar> {
  late final SearchTagQueryState queryProvider = ref.read(searchTagQueryStateProvider.notifier);
  late final TextEditingController controller = TextEditingController(text: queryProvider.currentState);

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
            decoration: BoxDecoration(
              color: context.theme.inputDecorationTheme.fillColor,
              borderRadius: context.theme.appTheme.textFieldBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            style: context.theme.textTheme.titleMedium,
            clearButtonMode: OverlayVisibilityMode.editing,
            placeholder: context.l10n.searchByTagCaption,
            placeholderStyle: context.theme.inputDecorationTheme.hintStyle?.copyWith(height: 1.35),
            onChanged: queryProvider.setState,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<SearchTagMode>(
          isDense: true,
          value: ref.watch(searchTagModeStateProvider),
          underline: const SizedBox.shrink(),
          items: <DropdownMenuItem<SearchTagMode>>[
            for (final SearchTagMode item in SearchTagMode.values)
              DropdownMenuItem<SearchTagMode>(
                key: Key(item.name),
                value: item,
                child: Text(item.name),
              ),
          ],
          onChanged: (SearchTagMode? value) => ref.read(searchTagModeStateProvider.notifier).setState(value!),
        ),
      ],
    );
  }
}
