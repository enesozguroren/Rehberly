namespace Rehberly.Shared.Messages;

public record UserCreatedEvent
{
    public Guid UserId { get; init; }
    public string Username { get; init; }
    public string Email { get; init; }
}