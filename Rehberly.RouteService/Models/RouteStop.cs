using System.Text.Json.Serialization;

namespace Rehberly.RouteService.Models
{
    public class RouteStop
    {
        public int Id { get; set; }
        
        // Hangi rotaya ait?
        public int TravelRouteId { get; set; }
        
        // Durak Bilgileri
        public string Title { get; set; } = string.Empty; // Örn: "Louvre Müzesi"
        public string Location { get; set; } = string.Empty; // Harita konumu veya metin
        public string Notes { get; set; } = string.Empty; // "Biletleri sabah erken alın yoksa sıra beklersiniz"
        public string ImageUrl { get; set; } = string.Empty; // Eyfel kulesi önündeki o havalı fotoğraf :)
        
        // JsonIgnore: Döngüsel hatayı önlemek için (Swagger'ı çökertmemesi için)
        [JsonIgnore]
        public TravelRoute? TravelRoute { get; set; }
    }
}
