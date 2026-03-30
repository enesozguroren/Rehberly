var builder = WebApplication.CreateBuilder(args);

// YARP'ı sisteme ekle ve ayarlarını appsettings.json dosyasından almasını söyle
builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

// Gelen istekleri YARP üzerinden yönlendir
app.MapReverseProxy();

app.Run();