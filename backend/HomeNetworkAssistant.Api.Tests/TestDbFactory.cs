using HomeNetworkAssistant.Api.Data;
using HomeNetworkAssistant.Api.Entities;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Tests;

internal sealed class TestDbFactory : IDisposable
{
    private readonly SqliteConnection _connection;

    public TestDbFactory()
    {
        _connection = new SqliteConnection("Data Source=:memory:");
        _connection.Open();
    }

    public AppDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite(_connection)
            .Options;

        var context = new AppDbContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    public async Task SeedAsync()
    {
        await using var context = CreateContext();
        if (await context.Users.AnyAsync())
        {
            return;
        }

        context.Users.AddRange(
            new UserEntity
            {
                Id = 1,
                Login = "admin",
                Password = "admin123",
                Role = "admin",
                SavedSettingsJson = "{}",
            },
            new UserEntity
            {
                Id = 2,
                Login = "user",
                Password = "user123",
                Role = "user",
                SavedSettingsJson = "{}",
            });

        context.Projects.Add(new NetworkProjectEntity
        {
            Id = 1,
            Name = "Домашняя сеть",
            Description = "Сеть квартиры",
            PropertyType = "Квартира",
            RoomCount = 4,
            Provider = "NetHome",
            PrimaryRouterName = "Router",
        });

        context.RouterSettings.Add(new RouterSettingsEntity
        {
            Id = 1,
            ProjectId = 1,
            Ssid = "HomeMesh",
            Password = "safehome2026",
            Band = "5 GHz",
            Channel = "36",
            DhcpEnabled = true,
            DhcpRange = "192.168.1.100 - 192.168.1.200",
            GuestNetworkEnabled = true,
            HiddenSsid = false,
            MaxDevices = 40,
        });

        context.Devices.AddRange(
            new NetworkDeviceEntity
            {
                Id = 1,
                ProjectId = 1,
                Name = "Router",
                Type = "router",
                IpAddress = "192.168.1.1",
                MacAddress = "AA:BB:CC:DD:EE:01",
                ConnectionType = "ethernet",
                Room = "Прихожая",
                Status = "active",
                SignalStrength = 100,
                SpeedMbps = 1000,
                Description = "Main router",
                CreatedBy = "admin",
                CreatedAt = DateTime.UtcNow,
            },
            new NetworkDeviceEntity
            {
                Id = 2,
                ProjectId = 1,
                Name = "Laptop",
                Type = "laptop",
                IpAddress = "192.168.1.10",
                MacAddress = "AA:BB:CC:DD:EE:02",
                ConnectionType = "wifi",
                Room = "Кабинет",
                Status = "pending",
                SignalStrength = 80,
                SpeedMbps = 300,
                Description = "Work laptop",
                CreatedBy = "user",
                CreatedAt = DateTime.UtcNow,
            });

        context.DeviceRequests.Add(new DeviceRequestEntity
        {
            Id = 1,
            ProjectId = 1,
            DeviceId = 2,
            RequesterLogin = "user",
            Status = "pending",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        });

        await context.SaveChangesAsync();
    }

    public void Dispose()
    {
        _connection.Dispose();
    }
}
