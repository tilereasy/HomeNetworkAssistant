using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class NotificationService(AppDbContext dbContext, UserService userService)
{
    public async Task<IReadOnlyList<NotificationDto>> GetNotificationsAsync(
        int projectId,
        string actingLogin,
        string? targetRole)
    {
        var user = await userService.GetRequiredUserAsync(actingLogin);
        var isAdmin = string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase);
        var effectiveTargetRole = isAdmin ? targetRole : user.Role;

        var query = dbContext.Notifications.Where(item => item.ProjectId == projectId);
        if (!string.IsNullOrWhiteSpace(effectiveTargetRole))
        {
            query = query.Where(item => item.TargetRole == effectiveTargetRole);
        }

        return await query
            .OrderByDescending(item => item.CreatedAt)
            .Select(item => item.ToDto())
            .ToListAsync();
    }

    public async Task MarkReadAsync(int notificationId, string actingLogin)
    {
        var user = await userService.GetRequiredUserAsync(actingLogin);
        var notification = await dbContext.Notifications.FirstOrDefaultAsync(item => item.Id == notificationId)
            ?? throw new InvalidOperationException($"Notification '{notificationId}' not found.");

        if (!string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(notification.TargetRole, user.Role, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("You cannot modify notifications for another role.");
        }

        notification.IsRead = true;
        await dbContext.SaveChangesAsync();
    }

    public async Task AddAsync(NotificationItemEntity entity)
    {
        dbContext.Notifications.Add(entity);
        await dbContext.SaveChangesAsync();
    }
}
