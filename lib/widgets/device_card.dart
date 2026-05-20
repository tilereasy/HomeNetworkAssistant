import 'package:flutter/material.dart';

import '../models/network_device.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final NetworkDevice device;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _statusColor(device.status).withValues(alpha: 0.15),
          child: Icon(_iconForType(device.type), color: _statusColor(device.status)),
        ),
        title: Text(device.name),
        subtitle: Text(
          '${device.ipAddress} · ${device.connectionType.name.toUpperCase()} · ${_statusLabel(device.status)}\n'
          'Комната: ${device.room} · Сигнал: ${device.signalStrength}%',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            device.isFavorite ? Icons.star : Icons.star_border,
            color: device.isFavorite ? Colors.amber.shade700 : null,
          ),
          onPressed: onFavoriteTap,
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'router':
      return Icons.router;
    case 'mesh':
      return Icons.wifi_tethering;
    case 'pc':
      return Icons.desktop_windows;
    case 'laptop':
      return Icons.laptop;
    case 'phone':
      return Icons.smartphone;
    case 'tv':
      return Icons.tv;
    case 'printer':
      return Icons.print;
    case 'nas':
      return Icons.storage;
    case 'camera':
      return Icons.videocam;
    case 'speaker':
      return Icons.speaker;
    case 'lamp':
      return Icons.lightbulb;
    case 'tablet':
      return Icons.tablet_mac;
    case 'console':
      return Icons.sports_esports;
    case 'server':
      return Icons.dns;
    case 'switch':
      return Icons.hub;
    case 'vacuum':
      return Icons.cleaning_services;
    default:
      return Icons.memory;
  }
}

String statusLabel(DeviceStatus status) => _statusLabel(status);

String _statusLabel(DeviceStatus status) {
  switch (status) {
    case DeviceStatus.active:
      return 'Активно';
    case DeviceStatus.inactive:
      return 'Неактивно';
    case DeviceStatus.issue:
      return 'Проблема';
    case DeviceStatus.pending:
      return 'Ожидает одобрения';
    case DeviceStatus.rejected:
      return 'Отклонено';
  }
}

Color _statusColor(DeviceStatus status) {
  switch (status) {
    case DeviceStatus.active:
      return Colors.green;
    case DeviceStatus.inactive:
      return Colors.grey;
    case DeviceStatus.issue:
      return Colors.orange;
    case DeviceStatus.pending:
      return Colors.blue;
    case DeviceStatus.rejected:
      return Colors.red;
  }
}
