import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import 'device_card.dart';
import 'empty_state.dart';

class DeviceListContent extends StatelessWidget {
  const DeviceListContent({
    super.key,
    required this.controller,
    required this.devices,
    required this.showFilters,
    required this.showLoadMore,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onDeviceTap,
  });

  final AppController controller;
  final List<NetworkDevice> devices;
  final bool showFilters;
  final bool showLoadMore;
  final String emptyTitle;
  final String emptySubtitle;
  final ValueChanged<NetworkDevice> onDeviceTap;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return EmptyState(title: emptyTitle, subtitle: emptySubtitle);
    }

    return Column(
      children: [
        if (showFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.deviceTypeFilter,
                    decoration: const InputDecoration(
                      labelText: 'Тип',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.deviceTypeOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item == 'all' ? 'Все типы' : item),
                            ))
                        .toList(),
                    onChanged: (value) => controller.setDeviceFilters(type: value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.deviceRoomFilter,
                    decoration: const InputDecoration(
                      labelText: 'Комната',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.roomOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item == 'all' ? 'Все комнаты' : item),
                            ))
                        .toList(),
                    onChanged: (value) => controller.setDeviceFilters(room: value),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length + (showLoadMore ? 1 : 0),
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
                onTap: () => onDeviceTap(device),
                onFavoriteTap: () => controller.toggleFavorite(device.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
