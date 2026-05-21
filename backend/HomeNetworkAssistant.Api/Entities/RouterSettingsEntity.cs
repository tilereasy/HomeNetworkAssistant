namespace HomeNetworkAssistant.Api.Entities;

public class RouterSettingsEntity
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public required string Ssid { get; set; }
    public required string Password { get; set; }
    public required string Band { get; set; }
    public required string Channel { get; set; }
    public bool DhcpEnabled { get; set; }
    public required string DhcpRange { get; set; }
    public bool GuestNetworkEnabled { get; set; }
    public bool HiddenSsid { get; set; }
    public int MaxDevices { get; set; }

    public NetworkProjectEntity? Project { get; set; }
}
