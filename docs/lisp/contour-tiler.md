### CTILE70 — Kontur Çizgilerini 70x70 Karelere Bölme

**Amaç**: Seçilen kontur çizgilerini 70x70 cm (veya verilen ölçü) karo alanlarına böler, her karoyu ayrı bir blok olarak XCLIP'ler ve satır/sütun dizilimiyle yerleştirir. CNC lazer kesim için her karo bağımsız parçadır.

### Komutlar
- **CTILE70**: Konturları karo bloklarına böler ve layout gibi yan yana dizer.

### Kullanım
1. `APPLOAD` ile `src/lisp/contour-tiler.lsp` yükleyin.
2. `CTILE70` yazın ve konturları (LWPOLYLINE/POLYLINE/SPLINE/LINE/ARC) seçin.
3. Karo genişlik/yükseklik (cm), karo arası boşluk ve sütun sayısını girin.
4. Program, kaynak bir blok oluşturur, her karo için XCLIP sınırı uygular ve karoları yan yana dizer. Karo etiketleri sol-alt köşe yakınında eklenir.

### Notlar
- Kaynak seçiminiz bozulmaz, blok oluşturma Retain ile yapılır.
- XCLIP dikdörtgenleri dünya koordinatlarındadır; çizimin dönüşümlü olması durumunda WCS'de çalışmanız önerilir.
- Sütun sayısı dizilişi yatay paketlemeyi belirler; satırlar otomatik ilerler.


