import 'dart:convert';

import 'package:http/http.dart' as http;

class FakeApiBackend {
  FakeApiBackend(Map<String, dynamic> seed)
      : _users = List<Map<String, dynamic>>.from(
          (seed['users'] as List<dynamic>).map((item) => Map<String, dynamic>.from(item as Map)),
        ),
        _projects = List<Map<String, dynamic>>.from(
          (seed['projects'] as List<dynamic>).map((item) => Map<String, dynamic>.from(item as Map)),
        ),
        _devices = List<Map<String, dynamic>>.from(
          (seed['devices'] as List<dynamic>).map((item) => Map<String, dynamic>.from(item as Map)),
        ),
        _requests = List<Map<String, dynamic>>.from(
          ((seed['deviceRequests'] as List<dynamic>? ?? const []))
              .map((item) => Map<String, dynamic>.from(item as Map)),
        ),
        _notifications = List<Map<String, dynamic>>.from(
          ((seed['notifications'] as List<dynamic>? ?? const []))
              .map((item) => Map<String, dynamic>.from(item as Map)),
        ),
        _routerSettings = List<Map<String, dynamic>>.from(
          (seed['routerSettings'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map)),
        );

  final List<Map<String, dynamic>> _users;
  final List<Map<String, dynamic>> _projects;
  final List<Map<String, dynamic>> _devices;
  final List<Map<String, dynamic>> _requests;
  final List<Map<String, dynamic>> _notifications;
  final List<Map<String, dynamic>> _routerSettings;

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    final method = request.method.toUpperCase();
    final segments = request.url.pathSegments;
    final userLogin = request.headers['X-User-Login'];

    if (method == 'POST' && path == '/api/auth/login') {
      final body = json.decode(request.body) as Map<String, dynamic>;
      final user = _users.cast<Map<String, dynamic>?>().firstWhere(
            (item) =>
                item?['login'] == body['login'] && item?['password'] == body['password'],
            orElse: () => null,
          );
      if (user == null) {
        return http.Response('', 401);
      }
      user['lastLogin'] = DateTime.now().toUtc().toIso8601String();
      return _json(200, {'user': _publicUser(user)});
    }

    if (method == 'GET' && path == '/api/users') {
      return _json(200, _users.map(_publicUser).toList());
    }

    if (method == 'GET' && path == '/api/projects') {
      return _json(200, _projects);
    }

    if (method == 'POST' && path == '/api/projects') {
      _ensureAdmin(userLogin);
      final body = json.decode(request.body) as Map<String, dynamic>;
      final id = _nextId(_projects);
      final project = {
        'id': id,
        'name': body['name'],
        'description': body['description'],
        'propertyType': body['propertyType'],
        'roomCount': body['roomCount'],
        'provider': body['provider'],
        'primaryRouterName': body['primaryRouterName'],
      };
      _projects.add(project);
      _routerSettings.add({
        'projectId': id,
        'ssid': 'NewProjectWiFi',
        'password': 'change-me',
        'band': '5 GHz',
        'channel': '36',
        'dhcpEnabled': true,
        'dhcpRange': '192.168.1.100 - 192.168.1.200',
        'guestNetworkEnabled': true,
        'hiddenSsid': false,
        'maxDevices': 40,
      });
      return _json(201, project);
    }

    if (segments.length >= 3 && segments[0] == 'api' && segments[1] == 'projects') {
      final projectId = int.parse(segments[2]);

      if (segments.length == 4 && segments[3] == 'devices' && method == 'GET') {
        final includeDeleted = request.url.queryParameters['includeDeleted'] == 'true';
        final type = request.url.queryParameters['type'];
        final room = request.url.queryParameters['room'];
        final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
        final pageSize = int.tryParse(request.url.queryParameters['pageSize'] ?? '') ?? 500;
        final filtered = _devices.where((item) {
          if (item['projectId'] != projectId) {
            return false;
          }
          if (!includeDeleted && item['isDeleted'] == true) {
            return false;
          }
          if (type != null && item['type'] != type) {
            return false;
          }
          if (room != null && item['room'] != room) {
            return false;
          }
          return true;
        }).toList()
          ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        return _json(200, {
          'items': filtered.sublist(start.clamp(0, filtered.length), end.clamp(0, filtered.length)),
          'totalCount': filtered.length,
          'page': page,
          'pageSize': pageSize,
        });
      }

      if (segments.length == 4 && segments[3] == 'devices' && method == 'POST') {
        _ensureUser(userLogin);
        final user = _requireUser(userLogin);
        final body = json.decode(request.body) as Map<String, dynamic>;
        final isAdmin = user['role'] == 'admin';
        final deviceId = _nextId(_devices);
        final device = {
          'id': deviceId,
          'projectId': projectId,
          'name': body['name'],
          'type': body['type'],
          'ipAddress': body['ipAddress'],
          'macAddress': body['macAddress'],
          'connectionType': body['connectionType'],
          'room': body['room'],
          'status': isAdmin ? body['status'] : 'pending',
          'signalStrength': body['signalStrength'],
          'speedMbps': body['speedMbps'],
          'description': body['description'],
          'isFavorite': false,
          'isDeleted': false,
          'createdBy': user['login'],
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'isGuest': body['isGuest'],
          'requiresStaticIp': body['requiresStaticIp'],
        };
        _devices.add(device);
        if (!isAdmin) {
          final requestId = _nextId(_requests);
          _requests.add({
            'id': requestId,
            'projectId': projectId,
            'deviceId': deviceId,
            'requesterLogin': user['login'],
            'status': 'pending',
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          });
          _notifications.insert(0, {
            'id': _nextId(_notifications),
            'projectId': projectId,
            'title': 'Новый запрос на устройство',
            'message': 'Пользователь ${user['login']} хочет добавить устройство "${device['name']}"',
            'targetRole': 'admin',
            'isRead': false,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'actionType': 'deviceRequest',
            'relatedDeviceId': deviceId,
          });
        }
        return _json(201, device);
      }

      if (segments.length == 4 && segments[3] == 'requests' && method == 'GET') {
        _ensureUser(userLogin);
        final currentUser = _requireUser(userLogin);
        final requesterLogin = currentUser['role'] == 'admin'
            ? request.url.queryParameters['requesterLogin']
            : currentUser['login'] as String;
        final items = _requests.where((item) {
          if (item['projectId'] != projectId) {
            return false;
          }
          if (requesterLogin != null && item['requesterLogin'] != requesterLogin) {
            return false;
          }
          return true;
        }).toList()
          ..sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
        return _json(200, items);
      }

      if (segments.length == 4 && segments[3] == 'notifications' && method == 'GET') {
        _ensureUser(userLogin);
        final currentUser = _requireUser(userLogin);
        final targetRole = currentUser['role'] == 'admin'
            ? (request.url.queryParameters['targetRole'] ?? 'admin')
            : currentUser['role'] as String;
        final items = _notifications.where((item) {
          return item['projectId'] == projectId && item['targetRole'] == targetRole;
        }).toList()
          ..sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
        return _json(200, items);
      }

      if (segments.length == 4 && segments[3] == 'router-settings' && method == 'GET') {
        final settings = _routerSettings.firstWhere((item) => item['projectId'] == projectId);
        return _json(200, settings);
      }

      if (segments.length == 4 && segments[3] == 'router-settings' && method == 'PUT') {
        _ensureAdmin(userLogin);
        final body = json.decode(request.body) as Map<String, dynamic>;
        final index = _routerSettings.indexWhere((item) => item['projectId'] == projectId);
        final updated = {
          'projectId': projectId,
          'ssid': body['ssid'],
          'password': body['password'],
          'band': body['band'],
          'channel': body['channel'],
          'dhcpEnabled': body['dhcpEnabled'],
          'dhcpRange': body['dhcpRange'],
          'guestNetworkEnabled': body['guestNetworkEnabled'],
          'hiddenSsid': body['hiddenSsid'],
          'maxDevices': body['maxDevices'],
        };
        _routerSettings[index] = updated;
        return _json(200, updated);
      }
    }

    if (segments.length >= 3 && segments[0] == 'api' && segments[1] == 'devices') {
      final deviceId = int.parse(segments[2]);
      final deviceIndex = _devices.indexWhere((item) => item['id'] == deviceId);
      final device = _devices[deviceIndex];

      if (segments.length == 3 && method == 'PUT') {
        _ensureAdmin(userLogin);
        final body = json.decode(request.body) as Map<String, dynamic>;
        final updated = {
          ...device,
          'name': body['name'],
          'type': body['type'],
          'ipAddress': body['ipAddress'],
          'macAddress': body['macAddress'],
          'connectionType': body['connectionType'],
          'room': body['room'],
          'status': body['status'],
          'signalStrength': body['signalStrength'],
          'speedMbps': body['speedMbps'],
          'description': body['description'],
          'isGuest': body['isGuest'],
          'requiresStaticIp': body['requiresStaticIp'],
        };
        _devices[deviceIndex] = updated;
        return _json(200, updated);
      }

      if (segments.length == 4 && segments[3] == 'favorite' && method == 'POST') {
        _ensureUser(userLogin);
        device['isFavorite'] = !(device['isFavorite'] as bool);
        return _json(200, device);
      }

      if (segments.length == 4 && segments[3] == 'trash' && method == 'POST') {
        _ensureAdmin(userLogin);
        device['isDeleted'] = true;
        device['isFavorite'] = false;
        return http.Response('', 204);
      }

      if (segments.length == 4 && segments[3] == 'restore' && method == 'POST') {
        _ensureAdmin(userLogin);
        device['isDeleted'] = false;
        return http.Response('', 204);
      }

      if (segments.length == 4 && segments[3] == 'resend-request' && method == 'POST') {
        _ensureUser(userLogin);
        final currentUser = _requireUser(userLogin);
        device['status'] = 'pending';
        _requests.insert(0, {
          'id': _nextId(_requests),
          'projectId': device['projectId'],
          'deviceId': deviceId,
          'requesterLogin': currentUser['login'],
          'status': 'pending',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
        _notifications.insert(0, {
          'id': _nextId(_notifications),
          'projectId': device['projectId'],
          'title': 'Повторный запрос на устройство',
          'message':
              'Пользователь ${currentUser['login']} повторно отправил запрос на "${device['name']}"',
          'targetRole': 'admin',
          'isRead': false,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'actionType': 'deviceRequest',
          'relatedDeviceId': deviceId,
        });
        return _json(200, device);
      }
    }

    if (segments.length == 4 && segments[0] == 'api' && segments[1] == 'requests') {
      final requestId = int.parse(segments[2]);
      final requestIndex = _requests.indexWhere((item) => item['id'] == requestId);
      final requestItem = _requests[requestIndex];
      final deviceIndex = _devices.indexWhere((item) => item['id'] == requestItem['deviceId']);
      final device = _devices[deviceIndex];

      if (segments[3] == 'approve' && method == 'POST') {
        _ensureAdmin(userLogin);
        requestItem['status'] = 'approved';
        requestItem['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        device['status'] = 'active';
        _notifications.insert(0, {
          'id': _nextId(_notifications),
          'projectId': requestItem['projectId'],
          'title': 'Запрос одобрен',
          'message': 'Устройство "${device['name']}" одобрено администратором.',
          'targetRole': 'user',
          'isRead': false,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'actionType': 'info',
          'relatedDeviceId': device['id'],
        });
        return _json(200, requestItem);
      }

      if (segments[3] == 'reject' && method == 'POST') {
        _ensureAdmin(userLogin);
        requestItem['status'] = 'rejected';
        requestItem['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        device['status'] = 'rejected';
        _notifications.insert(0, {
          'id': _nextId(_notifications),
          'projectId': requestItem['projectId'],
          'title': 'Запрос отклонён',
          'message': 'Устройство "${device['name']}" отклонено администратором.',
          'targetRole': 'user',
          'isRead': false,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'actionType': 'info',
          'relatedDeviceId': device['id'],
        });
        return _json(200, requestItem);
      }
    }

    if (segments.length == 4 &&
        segments[0] == 'api' &&
        segments[1] == 'notifications' &&
        segments[3] == 'read' &&
        method == 'POST') {
      _ensureUser(userLogin);
      final notificationId = int.parse(segments[2]);
      final index = _notifications.indexWhere((item) => item['id'] == notificationId);
      _notifications[index]['isRead'] = true;
      return http.Response('', 204);
    }

    return http.Response('Not Found: ${request.method} ${request.url}', 404);
  }

  Map<String, dynamic> _publicUser(Map<String, dynamic> user) {
    return {
      'id': user['id'],
      'login': user['login'],
      'role': user['role'],
      'lastLogin': user['lastLogin'],
      'savedSettings': user['savedSettings'] ?? const {},
      'favoriteDeviceIds': user['favoriteDeviceIds'] ?? const [],
    };
  }

  Map<String, dynamic> _requireUser(String? login) {
    final user = _users.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['login'] == login,
          orElse: () => null,
        );
    if (user == null) {
      throw StateError('Unknown user: $login');
    }
    return user;
  }

  void _ensureUser(String? login) {
    if (login == null || login.isEmpty) {
      throw StateError('X-User-Login is required for this test request.');
    }
  }

  void _ensureAdmin(String? login) {
    final user = _requireUser(login);
    if (user['role'] != 'admin') {
      throw StateError('Admin access expected in fake backend.');
    }
  }

  int _nextId(List<Map<String, dynamic>> items) {
    return items.fold<int>(0, (maxId, item) {
          final id = item['id'] as int? ?? 0;
          return id > maxId ? id : maxId;
        }) +
        1;
  }

  http.Response _json(int status, Object body) {
    return http.Response(
      json.encode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
