import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/string_utils.dart';

class WaterClarityManager extends NamedEntityManager<WaterClarity> {
  static WaterClarityManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).waterClarityManager;

  CatchManager get _catchManager => appManager.catchManager;

  WaterClarityManager(AppManager app) : super(app);

  @override
  WaterClarity entityFromBytes(List<int> bytes) =>
      WaterClarity.fromBuffer(bytes);

  @override
  Id id(WaterClarity clarity) => clarity.id;

  @override
  String name(WaterClarity clarity) => clarity.name;

  @override
  String get tableName => "water_clarity";

  int numberOfCatches(Id? clarityId) => numberOf<Catch>(clarityId,
      _catchManager.list(), (cat) => cat.waterClarityId == clarityId);

  String deleteMessage(BuildContext context, WaterClarity clarity) {
    var numOfCatches = numberOfCatches(clarity.id);
    var string = numOfCatches == 1
        ? Strings.of(context).waterClarityListPageDeleteMessageSingular
        : Strings.of(context).waterClarityListPageDeleteMessage;
    return format(string, [clarity.name, numOfCatches]);
  }
}