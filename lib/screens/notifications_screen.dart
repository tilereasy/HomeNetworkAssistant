import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../models/notification_item.dart';
import '../services/app_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.visibleNotifications;
    if (items.isEmpty) {
      return const EmptyState(
        title: 'Нет уведомлений',
        subtitle: 'Новые уведомления по сети появятся здесь.',
        icon: Icons.notifications_off_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((item) {
        NetworkDevice? device;
        if (item.relatedDeviceId != null) {
          for (final entry in controller.data.devices) {
            if (entry.id == item.relatedDeviceId) {
              device = entry;
              break;
            }
          }
        }

        final deviceId = device?.id;
        final request = deviceId == null
            ? <dynamic>[]
            : controller.currentProjectRequests
                .where((entry) => entry.deviceId == deviceId)
                .toList();
        if (request.isNotEmpty) {
          request.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        }

        final latestRequest = request.isEmpty ? null : request.first;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (device != null) StatusChip(status: device.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.message),
                const SizedBox(height: 8),
                Text(
                  'Дата: ${item.createdAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (controller.isAdmin &&
                    item.actionType == NotificationActionType.deviceRequest &&
                    device != null &&
                    latestRequest != null &&
                    latestRequest.status.name == 'pending') ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => controller.decideDeviceRequest(
                          requestId: latestRequest.id,
                          notificationId: item.id,
                          deviceId: device!.id,
                          approve: true,
                        ),
                        child: const Text('Одобрить'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.decideDeviceRequest(
                          requestId: latestRequest.id,
                          notificationId: item.id,
                          deviceId: device!.id,
                          approve: false,
                        ),
                        child: const Text('Отклонить'),
                      ),
                    ],
                  ),
                ] else if (!item.isRead) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => controller.markNotificationRead(item.id),
                    child: const Text('Отметить как прочитанное'),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
