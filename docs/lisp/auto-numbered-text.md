# Otomatik Numaralı Text Yazma

## Açıklama

Bu LISP programı, 1'den kullanıcının belirlediği sayıya kadar otomatik boyutlu text objeleri oluşturur. Her sayı için ayrı nokta seçimi yaparak, sayıları istediğiniz yerlere yerleştirebilirsiniz. Text boyutları, yazılacak sayı miktarına göre otomatik olarak ayarlanır.

## Özellikler

- **Otomatik Boyutlandırma**: Sayı miktarına göre text yüksekliği otomatik hesaplanır
- **Ayrı Yerleştirme**: Her sayı için ayrı nokta seçimi yapabilirsiniz
- **Esnek Konumlandırma**: Sayıları istediğiniz yerlere yerleştirebilirsiniz
- **Ayarlanabilir Parametreler**: Text yüksekliği ve satır aralığı ayarlanabilir
- **Hata Kontrolü**: Geçersiz girişler için doğrulama
- **Kullanıcı Dostu**: Türkçe arayüz ve açıklamalar

## Komutlar

### AUTOTEXT
Ana komut. 1'den istenen sayıya kadar text yazar.

**Kullanım:**
```
AUTOTEXT
```

**Adımlar:**
1. Program mevcut ayarları gösterir
2. Kaça kadar sayı yazılacağını sorar (1'den başlayarak)
3. Her sayı için ayrı ayrı nokta seçmenizi ister
4. Otomatik hesaplanan text yüksekliğini gösterir
5. Her sayıyı seçtiğiniz noktaya yerleştirir

### SETTEXTHEIGHT
Text yüksekliğini ayarlar.

**Kullanım:**
```
SETTEXTHEIGHT
```

### SETTEXTSPACING
Satır aralığı çarpanını ayarlar.

**Kullanım:**
```
SETTEXTSPACING
```

### SHOWAUTOTEXTSETTINGS
Mevcut ayarları gösterir.

**Kullanım:**
```
SHOWAUTOTEXTSETTINGS
```

## Otomatik Boyutlandırma

Program, yazılacak sayı miktarına göre text yüksekliğini otomatik olarak ayarlar:

- **1-10 arası**: Normal boyut (100%)
- **11-50 arası**: %80 boyut
- **51-100 arası**: %60 boyut
- **101-500 arası**: %40 boyut
- **500+ arası**: %30 boyut

## Global Değişkenler

- `*AUTO-TEXT-HEIGHT*`: Varsayılan text yüksekliği (2.5)
- `*AUTO-TEXT-SPACING*`: Satır aralığı çarpanı (1.0)

## Örnek Kullanım

1. AutoCAD'de `AUTOTEXT` komutunu çalıştırın
2. "Kaça kadar sayı yazılacak?" sorusuna `5` yazın
3. "1 sayısının yerleştirileceği noktayı seçin" - istediğiniz yeri seçin
4. "2 sayısının yerleştirileceği noktayı seçin" - başka bir yeri seçin
5. "3 sayısının yerleştirileceği noktayı seçin" - farklı bir yeri seçin
6. Bu şekilde 5'e kadar devam edin
7. Her sayı seçtiğiniz noktaya yerleştirilir

## Teknik Detaylar

- Text objeleri `TEXT` entity tipinde oluşturulur
- Her text objesi ayrı bir entity olarak oluşturulur
- Her sayı için ayrı nokta seçimi yapılır
- Text yüksekliği sayı miktarına göre otomatik hesaplanır
- Maksimum 10,000 sayıya kadar destekler
- İptal etmek için ESC tuşuna basabilirsiniz

## Hata Durumları

- Geçersiz sayı girişi: Pozitif sayı girin
- Geçersiz nokta seçimi: Geçerli bir nokta seçin
- Çok büyük sayı: 1-10,000 arası değer girin

## Sürüm

- **Versiyon**: 1.0.0
- **Tarih**: 2025-01-27
- **Yazar**: ArchBuilder.AI
