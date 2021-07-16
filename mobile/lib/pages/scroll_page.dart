import 'package:flutter/material.dart';
import '../res/dimen.dart';
import '../widgets/widget.dart';

class ScrollPage extends StatelessWidget {
  final AppBar? appBar;
  final List<Widget> children;

  /// See [Scaffold.persistentFooterButtons].
  final List<Widget>? footer;

  final EdgeInsets padding;

  /// See [Scaffold.extendBodyBehindAppBar].
  final bool extendBodyBehindAppBar;

  final bool enableHorizontalSafeArea;
  final bool centerContent;

  /// When non-null, material swipe-to-refresh feature is enabled. See
  /// [RefreshIndicator.onRefresh].
  final Future<void> Function()? onRefresh;

  /// Sets the [RefreshIndicator] key, which can be used to hide/show the
  /// refresh indicator programmatically. This field is ignored if [onRefresh]
  /// is null.
  final Key? refreshIndicatorKey;

  ScrollPage({
    this.appBar,
    this.children = const [],
    this.footer,
    this.padding = insetsZero,
    this.extendBodyBehindAppBar = true,
    this.enableHorizontalSafeArea = true,
    this.centerContent = false,
    this.onRefresh,
    this.refreshIndicatorKey,
  });

  @override
  Widget build(BuildContext context) {
    Widget scrollView = SingleChildScrollView(
      // Apply vertical padding inside the child Column so scrolling isn't
      // cut off.
      padding: padding.copyWith(
        top: 0,
        bottom: 0,
      ),
      child: SafeArea(
        left: enableHorizontalSafeArea,
        right: enableHorizontalSafeArea,
        child: Column(
          children: []
            ..add(VerticalSpace(padding.top))
            ..addAll(children)
            ..add(VerticalSpace(padding.bottom)),
        ),
      ),
      // Ensures view is scrollable, even when items don't exceed screen size.
      physics: AlwaysScrollableScrollPhysics(),
      // Ensures items are cut off when over-scrolling on iOS.
      clipBehavior: Clip.none,
    );

    if (centerContent) {
      scrollView = Center(
        child: scrollView,
      );
    }

    var child = scrollView;
    if (onRefresh != null) {
      child = RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: onRefresh!,
        child: scrollView,
      );
    }

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      persistentFooterButtons: footer,
      body: child,
    );
  }
}
