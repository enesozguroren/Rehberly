namespace Rehberly.RouteService.Models
{
    public class TravelRoute
    {
        public int Id { get; set; }
        
        // Rotayı kim oluşturdu? (Auth servisindeki kullanıcı adı)
        public string Username { get; set; } = string.Empty; 
        
        // Rota Temel Bilgileri
        public string Title { get; set; } = string.Empty; // Örn: "3 Günde Paris"
        public string Description { get; set; } = string.Empty; // Örn: "Minimum bütçeyle maksimum eğlence..."
        public decimal TotalBudget { get; set; } = 0; // Toplam harcama
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Oyunlaştırma (Gamification) - Senin o harika fikrin!
        public int SaveCount { get; set; } = 0; // Bu rotayı kaç kişi kendi profiline kaydetti?
        
        // Bir rotanın birden fazla durağı olur (Bire-Çok İlişki)
        public List<RouteStop> Stops { get; set; } = new List<RouteStop>();
    }
}