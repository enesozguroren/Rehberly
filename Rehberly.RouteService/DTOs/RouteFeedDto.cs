namespace Rehberly.RouteService.DTOs;

public class RouteFeedDto
{
    public Guid Id { get; set; }
    public string OwnerUsername { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal EstimatedBudget { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<RouteStopDto> Stops { get; set; } = new();
    public int LikesCount { get; set; }
    public int CommentsCount { get; set; }
    public int SavesCount { get; set; }
    public bool IsLiked { get; set; }
    public bool IsSaved { get; set; }
}

public class RouteStopDto
{
    public Guid Id { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string StopName { get; set; } = string.Empty;
    public int DayNumber { get; set; }
    public string Notes { get; set; } = string.Empty;
}

public class RouteCommentDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Text { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class CommentRouteDto
{
    public string Text { get; set; } = string.Empty;
}
