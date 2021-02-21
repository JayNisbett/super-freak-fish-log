import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/text.dart';

/// The page shown while initialization futures are completing.
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(children: [
        Align(
          alignment: Alignment(0.0, -0.5),
          child: Icon(
            CustomIcons.catches,
            size: 200,
            color: Colors.white,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: insetsDefault,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Label(
                    Strings.of(context).by,
                    style: TextStyle(color: Colors.white54),
                  ),
                  Label(
                    Strings.of(context).devName,
                    style: stylePrimary(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
