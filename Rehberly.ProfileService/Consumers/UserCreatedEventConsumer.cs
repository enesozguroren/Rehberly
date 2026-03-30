using MassTransit;
using Microsoft.EntityFrameworkCore;
using Rehberly.Shared.Messages;
using Rehberly.ProfileService.Data;
using Rehberly.ProfileService.Models; // Models klasörünü import ettik

namespace Rehberly.ProfileService.Consumers
{
    public class UserCreatedEventConsumer : IConsumer<UserCreatedEvent>
    {
        private readonly ProfileDbContext _context;

        // 1. Veritabanı bağlamını (DbContext) içeri alıyoruz (Dependency Injection)
        public UserCreatedEventConsumer(ProfileDbContext context)
        {
            _context = context;
        }

        public async Task Consume(ConsumeContext<UserCreatedEvent> context)
        {
            var message = context.Message;
            
            // 2. Bu kullanıcının yanlışlıkla önceden profili açılmış mı diye kontrol ediyoruz (güvenlik)
            var existingProfile = await _context.UserProfiles.FirstOrDefaultAsync(p => p.Username == message.Username);

            if (existingProfile == null)
            {
                // 3. Yepyeni, içi dolu bir profil oluşturuyoruz
                var newProfile = new UserProfile
                {
                    // Not: UserProfile modelindeki özellik isimleri farklıysa burayı kendi modeline göre düzenle.
                    Username = message.Username,
                    // Email özelliğin varsa açabilirsin: Email = message.Email,
                    
                    // Varsayılan (Default) atamalarımız:
                    Bio = "Merhaba! Ben Rehberly'de yepyeni bir kaşifim.",
                    ProfilePictureUrl = "default-avatar.png",
                    RankTitle = "Çaylak Kaşif" // Daha önceki kodlarında gördüğüm o efsane unvan :)
                };

                // 4. Veritabanına ekle ve kaydet
                _context.UserProfiles.Add(newProfile);
                await _context.SaveChangesAsync();

                Console.WriteLine($"\n\n🎯 [VERİTABANI BAŞARILI] {message.Username} adlı gezgin için yepyeni bir profil oluşturuldu ve veritabanına kaydedildi!\n\n");
            }
            else
            {
                Console.WriteLine($"\n\n⚠️ [BİLGİ] {message.Username} isimli kullanıcının zaten bir profili mevcut.\n\n");
            }
        }
    }
}