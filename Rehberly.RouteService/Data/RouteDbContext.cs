using Microsoft.EntityFrameworkCore;
using Rehberly.RouteService.Models;

namespace Rehberly.RouteService.Data;

public class RouteDbContext : DbContext
{
    public RouteDbContext(DbContextOptions<RouteDbContext> options) : base(options) { }

    public DbSet<Models.Route> Routes { get; set; }
    public DbSet<RouteStop> RouteStops { get; set; }
    public DbSet<RouteLike> RouteLikes { get; set; }
    public DbSet<RouteComment> RouteComments { get; set; }
    public DbSet<RouteSave> RouteSaves { get; set; }
}