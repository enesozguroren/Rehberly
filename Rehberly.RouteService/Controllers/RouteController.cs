using MassTransit;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rehberly.RouteService.Data;
using Rehberly.RouteService.DTOs;
using Rehberly.RouteService.Models;
using Rehberly.Shared.Messages;

namespace Rehberly.RouteService.Controllers;

[Route("api/[controller]")]
[ApiController]
public class RouteController : ControllerBase
{
    private readonly RouteDbContext _context;
    private readonly IPublishEndpoint _publishEndpoint;

    public RouteController(RouteDbContext context, IPublishEndpoint publishEndpoint)
    {
        _context = context;
        _publishEndpoint = publishEndpoint;
    }

    private IQueryable<RouteFeedDto> ProjectRouteFeed(IQueryable<Models.Route> query, string? username)
    {
        return query.Select(route => new RouteFeedDto
        {
            Id = route.Id,
            OwnerUsername = route.OwnerUsername,
            Title = route.Title,
            Description = route.Description,
            EstimatedBudget = route.EstimatedBudget,
            CreatedAt = route.CreatedAt,
            Stops = route.Stops
                .OrderBy(stop => stop.DayNumber)
                .Select(stop => new RouteStopDto
                {
                    Id = stop.Id,
                    CityName = stop.CityName,
                    StopName = stop.StopName,
                    DayNumber = stop.DayNumber,
                    Notes = stop.Notes
                })
                .ToList(),
            LikesCount = _context.RouteLikes.Count(like => like.RouteId == route.Id),
            CommentsCount = _context.RouteComments.Count(comment => comment.RouteId == route.Id),
            SavesCount = _context.RouteSaves.Count(save => save.RouteId == route.Id),
            IsLiked = username != null && _context.RouteLikes.Any(like => like.RouteId == route.Id && like.Username == username),
            IsSaved = username != null && _context.RouteSaves.Any(save => save.RouteId == route.Id && save.Username == username)
        });
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> CreateRoute(CreateRouteDto request)
    {
        var ownerUsername = User.Identity?.Name;
        if (string.IsNullOrEmpty(ownerUsername)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.Title))
        {
            return BadRequest("Rota basligi bos olamaz.");
        }

        var newRoute = new Models.Route
        {
            OwnerUsername = ownerUsername,
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            EstimatedBudget = request.EstimatedBudget,
            Stops = request.Stops.Select(stop => new RouteStop
            {
                CityName = stop.CityName.Trim(),
                StopName = stop.StopName.Trim(),
                DayNumber = stop.DayNumber,
                Notes = stop.Notes.Trim()
            }).ToList()
        };

        _context.Routes.Add(newRoute);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Rota basariyla olusturuldu!", routeId = newRoute.Id });
    }

    [HttpGet("feed")]
    public async Task<IActionResult> GetFeed()
    {
        var username = User.Identity?.IsAuthenticated == true ? User.Identity.Name : null;

        var routes = await ProjectRouteFeed(_context.Routes, username)
            .OrderByDescending(route => route.CreatedAt)
            .Take(20)
            .ToListAsync();

        return Ok(routes);
    }

    [HttpGet("saved")]
    [Authorize]
    public async Task<IActionResult> GetSavedRoutes()
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username)) return Unauthorized();

        var routeIds = await _context.RouteSaves
            .Where(save => save.Username == username)
            .OrderByDescending(save => save.SavedAt)
            .Select(save => save.RouteId)
            .ToListAsync();

        var routes = await ProjectRouteFeed(
                _context.Routes.Where(route => routeIds.Contains(route.Id)),
                username)
            .ToListAsync();

        return Ok(routes.OrderBy(route => routeIds.IndexOf(route.Id)));
    }

    [HttpPost("{id}/like")]
    [Authorize]
    public async Task<IActionResult> LikeRoute(Guid id)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username)) return Unauthorized();

        var routeExists = await _context.Routes.AnyAsync(route => route.Id == id);
        if (!routeExists) return NotFound("Rota bulunamadi.");

        var existingLike = await _context.RouteLikes.AnyAsync(like => like.RouteId == id && like.Username == username);
        if (existingLike) return Ok(new { message = "Rota zaten begenildi.", isLiked = true });

        _context.RouteLikes.Add(new RouteLike { RouteId = id, Username = username });
        await _context.SaveChangesAsync();

        return Ok(new { message = "Rota begenildi!", isLiked = true });
    }

    [HttpGet("{id}/comments")]
    public async Task<IActionResult> GetRouteComments(Guid id)
    {
        var comments = await _context.RouteComments
            .Where(comment => comment.RouteId == id)
            .OrderByDescending(comment => comment.CreatedAt)
            .Select(comment => new RouteCommentDto
            {
                Id = comment.Id,
                Username = comment.Username,
                Text = comment.Text,
                CreatedAt = comment.CreatedAt
            })
            .ToListAsync();

        return Ok(comments);
    }

    [HttpPost("{id}/comment")]
    [Authorize]
    public async Task<IActionResult> CommentRoute(Guid id, [FromBody] CommentRouteDto request)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username)) return Unauthorized();

        var text = request.Text.Trim();
        if (string.IsNullOrWhiteSpace(text)) return BadRequest("Yorum bos olamaz.");

        var routeExists = await _context.Routes.AnyAsync(route => route.Id == id);
        if (!routeExists) return NotFound("Rota bulunamadi.");

        var comment = new RouteComment { RouteId = id, Username = username, Text = text };
        _context.RouteComments.Add(comment);
        await _context.SaveChangesAsync();

        return Ok(new RouteCommentDto
        {
            Id = comment.Id,
            Username = comment.Username,
            Text = comment.Text,
            CreatedAt = comment.CreatedAt
        });
    }

    [HttpPost("{id}/save")]
    [Authorize]
    public async Task<IActionResult> SaveRoute(Guid id)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username)) return Unauthorized();

        var route = await _context.Routes.FindAsync(id);
        if (route == null) return NotFound("Rota bulunamadi.");

        var existingSave = await _context.RouteSaves.AnyAsync(save => save.RouteId == id && save.Username == username);
        if (existingSave)
        {
            return Ok(new { message = "Rota zaten kaydedildi.", routeId = id, isSaved = true });
        }

        _context.RouteSaves.Add(new RouteSave { RouteId = id, Username = username });
        await _context.SaveChangesAsync();

        await _publishEndpoint.Publish(new RouteSavedEvent
        {
            Username = username,
            RouteName = route.Title
        });

        return Ok(new { message = "Rota kaydedildi ve rutbeniz isleniyor!", routeId = id, isSaved = true });
    }

    [HttpDelete("{id}/save")]
    [Authorize]
    public async Task<IActionResult> UnsaveRoute(Guid id)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username)) return Unauthorized();

        var save = await _context.RouteSaves.FirstOrDefaultAsync(item => item.RouteId == id && item.Username == username);
        if (save == null)
        {
            return Ok(new { message = "Rota kayitlarda yok.", routeId = id, isSaved = false });
        }

        _context.RouteSaves.Remove(save);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Rota kayitlardan kaldirildi.", routeId = id, isSaved = false });
    }
}
