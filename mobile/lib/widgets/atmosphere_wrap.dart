import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/date_time_utils.dart';
import '../utils/protobuf_utils.dart';
import 'multi_measurement_input.dart';
import 'widget.dart';

class AtmosphereWrap extends StatelessWidget {
  final Atmosphere atmosphere;

  const AtmosphereWrap(this.atmosphere);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    if (atmosphere.hasTemperature()) {
      children.add(_Item(
        icon: Icons.cloud,
        title: atmosphere.temperature.displayValue(
          context,
          MultiMeasurementInputSpec.airTemperature(context)
              .mainValueDecimalPlaces,
        ),
        subtitle:
            SkyConditions.displayNameForList(context, atmosphere.skyConditions),
      ));
    }

    if (atmosphere.hasWindSpeed()) {
      children.add(_Item(
        icon: Icons.air,
        title: atmosphere.windSpeed.displayValue(
          context,
          MultiMeasurementInputSpec.windSpeed(context).mainValueDecimalPlaces,
        ),
        subtitle: atmosphere.hasWindDirection()
            ? atmosphere.windDirection.displayName(context)
            : Strings.of(context).atmosphereInputWind,
      ));
    }

    if (atmosphere.hasPressure()) {
      children.add(_Item(
        icon: Icons.speed,
        title: atmosphere.pressure.displayValue(
          context,
          MultiMeasurementInputSpec.airPressure(context).mainValueDecimalPlaces,
        ),
        subtitle: Strings.of(context).atmosphereInputPressure,
      ));
    }

    if (atmosphere.hasVisibility()) {
      children.add(_Item(
        icon: Icons.visibility,
        title: atmosphere.visibility.displayValue(
          context,
          MultiMeasurementInputSpec.airVisibility(context)
              .mainValueDecimalPlaces,
        ),
        subtitle: Strings.of(context).atmosphereInputVisibility,
      ));
    }

    if (atmosphere.hasHumidity()) {
      children.add(_Item(
        icon: CustomIcons.humidity,
        title: atmosphere.humidity.displayValue(
          context,
          MultiMeasurementInputSpec.airHumidity(context).mainValueDecimalPlaces,
        ),
        subtitle: Strings.of(context).atmosphereInputHumidity,
      ));
    }

    if (atmosphere.hasSunriseTimestamp()) {
      children.add(_Item(
        icon: CustomIcons.sunrise,
        title: formatTimeMillis(context, atmosphere.sunriseTimestamp),
        subtitle: Strings.of(context).atmosphereInputSunrise,
      ));
    }

    if (atmosphere.hasSunsetTimestamp()) {
      children.add(_Item(
        icon: CustomIcons.sunset,
        title: formatTimeMillis(context, atmosphere.sunsetTimestamp),
        subtitle: Strings.of(context).atmosphereInputSunset,
      ));
    }

    if (atmosphere.hasMoonPhase()) {
      children.add(_Item(
        icon: Icons.nightlight,
        title: atmosphere.moonPhase.displayName(context),
        subtitle: Strings.of(context).atmosphereInputMoon,
      ));
    }

    return Wrap(
      spacing: paddingDefault,
      runSpacing: paddingDefault,
      children: children,
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  _Item({
    required this.icon,
    required this.title,
    this.subtitle,
  }) : assert(isNotEmpty(title));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        Text(
          title,
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
        isEmpty(subtitle)
            ? const Empty()
            : Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: styleSubtitle(context),
                overflow: TextOverflow.visible,
              ),
      ],
    );
  }
}
