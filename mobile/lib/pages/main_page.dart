import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/add_anything_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/map_page.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/widget.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentBarItem = 1; // Default to the "Catches" tab.
  List<_BarItemData> _navItems;

  NavigatorState get _currentNavState =>
      _navItems[_currentBarItem].page.navigatorKey.currentState;

  @override
  void initState() {
    super.initState();

    _navItems = [
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (BuildContext context) => MapPage(),
        ),
        icon: Icons.map,
        titleBuilder: (context) => Strings.of(context).mapPageMenuLabel,
      ),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (BuildContext context) => CatchListPage(),
        ),
        icon: CustomIcons.catches,
        titleBuilder: (context) => Strings.of(context).catchListPageMenuLabel,
      ),
      _BarItemData(
          icon: Icons.add_box_rounded,
          titleBuilder: (context) => Strings.of(context).add,
          onTapOverride: () {
            fade(context, AddAnythingPage(), false);
          }),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (BuildContext context) => StatsPage(),
        ),
        icon: Icons.show_chart,
        titleBuilder: (context) => Strings.of(context).statsPageMenuTitle,
      ),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (BuildContext context) => MorePage(),
        ),
        icon: Icons.more_horiz,
        titleBuilder: (context) => Strings.of(context).morePageTitle,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      // Ensure clicking the Android physical back button closes a pushed page
      // rather than the entire app, if possible.
      onWillPop: () async => !await _currentNavState.maybePop(),
      child: Scaffold(
        // An IndexedStack is an easy way to persist state when switching
        // between pages.
        body: IndexedStack(
          index: _currentBarItem,
          children: _navItems
              .map((_BarItemData data) => data.page ?? Empty())
              .toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBarItem,
          type: BottomNavigationBarType.fixed,
          items: _navItems
              .map((_BarItemData data) => BottomNavigationBarItem(
                    icon: Icon(data.icon),
                    label: data.titleBuilder(context),
                  ))
              .toList(),
          onTap: (index) {
            if (_navItems[index].onTapOverride != null) {
              _navItems[index].onTapOverride();
              return;
            }

            if (_currentBarItem == index) {
              // Reset navigation stack if already on the current item.
              _currentNavState.popUntil((r) => r.isFirst);
            } else {
              setState(() {
                _currentBarItem = index;
              });
            }
          },
        ),
      ),
    );
  }
}

class _BarItemData {
  final _NavigatorPage page;
  final String Function(BuildContext) titleBuilder;
  final IconData icon;

  /// If set, overrides the default behaviour of showing the associated
  /// [Widget].
  final VoidCallback onTapOverride;

  _BarItemData({
    this.page,
    @required this.titleBuilder,
    @required this.icon,
    this.onTapOverride,
  })  : assert(page != null || onTapOverride != null),
        assert(titleBuilder != null),
        assert(icon != null);
}

/// A page with its own [Navigator]. Meant to be used in combination with a
/// [BottomNavigationBar] to persist back stack state when switching between
/// tabs.
class _NavigatorPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) builder;

  _NavigatorPage({
    this.navigatorKey,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: builder,
      ),
      observers: [
        HeroController(),
      ],
    );
  }
}
