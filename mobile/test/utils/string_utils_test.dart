import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test("Format function", () {
    var formatString = format("You caught %s fish in %s days.", [5, 3]);
    expect(formatString, "You caught 5 fish in 3 days.");

    formatString = format("You've added angler %s to your log.",
        ["Cohen Adair"]);
    expect(formatString, "You've added angler Cohen Adair to your log.");
  });

  test("Format bait name", () {
    var bait = Bait(name: "Bait");
    var category = BaitCategory(name: "Category");
    expect(formatBaitName(bait), "Bait");
    expect(formatBaitName(bait, category), "Category - Bait");
  });
}