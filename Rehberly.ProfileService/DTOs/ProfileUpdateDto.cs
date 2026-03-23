namespace Rehberly.ProfileService.DTOs
{
    public class ProfileUpdateDto
    {
        public string FullName { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public string TravelStyle { get; set; } = string.Empty;
        // Dikkat: Rank veya Şehir Sayısı burada yok! Hile yapılamaz.
    }
}