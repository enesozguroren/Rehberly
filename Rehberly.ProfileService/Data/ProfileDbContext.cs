using Microsoft.EntityFrameworkCore;
using Rehberly.ProfileService.Models;

namespace Rehberly.ProfileService.Data
{
    public class ProfileDbContext : DbContext
    {
        public ProfileDbContext(DbContextOptions<ProfileDbContext> options) : base(options)
        {
        }

        public DbSet<UserProfile> UserProfiles { get; set; }
    }
}