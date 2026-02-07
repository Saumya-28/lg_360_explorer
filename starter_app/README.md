# Liquid Galaxy Flutter Starter Kit

> **Gemini Summer of Code 2026 - Agentic Programming Contest**  
> A production-ready Flutter starter kit for building Liquid Galaxy applications using Google Antigravity and Gemini AI.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Gemini](https://img.shields.io/badge/Built%20with-Gemini%20AI-4285F4?logo=google)](https://deepmind.google/technologies/gemini/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Agentic Development](#agentic-development)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

This Flutter Starter Kit provides a **production-ready foundation** for building Liquid Galaxy applications. It was developed using **Google Antigravity** with **Gemini AI** as the primary development assistant, showcasing the power of agentic programming in modern software development.

The kit includes:
- ✅ Clean Architecture (Domain, Data, Presentation layers)
- ✅ State Management with Riverpod
- ✅ SSH/SFTP integration for LG communication
- ✅ KML generation utilities
- ✅ Multi-screen support for LG rigs
- ✅ Comprehensive example implementation

---

## ✨ Features

### Core Functionality
- **LG Connection Management**: Secure SSH/SFTP connection handling with robust error management
- **KML Builder**: Comprehensive utility class for generating KML content:
  - Tours with smooth camera movements
  - Information balloons for multi-screen display
  - Placemarks and paths
  - Screen-specific KML targeting
- **Multi-Screen Support**: Dedicated KML rendering for specific LG screens (leftmost, rightmost, center)
- **Tour System**: Native `gx:Tour` implementation with `gx:FlyTo` and `gx:Wait` commands

### Demo Application: Explore Cities 🌆

An automated tour showcasing LG capabilities:
- **5 Major Cities**: New York, Tokyo, Paris, Sydney, Rio de Janeiro
- **Instant Start**: Tour begins immediately upon user action
- **Smooth Navigation**: Automated camera movements with precise timing
- **Rich Information**: City details displayed on dedicated screens
- **Multi-Screen Integration**: 
  - Logo on leftmost screen
  - Information cards on rightmost screen
  - Tour visualization on center screens
- **Continuous Loop**: Seamless transitions between cities

### Technical Highlights
- **Clean Architecture**: Clear separation of Domain, Data, and Presentation layers
- **SOLID Principles**: Dependency injection, single responsibility, interface segregation
- **DRY Code**: Reusable components and utilities throughout
- **State Management**: Riverpod for reactive, testable state handling
- **Error Handling**: Comprehensive error states with user-friendly feedback
- **Responsive UI**: Material Design 3 with custom theming

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/        # App-wide constants (LG settings, colors)
│   ├── theme/           # Material theme configuration
│   └── utils/           # Utility classes (KMLBuilder)
├── data/
│   ├── datasources/     # Remote data sources (SSH/SFTP)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business entities (City, LGConnection)
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── providers/       # Riverpod providers
    ├── screens/         # UI screens
    ├── viewmodels/      # Business logic controllers
    └── widgets/         # Reusable UI components
```

### Design Patterns
- **Repository Pattern**: Abstraction layer for data access
- **Provider Pattern**: Dependency injection and state management
- **MVVM**: Model-View-ViewModel for presentation layer
- **Factory Pattern**: KML generation utilities

### Layer Responsibilities

**Domain Layer**
- Pure business logic
- Entity definitions
- Repository interfaces
- No dependencies on external frameworks

**Data Layer**
- Repository implementations
- Remote data sources (SSH, SFTP)
- Data models with serialization
- External service integration

**Presentation Layer**
- UI screens and widgets
- ViewModels for business logic
- State management with Riverpod
- User interaction handling

---

## 📦 Prerequisites

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Liquid Galaxy Rig** or emulator for testing
- **SSH Access** to LG master machine

---

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/lg-flutter-starter-kit.git
cd lg-flutter-starter-kit/starter_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure LG Connection
Edit `lib/core/constants/lg_constants.dart`:
```dart
static const String defaultHost = 'your-lg-ip';
static const String defaultUsername = 'lg';
static const String defaultPassword = 'your-password';
static const int defaultPort = 22;
static const int defaultScreenCount = 5;
```

### 4. Run the Application
```bash
# For Android emulator
flutter run

# For specific device
flutter run -d <device-id>

# For web
flutter run -d chrome
```

---

## 📖 Usage

### Connecting to Liquid Galaxy

1. Launch the app
2. Tap the **Settings** icon (top-right)
3. Enter your LG rig credentials:
   - **Host**: IP address of LG master
   - **Username**: SSH username (default: `lg`)
   - **Password**: SSH password
   - **Port**: SSH port (default: `22`)
   - **Screens**: Number of screens in your rig
4. Tap **Connect**
5. Wait for confirmation message

### Using Explore Cities

1. From the home screen, tap **Explore Cities** (Pink card)
2. Tap **Start Tour**
3. The tour will automatically:
   - Navigate to each city
   - Display city information on the rightmost screen
   - Show the LG logo on the leftmost screen
   - Loop through all 5 cities continuously
4. Tap **Stop Tour** to end and clear all screens

### Building Your Own Features

The starter kit provides reusable components for common LG operations:

```dart
// Connect to LG
final lgService = ref.read(lgServiceProvider);
await lgService.connect(connection);

// Send KML to master screen
await lgService.sendKML(kmlContent, fileName: 'my_feature.kml');

// Send KML to specific screen
await lgService.sendKMLToSlave(screenNumber, kmlContent);

// Fly to location
await lgService.flyTo(latitude, longitude, zoom, tilt, bearing);

// Clear all screens
await lgService.clearKML();
```

---

## 📁 Project Structure

```
starter_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── lg_constants.dart          # LG configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material theme
│   │   └── utils/
│   │       └── kml_builder.dart           # KML generation utility
│   ├── data/
│   │   ├── datasources/
│   │   │   └── lg_remote_datasource.dart  # SSH/SFTP client
│   │   └── repositories/
│   │       └── lg_repository_impl.dart    # LG repository
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── city.dart                  # City entity
│   │   │   └── lg_connection.dart         # LG connection entity
│   │   └── repositories/
│   │       └── lg_repository.dart         # LG repository interface
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── lg_service_provider.dart   # LG service provider
│   │   ├── screens/
│   │   │   ├── home_screen.dart           # Main screen
│   │   │   ├── settings_screen.dart       # LG settings
│   │   │   └── explore_cities_screen.dart # City tour demo
│   │   ├── viewmodels/
│   │   │   └── city_tour_view_model.dart  # City tour logic
│   │   └── widgets/
│   │       └── feature_card.dart          # Reusable card widget
│   └── main.dart                          # App entry point
├── test/                                  # Unit tests
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

---

## 🤖 Agentic Development

This project was built using **Google Antigravity** with **Gemini AI** as the primary development assistant. The agentic workflow enabled rapid, high-quality development while maintaining best practices.

### Development Process
1. **Planning**: AI-assisted architecture design and feature planning
2. **Implementation**: Iterative code generation with human oversight
3. **Debugging**: AI-powered error analysis and resolution
4. **Optimization**: Performance tuning and code refactoring
5. **Documentation**: Automated documentation generation

### AI Contributions
- ✅ Clean architecture scaffolding
- ✅ SSH/SFTP integration implementation
- ✅ KML generation utilities with tour support
- ✅ State management setup with Riverpod
- ✅ Multi-screen KML targeting logic
- ✅ UI/UX design and implementation
- ✅ Bug fixes and performance optimizations
- ✅ Comprehensive documentation

### Strengths of Agentic Development
- **Rapid Prototyping**: Quick iteration on features and architecture
- **Best Practices**: Automatic adherence to SOLID and DRY principles
- **Code Quality**: Consistent style, naming, and documentation
- **Problem Solving**: Intelligent debugging and optimization assistance
- **Knowledge Transfer**: Built-in documentation and code explanations

### Limitations Encountered
- **Context Limitations**: Required breaking down complex features into smaller tasks
- **Domain Knowledge**: Needed human guidance for LG-specific requirements and protocols
- **Testing**: Manual verification essential for LG hardware integration
- **Edge Cases**: Human oversight needed for unusual scenarios

### Lessons Learned
- Clear, specific prompts yield better results
- Iterative refinement is more effective than one-shot generation
- Human expertise remains critical for domain-specific decisions
- AI excels at boilerplate, patterns, and documentation

---

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/kml_builder_test.dart
```

### Test Coverage
- **Unit Tests**: Core utilities (KMLBuilder, data models)
- **Widget Tests**: UI components and screens
- **Integration Tests**: LG connection flow

### Manual Testing Checklist
- [ ] LG connection establishment
- [ ] Multi-screen KML rendering (left, right, center)
- [ ] City tour smooth transitions
- [ ] Error state handling and user feedback
- [ ] Disconnect/reconnect flow
- [ ] Screen clearing functionality

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and architecture
4. Write tests for new features
5. Update documentation as needed
6. Commit with clear messages (`git commit -m 'Add amazing feature'`)
7. Push to your branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `dart format .`
- Document public APIs with dartdoc comments
- Keep functions small and focused

---

## 📄 License

This project is licensed under the **Apache License 2.0** - see the [LICENSE](LICENSE) file for details.

```
Copyright 2026 Liquid Galaxy Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 🙏 Acknowledgments

- **Liquid Galaxy Project**: For the amazing platform and contest opportunity
- **Google Antigravity & Gemini**: For enabling agentic development
- **Flutter Team**: For the excellent framework
- **Contest Mentors**: Victor and Victor for guidance and inspiration

---

## 📞 Contact & Support

- **Project Repository**: [GitHub](https://github.com/yourusername/lg-flutter-starter-kit)
- **Liquid Galaxy Discord**: `#AI` channel
- **Issues**: [GitHub Issues](https://github.com/yourusername/lg-flutter-starter-kit/issues)
- **Documentation**: [Wiki](https://github.com/yourusername/lg-flutter-starter-kit/wiki)

---

## 🎯 Contest Submission

**Gemini Summer of Code 2026 - Agentic Programming Contest**

**Category**: Flutter  
**Submission Date**: February 2026  
**Video Demo**: [Link to demo video]  
**Developer**: [Your Name]

### Deliverables Checklist
- [x] Flutter Starter Kit with best practices
- [x] Clean Architecture implementation
- [x] Multi-screen LG support
- [x] Comprehensive documentation
- [x] Video demonstration
- [x] Test coverage
- [x] `.agent/` folder with Antigravity skills

---

**Built with ❤️ using Google Antigravity and Gemini AI**
