# PDF to DXF Converter

PDF dosyalarındaki AutoCAD çizimlerini DXF formatına dönüştüren Python kütüphanesi.

## Özellikler

- 📄 PDF dosyalarından vektör grafikleri çıkarma
- 🔄 Geometrik şekilleri DXF formatına dönüştürme
- 📐 Çizgiler, eğriler, dikdörtgenler ve daireler desteği
- 🎨 Renk ve katman yönetimi
- ⚙️ Esnek konfigürasyon seçenekleri
- 📊 Detaylı dönüştürme raporları
- 🚀 Toplu dosya işleme
- 🧪 Kapsamlı test desteği

## Kurulum

### Gereksinimler

- Python 3.8+
- Windows, macOS veya Linux

### Bağımlılıkları Yükle

```bash
pip install -r requirements.txt
```

## Hızlı Başlangıç

### Komut Satırından Kullanım

```bash
# Temel kullanım
python pdf_to_dxf.py input.pdf output.dxf

# Konfigürasyon dosyası ile
python pdf_to_dxf.py --config config.json input.pdf output.dxf

# Detaylı çıktı ile
python pdf_to_dxf.py --verbose input.pdf output.dxf
```

### Python Kodu İle Kullanım

```python
from src.pdf_to_dxf import PDFToDXFConverter, ConversionConfig

# Varsayılan konfigürasyon
config = ConversionConfig()
converter = PDFToDXFConverter(config)

# PDF'i DXF'e dönüştür
success = converter.convert_pdf_to_dxf("input.pdf", "output.dxf")
```

## Desteklenen Geometriler

- **Çizgiler**: Düz çizgiler, kalınlık ve renk desteği
- **Eğriler**: Bezier eğrileri, yaklaşık polyline dönüştürme
- **Dikdörtgenler**: Basit dikdörtgenler, dolu/boş seçenekleri
- **Daireler**: Merkez ve yarıçap, dolu/boş seçenekleri
- **Metin**: Konum ve içerik, font boyutu, renk desteği

## Örnekler

### Temel Dönüştürme

```python
from src.pdf_to_dxf import PDFToDXFConverter

converter = PDFToDXFConverter()
success = converter.convert_pdf_to_dxf("drawing.pdf", "output.dxf")
```

### Toplu İşleme

```python
import os
from pathlib import Path

pdf_files = list(Path("input").glob("*.pdf"))
converter = PDFToDXFConverter()

for pdf_file in pdf_files:
    output_file = f"output/{pdf_file.stem}.dxf"
    converter.convert_pdf_to_dxf(str(pdf_file), output_file)
```

## Test Etme

```bash
python -m pytest tests/ -v
```

## Proje Yapısı

```
pdf-to-dxf-converter/
├── src/pdf_to_dxf/          # Ana kütüphane
├── examples/                # Kullanım örnekleri
├── tests/                   # Test dosyaları
├── pdf_to_dxf.py           # Ana program
└── requirements.txt         # Bağımlılıklar
```

## Sorun Giderme

### Yaygın Sorunlar

1. **PDF dosyası okunamıyor**: Dosyanın geçerli PDF formatında olduğunu kontrol edin
2. **Geometri çıkarılamıyor**: PDF'in vektör grafikleri içerdiğini kontrol edin
3. **DXF dosyası oluşturulamıyor**: Çıkış dizininin yazılabilir olduğunu kontrol edin

## Lisans

MIT License

