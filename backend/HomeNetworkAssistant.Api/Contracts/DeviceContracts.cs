namespace HomeNetworkAssistant.Api.Contracts;

public sealed record DeviceDto(
    int Id,
    int ProjectId,
    string Name,
    string Type,
    string IpAddress,
    string MacAddress,
    string ConnectionType,
    string Room,
    string Status,
    int SignalStrength,
    int SpeedMbps,
    string Description,
    bool IsFavorite,
    bool IsDeleted,
    string CreatedBy,
    DateTime CreatedAt,
    bool IsGuest,
    bool RequiresStaticIp);

public sealed record CreateDeviceRequest(
    string Name,
    string Type,
    string IpAddress,
    string MacAddress,
    string ConnectionType,
    string Room,
    string Status,
    int SignalStrength,
    int SpeedMbps,
    string Description,
    bool IsGuest,
    bool RequiresStaticIp);

public sealed record UpdateDeviceRequest(
    string Name,
    string Type,
    string IpAddress,
    string MacAddress,
    string ConnectionType,
    string Room,
    string Status,
    int SignalStrength,
    int SpeedMbps,
    string Description,
    bool IsGuest,
    bool RequiresStaticIp);

public sealed record PagedResponse<T>(IReadOnlyList<T> Items, int TotalCount, int Page, int PageSize);
