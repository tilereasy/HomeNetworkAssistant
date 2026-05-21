using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class RequestService(
    AppDbContext dbContext,
    UserService userService,
    DeviceService deviceService,
    NotificationService notificationService)
{
    public async Task<IReadOnlyList<DeviceRequestDto>> GetRequestsAsync(
        int projectId,
        string actingLogin,
        string? requesterLogin)
    {
        var user = await userService.GetRequiredUserAsync(actingLogin);
        var isAdmin = string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase);
        var effectiveRequesterLogin = isAdmin ? requesterLogin : user.Login;

        var query = dbContext.DeviceRequests.Where(item => item.ProjectId == projectId);
        if (!string.IsNullOrWhiteSpace(effectiveRequesterLogin))
        {
            query = query.Where(item => item.RequesterLogin == effectiveRequesterLogin);
        }

        return await query
            .OrderByDescending(item => item.CreatedAt)
            .Select(item => item.ToDto())
            .ToListAsync();
    }

    public async Task<DeviceRequestDto> ApproveAsync(int requestId, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var request = await GetRequiredRequestEntityAsync(requestId);
        var device = await deviceService.GetRequiredDeviceEntityAsync(request.DeviceId);

        request.Status = "approved";
        request.UpdatedAt = DateTime.UtcNow;
        device.Status = "active";
        await dbContext.SaveChangesAsync();

        await notificationService.AddAsync(new NotificationItemEntity
        {
            ProjectId = request.ProjectId,
            Title = "Запрос одобрен",
            Message = $"Устройство \"{device.Name}\" одобрено администратором.",
            TargetRole = "user",
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
            ActionType = "info",
            RelatedDeviceId = device.Id,
        });

        return request.ToDto();
    }

    public async Task<DeviceRequestDto> RejectAsync(int requestId, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var request = await GetRequiredRequestEntityAsync(requestId);
        var device = await deviceService.GetRequiredDeviceEntityAsync(request.DeviceId);

        request.Status = "rejected";
        request.UpdatedAt = DateTime.UtcNow;
        device.Status = "rejected";
        await dbContext.SaveChangesAsync();

        await notificationService.AddAsync(new NotificationItemEntity
        {
            ProjectId = request.ProjectId,
            Title = "Запрос отклонён",
            Message = $"Устройство \"{device.Name}\" отклонено администратором.",
            TargetRole = "user",
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
            ActionType = "info",
            RelatedDeviceId = device.Id,
        });

        return request.ToDto();
    }

    public async Task<DeviceRequestEntity> GetRequiredRequestEntityAsync(int requestId)
    {
        return await dbContext.DeviceRequests.FirstOrDefaultAsync(item => item.Id == requestId)
            ?? throw new InvalidOperationException($"Request '{requestId}' not found.");
    }
}
