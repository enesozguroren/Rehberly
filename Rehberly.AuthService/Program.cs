using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Rehberly.AuthService.Data;
using System.Text;
using MassTransit;

var builder = WebApplication.CreateBuilder(args);
const string MobileClientCorsPolicy = "MobileClient";
var configuredCorsOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .GetChildren()
    .Select(origin => origin.Value)
    .Where(origin => !string.IsNullOrWhiteSpace(origin))
    .Cast<string>()
    .ToArray();
var allowedCorsOrigins = builder.Environment.IsDevelopment() ||
    builder.Environment.IsEnvironment("Local")
        ? new[]
        {
            "http://localhost:3000",
            "http://localhost:5000",
            "http://localhost:5173",
            "http://localhost:5229",
            "http://localhost:5190"
        }
        : configuredCorsOrigins;

builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((context, cfg) =>
    {
        // Docker'daki rabbitmq servisimize bağlanıyoruz
        var rabbitMqHost = builder.Configuration["RabbitMq:Host"] ?? "rabbitmq";
        cfg.Host(rabbitMqHost, "/", h => {
            h.Username("guest");
            h.Password("guest");
        });
    });
});

// 1. Veritabanı Bağlantısı (İsim AppDbContext olarak düzeltildi!)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();
builder.Services.AddCors(options =>
{
    options.AddPolicy(MobileClientCorsPolicy, policy =>
    {
        policy.WithOrigins(allowedCorsOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// 2. Swagger'a "Kilit" (Authorize) Butonu Ekleme
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Rehberly Auth API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Token'ınızı buraya girin. Örnek: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement{
    {
        new OpenApiSecurityScheme{
            Reference = new OpenApiReference{
                Type = ReferenceType.SecurityScheme,
                Id = "Bearer"
            }
        },
        new string[]{}
    }});
});

// 3. Güvenlik Görevlisi (JWT Doğrulama Ayarları)
var tokenSecret = builder.Configuration.GetSection("Jwt:Token").Value;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenSecret!)),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

var app = builder.Build();

// --- OTOMATİK VERİTABANI GÜNCELLEYİCİ (AppDbContext olarak düzeltildi!) ---
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    dbContext.Database.Migrate(); 
}
// ----------------------------------------

if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Local"))
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// 4. Kimlik Doğrulama ve Yetkilendirmeyi Aktif Et
app.UseCors(MobileClientCorsPolicy);
app.UseAuthentication();
app.UseAuthorization();

app.MapHealthChecks("/health");
app.MapControllers();
app.Run();
