namespace HomeNetworkAssistant.Api.Entities;

public class UserEntity
{
    public int Id { get; set; }
    public required string Login { get; set; }
    public required string Password { get; set; }
    public required string Role { get; set; }
    public DateTime? LastLogin { get; set; }
    public string SavedSettingsJson { get; set; } = "{}";
}
