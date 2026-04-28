using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Rehberly.ProfileService.Data;
using System.Text;
using MassTransit;
using Rehberly.ProfileService.Consumers;

var builder = WebApplication.CreateBuilder(args);
const string MobileClientCorsPolicy = "MobileClient";

// 1. Veritabanı Bağlantısı
builder.Services.AddDbContext<ProfileDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddCors(options =>
{
    options.AddPolicy(MobileClientCorsPolicy, policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// MassTransit & RabbitMQ Ayarları (Alıcı Modu)
// MassTransit & RabbitMQ Ayarları (Alıcı Modu)
builder.Services.AddMassTransit(x =>
{
    // 1. KULAK: Yeni kayıtları dinler
    x.AddConsumer<UserCreatedEventConsumer>();
    
    // 2. KULAK: Rota kaydedilmelerini dinler (İŞTE BUNU UNUTMUŞTUK!)
    x.AddConsumer<RouteSavedEventConsumer>();

    x.UsingRabbitMq((context, cfg) =>
    {
        var rabbitMqHost = builder.Configuration["RabbitMq:Host"] ?? "rabbitmq";
        cfg.Host(rabbitMqHost, "/", h => {
            h.Username("guest");
            h.Password("guest");
        });

        // 1. KUYRUK (Yeni Kullanıcılar)
        cfg.ReceiveEndpoint("profile-user-created-queue", e =>
        {
            e.ConfigureConsumer<UserCreatedEventConsumer>(context);
        });

        // 2. KUYRUK (Rota Kaydedenler)
        cfg.ReceiveEndpoint("profile-route-saved-queue", e =>
        {
            e.ConfigureConsumer<RouteSavedEventConsumer>(context);
        });
    });
});

// 2. Swagger'a Kilit Butonu Ekleme
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Rehberly Profile API", Version = "v1" });
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

// 3. JWT Doğrulama Ayarları
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

// --- OTOMATİK VERİTABANI GÜNCELLEYİCİ (ProfileDbContext olarak düzeltildi) ---
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ProfileDbContext>();
    dbContext.Database.Migrate(); 
}
// ----------------------------------------

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// 4. Kimlik Doğrulamayı Aktif Et
app.UseCors(MobileClientCorsPolicy);
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
