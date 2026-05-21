import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/device_request.dart';
import '../models/network_device.dart';
import '../models/network_project.dart';
import '../models/notification_item.dart';
import '../models/router_settings.dart';
import '../models/user.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class HttpApiService {
  HttpApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers({String? userLogin}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (userLogin != null && userLogin.isNotEmpty) {
      headers['X-User-Login'] = userLogin;
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }

  Never _throw(http.Response response) {
    final body = _decode(response);
    final message = body is Map<String, dynamic> && body['error'] is String
        ? body['error'] as String
        : 'HTTP ${response.statusCode}';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<User> login(String login, String password) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _headers(),
      body: json.encode({'login': login, 'password': password}),
    );
    if (response.statusCode == 401) {
      throw const ApiException('Неверный логин или пароль', statusCode: 401);
    }
    if (response.statusCode != 200) {
      _throw(response);
    }

    final payload = _decode(response) as Map<String, dynamic>;
    final userJson = payload['user'] as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  Future<List<User>> fetchUsers() async {
    final response = await _client.get(_uri('/api/users'), headers: _headers());
    if (response.statusCode != 200) {
      _throw(response);
    }
    final payload = _decode(response) as List<dynamic>;
    return payload.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<NetworkProject>> fetchProjects({String? userLogin}) async {
    final response = await _client.get(
      _uri('/api/projects'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    final payload = _decode(response) as List<dynamic>;
    return payload
        .map((item) => NetworkProject.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<NetworkProject> createProject(
    NetworkProject project, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/projects'),
      headers: _headers(userLogin: userLogin),
      body: json.encode({
        'name': project.name,
        'description': project.description,
        'propertyType': project.propertyType,
        'roomCount': project.roomCount,
        'provider': project.provider,
        'primaryRouterName': project.primaryRouterName,
      }),
    );
    if (response.statusCode != 201) {
      _throw(response);
    }
    return NetworkProject.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<NetworkDevice>> fetchDevices(
    int projectId, {
    required String userLogin,
    String? type,
    String? room,
    bool includeDeleted = true,
    int page = 1,
    int pageSize = 500,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/projects/$projectId/devices',
        {
          'includeDeleted': includeDeleted.toString(),
          'page': '$page',
          'pageSize': '$pageSize',
          if (type != null && type != 'all') 'type': type,
          if (room != null && room != 'all') 'room': room,
        },
      ),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    final payload = _decode(response) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>;
    return items
        .map((item) => NetworkDevice.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<NetworkDevice> createDevice(
    int projectId,
    NetworkDevice device, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/projects/$projectId/devices'),
      headers: _headers(userLogin: userLogin),
      body: json.encode({
        'name': device.name,
        'type': device.type,
        'ipAddress': device.ipAddress,
        'macAddress': device.macAddress,
        'connectionType': device.connectionType.name,
        'room': device.room,
        'status': device.status.name,
        'signalStrength': device.signalStrength,
        'speedMbps': device.speedMbps,
        'description': device.description,
        'isGuest': device.isGuest,
        'requiresStaticIp': device.requiresStaticIp,
      }),
    );
    if (response.statusCode != 201) {
      _throw(response);
    }
    return NetworkDevice.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<NetworkDevice> updateDevice(
    NetworkDevice device, {
    required String userLogin,
  }) async {
    final response = await _client.put(
      _uri('/api/devices/${device.id}'),
      headers: _headers(userLogin: userLogin),
      body: json.encode({
        'name': device.name,
        'type': device.type,
        'ipAddress': device.ipAddress,
        'macAddress': device.macAddress,
        'connectionType': device.connectionType.name,
        'room': device.room,
        'status': device.status.name,
        'signalStrength': device.signalStrength,
        'speedMbps': device.speedMbps,
        'description': device.description,
        'isGuest': device.isGuest,
        'requiresStaticIp': device.requiresStaticIp,
      }),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return NetworkDevice.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<NetworkDevice> toggleFavorite(
    int deviceId, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/devices/$deviceId/favorite'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return NetworkDevice.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> moveToTrash(int deviceId, {required String userLogin}) async {
    final response = await _client.post(
      _uri('/api/devices/$deviceId/trash'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 204) {
      _throw(response);
    }
  }

  Future<void> restoreDevice(int deviceId, {required String userLogin}) async {
    final response = await _client.post(
      _uri('/api/devices/$deviceId/restore'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 204) {
      _throw(response);
    }
  }

  Future<void> resendDeviceRequest(int deviceId, {required String userLogin}) async {
    final response = await _client.post(
      _uri('/api/devices/$deviceId/resend-request'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
  }

  Future<List<DeviceRequest>> fetchRequests(
    int projectId, {
    required String userLogin,
    String? requesterLogin,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/projects/$projectId/requests',
        {
          if (requesterLogin != null && requesterLogin.isNotEmpty)
            'requesterLogin': requesterLogin,
        },
      ),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    final payload = _decode(response) as List<dynamic>;
    return payload
        .map((item) => DeviceRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DeviceRequest> approveRequest(
    int requestId, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/requests/$requestId/approve'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return DeviceRequest.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<DeviceRequest> rejectRequest(
    int requestId, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/requests/$requestId/reject'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return DeviceRequest.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<NotificationItem>> fetchNotifications(
    int projectId, {
    required String userLogin,
    String? targetRole,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/projects/$projectId/notifications',
        {
          if (targetRole != null && targetRole.isNotEmpty) 'targetRole': targetRole,
        },
      ),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    final payload = _decode(response) as List<dynamic>;
    return payload
        .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(
    int notificationId, {
    required String userLogin,
  }) async {
    final response = await _client.post(
      _uri('/api/notifications/$notificationId/read'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 204) {
      _throw(response);
    }
  }

  Future<RouterSettings> fetchRouterSettings(
    int projectId, {
    required String userLogin,
  }) async {
    final response = await _client.get(
      _uri('/api/projects/$projectId/router-settings'),
      headers: _headers(userLogin: userLogin),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return RouterSettings.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<RouterSettings> updateRouterSettings(
    RouterSettings settings, {
    required String userLogin,
  }) async {
    final response = await _client.put(
      _uri('/api/projects/${settings.projectId}/router-settings'),
      headers: _headers(userLogin: userLogin),
      body: json.encode({
        'ssid': settings.ssid,
        'password': settings.password,
        'band': settings.band,
        'channel': settings.channel,
        'dhcpEnabled': settings.dhcpEnabled,
        'dhcpRange': settings.dhcpRange,
        'guestNetworkEnabled': settings.guestNetworkEnabled,
        'hiddenSsid': settings.hiddenSsid,
        'maxDevices': settings.maxDevices,
      }),
    );
    if (response.statusCode != 200) {
      _throw(response);
    }
    return RouterSettings.fromJson(_decode(response) as Map<String, dynamic>);
  }
}
