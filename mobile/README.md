# Rehberly Mobile

Flutter istemcisi `lib/core`, `lib/features` ve `lib/shared` katmanlariyla duzenlendi.

Bu ortamda Flutter SDK bulunmadigi icin platform klasorleri uretilmedi. Ilk calistirmadan once:

```powershell
cd mobile
flutter create --platforms=android,ios .
flutter pub get
```

Android'de yerel HTTP servislerine baglanirken `android/app/src/main/AndroidManifest.xml`
icindeki `<application>` etiketine su attribute'u ekleyin:

```xml
android:usesCleartextTraffic="true"
```

Yerel servisler icin varsayilan adresler:

- Android emulator: `10.0.2.2`
- iOS simulator, desktop ve web: `localhost`
- AuthService: `5229`
- RouteService: `5190`
- ProfileService: `5068`

Gercek cihazda calistirirken host IP verin:

```powershell
flutter run --dart-define=REHBERLY_API_HOST=192.168.1.23
```

Gateway uzerinden tek port kullanmak isterseniz:

```powershell
flutter run --dart-define=REHBERLY_USE_GATEWAY=true --dart-define=REHBERLY_GATEWAY_PORT=5082
```
