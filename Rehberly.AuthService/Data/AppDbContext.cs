using Microsoft.EntityFrameworkCore;
using Rehberly.AuthService.Models;

namespace Rehberly.AuthService.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
    }
}