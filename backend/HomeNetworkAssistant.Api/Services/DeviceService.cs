using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class DeviceService(
    AppDbContext dbContext,
    UserService userService,
    NotificationService notificationService)
{
    public async Task<PagedResponse<DeviceDto>> GetDevicesAsync(
        int projectId,
        string? type,
        string? room,
        bool includeDeleted,
        int page,
        int pageSize)
    {
        page = page <= 0 ? 1 : page;
        pageSize = pageSize <= 0 ? 20 : pageSize;

        var query = dbContext.Devices.Where(device => device.ProjectId == projectId);
        if (!includeDeleted)
        {
            query = query.Where(device => !device.IsDeleted);
        }
        if (!string.IsNullOrWhiteSpace(type))
        {
            query = query.Where(device => device.Type == type);
        }
        if (!string.IsNullOrWhiteSpace(room))
        {
            query = query.Where(device => device.Room == room);
        }

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(device => device.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(device => device.ToDto())
            .ToListAsync();

        return new PagedResponse<DeviceDto>(items, totalCount, page, pageSize);
    }

    public async Task<DeviceDto> CreateAsync(int projectId, CreateDeviceRequest request, string actingLogin)
    {
        var user = await userService.GetRequiredUserAsync(actingLogin);
        var entity = new NetworkDeviceEntity
        {
            ProjectId = projectId,
            Name = request.Name,
            Type = request.Type,
            IpAddress = request.IpAddress,
            MacAddress = request.MacAddress,
            ConnectionType = request.ConnectionType,
            Room = request.Room,
            Status = string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase)
                ? request.Status
                : "pending",
            SignalStrength = request.SignalStrength,
            SpeedMbps = request.SpeedMbps,
            Description = request.Description,
            IsFavorite = false,
            IsDeleted = false,
            CreatedBy = user.Login,
            CreatedAt = DateTime.UtcNow,
            IsGuest = request.IsGuest,
            RequiresStaticIp = request.RequiresStaticIp,
        };

        dbContext.Devices.Add(entity);
        await dbContext.SaveChangesAsync();

        if (!string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
        {
            var deviceRequest = new DeviceRequestEntity
            {
                ProjectId = projectId,
                DeviceId = entity.Id,
                RequesterLogin = user.Login,
                Status = "pending",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };
            dbContext.DeviceRequests.Add(deviceRequest);
            await dbContext.SaveChangesAsync();

            await notificationService.AddAsync(new NotificationItemEntity
            {
                ProjectId = projectId,
                Title = "Новый запрос на устройство",
                Message = $"Пользователь {user.Login} хочет добавить устройство \"{entity.Name}\"",
                TargetRole = "admin",
                IsRead = false,
                CreatedAt = DateTime.UtcNow,
                ActionType = "deviceRequest",
                RelatedDeviceId = entity.Id,
            });
        }

        return entity.ToDto();
    }

    public async Task<DeviceDto> UpdateAsync(int deviceId, UpdateDeviceRequest request, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var device = await GetRequiredDeviceEntityAsync(deviceId);

        device.Name = request.Name;
        device.Type = request.Type;
        device.IpAddress = request.IpAddress;
        device.MacAddress = request.MacAddress;
        device.ConnectionType = request.ConnectionType;
        device.Room = request.Room;
        device.Status = request.Status;
        device.SignalStrength = request.SignalStrength;
        device.SpeedMbps = request.SpeedMbps;
        device.Description = request.Description;
        device.IsGuest = request.IsGuest;
        device.RequiresStaticIp = request.RequiresStaticIp;

        await dbContext.SaveChangesAsync();
        return device.ToDto();
    }

    public async Task<DeviceDto> ToggleFavoriteAsync(int deviceId, string actingLogin)
    {
        await userService.GetRequiredUserAsync(actingLogin);
        var device = await GetRequiredDeviceEntityAsync(deviceId);
        device.IsFavorite = !device.IsFavorite;
        await dbContext.SaveChangesAsync();
        return device.ToDto();
    }

    public async Task TrashAsync(int deviceId, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var device = await GetRequiredDeviceEntityAsync(deviceId);
        device.IsDeleted = true;
        device.IsFavorite = false;
        await dbContext.SaveChangesAsync();
    }

    public async Task RestoreAsync(int deviceId, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var device = await GetRequiredDeviceEntityAsync(deviceId);
        device.IsDeleted = false;
        await dbContext.SaveChangesAsync();
    }

    public async Task<DeviceDto> ResendRequestAsync(int deviceId, string actingLogin)
    {
        var user = await userService.GetRequiredUserAsync(actingLogin);
        if (string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only user requests can be resent.");
        }

        var device = await GetRequiredDeviceEntityAsync(deviceId);
        if (!string.Equals(device.CreatedBy, user.Login, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("You can resend only your own device requests.");
        }

        device.Status = "pending";

        var request = new DeviceRequestEntity
        {
            ProjectId = device.ProjectId,
            DeviceId = device.Id,
            RequesterLogin = user.Login,
            Status = "pending",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
        dbContext.DeviceRequests.Add(request);
        await dbContext.SaveChangesAsync();

        await notificationService.AddAsync(new NotificationItemEntity
        {
            ProjectId = device.ProjectId,
            Title = "Повторный запрос на устройство",
            Message = $"Пользователь {user.Login} повторно отправил запрос на \"{device.Name}\"",
            TargetRole = "admin",
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
            ActionType = "deviceRequest",
            RelatedDeviceId = device.Id,
        });

        return device.ToDto();
    }

    public async Task<NetworkDeviceEntity> GetRequiredDeviceEntityAsync(int deviceId)
    {
        return await dbContext.Devices.FirstOrDefaultAsync(device => device.Id == deviceId)
            ?? throw new InvalidOperationException($"Device '{deviceId}' not found.");
    }
}
