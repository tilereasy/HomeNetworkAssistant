namespace HomeNetworkAssistant.Api.Entities;

public class NotificationItemEntity
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public required string Title { get; set; }
    public required string Message { get; set; }
    public required string TargetRole { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public required string ActionType { get; set; }
    public int? RelatedDeviceId { get; set; }

    public NetworkProjectEntity? Project { get; set; }
}
