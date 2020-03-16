import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:quiver/strings.dart';

/// A generic page for getting a "Name" input from the user.
class SaveNamePage extends StatefulWidget {
  final String title;
  final String oldName;

  /// Invoked when the "Save" button is pressed. The value entered is passed to
  /// this callback.
  ///
  /// See [FormPage.onSave].
  final bool Function(String) onSave;

  /// Invoked when the name input changes.
  final FutureOr<ValidationCallback> Function(String) validate;

  SaveNamePage({
    @required this.title,
    this.oldName,
    this.onSave,
    this.validate,
  });

  @override
  _SaveNamePageState createState() => _SaveNamePageState();
}

class _SaveNamePageState extends State<SaveNamePage> {
  final _controller = TextInputController(
    validate: (context) => Strings.of(context).inputGenericRequired,
  );

  bool get inputEqualsOld => widget.oldName != null
      && isEqualTrimmedLowercase(widget.oldName, _controller.text);

  @override
  void initState() {
    super.initState();

    if (isNotEmpty(widget.oldName)) {
      _controller.text = widget.oldName;

      // If editing an old name, that old name is valid.
      _controller.validate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: widget.title,
      editable: false,
      onSave: () {
        if (inputEqualsOld) {
          // If the name didn't change, act as though "back" or "cancel" was
          // pressed.
          return true;
        }

        if (widget.onSave == null || widget.onSave(_controller.text)) {
          return true;
        }

        return false;
      },
      fieldBuilder: (context, _) {
        return {
          Entity.keyName : TextInput.name(
            context,
            controller: _controller,
            autofocus: true,
            validate: () async {
              var callback;
              if (!inputEqualsOld) {
                callback = await widget.validate(_controller.text);
              }

              // Trigger "Save" button state refresh.
              setState(() {});
              return callback;
            },
          ),
        };
      },
      isInputValid: isEmpty(_controller.error(context)),
    );
  }
}