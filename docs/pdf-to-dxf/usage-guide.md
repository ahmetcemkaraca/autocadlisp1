# PDF to DXF Converter - Kullanım Kılavuzu

Bu kılavuz, PDF to DXF Converter kütüphanesinin detaylı kullanımını açıklar.

## İçindekiler

1. [Temel Kullanım](#temel-kullanım)
2. [Konfigürasyon](#konfigürasyon)
3. [Gelişmiş Özellikler](#gelişmiş-özellikler)
4. [Sorun Giderme](#sorun-giderme)
5. [En İyi Uygulamalar](#en-iyi-uygulamalar)

## Temel Kullanım

### Komut Satırından

```bash
# Basit dönüştürme
python pdf_to_dxf.py input.pdf output.dxf

# Konfigürasyon ile
python pdf_to_dxf.py --config my_config.json input.pdf output.dxf

# Detaylı çıktı
python pdf_to_dxf.py --verbose input.pdf output.dxf
```

### Python Kodu

```python
from src.pdf_to_dxf import PDFToDXFConverter, ConversionConfig

# Varsayılan konfigürasyon
converter = PDFToDXFConverter()
success = converter.convert_pdf_to_dxf("input.pdf", "output.dxf")
```

## Konfigürasyon

### Konfigürasyon Dosyası Oluşturma

```bash
python pdf_to_dxf.py --create-config config.json
```

### Konfigürasyon Parametreleri

```json
{
  "dxf_version": "R2018",
  "units": "mm",
  "precision": 6,
  "min_line_length": 0.1,
  "max_line_width": 5.0,
  "curve_tolerance": 0.01,
  "create_layers": true,
  "layer_prefix": "PDF_",
  "auto_scale": false,
  "preserve_scale": true
}
```

### DXF Sürümleri

| Sürüm | Açıklama | Uyumluluk |
|-------|----------|-----------|
| R12   | En uyumlu | Eski AutoCAD sürümleri |
| R2010 | Orta düzey | AutoCAD 2010+ |
| R2018 | Modern | AutoCAD 2018+ |
| R2020 | En yeni | AutoCAD 2020+ |

### Birim Sistemleri

- `mm`: Milimetre (varsayılan)
- `cm`: Santimetre
- `m`: Metre
- `in`: İnç

## Gelişmiş Özellikler

### Toplu İşleme

```python
from pathlib import Path

pdf_files = list(Path("input").glob("*.pdf"))
converter = PDFToDXFConverter()

for pdf_file in pdf_files:
    output_file = f"output/{pdf_file.stem}.dxf"
    converter.convert_pdf_to_dxf(str(pdf_file), output_file)
```

### Analiz ve Raporlama

```python
from examples.advanced_usage import AdvancedPDFToDXFConverter

advanced_converter = AdvancedPDFToDXFConverter()
analysis = advanced_converter.convert_with_analysis("input.pdf", "output.dxf")

print(f"Parse edilen nesneler: {analysis['parse_stats']['total_objects']}")
print(f"Dönüştürülen nesneler: {analysis['conversion_stats']['total_dxf_objects']}")
```

### Özel Konfigürasyonlar

#### Yüksek Kalite

```python
config = ConversionConfig(
    dxf_version="R2020",
    precision=8,
    min_line_length=0.01,
    curve_tolerance=0.001,
    create_layers=True
)
```

#### Performans Odaklı

```python
config = ConversionConfig(
    dxf_version="R12",
    precision=3,
    min_line_length=1.0,
    create_layers=False
)
```

#### Mimari Çizimler

```python
config = ConversionConfig(
    dxf_version="R2018",
    units="mm",
    create_layers=True,
    layer_prefix="ARCH_",
    preserve_scale=True
)
```

## Sorun Giderme

### Yaygın Hatalar

1. **"PDF dosyası bulunamadı"**
   - Dosya yolunu kontrol edin
   - Dosya izinlerini kontrol edin

2. **"Geometri çıkarılamıyor"**
   - PDF'in vektör grafikleri içerdiğini kontrol edin
   - Tarama PDF'leri desteklenmez

3. **"DXF dosyası oluşturulamıyor"**
   - Çıkış dizininin yazılabilir olduğunu kontrol edin
   - Yeterli disk alanı olduğunu kontrol edin

### Debug Modu

```bash
python pdf_to_dxf.py --verbose input.pdf output.dxf
```

### Log Dosyaları

Program `pdf_to_dxf.log` dosyasında detaylı log bilgileri tutar.

## En İyi Uygulamalar

### PDF Hazırlama

1. Vektör grafikleri içeren PDF'ler kullanın
2. Tarama (raster) PDF'lerden kaçının
3. PDF'leri optimize edin

### Konfigürasyon Seçimi

1. **Küçük dosyalar**: Yüksek kalite konfigürasyonu
2. **Büyük dosyalar**: Performans odaklı konfigürasyon
3. **Mimari çizimler**: Özel mimari konfigürasyonu

### Dosya Organizasyonu

```
project/
├── input/          # PDF dosyaları
├── output/         # DXF dosyaları
├── configs/        # Konfigürasyon dosyaları
└── logs/          # Log dosyaları
```

### Performans Optimizasyonu

1. Büyük dosyalar için `auto_scale=True` kullanın
2. Gereksiz katmanlar için `create_layers=False` kullanın
3. Düşük hassasiyet için `precision=3` kullanın

## Örnek Senaryolar

### Teknik Çizim Dönüştürme

```python
config = ConversionConfig(
    dxf_version="R2018",
    units="mm",
    precision=6,
    create_layers=True,
    layer_prefix="TECH_"
)
converter = PDFToDXFConverter(config)
```

### Mimari Plan Dönüştürme

```python
config = ConversionConfig(
    dxf_version="R2020",
    units="mm",
    precision=8,
    create_layers=True,
    layer_prefix="ARCH_",
    preserve_scale=True
)
converter = PDFToDXFConverter(config)
```

### Toplu Dönüştürme

```python
import os
from pathlib import Path

def batch_convert(input_dir, output_dir):
    converter = PDFToDXFConverter()
    pdf_files = list(Path(input_dir).glob("*.pdf"))
    
    for pdf_file in pdf_files:
        output_file = Path(output_dir) / f"{pdf_file.stem}.dxf"
        converter.convert_pdf_to_dxf(str(pdf_file), str(output_file))
        print(f"Dönüştürüldü: {pdf_file.name} -> {output_file.name}")

batch_convert("input", "output")
```

## API Referansı

### PDFToDXFConverter

```python
class PDFToDXFConverter:
    def __init__(self, config: ConversionConfig = None)
    def convert_pdf_to_dxf(self, input_path: str, output_path: str) -> bool
```

### ConversionConfig

```python
class ConversionConfig:
    dxf_version: str = "R2010"
    units: str = "mm"
    precision: int = 6
    min_line_length: float = 0.1
    max_line_width: float = 10.0
    curve_tolerance: float = 0.01
    create_layers: bool = True
    layer_prefix: str = "PDF_LAYER_"
    auto_scale: bool = False
    preserve_scale: bool = True
```

## Destek

Sorularınız için:
- GitHub Issues açın
- Dokümantasyonu inceleyin
- Örnekleri çalıştırın

