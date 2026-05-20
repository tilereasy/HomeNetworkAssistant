import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/empty_state.dart';

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
      children: items
          .map(
            (item) => Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text('${item.message}\n${item.createdAt.toLocal()}'),
                isThreeLine: true,
                trailing: item.isRead
                    ? null
                    : TextButton(
                        onPressed: () => controller.markNotificationRead(item.id),
                        child: const Text('Прочитано'),
                      ),
              ),
            ),
          )
          .toList(),
    );
  }
}
