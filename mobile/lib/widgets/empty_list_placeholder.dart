import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/text.dart';
import 'widget.dart';

class EmptyListPlaceholder extends StatelessWidget {
  static EmptyListPlaceholder noSearchResults(
    BuildContext context, {
    EdgeInsets padding = insetsDefault,
    bool scrollable = false,
  }) {
    return EmptyListPlaceholder(
      title: Strings.of(context).emptyListPlaceholderNoResultsTitle,
      description: Strings.of(context).emptyListPlaceholderNoResultsDescription,
      icon: Icons.search_off,
      padding: padding,
      scrollable: scrollable,
    );
  }

  final String title;
  final String description;

  /// If set, a [IconLabel] is used, and [descriptionIcon] is inserted into
  /// [description].
  final IconData descriptionIcon;

  final IconData icon;
  final EdgeInsets padding;

  /// If true, will embed the view in a [SingleChildScrollView]. Defaults to
  /// true.
  final bool scrollable;

  EmptyListPlaceholder({
    this.title,
    this.description,
    this.descriptionIcon,
    this.icon,
    this.padding = insetsDefault,
    this.scrollable = true,
  })  : assert(padding != null),
        assert(scrollable != null);

  EmptyListPlaceholder.static({
    String title,
    String description,
    IconData descriptionIcon,
    IconData icon,
    EdgeInsets padding = insetsDefault,
  }) : this(
          title: title,
          description: description,
          descriptionIcon: descriptionIcon,
          icon: icon,
          padding: padding,
          scrollable: false,
        );

  @override
  Widget build(BuildContext context) {
    Widget descriptionWidget = Empty();
    if (isNotEmpty(description)) {
      var overflow = TextOverflow.visible;
      var align = TextAlign.center;
      var enabled = false;

      if (descriptionIcon == null) {
        descriptionWidget = PrimaryLabel(
          description,
          overflow: overflow,
          align: align,
          enabled: enabled,
        );
      } else {
        descriptionWidget = IconLabel(
          text: description,
          icon: Icon(
            descriptionIcon,
            color: Colors.black,
          ),
          textStyle: stylePrimary(context, enabled: enabled),
          overflow: overflow,
          align: align,
        );
      }
    }

    var child = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WatermarkLogo(
            icon: icon,
            color: Colors.grey.shade400,
          ),
          Padding(
            padding: insetsVerticalDefault,
            child: AlertTitleLabel(title),
          ),
          descriptionWidget,
        ],
      ),
    );

    if (scrollable) {
      return Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}