using Microsoft.EntityFrameworkCore;
using Rehberly.RouteService.Models;

namespace Rehberly.RouteService.Data
{
    public class RouteDbContext : DbContext
    {
        public RouteDbContext(DbContextOptions<RouteDbContext> options) : base(options)
        {
        }

        // Entity Framework'e tablolarımızı tanıtıyoruz
        public DbSet<TravelRoute> TravelRoutes { get; set; }
        public DbSet<RouteStop> RouteStops { get; set; }
    }
}
