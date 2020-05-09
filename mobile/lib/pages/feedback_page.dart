import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/device_utils.dart';
import 'package:mobile/utils/snackbar_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/dropdown_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:package_info/package_info.dart';
import 'package:quiver/strings.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const String _nameId = "name";
  static const String _emailId = "email";
  static const String _typeId = "type";
  static const String _messageId = "message";

  final Log _log = Log("FeedbackPage");

  final Map<String, InputData> _fields = {};

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  TextInputController get _nameController => _fields[_nameId].controller;
  TextInputController get _emailController => _fields[_emailId].controller;
  InputController<_FeedbackType> get _typeController =>
      _fields[_typeId].controller;
  TextInputController get _messageController => _fields[_messageId].controller;

  @override
  void initState() {
    super.initState();

    _fields[_nameId] = InputData(
      id: _nameId,
      label: (context) => "",
      controller: TextInputController(),
      showing: true,
    );

    _fields[_emailId] = InputData(
      id: _emailId,
      label: (context) => "",
      controller: TextInputController(),
      showing: true,
    );

    _fields[_typeId] = InputData(
      id: _typeId,
      label: (context) => "",
      controller: InputController<_FeedbackType>(
        value: _FeedbackType.bug,
      ),
      showing: true,
    );

    _fields[_messageId] = InputData(
      id: _messageId,
      label: (context) => "",
      controller: TextInputController(
        validate: (context) => Strings.of(context).inputGenericRequired,
      ),
      showing: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(Strings.of(context).feedbackPageTitle),
      isInputValid: isEmpty(_emailController.error(context))
          && isEmpty(_messageController.error(context)),
      saveButtonText: Strings.of(context).feedbackPageSend,
      fieldBuilder: (context) => {
        _nameId: TextInput.name(context,
          controller: _nameController,
          autofocus: true,
        ),
        _emailId: TextInput.email(context,
          controller: _emailController,
          // To update "Send" button state.
          onChanged: () => setState(() {}),
        ),
        _typeId: Padding(
          padding: insetsBottomDefault,
          child: Column(
            children: <Widget>[
              DropdownInput(
                options: _FeedbackType.values,
                value: _typeController.value,
                buildOption: (_FeedbackType type) =>
                    Text(_feedbackTypeToString(type)),
                onChanged: (_FeedbackType newType) {
                  setState(() {
                    _typeController.value = newType;
                  });
                },
              ),
            ],
          ),
        ),
        _messageId: TextInput(
          label: Strings.of(context).feedbackPageMessage,
          controller: _messageController,
          capitalization: TextCapitalization.sentences,
          maxLength: null,
          // To update "Send" button state.
          onChanged: () => setState(() {}),
          validator: EmptyValidator(),
        ),
      },
      onSave: (context) async {
        if (!await isConnected()) {
          showErrorSnackBar(context,
              Strings.of(context).feedbackPageConnectionError);
          return false;
        }

        showPermanentSnackBar(context, Strings.of(context).feedbackPageSending);

        String name = _nameController.text;
        String email = _emailController.text;
        String type = _feedbackTypeToString(_typeController.value);
        String message = _messageController.text;

        String appVersion = (await PackageInfo.fromPlatform()).version;
        String osVersion;
        String deviceModel;

        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isIOS) {
          IosDeviceInfo info = await deviceInfo.iosInfo;
          osVersion = "${info.systemName} (${info.systemVersion})";
          deviceModel = info.utsname.machine;
        } else if (Platform.isAndroid) {
          AndroidDeviceInfo info = await deviceInfo.androidInfo;
          osVersion = "Android (${info.version.sdkInt})";
          deviceModel = info.model;
        }

        SmtpServer server = gmail(_propertiesManager.clientSenderEmail,
            _propertiesManager.clientSenderPassword);

        Message content = Message()
            ..from = Address(_propertiesManager.clientSenderEmail,
                "Anglers' Log Client")
            ..recipients.add(_propertiesManager.supportEmail)
            ..subject = "Feedback from Anglers' Log"
            ..text = format(_propertiesManager.feedbackTemplate, [
              appVersion,
              isNotEmpty(osVersion) ? osVersion : "Unknown",
              isNotEmpty(deviceModel) ? deviceModel : "Unknown",
              type,
              isNotEmpty(name) ? name : "Unknown",
              isNotEmpty(email) ? email : "Unknown",
              message,
            ]);

        try {
          await send(content, server);
        } on MailerException catch(e) {
          for (var p in e.problems) {
            _log.e("Error sending feedback: ${p.code}: ${p.msg}");
          }

          // Hide "sending" SnackBar and show error.
          Scaffold.of(context).hideCurrentSnackBar();
          showErrorSnackBar(context,
              Strings.of(context).feedbackPageErrorSending);

          return false;
        }

        return true;
      },
    );
  }

  String _feedbackTypeToString(_FeedbackType type) {
    switch (type) {
      case _FeedbackType.bug:
        return Strings.of(context).feedbackPageBugType;
      case _FeedbackType.feedback:
        return Strings.of(context).feedbackPageFeedbackType;
      case _FeedbackType.suggestion:
        return Strings.of(context).feedbackPageSuggestionType;
    }
    return null;
  }
}

enum _FeedbackType {
  suggestion, feedback, bug
}