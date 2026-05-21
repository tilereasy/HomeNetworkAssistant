namespace HomeNetworkAssistant.Api.Entities;

public class NetworkProjectEntity
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }
    public required string PropertyType { get; set; }
    public int RoomCount { get; set; }
    public required string Provider { get; set; }
    public required string PrimaryRouterName { get; set; }

    public ICollection<NetworkDeviceEntity> Devices { get; set; } = new List<NetworkDeviceEntity>();
    public ICollection<DeviceRequestEntity> DeviceRequests { get; set; } = new List<DeviceRequestEntity>();
    public ICollection<NotificationItemEntity> Notifications { get; set; } = new List<NotificationItemEntity>();
    public ICollection<RouterSettingsEntity> RouterSettings { get; set; } = new List<RouterSettingsEntity>();
}
