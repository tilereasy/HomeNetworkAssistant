import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final devices = controller.activeDevices;
    final weakSignal = devices.where((item) => item.signalStrength < 40).toList();
    final issues = devices.where((item) => item.status == DeviceStatus.issue).toList();
    final wifiCount = devices.where((item) => item.connectionType == ConnectionType.wifi).length;
    final router = controller.currentRouterSettings;

    final items = <String>[
      if (weakSignal.isNotEmpty)
        'Устройство ${weakSignal.first.name} находится в зоне слабого сигнала. Рекомендуется усилить покрытие.',
      if (issues.isNotEmpty)
        'Обнаружены проблемные устройства. Проверьте IP, DHCP и физическое подключение.',
      if (wifiCount > 10)
        'Сеть Wi-Fi перегружена. Переведите часть устройств на 5 GHz или Ethernet.',
      if (!router.dhcpEnabled)
        'DHCP выключен. Убедитесь, что у всех устройств настроены статические адреса.',
      if (router.maxDevices < devices.length)
        'Лимит устройств на роутере меньше числа активных узлов. Увеличьте максимум подключений.',
      if (router.band == '2.4 GHz' && wifiCount > 6)
        'Для текущего проекта стоит включить 5 GHz для разгрузки 2.4 GHz диапазона.',
    ];

    if (items.isEmpty) {
      items.add('Сеть выглядит стабильно. Явных рекомендаций сейчас нет.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.tips_and_updates_outlined),
                title: Text(item),
              ),
            ),
          )
          .toList(),
    );
  }
}
