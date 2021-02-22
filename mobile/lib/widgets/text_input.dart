import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';

class TextInput extends StatefulWidget {
  static const int _inputLimitDefault = 40;
  static const int _inputLimitName = _inputLimitDefault;
  static const int _inputLimitNumber = 10;
  static const int _inputLimitDescription = 140;
  static const int _inputLimitEmail = 64;

  final String initialValue;
  final String label;
  final TextCapitalization capitalization;
  final TextInputAction textInputAction;

  /// The controller for the [TextInput]. The [TextInput] will update the
  /// controller's [validate] property automatically.
  final TextInputController controller;

  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;

  /// Invoked when the [TextInput] text changes, _after_ [Validator.run] is
  /// invoked. Implement this property to update the state of the parent
  /// widget.
  final VoidCallback onChanged;

  /// Invoked when the "return" button is pressed on the keyboard when this
  /// [TextInput] is in focus.
  final VoidCallback onSubmitted;

  TextInput({
    this.initialValue,
    this.label,
    this.capitalization = TextCapitalization.none,
    this.textInputAction,
    this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLength = _inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  TextInput.name(
    BuildContext context, {
    String label,
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    VoidCallback onChanged,
  }) : this(
          initialValue: initialValue,
          label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
          capitalization: TextCapitalization.words,
          controller: controller,
          maxLength: _inputLimitName,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
        );

  TextInput.description(
    BuildContext context, {
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
  }) : this(
          initialValue: initialValue,
          label: Strings.of(context).inputDescriptionLabel,
          capitalization: TextCapitalization.sentences,
          controller: controller,
          maxLength: _inputLimitDescription,
          enabled: enabled,
          autofocus: autofocus,
        );

  TextInput.number(
    BuildContext context, {
    double initialValue,
    String label,
    String requiredText,
    NumberInputController controller,
    bool enabled,
    bool autofocus = false,
    bool required = false,
  }) : this(
          initialValue: initialValue == null ? null : initialValue.toString(),
          label: label,
          controller: controller,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          enabled: enabled,
          autofocus: autofocus,
          maxLength: _inputLimitNumber,
        );

  TextInput.email(
    BuildContext context, {
    String initialValue,
    EmailInputController controller,
    bool enabled,
    bool autofocus = false,
    VoidCallback onChanged,
    TextInputAction textInputAction,
  }) : this(
          initialValue: initialValue,
          label: Strings.of(context).inputEmailLabel,
          capitalization: TextCapitalization.none,
          controller: controller,
          maxLength: _inputLimitEmail,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          textInputAction: textInputAction,
        );

  TextInput.password(
    BuildContext context, {
    PasswordInputController controller,
    VoidCallback onChanged,
    VoidCallback onSubmitted,
  }) : this(
          label: Strings.of(context).inputPasswordLabel,
          capitalization: TextCapitalization.none,
          maxLength: null,
          obscureText: true,
          maxLines: 1,
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        );

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  ValidationCallback get _validationCallback =>
      widget.controller?.validator?.run(context, widget.controller.value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateError();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        initialValue: widget.initialValue,
        controller: widget.controller?.editingController,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.controller?.error,
        ),
        textCapitalization: widget.capitalization,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        onChanged: (_) {
          widget.onChanged?.call();
          setState(_updateError);
        },
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
      ),
    );
  }

  void _updateError() {
    widget.controller?.error = _validationCallback?.call(context);
  }
}
