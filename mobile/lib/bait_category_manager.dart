import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/string_utils.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitCategoryManager;

  BaitManager get _baitManager => appManager.baitManager;

  BaitCategoryManager(AppManager app) : super(app);

  @override
  BaitCategory entityFromBytes(List<int> bytes) =>
      BaitCategory.fromBuffer(bytes);

  @override
  Id id(BaitCategory baitCategory) => baitCategory.id;

  @override
  String name(BaitCategory baitCategory) => baitCategory.name;

  @override
  String get tableName => "bait_category";

  int numberOfBaits(Id? baitCategoryId) => numberOf<Bait>(
      baitCategoryId, _baitManager.list(), (bait) => bait.baitCategoryId);

  String deleteMessage(BuildContext context, BaitCategory baitCategory) {
    var numOfBaits = numberOfBaits(baitCategory.id);
    var string = numOfBaits == 1
        ? Strings.of(context).baitCategoryListPageDeleteMessageSingular
        : Strings.of(context).baitCategoryListPageDeleteMessage;
    return format(string, [baitCategory.name, numOfBaits]);
  }
}
