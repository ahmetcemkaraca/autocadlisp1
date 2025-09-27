"""
DXF Writer Module
DXF geometrilerini DXF dosyasına yazar.
"""

import ezdxf
import os
from typing import List, Dict, Any, Optional
import logging
from datetime import datetime

from .geometry_converter import DXFGeometry
from .config import ConversionConfig, DXFWriterConfig

logger = logging.getLogger(__name__)

class DXFWriter:
    """DXF geometrilerini DXF dosyasına yazan ana sınıf"""
    
    def __init__(self, config: ConversionConfig):
        """
        DXF Writer başlatıcı
        
        Args:
            config: Dönüştürme konfigürasyonu
        """
        self.config = config
        self.writer_config = DXFWriterConfig()
        self.doc: Optional[ezdxf.Document] = None
        self.msp = None
        
    def create_dxf_document(self) -> ezdxf.Document:
        """
        Yeni DXF dokümanı oluşturur
        
        Returns:
            ezdxf.Document: Oluşturulan DXF dokümanı
        """
        try:
            # DXF dokümanı oluştur
            self.doc = ezdxf.new(self.config.dxf_version, setup=True)
            self.msp = self.doc.modelspace()
            
            # Varsayılan katmanları oluştur
            if self.writer_config.create_default_layers:
                self._create_default_layers()
            
            # Doküman bilgilerini ayarla
            self._set_document_properties()
            
            logger.info(f"DXF dokümanı oluşturuldu (sürüm: {self.config.dxf_version})")
            return self.doc
            
        except Exception as e:
            logger.error(f"DXF dokümanı oluşturma hatası: {str(e)}")
            raise
    
    def write_geometries(self, dxf_geometries: List[DXFGeometry]) -> None:
        """
        DXF geometrilerini dokümana yazar
        
        Args:
            dxf_geometries: Yazılacak DXF geometrileri
        """
        if not self.doc or not self.msp:
            raise RuntimeError("DXF dokümanı oluşturulmamış. Önce create_dxf_document() çağırın.")
        
        logger.info(f"{len(dxf_geometries)} DXF geometrisi yazılıyor")
        
        for dxf_geom in dxf_geometries:
            try:
                self._write_single_geometry(dxf_geom)
            except Exception as e:
                logger.error(f"Geometri yazma hatası ({dxf_geom.entity_type}): {str(e)}")
                continue
        
        logger.info("DXF geometrileri başarıyla yazıldı")
    
    def _write_single_geometry(self, dxf_geom: DXFGeometry) -> None:
        """
        Tek bir DXF geometrisini dokümana yazar
        
        Args:
            dxf_geom: Yazılacak DXF geometrisi
        """
        try:
            if dxf_geom.entity_type == "LINE":
                self._write_line(dxf_geom)
            elif dxf_geom.entity_type == "POLYLINE":
                self._write_polyline(dxf_geom)
            elif dxf_geom.entity_type == "CIRCLE":
                self._write_circle(dxf_geom)
            elif dxf_geom.entity_type == "TEXT":
                self._write_text(dxf_geom)
            else:
                logger.warning(f"Desteklenmeyen entity tipi: {dxf_geom.entity_type}")
                
        except Exception as e:
            logger.error(f"Entity yazma hatası ({dxf_geom.entity_type}): {str(e)}")
            raise
    
    def _write_line(self, dxf_geom: DXFGeometry) -> None:
        """
        LINE entity'sini yazar
        
        Args:
            dxf_geom: DXF çizgi geometrisi
        """
        coords = dxf_geom.coordinates
        if len(coords) < 2:
            raise ValueError("Çizgi için en az 2 koordinat gerekli")
        
        start = coords[0]
        end = coords[1]
        
        # DXF attributları
        dxfattribs = {
            "layer": dxf_geom.layer,
            "color": dxf_geom.properties.get("color", 7),
        }
        
        # Çizgi kalınlığı (eğer destekleniyorsa)
        width = dxf_geom.properties.get("width", 1.0)
        if width > 0:
            dxfattribs["lineweight"] = int(width * 100)  # Line weight in 0.01mm
        
        self.msp.add_line(start, end, dxfattribs=dxfattribs)
    
    def _write_polyline(self, dxf_geom: DXFGeometry) -> None:
        """
        POLYLINE entity'sini yazar
        
        Args:
            dxf_geom: DXF polyline geometrisi
        """
        coords = dxf_geom.coordinates
        if len(coords) < 2:
            raise ValueError("Polyline için en az 2 koordinat gerekli")
        
        # DXF attributları
        dxfattribs = {
            "layer": dxf_geom.layer,
            "color": dxf_geom.properties.get("color", 7),
        }
        
        # Çizgi kalınlığı
        width = dxf_geom.properties.get("width", 1.0)
        if width > 0:
            dxfattribs["lineweight"] = int(width * 100)
        
        # Kapalı polyline kontrolü
        closed = dxf_geom.properties.get("closed", False)
        if closed:
            dxfattribs["closed"] = True
        
        # Polyline oluştur
        polyline = self.msp.add_polyline2d(coords, dxfattribs=dxfattribs)
        
        # Doldurma (eğer varsa)
        filled = dxf_geom.properties.get("filled", False)
        if filled:
            polyline.dxf.const_width = width
    
    def _write_circle(self, dxf_geom: DXFGeometry) -> None:
        """
        CIRCLE entity'sini yazar
        
        Args:
            dxf_geom: DXF daire geometrisi
        """
        coords = dxf_geom.coordinates
        if len(coords) < 1:
            raise ValueError("Daire için en az 1 koordinat (merkez) gerekli")
        
        center = coords[0]
        radius = dxf_geom.properties.get("radius", 1.0)
        
        # DXF attributları
        dxfattribs = {
            "layer": dxf_geom.layer,
            "color": dxf_geom.properties.get("color", 7),
        }
        
        # Çizgi kalınlığı
        width = dxf_geom.properties.get("width", 1.0)
        if width > 0:
            dxfattribs["lineweight"] = int(width * 100)
        
        self.msp.add_circle(center, radius, dxfattribs=dxfattribs)
    
    def _write_text(self, dxf_geom: DXFGeometry) -> None:
        """
        TEXT entity'sini yazar
        
        Args:
            dxf_geom: DXF metin geometrisi
        """
        coords = dxf_geom.coordinates
        if len(coords) < 1:
            raise ValueError("Metin için en az 1 koordinat gerekli")
        
        position = coords[0]
        text_content = dxf_geom.properties.get("text", "")
        height = dxf_geom.properties.get("height", 12.0)
        
        # DXF attributları
        dxfattribs = {
            "layer": dxf_geom.layer,
            "color": dxf_geom.properties.get("color", 7),
            "height": height,
        }
        
        self.msp.add_text(text_content, dxfattribs=dxfattribs).set_pos(position)
    
    def _create_default_layers(self) -> None:
        """Varsayılan katmanları oluşturur"""
        try:
            # Varsayılan katmanlar
            default_layers = {
                "LINES": 7,      # Beyaz
                "CURVES": 5,     # Mavi
                "RECTANGLES": 3, # Yeşil
                "CIRCLES": 1,    # Kırmızı
                "TEXT": 2,       # Sarı
                "DIMENSIONS": 6  # Magenta
            }
            
            for layer_name, color in default_layers.items():
                if not self.doc.layers.has_entry(layer_name):
                    layer = self.doc.layers.add(layer_name)
                    layer.color = color
                    layer.linetype = "CONTINUOUS"
            
            logger.info("Varsayılan katmanlar oluşturuldu")
            
        except Exception as e:
            logger.error(f"Katman oluşturma hatası: {str(e)}")
    
    def _set_document_properties(self) -> None:
        """Doküman özelliklerini ayarlar"""
        try:
            # Doküman bilgileri
            self.doc.header['$ACADVER'] = self.config.dxf_version
            
            # Birim ayarları
            if self.config.units == "mm":
                self.doc.header['$INSUNITS'] = 4  # Millimeters
            elif self.config.units == "cm":
                self.doc.header['$INSUNITS'] = 3  # Centimeters
            elif self.config.units == "m":
                self.doc.header['$INSUNITS'] = 6  # Meters
            elif self.config.units == "in":
                self.doc.header['$INSUNITS'] = 1  # Inches
            else:
                self.doc.header['$INSUNITS'] = 0  # Unitless
            
            # Doküman oluşturma bilgileri
            self.doc.header['$TDCREATE'] = datetime.now()
            self.doc.header['$TDUPDATE'] = datetime.now()
            
            # PDF to DXF converter bilgisi
            self.doc.header['$DWGPROPS'] = "PDF to DXF Converter"
            
            logger.info("Doküman özellikleri ayarlandı")
            
        except Exception as e:
            logger.error(f"Doküman özellikleri ayarlama hatası: {str(e)}")
    
    def save_dxf_file(self, output_path: str) -> str:
        """
        DXF dosyasını kaydeder
        
        Args:
            output_path: Çıktı dosya yolu
            
        Returns:
            str: Kaydedilen dosya yolu
        """
        if not self.doc:
            raise RuntimeError("DXF dokümanı oluşturulmamış")
        
        try:
            # Çıktı dizinini oluştur
            output_dir = os.path.dirname(output_path)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)
            
            # Dosyayı kaydet
            self.doc.saveas(output_path)
            
            logger.info(f"DXF dosyası kaydedildi: {output_path}")
            return output_path
            
        except Exception as e:
            logger.error(f"DXF dosyası kaydetme hatası: {str(e)}")
            raise
    
    def get_document_statistics(self) -> Dict[str, Any]:
        """
        DXF dokümanı hakkında istatistik döndürür
        
        Returns:
            Dict[str, Any]: Doküman istatistikleri
        """
        if not self.doc:
            return {}
        
        stats = {
            "dxf_version": self.config.dxf_version,
            "units": self.config.units,
            "layers": [],
            "total_entities": 0,
            "entity_counts": {}
        }
        
        try:
            # Katman bilgileri
            for layer in self.doc.layers:
                stats["layers"].append({
                    "name": layer.dxf.name,
                    "color": layer.dxf.color,
                    "linetype": layer.dxf.linetype
                })
            
            # Entity sayıları
            for entity in self.msp:
                entity_type = entity.dxftype()
                stats["total_entities"] += 1
                
                if entity_type not in stats["entity_counts"]:
                    stats["entity_counts"][entity_type] = 0
                stats["entity_counts"][entity_type] += 1
            
        except Exception as e:
            logger.error(f"İstatistik hesaplama hatası: {str(e)}")
        
        return stats
    
    def close_document(self) -> None:
        """DXF dokümanını kapatır"""
        if self.doc:
            self.doc = None
            self.msp = None
            logger.info("DXF dokümanı kapatıldı")

