#!/usr/bin/env python3
"""
PDF to DXF Converter - Ana Program
PDF dosyalarındaki AutoCAD çizimlerini DXF formatına dönüştürür.

Kullanım:
    python pdf_to_dxf.py input.pdf output.dxf
    python pdf_to_dxf.py --config config.json input.pdf output.dxf
"""

import sys
import os
import argparse
import logging
from pathlib import Path
from typing import Optional

# Proje modüllerini import et
from src.pdf_to_dxf import (
    PDFParser, 
    GeometryConverter, 
    DXFWriter, 
    ConversionConfig,
    load_config_from_file,
    save_config_to_file
)

# Logging konfigürasyonu
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('pdf_to_dxf.log', encoding='utf-8')
    ]
)
logger = logging.getLogger(__name__)

class PDFToDXFConverter:
    """PDF to DXF dönüştürücü ana sınıfı"""
    
    def __init__(self, config: Optional[ConversionConfig] = None):
        """
        Dönüştürücü başlatıcı
        
        Args:
            config: Dönüştürme konfigürasyonu (opsiyonel)
        """
        self.config = config or ConversionConfig()
        self.parser = PDFParser(self.config)
        self.converter = GeometryConverter(self.config)
        self.writer = DXFWriter(self.config)
        
    def convert_pdf_to_dxf(self, input_path: str, output_path: str) -> bool:
        """
        PDF dosyasını DXF formatına dönüştürür
        
        Args:
            input_path: Giriş PDF dosya yolu
            output_path: Çıkış DXF dosya yolu
            
        Returns:
            bool: Dönüştürme başarılı mı
        """
        try:
            logger.info(f"PDF to DXF dönüştürme başlıyor: {input_path} -> {output_path}")
            
            # 1. PDF dosyasını kontrol et
            if not self._validate_input_file(input_path):
                return False
            
            # 2. PDF'den geometrileri çıkar
            logger.info("PDF geometrileri çıkarılıyor...")
            pdf_geometries = self.parser.parse_pdf(input_path)
            
            if not pdf_geometries:
                logger.warning("PDF'den hiç geometri çıkarılamadı")
                return False
            
            # Parse istatistiklerini göster
            parse_stats = self.parser.get_statistics()
            logger.info(f"Parse istatistikleri: {parse_stats}")
            
            # 3. Geometrileri DXF formatına dönüştür
            logger.info("Geometriler DXF formatına dönüştürülüyor...")
            dxf_geometries = self.converter.convert_geometries(pdf_geometries)
            
            if not dxf_geometries:
                logger.warning("Hiç DXF geometrisi oluşturulamadı")
                return False
            
            # Dönüştürme istatistiklerini göster
            conversion_stats = self.converter.get_conversion_statistics()
            logger.info(f"Dönüştürme istatistikleri: {conversion_stats}")
            
            # 4. DXF dokümanı oluştur ve yaz
            logger.info("DXF dokümanı oluşturuluyor...")
            self.writer.create_dxf_document()
            self.writer.write_geometries(dxf_geometries)
            
            # 5. DXF dosyasını kaydet
            logger.info("DXF dosyası kaydediliyor...")
            saved_path = self.writer.save_dxf_file(output_path)
            
            # Doküman istatistiklerini göster
            doc_stats = self.writer.get_document_statistics()
            logger.info(f"DXF doküman istatistikleri: {doc_stats}")
            
            # 6. DXF dokümanını kapat
            self.writer.close_document()
            
            logger.info(f"Başarıyla tamamlandı: {saved_path}")
            return True
            
        except Exception as e:
            logger.error(f"Dönüştürme hatası: {str(e)}")
            return False
    
    def _validate_input_file(self, file_path: str) -> bool:
        """
        Giriş dosyasını doğrular
        
        Args:
            file_path: Dosya yolu
            
        Returns:
            bool: Dosya geçerli mi
        """
        if not os.path.exists(file_path):
            logger.error(f"Dosya bulunamadı: {file_path}")
            return False
        
        if not file_path.lower().endswith('.pdf'):
            logger.error("Dosya PDF formatında değil")
            return False
        
        file_size = os.path.getsize(file_path)
        if file_size == 0:
            logger.error("Dosya boş")
            return False
        
        logger.info(f"Dosya doğrulandı: {file_path} ({file_size} bytes)")
        return True

def create_sample_config(output_path: str) -> None:
    """
    Örnek konfigürasyon dosyası oluşturur
    
    Args:
        output_path: Çıktı dosya yolu
    """
    try:
        sample_config = ConversionConfig(
            dxf_version="R2018",
            units="mm",
            precision=6,
            min_line_length=0.1,
            max_line_width=5.0,
            curve_tolerance=0.01,
            create_layers=True,
            layer_prefix="PDF_",
            output_directory="output",
            preserve_scale=True,
            auto_scale=False
        )
        
        save_config_to_file(sample_config, output_path)
        logger.info(f"Örnek konfigürasyon dosyası oluşturuldu: {output_path}")
        
    except Exception as e:
        logger.error(f"Konfigürasyon dosyası oluşturma hatası: {str(e)}")

def main():
    """Ana program fonksiyonu"""
    parser = argparse.ArgumentParser(
        description="PDF dosyalarındaki AutoCAD çizimlerini DXF formatına dönüştürür",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Örnekler:
  python pdf_to_dxf.py input.pdf output.dxf
  python pdf_to_dxf.py --config config.json input.pdf output.dxf
  python pdf_to_dxf.py --create-config sample_config.json
  python pdf_to_dxf.py --verbose input.pdf output.dxf
        """
    )
    
    parser.add_argument(
        'input_pdf', 
        nargs='?',
        help='Giriş PDF dosya yolu'
    )
    
    parser.add_argument(
        'output_dxf', 
        nargs='?',
        help='Çıkış DXF dosya yolu'
    )
    
    parser.add_argument(
        '--config', '-c',
        type=str,
        help='Konfigürasyon dosyası yolu (JSON format)'
    )
    
    parser.add_argument(
        '--create-config',
        type=str,
        help='Örnek konfigürasyon dosyası oluştur'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Detaylı çıktı göster'
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version='PDF to DXF Converter 1.0.0'
    )
    
    args = parser.parse_args()
    
    # Logging seviyesini ayarla
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Örnek konfigürasyon oluşturma
        if args.create_config:
            create_sample_config(args.create_config)
            return
        
        # Gerekli argümanları kontrol et
        if not args.input_pdf or not args.output_dxf:
            parser.print_help()
            sys.exit(1)
        
        # Konfigürasyonu yükle
        config = None
        if args.config:
            if not os.path.exists(args.config):
                logger.error(f"Konfigürasyon dosyası bulunamadı: {args.config}")
                sys.exit(1)
            config = load_config_from_file(args.config)
            logger.info(f"Konfigürasyon yüklendi: {args.config}")
        
        # Dönüştürücüyü başlat ve çalıştır
        converter = PDFToDXFConverter(config)
        success = converter.convert_pdf_to_dxf(args.input_pdf, args.output_dxf)
        
        if success:
            logger.info("Dönüştürme başarıyla tamamlandı!")
            sys.exit(0)
        else:
            logger.error("Dönüştürme başarısız!")
            sys.exit(1)
            
    except KeyboardInterrupt:
        logger.info("Kullanıcı tarafından iptal edildi")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Beklenmeyen hata: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()

