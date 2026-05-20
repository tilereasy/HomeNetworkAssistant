import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import '../widgets/device_list_content.dart';
import 'device_details_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final canShowMore = controller.visibleDevicesCount < controller.filteredDevices.length;
    return DeviceListContent(
      controller: controller,
      devices: controller.pagedDevices,
      showFilters: true,
      showLoadMore: canShowMore,
      emptyTitle: 'Нет устройств',
      emptySubtitle: 'Добавьте устройство или измените фильтры.',
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
