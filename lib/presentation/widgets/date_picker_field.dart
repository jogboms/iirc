import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';
import '../utils.dart';
import 'common_form_field_state.dart';

class DatePickerField extends FormField<DateTime> {
  DatePickerField({
    super.key,
    required super.initialValue,
    required this.onChanged,
  }) : super(
          builder: (FormFieldState<DateTime> fieldState) {
            final DateTime date = fieldState.value ?? clock.now();

            return Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    DateFormat.yMMMEd().format(date),
                    style: fieldState.context.theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () async {
                    final DateTime? value = await showDatePicker(
                      context: fieldState.context,
                      initialDate: date,
                      firstDate: DateTime(0),
                      lastDate: DateTime(clock.now().year + 1),
                    );
                    fieldState.didChange(value);
                  },
                  child: Text(fieldState.context.l10n.selectItemDateCaption),
                ),
              ],
            );
          },
        );

  final ValueChanged<DateTime> onChanged;

  @override
  FormFieldState<DateTime> createState() => DatePickerState();
}

@visibleForTesting
class DatePickerState extends CommonFormFieldState<DateTime> {
  @override
  void didChange(DateTime? value) {
    if (value != null) {
      (widget as DatePickerField).onChanged(value);
    }
    super.didChange(value);
  }
}
