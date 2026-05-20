class RouterSettings {
  const RouterSettings({
    required this.ssid,
    required this.password,
    required this.band,
    required this.channel,
    required this.dhcpEnabled,
    required this.guestNetworkEnabled,
    required this.hiddenSsid,
    required this.maxDevices,
  });

  final String ssid;
  final String password;
  final String band;
  final String channel;
  final bool dhcpEnabled;
  final bool guestNetworkEnabled;
  final bool hiddenSsid;
  final int maxDevices;

  RouterSettings copyWith({
    String? ssid,
    String? password,
    String? band,
    String? channel,
    bool? dhcpEnabled,
    bool? guestNetworkEnabled,
    bool? hiddenSsid,
    int? maxDevices,
  }) {
    return RouterSettings(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      band: band ?? this.band,
      channel: channel ?? this.channel,
      dhcpEnabled: dhcpEnabled ?? this.dhcpEnabled,
      guestNetworkEnabled: guestNetworkEnabled ?? this.guestNetworkEnabled,
      hiddenSsid: hiddenSsid ?? this.hiddenSsid,
      maxDevices: maxDevices ?? this.maxDevices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'band': band,
      'channel': channel,
      'dhcpEnabled': dhcpEnabled,
      'guestNetworkEnabled': guestNetworkEnabled,
      'hiddenSsid': hiddenSsid,
      'maxDevices': maxDevices,
    };
  }

  factory RouterSettings.fromJson(Map<String, dynamic> json) {
    return RouterSettings(
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      band: json['band'] as String,
      channel: json['channel'] as String,
      dhcpEnabled: json['dhcpEnabled'] as bool,
      guestNetworkEnabled: json['guestNetworkEnabled'] as bool,
      hiddenSsid: json['hiddenSsid'] as bool,
      maxDevices: json['maxDevices'] as int,
    );
  }
}
