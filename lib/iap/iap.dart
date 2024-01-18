import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

import 'purchase_state_manager.dart';
import 'verifier/purchase_verifier.dart';

class IAP {
  final _nonConsumableStateManager = PurchaseStateManager();
  final _verifiers = <PurchaseVerifier>[];

  final purchasing = ValueNotifier<Purchasing?>(null);

  ///
  /// init IAP class
  ///
  Future<void> init() async {
    await _nonConsumableStateManager.init();
    await FlutterInappPurchase.instance.finalize();
    final result = await FlutterInappPurchase.instance.initialize();
    _log("init result: $result");
    FlutterInappPurchase.purchaseUpdated
        .asBroadcastStream()
        .listen(_purchaseUpdate);
    FlutterInappPurchase.purchaseError
        .asBroadcastStream()
        .listen(_purchaseError);
  }

  ///
  /// add [PurchaseVerifier]
  ///
  void addVerifier(PurchaseVerifier verifier) {
    _verifiers.add(verifier);
  }

  ///
  /// remove [PurchaseVerifier]
  ///
  void removeVerifier(PurchaseVerifier verifier) {
    _verifiers.remove(verifier);
  }

  ///
  /// state of Subscription or non-consumable product
  /// returns in [ValueNotifier<bool>]
  ///
  ValueNotifier<bool> stateOf(String productId) {
    return _nonConsumableStateManager.stateOf(productId);
  }

  ///
  /// apply purchase from AppStore
  /// restore the state of Subscription or non-consumable product
  /// result will update in [stateOf]
  ///
  Future<void> restore() async {
    final applyingProducts =
        await FlutterInappPurchase.instance.getAppStoreInitiatedProducts();
    for (var product in applyingProducts) {
      final productId = product.productId;
      if (productId == null) continue;
      await purchase(productId);
    }
    final purchases =
        (await FlutterInappPurchase.instance.getAvailablePurchases()) ?? [];
    final distinctedPurchases = <PurchasedItem>[];
    //sort by new to old
    for (var item in purchases.reversed) {
      if (distinctedPurchases.any((e) =>
          e.originalTransactionIdentifierIOS != null &&
          e.originalTransactionIdentifierIOS ==
              item.originalTransactionIdentifierIOS)) continue;
      distinctedPurchases.add(item);
    }
    for (var purchase in distinctedPurchases) {
      final productId = purchase.productId;
      final purchaseToken =
          purchase.purchaseToken ?? purchase.transactionReceipt;
      if (productId == null || purchaseToken == null) continue;
      var success = true;
      for (var verifier in _verifiers) {
        if (!await verifier.verify(productId, purchaseToken)) {
          _log(
            "verifier<${verifier.runtimeType}> returns false during restore",
          );
          success = false;
          break;
        }
      }
      stateOf(productId).value = success;
    }
    _nonConsumableStateManager.revokeNotExits(
      distinctedPurchases.map((e) => e.productId).whereType(),
    );
    //revoke purchase cache
    await _nonConsumableStateManager.save();
  }

  ///
  /// query products and subscriptions by product ids
  ///
  Future<List<IAPItem>> queryProducts(List<String> productIds) async {
    final lists = await Future.wait([
      FlutterInappPurchase.instance.getProducts(productIds),
      FlutterInappPurchase.instance.getSubscriptions(productIds),
    ]);
    final products = lists[0];
    final subscriptions = lists[1];
    // doc: "iOS does not differentiate between IAP products and subscriptions."
    final results = [...products];
    for (var sub in subscriptions) {
      if (results.any((e) => e.productId == sub.productId)) continue;
      results.add(sub);
    }
    return results;
  }

  Future<bool> purchase(String productId) async {
    final lists = await Future.wait([
      FlutterInappPurchase.instance.getProducts([productId]),
      FlutterInappPurchase.instance.getSubscriptions([productId]),
    ]);
    final products = lists[0];
    final subscriptions = lists[1];
    final ProductType type;
    if (products.any((e) => e.productId == productId)) {
      type = ProductType.consumable;
      //TODO non-consumable product
    } else if (subscriptions.any((e) => e.productId == productId)) {
      type = ProductType.nonConsumable;
    } else {
      _log("product/subscription not found, productId: $productId");
      return false;
    }
    if (purchasing.value != null) {
      // current purchasing not finished.
      return false;
    }
    final value = Purchasing(
      productId: productId,
      completer: Completer<bool>(),
      type: type,
    );
    purchasing.value = value;
    try {
      final f = type == ProductType.consumable
          ? FlutterInappPurchase.instance.requestPurchase
          : FlutterInappPurchase.instance.requestSubscription;
      f.call(productId);
    } catch (e, stack) {
      _log("Failed during purchase e: $e");
      debugPrintStack(stackTrace: stack);
      purchasing.value = null;
      if (!value.completer.isCompleted) {
        value.completer.complete(false);
      }
    }
    return await value.completer.future;
  }

  Future<void> _purchaseUpdate(PurchasedItem? item) async {
    final purchasingValue = purchasing.value;
    final productId = item?.productId;
    final purchaseToken = item?.purchaseToken ?? item?.transactionReceipt;
    if (item == null ||
        productId == null ||
        purchaseToken == null ||
        purchasingValue == null) return;
    final isPaid = item.purchaseStateAndroid == PurchaseState.purchased ||
        item.transactionStateIOS == TransactionState.purchased ||
        item.transactionStateIOS ==
            TransactionState.restored; // purchase from app store
    if (!isPaid) return;
    var success = true;
    for (var verifier in _verifiers) {
      if (!await verifier.verify(productId, purchaseToken)) {
        _log(
          "verifier<${verifier.runtimeType}> returns false during _purchaseUpdate",
        );
        success = false;
        break;
      }
    }
    if (success) {
      FlutterInappPurchase.instance.finishTransaction(
        item,
        isConsumable: purchasingValue.type == ProductType.consumable,
      );
      stateOf(productId).value = true;
      _nonConsumableStateManager.save();
    }
    final completer = purchasingValue.completer;
    if (!completer.isCompleted) {
      completer.complete(success);
    }
    purchasing.value = null;
  }

  Future<void> _purchaseError(PurchaseResult? result) async {
    final purchasingValue = purchasing.value;
    if (result == null ||
        purchasingValue == null ||
        purchasingValue.completer.isCompleted) return;
    _log("purchaseError: $result, productId: ${purchasingValue.productId}");
    purchasingValue.completer.complete(false);
    purchasing.value = null;
  }
}

_log(Object? obj) {
  if (MonetizationKit.debug) {
    // ignore: avoid_print
    print("[IAP]$obj");
  }
}

class Purchasing {
  final String productId;
  final Completer<bool> completer;
  final ProductType type;
  const Purchasing({
    required this.productId,
    required this.completer,
    required this.type,
  });
}

enum ProductType {
  consumable,
  nonConsumable,
}
