# Rehberly - Microservice Architecture & Mobile App 🚀

Modern, ölçeklenebilir ve güvenli bir sosyal rota platformu. Bu proje, dağıtık sistem prensiplerine uygun olarak mikroservis mimarisi ile .NET ortamında geliştirilmiş arka plan servislerini ve bu servislere bağlanan çapraz platform (cross-platform) bir mobil uygulamayı içermektedir.

## 🛠 Kullanılan Teknolojiler
* **Backend:** .NET 10 (ASP.NET Core Web API)
* **Mobile Frontend:** Flutter & Dart
* **Veritabanı & Mesajlaşma:** PostgreSQL, RabbitMQ (Docker üzerinden çalışır)
* **ORM:** Entity Framework Core
* **Güvenlik:** BCrypt (Password Hashing), JWT (JSON Web Token)
* **İletişim:** Senkron (REST API) ve Asenkron (RabbitMQ) mikroservis haberleşmesi
* **Dokümantasyon:** Swagger / OpenAPI

---

## 🧩 Sistem Mimarisi

Proje, birbirinden bağımsız çalışabilen ve yönetilebilen şu modüllerden oluşmaktadır:
1. **AuthService:** Kullanıcı kayıt, giriş ve JWT tabanlı kimlik doğrulama işlemleri.
2. **ProfileService:** Kullanıcı profillerinin yönetimi.
3. **RouteService:** Rota oluşturma, kaydetme ve keşfetme işlemleri.
4. **Mobile Client:** Servislerle API Gateway üzerinden veya doğrudan haberleşen kullanıcı arayüzü.

---

## 📅 13 Haftalık Proje Geliştirme Takvimi

Proje, yazılım mühendisliği yaşam döngüsüne uygun olarak aşağıdaki 13 haftalık sprintlere bölünerek geliştirilmektedir:

* **1. Hafta (13 Mart - 19 Mart):** Proje gereksinim analizi, mikroservis mimari tasarım kararlarının alınması ve veritabanı şemalarının planlaması.
* **2. Hafta (20 Mart - 26 Mart):** Geliştirme ortamının kurulması, .NET 10 ve PostgreSQL entegrasyonu. 
* **3. Hafta (27 Mart - 2 Nisan):** Entity Framework Core migration işlemleri, Kullanıcı modellerinin oluşturulması ve Register uç noktasının BCrypt ile tamamlanması.
* **4. Hafta (3 Nisan - 9 Nisan):** JWT altyapısının entegre edilmesi ve Login servislerinin yazılması.
* **5. Hafta (10 Nisan - 16 Nisan):** API Gateway araştırmaları ve temel yönlendirme konfigürasyonlarının hazırlanması.
* **6. Hafta (17 Nisan - 23 Nisan):** ProfileService ve RouteService mikroservislerinin tasarlanması.
* **7. Hafta (24 Nisan - 30 Nisan):** Mikroservisler arası iletişimin (RabbitMQ) kurgulanması. Mobil uygulama temellerinin atılması.
* **8. Hafta (1 Mayıs - 7 Mayıs):** Merkezi Hata Yönetimi (Global Exception Handling) ve siber güvenlik sıkılaştırmaları.
* **9. Hafta (8 Mayıs - 14 Mayıs):** İstemci (Flutter) entegrasyonu ve API testleri.
* **10. Hafta (15 Mayıs - 21 Mayıs):** Birim testlerinin (Unit Testing) yazılması ve kod refactoring.
* **11. Hafta (22 Mayıs - 28 Mayıs):** Dockerize işlemleri (Dockerfile ve docker-compose yazımı).
* **12. Hafta (29 Mayıs - 4 Haziran):** CI/CD süreçlerinin tasarlanması ve bulut ortamına deploy hazırlığı.
* **13. Hafta (5 Haziran - 11 Haziran):** Son entegrasyon testleri, bug-fix, dokümantasyon ve proje teslimi.

---

## ⚙️ Kurulum ve Çalıştırma Rehberi

Projeyi kendi bilgisayarınızda ayağa kaldırmak için aşağıdaki adımları izleyebilirsiniz.

### 📌 Ön Koşullar
* [.NET 10 SDK](https://dotnet.microsoft.com/download)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Postgres ve RabbitMQ için)

### BÖLÜM 1: Sıfırdan İlk Kurulum
*Projeyi bilgisayarınıza ilk kez indirdiğinizde yapmanız gerekenler:*

1. Terminalde proje ana dizinindeyken mobil paketleri indirin ve Android klasörünü oluşturun:
   ```bash
   cd mobile
   flutter pub get
   flutter create --platforms=android .
2. Uygulamanın yerel ağa bağlanabilmesi için mobile/android/app/src/main/AndroidManifest.xml dosyasındaki <application etiketinin içine şu satırı ekleyin:
    android:usesCleartextTraffic="true"



# BÖLÜM 1: GÜNLÜK ÇALIŞTIRMA RUTİNİ (Bilgisayarı kapatıp açtıktan sonra)

## Adım 1: Telefonu Bilgisayara Bağla
Bilgisayarı yeniden başlattığın için telefonunla bilgisayar arasındaki kablosuz bağlantı koptu. Tekrar bağlamak için:
1. Bilgisayarından **Mobil Etkin Nokta**'yı (Hotspot) aç ve telefonunun bu ağa bağlı olduğundan emin ol.
2. Telefonda **Geliştirici Seçenekleri -> Kablosuz Hata Ayıklama** menüsüne gir.
3. Kablosuz hata ayıklamayı kapatıp tekrar aç.
4. Ekranda yazan **IP adresi ve Bağlantı noktası** rakamlarına bak (Örn: `192.168.137.47:12345`).
5. VS Code'da bir terminal aç ve şu komutları sırayla gir:
   cd $env:LOCALAPPDATA\Android\sdk\platform-tools
   .\adb connect TELEFONDA_YAZAN_IP:TELEFONDA_YAZAN_PORT

## Adım 2: Veritabanını (Docker) Çalıştır
Arka plandaki veritabanlarının uyanması lazım.
1. Windows Başlat menüsünden Docker Desktop'ı aç ve sağ alttaki balina simgesi sabitlenene kadar (çalışana kadar) bekle.
2. VS Code'da terminali projenin ana klasörüne (Rehberly) getir ve şunu yaz:
    docker compose up -d postgres rabbitmq

## Adım 3: Arka Plan Servislerini (Backend) Çalıştır
Veritabanı hazır, şimdi bizim yazdığımız API servislerini ayaklandırmamız lazım.
1. VS Code'da terminali projenin ana klasöründe (Rehberly) tutarak ekranı 3'e böl (Split Terminal).
2. Her bir pencereye şu komutlardan birini yapıştırıp Enter'a bas:
    dotnet run --project Rehberly.AuthService --launch-profile mobile   
    dotnet run --project Rehberly.RouteService --launch-profile mobile
    dotnet run --project Rehberly.ProfileService --launch-profile mobile
(Servislerin ekranda dinlemeye başladığını gördüğünde arka plan tamamen hazır demektir).

## Adım 4: Uygulamayı Telefonda Başlat
Uygulama beyninin nerede olduğunu (yani senin bilgisayarının adresini) bilmeli.
1. Yeni bir terminal sekmesi aç ve bilgisayarının IP'sini öğrenmek için ipconfig yaz.
2. Çıkan listede Mobil Etkin Nokta (veya Yerel Ağ Bağlantısı) altındaki IPv4 Adresini bul (Genelde 192.168.137.1 olur).
3. Terminalde mobile klasörüne gir ve bulduğun IP adresiyle uygulamayı çalıştır:
    cd mobile
    flutter run --dart-define=REHBERLY_API_HOST=BULDUGUN_IP_ADRESI
4. Terminal sana 2 seçenek sunarsa 1 yaz ve Enter'a bas. Uygulama telefonda açılacaktır! ek olarak: 
    Uygulama telefonda çalışırken terminal ekranında (flutter run komutunu yazdığın sekmede) klavyeden şu tuşlara basarak hızlıca işlem yapabilirsin (Enter'a basmana gerek yok):
    r (Hot Reload): Kodda yaptığın görsel veya mantıksal değişiklikleri saniyeler içinde telefona yansıtır. Uygulamayı baştan başlatmaz, sadece değişen yerleri günceller.
    R (Hot Restart): Uygulamayı telefonda tamamen yeniden başlatır. State (durum) ve değişkenler sıfırlanır, en başa döner.
    q (Quit): Uygulamayı telefonda kapatır ve terminaldeki çalışma sürecini tamamen sonlandırır.
    d (Detach): Uygulama telefonda çalışmaya devam eder ama VS Code ile olan bağlantısı kopar (Artık logları göremezsin, kendi kendine takılır).
    c (Clear): Terminal ekranındaki kalabalık log yazılarını temizler, ekranı ferahlatır.
    h (Help): Kullanabileceğin tüm diğer komutları terminalde listeler.

