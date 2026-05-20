import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text(user.login),
            subtitle: Text(user.isAdmin ? 'Роль: администратор' : 'Роль: пользователь'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Последний вход'),
            subtitle: Text('${user.lastLogin?.toLocal() ?? 'Нет данных'}'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Избранные устройства'),
            subtitle: Text('${user.favoriteDeviceIds.length} сохранено в профиле'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Текущий проект'),
            subtitle: Text(controller.currentProject.name),
          ),
        ),
      ],
    );
  }
}
