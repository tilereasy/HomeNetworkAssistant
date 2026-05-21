using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/notifications")]
public class NotificationsController(NotificationService notificationService) : BaseApiController
{
    [HttpPost("{notificationId:int}/read")]
    public async Task<IActionResult> MarkRead(int notificationId)
    {
        try
        {
            await notificationService.MarkReadAsync(notificationId, RequireUserLogin());
            return NoContent();
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }
}
