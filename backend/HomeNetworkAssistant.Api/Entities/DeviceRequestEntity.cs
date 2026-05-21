namespace HomeNetworkAssistant.Api.Entities;

public class DeviceRequestEntity
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public int DeviceId { get; set; }
    public required string RequesterLogin { get; set; }
    public required string Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public NetworkProjectEntity? Project { get; set; }
    public NetworkDeviceEntity? Device { get; set; }
}
