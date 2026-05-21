using HomeNetworkAssistant.Api.Contracts;
using HomeNetworkAssistant.Api.Services;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Tests;

public sealed class ApiServiceTests : IDisposable
{
    private readonly TestDbFactory _factory = new();

    public ApiServiceTests()
    {
        _factory.SeedAsync().GetAwaiter().GetResult();
    }

    [Fact]
    public async Task Login_Returns_User_For_Valid_Credentials()
    {
        await using var context = _factory.CreateContext();
        var service = new AuthService(context);

        var response = await service.LoginAsync(new LoginRequest("admin", "admin123"));

        Assert.NotNull(response);
        Assert.Equal("admin", response!.User.Login);
        Assert.Equal("admin", response.User.Role);
    }

    [Fact]
    public async Task CreateDevice_AsUser_Creates_Pending_Request_And_Notification()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var notificationService = new NotificationService(context, userService);
        var deviceService = new DeviceService(context, userService, notificationService);

        var device = await deviceService.CreateAsync(
            1,
            new CreateDeviceRequest(
                "Pixel 9",
                "phone",
                "192.168.1.50",
                "AA:BB:CC:DD:EE:50",
                "wifi",
                "Спальня",
                "active",
                70,
                300,
                "New phone",
                false,
                false),
            "user");

        Assert.Equal("pending", device.Status);
        Assert.True(await context.DeviceRequests.AnyAsync(request => request.DeviceId == device.Id));
        Assert.True(await context.Notifications.AnyAsync(item => item.RelatedDeviceId == device.Id));
    }

    [Fact]
    public async Task Approve_Request_Updates_Request_And_Device()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var notificationService = new NotificationService(context, userService);
        var deviceService = new DeviceService(context, userService, notificationService);
        var requestService = new RequestService(context, userService, deviceService, notificationService);

        var response = await requestService.ApproveAsync(1, "admin");

        Assert.Equal("approved", response.Status);
        Assert.Equal("active", (await deviceService.GetRequiredDeviceEntityAsync(2)).Status);
    }

    [Fact]
    public async Task Devices_Filter_And_Pagination_Work()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var notificationService = new NotificationService(context, userService);
        var deviceService = new DeviceService(context, userService, notificationService);

        var response = await deviceService.GetDevicesAsync(1, "laptop", null, false, 1, 10);

        Assert.Single(response.Items);
        Assert.Equal("Laptop", response.Items[0].Name);
        Assert.Equal(1, response.TotalCount);
    }

    [Fact]
    public async Task NonAdmin_Only_Sees_Own_Requests()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var notificationService = new NotificationService(context, userService);
        var deviceService = new DeviceService(context, userService, notificationService);
        var requestService = new RequestService(context, userService, deviceService, notificationService);

        var response = await requestService.GetRequestsAsync(1, "user", "admin");

        Assert.Single(response);
        Assert.Equal("user", response[0].RequesterLogin);
    }

    [Fact]
    public async Task Resend_Request_Creates_New_Pending_Request_And_Admin_Notification()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var notificationService = new NotificationService(context, userService);
        var deviceService = new DeviceService(context, userService, notificationService);

        var response = await deviceService.ResendRequestAsync(2, "user");

        Assert.Equal("pending", response.Status);
        Assert.Equal(2, await context.DeviceRequests.CountAsync(item => item.DeviceId == 2));
        Assert.True(await context.Notifications.AnyAsync(item =>
            item.RelatedDeviceId == 2 &&
            item.TargetRole == "admin" &&
            item.ActionType == "deviceRequest"));
    }

    [Fact]
    public async Task RouterSettings_Update_Persists_DhcpRange()
    {
        await using var context = _factory.CreateContext();
        var userService = new UserService(context);
        var service = new RouterSettingsService(context, userService);

        var response = await service.UpdateAsync(
            1,
            new UpdateRouterSettingsRequest(
                "Mesh",
                "newpass",
                "2.4 GHz",
                "11",
                false,
                "192.168.1.2 - 192.168.1.50",
                true,
                false,
                20),
            "admin");

        Assert.Equal("192.168.1.2 - 192.168.1.50", response.DhcpRange);
        Assert.False(response.DhcpEnabled);
    }

    public void Dispose()
    {
        _factory.Dispose();
    }
}
