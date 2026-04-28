namespace Rehberly.Shared.Messages;

public record UserCreatedEvent
{
    public Guid UserId { get; init; }
    public string Username { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;
}
