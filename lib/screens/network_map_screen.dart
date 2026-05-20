import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class NetworkMapScreen extends StatelessWidget {
  const NetworkMapScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final wifi = controller.activeDevices
        .where((device) => device.connectionType.name == 'wifi')
        .toList();
    final ethernet = controller.activeDevices
        .where((device) => device.connectionType.name == 'ethernet')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFE0F2F1),
          child: ListTile(
            title: Text(controller.currentProject.name),
            subtitle: Text(
              '${controller.currentProject.propertyType} · ${controller.currentProject.provider}',
            ),
          ),
        ),
        const _MapNode(title: 'Интернет'),
        const _MapConnector(),
        _MapNode(title: controller.currentProject.primaryRouterName),
        const _MapConnector(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Branch(title: 'Wi-Fi', items: wifi.map((e) => e.name).toList())),
            const SizedBox(width: 16),
            Expanded(
              child: _Branch(
                title: 'Ethernet',
                items: ethernet.map((e) => e.name).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
      ),
    );
  }
}

class _MapConnector extends StatelessWidget {
  const _MapConnector();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(Icons.more_vert),
      ),
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $item'),
                )),
          ],
        ),
      ),
    );
  }
}
