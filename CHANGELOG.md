# Changelog

Tüm önemli değişiklikler bu dosyada belgelenecektir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına uygun olarak,
ve bu proje [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kullanmaktadır.

## [Unreleased]

## [1.0.1] - 2025-09-26

### Added
- **Platform Support Expansion**: Android Kotlin, iOS Swift, Flutter, Go Web API, .NET MAUI, Node.js Backend, Prisma ORM instruction files
- **Registry System**: Complete registry and context management system
  - `docs/registry/` klasörü ve şema dosyaları
  - `scripts/validate-registry.ps1` ve `scripts/rehydrate-context.ps1` validation scriptleri
  - Registry README dokumentasyonu
- **Context Management**: `.mds/context/` yapısı ve session tracking sistemi
- **Version Management**: `version.md` dosyası ve 2-prompt versiyonlama prensibi
- **Enhanced UX Guidelines**: Kapsamlı UX instruction dosyası

### Changed
- **Platform Coverage**: 4 platformdan 10+ platforma genişletildi
- **Project Structure**: Registry, scripts, context klasörleri eklendi
- **README.md**: Yeni platform desteği ve registry sistemi belgelendi
- **Teknoloji Desteği**: Mobile (Android/iOS/Flutter) ve additional backend (.NET MAUI/Node.js/Go) desteği

### Technical
- Taslak-App projesinden başarılı entegrasyon tamamlandı
- Registry validation sistemi aktif
- Context rehydration mekanizması kuruldu

## [1.0.0] - 2025-01-19

### Added
- **Geliştirme Kuralları**
  - Git branch workflow (feature/bugfix/docs)
  - Mandatory import verification process  
  - Documentation automation standards
  - Code quality gates (lint/format/test)

- **Teknoloji Desteği**
  - .NET WPF desktop applications
  - Python FastAPI cloud services
  - TypeScript/React web applications
  - AI integration patterns

- **Instruction System**
  - Role-based instruction attachment
  - Technology-specific guidelines
  - Security and performance standards
  - Error handling patterns

- **Registry & Context Management**
  - Persistent context tracking
  - API contract management
  - Data structure standards
  - Version control integration

### Security
- OWASP security defaults
- Input validation patterns
- Secret management standards
- Dependency audit requirements

### Documentation
- Turkish user documentation
- English technical documentation
- Code examples and patterns
- Setup and deployment guides

---

## Versiyon Notları

### Semantic Versioning Kuralları
- **MAJOR**: Breaking changes, API değişiklikleri
- **MINOR**: Yeni özellikler, backward-compatible 
- **PATCH**: Bug fix, performans iyileştirmeleri

### Commit Mesaj Formatı
```
type(scope): description

feat: yeni özellik
fix: bug düzeltmesi  
docs: dokümantasyon
style: format değişiklikleri
refactor: kod restructure
test: test ekleme/düzeltme
chore: build/config değişiklikleri
```

### Release Süreci
1. Version.md güncellemesi
2. CHANGELOG.md entry
3. Git tag oluşturma
4. Release notes hazırlama
5. Documentation güncelleme