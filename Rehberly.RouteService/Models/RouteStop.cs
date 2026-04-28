using System.Text.Json.Serialization;

namespace Rehberly.RouteService.Models;

public class RouteStop
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RouteId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string StopName { get; set; } = string.Empty;
    public int DayNumber { get; set; }
    public string Notes { get; set; } = string.Empty;

    [JsonIgnore] 
    public Route? Route { get; set; }
}
