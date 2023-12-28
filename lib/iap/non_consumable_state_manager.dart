import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NonConsumableStateManager {
  final _subscriptionStatePool = <String, ValueNotifier<bool>>{};

  late File _file;
  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _file = File("${dir.path}/monet_ncs.json");
    await _file.create();
    final data = await _file.readAsBytes();
    if (data.isEmpty) return;
    final json = String.fromCharCodes(data.reversed);
    final productIds = (jsonDecode(json) as List).map((e) => e.toString());
    for (var productId in productIds) {
      stateOf(productId).value = true;
    }
  }

  void revokeNotExits(Iterable<String> productIds) {
    for (var productId in _subscriptionStatePool.keys) {
      if (productIds.contains(productId)) continue;
      _subscriptionStatePool[productId]?.value = false;
    }
  }

  Future<void> save() async {
    final json = jsonEncode(_subscriptionStatePool.keys.toList());
    await _file.writeAsBytes(json.codeUnits.reversed.toList());
  }

  ValueNotifier<bool> stateOf(String productId) {
    return _subscriptionStatePool[productId] ??= ValueNotifier(false);
  }
}
