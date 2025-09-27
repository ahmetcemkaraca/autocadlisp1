#!/usr/bin/env python3
"""
PDF to DXF Converter - Gelişmiş Kullanım Örnekleri
Karmaşık dönüştürme senaryoları ve özel konfigürasyonlar gösterir.
"""

import sys
import os
import json
from pathlib import Path
from typing import List, Dict, Any

# Proje root dizinini path'e ekle
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.pdf_to_dxf import (
    PDFToDXFConverter, 
    ConversionConfig, 
    PDFParser, 
    GeometryConverter, 
    DXFWriter,
    save_config_to_file,
    load_config_from_file
)

class AdvancedPDFToDXFConverter:
    """Gelişmiş PDF to DXF dönüştürücü sınıfı"""
    
    def __init__(self):
        self.converter = None
        self.conversion_log = []
    
    def setup_converter(self, config: ConversionConfig):
        """Dönüştürücüyü kurar"""
        self.converter = PDFToDXFConverter(config)
    
    def convert_with_analysis(self, input_pdf: str, output_dxf: str) -> Dict[str, Any]:
        """
        Detaylı analiz ile dönüştürme yapar
        
        Args:
            input_pdf: Giriş PDF dosyası
            output_dxf: Çıkış DXF dosyası
            
        Returns:
            Dict[str, Any]: Dönüştürme analiz raporu
        """
        if not self.converter:
            raise RuntimeError("Dönüştürücü kurulmamış")
        
        analysis = {
            "input_file": input_pdf,
            "output_file": output_dxf,
            "success": False,
            "parse_stats": {},
            "conversion_stats": {},
            "document_stats": {},
            "errors": []
        }
        
        try:
            # 1. PDF analizi
            print("📊 PDF analizi yapılıyor...")
            pdf_geometries = self.converter.parser.parse_pdf(input_pdf)
            analysis["parse_stats"] = self.converter.parser.get_statistics()
            
            if not pdf_geometries:
                analysis["errors"].append("PDF'den geometri çıkarılamadı")
                return analysis
            
            # 2. Dönüştürme analizi
            print("🔄 Geometri dönüştürme analizi...")
            dxf_geometries = self.converter.converter.convert_geometries(pdf_geometries)
            analysis["conversion_stats"] = self.converter.converter.get_conversion_statistics()
            
            if not dxf_geometries:
                analysis["errors"].append("DXF geometrisi oluşturulamadı")
                return analysis
            
            # 3. DXF doküman oluşturma
            print("📝 DXF dokümanı oluşturuluyor...")
            self.converter.writer.create_dxf_document()
            self.converter.writer.write_geometries(dxf_geometries)
            
            # 4. Dosya kaydetme
            print("💾 DXF dosyası kaydediliyor...")
            self.converter.writer.save_dxf_file(output_dxf)
            analysis["document_stats"] = self.converter.writer.get_document_statistics()
            
            # 5. Temizlik
            self.converter.writer.close_document()
            
            analysis["success"] = True
            print("✅ Dönüştürme başarıyla tamamlandı")
            
        except Exception as e:
            analysis["errors"].append(str(e))
            print(f"❌ Dönüştürme hatası: {str(e)}")
        
        self.conversion_log.append(analysis)
        return analysis
    
    def batch_convert_with_report(self, pdf_files: List[str], output_dir: str) -> Dict[str, Any]:
        """
        Toplu dönüştürme ve rapor oluşturma
        
        Args:
            pdf_files: PDF dosya listesi
            output_dir: Çıkış dizini
            
        Returns:
            Dict[str, Any]: Toplu dönüştürme raporu
        """
        batch_report = {
            "total_files": len(pdf_files),
            "successful_conversions": 0,
            "failed_conversions": 0,
            "conversions": [],
            "summary": {}
        }
        
        print(f"🔄 {len(pdf_files)} dosya toplu dönüştürülüyor...")
        
        for i, pdf_file in enumerate(pdf_files, 1):
            print(f"\n📄 [{i}/{len(pdf_files)}] İşleniyor: {Path(pdf_file).name}")
            
            output_file = Path(output_dir) / f"{Path(pdf_file).stem}.dxf"
            
            analysis = self.convert_with_analysis(pdf_file, str(output_file))
            batch_report["conversions"].append(analysis)
            
            if analysis["success"]:
                batch_report["successful_conversions"] += 1
            else:
                batch_report["failed_conversions"] += 1
        
        # Özet istatistikler
        batch_report["summary"] = self._generate_batch_summary(batch_report["conversions"])
        
        return batch_report
    
    def _generate_batch_summary(self, conversions: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Toplu dönüştürme özeti oluşturur"""
        summary = {
            "total_objects_parsed": 0,
            "total_objects_converted": 0,
            "average_objects_per_file": 0,
            "most_common_entity_types": {},
            "layer_usage": {}
        }
        
        successful_conversions = [c for c in conversions if c["success"]]
        
        if successful_conversions:
            # Toplam nesne sayıları
            for conv in successful_conversions:
                parse_stats = conv.get("parse_stats", {})
                doc_stats = conv.get("document_stats", {})
                
                summary["total_objects_parsed"] += parse_stats.get("total_objects", 0)
                summary["total_objects_converted"] += doc_stats.get("total_entities", 0)
            
            # Ortalama nesne sayısı
            summary["average_objects_per_file"] = (
                summary["total_objects_converted"] / len(successful_conversions)
            )
            
            # En yaygın entity tipleri
            entity_counts = {}
            layer_counts = {}
            
            for conv in successful_conversions:
                doc_stats = conv.get("document_stats", {})
                entity_counts_file = doc_stats.get("entity_counts", {})
                
                for entity_type, count in entity_counts_file.items():
                    entity_counts[entity_type] = entity_counts.get(entity_type, 0) + count
                
                layers = doc_stats.get("layers", [])
                for layer in layers:
                    layer_name = layer.get("name", "Unknown")
                    layer_counts[layer_name] = layer_counts.get(layer_name, 0) + 1
            
            summary["most_common_entity_types"] = dict(
                sorted(entity_counts.items(), key=lambda x: x[1], reverse=True)[:5]
            )
            summary["layer_usage"] = layer_counts
        
        return summary
    
    def save_conversion_report(self, report: Dict[str, Any], output_file: str):
        """Dönüştürme raporunu dosyaya kaydeder"""
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"📊 Rapor kaydedildi: {output_file}")

def create_optimized_config_for_large_files() -> ConversionConfig:
    """Büyük dosyalar için optimize edilmiş konfigürasyon"""
    return ConversionConfig(
        dxf_version="R12",  # En uyumlu sürüm
        units="mm",
        precision=3,  # Düşük hassasiyet, daha hızlı işlem
        min_line_length=1.0,  # Daha büyük minimum uzunluk
        max_line_width=5.0,
        curve_tolerance=0.1,  # Daha büyük tolerans
        create_layers=False,  # Katman oluşturma kapalı
        auto_scale=True,
        preserve_scale=False
    )

def create_high_quality_config() -> ConversionConfig:
    """Yüksek kalite konfigürasyonu"""
    return ConversionConfig(
        dxf_version="R2020",
        units="mm",
        precision=8,  # Yüksek hassasiyet
        min_line_length=0.01,  # Çok küçük çizgileri de dahil et
        max_line_width=10.0,
        curve_tolerance=0.001,  # Çok düşük tolerans
        create_layers=True,
        layer_prefix="HQ_",
        auto_scale=False,
        preserve_scale=True
    )

def create_architectural_config() -> ConversionConfig:
    """Mimari çizimler için özel konfigürasyon"""
    config = ConversionConfig(
        dxf_version="R2018",
        units="mm",
        precision=6,
        min_line_length=0.1,
        create_layers=True,
        layer_prefix="ARCH_",
        auto_scale=False,
        preserve_scale=True
    )
    
    # Mimari katmanlar
    config.stroke_color_mapping.update({
        "wall": 7,      # Beyaz
        "door": 1,      # Kırmızı
        "window": 3,    # Yeşil
        "dimension": 6, # Magenta
        "text": 2       # Sarı
    })
    
    return config

def advanced_conversion_example():
    """Gelişmiş dönüştürme örneği"""
    print("PDF to DXF Converter - Gelişmiş Kullanım Örneği")
    print("=" * 60)
    
    # Gelişmiş dönüştürücüyü başlat
    advanced_converter = AdvancedPDFToDXFConverter()
    
    # Yüksek kalite konfigürasyonu
    config = create_high_quality_config()
    advanced_converter.setup_converter(config)
    
    # Tek dosya dönüştürme analizi
    input_pdf = "complex_drawing.pdf"
    output_dxf = "output/complex_drawing_hq.dxf"
    
    if os.path.exists(input_pdf):
        print(f"🔍 Detaylı analiz ile dönüştürülüyor: {input_pdf}")
        analysis = advanced_converter.convert_with_analysis(input_pdf, output_dxf)
        
        print("\n📊 Analiz Sonuçları:")
        print(f"- Başarılı: {'✅' if analysis['success'] else '❌'}")
        print(f"- Parse edilen nesneler: {analysis['parse_stats'].get('total_objects', 0)}")
        print(f"- Dönüştürülen nesneler: {analysis['conversion_stats'].get('total_dxf_objects', 0)}")
        
        if analysis['errors']:
            print(f"- Hatalar: {len(analysis['errors'])}")
            for error in analysis['errors']:
                print(f"  • {error}")
    else:
        print(f"⚠️  Test dosyası bulunamadı: {input_pdf}")

def batch_conversion_with_analysis():
    """Toplu dönüştürme ve analiz örneği"""
    print("\nPDF to DXF Converter - Toplu Dönüştürme Analizi")
    print("=" * 60)
    
    # Toplu dönüştürme için optimize edilmiş konfigürasyon
    config = create_optimized_config_for_large_files()
    advanced_converter = AdvancedPDFToDXFConverter()
    advanced_converter.setup_converter(config)
    
    # Test dosyaları
    pdf_files = [
        "technical_drawing_1.pdf",
        "technical_drawing_2.pdf",
        "floor_plan.pdf",
        "mechanical_part.pdf"
    ]
    
    # Sadece mevcut dosyaları filtrele
    existing_files = [f for f in pdf_files if os.path.exists(f)]
    
    if existing_files:
        print(f"📁 {len(existing_files)} dosya toplu dönüştürülüyor...")
        
        batch_report = advanced_converter.batch_convert_with_report(
            existing_files, 
            "output/batch"
        )
        
        print("\n📊 Toplu Dönüştürme Raporu:")
        print(f"- Toplam dosya: {batch_report['total_files']}")
        print(f"- Başarılı: {batch_report['successful_conversions']}")
        print(f"- Başarısız: {batch_report['failed_conversions']}")
        
        summary = batch_report['summary']
        if summary:
            print(f"- Toplam parse edilen nesne: {summary['total_objects_parsed']}")
            print(f"- Toplam dönüştürülen nesne: {summary['total_objects_converted']}")
            print(f"- Dosya başına ortalama nesne: {summary['average_objects_per_file']:.1f}")
            
            print("\n🏆 En Yaygın Entity Tipleri:")
            for entity_type, count in summary['most_common_entity_types'].items():
                print(f"  • {entity_type}: {count}")
        
        # Raporu kaydet
        advanced_converter.save_conversion_report(
            batch_report, 
            "output/batch_conversion_report.json"
        )
    else:
        print("⚠️  Test dosyaları bulunamadı")

def configuration_comparison_example():
    """Farklı konfigürasyonların karşılaştırılması"""
    print("\nPDF to DXF Converter - Konfigürasyon Karşılaştırması")
    print("=" * 60)
    
    # Farklı konfigürasyonlar
    configs = {
        "Optimized": create_optimized_config_for_large_files(),
        "High Quality": create_high_quality_config(),
        "Architectural": create_architectural_config()
    }
    
    test_file = "test_drawing.pdf"
    
    if os.path.exists(test_file):
        comparison_results = {}
        
        for config_name, config in configs.items():
            print(f"\n🔧 {config_name} konfigürasyonu test ediliyor...")
            
            advanced_converter = AdvancedPDFToDXFConverter()
            advanced_converter.setup_converter(config)
            
            output_file = f"output/comparison_{config_name.lower().replace(' ', '_')}.dxf"
            analysis = advanced_converter.convert_with_analysis(test_file, output_file)
            
            comparison_results[config_name] = {
                "success": analysis['success'],
                "parse_objects": analysis['parse_stats'].get('total_objects', 0),
                "converted_objects": analysis['conversion_stats'].get('total_dxf_objects', 0),
                "processing_time": "N/A",  # Gerçek uygulamada zaman ölçümü eklenebilir
                "file_size": os.path.getsize(output_file) if analysis['success'] else 0
            }
        
        print("\n📊 Karşılaştırma Sonuçları:")
        print("-" * 80)
        print(f"{'Konfigürasyon':<15} {'Başarılı':<8} {'Parse':<8} {'Dönüştür':<8} {'Dosya Boyutu':<12}")
        print("-" * 80)
        
        for config_name, results in comparison_results.items():
            success = "✅" if results['success'] else "❌"
            file_size = f"{results['file_size']/1024:.1f} KB" if results['file_size'] > 0 else "N/A"
            
            print(f"{config_name:<15} {success:<8} {results['parse_objects']:<8} "
                  f"{results['converted_objects']:<8} {file_size:<12}")
    else:
        print(f"⚠️  Test dosyası bulunamadı: {test_file}")

def save_custom_configurations():
    """Özel konfigürasyonları dosyaya kaydet"""
    print("\nPDF to DXF Converter - Özel Konfigürasyon Kaydetme")
    print("=" * 60)
    
    configs = {
        "optimized_config.json": create_optimized_config_for_large_files(),
        "high_quality_config.json": create_high_quality_config(),
        "architectural_config.json": create_architectural_config()
    }
    
    for filename, config in configs.items():
        output_path = f"examples/{filename}"
        save_config_to_file(config, output_path)
        print(f"💾 Konfigürasyon kaydedildi: {output_path}")
    
    print("\n📝 Kullanım örnekleri:")
    for filename in configs.keys():
        print(f"python pdf_to_dxf.py --config examples/{filename} input.pdf output.dxf")

if __name__ == "__main__":
    # Gelişmiş örnekleri çalıştır
    advanced_conversion_example()
    batch_conversion_with_analysis()
    configuration_comparison_example()
    save_custom_configurations()
    
    print("\n" + "=" * 60)
    print("Gelişmiş örnekler tamamlandı!")
    print("Daha fazla bilgi için dokümantasyonu inceleyin.")

