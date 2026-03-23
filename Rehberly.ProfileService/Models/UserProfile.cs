namespace Rehberly.ProfileService.Models
{
    public class UserProfile
    {
        public int Id { get; set; }
        
        // Auth servisindeki kullanıcıyı tanımamız için gereken bağ (Mikroservis mantığı)
        public string Username { get; set; } = string.Empty; 
        
        // Temel Profil Bilgileri
        public string FullName { get; set; } = string.Empty;
        public string Bio { get; set; } = "Dünyayı keşfetmeye hazır yeni bir gezgin!";
        public string ProfilePictureUrl { get; set; } = string.Empty;
        
        // Seyahat/Oyunlaştırma (Gamification) Bilgileri
        public string TravelStyle { get; set; } = "Henüz Belirtilmedi"; // Sırt Çantalı, Lüks Gezgin, vs.
        public string RankTitle { get; set; } = "Çaylak Kaşif"; // Başlangıç Seviyesi
        public int VisitedCountryCount { get; set; } = 0;
        public int VisitedCityCount { get; set; } = 0;
    }
}