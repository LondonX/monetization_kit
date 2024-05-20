import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:monetization_kit/ad/entity/ad_enum.dart';
import 'package:monetization_kit/ad/provider/ad_provider.dart';
import 'package:monetization_kit/monetization_kit.dart';

class SettingsPage extends StatefulWidget {
  final List<FakeAnalytics> fakeAnalyticsList;
  const SettingsPage({
    super.key,
    required this.fakeAnalyticsList,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Timer? _lazyUpdating;
  _analyticsChange() {
    _lazyUpdating?.cancel();
    _lazyUpdating = Timer(const Duration(milliseconds: 20), () {
      setState(() {});
    });
  }

  @override
  void initState() {
    for (var analytics in widget.fakeAnalyticsList) {
      analytics.addListener(_analyticsChange);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var analytics in widget.fakeAnalyticsList) {
      analytics.removeListener(_analyticsChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("MonetizationKit initial finished"),
          subtitle: Text(
              "${MonetizationKit.instance.adProviders.length} AdProviders."),
        ),
        ListTile(
          title: const Text("Admob inspector"),
          onTap: MonetizationKit.instance.startAdmobInspector,
        ),
        ListTile(
          title: const Text("Admob mediation test"),
          onTap: MonetizationKit.instance.startAdmobMediationTest,
        ),
        SwitchListTile(
          title: const Text("MonetizationKit.debug"),
          value: MonetizationKit.debug,
          onChanged: (v) {
            setState(() {
              MonetizationKit.debug = v;
            });
          },
        ),
        ListTile(
          title: Row(
            children: [
              const Text("Fake analytics"),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _logs.clear();
                  });
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          subtitle: ListView.builder(
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(_logs[index]),
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }
}

final _logs = <String>[];

class FakeAnalytics extends ChangeNotifier {
  final String page;
  FakeAnalytics({
    required this.page,
  });

  log(String s) {
    _logs.insert(0, s);
    notifyListeners();
    // ignore: avoid_print
    if (!kReleaseMode) print("[FakeAnalytics]$s");
  }

  logAds(AdProvider provider, AdAction action, AdType type, String unitId) {
    final String actionReadable;
    switch (action) {
      case AdAction.request:
        actionReadable = "🟡 ${action.name}";
        break;
      case AdAction.loaded:
        actionReadable = "🟢 ${action.name}";
        break;
      case AdAction.loadFailed:
        actionReadable = "🔴 ${action.name}";
        break;
      case AdAction.impress:
        actionReadable = "👁 ${action.name}";
        break;
      case AdAction.click:
        actionReadable = "✋ ${action.name}";
        break;
      case AdAction.close:
        actionReadable = "❎ ${action.name}";
        break;
    }
    log(
      "$page(${provider.name})\n$actionReadable\n${type.name}\n$unitId",
    );
  }
}
