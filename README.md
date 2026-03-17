# Rehberly - Microservice Architecture 🚀

Modern, ölçeklenebilir ve güvenli bir sosyal platform altyapısı. Bu proje, dağıtık sistem prensiplerine uygun olarak mikroservis mimarisi ile geliştirilmektedir. Mevcut depo (repository), sistemin kimlik doğrulama ve yetkilendirme süreçlerini yöneten **AuthService** modülünü içermektedir.

## 🛠 Kullanılan Teknolojiler
* **Framework:** .NET 10 (ASP.NET Core Web API)
* **Veritabanı:** PostgreSQL
* **ORM:** Entity Framework Core
* **Güvenlik:** BCrypt (Password Hashing), JWT (JSON Web Token) *[Geliştirme Aşamasında]*
* **Dokümantasyon:** Swagger / OpenAPI

---

## 📅 13 Haftalık Proje Geliştirme Takvimi

Proje, yazılım mühendisliği yaşam döngüsüne uygun olarak aşağıdaki 13 haftalık sprintlere bölünerek geliştirilmektedir:

* **1. Hafta (13 Mart - 19 Mart):** Proje gereksinim analizi, mikroservis mimari tasarım kararlarının alınması ve veritabanı şemalarının teorik planlaması.
* **2. Hafta (20 Mart - 26 Mart):** Geliştirme ortamının kurulması, .NET 10 ve PostgreSQL entegrasyonu, AuthService iskeletinin ayağa kaldırılması. 
* **3. Hafta (27 Mart - 2 Nisan):** Entity Framework Core migration işlemlerinin yapılması, Kullanıcı (User) modellerinin oluşturulması ve Register (Kayıt) uç noktasının BCrypt şifreleme ile tamamlanması.
* **4. Hafta (3 Nisan - 9 Nisan):** JWT (JSON Web Token) altyapısının sisteme entegre edilmesi ve Login (Giriş) doğrulama servislerinin yazılması.
* **5. Hafta (10 Nisan - 16 Nisan):** API Gateway (API Geçidi) araştırmalarının yapılması ve mikroservisler için temel yönlendirme (routing) konfigürasyonlarının hazırlanması.
* **6. Hafta (17 Nisan - 23 Nisan):** Platformun ikinci temel mikroservisinin (örn. Kullanıcı Profili veya İçerik servisi) tasarlanması ve bağımsız veritabanı bağlantılarının kurulması.
* **7. Hafta (24 Nisan - 30 Nisan):** Mikroservisler arası güvenli iletişimin (senkron/REST veya asenkron/Message Broker) kurgulanması.
* **8. Hafta (1 Mayıs - 7 Mayıs):** Sistem genelinde Global Exception Handling (Merkezi Hata Yönetimi) yapısının kurulması ve siber güvenlik sıkılaştırmalarının (CORS, Rate Limiting) yapılması.
* **9. Hafta (8 Mayıs - 14 Mayıs):** İstemci (Frontend) entegrasyonu için hazırlıkların yapılması ve Swagger üzerinden kapsamlı API testlerinin yürütülmesi.
* **10. Hafta (15 Mayıs - 21 Mayıs):** Kritik iş mantıkları için birim testlerinin (Unit Testing) yazılması ve kod refactoring işlemleri.
* **11. Hafta (22 Mayıs - 28 Mayıs):** Mikroservislerin izole edilmesi amacıyla Dockerize işlemleri (Dockerfile ve docker-compose yazımı).
* **12. Hafta (29 Mayıs - 4 Haziran):** Konteyner mimarisinin bulut ortamına (örneğin Kubernetes cluster veya temel sunucu) deploy edilmesi için CI/CD süreçlerinin tasarlanması.
* **13. Hafta (5 Haziran - 11 Haziran):** Son entegrasyon testlerinin yapılması, olası hataların (bug-fix) giderilmesi, README ve API dokümantasyonlarının nihai haline getirilerek projenin teslime hazır hale getirilmesi.

---

## ⚙️ Kurulum ve Çalıştırma Rehberi

Projeyi kendi bilgisayarınızda (lokal ortamda) ayağa kaldırmak için aşağıdaki adımları izleyebilirsiniz.

### Ön Koşullar
* [.NET 10 SDK](https://dotnet.microsoft.com/download)
* [PostgreSQL](https://www.postgresql.org/download/) (v16 veya üzeri önerilir)

### Adım 1: Veritabanı Ayarları
1. PostgreSQL'i kurun ve çalışır durumda olduğundan emin olun.
2. Proje dizinindeki `Rehberly.AuthService/appsettings.json` dosyasını açın.
3. `ConnectionStrings:DefaultConnection` alanındaki `Password=senin_sifren` kısmını kendi yerel PostgreSQL şifreniz ile güncelleyin.

### Adım 2: Tabloların Oluşturulması (Migration)
Terminali açın, `Rehberly.AuthService` dizinine girin ve Entity Framework Core kullanarak veritabanı tablolarını oluşturun:

```bash
cd Rehberly.AuthService
dotnet ef database update
```

### Adım 3: Projeyi Başlatma
Tablolar başarıyla oluştuktan sonra, sunucuyu ayağa kaldırmak için şu komutu çalıştırın:

```bash
dotnet run
```

### Adım 4: Test (Swagger)
Uygulama çalıştıktan sonra terminalde belirtilen adrese (genellikle `http://localhost:5229`) gidin ve URL'in sonuna `/swagger` ekleyerek API arayüzüne erişin. Örnek:
`http://localhost:5229/swagger`

Buradan `/api/Auth/register` gibi uç noktaları doğrudan tarayıcınız üzerinden test edebilirsiniz.