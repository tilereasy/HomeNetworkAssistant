using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/auth")]
public class AuthController(AuthService authService) : BaseApiController
{
    [HttpPost("login")]
    [ProducesResponseType<LoginResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var response = await authService.LoginAsync(request);
        return response is null ? Unauthorized() : Ok(response);
    }
}
