import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/pages/photos_page.dart';
import 'package:mobile/widgets/app_bar_gradient.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn(["1", "2", "3", "4"]);
  });

  testWidgets("No images", (tester) async {
    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => PhotosPage(),
      appManager: appManager,
    ));

    expect(find.byType(Photo), findsNothing);
  });

  testWidgets("Thumbnails loaded", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => PhotosPage(),
      appManager: appManager,
    ));

    expect(find.byType(Photo), findsNWidgets(4));
  });

  testWidgets("Tapping thumbnail opens image", (tester) async {
    var image = await loadImage(tester, "test/resources/flutter_logo.png");
    when(appManager.imageManager.dartImage(any, any, any))
        .thenAnswer((_) => Future.value(image));

    await tester.pumpWidget(Testable(
      (_) => PhotosPage(),
      appManager: appManager,
    ));
    // Wait for photo future to settle.
    await tester.pump(Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(Photo).first);
    expect(find.byType(PhotoGalleryPage), findsOneWidget);
  });

  testWidgets("If there are no images, gradient app bar isn't shown",
      (tester) async {
    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);
    await tester.pumpWidget(Testable(
      (_) => PhotosPage(),
      appManager: appManager,
    ));

    expect(find.byType(AppBarGradient), findsNothing);
  });
}
