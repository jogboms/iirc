import 'package:flutter/material.dart';
import 'package:o_color_picker/o_color_picker.dart';

import '../utils.dart';
import 'common_form_field_state.dart';
import 'tag_color_box.dart';

class ColorPickerField extends FormField<Color> {
  ColorPickerField({
    super.key,
    super.initialValue,
    required this.onChanged,
  }) : super(
          builder: (FormFieldState<Color> fieldState) {
            final ColorPickerState state = fieldState as ColorPickerState;
            final Color? color = state.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (color != null) ...<Widget>[
                      TagColorBox(code: color.value),
                      const SizedBox(width: 4),
                    ],
                    TextButton(
                      onPressed: state.toggle,
                      child: Text(fieldState.context.l10n.selectTagColorCaption),
                    ),
                  ],
                ),
                if (state.isSelecting) ...<Widget>[
                  const SizedBox(height: 4),
                  OColorPicker(
                    selectedColor: color,
                    colors: primaryColorsPalette,
                    onColorChange: (Color color) => fieldState.didChange(color),
                  ),
                ]
              ],
            );
          },
        );

  final ValueChanged<Color> onChanged;

  @override
  FormFieldState<Color> createState() => ColorPickerState();
}

@visibleForTesting
class ColorPickerState extends CommonFormFieldState<Color> {
  bool isSelecting = false;

  void toggle() => setState(() => isSelecting = !isSelecting);

  @override
  void didChange(Color? value) {
    (widget as ColorPickerField).onChanged(value!);
    toggle();
    super.didChange(value);
  }
}
