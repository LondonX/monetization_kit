import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

class IAPPage extends StatefulWidget {
  const IAPPage({super.key});

  @override
  State<IAPPage> createState() => _IAPPageState();
}

class _IAPPageState extends State<IAPPage> {
  final _refresher = GlobalKey<RefreshIndicatorState>();
  final _products = <IAPItem>[];
  bool _restoring = false;

  Future<void> _refresh() async {
    final products = await MonetizationKit.instance.iap
        .queryProducts(["wallpaper_gpt_pro_monthly"]);
    setState(() {
      _products
        ..clear()
        ..addAll(products);
    });
  }

  Future<void> _restore() async {
    setState(() {
      _restoring = true;
    });
    await MonetizationKit.instance.iap.restore();
    setState(() {
      _restoring = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refresher.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refresher,
      onRefresh: _refresh,
      child: ListView(
        children: [
          ListTile(
            title: const Text("Restore purchase"),
            onTap: _restoring ? null : _restore,
            trailing: _restoring
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(),
                  )
                : null,
          ),
          ..._products.map(_buildProduct),
        ],
      ),
    );
  }

  Widget _buildProduct(IAPItem product) {
    final purchaseState =
        MonetizationKit.instance.iap.stateOf(product.productId!);
    return ListTile(
      title: Text(product.title ?? "<NO TITLE>"),
      subtitle: Text(product.description ?? "<NO DESCRIPTION>"),
      trailing: ValueListenableBuilder(
        valueListenable: purchaseState,
        builder: (context, isPurchased, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.price ?? "<NO PRICE>",
                style: const TextStyle(color: Colors.red),
              ),
              if (isPurchased)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: const Icon(Icons.check, color: Colors.green),
                ),
            ],
          );
        },
      ),
      onTap: () {
        MonetizationKit.instance.iap.purchase(product.productId!);
      },
    );
  }
}
