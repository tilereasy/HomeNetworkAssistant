using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Services;

public class UserService(AppDbContext dbContext)
{
    public async Task<IReadOnlyList<UserDto>> GetUsersAsync()
    {
        return await dbContext.Users
            .OrderBy(user => user.Login)
            .Select(user => user.ToDto())
            .ToListAsync();
    }

    public async Task<Entities.UserEntity> GetRequiredUserAsync(string login)
    {
        return await dbContext.Users.FirstOrDefaultAsync(user => user.Login == login)
            ?? throw new InvalidOperationException($"User '{login}' not found.");
    }

    public async Task<bool> IsAdminAsync(string login)
    {
        var user = await GetRequiredUserAsync(login);
        return string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase);
    }

    public async Task EnsureAdminAsync(string login)
    {
        if (!await IsAdminAsync(login))
        {
            throw new InvalidOperationException("Admin access is required.");
        }
    }
}
