import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/gen/custom_icons.dart';
import '../subscription_manager.dart';
import '../user_preference_manager.dart';
import '../utils/page_utils.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';
import 'pro_page.dart';
import 'units_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: <Widget>[
          _buildFetchAtmosphere(context),
          const MinDivider(),
          _buildUnits(context),
        ],
      ),
    );
  }

  Widget _buildFetchAtmosphere(BuildContext context) {
    return CheckboxInput(
      label: Strings.of(context).settingsPageFetchAtmosphereTitle,
      description: Strings.of(context).settingsPageFetchAtmosphereDescription,
      value: _userPreferenceManager.autoFetchAtmosphere,
      onChanged: (checked) {
        if (_subscriptionManager.isPro && checked) {
          _userPreferenceManager.setAutoFetchAtmosphere(true);
        } else if (checked) {
          // "Uncheck" checkbox, since automatically refreshing data is
          // a pro feature.
          setState(() {
            _userPreferenceManager.setAutoFetchAtmosphere(false);
          });
          present(context, ProPage());
        } else {
          _userPreferenceManager.setAutoFetchAtmosphere(false);
        }
      },
    );
  }

  Widget _buildUnits(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).unitsPageTitle),
      leading: const Icon(CustomIcons.ruler),
      trailing: RightChevronIcon(),
      onTap: () => push(context, UnitsPage()),
    );
  }
}
