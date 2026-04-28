var builder = WebApplication.CreateBuilder(args);
const string MobileClientCorsPolicy = "MobileClient";

// YARP'ı sisteme ekle ve ayarlarını appsettings.json dosyasından almasını söyle
builder.Services.AddCors(options =>
{
    options.AddPolicy(MobileClientCorsPolicy, policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

// Gelen istekleri YARP üzerinden yönlendir
app.UseCors(MobileClientCorsPolicy);
app.MapReverseProxy();

app.Run();
