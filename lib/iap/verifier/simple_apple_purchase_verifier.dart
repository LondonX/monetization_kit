import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:monetization_kit/iap/verifier/purchase_verifier.dart';
import 'package:monetization_kit/monetization_kit.dart';

///
/// Simple practice of purchase verify of Apple
/// doc: https://developer.apple.com/documentation/appstorereceipts/verifyreceipt
///
class SimpleApplePurchaseVerifier extends PurchaseVerifier {
  final String password;

  const SimpleApplePurchaseVerifier({required this.password});

  @override
  FutureOr<bool> verify(String productId, String purchaseToken) async {
    if (!Platform.isIOS && !Platform.isMacOS) return true;
    final body = {
      "receipt-data": purchaseToken,
      "password": password,
    };
    final respList = await Future.wait([
      FlutterInappPurchase.instance.validateReceiptIos(
        receiptBody: body,
        isTest: false,
      ),
      FlutterInappPurchase.instance.validateReceiptIos(
        receiptBody: body,
        isTest: true,
      )
    ]);
    final jsonList = respList.map((e) => _safeJsonDecode(e.body));
    final validJson =
        jsonList.where((json) => json?["status"] == 0).firstOrNull;
    // Cannot fetch receipt info.
    if (validJson == null) return false;
    final latestReceipts = (validJson["latest_receipt_info"] as List?)
            ?.where((receipt) => receipt["product_id"] == productId)
            .toList() ??
        [];
    var maxExpireAt = 0;
    for (var receipt in latestReceipts) {
      final expireMs = receipt["expires_date_ms"];
      if (expireMs == null) {
        // in-app-purchase, not subscription
        return true;
      }
      final expire = int.tryParse(expireMs) ?? 0;
      if (expire > maxExpireAt) {
        maxExpireAt = expire;
      }
    }
    final isCanceled = maxExpireAt < DateTime.now().millisecondsSinceEpoch;
    if (isCanceled) return false;
    return true;
  }
}

Map<String, dynamic>? _safeJsonDecode(String s) {
  try {
    return jsonDecode(s);
  } catch (e) {
    if (MonetizationKit.debug) {
      // ignore: avoid_print
      print(
        "[SimpleApplePurchaseVerifier]failed to transform resp from apple, e: $e",
      );
    }
  }
  return null;
}
