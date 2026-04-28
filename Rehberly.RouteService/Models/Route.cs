namespace Rehberly.RouteService.Models;

public class Route
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string OwnerUsername { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal EstimatedBudget { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public List<RouteStop> Stops { get; set; } = new();
}
