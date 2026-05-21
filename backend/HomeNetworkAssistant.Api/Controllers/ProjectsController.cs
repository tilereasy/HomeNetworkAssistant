using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/projects")]
public class ProjectsController(
    ProjectService projectService,
    DeviceService deviceService,
    RequestService requestService,
    NotificationService notificationService,
    RouterSettingsService routerSettingsService) : BaseApiController
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ProjectDto>>> GetProjects()
    {
        return Ok(await projectService.GetProjectsAsync());
    }

    [HttpPost]
    public async Task<ActionResult<ProjectDto>> CreateProject([FromBody] CreateProjectRequest request)
    {
        try
        {
            var project = await projectService.CreateAsync(request, RequireUserLogin());
            return CreatedAtAction(nameof(GetProject), new { projectId = project.Id }, project);
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpGet("{projectId:int}")]
    public async Task<ActionResult<ProjectDto>> GetProject(int projectId)
    {
        try
        {
            return Ok(await projectService.GetProjectAsync(projectId));
        }
        catch (InvalidOperationException exception)
        {
            return NotFound(new { error = exception.Message });
        }
    }

    [HttpGet("{projectId:int}/devices")]
    public async Task<ActionResult<PagedResponse<DeviceDto>>> GetDevices(
        int projectId,
        [FromQuery] string? type,
        [FromQuery] string? room,
        [FromQuery] bool includeDeleted = false,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        return Ok(await deviceService.GetDevicesAsync(projectId, type, room, includeDeleted, page, pageSize));
    }

    [HttpPost("{projectId:int}/devices")]
    public async Task<ActionResult<DeviceDto>> CreateDevice(int projectId, [FromBody] CreateDeviceRequest request)
    {
        try
        {
            var device = await deviceService.CreateAsync(projectId, request, RequireUserLogin());
            return CreatedAtAction(nameof(GetDevices), new { projectId }, device);
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpGet("{projectId:int}/requests")]
    public async Task<ActionResult<IReadOnlyList<DeviceRequestDto>>> GetRequests(
        int projectId,
        [FromQuery] string? requesterLogin)
    {
        try
        {
            return Ok(await requestService.GetRequestsAsync(projectId, RequireUserLogin(), requesterLogin));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpGet("{projectId:int}/notifications")]
    public async Task<ActionResult<IReadOnlyList<NotificationDto>>> GetNotifications(
        int projectId,
        [FromQuery] string? targetRole)
    {
        try
        {
            return Ok(await notificationService.GetNotificationsAsync(projectId, RequireUserLogin(), targetRole));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpGet("{projectId:int}/router-settings")]
    public async Task<ActionResult<RouterSettingsDto>> GetRouterSettings(int projectId)
    {
        try
        {
            return Ok(await routerSettingsService.GetAsync(projectId));
        }
        catch (InvalidOperationException exception)
        {
            return NotFound(new { error = exception.Message });
        }
    }

    [HttpPut("{projectId:int}/router-settings")]
    public async Task<ActionResult<RouterSettingsDto>> UpdateRouterSettings(
        int projectId,
        [FromBody] UpdateRouterSettingsRequest request)
    {
        try
        {
            return Ok(await routerSettingsService.UpdateAsync(projectId, request, RequireUserLogin()));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }
}
