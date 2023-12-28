import 'dart:async';

abstract class PurchaseVerifier {
  const PurchaseVerifier();
  FutureOr<bool> verify(
    String productId,
    String purchaseToken,
  );
}
