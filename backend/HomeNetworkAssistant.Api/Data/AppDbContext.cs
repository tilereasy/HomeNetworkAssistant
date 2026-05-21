using HomeNetworkAssistant.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeNetworkAssistant.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<UserEntity> Users => Set<UserEntity>();
    public DbSet<NetworkProjectEntity> Projects => Set<NetworkProjectEntity>();
    public DbSet<NetworkDeviceEntity> Devices => Set<NetworkDeviceEntity>();
    public DbSet<DeviceRequestEntity> DeviceRequests => Set<DeviceRequestEntity>();
    public DbSet<NotificationItemEntity> Notifications => Set<NotificationItemEntity>();
    public DbSet<RouterSettingsEntity> RouterSettings => Set<RouterSettingsEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserEntity>()
            .HasIndex(user => user.Login)
            .IsUnique();

        modelBuilder.Entity<NetworkProjectEntity>()
            .Property(project => project.Name)
            .HasMaxLength(200);

        modelBuilder.Entity<NetworkDeviceEntity>()
            .HasOne(device => device.Project)
            .WithMany(project => project.Devices)
            .HasForeignKey(device => device.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<DeviceRequestEntity>()
            .HasOne(request => request.Project)
            .WithMany(project => project.DeviceRequests)
            .HasForeignKey(request => request.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<DeviceRequestEntity>()
            .HasOne(request => request.Device)
            .WithMany()
            .HasForeignKey(request => request.DeviceId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<NotificationItemEntity>()
            .HasOne(notification => notification.Project)
            .WithMany(project => project.Notifications)
            .HasForeignKey(notification => notification.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RouterSettingsEntity>()
            .HasOne(settings => settings.Project)
            .WithMany(project => project.RouterSettings)
            .HasForeignKey(settings => settings.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RouterSettingsEntity>()
            .HasIndex(settings => settings.ProjectId)
            .IsUnique();
    }
}
