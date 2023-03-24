import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

class SettingsPage extends StatefulWidget {
  final FakeAnalytics fakeAnalytics;
  const SettingsPage({
    super.key,
    required this.fakeAnalytics,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("MonetizationKit initial finished"),
          subtitle: Text(
              "${MonetizationKit.instance.adProviders.length} AdProviders."),
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
          title: const Text("Fake analytics"),
          subtitle: AnimatedBuilder(
            animation: widget.fakeAnalytics,
            builder: (context, child) {
              final logs = widget.fakeAnalytics._logs;
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(logs[index]),
                  );
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FakeAnalytics extends ChangeNotifier {
  final _logs = <String>[];

  log(String s) {
    _logs.insert(0, s);
    notifyListeners();
    // ignore: avoid_print
    if (!kReleaseMode) print("[FakeAnalytics]$s");
  }
}
