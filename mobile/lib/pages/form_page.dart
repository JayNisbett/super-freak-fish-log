import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/core.dart';

import 'add_custom_field_page.dart';

/// A function responsible for building all input widgets.
///
/// @return The returned map key [String] represents the identifier in the
/// underlying model object, such as "angler", "bait_id", etc. The returned
/// map value [Widget] is the widget that is displayed.
///
/// Note that the returned map key is used in keeping track of [InputFields]
/// that are selected for deletion.
typedef FieldBuilder = Map<String, Widget> Function(BuildContext);

enum _OverflowOption {
  manageFields,
}

/// A small data structure that stores information on fields that can be added
/// to the form by a user.
class FormPageFieldOption {
  /// The unique ID of the field. Used for identification purposes.
  final String id;

  /// The name of the field, as seen and selected by the user.
  final String userFacingName;

  /// Whether or not the option is already part of the form.
  final bool used;

  /// Whether or not the field can be removed from the form. Defaults to `true`.
  final bool removable;

  FormPageFieldOption({
    this.id,
    this.userFacingName,
    this.used = false,
    this.removable = true,
  });

  @override
  bool operator ==(other) => other is FormPageFieldOption
      && id == other.id
      && userFacingName == other.userFacingName
      && used == other.used
      && removable == other.removable;

  @override
  int get hashCode => hash4(id, userFacingName, used, removable);
}

/// A customizable user input page that supports user-manageable input fields.
/// If desired, users can add and remove input fields.
///
/// Widgets using the [FormPage] widget are responsible for tracking field input
/// values and input validation.
class FormPage extends StatefulWidget {
  /// See [AppBar.title].
  final Widget title;

  final FieldBuilder fieldBuilder;

  /// A [List] of fields that can be added to the form, if the user desires.
  final List<FormPageFieldOption> addFieldOptions;

  /// Called when a field is added to the form.
  final void Function(Set<String> ids) onAddFields;

  /// Used when state is set. Common form components need to be updated
  /// based on whether or not the form has valid input. For example, the "Save"
  /// button is disabled when the input is not valid.
  final bool isInputValid;

  /// Whether this form's components can be added or removed.
  final bool editable;

  /// Called when the save button is pressed. Returning true will dismiss
  /// the form page; false will leave it open.
  ///
  /// A unique [BuildContext] is passed into the function if the current
  /// [Scaffold] needs to be accessed. For example, to show a [SnackBar].
  final FutureOr<bool> Function(BuildContext) onSave;

  /// Space between form input widgets.
  final double runSpacing;

  /// The text for the "save" button. Defaults to "Save".
  final String saveButtonText;

  final EdgeInsets padding;

  FormPage({
    Key key,
    this.title,
    @required this.fieldBuilder,
    this.onSave,
    this.addFieldOptions,
    this.onAddFields,
    this.editable = true,
    this.padding = insetsHorizontalDefault,
    this.runSpacing,
    this.saveButtonText,
    @required this.isInputValid,
  }) : assert(fieldBuilder != null),
       assert(isInputValid != null),
       super(key: key);

  FormPage.immutable({
    Key key,
    Widget title,
    FieldBuilder fieldBuilder,
    FutureOr<bool> Function(BuildContext) onSave,
    EdgeInsets padding = insetsHorizontalDefault,
    double runSpacing,
    @required bool isInputValid,
    String saveButtonText,
  }) : this(
    key: key,
    title: title,
    fieldBuilder: fieldBuilder,
    onSave: onSave,
    addFieldOptions: null,
    onAddFields: null,
    editable: false,
    padding: padding,
    runSpacing: runSpacing,
    isInputValid: isInputValid,
    saveButtonText: saveButtonText,
  );

  @override
  _FormPageState createState() => _FormPageState();

  FormPageFieldOption fieldOption(String id) {
    if (addFieldOptions == null) {
      return null;
    } else {
      return addFieldOptions.firstWhere((option) => option.id == id,
          orElse: () => null);
    }
  }
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  bool get canAddFields =>
      widget.addFieldOptions != null && widget.addFieldOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          Builder(builder: (context) => ActionButton(
            text: widget.saveButtonText ?? Strings.of(context).save,
            onPressed: widget.isInputValid
                ? () => _onPressedSave(context) : null,
            condensed: widget.editable,
          )),
          widget.editable ? PopupMenuButton<_OverflowOption>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem<_OverflowOption>(
                value: _OverflowOption.manageFields,
                child: Text(Strings.of(context).formPageManageFieldText),
              ),
            ],
            onSelected: (option) {
              if (option == _OverflowOption.manageFields) {
                present(context, _addFieldSelectionPage());
              }
            },
          ) : Empty(),
        ],
      ),
      body: Padding(
        padding: widget.padding,
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            padding: insetsBottomDefault,
            child: SafeArea(
              left: true,
              right: true,
              top: true,
              bottom: true,
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Wrap(
          runSpacing: widget.runSpacing ?? paddingSmall,
          children: widget.fieldBuilder(context).values.toList(),
        ),
      ],
    );
  }

  Widget _addFieldSelectionPage() => _SelectionPage(
    options: widget.addFieldOptions,
    onSelectItems: (selectedIds) => widget.onAddFields(selectedIds),
  );

  void _onPressedSave(BuildContext saveContext) async {
    if (!_key.currentState.validate()) {
      return;
    }

    _key.currentState.save();

    if (widget.onSave == null || await widget.onSave(saveContext)) {
      Navigator.pop(context);
    }
  }
}

class _SelectionPage extends StatefulWidget {
  final List<FormPageFieldOption> options;
  final Function(Set<String>) onSelectItems;

  _SelectionPage({
    @required this.options,
    this.onSelectItems,
  }) : assert(options != null);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  List<CustomEntity> _addedCustomFields = [];

  @override
  Widget build(BuildContext context) {
    List<FormPageFieldOption> options = allOptions;
    Set<FormPageFieldOption> used = options.where((e) => e.used).toSet();

    return PickerPage<FormPageFieldOption>(
      title: Text(Strings.of(context).formPageSelectFieldsTitle),
      initialValues: used,
      itemBuilder: () => options.map((o) =>
          PickerPageItem<FormPageFieldOption>(
            title: o.userFacingName,
            value: o,
            enabled: o.removable,
          )).toList(),
      onFinishedPicking: (context, options) {
        widget.onSelectItems(options.map((o) => o.id).toSet());
        Navigator.pop(context);
      },
      itemManager: PickerPageItemAddManager<FormPageFieldOption>(
        onAddPressed: () => present(context, AddCustomFieldPage(
          onSave: (customField) {
            setState(() {
              _addedCustomFields.add(customField);
            });
          },
        ),
      )),
    );
  }

  List<FormPageFieldOption> get allOptions {
    return []..addAll(widget.options)
      ..addAll(_addedCustomFields.map((CustomEntity field) {
        return FormPageFieldOption(
          id: field.id,
          userFacingName: field.name,
        );
      }));
  }
}