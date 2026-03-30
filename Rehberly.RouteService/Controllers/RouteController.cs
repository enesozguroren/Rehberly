using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rehberly.RouteService.Data;
using Rehberly.RouteService.DTOs;
using Rehberly.RouteService.Models;
using System.Security.Claims;
using MassTransit;
using Rehberly.Shared;

namespace Rehberly.RouteService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RouteController : ControllerBase
    {
        private readonly RouteDbContext _context;
        private readonly IPublishEndpoint _publishEndpoint; // POSTACIYI ÇAĞIR

        // Sadece TEK BİR kurucu metodumuz (constructor) olmalı
        public RouteController(RouteDbContext context, IPublishEndpoint publishEndpoint)
        {
            _context = context;
            _publishEndpoint = publishEndpoint;
        }

        // 1. ROTA OLUŞTURMA (Sadece giriş yapanlar "Ben burayı böyle gezdim" diyebilir)
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateRoute(CreateRouteDto request)
        {
            var username = User.Identity?.Name ?? User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(username)) return Unauthorized("Kimlik doğrulanamadı.");

            var newRoute = new TravelRoute
            {
                Username = username,
                Title = request.Title,
                Description = request.Description,
                TotalBudget = request.TotalBudget,
                Stops = request.Stops.Select(s => new RouteStop
                {
                    Title = s.Title,
                    Location = s.Location,
                    Notes = s.Notes,
                    ImageUrl = s.ImageUrl
                }).ToList()
            };

            _context.TravelRoutes.Add(newRoute);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Harika! Rotan başarıyla paylaşıldı ve diğer gezginlere ilham olmaya hazır.", routeId = newRoute.Id });
        }

        // 2. ANA AKIŞ / KEŞFET (Herkes görebilir, Trend rotalar en üstte!)
        [HttpGet("feed")]
        public async Task<IActionResult> GetFeed()
        {
            var routes = await _context.TravelRoutes
                .Include(r => r.Stops) 
                .OrderByDescending(r => r.SaveCount) 
                .Take(50) 
                .ToListAsync();

            return Ok(routes);
        }

        // 3. ROTAYI KAYDETME (Gamification / Oyunlaştırma Puanı!)
        [HttpPost("{id}/save")]
        [Authorize]
        public async Task<IActionResult> SaveRoute(int id)
        {
            var route = await _context.TravelRoutes.FindAsync(id);
            if (route == null) return NotFound("Böyle bir rota bulunamadı.");

            route.SaveCount += 1; 
            await _context.SaveChangesAsync();

            // 🐇 POSTACIYA MEKTUBU VERİYORUZ!
            await _publishEndpoint.Publish(new RouteSavedEvent
            {
                RouteOwnerUsername = route.Username
            });

            return Ok(new { message = "Rota başarıyla kaydedildi! (Mektup postaneye bırakıldı)", currentSaveCount = route.SaveCount });
        }
    }
}