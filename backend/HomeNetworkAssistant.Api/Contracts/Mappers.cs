using System.Text.Json;
using HomeNetworkAssistant.Api.Entities;

namespace HomeNetworkAssistant.Api.Contracts;

public static class Mappers
{
    public static UserDto ToDto(this UserEntity user)
    {
        var savedSettings = JsonSerializer.Deserialize<Dictionary<string, object>>(user.SavedSettingsJson);
        return new UserDto(user.Id, user.Login, user.Role, user.LastLogin, savedSettings);
    }

    public static ProjectDto ToDto(this NetworkProjectEntity project) =>
        new(
            project.Id,
            project.Name,
            project.Description,
            project.PropertyType,
            project.RoomCount,
            project.Provider,
            project.PrimaryRouterName);

    public static DeviceDto ToDto(this NetworkDeviceEntity device) =>
        new(
            device.Id,
            device.ProjectId,
            device.Name,
            device.Type,
            device.IpAddress,
            device.MacAddress,
            device.ConnectionType,
            device.Room,
            device.Status,
            device.SignalStrength,
            device.SpeedMbps,
            device.Description,
            device.IsFavorite,
            device.IsDeleted,
            device.CreatedBy,
            device.CreatedAt,
            device.IsGuest,
            device.RequiresStaticIp);

    public static DeviceRequestDto ToDto(this DeviceRequestEntity request) =>
        new(
            request.Id,
            request.ProjectId,
            request.DeviceId,
            request.RequesterLogin,
            request.Status,
            request.CreatedAt,
            request.UpdatedAt);

    public static NotificationDto ToDto(this NotificationItemEntity notification) =>
        new(
            notification.Id,
            notification.ProjectId,
            notification.Title,
            notification.Message,
            notification.TargetRole,
            notification.IsRead,
            notification.CreatedAt,
            notification.ActionType,
            notification.RelatedDeviceId);

    public static RouterSettingsDto ToDto(this RouterSettingsEntity settings) =>
        new(
            settings.Id,
            settings.ProjectId,
            settings.Ssid,
            settings.Password,
            settings.Band,
            settings.Channel,
            settings.DhcpEnabled,
            settings.DhcpRange,
            settings.GuestNetworkEnabled,
            settings.HiddenSsid,
            settings.MaxDevices);
}
