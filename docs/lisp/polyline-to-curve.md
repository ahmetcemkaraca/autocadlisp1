# Polyline to Curve LISP Dokümantasyonu

## Genel Bakış

Bu LISP kodu AutoCAD'de mevcut polyline çizgilerini curved (eğri) çizgiler haline getirmek ve polyline'ları birleştirmek için yazılmıştır. Kod beş farklı yaklaşım sunar:

1. **PL2CURVE** - Polyline'ları spline eğrilerine dönüştürür
2. **SMOOTHPL** - Polyline'ları smooth (yumuşak) yapar  
3. **FITCURVE** - Polyline'ları fit curve (uygun eğri) yapar
4. **JOINPL** - İki polyline'ı uç uca birleştirir
5. **AUTOJOINPL** - Seçilen polyline'lar arasında uç uca gelenleri otomatik birleştirir
6. **SETTOL** - Birleştirme toleransını ayarlar

## Kurulum

1. `polyline-to-curve.lsp` dosyasını AutoCAD'e yükleyin:
   ```
   (load "polyline-to-curve.lsp")
   ```

2. Alternatif olarak AutoCAD'de APPLOAD komutu ile yükleyebilirsiniz:
   - Komut satırında `APPLOAD` yazın
   - `polyline-to-curve.lsp` dosyasını seçin
   - Load butonuna tıklayın

## Kullanım

### PL2CURVE Komutu

Bu komut polyline'ları tamamen yeni spline eğrilerine dönüştürür:

```
Komut: PL2CURVE
```

**Nasıl Çalışır:**
- Komut çalıştırıldığında polyline seçmenizi ister
- Seçilen her polyline'ın noktalarını ve bulge değerlerini analiz eder  
- Orijinal polyline'ın geometrisini koruyarak smooth bir spline oluşturur
- Orijinal polyline'ı siler ve yerine spline koyar

**Avantajları:**
- En smooth ve estetik sonuç verir
- Karmaşık eğrileri mükemmel şekilde işler
- Bulge değerlerini spline'a dönüştürür

### SMOOTHPL Komutu

AutoCAD'in dahili smooth özelliğini kullanır:

```
Komut: SMOOTHPL
```

**Nasıl Çalışır:**
- Seçilen polyline'ları AutoCAD'in PEDIT komutunun Smooth seçeneği ile işler
- Orijinal polyline'ı korur ama smooth yapar

**Avantajları:**
- Hızlı ve güvenilir
- AutoCAD'in standart özelliğini kullanır
- Polyline özelliklerini korur

### JOINPL Komutu

İki polyline'ı uç uca birleştirir:

```
Komut: JOINPL
```

**Nasıl Çalışır:**
- İlk polyline'ı seçmenizi ister
- İkinci polyline'ı seçmenizi ister
- Her iki polyline'ın uç noktalarını kontrol eder
- Tolerans dahilinde (0.001 birim) uç uca gelenleri birleştirir
- Gerektiğinde polyline'ları ters çevirir
- Orijinal polyline'ları siler ve tek polyline oluşturur

**Avantajları:**
- Manuel kontrol imkanı
- Hassas birleştirme
- Layer ve renk özelliklerini korur
- Farklı birleştirme kombinasyonlarını destekler

### AUTOJOINPL Komutu

Seçilen polyline'lar arasında uç uca gelenleri otomatik birleştirir:

```
Komut: AUTOJOINPL
```

**Nasıl Çalışır:**
- Birden çok polyline seçmenizi ister
- Tüm polyline çiftlerini kontrol eder
- Uç uca gelen polyline'ları otomatik birleştirir
- İşlem sonunda kaç çift birleştirildiğini rapor eder

**Avantajları:**
- Toplu işlem yapabilir
- Zaman tasarrufu sağlar
- Karmaşık çizimler için ideal
- Otomatik birleştirme algoritması

### SETTOL Komutu

Polyline birleştirme toleransını ayarlar:

```
Komut: SETTOL
```

**Nasıl Çalışır:**
- Mevcut tolerans değerini gösterir
- Yeni tolerans değeri girmenizi ister
- Tolerans değeri global olarak kaydedilir
- Sonraki JOINPL ve AUTOJOINPL işlemlerinde kullanılır

**Avantajları:**
- Hassasiyet kontrolü
- Farklı ölçeklerde çalışma imkanı
- Kullanıcı tercihine göre ayarlama
- Session boyunca tolerans hatırlama

### FITCURVE Komutu

AutoCAD'in fit curve özelliğini kullanır:

```
Komut: FITCURVE
```

**Nasıl Çalışır:**
- Seçilen polyline'ları AutoCAD'in PEDIT komutunun Fit seçeneği ile işler
- Tüm vertex noktalarından geçen bir eğri oluşturur

**Avantajları:**
- Vertex noktalarından tam geçer
- Kontrol edilebilir eğri oluşturur
- Hızlı işlem yapar

## Kod Yapısı

### Ana Fonksiyonlar

**Eğri Dönüştürme:**
- `c:pl2curve` - Ana dönüştürme komutu
- `get-polyline-points` - Polyline noktalarını çıkarır
- `get-polyline-bulges` - Bulge değerlerini çıkarır  
- `create-curved-polyline` - Yeni spline oluşturur
- `calculate-arc-points` - Arc noktalarını hesaplar
- `calculate-arc-center` - Arc merkezini hesaplar

**Polyline Birleştirme:**
- `c:joinpl` - İki polyline'ı manuel birleştirme
- `c:autojoinpl` - Otomatik toplu birleştirme
- `create-joined-polyline` - Birleştirilmiş polyline oluşturur
- `join-two-polylines` - İki polyline birleştirme algoritması

### Desteklenen Polyline Tipleri

- LWPOLYLINE (Lightweight Polyline)
- POLYLINE (Legacy Polyline)
- Kapalı ve açık polyline'lar
- Bulge değeri olan polyline'lar

## Hata Yönetimi

Kod aşağıdaki durumları kontrol eder:

- Geçersiz polyline seçimi
- Boş seçim setleri
- Nokta hesaplama hataları
- Spline oluşturma başarısızlıkları

Her hata durumunda uygun mesaj gösterilir.

## Performans Notları

- Büyük polyline'lar için işlem süresi artabilir
- PL2CURVE komutu en detaylı ama en yavaş seçenektir
- SMOOTHPL ve FITCURVE daha hızlı alternatiflerdir

## Örnekler

### Basit Kullanım

```
Komut: PL2CURVE
Polyline'ları seçin (curved çizgiler haline getirilecek): [polyline'ları seç]
Polyline 1 curved çizgiye dönüştürüldü.
Polyline 2 curved çizgiye dönüştürüldü.
Toplam 2 polyline işlendi.
```

### Smooth İşlemi

```
Komut: SMOOTHPL  
Smooth yapılacak polyline'ları seçin: [polyline'ları seç]
Polyline'lar smooth yapıldı.
```

### Polyline Birleştirme

```
Komut: JOINPL
Birleştirilecek ilk polyline'ı seçin: [ilk polyline'ı seç]
Birleştirilecek ikinci polyline'ı seçin: [ikinci polyline'ı seç]
Polyline'lar birleştirildi (end1->start2).
Birleştirme işlemi tamamlandı.
```

### Otomatik Birleştirme

```
Komut: AUTOJOINPL
Birleştirilecek polyline'ları seçin: [birden çok polyline seç]
Polyline çifti 1 birleştirildi.
Polyline çifti 2 birleştirildi.
Toplam 2 polyline çifti birleştirildi.
```

### Tolerans Ayarlama

```
Komut: SETTOL
Mevcut tolerans: 0.001000
Yeni tolerans değeri: 0.01
Tolerans 0.010000 olarak ayarlandı.
```

## Sık Karşılaşılan Problemler

**Problem:** Polyline seçilmiyor  
**Çözüm:** Sadece LWPOLYLINE ve POLYLINE türündeki çizgileri seçin

**Problem:** Eğri düzgün oluşmuyor  
**Çözüm:** PL2CURVE yerine SMOOTHPL komutunu deneyin

**Problem:** İşlem çok yavaş  
**Çözüm:** Az sayıda polyline seçin veya FITCURVE kullanın

**Problem:** Polyline'lar birleşmiyor  
**Çözüm:** SETTOL komutu ile toleransı artırın veya uç noktaların yakınlığını kontrol edin

**Problem:** Renk hatası alıyorum  
**Çözüm:** Kod otomatik olarak geçersiz renkleri düzeltir, tekrar deneyin

**Problem:** Yanlış polyline'lar birleşiyor  
**Çözüm:** JOINPL ile manuel seçim yapın, AUTOJOINPL yerine

**Problem:** Birleştirme sonrası özellikler kaybolur  
**Çözüm:** Kod otomatik olarak layer ve renk özelliklerini korur

## Genişletme İmkanları

Bu kod aşağıdaki özelliklerle genişletilebilir:

- Eğri kalitesi ayarları
- Batch processing seçenekleri  
- Farklı spline türleri desteği
- Geri alma (undo) fonksiyonu
- Layer ve renk koruma

## Lisans ve Destek

Bu kod ArchBuilder.AI tarafından geliştirilmiştir ve açık kaynak olarak sunulmaktadır.