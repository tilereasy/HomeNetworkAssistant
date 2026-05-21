using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/devices")]
public class DevicesController(DeviceService deviceService) : BaseApiController
{
    [HttpPut("{deviceId:int}")]
    public async Task<ActionResult<DeviceDto>> UpdateDevice(int deviceId, [FromBody] UpdateDeviceRequest request)
    {
        try
        {
            return Ok(await deviceService.UpdateAsync(deviceId, request, RequireUserLogin()));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpPost("{deviceId:int}/favorite")]
    public async Task<ActionResult<DeviceDto>> ToggleFavorite(int deviceId)
    {
        try
        {
            return Ok(await deviceService.ToggleFavoriteAsync(deviceId, RequireUserLogin()));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpPost("{deviceId:int}/trash")]
    public async Task<IActionResult> MoveToTrash(int deviceId)
    {
        try
        {
            await deviceService.TrashAsync(deviceId, RequireUserLogin());
            return NoContent();
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpPost("{deviceId:int}/restore")]
    public async Task<IActionResult> Restore(int deviceId)
    {
        try
        {
            await deviceService.RestoreAsync(deviceId, RequireUserLogin());
            return NoContent();
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }
}
