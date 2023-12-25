import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:monetization_kit/iap/consuming_manager.dart';

export 'package:in_app_purchase/in_app_purchase.dart';

class IAP {
  Future<bool> Function(
    String productId,
    String serverVerificationData,
  )? verifyPurchase;

  Completer<bool>? _purchasing;
  Completer<void>? _storing;
  Timer? _purchaseRevoking;
  final _stateListeners = <String, ValueNotifier<bool>>{};

  IAP({required this.verifyPurchase}) {
    InAppPurchase.instance.purchaseStream.listen((detailsList) async {
      _storing?.complete();
      _storing = null;
      _iapLog("purchaseStream detailsList: ${detailsList.length}");
      final verifyNeeded = <String, String>{};
      for (var detail in detailsList) {
        // product can be restore, stop auto revoking
        _purchaseRevoking?.cancel();
        if (detail.status == PurchaseStatus.pending) {
          _iapLog("purchaseStream pending...");
          return;
        }
        // 手动完成订阅
        if (detail.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(detail);
        }
        if (detail.status == PurchaseStatus.canceled) {
          _purchasing?.complete(false);
          return;
        }
        if (detail.productID.isEmpty ||
            detail.verificationData.serverVerificationData.isEmpty) {
          continue;
        }
        verifyNeeded[detail.productID] =
            detail.verificationData.serverVerificationData;
      }
      _iapLog("purchaseStream verifyNeeded: ${verifyNeeded.length}");
      // 验证订阅
      bool verified = false;
      for (var productId in verifyNeeded.keys) {
        final token = verifyNeeded[productId]!;
        _iapLog("purchaseStream verifyPurchase: productId: $productId");
        verified = verifyPurchase == null
            ? true
            : await verifyPurchase!.call(
                productId,
                token,
              );
        final listener = _stateListeners[productId] ??= ValueNotifier(verified);
        listener.value = verified;
        final consuming =
            Consuming(productId: productId, serverVerificationData: token);
        if (verified) {
          ConsumingManager.instance.apply(
            (consumingList) {
              if (!consumingList.contains(consuming)) {
                consumingList.add(consuming);
              }
            },
          );
        } else {
          ConsumingManager.instance.apply(
            (consumingList) {
              if (consumingList.contains(consuming)) {
                consumingList.remove(consuming);
              }
            },
          );
        }
        if (verified == false) break;
      }
      ConsumingManager.instance.apply(
        (consumingList) {
          for (var consuming in consumingList) {
            // already unsubscribed
            if (!verifyNeeded.keys.contains(consuming.productId) ||
                !verifyNeeded.values
                    .contains(consuming.serverVerificationData)) {
              _stateListeners[consuming.productId]?.value = false;
            }
          }
        },
      );
      _purchasing?.complete(verified);
    });
  }

  ///
  /// check if IAP is available
  ///
  Future<bool> connect() async {
    return await InAppPurchase.instance.isAvailable();
  }

  ///
  /// restore purchase
  /// [revokeTimeout] Auto revoking purchase state after given duration, default 5s.
  ///
  Future<void> restore({
    Duration revokeTimeout = const Duration(seconds: 5),
  }) async {
    _purchaseRevoking = Timer(revokeTimeout, () {
      for (var listener in _stateListeners.values) {
        listener.value = false;
      }
      ConsumingManager.instance.apply((consumingList) => consumingList.clear());
      _storing?.complete();
      _storing = null;
    });
    _storing = Completer();
    await InAppPurchase.instance.restorePurchases();
    await _storing!.future;
  }

  ValueNotifier<bool> stateOf(String productId) {
    final purchased = ConsumingManager.instance.list.any(
      (consuming) => consuming.productId == productId,
    );
    return _stateListeners[productId] ??= ValueNotifier(purchased);
  }

  ///
  /// query products with product ID list
  ///
  Future<List<ProductDetails>> queryProducts(List<String> productIdList) async {
    final resp = await InAppPurchase.instance.queryProductDetails({
      ...productIdList,
      "queryId-${DateTime.now().millisecondsSinceEpoch}",
    });
    return resp.productDetails;
  }

  ///
  /// return true if purchase is succeed
  ///
  Future<bool> purchase(
    ProductType type,
    ProductDetails product, {
    Map<String, dynamic>? extra,
  }) async {
    _iapLog("purchase type: ${type.name}");
    if (_purchasing != null) return false;
    _purchasing = Completer();
    final Future<bool> Function({required PurchaseParam purchaseParam}) buyFunc;
    switch (type) {
      case ProductType.consumable:
        buyFunc = InAppPurchase.instance.buyConsumable;
        break;
      case ProductType.inconsumable:
        buyFunc = InAppPurchase.instance.buyNonConsumable;
        break;
    }
    buyFunc.call(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: extra == null ? null : jsonEncode(extra),
      ),
    );
    final result = await _purchasing!.future;
    _purchasing = null;
    _iapLog("purchase type: ${type.name} result: $result");
    return result;
  }
}

_iapLog(Object? obj) {
  if (kReleaseMode) return;
  // ignore: avoid_print
  print("[IAP]$obj");
}

enum ProductType {
  consumable,
  inconsumable,
}
