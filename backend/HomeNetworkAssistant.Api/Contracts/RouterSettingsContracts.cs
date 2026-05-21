namespace HomeNetworkAssistant.Api.Contracts;

public sealed record RouterSettingsDto(
    int Id,
    int ProjectId,
    string Ssid,
    string Password,
    string Band,
    string Channel,
    bool DhcpEnabled,
    string DhcpRange,
    bool GuestNetworkEnabled,
    bool HiddenSsid,
    int MaxDevices);

public sealed record UpdateRouterSettingsRequest(
    string Ssid,
    string Password,
    string Band,
    string Channel,
    bool DhcpEnabled,
    string DhcpRange,
    bool GuestNetworkEnabled,
    bool HiddenSsid,
    int MaxDevices);
