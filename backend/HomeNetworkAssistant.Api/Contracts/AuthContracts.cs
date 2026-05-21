namespace HomeNetworkAssistant.Api.Contracts;

public sealed record LoginRequest(string Login, string Password);

public sealed record UserDto(
    int Id,
    string Login,
    string Role,
    DateTime? LastLogin,
    Dictionary<string, object>? SavedSettings);

public sealed record LoginResponse(UserDto User);
