using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class RouterSettingsService(AppDbContext dbContext, UserService userService)
{
    public async Task<RouterSettingsDto> GetAsync(int projectId)
    {
        var settings = await GetRequiredEntityAsync(projectId);
        return settings.ToDto();
    }

    public async Task<RouterSettingsDto> UpdateAsync(
        int projectId,
        UpdateRouterSettingsRequest request,
        string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);
        var settings = await GetRequiredEntityAsync(projectId);
        settings.Ssid = request.Ssid;
        settings.Password = request.Password;
        settings.Band = request.Band;
        settings.Channel = request.Channel;
        settings.DhcpEnabled = request.DhcpEnabled;
        settings.DhcpRange = request.DhcpRange;
        settings.GuestNetworkEnabled = request.GuestNetworkEnabled;
        settings.HiddenSsid = request.HiddenSsid;
        settings.MaxDevices = request.MaxDevices;
        await dbContext.SaveChangesAsync();
        return settings.ToDto();
    }

    private async Task<Entities.RouterSettingsEntity> GetRequiredEntityAsync(int projectId)
    {
        return await dbContext.RouterSettings.FirstOrDefaultAsync(item => item.ProjectId == projectId)
            ?? throw new InvalidOperationException($"Router settings for project '{projectId}' not found.");
    }
}
