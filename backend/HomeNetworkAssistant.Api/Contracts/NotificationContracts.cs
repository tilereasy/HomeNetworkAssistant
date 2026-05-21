namespace HomeNetworkAssistant.Api.Contracts;

public sealed record NotificationDto(
    int Id,
    int ProjectId,
    string Title,
    string Message,
    string TargetRole,
    bool IsRead,
    DateTime CreatedAt,
    string ActionType,
    int? RelatedDeviceId);
