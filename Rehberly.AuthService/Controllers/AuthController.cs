using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rehberly.AuthService.Data;
using Rehberly.AuthService.DTOs;
using Rehberly.AuthService.Models;

namespace Rehberly.AuthService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(UserRegisterDto request)
        {
            // Kullanıcı adı veya email alınmış mı kontrolü
            if (await _context.Users.AnyAsync(u => u.Username == request.Username || u.Email == request.Email))
            {
                return BadRequest("Bu kullanıcı adı veya e-posta zaten kullanımda.");
            }

            // Şifreyi şifreleme (Hash)
            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            // Yeni kullanıcıyı oluşturma
            var newUser = new User
            {
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash
            };

            // Veritabanına kaydetme
            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı başarıyla oluşturuldu!" });
        }

        [HttpPost("login")]
        public IActionResult Login()
        {
            return Ok(new { token = "ornek_jwt_token_gelecek" });
        }
    }
}