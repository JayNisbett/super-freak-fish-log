import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app_manager.dart';
import 'auth_manager.dart';
import 'log.dart';
import 'properties_manager.dart';
import 'utils/void_stream_controller.dart';
import 'wrappers/purchases_wrapper.dart';

enum SubscriptionState {
  pro,
  free,
}

enum RestoreSubscriptionResult {
  noSubscriptionsFound,
  error,
  success,
}

/// Manages a user's subscription state. A middleman between the app and the
/// RevenueCat SDK.
///
/// Sandbox testing notes:
/// - iOS subscriptions will auto-review five times before becoming inactive.
///   There's nothing to do here but wait. For wait times, see
///   https://help.apple.com/app-store-connect/#/dev7e89e149d.
class SubscriptionManager {
  static SubscriptionManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).subscriptionManager;

  static const _debugPurchases = false;
  static const _idProEntitlement = "pro";

  static const _trialDaysYearly = 14;
  static const _trialDaysMonthly = 7;

  final _log = Log("SubscriptionManager");
  final _controller = VoidStreamController();

  final AppManager _appManager;

  var _state = SubscriptionState.free;

  SubscriptionManager(this._appManager);

  AuthManager get _authManager => _appManager.authManager;

  PropertiesManager get _propertiesManager => _appManager.propertiesManager;

  PurchasesWrapper get _purchasesWrapper => _appManager.purchasesWrapper;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  bool get isFree =>
      !_userPreferenceManager.isPro && _state == SubscriptionState.free;

  bool get isPro =>
      _userPreferenceManager.isPro || _state == SubscriptionState.pro;

  /// A [Stream] that fires events when [state] updates. Listeners should
  /// access the [state] property directly, as it will always have a valid
  /// value, unlike the [AsyncSnapshot] passed to the listener function.
  Stream<void> get stream => _controller.stream;

  Future<void> initialize() async {
    // Setup RevenueCat.
    await _purchasesWrapper.setup(_propertiesManager.revenueCatApiKey);
    _purchasesWrapper.setDebugEnabled(_debugPurchases);

    // Allows the same Apple ID/Google account to be used to restore purchases
    // on multiple Anglers' Log accounts, since IAPs are tied to storefront IDs.
    _purchasesWrapper.setAllowSharingStoreAccount(true);

    // Setup purchase state listener.
    _purchasesWrapper
        .addPurchaserInfoUpdateListener(_setStateFromPurchaserInfo);

    _authManager.stream.listen((_) {
      if (_authManager.state == AuthState.loggedIn) {
        _purchasesWrapper.identify(_authManager.userId!);
      } else {
        _purchasesWrapper.reset();
      }
    });
  }

  Future<void> purchaseSubscription(Subscription sub) async {
    // Note that this method doesn't return an error or result object because
    // purchase errors are shown by the underlying storefront UI.
    try {
      _setStateFromPurchaserInfo(
          await _purchasesWrapper.purchasePackage(sub.package));
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) !=
          PurchasesErrorCode.purchaseCancelledError) {
        _log.e("Purchase error: ${e.message}");
      }
    }
  }

  Future<RestoreSubscriptionResult> restoreSubscription() async {
    try {
      _setStateFromPurchaserInfo(await _purchasesWrapper.restoreTransactions());
      return isFree
          ? RestoreSubscriptionResult.noSubscriptionsFound
          : RestoreSubscriptionResult.success;
    } on PlatformException catch (e) {
      _log.e("Purchase restore error: ${e.message}");
      return RestoreSubscriptionResult.error;
    }
  }

  Future<Subscriptions?> subscriptions() async {
    var offerings = await _purchasesWrapper.getOfferings();

    if (offerings.current == null) {
      _log.e("Current offering is null");
      return null;
    }

    if (offerings.current!.availablePackages.isEmpty) {
      _log.e("Current offering has no available packages");
      return null;
    }

    return Subscriptions(
      Subscription(offerings.current!.monthly!, _trialDaysMonthly),
      Subscription(offerings.current!.annual!, _trialDaysYearly),
    );
  }

  void _setState(SubscriptionState state) {
    if (_state == state) {
      return;
    }
    _log.d("Updated state: $state");
    _state = state;
    _controller.notify();
  }

  void _setStateFromPurchaserInfo(PurchaserInfo purchaserInfo) {
    _setState(purchaserInfo.entitlements.all[_idProEntitlement]!.isActive
        ? SubscriptionState.pro
        : SubscriptionState.free);
  }
}

class Subscription {
  final Package package;
  final int trialLengthDays;

  Subscription(this.package, this.trialLengthDays);

  String get price => package.product.priceString;
}

/// A convenience class that stores subscription options. A single class like
/// this is easier to manage than a collection of subscriptions, especially
/// when the options shouldn't change.
class Subscriptions {
  final Subscription monthly;
  final Subscription yearly;

  Subscriptions(this.monthly, this.yearly);
}
