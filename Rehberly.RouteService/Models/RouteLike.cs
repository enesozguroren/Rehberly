namespace Rehberly.RouteService.Models;

public class RouteLike
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RouteId { get; set; }
    public string Username { get; set; } = string.Empty;
    public DateTime LikedAt { get; set; } = DateTime.UtcNow;
}
