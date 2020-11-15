import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';

class AddAnythingPage extends StatelessWidget {
  static const double _blurSigma = 6.0;
  static const double _backgroundOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    // TODO: Verify BackdropFilter fix on GoogleMap (https://github.com/flutter/flutter/issues/43902)
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: _blurSigma,
        sigmaY: _blurSigma,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor
            .withOpacity(_backgroundOpacity),
        body: SafeArea(
          top: true,
          bottom: true,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingIconButton(
                          icon: CustomIcons.catches,
                          label: Strings.of(context).addAnythingPageCatch,
                          onPressed: () {
                            Navigator.of(context).pop();
                            present(context, AddCatchJourney());
                          }
                        ),
                        FloatingIconButton(
                          icon: Icons.public,
                          label: Strings.of(context).addAnythingPageTrip,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    FloatingIconButton(
                      icon: Icons.close,
                      padding: insetsTiny,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}