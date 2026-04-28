namespace Rehberly.Shared.Messages;

public record RouteSavedEvent
{
    public string Username { get; init; } = string.Empty;
    public string RouteName { get; init; } = string.Empty;
}
