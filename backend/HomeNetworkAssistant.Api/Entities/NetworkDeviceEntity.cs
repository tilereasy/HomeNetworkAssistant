namespace HomeNetworkAssistant.Api.Entities;

public class NetworkDeviceEntity
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public required string Name { get; set; }
    public required string Type { get; set; }
    public required string IpAddress { get; set; }
    public required string MacAddress { get; set; }
    public required string ConnectionType { get; set; }
    public required string Room { get; set; }
    public required string Status { get; set; }
    public int SignalStrength { get; set; }
    public int SpeedMbps { get; set; }
    public required string Description { get; set; }
    public bool IsFavorite { get; set; }
    public bool IsDeleted { get; set; }
    public required string CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsGuest { get; set; }
    public bool RequiresStaticIp { get; set; }

    public NetworkProjectEntity? Project { get; set; }
}
