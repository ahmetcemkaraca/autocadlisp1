"""
PDF Parser Module
PDF dosyalarından geometrik çizimleri çıkarır ve analiz eder.
"""

import fitz  # PyMuPDF
import pdfplumber
from typing import List, Dict, Any, Tuple, Optional
import logging
from dataclasses import dataclass
import numpy as np
from .config import ConversionConfig, PDFParserConfig

# Logging konfigürasyonu
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class GeometryObject:
    """Geometrik nesne temel sınıfı"""
    object_type: str  # 'line', 'curve', 'rectangle', 'circle', 'text'
    coordinates: List[Tuple[float, float]]
    properties: Dict[str, Any]
    page_number: int

@dataclass
class Line:
    """Çizgi geometrisi"""
    start: Tuple[float, float]
    end: Tuple[float, float]
    width: float = 1.0
    color: Tuple[float, float, float] = (0.0, 0.0, 0.0)

@dataclass
class Curve:
    """Eğri geometrisi"""
    control_points: List[Tuple[float, float]]
    curve_type: str  # 'bezier', 'arc', 'quadratic'
    width: float = 1.0
    color: Tuple[float, float, float] = (0.0, 0.0, 0.0)

@dataclass
class Rectangle:
    """Dikdörtgen geometrisi"""
    top_left: Tuple[float, float]
    bottom_right: Tuple[float, float]
    width: float = 1.0
    color: Tuple[float, float, float] = (0.0, 0.0, 0.0)
    filled: bool = False

@dataclass
class Circle:
    """Daire geometrisi"""
    center: Tuple[float, float]
    radius: float
    width: float = 1.0
    color: Tuple[float, float, float] = (0.0, 0.0, 0.0)
    filled: bool = False

@dataclass
class Text:
    """Metin geometrisi"""
    position: Tuple[float, float]
    content: str
    font_size: float = 12.0
    color: Tuple[float, float, float] = (0.0, 0.0, 0.0)

class PDFParser:
    """PDF dosyalarından geometrik çizimleri çıkaran ana sınıf"""
    
    def __init__(self, config: ConversionConfig):
        """
        PDF Parser başlatıcı
        
        Args:
            config: Dönüştürme konfigürasyonu
        """
        self.config = config
        self.parser_config = PDFParserConfig()
        self.geometries: List[GeometryObject] = []
        
    def parse_pdf(self, pdf_path: str) -> List[GeometryObject]:
        """
        PDF dosyasını parse eder ve geometrik nesneleri çıkarır
        
        Args:
            pdf_path: PDF dosya yolu
            
        Returns:
            List[GeometryObject]: Çıkarılan geometrik nesneler
        """
        logger.info(f"PDF dosyası parse ediliyor: {pdf_path}")
        
        try:
            # PyMuPDF ile vektör çizimlerini çıkar
            vector_geometries = self._extract_vector_graphics(pdf_path)
            
            # PDFPlumber ile çizgi ve şekilleri çıkar
            line_geometries = self._extract_lines_with_pdfplumber(pdf_path)
            
            # Tüm geometrileri birleştir
            all_geometries = vector_geometries + line_geometries
            
            # Geometrileri filtrele ve temizle
            filtered_geometries = self._filter_geometries(all_geometries)
            
            self.geometries = filtered_geometries
            logger.info(f"Toplam {len(filtered_geometries)} geometrik nesne çıkarıldı")
            
            return filtered_geometries
            
        except Exception as e:
            logger.error(f"PDF parse hatası: {str(e)}")
            raise
    
    def _extract_vector_graphics(self, pdf_path: str) -> List[GeometryObject]:
        """
        PyMuPDF kullanarak vektör grafiklerini çıkarır
        
        Args:
            pdf_path: PDF dosya yolu
            
        Returns:
            List[GeometryObject]: Vektör grafik nesneleri
        """
        geometries = []
        
        try:
            doc = fitz.open(pdf_path)
            
            for page_num in range(len(doc)):
                page = doc[page_num]
                
                # Sayfadan çizimleri çıkar
                drawings = page.get_drawings()
                
                for drawing in drawings:
                    geometries.extend(self._process_drawing(drawing, page_num))
            
            doc.close()
            
        except Exception as e:
            logger.error(f"Vektör grafik çıkarma hatası: {str(e)}")
        
        return geometries
    
    def _process_drawing(self, drawing: Dict, page_num: int) -> List[GeometryObject]:
        """
        Tek bir çizimi işler ve geometrik nesnelere dönüştürür
        
        Args:
            drawing: PyMuPDF çizim verisi
            page_num: Sayfa numarası
            
        Returns:
            List[GeometryObject]: İşlenmiş geometrik nesneler
        """
        geometries = []
        
        try:
            items = drawing.get("items", [])
            fill_color = drawing.get("fill", (0, 0, 0))
            stroke_color = drawing.get("color", (0, 0, 0))
            line_width = drawing.get("width", 1.0)
            
            for item in items:
                item_type = item[0]
                
                if item_type == "l":  # Line
                    start, end = item[1], item[2]
                    line = Line(
                        start=start,
                        end=end,
                        width=line_width,
                        color=stroke_color
                    )
                    geometries.append(self._line_to_geometry(line, page_num))
                    
                elif item_type == "re":  # Rectangle
                    rect_coords = item[1]
                    rectangle = Rectangle(
                        top_left=(rect_coords.x0, rect_coords.y0),
                        bottom_right=(rect_coords.x1, rect_coords.y1),
                        width=line_width,
                        color=stroke_color,
                        filled=bool(drawing.get("fill"))
                    )
                    geometries.append(self._rectangle_to_geometry(rectangle, page_num))
                    
                elif item_type == "c":  # Bezier curve
                    p1, p2, p3, p4 = item[1], item[2], item[3], item[4]
                    curve = Curve(
                        control_points=[p1, p2, p3, p4],
                        curve_type="bezier",
                        width=line_width,
                        color=stroke_color
                    )
                    geometries.append(self._curve_to_geometry(curve, page_num))
                    
                elif item_type == "qu":  # Quad (dörtgen)
                    quad_coords = item[1]
                    # Dörtgeni çizgilere dönüştür
                    points = [
                        (quad_coords.ul.x, quad_coords.ul.y),
                        (quad_coords.ur.x, quad_coords.ur.y),
                        (quad_coords.lr.x, quad_coords.lr.y),
                        (quad_coords.ll.x, quad_coords.ll.y)
                    ]
                    
                    for i in range(len(points)):
                        start = points[i]
                        end = points[(i + 1) % len(points)]
                        line = Line(
                            start=start,
                            end=end,
                            width=line_width,
                            color=stroke_color
                        )
                        geometries.append(self._line_to_geometry(line, page_num))
        
        except Exception as e:
            logger.error(f"Çizim işleme hatası: {str(e)}")
        
        return geometries
    
    def _extract_lines_with_pdfplumber(self, pdf_path: str) -> List[GeometryObject]:
        """
        PDFPlumber kullanarak çizgileri çıkarır
        
        Args:
            pdf_path: PDF dosya yolu
            
        Returns:
            List[GeometryObject]: Çıkarılan çizgi nesneleri
        """
        geometries = []
        
        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages):
                    
                    # Çizgileri çıkar
                    lines = page.lines
                    for line in lines:
                        if line.get('linewidth', 0) > 0:  # Sadece görünür çizgiler
                            line_obj = Line(
                                start=(line['x0'], line['y0']),
                                end=(line['x1'], line['y1']),
                                width=line.get('linewidth', 1.0),
                                color=self._get_line_color(line)
                            )
                            geometries.append(self._line_to_geometry(line_obj, page_num))
                    
                    # Eğrileri çıkar
                    curves = page.curves
                    for curve in curves:
                        if len(curve.get('points', [])) >= 3:
                            curve_obj = Curve(
                                control_points=curve['points'],
                                curve_type="bezier",
                                width=curve.get('linewidth', 1.0),
                                color=self._get_line_color(curve)
                            )
                            geometries.append(self._curve_to_geometry(curve_obj, page_num))
                    
                    # Dikdörtgenleri çıkar
                    rects = page.rects
                    for rect in rects:
                        rectangle = Rectangle(
                            top_left=(rect['x0'], rect['y0']),
                            bottom_right=(rect['x1'], rect['y1']),
                            width=rect.get('linewidth', 1.0),
                            color=self._get_line_color(rect),
                            filled=bool(rect.get('non_stroking_color'))
                        )
                        geometries.append(self._rectangle_to_geometry(rectangle, page_num))
        
        except Exception as e:
            logger.error(f"PDFPlumber çıkarma hatası: {str(e)}")
        
        return geometries
    
    def _filter_geometries(self, geometries: List[GeometryObject]) -> List[GeometryObject]:
        """
        Geometrileri filtreler ve temizler
        
        Args:
            geometries: Filtrelenecek geometriler
            
        Returns:
            List[GeometryObject]: Filtrelenmiş geometriler
        """
        filtered = []
        
        for geom in geometries:
            # Minimum uzunluk kontrolü
            if self._is_geometry_valid(geom):
                filtered.append(geom)
        
        # Performans için maksimum nesne sayısını kontrol et
        if len(filtered) > self.parser_config.max_objects_per_page:
            logger.warning(f"Çok fazla geometri ({len(filtered)}), performans için sınırlanıyor")
            filtered = filtered[:self.parser_config.max_objects_per_page]
        
        return filtered
    
    def _is_geometry_valid(self, geom: GeometryObject) -> bool:
        """
        Geometrinin geçerli olup olmadığını kontrol eder
        
        Args:
            geom: Kontrol edilecek geometri
            
        Returns:
            bool: Geometri geçerli mi
        """
        try:
            if geom.object_type == "line":
                coords = geom.coordinates
                if len(coords) >= 2:
                    start, end = coords[0], coords[1]
                    length = np.sqrt((end[0] - start[0])**2 + (end[1] - start[1])**2)
                    return length >= self.config.min_line_length
                    
            elif geom.object_type == "curve":
                # Eğri için minimum kontrol noktası sayısı
                return len(geom.coordinates) >= 3
                
            elif geom.object_type in ["rectangle", "circle"]:
                return len(geom.coordinates) >= 2
                
            return True
            
        except Exception:
            return False
    
    def _get_line_color(self, line_data: Dict) -> Tuple[float, float, float]:
        """
        Çizgi rengini çıkarır
        
        Args:
            line_data: Çizgi verisi
            
        Returns:
            Tuple[float, float, float]: RGB renk değerleri
        """
        stroke_color = line_data.get('stroking_color')
        if stroke_color and len(stroke_color) >= 3:
            return tuple(stroke_color[:3])
        return (0.0, 0.0, 0.0)  # Varsayılan siyah
    
    def _line_to_geometry(self, line: Line, page_num: int) -> GeometryObject:
        """Çizgiyi GeometryObject'e dönüştürür"""
        return GeometryObject(
            object_type="line",
            coordinates=[line.start, line.end],
            properties={
                "width": line.width,
                "color": line.color,
                "length": np.sqrt((line.end[0] - line.start[0])**2 + (line.end[1] - line.start[1])**2)
            },
            page_number=page_num
        )
    
    def _curve_to_geometry(self, curve: Curve, page_num: int) -> GeometryObject:
        """Eğriyi GeometryObject'e dönüştürür"""
        return GeometryObject(
            object_type="curve",
            coordinates=curve.control_points,
            properties={
                "curve_type": curve.curve_type,
                "width": curve.width,
                "color": curve.color,
                "segments": self.parser_config.bezier_curve_segments
            },
            page_number=page_num
        )
    
    def _rectangle_to_geometry(self, rectangle: Rectangle, page_num: int) -> GeometryObject:
        """Dikdörtgeni GeometryObject'e dönüştürür"""
        return GeometryObject(
            object_type="rectangle",
            coordinates=[rectangle.top_left, rectangle.bottom_right],
            properties={
                "width": rectangle.width,
                "color": rectangle.color,
                "filled": rectangle.filled,
                "area": abs((rectangle.bottom_right[0] - rectangle.top_left[0]) * 
                           (rectangle.bottom_right[1] - rectangle.top_left[1]))
            },
            page_number=page_num
        )
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Parse edilen geometriler hakkında istatistik döndürür
        
        Returns:
            Dict[str, Any]: İstatistik verileri
        """
        if not self.geometries:
            return {}
        
        stats = {
            "total_objects": len(self.geometries),
            "by_type": {},
            "by_page": {},
            "total_lines": 0,
            "total_curves": 0,
            "total_rectangles": 0,
            "total_circles": 0
        }
        
        for geom in self.geometries:
            # Tip bazında sayım
            if geom.object_type not in stats["by_type"]:
                stats["by_type"][geom.object_type] = 0
            stats["by_type"][geom.object_type] += 1
            
            # Sayfa bazında sayım
            if geom.page_number not in stats["by_page"]:
                stats["by_page"][geom.page_number] = 0
            stats["by_page"][geom.page_number] += 1
            
            # Toplam sayılar
            if geom.object_type == "line":
                stats["total_lines"] += 1
            elif geom.object_type == "curve":
                stats["total_curves"] += 1
            elif geom.object_type == "rectangle":
                stats["total_rectangles"] += 1
            elif geom.object_type == "circle":
                stats["total_circles"] += 1
        
        return stats

