import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/widgets/dropdown_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import 'form_page.dart';

/// A input page for users to create custom fields to be used elsewhere in the
/// app. This form is immutable.
class AddCustomFieldPage extends StatefulWidget {
  final Function(CustomEntity) onSave;

  AddCustomFieldPage({
    this.onSave,
  });

  @override
  _AddCustomFieldPageState createState() => _AddCustomFieldPageState();
}

class _AddCustomFieldPageState extends State<AddCustomFieldPage> {
  static const String _nameId = "name";
  static const String _descriptionId = "description";
  static const String _dataTypeId = "dataType";

  final Map<String, InputController> _inputOptions = {
    _nameId: TextInputController(
      validate: (context) => Strings.of(context).inputGenericRequired,
    ),
    _descriptionId: TextInputController(),
    _dataTypeId: InputController<InputType>(
      value: InputType.number,
    ),
  };

  TextInputController get _nameController =>
      _inputOptions[_nameId] as TextInputController;

  TextInputController get _descriptionController =>
      _inputOptions[_descriptionId] as TextInputController;

  InputController<InputType> get _dataTypeController =>
      _inputOptions[_dataTypeId] as InputController<InputType>;

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Strings.of(context).addCustomFieldPageTitle,
      fieldBuilder: (BuildContext context, _) {
        return Map.fromIterable(_inputOptions.keys,
          key: (dynamic item) => item.toString(),
          value: (dynamic item) => _inputField(context, item.toString()),
        );
      },
      onSave: _save,
      isInputValid: isEmpty(_nameController.error(context)),
    );
  }

  Widget _inputField(BuildContext context, String key) {
    switch (key) {
      case _nameId: return TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        validate: _validateName,
      );
      case _descriptionId: return TextInput.description(
        context,
        controller: _descriptionController,
      );
      case _dataTypeId: return DropdownInput<InputType>(
        options: InputType.values,
        value: _dataTypeController.value,
        buildOption: (InputType type) =>
            Text(inputTypeLocalizedString(context, type)),
        onChanged: (InputType newType) {
          setState(() {
            _dataTypeController.value = newType;
          });
        },
      );
      default: print("Unknown key: $key");
    }

    return Empty();
  }

  void _save() {
    var customField = CustomEntity(
      name: _nameController.text,
      description: _descriptionController.text,
      type: _dataTypeController.value,
    );

    CustomFieldManager.of(context).addField(customField);
    widget.onSave?.call(customField);
  }

  FutureOr<ValidationCallback> _validateName() async {
    String name = _nameController.text;
    ValidationCallback callback;

    if (isEmpty(name)) {
      callback = (context) => Strings.of(context).inputGenericRequired;
    } else if (await CustomFieldManager.of(context).nameExists(name)) {
      callback = (context) => Strings.of(context).addCustomFieldPageNameExists;
    }

    // Trigger "Save" button state refresh.
    setState(() {});
    return callback;
  }
}