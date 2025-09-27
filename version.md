# Version History

## v1.0.0 - AutoCAD LISP Polyline to Curve Dönüştürücü
**Tarih:** 2025-09-26 14:09:49

### Yeni Özellikler
- AutoCAD LISP polyline-to-curve.lsp modülü oluşturuldu
- PL2CURVE komutu: Polyline'ları spline eğrilerine dönüştürür
- SMOOTHPL komutu: Polyline'ları smooth yapar
- FITCURVE komutu: Polyline'ları fit curve yapar
- Kapsamlı hata yönetimi ve kullanıcı geri bildirimi
- LWPOLYLINE ve POLYLINE türleri için destek
- Bulge değeri olan polyline'lar için arc hesaplama algoritması

### Teknik Özellikler
- DXF kod analizi ile polyline geometrisi okuma
- Spline interpolasyon ve arc hesaplama fonksiyonları
- Türkçe kullanıcı mesajları ve dokümantasyon
- Registry ve context yönetimi entegrasyonu

### Dokümantasyon
- Detaylı kullanım kılavuzu (docs/lisp/polyline-to-curve.md)
- Kod yapısı ve fonksiyon referansları
- Kurulum ve yapılandırma rehberi
- Hata giderme ve performans notları

## v1.1.0 - Polyline Birleştirme Özelliği Eklendi
**Tarih:** 2025-09-26 14:22:10

### Yeni Özellikler
- **JOINPL komutu**: İki polyline'ı manuel uç uca birleştirme
- **AUTOJOINPL komutu**: Seçilen polyline'lar arasında otomatik birleştirme
- Akıllı uç nokta algılama sistemi (0.001 birim tolerans)
- Otomatik polyline yön belirleme ve ters çevirme
- Layer ve renk özelliklerini koruma

### Teknik İyileştirmeler
- `create-joined-polyline` - Birleştirilmiş polyline oluşturma fonksiyonu
- `join-two-polylines` - İki polyline birleştirme algoritması
- Dört farklı birleştirme senaryosu desteği:
  - end1->start2 (doğrudan birleştirme)
  - end1->end2 (ikinci polyline ters çevrilir)
  - start1->start2 (ilk polyline ters çevrilir)
  - start1->end2 (polyline sırası değişir)

### Kullanım Senaryoları
- Kesik çizgilerin birleştirilmesi
- Karmaşık çizimlerde polyline temizleme
- Toplu polyline birleştirme işlemleri
- CAD dosya optimizasyonu

### Dokümantasyon Güncellemeleri
- JOINPL ve AUTOJOINPL komutları için detaylı kullanım örnekleri
- Birleştirme algoritması açıklamaları
- Hata senaryoları ve çözümleri
- Performans optimizasyon önerileri

## v1.1.1 - Hata Düzeltmeleri ve İyileştirmeler
**Tarih:** 2025-09-26 14:38:09

### Hata Düzeltmeleri
- **Renk hatası**: AutoCAD'de geçersiz renk numarası hatası düzeltildi
- **Entity modification**: COMMAND yerine ENTMOD kullanılarak daha güvenli özellik ayarlama
- **Tolerans kontrolü**: Geçersiz renk değerleri için otomatik düzeltme
- **BYLAYER renk**: Renk 256 için özel işlem eklendi

### Yeni Özellikler
- **SETTOL komutu**: Birleştirme toleransını kullanıcı ayarlayabilir
- **Global tolerans**: `*JOIN-TOLERANCE*` değişkeni ile tolerans hatırlama
- **Performans uyarısı**: 50+ polyline seçildiğinde kullanıcı onayı
- **Güvenli işlem**: Entity data ile doğrudan özellik ayarlama

### Teknik İyileştirmeler
- Entity modification yerine ENTMOD/ENTUPD kullanımı
- Renk değeri validasyonu ve otomatik düzeltme
- Global değişken yönetimi
- Kullanıcı etkileşimi iyileştirmeleri

### Kullanıcı Deneyimi
- Daha açıklayıcı hata mesajları
- Tolerans ayarlama kolaylığı
- Büyük dosyalar için uyarı sistemi
- Session boyunca ayar hatırlama

## v1.2.0 - 2D Polyline Basitleştirme (Douglas–Peucker)
**Tarih:** 2025-09-26 15:05:00
-
## v1.3.0 - Konturları 70x70 Karo Bloklarına Bölme
**Tarih:** 2025-09-26 15:25:00

### Yeni Özellikler
- `CTILE70` komutu: Konturları 70x70 (veya verilen) karelere böler
- Her karoyu XCLIP’li ayrı bir blok yerleşimi olarak dizer

### Kullanım
- `APPLOAD` → `contour-tiler.lsp`, komut `CTILE70`
- Genişlik/yükseklik, boşluk, sütun sayısı parametreleri

### Notlar
- Kaynak seçim korunur (Retain), WCS önerilir
- Karo etiketleri otomatik eklenir (Tcol-row)

### Yeni Özellikler
- `SIMPLIFYPL` komutu: 2D LWPOLYLINE vertex sayısını tolerans ile azaltır
- `SETSIMP` komutu: Global `*SIMPLIFY-TOL*` toleransını ayarlar

### Teknik Ayrıntılar
- Douglas–Peucker özyinelemeli algoritma
- Kapalı polyline desteği; kapanış özelliğini korur
- Referans polyline özelliklerinin yeni nesneye aktarımı

### Dokümantasyon
- `docs/lisp/polyline-simplify.md` kullanım kılavuzu
- `README.md` güncellendi

## v1.4.0 - Otomatik Numaralı Text Yazma
**Tarih:** 2025-01-27 12:00:00

### Yeni Özellikler
- **AUTOTEXT komutu**: 1'den istenen sayıya kadar otomatik boyutlu text yazar
- **Otomatik boyutlandırma**: Sayı miktarına göre text yüksekliği otomatik hesaplanır
- **Esnek yerleştirme**: Kullanıcı text başlangıç noktasını seçebilir
- **Ayarlanabilir parametreler**: Text yüksekliği ve satır aralığı ayarlanabilir

### Komutlar
- `AUTOTEXT`: Ana komut - 1'den N'e kadar text yazar
- `SETTEXTHEIGHT`: Text yüksekliğini ayarlar
- `SETTEXTSPACING`: Satır aralığı çarpanını ayarlar
- `SHOWAUTOTEXTSETTINGS`: Mevcut ayarları gösterir

### Otomatik Boyutlandırma Algoritması
- **1-10 arası**: Normal boyut (100%)
- **11-50 arası**: %80 boyut
- **51-100 arası**: %60 boyut
- **101-500 arası**: %40 boyut
- **500+ arası**: %30 boyut

### Teknik Özellikler
- Maksimum 10,000 sayıya kadar destek
- Hata kontrolü ve doğrulama
- Global değişken yönetimi (`*AUTO-TEXT-HEIGHT*`, `*AUTO-TEXT-SPACING*`)
- Türkçe kullanıcı arayüzü

### Dokümantasyon
- `docs/lisp/auto-numbered-text.md` detaylı kullanım kılavuzu
- Registry güncellemeleri (`docs/registry/identifiers.json`)
- Kod yapısı ve fonksiyon referansları