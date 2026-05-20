import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/empty_state.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final devices = controller.trashDevices;
    if (devices.isEmpty) {
      return const EmptyState(
        title: 'Корзина пуста',
        subtitle: 'Удалённые устройства появятся здесь.',
        icon: Icons.delete_outline,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!controller.isAdmin)
          const Card(
            child: ListTile(
              title: Text('Восстановление доступно администратору'),
            ),
          ),
        ...devices.map(
          (device) => Card(
            child: ListTile(
              title: Text(device.name),
              subtitle: Text('${device.ipAddress} · ${device.room}'),
              trailing: controller.isAdmin
                  ? OutlinedButton(
                      onPressed: () => controller.restoreDevice(device.id),
                      child: const Text('Восстановить'),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
