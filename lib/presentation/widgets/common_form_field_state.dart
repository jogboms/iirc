import 'package:flutter/widgets.dart';

class CommonFormFieldState<T> extends FormFieldState<T> {
  CommonFormFieldState();

  @override
  void initState() {
    // NOTE: Weird release mode bug on flutter web
    setValue(widget.initialValue);
    super.initState();
  }
}
