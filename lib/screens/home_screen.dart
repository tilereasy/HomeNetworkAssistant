import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/app_drawer.dart';
import 'about_screen.dart';
import 'add_device_screen.dart';
import 'device_list_screen.dart';
import 'favorites_screen.dart';
import 'my_devices_screen.dart';
import 'network_map_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'project_selection_screen.dart';
import 'recommendations_screen.dart';
import 'router_settings_screen.dart';
import 'trash_screen.dart';
import 'user_requests_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForSection(controller.section)),
            actions: [
              IconButton(
                tooltip: 'Уведомления',
                onPressed: () => controller.setSection(AppSection.notifications),
                icon: Badge.count(
                  count: controller.unreadNotificationsCount,
                  isLabelVisible: controller.unreadNotificationsCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          drawer: AppDrawer(controller: controller),
          floatingActionButton: controller.section == AppSection.devices ||
                  controller.section == AppSection.projects
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddFlow(context),
                  icon: Icon(
                    controller.section == AppSection.projects ? Icons.home_work : Icons.add,
                  ),
                  label: Text(
                    controller.section == AppSection.projects
                        ? 'Новый проект'
                        : controller.isAdmin
                            ? 'Добавить устройство'
                            : 'Запросить устройство',
                  ),
                )
              : null,
          body: _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    switch (controller.section) {
      case AppSection.projects:
        return ProjectSelectionScreen(controller: controller);
      case AppSection.devices:
        return DeviceListScreen(controller: controller);
      case AppSection.myDevices:
        return MyDevicesScreen(controller: controller);
      case AppSection.favorites:
        return FavoritesScreen(controller: controller);
      case AppSection.requests:
        return UserRequestsScreen(controller: controller);
      case AppSection.trash:
        return TrashScreen(controller: controller);
      case AppSection.networkMap:
        return NetworkMapScreen(controller: controller);
      case AppSection.routerSettings:
        return RouterSettingsScreen(controller: controller);
      case AppSection.recommendations:
        return RecommendationsScreen(controller: controller);
      case AppSection.notifications:
        return NotificationsScreen(controller: controller);
      case AppSection.profile:
        return ProfileScreen(controller: controller);
      case AppSection.about:
        return const AboutScreen();
    }
  }

  Future<void> _openAddFlow(BuildContext context) async {
    if (controller.section == AppSection.projects) {
      await showDialog<void>(
        context: context,
        builder: (_) => ProjectCreateDialog(controller: controller),
      );
      return;
    }

    final draft = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddDeviceScreen(controller: controller)),
    );
    if (draft != null) {
      await controller.addDevice(draft);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.isAdmin
                  ? 'Устройство добавлено'
                  : 'Запрос на устройство отправлен администратору',
            ),
          ),
        );
      }
    }
  }
}

String _titleForSection(AppSection section) {
  switch (section) {
    case AppSection.projects:
      return 'Проекты сети';
    case AppSection.devices:
      return 'Устройства сети';
    case AppSection.myDevices:
      return 'Мои устройства';
    case AppSection.favorites:
      return 'Избранное';
    case AppSection.requests:
      return 'Запросы';
    case AppSection.trash:
      return 'Корзина';
    case AppSection.networkMap:
      return 'Карта сети';
    case AppSection.routerSettings:
      return 'Настройки роутера';
    case AppSection.recommendations:
      return 'Рекомендации';
    case AppSection.notifications:
      return 'Уведомления';
    case AppSection.profile:
      return 'Профиль';
    case AppSection.about:
      return 'О приложении';
  }
}
