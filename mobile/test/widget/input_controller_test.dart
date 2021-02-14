import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

class MockNameValidator extends Mock implements NameValidator {}

void main() {
  test("Use IdInputController instead of InputController<Id>", () {
    expect(() => InputController<Id>(), throwsAssertionError);
  });

  group("IdInputController", () {
    test("Empty uuid sets value to null", () {
      var controller = IdInputController();
      expect(controller.value, isNull);

      controller.value = Id();
      expect(controller.value, isNull);
    });

    test("Value is set if uuid is not empty", () {
      var controller = IdInputController();
      expect(controller.value, isNull);

      var id = randomId();
      controller.value = id;
      expect(controller.value, id);
    });
  });

  group("TextInputController", () {
    test("Empty value returns null", () {
      var controller = TextInputController(
        validator: NameValidator(),
      );
      expect(controller.value, isNull);
    });

    test("Value is trimmed of trailing and leading whitespace", () {
      var controller = TextInputController(
        validator: NameValidator(),
      );
      controller.value = " Whitespace String ";
      expect(controller.value, "Whitespace String");
    });

    test("Initial value is trimmed of trailing and leading whitespace", () {
      var controller = TextInputController(
        editingController: TextEditingController(
          text: " Test with whitespace ",
        ),
        validator: NameValidator(),
      );
      expect(controller.value, "Test with whitespace");
    });

    testWidgets("Null validator", (tester) async {
      var context = await buildContext(tester);
      var controller = TextInputController();
      expect(controller.valid(context), isTrue);
    });

    testWidgets("Non-null validator", (tester) async {
      var context = await buildContext(tester);
      var validator = MockNameValidator();
      when(validator.run(context, "Test")).thenReturn((context) => "BAD");
      var controller = TextInputController(validator: MockNameValidator());
      expect(controller.valid(context), isTrue);
    });
  });

  group("TimestampInputController", () {
    test("Null input", () {
      var controller = TimestampInputController();
      expect(controller.date, isNull);
      expect(controller.time, isNull);
    });

    test("Non-null input", () {
      var controller = TimestampInputController(
        date: DateTime(2020, 1, 15),
        time: TimeOfDay(hour: 15, minute: 30),
      );
      expect(controller.value,
          DateTime(2020, 1, 15, 15, 30).millisecondsSinceEpoch);
    });

    test("Set to non-null", () {
      var controller = TimestampInputController();
      var timestamp = DateTime(2020, 1, 15, 15, 30).millisecondsSinceEpoch;
      controller.value = timestamp;
      expect(controller.value, timestamp);
    });

    test("Set to null", () {
      var controller = TimestampInputController();
      controller.value = null;
      expect(controller.value, isNull);
    });
  });
}
