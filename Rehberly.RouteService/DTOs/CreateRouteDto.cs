namespace Rehberly.RouteService.DTOs;

public class CreateRouteDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal EstimatedBudget { get; set; }
    public List<CreateRouteStopDto> Stops { get; set; } = new();
}

public class CreateRouteStopDto
{
    public string CityName { get; set; } = string.Empty;
    public string StopName { get; set; } = string.Empty;
    public int DayNumber { get; set; }
    public string Notes { get; set; } = string.Empty;
}
