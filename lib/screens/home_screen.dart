import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../models/notification_item.dart';
import '../models/router_settings.dart';
import '../services/app_controller.dart';
import '../widgets/device_card.dart';
import 'device_details_screen.dart';
import 'device_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final user = controller.currentUser!;

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
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user.login),
                  accountEmail: Text(user.isAdmin ? 'Администратор' : 'Пользователь'),
                  currentAccountPicture: CircleAvatar(
                    child: Text(user.login.substring(0, 1).toUpperCase()),
                  ),
                ),
                ..._buildDrawerEntries(user.isAdmin),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Выйти'),
                  onTap: controller.logout,
                ),
              ],
            ),
          ),
          floatingActionButton: controller.section == AppSection.devices
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddDevice(context),
                  icon: const Icon(Icons.add),
                  label: Text(user.isAdmin ? 'Добавить устройство' : 'Запросить устройство'),
                )
              : null,
          body: _buildBody(context),
        );
      },
    );
  }

  List<Widget> _buildDrawerEntries(bool isAdmin) {
    final entries = <MapEntry<AppSection, String>>[
      const MapEntry(AppSection.devices, 'Устройства'),
      const MapEntry(AppSection.favorites, 'Избранное'),
      const MapEntry(AppSection.trash, 'Корзина'),
      const MapEntry(AppSection.networkMap, 'Карта сети'),
      const MapEntry(AppSection.routerSettings, 'Настройки роутера'),
      const MapEntry(AppSection.recommendations, 'Рекомендации'),
      const MapEntry(AppSection.notifications, 'Уведомления'),
      const MapEntry(AppSection.profile, 'Профиль'),
      const MapEntry(AppSection.about, 'О приложении'),
    ];

    return entries.where((entry) => isAdmin || entry.key != AppSection.trash).map((entry) {
      return Builder(
        builder: (context) => ListTile(
          selected: controller.section == entry.key,
          title: Text(entry.value),
          onTap: () {
            Navigator.of(context).pop();
            controller.setSection(entry.key);
          },
        ),
      );
    }).toList();
  }

  Widget _buildBody(BuildContext context) {
    switch (controller.section) {
      case AppSection.devices:
        return _DeviceListSection(controller: controller, devices: controller.pagedDevices);
      case AppSection.favorites:
        return _DeviceListSection(
          controller: controller,
          devices: controller.favoriteDevices,
          emptyMessage: 'Нет избранных устройств',
        );
      case AppSection.trash:
        return _TrashSection(controller: controller);
      case AppSection.networkMap:
        return _NetworkMapSection(controller: controller);
      case AppSection.routerSettings:
        return _RouterSettingsSection(controller: controller);
      case AppSection.recommendations:
        return _RecommendationsSection(controller: controller);
      case AppSection.notifications:
        return _NotificationsSection(controller: controller);
      case AppSection.profile:
        return _ProfileSection(controller: controller);
      case AppSection.about:
        return const _AboutSection();
    }
  }

  Future<void> _openAddDevice(BuildContext context) async {
    final createdBy = controller.currentUser!.login;
    final draft = await Navigator.of(context).push<NetworkDevice>(
      MaterialPageRoute(
        builder: (_) => DeviceFormScreen(
          isAdmin: controller.isAdmin,
          createdBy: createdBy,
        ),
      ),
    );

    if (draft != null) {
      await controller.addDevice(draft);
    }
  }
}

class _DeviceListSection extends StatelessWidget {
  const _DeviceListSection({
    required this.controller,
    required this.devices,
    this.emptyMessage = 'Список пуст',
  });

  final AppController controller;
  final List<NetworkDevice> devices;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    final canShowMore = controller.section == AppSection.devices &&
        controller.visibleDevicesCount < controller.activeDevices.length;

    return ListView.builder(
      itemCount: devices.length + (canShowMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == devices.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: controller.showMoreDevices,
              child: const Text('Показать ещё 5'),
            ),
          );
        }

        final device = devices[index];
        return DeviceCard(
          device: device,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeviceDetailsScreen(
                  controller: controller,
                  deviceId: device.id,
                ),
              ),
            );
          },
          onFavoriteTap: () => controller.toggleFavorite(device.id),
        );
      },
    );
  }
}

class _TrashSection extends StatelessWidget {
  const _TrashSection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final devices = controller.trashDevices;
    if (devices.isEmpty) {
      return const Center(child: Text('Корзина пуста'));
    }

    return ListView(
      children: devices
          .map(
            (device) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(device.name),
                subtitle: Text('${device.ipAddress} · ${device.room}'),
                trailing: OutlinedButton(
                  onPressed: () => controller.restoreDevice(device.id),
                  child: const Text('Восстановить'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.visibleNotifications;
    if (items.isEmpty) {
      return const Center(child: Text('Уведомлений нет'));
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
                    if (!item.isRead)
                      const Icon(Icons.circle, size: 12, color: Colors.redAccent),
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
                    device.status == DeviceStatus.pending) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => controller.decideDeviceRequest(
                          notificationId: item.id,
                          deviceId: device!.id,
                          approve: true,
                        ),
                        child: const Text('Одобрить'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.decideDeviceRequest(
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

class _RouterSettingsSection extends StatefulWidget {
  const _RouterSettingsSection({required this.controller});

  final AppController controller;

  @override
  State<_RouterSettingsSection> createState() => _RouterSettingsSectionState();
}

class _RouterSettingsSectionState extends State<_RouterSettingsSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ssidController;
  late final TextEditingController _passwordController;
  late String _band;
  late String _channel;
  late bool _dhcpEnabled;
  late bool _guestEnabled;
  late bool _hiddenSsid;
  late double _maxDevices;

  @override
  void initState() {
    super.initState();
    final settings = widget.controller.data.routerSettings;
    _ssidController = TextEditingController(text: settings.ssid);
    _passwordController = TextEditingController(text: settings.password);
    _band = settings.band;
    _channel = settings.channel;
    _dhcpEnabled = settings.dhcpEnabled;
    _guestEnabled = settings.guestNetworkEnabled;
    _hiddenSsid = settings.hiddenSsid;
    _maxDevices = settings.maxDevices.toDouble();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.controller.isAdmin;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _ssidController,
            readOnly: !isAdmin,
            decoration: const InputDecoration(
              labelText: 'SSID сети',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            readOnly: !isAdmin,
            decoration: const InputDecoration(
              labelText: 'Пароль Wi-Fi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Диапазон Wi-Fi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '2.4 GHz', label: Text('2.4 GHz')),
              ButtonSegment(value: '5 GHz', label: Text('5 GHz')),
            ],
            selected: {_band},
            onSelectionChanged:
                isAdmin ? (values) => setState(() => _band = values.first) : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _channel,
            decoration: const InputDecoration(
              labelText: 'Канал Wi-Fi',
              border: OutlineInputBorder(),
            ),
            items: const ['1', '6', '11', '36', '40', '44']
                .map((channel) => DropdownMenuItem(value: channel, child: Text(channel)))
                .toList(),
            onChanged: isAdmin ? (value) => setState(() => _channel = value!) : null,
          ),
          SwitchListTile(
            value: _dhcpEnabled,
            onChanged: isAdmin ? (value) => setState(() => _dhcpEnabled = value) : null,
            title: const Text('DHCP включён'),
          ),
          SwitchListTile(
            value: _guestEnabled,
            onChanged: isAdmin ? (value) => setState(() => _guestEnabled = value) : null,
            title: const Text('Гостевая сеть'),
          ),
          SwitchListTile(
            value: _hiddenSsid,
            onChanged: isAdmin ? (value) => setState(() => _hiddenSsid = value) : null,
            title: const Text('Скрывать SSID'),
          ),
          const SizedBox(height: 12),
          Text('Максимум устройств: ${_maxDevices.round()}'),
          Slider(
            value: _maxDevices,
            min: 5,
            max: 100,
            divisions: 19,
            onChanged: isAdmin ? (value) => setState(() => _maxDevices = value) : null,
          ),
          if (isAdmin)
            FilledButton(
              onPressed: () {
                final settings = RouterSettings(
                  ssid: _ssidController.text.trim(),
                  password: _passwordController.text.trim(),
                  band: _band,
                  channel: _channel,
                  dhcpEnabled: _dhcpEnabled,
                  guestNetworkEnabled: _guestEnabled,
                  hiddenSsid: _hiddenSsid,
                  maxDevices: _maxDevices.round(),
                );
                widget.controller.saveRouterSettings(settings);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки сохранены')),
                );
              },
              child: const Text('Сохранить настройки'),
            ),
        ],
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final devices = controller.activeDevices;
    final weakSignal = devices.where((device) => device.signalStrength < 40).toList();
    final on24GHz = devices
        .where((device) => device.connectionType == ConnectionType.wifi)
        .length;
    final issues = devices.where((device) => device.status == DeviceStatus.issue).toList();

    final recommendations = <String>[
      if (weakSignal.isNotEmpty)
        'У ${weakSignal.first.name} слабый сигнал. Переместите роутер или добавьте mesh-точку.',
      if (on24GHz > 10)
        'В Wi-Fi сегменте много устройств. Переведите часть техники на 5 GHz или Ethernet.',
      if (issues.isNotEmpty)
        'Есть устройства со статусом "Проблема". Проверьте DHCP, IP и кабельные подключения.',
      if (!controller.data.routerSettings.dhcpEnabled)
        'DHCP отключён. Убедитесь, что у всех устройств настроены статические адреса.',
    ];

    if (recommendations.isEmpty) {
      recommendations.add('Сеть выглядит стабильно. Критичных рекомендаций нет.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: recommendations
          .map(
            (text) => Card(
              child: ListTile(
                leading: const Icon(Icons.tips_and_updates_outlined),
                title: Text(text),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NetworkMapSection extends StatelessWidget {
  const _NetworkMapSection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final wired = controller.activeDevices
        .where((device) => device.connectionType == ConnectionType.ethernet)
        .take(4)
        .toList();
    final wifi = controller.activeDevices
        .where((device) => device.connectionType == ConnectionType.wifi)
        .take(4)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NetworkNode(title: 'Интернет', color: Colors.blueGrey.shade100),
        const _ConnectorLine(),
        _NetworkNode(title: 'Основной роутер', color: Colors.teal.shade100),
        const _ConnectorLine(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BranchColumn(
                title: 'Wi-Fi',
                nodes: wifi.map((device) => device.name).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BranchColumn(
                title: 'Ethernet',
                nodes: wired.map((device) => device.name).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    final ownDevices = controller.activeDevices
        .where((device) => device.createdBy == user.login)
        .length;

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
            title: const Text('Мои устройства'),
            subtitle: Text('$ownDevices устройств создано этим пользователем'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Избранное'),
            subtitle: Text('${controller.favoriteDevices.length} устройств в избранном'),
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Home Network Assistant'),
            subtitle: Text(
              'Приложение для учёта устройств домашней сети, работы с ролями, уведомлениями и настройками роутера.',
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkNode extends StatelessWidget {
  const _NetworkNode({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine();

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

class _BranchColumn extends StatelessWidget {
  const _BranchColumn({required this.title, required this.nodes});

  final String title;
  final List<String> nodes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...nodes.map((node) => _NetworkNode(title: node, color: Colors.white)),
      ],
    );
  }
}

String _titleForSection(AppSection section) {
  switch (section) {
    case AppSection.devices:
      return 'Устройства сети';
    case AppSection.favorites:
      return 'Избранное';
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
