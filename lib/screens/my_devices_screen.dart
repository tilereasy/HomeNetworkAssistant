import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import '../widgets/device_list_content.dart';
import 'device_details_screen.dart';

class MyDevicesScreen extends StatelessWidget {
  const MyDevicesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return DeviceListContent(
      controller: controller,
      devices: controller.myDevices,
      showFilters: false,
      showLoadMore: false,
      emptyTitle: 'У вас пока нет устройств',
      emptySubtitle: 'Добавьте своё устройство и отправьте его на одобрение.',
      onDeviceTap: (device) => _openDetails(context, device),
    );
  }

  void _openDetails(BuildContext context, NetworkDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailsScreen(controller: controller, deviceId: device.id),
      ),
    );
  }
}
