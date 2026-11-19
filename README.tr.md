# AutoCAD için PolylineTools

[![CI](https://github.com/ahmetcemkaraca/autocadlisp/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmetcemkaraca/autocadlisp/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

[English](README.md) | Türkçe

AutoCAD'de sıkıcı olan altı işi yapan küçük bir AutoLISP araç seti:

- polyline'ları (yay segmentleri dahil) pürüzsüz spline eğrilere dönüştürür,
- polyline'ları polyline olarak kalarak yumuşatır veya curve-fit yapar,
- polyline'ları uç uca birleştirir (tek çift ya da tüm seçim) ve yay segmentlerini korur,
- gereksiz köşe noktalarını tolerans dahilinde silerek polyline'ları sadeleştirir,
- kontur çizimlerini XCLIP'li karolara bölüp ızgara olarak dizer (büyük modelleri parça parça kesmek için),
- numaralandırma yapar: tıkladığınız noktalara `1, 2, 3 ...` metinlerini yerleştirir.

Her şey **tek dosya** olarak gelir: [`dist/polyline-tools.lsp`](dist/polyline-tools.lsp). Bağımlılık ve kurulum programı yoktur.
AutoCAD'de ve Visual LISP çalıştıran diğer CAD programlarında (ör. BricsCAD) çalışır.

## Kurulum

1. [`polyline-tools.lsp`](dist/polyline-tools.lsp) dosyasını indirin (veya depoyu klonlayın).
2. AutoCAD'de `APPLOAD` komutunu çalıştırın, dosyayı seçin ve **Load**'a basın.
   Her oturumda yüklenmesi için aynı pencerede **Startup Suite**'e ekleyin.
3. Komutları görmek için `PLXHELP` yazın.

Komut satırından da yükleyebilirsiniz: `(load "C:/yol/polyline-tools.lsp")`.

## Komutlar

| Komut | Ne yapar |
| --- | --- |
| `PL2CURVE` | Seçilen her polyline'ı köşelerinden geçen bir spline ile değiştirir. Yay segmentleri (bulge) her 10 derecede örneklenir, böylece yaylar yay gibi kalır. Layer, renk, çizgi tipi ve çizgi kalınlığı korunur. Kapalı polyline'lar kapalı spline olur. |
| `SMOOTHPL` | Seçilen polyline'ları `PEDIT` ile spline-fit yapar. Polyline olarak kalırlar. |
| `FITCURVE` | Seçilen polyline'ları `PEDIT` ile curve-fit yapar. Eğri her köşeden geçer. |
| `JOINPL` | Uçları değen iki polyline'ı birleştirir. Gerekirse biri ters çevrilir; yay segmentleri ve ilk polyline'ın layer/rengi korunur. |
| `AUTOJOINPL` | Seçimdeki birbirine değen tüm polyline zincirlerini birleştirir. Başladığı yerde biten zincirler kapalı polyline olur. |
| `SETTOL` | İki uç noktanın "değiyor" sayılacağı mesafeyi ayarlar (varsayılan `0.001`). |
| `SIMPLIFYPL` | Polyline'lardaki gereksiz köşeleri Douglas-Peucker algoritmasıyla siler. Önce tolerans (varsayılan `0.5`, hatırlanır), sonra polyline'lar sorulur. Yay segmentlerine dokunulmaz; kapalı polyline'lar kapalı kalır; layer, renk, çizgi tipi ve kalınlığı korunur. |
| `CTILE70` | Seçilen kontur nesnelerini (`LWPOLYLINE`, `POLYLINE`, `SPLINE`, `LINE`, `ARC`) karo ızgarasına böler (varsayılan 70 x 70 çizim birimi). Seçime değen her karo, tek bir kaynak bloğun XCLIP'li bir eklemesi olur, `Ti-j` olarak etiketlenir ve çizimin sağında satırlar halinde dizilir. Orijinal nesneler yerinde kalır. World UCS'de çalışır, sonra UCS'nizi geri yükler. |
| `NUMBER` | Başlangıç sayısı, bitiş sayısı ve metin yüksekliğini sorar; her tıklamada bir sayı yerleştirir (ortalı, geçerli UCS düzleminde). `Enter` veya `ESC` durdurur. |
| `PLXHELP` | Komutları listeler. |
| `PLXLANG` | Mesajları İngilizce / Türkçe arasında değiştirir. |

Her komut tek bir undo grubu içinde çalışır: tek bir `U` tüm işlemi geri alır ve `ESC`'ye bassanız bile sistem değişkenleri eski haline döner.

### Örnek

```text
Command: PL2CURVE
Polyline'ları seçin:  [nesneleri seç]
3 polyline spline'a dönüştürüldü.

Command: AUTOJOINPL
Polyline'ları seçin:  [nesneleri seç]
7 polyline, 2 yeni polyline olarak birleştirildi.
```

### Bilmekte fayda var

- `JOINPL` ve `AUTOJOINPL`, aynı düzlemdeki açık 2B polyline'larla (`LWPOLYLINE` ve 2B `POLYLINE`) çalışır. Sonuç `LWPOLYLINE` olarak yazılır.
- `SIMPLIFYPL` düz (2B) polyline'larla çalışır; `CTILE70` çizimde `PLX_TILES_n` adlı bir blok bırakır (karolar bunu kullanır - karoları sildikten sonra `PURGE` yapın). da kabul eder; 3B ağlar (mesh) atlanır.
- `NUMBER` kısa ve genel bir komut adıdır. Başka bir rutininiz de `NUMBER` ise `src/lisp/50-number.lsp` içindeki `c:number` adını değiştirin.
- `PL2CURVE` orijinal nesneleri değiştirir. Geri almak için `U` kullanın.

## Depo yapısı

```text
.
├── dist/polyline-tools.lsp   Üretilen tek dosyalık sürüm - kullanıcıların yüklediği dosya
├── src/lisp/                 Kaynak modüller, dosya adı sırasıyla birleştirilir
├── scripts/                  build.ps1 (paketleme) ve lint.ps1 (statik kontroller)
├── docs/                     Mimari notları ve manuel test planı
└── .github/                  CI, sürüm iş akışı, issue ve PR şablonları
```

## Geliştirme

PowerShell 7 (`pwsh`) veya Windows PowerShell 5.1 gerekir. AutoCAD yalnızca manuel testler için gereklidir.

```powershell
./scripts/lint.ps1      # statik kontroller
./scripts/build.ps1     # dist/polyline-tools.lsp dosyasını yeniden üret
```

CI aynı iki adımı çalıştırır ve `dist/polyline-tools.lsp` güncel değilse başarısız olur.
Ayrıntılar: [CONTRIBUTING.md](CONTRIBUTING.md), [docs/architecture.md](docs/architecture.md), [docs/testing.md](docs/testing.md).

## Lisans

[GNU GPL v3.0](LICENSE).
