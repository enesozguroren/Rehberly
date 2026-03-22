using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rehberly.AuthService.Data;
using Rehberly.AuthService.DTOs;
using Rehberly.AuthService.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Rehberly.AuthService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(UserRegisterDto request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username || u.Email == request.Email))
            {
                return BadRequest("Bu kullanıcı adı veya e-posta zaten kullanımda.");
            }

            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var newUser = new User
            {
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı başarıyla oluşturuldu!" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(UserLoginDto request)
        {
            // 1. Kullanıcıyı bul
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);
            if (user == null)
            {
                return BadRequest("Kullanıcı bulunamadı.");
            }

            // 2. Şifreyi kontrol et
            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return BadRequest("Yanlış şifre.");
            }

            // 3. Token hazırlığı
            var tokenSecret = _configuration.GetSection("Jwt:Token").Value;
            if (string.IsNullOrEmpty(tokenSecret)) return StatusCode(500, "Token anahtarı bulunamadı!");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenSecret));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Username)
            };

            // 4. Token'ı oluştur
            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(1),
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return Ok(new { token = jwt });
        }

        // SADECE GİRİŞ YAPMIŞ KULLANICILAR BURAYI GÖREBİLİR
        [HttpGet("profile")]
        [Microsoft.AspNetCore.Authorization.Authorize] // Bu kilit işaretidir!
        public IActionResult GetProfile()
        {
            // Token'ın içinden giriş yapmış kişinin adını okuyoruz
            var userName = User.Identity?.Name;
            
            return Ok(new 
            { 
                message = $"VIP odaya hoş geldin, {userName}! Token'ın başarıyla doğrulandı." 
            });
        }


    }
}