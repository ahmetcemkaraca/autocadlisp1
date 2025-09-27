"""
Geometry Converter Module
PDF geometrilerini DXF formatına dönüştürür.
"""

import ezdxf
import numpy as np
from typing import List, Dict, Any, Tuple, Optional
import logging
from dataclasses import dataclass
import math

from .pdf_parser import GeometryObject
from .config import ConversionConfig, DXFWriterConfig

logger = logging.getLogger(__name__)

@dataclass
class DXFGeometry:
    """DXF geometri temel sınıfı"""
    entity_type: str  # 'LINE', 'POLYLINE', 'ARC', 'CIRCLE', 'TEXT'
    coordinates: List[Tuple[float, float, float]]
    properties: Dict[str, Any]
    layer: str = "0"

class GeometryConverter:
    """PDF geometrilerini DXF formatına dönüştüren ana sınıf"""
    
    def __init__(self, config: ConversionConfig):
        """
        Geometri dönüştürücü başlatıcı
        
        Args:
            config: Dönüştürme konfigürasyonu
        """
        self.config = config
        self.writer_config = DXFWriterConfig()
        self.dxf_geometries: List[DXFGeometry] = []
        self.scale_factor = 1.0
        self.offset_x = 0.0
        self.offset_y = 0.0
        
    def convert_geometries(self, pdf_geometries: List[GeometryObject]) -> List[DXFGeometry]:
        """
        PDF geometrilerini DXF formatına dönüştürür
        
        Args:
            pdf_geometries: PDF geometrik nesneleri
            
        Returns:
            List[DXFGeometry]: DXF geometrik nesneleri
        """
        logger.info(f"{len(pdf_geometries)} geometri dönüştürülüyor")
        
        # Koordinat sistemi ayarlarını hesapla
        self._calculate_coordinate_system(pdf_geometries)
        
        dxf_geometries = []
        
        for pdf_geom in pdf_geometries:
            try:
                dxf_geom = self._convert_single_geometry(pdf_geom)
                if dxf_geom:
                    dxf_geometries.append(dxf_geom)
            except Exception as e:
                logger.error(f"Geometri dönüştürme hatası: {str(e)}")
                continue
        
        self.dxf_geometries = dxf_geometries
        logger.info(f"{len(dxf_geometries)} DXF geometrisi oluşturuldu")
        
        return dxf_geometries
    
    def _calculate_coordinate_system(self, pdf_geometries: List[GeometryObject]) -> None:
        """
        Koordinat sistemi ayarlarını hesaplar (ölçeklendirme ve offset)
        
        Args:
            pdf_geometries: PDF geometrik nesneleri
        """
        if not pdf_geometries:
            return
        
        # Tüm koordinatları topla
        all_coords = []
        for geom in pdf_geometries:
            all_coords.extend(geom.coordinates)
        
        if not all_coords:
            return
        
        # Bounding box hesapla
        min_x = min(coord[0] for coord in all_coords)
        max_x = max(coord[0] for coord in all_coords)
        min_y = min(coord[1] for coord in all_coords)
        max_y = max(coord[1] for coord in all_coords)
        
        # Offset hesapla (çizimin başlangıç noktasını (0,0) yap)
        self.offset_x = -min_x
        self.offset_y = -min_y
        
        # Ölçeklendirme hesapla (eğer gerekirse)
        if self.config.auto_scale:
            width = max_x - min_x
            height = max_y - min_y
            max_dimension = max(width, height)
            
            # Çizimi belirli bir boyuta ölçekle (örneğin 1000mm)
            target_size = 1000.0
            if max_dimension > 0:
                self.scale_factor = target_size / max_dimension
            else:
                self.scale_factor = 1.0
        else:
            self.scale_factor = 1.0
        
        logger.info(f"Koordinat sistemi ayarları - Offset: ({self.offset_x:.2f}, {self.offset_y:.2f}), Ölçek: {self.scale_factor:.4f}")
    
    def _convert_single_geometry(self, pdf_geom: GeometryObject) -> Optional[DXFGeometry]:
        """
        Tek bir PDF geometrisini DXF formatına dönüştürür
        
        Args:
            pdf_geom: PDF geometrik nesnesi
            
        Returns:
            Optional[DXFGeometry]: DXF geometrik nesnesi
        """
        try:
            if pdf_geom.object_type == "line":
                return self._convert_line(pdf_geom)
            elif pdf_geom.object_type == "curve":
                return self._convert_curve(pdf_geom)
            elif pdf_geom.object_type == "rectangle":
                return self._convert_rectangle(pdf_geom)
            elif pdf_geom.object_type == "circle":
                return self._convert_circle(pdf_geom)
            elif pdf_geom.object_type == "text":
                return self._convert_text(pdf_geom)
            else:
                logger.warning(f"Desteklenmeyen geometri tipi: {pdf_geom.object_type}")
                return None
                
        except Exception as e:
            logger.error(f"Geometri dönüştürme hatası ({pdf_geom.object_type}): {str(e)}")
            return None
    
    def _convert_line(self, pdf_geom: GeometryObject) -> DXFGeometry:
        """
        Çizgi geometrisini DXF LINE'a dönüştürür
        
        Args:
            pdf_geom: PDF çizgi geometrisi
            
        Returns:
            DXFGeometry: DXF çizgi geometrisi
        """
        coords = pdf_geom.coordinates
        if len(coords) < 2:
            raise ValueError("Çizgi için en az 2 koordinat gerekli")
        
        start = self._transform_coordinate(coords[0])
        end = self._transform_coordinate(coords[1])
        
        # Çizgi kalınlığını kontrol et
        width = pdf_geom.properties.get("width", 1.0)
        if width > self.config.max_line_width:
            width = self.config.max_line_width
        
        return DXFGeometry(
            entity_type="LINE",
            coordinates=[start, end],
            properties={
                "width": width,
                "color": self._get_dxf_color(pdf_geom.properties.get("color", (0, 0, 0))),
                "layer": self._get_layer_name("LINES")
            },
            layer=self._get_layer_name("LINES")
        )
    
    def _convert_curve(self, pdf_geom: GeometryObject) -> DXFGeometry:
        """
        Eğri geometrisini DXF POLYLINE'a dönüştürür (Bezier eğrisi yaklaşımı)
        
        Args:
            pdf_geom: PDF eğri geometrisi
            
        Returns:
            DXFGeometry: DXF polyline geometrisi
        """
        coords = pdf_geom.coordinates
        curve_type = pdf_geom.properties.get("curve_type", "bezier")
        
        if curve_type == "bezier" and len(coords) >= 4:
            # Bezier eğrisini segmentlere böl
            segments = self._approximate_bezier_curve(coords[:4])
        else:
            # Basit eğri yaklaşımı
            segments = self._approximate_curve(coords)
        
        if len(segments) < 2:
            # Eğri çok kısa, çizgi olarak dönüştür
            return self._convert_line(pdf_geom)
        
        # 3D koordinatlara dönüştür
        dxf_coords = [self._transform_coordinate(coord) for coord in segments]
        
        width = pdf_geom.properties.get("width", 1.0)
        if width > self.config.max_line_width:
            width = self.config.max_line_width
        
        return DXFGeometry(
            entity_type="POLYLINE",
            coordinates=dxf_coords,
            properties={
                "width": width,
                "color": self._get_dxf_color(pdf_geom.properties.get("color", (0, 0, 0))),
                "closed": False,
                "layer": self._get_layer_name("CURVES")
            },
            layer=self._get_layer_name("CURVES")
        )
    
    def _convert_rectangle(self, pdf_geom: GeometryObject) -> DXFGeometry:
        """
        Dikdörtgen geometrisini DXF POLYLINE'a dönüştürür
        
        Args:
            pdf_geom: PDF dikdörtgen geometrisi
            
        Returns:
            DXFGeometry: DXF polyline geometrisi
        """
        coords = pdf_geom.coordinates
        if len(coords) < 2:
            raise ValueError("Dikdörtgen için en az 2 koordinat gerekli")
        
        top_left = coords[0]
        bottom_right = coords[1]
        
        # Dikdörtgen köşelerini hesapla
        corners = [
            top_left,
            (bottom_right[0], top_left[1]),
            bottom_right,
            (top_left[0], bottom_right[1]),
            top_left  # Kapalı polyline için
        ]
        
        # 3D koordinatlara dönüştür
        dxf_coords = [self._transform_coordinate(coord) for coord in corners]
        
        width = pdf_geom.properties.get("width", 1.0)
        if width > self.config.max_line_width:
            width = self.config.max_line_width
        
        return DXFGeometry(
            entity_type="POLYLINE",
            coordinates=dxf_coords,
            properties={
                "width": width,
                "color": self._get_dxf_color(pdf_geom.properties.get("color", (0, 0, 0))),
                "closed": True,
                "filled": pdf_geom.properties.get("filled", False),
                "layer": self._get_layer_name("RECTANGLES")
            },
            layer=self._get_layer_name("RECTANGLES")
        )
    
    def _convert_circle(self, pdf_geom: GeometryObject) -> DXFGeometry:
        """
        Daire geometrisini DXF CIRCLE'a dönüştürür
        
        Args:
            pdf_geom: PDF daire geometrisi
            
        Returns:
            DXFGeometry: DXF daire geometrisi
        """
        coords = pdf_geom.coordinates
        if len(coords) < 2:
            raise ValueError("Daire için en az 2 koordinat gerekli")
        
        center = self._transform_coordinate(coords[0])
        radius = self._calculate_radius(coords[0], coords[1])
        
        width = pdf_geom.properties.get("width", 1.0)
        if width > self.config.max_line_width:
            width = self.config.max_line_width
        
        return DXFGeometry(
            entity_type="CIRCLE",
            coordinates=[center],
            properties={
                "radius": radius,
                "width": width,
                "color": self._get_dxf_color(pdf_geom.properties.get("color", (0, 0, 0))),
                "filled": pdf_geom.properties.get("filled", False),
                "layer": self._get_layer_name("CIRCLES")
            },
            layer=self._get_layer_name("CIRCLES")
        )
    
    def _convert_text(self, pdf_geom: GeometryObject) -> DXFGeometry:
        """
        Metin geometrisini DXF TEXT'e dönüştürür
        
        Args:
            pdf_geom: PDF metin geometrisi
            
        Returns:
            DXFGeometry: DXF metin geometrisi
        """
        coords = pdf_geom.coordinates
        if len(coords) < 1:
            raise ValueError("Metin için en az 1 koordinat gerekli")
        
        position = self._transform_coordinate(coords[0])
        
        return DXFGeometry(
            entity_type="TEXT",
            coordinates=[position],
            properties={
                "text": pdf_geom.properties.get("content", ""),
                "height": pdf_geom.properties.get("font_size", 12.0) * self.scale_factor,
                "color": self._get_dxf_color(pdf_geom.properties.get("color", (0, 0, 0))),
                "layer": self._get_layer_name("TEXT")
            },
            layer=self._get_layer_name("TEXT")
        )
    
    def _approximate_bezier_curve(self, control_points: List[Tuple[float, float]]) -> List[Tuple[float, float]]:
        """
        Bezier eğrisini line segmentlere yaklaştırır
        
        Args:
            control_points: Bezier kontrol noktaları
            
        Returns:
            List[Tuple[float, float]]: Yaklaşık noktalar
        """
        if len(control_points) != 4:
            return control_points
        
        p0, p1, p2, p3 = control_points
        segments = self.writer_config.arc_approximation_segments
        points = []
        
        for i in range(segments + 1):
            t = i / segments
            # Bezier eğrisi formülü
            point = (
                (1-t)**3 * p0[0] + 3*(1-t)**2*t * p1[0] + 3*(1-t)*t**2 * p2[0] + t**3 * p3[0],
                (1-t)**3 * p0[1] + 3*(1-t)**2*t * p1[1] + 3*(1-t)*t**2 * p2[1] + t**3 * p3[1]
            )
            points.append(point)
        
        return points
    
    def _approximate_curve(self, control_points: List[Tuple[float, float]]) -> List[Tuple[float, float]]:
        """
        Genel eğriyi line segmentlere yaklaştırır
        
        Args:
            control_points: Eğri kontrol noktaları
            
        Returns:
            List[Tuple[float, float]]: Yaklaşık noktalar
        """
        if len(control_points) < 3:
            return control_points
        
        # Basit line interpolation
        points = []
        for i in range(len(control_points) - 1):
            start = control_points[i]
            end = control_points[i + 1]
            
            # İki nokta arasında segment ekle
            segments = 5  # Her segment için 5 nokta
            for j in range(segments + 1):
                t = j / segments
                point = (
                    start[0] + t * (end[0] - start[0]),
                    start[1] + t * (end[1] - start[1])
                )
                points.append(point)
        
        return points
    
    def _transform_coordinate(self, coord: Tuple[float, float]) -> Tuple[float, float, float]:
        """
        PDF koordinatını DXF koordinatına dönüştürür
        
        Args:
            coord: PDF koordinatı (x, y)
            
        Returns:
            Tuple[float, float, float]: DXF koordinatı (x, y, z)
        """
        x = (coord[0] + self.offset_x) * self.scale_factor
        y = (coord[1] + self.offset_y) * self.scale_factor
        z = 0.0  # 2D çizim için z = 0
        
        return (x, y, z)
    
    def _calculate_radius(self, center: Tuple[float, float], point: Tuple[float, float]) -> float:
        """
        Merkez ve nokta arasındaki mesafeyi hesaplar (yarıçap)
        
        Args:
            center: Merkez koordinatı
            point: Nokta koordinatı
            
        Returns:
            float: Yarıçap
        """
        dx = point[0] - center[0]
        dy = point[1] - center[1]
        return math.sqrt(dx*dx + dy*dy) * self.scale_factor
    
    def _get_dxf_color(self, rgb_color: Tuple[float, float, float]) -> int:
        """
        RGB renk değerini DXF renk indeksine dönüştürür
        
        Args:
            rgb_color: RGB renk değeri (0-1 arası)
            
        Returns:
            int: DXF renk indeksi
        """
        # Basit renk eşleme (daha gelişmiş eşleme eklenebilir)
        r, g, b = rgb_color
        
        if r > 0.8 and g < 0.2 and b < 0.2:
            return 1  # Kırmızı
        elif r < 0.2 and g > 0.8 and b < 0.2:
            return 3  # Yeşil
        elif r < 0.2 and g < 0.2 and b > 0.8:
            return 5  # Mavi
        elif r > 0.8 and g > 0.8 and b < 0.2:
            return 2  # Sarı
        elif r < 0.2 and g > 0.8 and b > 0.8:
            return 4  # Cyan
        elif r > 0.8 and g < 0.2 and b > 0.8:
            return 6  # Magenta
        elif r > 0.8 and g > 0.8 and b > 0.8:
            return 7  # Beyaz
        else:
            return 0  # Siyah
    
    def _get_layer_name(self, layer_type: str) -> str:
        """
        Katman adını oluşturur
        
        Args:
            layer_type: Katman tipi
            
        Returns:
            str: Katman adı
        """
        if not self.config.create_layers:
            return "0"  # Varsayılan katman
        
        return f"{self.config.layer_prefix}{layer_type}"
    
    def get_conversion_statistics(self) -> Dict[str, Any]:
        """
        Dönüştürme istatistiklerini döndürür
        
        Returns:
            Dict[str, Any]: Dönüştürme istatistikleri
        """
        if not self.dxf_geometries:
            return {}
        
        stats = {
            "total_dxf_objects": len(self.dxf_geometries),
            "by_entity_type": {},
            "by_layer": {},
            "coordinate_system": {
                "scale_factor": self.scale_factor,
                "offset_x": self.offset_x,
                "offset_y": self.offset_y
            }
        }
        
        for geom in self.dxf_geometries:
            # Entity tipine göre sayım
            if geom.entity_type not in stats["by_entity_type"]:
                stats["by_entity_type"][geom.entity_type] = 0
            stats["by_entity_type"][geom.entity_type] += 1
            
            # Katmana göre sayım
            if geom.layer not in stats["by_layer"]:
                stats["by_layer"][geom.layer] = 0
            stats["by_layer"][geom.layer] += 1
        
        return stats

