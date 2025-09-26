# AutoCAD LISP Polyline to Curve Dönüştürücü

AutoCAD'de mevcut polyline çizgilerini curved (eğri) çizgiler haline getiren kapsamlı LISP araç seti.

## 🎯 Özellikler

- **PL2CURVE**: Polyline'ları spline eğrilerine dönüştürür
- **SMOOTHPL**: Polyline'ları smooth (yumuşak) yapar
- **FITCURVE**: Polyline'ları fit curve (uygun eğri) yapar
- **JOINPL**: İki polyline'ı uç uca birleştirir
- **AUTOJOINPL**: Seçilen polyline'lar arasında uç uca gelenleri otomatik birleştirir

## 🚀 Hızlı Başlangıç

1. `src/lisp/polyline-to-curve.lsp` dosyasını AutoCAD'e yükleyin
2. Komut satırında `PL2CURVE` yazın
3. Dönüştürmek istediğiniz polyline'ları seçin

## 📚 Dokümantasyon

Detaylı kullanım kılavuzu: [docs/lisp/polyline-to-curve.md](docs/lisp/polyline-to-curve.md)

## 💻 Kullanım Örnekleri

### Temel Dönüştürme
```
Komut: PL2CURVE
Polyline'ları seçin: [çizgileri seç]
Polyline 1 curved çizgiye dönüştürüldü.
Toplam 1 polyline işlendi.
```

### Hızlı Smooth İşlemi
```
Komut: SMOOTHPL
Smooth yapılacak polyline'ları seçin: [çizgileri seç] 
Polyline'lar smooth yapıldı.
```

### Polyline Birleştirme
```
Komut: JOINPL
Birleştirilecek ilk polyline'ı seçin: [ilk çizgiyi seç]
Birleştirilecek ikinci polyline'ı seçin: [ikinci çizgiyi seç]
Polyline'lar birleştirildi (end1->start2).
```

### Otomatik Birleştirme
```
Komut: AUTOJOINPL
Birleştirilecek polyline'ları seçin: [birden çok çizgi seç]
Toplam 3 polyline çifti birleştirildi.
```

## 📁 Proje Yapısı

```
├── src/lisp/                  # LISP kaynak kodları
│   └── polyline-to-curve.lsp  # Ana LISP dosyası
├── docs/lisp/                 # LISP dokümantasyonları  
│   └── polyline-to-curve.md   # Detaylı kullanım kılavuzu
└── docs/registry/             # Proje kayıt sistemi
    └── identifiers.json       # Modül tanımları
```

Bu proje, sıfırdan kod geliştirme için hazırlanmış kapsamlı bir şablondur. Tüm modern geli## 🔄 Registry ve Context Yönetimi

Proje tutarlılığı için:

### Registry Dosyaları (Zorunlu)
- `docs/registry/identifiers.json` - Modüller, export'lar, değişkenlar
- `docs/registry/endpoints.json` - API contract'ları 
- `docs/registry/schemas.json` - Veri modelleri
- `docs/registry/README.md` - Registry kullanım rehberi

### Context Dosyaları
- `.mds/context/current-context.md` - Aktif teknik özet
- `.mds/context/history/` - Session geçmişi

### Validation Scripts
- `scripts/validate-registry.ps1` - Registry dosyalarının doğruluğunu kontrol eder
- `scripts/rehydrate-context.ps1` - Context dosyalarını günceller

### Kullanım
```bash
# Registry doğrulama
.\scripts\validate-registry.ps1

# Context yenileme  
.\scripts\rehydrate-context.ps1
```ları, en iyi pratikler ve standartlar içermektedir.

## 🚀 Özellikler

### Teknoloji Desteği
- **Desktop Applications**: .NET WPF, .NET MAUI uygulamaları
- **Cloud Services**: Python FastAPI, Node.js, Go Web API backend servisler  
- **Web Applications**: TypeScript/React/Next.js frontend
- **Mobile Applications**: Android Kotlin, iOS Swift, Flutter cross-platform
- **AI Integration**: OpenAI, Azure OpenAI, Vertex AI entegrasyonu
- **Database**: Entity Framework Core, SQLAlchemy, Prisma ORM

### Geliştirme Kuralları
- **Git Workflow**: Feature branch stratejisi
- **Code Quality**: Lint, format, test coverage
- **Security**: OWASP güvenlik standartları
- **Performance**: Optimize edilmiş kod yapıları
- **Documentation**: Türkçe ve İngilizce dokümantasyon

## 📁 Proje Yapısı

```
├── .github/
│   ├── instructions/          # Geliştirme kuralları
│   ├── prompts/              # Yeniden kullanılabilir görevler
│   └── copilot-instructions.md # Ana kurallar dosyası
├── src/
│   ├── desktop-app/          # .NET WPF/.NET MAUI uygulaması
│   ├── cloud-server/         # Python FastAPI/Node.js/Go backend
│   ├── web-app/              # React/Next.js frontend
│   ├── mobile-app/           # Android/iOS/Flutter mobile
│   └── shared/               # Ortak kütüphaneler
├── docs/
│   ├── registry/             # API sözleşmeleri ve şemalar
│   └── architecture/         # Sistem dokümantasyonu
├── scripts/                  # Validation ve automation scriptleri
├── tests/                    # Test dosyaları
├── .mds/
│   └── context/              # Session ve bağlam yönetimi
├── version.md                # Versiyon geçmişi
└── configs/                  # Konfigürasyon dosyaları
```

## 🔧 Geliştirme Workflow'u

### 1. Feature Branch Oluşturma
```bash
git checkout master
git pull origin master  
git checkout -b feature/yeni-ozellik-adi
```

### 2. Kod Geliştirme
- İlgili instruction dosyalarını oku
- Kod standartlarına uy
- Test yaz
- Dokümante et

### 3. Kalite Kontrolleri
- Lint ve format kontrol
- Unit/integration testleri
- Security scan
- Performance analizi

### 4. Review ve Merge
- Feature branch'i push et
- Pull Request oluştur
- Code review bekle
- Master'a merge

## 📚 Instruction Dosyaları

### Ana Kurallar
- **architect.instructions.md**: Mimari planlama ve tasarım
- **developer.instructions.md**: Temel geliştirme kuralları
- **security.instructions.md**: Güvenlik standartları
- **qa.instructions.md**: Test ve kalite assurance

### Teknoloji Spesifik
- **dotnet-backend.instructions.md**: .NET WPF uygulamaları
- **dotnet-maui.instructions.md**: .NET MAUI cross-platform uygulamaları
- **python-fastapi.instructions.md**: Python backend servisler
- **node-backend.instructions.md**: Node.js backend servisler
- **go-webapi.instructions.md**: Go Web API servisler
- **web-typescript-react.instructions.md**: Frontend uygulamalar
- **android-kotlin.instructions.md**: Android native uygulamalar
- **ios-swift.instructions.md**: iOS native uygulamalar
- **flutter.instructions.md**: Cross-platform mobile uygulamalar
- **prisma.instructions.md**: Prisma ORM veritabanı katmanı
- **ai-integration.instructions.md**: AI servis entegrasyonu
- **ux.instructions.md**: Kullanıcı deneyimi tasarımı

### Operasyonel
- **devops.instructions.md**: CI/CD ve deployment
- **performance-optimization.instructions.md**: Performans optimizasyonu
- **error-handling.instructions.md**: Hata yönetimi
- **logging-standards.instructions.md**: Log standartları

## 🛠️ Kullanım

### Yeni Proje Başlatma
1. Bu şablonu fork et veya kopyala
2. Proje ismine uygun olarak rename et
3. `copilot-instructions.md` dosyasını incele
4. İlgili instruction dosyalarını oku
5. Geliştirmeye başla

### Mevcut Projeye Entegrasyon
1. `.github/` klasörünü kopyala
2. Instruction dosyalarını proje ihtiyaçlarına göre düzenle
3. Existing workflow'ları güncelle
4. Team'e kuralları paylaş

## 🔄 Registry ve Context Yönetimi

Proje tutarlılığı için:

### Registry Dosyaları (Zorunlu)
- `docs/registry/identifiers.json` - Modüller, export'lar, değişkenler
- `docs/registry/endpoints.json` - API contract'ları 
- `docs/registry/schemas.json` - Veri modelleri

### Context Dosyaları
- `.mds/context/current-context.md` - Aktif teknik özet
- `.mds/context/history/` - Session geçmişi

## 📝 Dil Politikası

- **Kod ve identifier'lar**: İngilizce
- **Kod içi yorumlar ve loglar**: Türkçe  
- **UI metinleri**: i18n ile İngilizce/Türkçe
- **Dokümantasyon**: Türkçe (kullanıcı), İngilizce (teknik)

## ⚡ Hızlı Başlangıç

```bash
# Repo'yu klonla
git clone <repo-url>
cd <proje-adi>

# Bağımlılıkları yükle
npm install          # Frontend için
pip install -r requirements.txt  # Backend için

# Geliştirmeye başla
git checkout -b feature/ilk-ozellik
```

## 🤝 Katkıda Bulunma

1. Feature branch oluştur
2. Değişiklikleri yap
3. Test yaz
4. Dokümante et
5. Pull request aç

## 📄 Lisans

MIT License - Detaylar için LICENSE dosyasına bakın.

---

**Not**: Bu şablon sürekli olarak güncellenmektedir. En son standartlar ve en iyi pratikler için instruction dosyalarını düzenli olarak kontrol edin.