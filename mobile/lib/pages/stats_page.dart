import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatelessWidget {
  final AppManager app;

  StatsPage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).statsPageTitle,
        actions: [
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}