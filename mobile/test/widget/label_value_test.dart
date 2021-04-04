import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/label_value.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Long value renders column", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => LabelValue(
          label: "Test",
          value: "A really long value that shows in a column",
        ),
      ),
    );
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets("Short column renders row", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => LabelValue(
          label: "Test",
          value: "Value",
        ),
      ),
    );
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });
}
