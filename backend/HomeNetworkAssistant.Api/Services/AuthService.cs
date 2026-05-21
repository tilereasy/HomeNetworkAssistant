using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class AuthService(AppDbContext dbContext)
{
    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(
            item => item.Login == request.Login && item.Password == request.Password);

        if (user is null)
        {
            return null;
        }

        user.LastLogin = DateTime.UtcNow;
        await dbContext.SaveChangesAsync();
        return new LoginResponse(user.ToDto());
    }
}
