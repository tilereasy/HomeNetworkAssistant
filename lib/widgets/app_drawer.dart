import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    final entries = user.isAdmin
        ? const [
            MapEntry(AppSection.projects, 'Проекты'),
            MapEntry(AppSection.devices, 'Устройства'),
            MapEntry(AppSection.favorites, 'Избранное'),
            MapEntry(AppSection.trash, 'Корзина'),
            MapEntry(AppSection.networkMap, 'Карта сети'),
            MapEntry(AppSection.routerSettings, 'Настройки роутера'),
            MapEntry(AppSection.recommendations, 'Рекомендации'),
            MapEntry(AppSection.notifications, 'Уведомления'),
            MapEntry(AppSection.requests, 'Запросы пользователей'),
            MapEntry(AppSection.profile, 'Профиль'),
            MapEntry(AppSection.about, 'О приложении'),
          ]
        : const [
            MapEntry(AppSection.projects, 'Проекты'),
            MapEntry(AppSection.devices, 'Устройства'),
            MapEntry(AppSection.myDevices, 'Мои устройства'),
            MapEntry(AppSection.favorites, 'Избранное'),
            MapEntry(AppSection.requests, 'Отправленные запросы'),
            MapEntry(AppSection.networkMap, 'Карта сети'),
            MapEntry(AppSection.notifications, 'Уведомления'),
            MapEntry(AppSection.profile, 'Профиль'),
            MapEntry(AppSection.about, 'О приложении'),
          ];

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.login),
            accountEmail: Text(user.isAdmin ? 'Администратор' : 'Пользователь'),
            currentAccountPicture: CircleAvatar(
              child: Text(user.login.substring(0, 1).toUpperCase()),
            ),
          ),
          ...entries.map(
            (entry) => ListTile(
              selected: controller.section == entry.key,
              title: Text(entry.value),
              onTap: () {
                Navigator.of(context).pop();
                controller.setSection(entry.key);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выйти'),
            onTap: () async {
              Navigator.of(context).pop();
              await controller.logout();
            },
          ),
        ],
      ),
    );
  }
}
