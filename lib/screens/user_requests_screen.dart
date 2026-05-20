import 'package:flutter/material.dart';

import '../models/device_request.dart';
import '../services/app_controller.dart';
import '../widgets/empty_state.dart';

class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final requests = controller.isAdmin ? controller.currentProjectRequests : controller.myRequests;
    if (requests.isEmpty) {
      return EmptyState(
        title: controller.isAdmin ? 'Нет пользовательских запросов' : 'Нет отправленных запросов',
        subtitle: controller.isAdmin
            ? 'Заявки на новые устройства появятся здесь.'
            : 'Отправьте новое устройство на рассмотрение администратору.',
        icon: Icons.assignment_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: requests.map((request) {
        final device = controller.data.devices.firstWhere((item) => item.id == request.deviceId);
        int notificationId = 0;
        for (final item in controller.data.notifications) {
          if (item.relatedDeviceId == device.id) {
            notificationId = item.id;
            break;
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Автор запроса: ${request.requesterLogin}'),
                Text('Статус: ${_label(request.status)}'),
                Text('Обновлено: ${request.updatedAt.toLocal()}'),
                if (controller.isAdmin && request.status == DeviceRequestStatus.pending) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => controller.decideDeviceRequest(
                          requestId: request.id,
                          notificationId: notificationId,
                          deviceId: device.id,
                          approve: true,
                        ),
                        child: const Text('Одобрить'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.decideDeviceRequest(
                          requestId: request.id,
                          notificationId: notificationId,
                          deviceId: device.id,
                          approve: false,
                        ),
                        child: const Text('Отклонить'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(DeviceRequestStatus status) {
    switch (status) {
      case DeviceRequestStatus.pending:
        return 'Ожидает';
      case DeviceRequestStatus.approved:
        return 'Одобрен';
      case DeviceRequestStatus.rejected:
        return 'Отклонён';
    }
  }
}
