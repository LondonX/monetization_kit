import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
      ],
    );
  }
}
