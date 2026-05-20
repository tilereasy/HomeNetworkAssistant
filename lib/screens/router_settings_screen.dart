import 'package:flutter/material.dart';

import '../models/router_settings.dart';
import '../services/app_controller.dart';

class RouterSettingsScreen extends StatefulWidget {
  const RouterSettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<RouterSettingsScreen> createState() => _RouterSettingsScreenState();
}

class _RouterSettingsScreenState extends State<RouterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ssidController;
  late final TextEditingController _passwordController;
  late final TextEditingController _dhcpRangeController;
  late String _band;
  late String _channel;
  late bool _dhcpEnabled;
  late bool _guestEnabled;
  late bool _hiddenSsid;
  late double _maxDevices;

  @override
  void initState() {
    super.initState();
    final settings = widget.controller.currentRouterSettings;
    _ssidController = TextEditingController(text: settings.ssid);
    _passwordController = TextEditingController(text: settings.password);
    _dhcpRangeController = TextEditingController(text: settings.dhcpRange);
    _band = settings.band;
    _channel = settings.channel;
    _dhcpEnabled = settings.dhcpEnabled;
    _guestEnabled = settings.guestNetworkEnabled;
    _hiddenSsid = settings.hiddenSsid;
    _maxDevices = settings.maxDevices.toDouble();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _dhcpRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.controller.isAdmin;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _ssidController,
            readOnly: !isAdmin,
            decoration: const InputDecoration(labelText: 'SSID сети', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            readOnly: !isAdmin,
            decoration: const InputDecoration(labelText: 'Пароль Wi-Fi', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('Диапазон Wi-Fi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '2.4 GHz', label: Text('2.4 GHz')),
              ButtonSegment(value: '5 GHz', label: Text('5 GHz')),
            ],
            selected: {_band},
            onSelectionChanged: isAdmin ? (values) => setState(() => _band = values.first) : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _channel,
            decoration: const InputDecoration(labelText: 'Канал Wi-Fi', border: OutlineInputBorder()),
            items: const ['1', '6', '11', '36', '40', '44']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: isAdmin ? (value) => setState(() => _channel = value!) : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dhcpRangeController,
            readOnly: !isAdmin,
            decoration: const InputDecoration(
              labelText: 'Диапазон DHCP',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            value: _dhcpEnabled,
            onChanged: isAdmin ? (value) => setState(() => _dhcpEnabled = value) : null,
            title: const Text('DHCP включён'),
          ),
          SwitchListTile(
            value: _guestEnabled,
            onChanged: isAdmin ? (value) => setState(() => _guestEnabled = value) : null,
            title: const Text('Гостевая сеть'),
          ),
          SwitchListTile(
            value: _hiddenSsid,
            onChanged: isAdmin ? (value) => setState(() => _hiddenSsid = value) : null,
            title: const Text('Скрывать SSID'),
          ),
          Text('Максимум устройств: ${_maxDevices.round()}'),
          Slider(
            value: _maxDevices,
            min: 5,
            max: 100,
            divisions: 19,
            onChanged: isAdmin ? (value) => setState(() => _maxDevices = value) : null,
          ),
          if (isAdmin)
            FilledButton(
              onPressed: () async {
                final settings = RouterSettings(
                  projectId: widget.controller.currentProject.id,
                  ssid: _ssidController.text.trim(),
                  password: _passwordController.text.trim(),
                  band: _band,
                  channel: _channel,
                  dhcpEnabled: _dhcpEnabled,
                  dhcpRange: _dhcpRangeController.text.trim(),
                  guestNetworkEnabled: _guestEnabled,
                  hiddenSsid: _hiddenSsid,
                  maxDevices: _maxDevices.round(),
                );
                await widget.controller.saveRouterSettings(settings);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Настройки сохранены')),
                  );
                }
              },
              child: const Text('Сохранить настройки'),
            ),
        ],
      ),
    );
  }
}
