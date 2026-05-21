using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[ApiController]
public abstract class BaseApiController : ControllerBase
{
    protected string RequireUserLogin()
    {
        var login = Request.Headers["X-User-Login"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(login))
        {
            throw new InvalidOperationException("X-User-Login header is required.");
        }

        return login;
    }
}
