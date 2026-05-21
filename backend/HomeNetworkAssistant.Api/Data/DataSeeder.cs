using System.Text.Json;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Data;

public class DataSeeder(AppDbContext dbContext, IWebHostEnvironment environment)
{
    public async Task SeedAsync()
    {
        if (await dbContext.Users.AnyAsync())
        {
            return;
        }

        var seedPath = Path.GetFullPath(
            Path.Combine(environment.ContentRootPath, "..", "..", "assets", "data", "seed_data.json"));

        if (!File.Exists(seedPath))
        {
            throw new FileNotFoundException($"Seed data not found: {seedPath}");
        }

        var json = await File.ReadAllTextAsync(seedPath);
        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
        };
        var seed = JsonSerializer.Deserialize<FrontendSeedData>(json, options)
            ?? throw new InvalidOperationException("Unable to deserialize seed data.");

        dbContext.Users.AddRange(seed.Users.Select(user => new UserEntity
        {
            Id = user.Id,
            Login = user.Login,
            Password = user.Password,
            Role = user.Role,
            LastLogin = user.LastLogin,
            SavedSettingsJson = JsonSerializer.Serialize(user.SavedSettings),
        }));

        dbContext.Projects.AddRange(seed.Projects.Select(project => new NetworkProjectEntity
        {
            Id = project.Id,
            Name = project.Name,
            Description = project.Description,
            PropertyType = project.PropertyType,
            RoomCount = project.RoomCount,
            Provider = project.Provider,
            PrimaryRouterName = project.PrimaryRouterName,
        }));

        dbContext.Devices.AddRange(seed.Devices.Select(device => new NetworkDeviceEntity
        {
            Id = device.Id,
            ProjectId = device.ProjectId,
            Name = device.Name,
            Type = device.Type,
            IpAddress = device.IpAddress,
            MacAddress = device.MacAddress,
            ConnectionType = device.ConnectionType,
            Room = device.Room,
            Status = device.Status,
            SignalStrength = device.SignalStrength,
            SpeedMbps = device.SpeedMbps,
            Description = device.Description,
            IsFavorite = device.IsFavorite,
            IsDeleted = device.IsDeleted,
            CreatedBy = device.CreatedBy,
            CreatedAt = device.CreatedAt,
            IsGuest = device.IsGuest,
            RequiresStaticIp = device.RequiresStaticIp,
        }));

        dbContext.DeviceRequests.AddRange(seed.DeviceRequests.Select(request => new DeviceRequestEntity
        {
            Id = request.Id,
            ProjectId = request.ProjectId,
            DeviceId = request.DeviceId,
            RequesterLogin = request.RequesterLogin,
            Status = request.Status,
            CreatedAt = request.CreatedAt,
            UpdatedAt = request.UpdatedAt,
        }));

        dbContext.Notifications.AddRange(seed.Notifications.Select(notification => new NotificationItemEntity
        {
            Id = notification.Id,
            ProjectId = notification.ProjectId,
            Title = notification.Title,
            Message = notification.Message,
            TargetRole = notification.TargetRole,
            IsRead = notification.IsRead,
            CreatedAt = notification.CreatedAt,
            ActionType = notification.ActionType,
            RelatedDeviceId = notification.RelatedDeviceId,
        }));

        dbContext.RouterSettings.AddRange(seed.RouterSettings.Select(settings => new RouterSettingsEntity
        {
            ProjectId = settings.ProjectId,
            Ssid = settings.Ssid,
            Password = settings.Password,
            Band = settings.Band,
            Channel = settings.Channel,
            DhcpEnabled = settings.DhcpEnabled,
            DhcpRange = settings.DhcpRange,
            GuestNetworkEnabled = settings.GuestNetworkEnabled,
            HiddenSsid = settings.HiddenSsid,
            MaxDevices = settings.MaxDevices,
        }));

        await dbContext.SaveChangesAsync();
    }

    private sealed class FrontendSeedData
    {
        public required List<UserSeed> Users { get; init; }
        public required List<ProjectSeed> Projects { get; init; }
        public required List<DeviceSeed> Devices { get; init; }
        public required List<DeviceRequestSeed> DeviceRequests { get; init; }
        public required List<NotificationSeed> Notifications { get; init; }
        public required List<RouterSettingsSeed> RouterSettings { get; init; }
    }

    private sealed class UserSeed
    {
        public int Id { get; init; }
        public required string Login { get; init; }
        public required string Password { get; init; }
        public required string Role { get; init; }
        public DateTime? LastLogin { get; init; }
        public Dictionary<string, object>? SavedSettings { get; init; }
    }

    private sealed class ProjectSeed
    {
        public int Id { get; init; }
        public required string Name { get; init; }
        public required string Description { get; init; }
        public required string PropertyType { get; init; }
        public int RoomCount { get; init; }
        public required string Provider { get; init; }
        public required string PrimaryRouterName { get; init; }
    }

    private sealed class DeviceSeed
    {
        public int Id { get; init; }
        public int ProjectId { get; init; }
        public required string Name { get; init; }
        public required string Type { get; init; }
        public required string IpAddress { get; init; }
        public required string MacAddress { get; init; }
        public required string ConnectionType { get; init; }
        public required string Room { get; init; }
        public required string Status { get; init; }
        public int SignalStrength { get; init; }
        public int SpeedMbps { get; init; }
        public required string Description { get; init; }
        public bool IsFavorite { get; init; }
        public bool IsDeleted { get; init; }
        public required string CreatedBy { get; init; }
        public DateTime CreatedAt { get; init; }
        public bool IsGuest { get; init; }
        public bool RequiresStaticIp { get; init; }
    }

    private sealed class DeviceRequestSeed
    {
        public int Id { get; init; }
        public int ProjectId { get; init; }
        public int DeviceId { get; init; }
        public required string RequesterLogin { get; init; }
        public required string Status { get; init; }
        public DateTime CreatedAt { get; init; }
        public DateTime UpdatedAt { get; init; }
    }

    private sealed class NotificationSeed
    {
        public int Id { get; init; }
        public int ProjectId { get; init; }
        public required string Title { get; init; }
        public required string Message { get; init; }
        public required string TargetRole { get; init; }
        public bool IsRead { get; init; }
        public DateTime CreatedAt { get; init; }
        public required string ActionType { get; init; }
        public int? RelatedDeviceId { get; init; }
    }

    private sealed class RouterSettingsSeed
    {
        public int ProjectId { get; init; }
        public required string Ssid { get; init; }
        public required string Password { get; init; }
        public required string Band { get; init; }
        public required string Channel { get; init; }
        public bool DhcpEnabled { get; init; }
        public required string DhcpRange { get; init; }
        public bool GuestNetworkEnabled { get; init; }
        public bool HiddenSsid { get; init; }
        public int MaxDevices { get; init; }
    }
}
