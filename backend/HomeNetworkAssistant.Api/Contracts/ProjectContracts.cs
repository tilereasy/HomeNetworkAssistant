namespace HomeNetworkAssistant.Api.Contracts;

public sealed record ProjectDto(
    int Id,
    string Name,
    string Description,
    string PropertyType,
    int RoomCount,
    string Provider,
    string PrimaryRouterName);

public sealed record CreateProjectRequest(
    string Name,
    string Description,
    string PropertyType,
    int RoomCount,
    string Provider,
    string PrimaryRouterName);
