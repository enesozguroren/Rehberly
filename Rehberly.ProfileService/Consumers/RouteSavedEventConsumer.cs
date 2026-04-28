using MassTransit;
using Microsoft.EntityFrameworkCore;
using Rehberly.ProfileService.Data;
using Rehberly.Shared.Messages;

namespace Rehberly.ProfileService.Consumers;

public class RouteSavedEventConsumer : IConsumer<RouteSavedEvent>
{
    private readonly ProfileDbContext _context;

    public RouteSavedEventConsumer(ProfileDbContext context)
    {
        _context = context;
    }

    public async Task Consume(ConsumeContext<RouteSavedEvent> context)
    {
        var msg = context.Message;
        
        // Kullanıcının profilini veritabanından bul
        var profile = await _context.UserProfiles.FirstOrDefaultAsync(p => p.Username == msg.Username);
        
        if (profile != null)
        {
            // EFSANE FİKİR DEVREDE: Rütbeyi güncelle!
            profile.RankTitle = "Deneyimli Gezgin"; 
            await _context.SaveChangesAsync();
            
            // Console'a yıldızlı kutlama mesajımızı bas
            Console.WriteLine($"\n\n⭐ [SEVİYE ATLADI] {msg.Username}, '{msg.RouteName}' rotasını kaydettiği için 'Deneyimli Gezgin' unvanını kazandı!\n\n");
        }
    }
}