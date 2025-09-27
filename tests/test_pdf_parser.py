#!/usr/bin/env python3
"""
PDF Parser Test Module
PDF parser modülünün birim testlerini içerir.
"""

import unittest
import tempfile
import os
from pathlib import Path
import sys

# Proje root dizinini path'e ekle
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.pdf_to_dxf.pdf_parser import PDFParser, Line, Curve, Rectangle, Circle
from src.pdf_to_dxf.config import ConversionConfig

class TestPDFParser(unittest.TestCase):
    """PDF Parser birim testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
        self.parser = PDFParser(self.config)
        
    def test_parser_initialization(self):
        """Parser başlatma testi"""
        self.assertIsNotNone(self.parser)
        self.assertEqual(self.parser.config, self.config)
        self.assertEqual(len(self.parser.geometries), 0)
    
    def test_line_creation(self):
        """Çizgi oluşturma testi"""
        line = Line(
            start=(0, 0),
            end=(10, 10),
            width=1.0,
            color=(0, 0, 0)
        )
        
        self.assertEqual(line.start, (0, 0))
        self.assertEqual(line.end, (10, 10))
        self.assertEqual(line.width, 1.0)
        self.assertEqual(line.color, (0, 0, 0))
    
    def test_curve_creation(self):
        """Eğri oluşturma testi"""
        curve = Curve(
            control_points=[(0, 0), (5, 5), (10, 0), (15, 5)],
            curve_type="bezier",
            width=2.0,
            color=(1, 0, 0)
        )
        
        self.assertEqual(len(curve.control_points), 4)
        self.assertEqual(curve.curve_type, "bezier")
        self.assertEqual(curve.width, 2.0)
        self.assertEqual(curve.color, (1, 0, 0))
    
    def test_rectangle_creation(self):
        """Dikdörtgen oluşturma testi"""
        rectangle = Rectangle(
            top_left=(0, 0),
            bottom_right=(10, 10),
            width=1.0,
            color=(0, 1, 0),
            filled=False
        )
        
        self.assertEqual(rectangle.top_left, (0, 0))
        self.assertEqual(rectangle.bottom_right, (10, 10))
        self.assertEqual(rectangle.width, 1.0)
        self.assertEqual(rectangle.color, (0, 1, 0))
        self.assertFalse(rectangle.filled)
    
    def test_circle_creation(self):
        """Daire oluşturma testi"""
        circle = Circle(
            center=(5, 5),
            radius=3.0,
            width=1.5,
            color=(0, 0, 1),
            filled=True
        )
        
        self.assertEqual(circle.center, (5, 5))
        self.assertEqual(circle.radius, 3.0)
        self.assertEqual(circle.width, 1.5)
        self.assertEqual(circle.color, (0, 0, 1))
        self.assertTrue(circle.filled)
    
    def test_geometry_validation(self):
        """Geometri doğrulama testi"""
        # Geçerli çizgi
        valid_line = self.parser._line_to_geometry(
            Line(start=(0, 0), end=(10, 10)), 0
        )
        self.assertTrue(self.parser._is_geometry_valid(valid_line))
        
        # Geçersiz çizgi (çok kısa)
        invalid_line = self.parser._line_to_geometry(
            Line(start=(0, 0), end=(0.05, 0.05)), 0  # min_line_length'tan küçük
        )
        self.assertFalse(self.parser._is_geometry_valid(invalid_line))
    
    def test_color_extraction(self):
        """Renk çıkarma testi"""
        # Test verisi
        line_data = {
            'stroking_color': [1.0, 0.0, 0.0, 1.0],  # Kırmızı
            'non_stroking_color': [0.0, 1.0, 0.0, 1.0]  # Yeşil
        }
        
        color = self.parser._get_line_color(line_data)
        self.assertEqual(color, (1.0, 0.0, 0.0))
        
        # Renk bilgisi olmayan durum
        no_color_data = {}
        default_color = self.parser._get_line_color(no_color_data)
        self.assertEqual(default_color, (0.0, 0.0, 0.0))
    
    def test_statistics_generation(self):
        """İstatistik oluşturma testi"""
        # Boş geometri listesi
        stats = self.parser.get_statistics()
        self.assertEqual(stats, {})
        
        # Test geometrileri ekle
        test_geometries = [
            self.parser._line_to_geometry(Line(start=(0, 0), end=(10, 10)), 0),
            self.parser._line_to_geometry(Line(start=(5, 5), end=(15, 15)), 0),
            self.parser._curve_to_geometry(
                Curve(control_points=[(0, 0), (5, 5), (10, 0)], curve_type="bezier"), 0
            )
        ]
        
        self.parser.geometries = test_geometries
        stats = self.parser.get_statistics()
        
        self.assertEqual(stats['total_objects'], 3)
        self.assertEqual(stats['by_type']['line'], 2)
        self.assertEqual(stats['by_type']['curve'], 1)
        self.assertEqual(stats['total_lines'], 2)
        self.assertEqual(stats['total_curves'], 1)

class TestPDFParserIntegration(unittest.TestCase):
    """PDF Parser entegrasyon testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
        self.parser = PDFParser(self.config)
    
    def test_nonexistent_file(self):
        """Var olmayan dosya testi"""
        with self.assertRaises(Exception):
            self.parser.parse_pdf("nonexistent_file.pdf")
    
    def test_invalid_pdf_file(self):
        """Geçersiz PDF dosyası testi"""
        # Geçici dosya oluştur
        with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as temp_file:
            temp_file.write(b"Bu bir PDF dosyası değil")
            temp_file_path = temp_file.name
        
        try:
            with self.assertRaises(Exception):
                self.parser.parse_pdf(temp_file_path)
        finally:
            os.unlink(temp_file_path)
    
    def test_empty_pdf_file(self):
        """Boş PDF dosyası testi"""
        # Bu test gerçek bir boş PDF dosyası gerektirir
        # Şimdilik mock test yapalım
        self.parser.geometries = []
        stats = self.parser.get_statistics()
        self.assertEqual(stats, {})

class TestGeometryConversion(unittest.TestCase):
    """Geometri dönüştürme testleri"""
    
    def setUp(self):
        """Test kurulumu"""
        self.config = ConversionConfig()
        self.parser = PDFParser(self.config)
    
    def test_line_to_geometry_conversion(self):
        """Çizgi-çizgi dönüştürme testi"""
        line = Line(start=(0, 0), end=(10, 10), width=2.0, color=(1, 0, 0))
        geometry = self.parser._line_to_geometry(line, 0)
        
        self.assertEqual(geometry.object_type, "line")
        self.assertEqual(geometry.coordinates, [(0, 0), (10, 10)])
        self.assertEqual(geometry.properties['width'], 2.0)
        self.assertEqual(geometry.properties['color'], (1, 0, 0))
        self.assertEqual(geometry.page_number, 0)
    
    def test_curve_to_geometry_conversion(self):
        """Eğri-geometri dönüştürme testi"""
        curve = Curve(
            control_points=[(0, 0), (5, 5), (10, 0)],
            curve_type="bezier",
            width=1.5,
            color=(0, 1, 0)
        )
        geometry = self.parser._curve_to_geometry(curve, 1)
        
        self.assertEqual(geometry.object_type, "curve")
        self.assertEqual(geometry.coordinates, [(0, 0), (5, 5), (10, 0)])
        self.assertEqual(geometry.properties['curve_type'], "bezier")
        self.assertEqual(geometry.properties['width'], 1.5)
        self.assertEqual(geometry.properties['color'], (0, 1, 0))
        self.assertEqual(geometry.page_number, 1)
    
    def test_rectangle_to_geometry_conversion(self):
        """Dikdörtgen-geometri dönüştürme testi"""
        rectangle = Rectangle(
            top_left=(0, 0),
            bottom_right=(10, 10),
            width=1.0,
            color=(0, 0, 1),
            filled=True
        )
        geometry = self.parser._rectangle_to_geometry(rectangle, 2)
        
        self.assertEqual(geometry.object_type, "rectangle")
        self.assertEqual(geometry.coordinates, [(0, 0), (10, 10)])
        self.assertEqual(geometry.properties['width'], 1.0)
        self.assertEqual(geometry.properties['color'], (0, 0, 1))
        self.assertTrue(geometry.properties['filled'])
        self.assertEqual(geometry.page_number, 2)

if __name__ == '__main__':
    # Test suite oluştur
    test_suite = unittest.TestSuite()
    
    # Test sınıflarını ekle
    test_classes = [
        TestPDFParser,
        TestPDFParserIntegration,
        TestGeometryConversion
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

