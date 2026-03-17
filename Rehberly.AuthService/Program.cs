using Microsoft.EntityFrameworkCore;
using Rehberly.AuthService.Data;

var builder = WebApplication.CreateBuilder(args);

// 1. Veritabanı Bağlantısını Servislere Ekleme
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// 2. Controller'ları (AuthController vb.) Sisteme Tanıtma
builder.Services.AddControllers();

// 3. Test Arayüzü (Swagger) Ayarları
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 4. HTTP İstek Hattı (Sadece geliştirme aşamasında arayüzü göster)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

// 5. Güvenlik ve Yetkilendirme
app.UseAuthorization();

// 6. Yazdığımız API Rotalarını Eşleştirme (Bunu yazmazsak endpoint'ler bulunamaz)
app.MapControllers();

app.Run();