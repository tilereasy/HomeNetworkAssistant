class RouterSettings {
  const RouterSettings({
    required this.projectId,
    required this.ssid,
    required this.password,
    required this.band,
    required this.channel,
    required this.dhcpEnabled,
    required this.dhcpRange,
    required this.guestNetworkEnabled,
    required this.hiddenSsid,
    required this.maxDevices,
  });

  final int projectId;
  final String ssid;
  final String password;
  final String band;
  final String channel;
  final bool dhcpEnabled;
  final String dhcpRange;
  final bool guestNetworkEnabled;
  final bool hiddenSsid;
  final int maxDevices;

  RouterSettings copyWith({
    int? projectId,
    String? ssid,
    String? password,
    String? band,
    String? channel,
    bool? dhcpEnabled,
    String? dhcpRange,
    bool? guestNetworkEnabled,
    bool? hiddenSsid,
    int? maxDevices,
  }) {
    return RouterSettings(
      projectId: projectId ?? this.projectId,
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      band: band ?? this.band,
      channel: channel ?? this.channel,
      dhcpEnabled: dhcpEnabled ?? this.dhcpEnabled,
      dhcpRange: dhcpRange ?? this.dhcpRange,
      guestNetworkEnabled: guestNetworkEnabled ?? this.guestNetworkEnabled,
      hiddenSsid: hiddenSsid ?? this.hiddenSsid,
      maxDevices: maxDevices ?? this.maxDevices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'ssid': ssid,
      'password': password,
      'band': band,
      'channel': channel,
      'dhcpEnabled': dhcpEnabled,
      'dhcpRange': dhcpRange,
      'guestNetworkEnabled': guestNetworkEnabled,
      'hiddenSsid': hiddenSsid,
      'maxDevices': maxDevices,
    };
  }

  factory RouterSettings.fromJson(Map<String, dynamic> json) {
    return RouterSettings(
      projectId: json['projectId'] as int? ?? 1,
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      band: json['band'] as String,
      channel: json['channel'] as String,
      dhcpEnabled: json['dhcpEnabled'] as bool,
      dhcpRange: json['dhcpRange'] as String? ?? '192.168.1.100 - 192.168.1.200',
      guestNetworkEnabled: json['guestNetworkEnabled'] as bool,
      hiddenSsid: json['hiddenSsid'] as bool,
      maxDevices: json['maxDevices'] as int,
    );
  }
}
