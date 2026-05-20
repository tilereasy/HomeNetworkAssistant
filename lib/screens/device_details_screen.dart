import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import '../widgets/device_card.dart';
import 'device_form_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  const DeviceDetailsScreen({
    super.key,
    required this.controller,
    required this.deviceId,
  });

  final AppController controller;
  final int deviceId;

  @override
  Widget build(BuildContext context) {
    final device = controller.data.devices.firstWhere((item) => item.id == deviceId);

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DeviceCard(
            device: device,
            onTap: () {},
            onFavoriteTap: () => controller.toggleFavorite(device.id),
          ),
          const SizedBox(height: 12),
          _DetailsCard(
            title: 'Подробности',
            rows: [
              'Тип: ${device.type}',
              'IP-адрес: ${device.ipAddress}',
              'MAC-адрес: ${device.macAddress}',
              'Комната: ${device.room}',
              'Подключение: ${device.connectionType.name}',
              'Скорость: ${device.speedMbps} Мбит/с',
              'Сигнал: ${device.signalStrength}%',
              'Статус: ${statusLabel(device.status)}',
              'Создал: ${device.createdBy}',
              'Добавлено: ${device.createdAt.toLocal()}',
              'Описание: ${device.description.isEmpty ? 'Нет' : device.description}',
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => controller.toggleFavorite(device.id),
                icon: Icon(device.isFavorite ? Icons.star : Icons.star_border),
                label: Text(
                  device.isFavorite ? 'Убрать из избранного' : 'В избранное',
                ),
              ),
              if (controller.isAdmin)
                OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<NetworkDevice>(
                      MaterialPageRoute(
                        builder: (_) => DeviceFormScreen(
                          initialDevice: device,
                          isAdmin: true,
                          createdBy: controller.currentUser!.login,
                        ),
                      ),
                    );

                    if (updated != null) {
                      await controller.updateDevice(updated);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                ),
              if (controller.isAdmin)
                OutlinedButton.icon(
                  onPressed: () async {
                    await controller.moveToTrash(device.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('В корзину'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.title, required this.rows});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(row),
                )),
          ],
        ),
      ),
    );
  }
}
