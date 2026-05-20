import 'package:flutter/material.dart';

import '../models/network_device.dart';

class DeviceFormView extends StatefulWidget {
  const DeviceFormView({
    super.key,
    this.initialDevice,
    required this.isAdmin,
    required this.createdBy,
  });

  final NetworkDevice? initialDevice;
  final bool isAdmin;
  final String createdBy;

  @override
  State<DeviceFormView> createState() => _DeviceFormViewState();
}

class _DeviceFormViewState extends State<DeviceFormView> {
  static const deviceTypes = [
    'router',
    'mesh',
    'pc',
    'laptop',
    'phone',
    'tv',
    'printer',
    'nas',
    'camera',
    'speaker',
    'lamp',
    'tablet',
    'console',
    'server',
    'switch',
    'vacuum',
  ];

  static const rooms = [
    'Прихожая',
    'Гостиная',
    'Кухня',
    'Спальня',
    'Кабинет',
    'Балкон',
    'Детская',
    'Гараж',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _macController;
  late final TextEditingController _speedController;
  late final TextEditingController _descriptionController;

  late String _type;
  late String _room;
  late ConnectionType _connectionType;
  late DeviceStatus _status;
  late bool _isGuest;
  late bool _requiresStaticIp;
  late double _signalStrength;

  @override
  void initState() {
    super.initState();
    final device = widget.initialDevice;
    _nameController = TextEditingController(text: device?.name ?? '');
    _ipController = TextEditingController(text: device?.ipAddress ?? '');
    _macController = TextEditingController(text: device?.macAddress ?? '');
    _speedController = TextEditingController(text: '${device?.speedMbps ?? 100}');
    _descriptionController = TextEditingController(text: device?.description ?? '');
    _type = device?.type ?? deviceTypes.first;
    _room = device?.room ?? rooms.first;
    _connectionType = device?.connectionType ?? ConnectionType.wifi;
    _status = device?.status ?? DeviceStatus.active;
    _isGuest = device?.isGuest ?? false;
    _requiresStaticIp = device?.requiresStaticIp ?? false;
    _signalStrength = (device?.signalStrength ?? 75).toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _macController.dispose();
    _speedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название устройства',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Введите название' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Тип устройства',
              border: OutlineInputBorder(),
            ),
            items: deviceTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _room,
            decoration: const InputDecoration(
              labelText: 'Комната',
              border: OutlineInputBorder(),
            ),
            items: rooms
                .map((room) => DropdownMenuItem(value: room, child: Text(room)))
                .toList(),
            onChanged: (value) => setState(() => _room = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'IP-адрес',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final raw = value?.trim() ?? '';
              final ipPattern = RegExp(
                r'^((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)$',
              );
              if (raw.isEmpty) {
                return 'Введите IP-адрес';
              }
              if (!ipPattern.hasMatch(raw)) {
                return 'Введите корректный IP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _macController,
            decoration: const InputDecoration(
              labelText: 'MAC-адрес',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final raw = value?.trim() ?? '';
              final macPattern = RegExp(r'^([0-9A-Fa-f]{2}:){1,5}[0-9A-Fa-f]{2}$');
              if (raw.isEmpty) {
                return 'Введите MAC-адрес';
              }
              if (!macPattern.hasMatch(raw)) {
                return 'Введите корректный MAC';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text('Способ подключения', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ConnectionType>(
            segments: const [
              ButtonSegment(
                value: ConnectionType.wifi,
                label: Text('Wi-Fi'),
                icon: Icon(Icons.wifi),
              ),
              ButtonSegment(
                value: ConnectionType.ethernet,
                label: Text('Ethernet'),
                icon: Icon(Icons.cable),
              ),
            ],
            selected: {_connectionType},
            onSelectionChanged: (values) => setState(() => _connectionType = values.first),
          ),
          const SizedBox(height: 16),
          Text('Статус', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<DeviceStatus>(
            segments: const [
              ButtonSegment(value: DeviceStatus.active, label: Text('Активно')),
              ButtonSegment(value: DeviceStatus.inactive, label: Text('Неактивно')),
              ButtonSegment(value: DeviceStatus.issue, label: Text('Проблема')),
            ],
            selected: {_status},
            onSelectionChanged: widget.isAdmin
                ? (values) => setState(() => _status = values.first)
                : null,
          ),
          CheckboxListTile(
            value: _isGuest,
            onChanged: (value) => setState(() => _isGuest = value ?? false),
            title: const Text('Гостевое устройство'),
          ),
          SwitchListTile(
            value: _requiresStaticIp,
            onChanged: (value) => setState(() => _requiresStaticIp = value),
            title: const Text('Требует статический IP'),
          ),
          Text('Уровень сигнала: ${_signalStrength.round()}%'),
          Slider(
            value: _signalStrength,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (value) => setState(() => _signalStrength = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _speedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Скорость (Мбит/с)',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || int.tryParse(value) == null
                ? 'Введите число'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Описание',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: Text(widget.initialDevice == null ? 'Сохранить устройство' : 'Сохранить изменения'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final source = widget.initialDevice;
    final device = NetworkDevice(
      id: source?.id ?? 0,
      projectId: source?.projectId ?? 0,
      name: _nameController.text.trim(),
      type: _type,
      ipAddress: _ipController.text.trim(),
      macAddress: _macController.text.trim(),
      connectionType: _connectionType,
      room: _room,
      status: widget.isAdmin ? _status : DeviceStatus.pending,
      signalStrength: _signalStrength.round(),
      speedMbps: int.parse(_speedController.text.trim()),
      description: _descriptionController.text.trim(),
      isFavorite: source?.isFavorite ?? false,
      isDeleted: source?.isDeleted ?? false,
      createdBy: source?.createdBy ?? widget.createdBy,
      createdAt: source?.createdAt ?? DateTime.now(),
      isGuest: _isGuest,
      requiresStaticIp: _requiresStaticIp,
    );

    Navigator.of(context).pop(device);
  }
}
