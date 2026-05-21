namespace HomeNetworkAssistant.Api.Contracts;

public sealed record DeviceRequestDto(
    int Id,
    int ProjectId,
    int DeviceId,
    string RequesterLogin,
    string Status,
    DateTime CreatedAt,
    DateTime UpdatedAt);
