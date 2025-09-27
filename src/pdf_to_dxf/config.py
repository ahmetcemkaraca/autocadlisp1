"""
PDF to DXF Converter Configuration Module
Konfigürasyon ayarlarını ve sabitleri yönetir.
"""

import os
from dataclasses import dataclass
from typing import Dict, Any, Optional

@dataclass
class ConversionConfig:
    """PDF to DXF dönüştürme konfigürasyonu"""
    
    # DXF dosya ayarları
    dxf_version: str = "R2010"  # AutoCAD sürümü
    units: str = "mm"  # Birim sistemi
    precision: int = 6  # Ondalık hassasiyeti
    
    # PDF işleme ayarları
    min_line_length: float = 0.1  # Minimum çizgi uzunluğu (mm)
    max_line_width: float = 10.0  # Maksimum çizgi kalınlığı (mm)
    curve_tolerance: float = 0.01  # Eğri yaklaşım toleransı
    
    # Renk ayarları
    default_color: int = 7  # Varsayılan DXF rengi (beyaz)
    stroke_color_mapping: Dict[str, int] = None
    
    # Katman ayarları
    create_layers: bool = True
    layer_prefix: str = "PDF_LAYER_"
    
    # Çıktı ayarları
    output_directory: str = "output"
    preserve_scale: bool = True
    auto_scale: bool = False
    
    def __post_init__(self):
        """Konfigürasyon doğrulaması ve varsayılan değerler"""
        if self.stroke_color_mapping is None:
            self.stroke_color_mapping = {
                "black": 0,
                "white": 7,
                "red": 1,
                "green": 3,
                "blue": 5,
                "yellow": 2,
                "cyan": 4,
                "magenta": 6
            }
        
        # Çıktı dizinini oluştur
        if not os.path.exists(self.output_directory):
            os.makedirs(self.output_directory)

class PDFParserConfig:
    """PDF parser özel konfigürasyonu"""
    
    # Çizgi tespiti ayarları
    line_detection_threshold: float = 0.5
    min_line_width: float = 0.1
    max_line_width: float = 5.0
    
    # Eğri tespiti ayarları
    curve_detection_enabled: bool = True
    bezier_curve_segments: int = 20
    
    # Metin işleme ayarları
    extract_text: bool = False
    text_as_geometry: bool = False
    
    # Performans ayarları
    max_objects_per_page: int = 10000
    memory_limit_mb: int = 512

class DXFWriterConfig:
    """DXF writer özel konfigürasyonu"""
    
    # Dosya formatı ayarları
    use_r12_fast_writer: bool = False
    include_headers: bool = True
    include_blocks: bool = True
    
    # Geometri ayarları
    polyline_approximation: bool = True
    arc_approximation_segments: int = 16
    
    # Katman yönetimi
    create_default_layers: bool = True
    layer_color_mapping: Dict[str, int] = None
    
    def __post_init__(self):
        if self.layer_color_mapping is None:
            self.layer_color_mapping = {
                "LINES": 7,
                "CURVES": 5,
                "TEXT": 3,
                "DIMENSIONS": 1
            }

# Varsayılan konfigürasyon örneği
DEFAULT_CONFIG = ConversionConfig()

# Gelişmiş konfigürasyonlar
ADVANCED_CONFIG = ConversionConfig(
    dxf_version="R2018",
    precision=8,
    min_line_length=0.01,
    curve_tolerance=0.001,
    create_layers=True,
    auto_scale=True
)

# Performans odaklı konfigürasyon
PERFORMANCE_CONFIG = ConversionConfig(
    dxf_version="R12",
    precision=3,
    min_line_length=1.0,
    curve_tolerance=0.1,
    create_layers=False,
    auto_scale=False
)

def load_config_from_file(config_path: str) -> ConversionConfig:
    """
    Konfigürasyon dosyasından ayarları yükler
    
    Args:
        config_path: Konfigürasyon dosyası yolu
        
    Returns:
        ConversionConfig: Yüklenen konfigürasyon
    """
    import json
    
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Konfigürasyon dosyası bulunamadı: {config_path}")
    
    with open(config_path, 'r', encoding='utf-8') as f:
        config_data = json.load(f)
    
    return ConversionConfig(**config_data)

def save_config_to_file(config: ConversionConfig, config_path: str) -> None:
    """
    Konfigürasyonu dosyaya kaydeder
    
    Args:
        config: Kaydedilecek konfigürasyon
        config_path: Kayıt yolu
    """
    import json
    
    config_dict = {
        'dxf_version': config.dxf_version,
        'units': config.units,
        'precision': config.precision,
        'min_line_length': config.min_line_length,
        'max_line_width': config.max_line_width,
        'curve_tolerance': config.curve_tolerance,
        'default_color': config.default_color,
        'stroke_color_mapping': config.stroke_color_mapping,
        'create_layers': config.create_layers,
        'layer_prefix': config.layer_prefix,
        'output_directory': config.output_directory,
        'preserve_scale': config.preserve_scale,
        'auto_scale': config.auto_scale
    }
    
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(config_dict, f, indent=2, ensure_ascii=False)

