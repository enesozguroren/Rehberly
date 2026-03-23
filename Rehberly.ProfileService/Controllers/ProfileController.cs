using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rehberly.ProfileService.Data;
using Rehberly.ProfileService.DTOs;
using Rehberly.ProfileService.Models;
using System.Security.Claims;

namespace Rehberly.ProfileService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProfileController : ControllerBase
    {
        private readonly ProfileDbContext _context;

        public ProfileController(ProfileDbContext context)
        {
            _context = context;
        }

        // 1. Profil Görüntüleme (Herkes görebilir, kilit yok!)
        [HttpGet("{username}")]
        public async Task<IActionResult> GetProfile(string username)
        {
            var profile = await _context.UserProfiles.FirstOrDefaultAsync(p => p.Username == username);
            
            if (profile == null)
            {
                return NotFound("Böyle bir gezgin henüz buralardan geçmedi.");
            }

            return Ok(profile);
        }

        // 2. Profil Güncelleme (SADECE GİRİŞ YAPANLAR)
        [HttpPut]
        [Authorize] // İŞTE GÜVENLİK KİLİDİ BURADA!
        public async Task<IActionResult> UpdateProfile(ProfileUpdateDto request)
        {
            // Artık "enes" diye elle yazmıyoruz. 
            // Token'ın içinden giriş yapan kişinin adını cımbızla çekiyoruz!
            var username = User.Identity?.Name ?? User.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrEmpty(username))
            {
                return Unauthorized("Kimlik doğrulanamadı.");
            }

            var profile = await _context.UserProfiles.FirstOrDefaultAsync(p => p.Username == username);
            
            if (profile == null)
            {
                profile = new UserProfile { Username = username };
                _context.UserProfiles.Add(profile);
            }

            profile.FullName = request.FullName;
            profile.Bio = request.Bio;
            profile.ProfilePictureUrl = request.ProfilePictureUrl;
            profile.TravelStyle = request.TravelStyle;

            await _context.SaveChangesAsync();

            return Ok(new { message = $"Harika! {username} profili başarıyla güncellendi!", profile });
        }
    }
}