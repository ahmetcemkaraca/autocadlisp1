#!/usr/bin/env python3
"""
Converter Test Module
PDF to DXF dönüştürücü birim testlerini içerir.
"""

import unittest
import tempfile
import os
from pathlib import Path
import sys

# Proje root dizinini path'e ekle
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.pdf_to_dxf.geometry_converter import GeometryConverter, DXFGeometry
from src.pdf_to_dxf.dxf_writer import DXFWriter
from src.pdf_to_dxf.pdf_parser import GeometryObject
from src.pdf_to_dxf.config import ConversionConfig

class TestGeometryConverter(unittest.TestCase):
    """Geometri dönüştürücü birim testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
        self.converter = GeometryConverter(self.config)
    
    def test_converter_initialization(self):
        """Dönüştürücü başlatma testi"""
        self.assertIsNotNone(self.converter)
        self.assertEqual(self.converter.config, self.config)
        self.assertEqual(len(self.converter.dxf_geometries), 0)
        self.assertEqual(self.converter.scale_factor, 1.0)
        self.assertEqual(self.converter.offset_x, 0.0)
        self.assertEqual(self.converter.offset_y, 0.0)
    
    def test_coordinate_transformation(self):
        """Koordinat dönüştürme testi"""
        # Basit koordinat dönüştürme
        coord = (10.0, 20.0)
        transformed = self.converter._transform_coordinate(coord)
        
        self.assertEqual(transformed, (10.0, 20.0, 0.0))
        
        # Offset ile koordinat dönüştürme
        self.converter.offset_x = 5.0
        self.converter.offset_y = -10.0
        transformed = self.converter._transform_coordinate(coord)
        
        self.assertEqual(transformed, (15.0, 10.0, 0.0))
        
        # Ölçeklendirme ile koordinat dönüştürme
        self.converter.scale_factor = 2.0
        transformed = self.converter._transform_coordinate(coord)
        
        self.assertEqual(transformed, (30.0, 20.0, 0.0))
    
    def test_dxf_color_conversion(self):
        """DXF renk dönüştürme testi"""
        # Kırmızı renk
        red_color = (1.0, 0.0, 0.0)
        dxf_color = self.converter._get_dxf_color(red_color)
        self.assertEqual(dxf_color, 1)
        
        # Yeşil renk
        green_color = (0.0, 1.0, 0.0)
        dxf_color = self.converter._get_dxf_color(green_color)
        self.assertEqual(dxf_color, 3)
        
        # Mavi renk
        blue_color = (0.0, 0.0, 1.0)
        dxf_color = self.converter._get_dxf_color(blue_color)
        self.assertEqual(dxf_color, 5)
        
        # Siyah renk (varsayılan)
        black_color = (0.0, 0.0, 0.0)
        dxf_color = self.converter._get_dxf_color(black_color)
        self.assertEqual(dxf_color, 0)
    
    def test_layer_name_generation(self):
        """Katman adı oluşturma testi"""
        # Katman oluşturma açık
        layer_name = self.converter._get_layer_name("LINES")
        expected = f"{self.config.layer_prefix}LINES"
        self.assertEqual(layer_name, expected)
        
        # Katman oluşturma kapalı
        self.config.create_layers = False
        layer_name = self.converter._get_layer_name("LINES")
        self.assertEqual(layer_name, "0")
        
        # Katman oluşturmayı tekrar aç
        self.config.create_layers = True
    
    def test_radius_calculation(self):
        """Yarıçap hesaplama testi"""
        center = (0, 0)
        point = (3, 4)  # 3-4-5 üçgeni
        radius = self.converter._calculate_radius(center, point)
        
        self.assertAlmostEqual(radius, 5.0, places=6)
        
        # Ölçeklendirme ile
        self.converter.scale_factor = 2.0
        radius = self.converter._calculate_radius(center, point)
        self.assertAlmostEqual(radius, 10.0, places=6)
    
    def test_bezier_curve_approximation(self):
        """Bezier eğri yaklaşımı testi"""
        control_points = [(0, 0), (5, 5), (10, 0), (15, 5)]
        approximated = self.converter._approximate_bezier_curve(control_points)
        
        self.assertIsInstance(approximated, list)
        self.assertGreater(len(approximated), len(control_points))
        
        # İlk ve son noktaların kontrol noktalarıyla eşleşmesi
        self.assertEqual(approximated[0], control_points[0])
        self.assertEqual(approximated[-1], control_points[-1])
    
    def test_line_conversion(self):
        """Çizgi dönüştürme testi"""
        # Test geometrisi oluştur
        pdf_geometry = GeometryObject(
            object_type="line",
            coordinates=[(0, 0), (10, 10)],
            properties={"width": 2.0, "color": (1, 0, 0)},
            page_number=0
        )
        
        dxf_geometry = self.converter._convert_line(pdf_geometry)
        
        self.assertIsInstance(dxf_geometry, DXFGeometry)
        self.assertEqual(dxf_geometry.entity_type, "LINE")
        self.assertEqual(len(dxf_geometry.coordinates), 2)
        self.assertEqual(dxf_geometry.properties['width'], 2.0)
        self.assertEqual(dxf_geometry.properties['color'], 1)  # Kırmızı
    
    def test_curve_conversion(self):
        """Eğri dönüştürme testi"""
        # Test geometrisi oluştur
        pdf_geometry = GeometryObject(
            object_type="curve",
            coordinates=[(0, 0), (5, 5), (10, 0), (15, 5)],
            properties={"curve_type": "bezier", "width": 1.5, "color": (0, 1, 0)},
            page_number=0
        )
        
        dxf_geometry = self.converter._convert_curve(pdf_geometry)
        
        self.assertIsInstance(dxf_geometry, DXFGeometry)
        self.assertEqual(dxf_geometry.entity_type, "POLYLINE")
        self.assertGreater(len(dxf_geometry.coordinates), 4)  # Yaklaşık noktalar
        self.assertEqual(dxf_geometry.properties['width'], 1.5)
        self.assertEqual(dxf_geometry.properties['color'], 3)  # Yeşil
    
    def test_rectangle_conversion(self):
        """Dikdörtgen dönüştürme testi"""
        # Test geometrisi oluştur
        pdf_geometry = GeometryObject(
            object_type="rectangle",
            coordinates=[(0, 0), (10, 10)],
            properties={"width": 1.0, "color": (0, 0, 1), "filled": True},
            page_number=0
        )
        
        dxf_geometry = self.converter._convert_rectangle(pdf_geometry)
        
        self.assertIsInstance(dxf_geometry, DXFGeometry)
        self.assertEqual(dxf_geometry.entity_type, "POLYLINE")
        self.assertEqual(len(dxf_geometry.coordinates), 5)  # 4 köşe + kapanış
        self.assertTrue(dxf_geometry.properties['closed'])
        self.assertTrue(dxf_geometry.properties['filled'])
        self.assertEqual(dxf_geometry.properties['color'], 5)  # Mavi
    
    def test_circle_conversion(self):
        """Daire dönüştürme testi"""
        # Test geometrisi oluştur
        pdf_geometry = GeometryObject(
            object_type="circle",
            coordinates=[(5, 5), (8, 5)],  # Merkez ve yarıçap noktası
            properties={"width": 2.0, "color": (1, 1, 0), "filled": False},
            page_number=0
        )
        
        dxf_geometry = self.converter._convert_circle(pdf_geometry)
        
        self.assertIsInstance(dxf_geometry, DXFGeometry)
        self.assertEqual(dxf_geometry.entity_type, "CIRCLE")
        self.assertEqual(len(dxf_geometry.coordinates), 1)  # Sadece merkez
        self.assertEqual(dxf_geometry.properties['radius'], 3.0)  # (8-5) = 3
        self.assertFalse(dxf_geometry.properties['filled'])
        self.assertEqual(dxf_geometry.properties['color'], 2)  # Sarı

class TestDXFWriter(unittest.TestCase):
    """DXF Writer birim testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
        self.writer = DXFWriter(self.config)
    
    def test_writer_initialization(self):
        """Writer başlatma testi"""
        self.assertIsNotNone(self.writer)
        self.assertEqual(self.writer.config, self.config)
        self.assertIsNone(self.writer.doc)
        self.assertIsNone(self.writer.msp)
    
    def test_dxf_document_creation(self):
        """DXF doküman oluşturma testi"""
        doc = self.writer.create_dxf_document()
        
        self.assertIsNotNone(doc)
        self.assertIsNotNone(self.writer.msp)
        self.assertEqual(doc.dxfversion, self.config.dxf_version)
    
    def test_default_layers_creation(self):
        """Varsayılan katmanlar oluşturma testi"""
        self.writer.create_dxf_document()
        self.writer._create_default_layers()
        
        # Katmanların varlığını kontrol et
        expected_layers = ["LINES", "CURVES", "RECTANGLES", "CIRCLES", "TEXT", "DIMENSIONS"]
        
        for layer_name in expected_layers:
            self.assertTrue(self.writer.doc.layers.has_entry(layer_name))
    
    def test_document_properties_setting(self):
        """Doküman özellikleri ayarlama testi"""
        self.writer.create_dxf_document()
        self.writer._set_document_properties()
        
        # Temel özellikleri kontrol et
        self.assertEqual(self.writer.doc.header['$ACADVER'], self.config.dxf_version)
        
        # Birim ayarını kontrol et
        if self.config.units == "mm":
            self.assertEqual(self.writer.doc.header['$INSUNITS'], 4)
    
    def test_line_writing(self):
        """Çizgi yazma testi"""
        self.writer.create_dxf_document()
        
        # Test DXF geometrisi
        dxf_geometry = DXFGeometry(
            entity_type="LINE",
            coordinates=[(0, 0, 0), (10, 10, 0)],
            properties={"width": 1.0, "color": 1},
            layer="LINES"
        )
        
        self.writer._write_line(dxf_geometry)
        
        # Modelspace'de çizgi varlığını kontrol et
        lines = list(self.writer.msp.query('LINE'))
        self.assertEqual(len(lines), 1)
        
        line = lines[0]
        self.assertEqual(line.dxf.start, (0, 0, 0))
        self.assertEqual(line.dxf.end, (10, 10, 0))
        self.assertEqual(line.dxf.color, 1)
    
    def test_polyline_writing(self):
        """Polyline yazma testi"""
        self.writer.create_dxf_document()
        
        # Test DXF geometrisi
        dxf_geometry = DXFGeometry(
            entity_type="POLYLINE",
            coordinates=[(0, 0, 0), (10, 0, 0), (10, 10, 0), (0, 10, 0), (0, 0, 0)],
            properties={"width": 2.0, "color": 3, "closed": True},
            layer="RECTANGLES"
        )
        
        self.writer._write_polyline(dxf_geometry)
        
        # Modelspace'de polyline varlığını kontrol et
        polylines = list(self.writer.msp.query('POLYLINE'))
        self.assertEqual(len(polylines), 1)
        
        polyline = polylines[0]
        self.assertEqual(polyline.dxf.color, 3)
        self.assertTrue(polyline.closed)
    
    def test_circle_writing(self):
        """Daire yazma testi"""
        self.writer.create_dxf_document()
        
        # Test DXF geometrisi
        dxf_geometry = DXFGeometry(
            entity_type="CIRCLE",
            coordinates=[(5, 5, 0)],
            properties={"radius": 3.0, "width": 1.5, "color": 5},
            layer="CIRCLES"
        )
        
        self.writer._write_circle(dxf_geometry)
        
        # Modelspace'de daire varlığını kontrol et
        circles = list(self.writer.msp.query('CIRCLE'))
        self.assertEqual(len(circles), 1)
        
        circle = circles[0]
        self.assertEqual(circle.dxf.center, (5, 5, 0))
        self.assertEqual(circle.dxf.radius, 3.0)
        self.assertEqual(circle.dxf.color, 5)
    
    def test_text_writing(self):
        """Metin yazma testi"""
        self.writer.create_dxf_document()
        
        # Test DXF geometrisi
        dxf_geometry = DXFGeometry(
            entity_type="TEXT",
            coordinates=[(0, 0, 0)],
            properties={"text": "Test Text", "height": 12.0, "color": 2},
            layer="TEXT"
        )
        
        self.writer._write_text(dxf_geometry)
        
        # Modelspace'de metin varlığını kontrol et
        texts = list(self.writer.msp.query('TEXT'))
        self.assertEqual(len(texts), 1)
        
        text = texts[0]
        self.assertEqual(text.dxf.text, "Test Text")
        self.assertEqual(text.dxf.height, 12.0)
        self.assertEqual(text.dxf.color, 2)
    
    def test_dxf_file_saving(self):
        """DXF dosya kaydetme testi"""
        self.writer.create_dxf_document()
        
        # Test geometrisi ekle
        dxf_geometry = DXFGeometry(
            entity_type="LINE",
            coordinates=[(0, 0, 0), (10, 10, 0)],
            properties={"width": 1.0, "color": 1},
            layer="0"
        )
        self.writer._write_line(dxf_geometry)
        
        # Geçici dosyaya kaydet
        with tempfile.NamedTemporaryFile(suffix='.dxf', delete=False) as temp_file:
            temp_file_path = temp_file.name
        
        try:
            saved_path = self.writer.save_dxf_file(temp_file_path)
            
            self.assertEqual(saved_path, temp_file_path)
            self.assertTrue(os.path.exists(temp_file_path))
            self.assertGreater(os.path.getsize(temp_file_path), 0)
            
        finally:
            if os.path.exists(temp_file_path):
                os.unlink(temp_file_path)
    
    def test_document_statistics(self):
        """Doküman istatistikleri testi"""
        self.writer.create_dxf_document()
        
        # Test geometrileri ekle
        test_geometries = [
            DXFGeometry("LINE", [(0, 0, 0), (10, 10, 0)], {"color": 1}, "LINES"),
            DXFGeometry("CIRCLE", [(5, 5, 0)], {"radius": 3.0, "color": 2}, "CIRCLES"),
            DXFGeometry("TEXT", [(0, 0, 0)], {"text": "Test", "height": 12.0, "color": 3}, "TEXT")
        ]
        
        for geom in test_geometries:
            if geom.entity_type == "LINE":
                self.writer._write_line(geom)
            elif geom.entity_type == "CIRCLE":
                self.writer._write_circle(geom)
            elif geom.entity_type == "TEXT":
                self.writer._write_text(geom)
        
        stats = self.writer.get_document_statistics()
        
        self.assertEqual(stats['total_entities'], 3)
        self.assertEqual(stats['entity_counts']['LINE'], 1)
        self.assertEqual(stats['entity_counts']['CIRCLE'], 1)
        self.assertEqual(stats['entity_counts']['TEXT'], 1)

class TestConverterIntegration(unittest.TestCase):
    """Dönüştürücü entegrasyon testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
    
    def test_full_conversion_pipeline(self):
        """Tam dönüştürme pipeline testi"""
        # Test PDF geometrileri
        test_pdf_geometries = [
            GeometryObject(
                object_type="line",
                coordinates=[(0, 0), (10, 10)],
                properties={"width": 1.0, "color": (1, 0, 0)},
                page_number=0
            ),
            GeometryObject(
                object_type="curve",
                coordinates=[(0, 0), (5, 5), (10, 0)],
                properties={"curve_type": "bezier", "width": 2.0, "color": (0, 1, 0)},
                page_number=0
            )
        ]
        
        # Dönüştürme işlemi
        converter = GeometryConverter(self.config)
        dxf_geometries = converter.convert_geometries(test_pdf_geometries)
        
        self.assertEqual(len(dxf_geometries), 2)
        self.assertEqual(dxf_geometries[0].entity_type, "LINE")
        self.assertEqual(dxf_geometries[1].entity_type, "POLYLINE")
        
        # DXF yazma işlemi
        writer = DXFWriter(self.config)
        writer.create_dxf_document()
        writer.write_geometries(dxf_geometries)
        
        # Sonuçları kontrol et
        doc_stats = writer.get_document_statistics()
        self.assertGreater(doc_stats['total_entities'], 0)
        
        writer.close_document()

if __name__ == '__main__':
    # Test suite oluştur
    test_suite = unittest.TestSuite()
    
    # Test sınıflarını ekle
    test_classes = [
        TestGeometryConverter,
        TestDXFWriter,
        TestConverterIntegration
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_suite.addTests(tests)
    
    # Testleri çalıştır
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Sonuçları yazdır
    print(f"\n{'='*50}")
    print(f"Toplam test: {result.testsRun}")
    print(f"Başarılı: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Başarısız: {len(result.failures)}")
    print(f"Hata: {len(result.errors)}")
    
    if result.failures:
        print(f"\nBaşarısız testler:")
        for test, traceback in result.failures:
            print(f"- {test}: {traceback}")
    
    if result.errors:
        print(f"\nHatalı testler:")
        for test, traceback in result.errors:
            print(f"- {test}: {traceback}")

