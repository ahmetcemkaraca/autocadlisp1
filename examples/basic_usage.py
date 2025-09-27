#!/usr/bin/env python3
"""
PDF to DXF Converter - Temel Kullanım Örneği
Basit PDF to DXF dönüştürme işlemi gösterir.
"""

import sys
import os
from pathlib import Path

# Proje root dizinini path'e ekle
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.pdf_to_dxf import PDFToDXFConverter, ConversionConfig

def basic_conversion_example():
    """Temel dönüştürme örneği"""
    print("PDF to DXF Converter - Temel Kullanım Örneği")
    print("=" * 50)
    
    # Giriş ve çıkış dosya yolları
    input_pdf = "sample_drawing.pdf"  # Örnek PDF dosyası
    output_dxf = "output/sample_drawing.dxf"
    
    # Varsayılan konfigürasyon
    config = ConversionConfig(
        dxf_version="R2018",
        units="mm",
        min_line_length=0.1,
        create_layers=True,
        layer_prefix="PDF_"
    )
    
    # Dönüştürücüyü başlat
    converter = PDFToDXFConverter(config)
    
    try:
        # Dönüştürme işlemini başlat
        print(f"PDF dosyası dönüştürülüyor: {input_pdf}")
        success = converter.convert_pdf_to_dxf(input_pdf, output_dxf)
        
        if success:
            print(f"✅ Dönüştürme başarılı: {output_dxf}")
        else:
            print("❌ Dönüştürme başarısız")
            
    except Exception as e:
        print(f"❌ Hata: {str(e)}")

def advanced_conversion_example():
    """Gelişmiş dönüştürme örneği"""
    print("\nPDF to DXF Converter - Gelişmiş Kullanım Örneği")
    print("=" * 50)
    
    # Gelişmiş konfigürasyon
    config = ConversionConfig(
        dxf_version="R2020",
        units="mm",
        precision=8,
        min_line_length=0.01,
        max_line_width=10.0,
        curve_tolerance=0.001,
        create_layers=True,
        layer_prefix="CONVERTED_",
        auto_scale=True,
        preserve_scale=False
    )
    
    # Dönüştürücüyü başlat
    converter = PDFToDXFConverter(config)
    
    # Birden fazla dosya dönüştürme
    pdf_files = [
        "technical_drawing.pdf",
        "floor_plan.pdf",
        "mechanical_part.pdf"
    ]
    
    for pdf_file in pdf_files:
        if os.path.exists(pdf_file):
            output_file = f"output/{Path(pdf_file).stem}.dxf"
            print(f"📄 İşleniyor: {pdf_file}")
            
            success = converter.convert_pdf_to_dxf(pdf_file, output_file)
            if success:
                print(f"✅ Tamamlandı: {output_file}")
            else:
                print(f"❌ Başarısız: {pdf_file}")
        else:
            print(f"⚠️  Dosya bulunamadı: {pdf_file}")

def custom_configuration_example():
    """Özel konfigürasyon örneği"""
    print("\nPDF to DXF Converter - Özel Konfigürasyon Örneği")
    print("=" * 50)
    
    # Özel konfigürasyon
    config = ConversionConfig(
        dxf_version="R12",  # Eski sürüm uyumluluğu
        units="in",  # İnç birimi
        precision=3,
        min_line_length=0.01,
        create_layers=False,  # Katman oluşturma
        stroke_color_mapping={
            "black": 0,
            "red": 1,
            "green": 3,
            "blue": 5,
            "yellow": 2
        }
    )
    
    print("Özel konfigürasyon ayarları:")
    print(f"- DXF Sürümü: {config.dxf_version}")
    print(f"- Birim: {config.units}")
    print(f"- Hassasiyet: {config.precision}")
    print(f"- Katmanlar: {'Açık' if config.create_layers else 'Kapalı'}")
    
    # Dönüştürücüyü başlat
    converter = PDFToDXFConverter(config)
    
    # Örnek dönüştürme
    input_pdf = "custom_drawing.pdf"
    output_dxf = "output/custom_drawing.dxf"
    
    if os.path.exists(input_pdf):
        success = converter.convert_pdf_to_dxf(input_pdf, output_dxf)
        print(f"Dönüştürme sonucu: {'✅ Başarılı' if success else '❌ Başarısız'}")
    else:
        print(f"⚠️  Test dosyası bulunamadı: {input_pdf}")

def batch_conversion_example():
    """Toplu dönüştürme örneği"""
    print("\nPDF to DXF Converter - Toplu Dönüştürme Örneği")
    print("=" * 50)
    
    # Toplu işlem için konfigürasyon
    config = ConversionConfig(
        dxf_version="R2018",
        units="mm",
        min_line_length=0.1,
        create_layers=True,
        layer_prefix="BATCH_"
    )
    
    # Dönüştürücüyü başlat
    converter = PDFToDXFConverter(config)
    
    # Toplu dönüştürme
    input_directory = "input_pdfs"
    output_directory = "output"
    
    if os.path.exists(input_directory):
        pdf_files = list(Path(input_directory).glob("*.pdf"))
        
        if pdf_files:
            print(f"📁 {len(pdf_files)} PDF dosyası bulundu")
            
            for pdf_file in pdf_files:
                output_file = output_directory / f"{pdf_file.stem}.dxf"
                print(f"🔄 İşleniyor: {pdf_file.name}")
                
                success = converter.convert_pdf_to_dxf(str(pdf_file), str(output_file))
                print(f"   {'✅ Başarılı' if success else '❌ Başarısız'}")
        else:
            print(f"⚠️  {input_directory} dizininde PDF dosyası bulunamadı")
    else:
        print(f"⚠️  Giriş dizini bulunamadı: {input_directory}")

if __name__ == "__main__":
    # Örnekleri çalıştır
    basic_conversion_example()
    advanced_conversion_example()
    custom_configuration_example()
    batch_conversion_example()
    
    print("\n" + "=" * 50)
    print("Tüm örnekler tamamlandı!")
    print("Daha fazla bilgi için README.md dosyasını inceleyin.")

