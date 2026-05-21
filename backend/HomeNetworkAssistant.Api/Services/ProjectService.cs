using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class ProjectService(AppDbContext dbContext, UserService userService)
{
    public async Task<IReadOnlyList<ProjectDto>> GetProjectsAsync()
    {
        return await dbContext.Projects
            .OrderBy(project => project.Id)
            .Select(project => project.ToDto())
            .ToListAsync();
    }

    public async Task<ProjectDto> GetProjectAsync(int projectId)
    {
        var project = await GetRequiredProjectEntityAsync(projectId);
        return project.ToDto();
    }

    public async Task<ProjectDto> CreateAsync(CreateProjectRequest request, string actingLogin)
    {
        await userService.EnsureAdminAsync(actingLogin);

        var entity = new NetworkProjectEntity
        {
            Name = request.Name,
            Description = request.Description,
            PropertyType = request.PropertyType,
            RoomCount = request.RoomCount,
            Provider = request.Provider,
            PrimaryRouterName = request.PrimaryRouterName,
        };

        dbContext.Projects.Add(entity);
        await dbContext.SaveChangesAsync();

        var routerSettings = new RouterSettingsEntity
        {
            ProjectId = entity.Id,
            Ssid = "NewProjectWiFi",
            Password = "change-me",
            Band = "5 GHz",
            Channel = "36",
            DhcpEnabled = true,
            DhcpRange = "192.168.1.100 - 192.168.1.200",
            GuestNetworkEnabled = true,
            HiddenSsid = false,
            MaxDevices = 40,
        };
        dbContext.RouterSettings.Add(routerSettings);
        await dbContext.SaveChangesAsync();

        return entity.ToDto();
    }

    public async Task<NetworkProjectEntity> GetRequiredProjectEntityAsync(int projectId)
    {
        return await dbContext.Projects.FirstOrDefaultAsync(project => project.Id == projectId)
            ?? throw new InvalidOperationException($"Project '{projectId}' not found.");
    }
}
