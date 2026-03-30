namespace Rehberly.RouteService.DTOs
{
    // 1. Ana Rota Taşıyıcısı
    public class CreateRouteDto
    {
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal TotalBudget { get; set; }
        
        // Bu rotanın içindeki durakların listesi
        public List<CreateRouteStopDto> Stops { get; set; } = new List<CreateRouteStopDto>();
    }

    // 2. Durağın Taşıyıcısı
    public class CreateRouteStopDto
    {
        public string Title { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
    }
}