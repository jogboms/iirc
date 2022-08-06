import 'package:flutter/material.dart';
import 'package:o_color_picker/o_color_picker.dart';

import '../utils.dart';
import 'tag_color_box.dart';

class ColorPickerField extends StatefulWidget {
  const ColorPickerField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final Color initialValue;
  final ValueChanged<Color> onChanged;

  @override
  State<ColorPickerField> createState() => ColorPickerState();
}

@visibleForTesting
class ColorPickerState extends State<ColorPickerField> {
  bool isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return FormField<Color>(
      initialValue: widget.initialValue,
      builder: (FormFieldState<Color> fieldState) {
        final Color? color = fieldState.value;

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
                  onPressed: () => setState(() => isSelecting = true),
                  child: Text(context.l10n.selectTagColorCaption),
                ),
              ],
            ),
            if (isSelecting) ...<Widget>[
              const SizedBox(height: 4),
              OColorPicker(
                selectedColor: fieldState.value,
                colors: primaryColorsPalette,
                onColorChange: (Color color) {
                  fieldState.didChange(color);
                  widget.onChanged(color);
                  setState(() => isSelecting = false);
                },
              ),
            ]
          ],
        );
      },
    );
  }
}
