### SIMPLIFYPL — 2D Polyline Basitleştirme

**Amaç**: 2D LWPOLYLINE nesnelerindeki vertex sayısını, şekli fark edilir derecede bozmadan azaltır. Douglas–Peucker algoritması kullanır.

### Komutlar
- **SIMPLIFYPL**: Seçili 2D LWPOLYLINE nesnelerini verilen toleransla basitleştirir.
- **SETSIMP**: Basitleştirme toleransını ayarlar (varsayılan: 0.5 çizim birimi).

### Kullanım
1. AutoCAD içine `src/lisp/polyline-simplify.lsp` dosyasını `APPLOAD` ile yükleyin.
2. Komut satırına `SIMPLIFYPL` yazın.
3. Tolerans girin (Enter ile mevcut değeri kullanabilirsiniz).
4. Basitleştirilecek LWPOLYLINE nesnelerini seçin.

### Notlar
- Kapalı polyline'larda kapalı olma özelliği korunur.
- Referans polyline'ın layer, color, linetype ve lineweight özellikleri yeni nesneye aktarılır.
- Tolerans yükseldikçe daha az vertex kalır; çok yüksek tolerans şekli bozabilir.


