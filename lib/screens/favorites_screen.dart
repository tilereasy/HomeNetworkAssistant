import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import '../widgets/device_list_content.dart';
import 'device_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return DeviceListContent(
      controller: controller,
      devices: controller.favoriteDevices,
      showFilters: false,
      showLoadMore: false,
      emptyTitle: 'Нет избранных устройств',
      emptySubtitle: 'Добавьте звёздочку интересным устройствам из общего списка.',
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
