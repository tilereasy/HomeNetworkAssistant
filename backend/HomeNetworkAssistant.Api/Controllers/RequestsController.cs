using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/requests")]
public class RequestsController(RequestService requestService) : BaseApiController
{
    [HttpPost("{requestId:int}/approve")]
    public async Task<ActionResult<DeviceRequestDto>> Approve(int requestId)
    {
        try
        {
            return Ok(await requestService.ApproveAsync(requestId, RequireUserLogin()));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpPost("{requestId:int}/reject")]
    public async Task<ActionResult<DeviceRequestDto>> Reject(int requestId)
    {
        try
        {
            return Ok(await requestService.RejectAsync(requestId, RequireUserLogin()));
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }
}
