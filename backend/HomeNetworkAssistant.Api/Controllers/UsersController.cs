using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeNetworkAssistant.Api.Controllers;

[Route("api/users")]
public class UsersController(UserService userService) : BaseApiController
{
    [HttpGet]
    [ProducesResponseType<IReadOnlyList<UserDto>>(StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<UserDto>>> GetUsers()
    {
        return Ok(await userService.GetUsersAsync());
    }
}
