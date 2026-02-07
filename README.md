# LG Explorer 360

<div align="center">

![LG Logo](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png)

**A Flutter application for exploring cities around the world on Liquid Galaxy**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

</div>

## Demo 

https://github.com/user-attachments/assets/59897c98-15d1-4a86-a6d5-99aa40ace31e


## Overview

LG Explorer 360 is a Flutter application that enables immersive city exploration on Liquid Galaxy rigs. Built with **Clean Architecture**, **Riverpod state management**, and **SSH connectivity via dartssh2**, it provides a seamless way to fly to cities, display information balloons, and visualize content across multiple screens.

### Key Features

- **City Exploration** - Fly to major cities around the world with preset locations
- **Multi-Screen KML** - Display logos on left screen and balloons on right screen
- **Clean Architecture** - Domain, Data, Presentation layers for maintainability
- **Riverpod State Management** - Type-safe, testable state handling
- **LG SSH Connection** - Secure communication with Liquid Galaxy rig
- **KML Builder Utilities** - Easy KML generation for visualizations
- **Information Balloons** - Display rich HTML content with city information
- **LG Operations** - Reboot, clear visualizations, and manage the rig

## Architecture

```
lib/
├── domain/              # Business Logic Layer
│   ├── entities/        # Business objects (LGConnection)
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Business use cases
├── data/                # Data Layer
│   ├── models/          # Data models with JSON serialization
│   ├── datasources/     # Remote/Local data sources
│   └── repositories/    # Repository implementations
├── presentation/        # Presentation Layer
│   ├── providers/       # Riverpod providers
│   ├── screens/         # UI screens
│   └── widgets/         # Reusable widgets
└── core/                # Core utilities
    ├── constants/       # App constants
    ├── services/        # Core services (LGService)
    └── utils/           # Utility classes (KMLBuilder)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Access to a Liquid Galaxy rig (or test environment)
- SSH credentials for the LG master machine

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lg_gemini_starter_kmp/starter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome
   # or
   flutter run -d macos
   ```

## Configuration

### LG Connection Setup

The app will prompt you for connection details on first launch:

- **Host IP**: IP address of the LG master machine (e.g., `192.168.1.42`)
- **Username**: SSH username (default: `lg`)
- **Password**: SSH password
- **Port**: SSH port (default: `22`)
- **Screen Count**: Number of screens in your LG rig (default: `5`)

### Environment Variables (Optional)

Create a `.env` file for default configuration:

```env
LG_HOST=192.168.1.42
LG_PORT=22
LG_USERNAME=lg
LG_PASSWORD=your_password
LG_SCREEN_COUNT=5
```

## Agentic AI Skills System (Development Tools)

This project includes 6 AI agent skills to guide development and future enhancements:

### 1. **Init Agent** (`01_init.md`)
Guides project initialization and LG configuration setup.

### 2. **Brainstorm Agent** (`02_brainstorm.md`)
Helps ideate creative features and "wow factor" visualizations.

### 3. **Plan Agent** (`03_plan.md`)
Creates detailed task breakdowns and implementation roadmaps.

### 4. **Execute Agent** (`04_execute.md`)
Implements features following Clean Architecture and SOLID principles.

### 5. **Review Agent** (`05_review.md`)
Performs strict code reviews checking for:
- Hardcoded strings
- Main thread blocking
- Missing KML headers
- SOLID principles compliance

### 6. **Quiz Agent** (`06_quiz.md`)
Validates understanding through educational assessments.

### Using the Skills

Navigate to `.agent/skills/` and read the skill files to understand each agent's role. Use them as prompts when working with AI coding assistants.

## Usage Examples

### Connecting to LG

```dart
final service = ref.read(lgServiceProvider);

await service.connect(
  host: '192.168.1.42',
  username: 'lg',
  password: 'your_password',
  port: 22,
  screenCount: 5,
);
```

### Sending KML

```dart
// Using KMLBuilder utility
final kml = KMLBuilder.createOrbit(
  longitude: -74.0060,
  latitude: 40.7128,
  range: 5000,
  tilt: 60,
);

final sendKMLUseCase = ref.read(sendKMLToLGProvider);
final result = await sendKMLUseCase(kml);

result.fold(
  (error) => print('Error: $error'),
  (success) => print('KML sent successfully!'),
);
```

### Custom KML

```dart
final kml = KMLBuilder()
  .addHeader()
  .addPlacemark(
    name: 'Taj Mahal',
    longitude: 78.0421,
    latitude: 27.1751,
    description: 'UNESCO World Heritage Site',
  )
  .build();

await service.sendKML(kml);
```

## Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## Dependencies

- **flutter_riverpod** - State management
- **dartssh2** - SSH connectivity
- **dartz** - Functional programming (Either type)
- **equatable** - Value equality
- **logger** - Logging
- **shared_preferences** - Local storage

## Project Structure Best Practices

### Domain Layer
- Define business entities (immutable, Equatable)
- Create abstract repository interfaces
- Implement use cases for business logic

### Data Layer
- Extend entities with data models
- Implement data sources (API, SSH, local)
- Implement repository interfaces with error handling

### Presentation Layer
- Create Riverpod providers for DI
- Build UI screens with ConsumerWidget
- Handle state with StateNotifier

## Security Notes

- **Never commit passwords** to version control
- Use environment variables for sensitive data
- Ensure SSH keys are properly secured
- Validate all user inputs before sending to LG

## Network Requirements

- Device must be on the same network as the LG rig
- SSH access must be enabled on the master machine
- Firewall rules must allow SSH connections (port 22)

## Troubleshooting

### Connection Failed
- Verify IP address is correct
- Check SSH credentials
- Ensure device is on same network
- Verify SSH is enabled on LG master

### KML Not Displaying
- Check KML has proper XML headers
- Verify KML is valid (use KMLBuilder)
- Check Google Earth is running on LG
- Review logs for error messages

## Resources

- [Liquid Galaxy Documentation](https://github.com/LiquidGalaxyLAB)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [KML Reference](https://developers.google.com/kml/documentation)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow Clean Architecture principles
2. Write tests for new features
3. Follow SOLID principles
4. Use the Review Agent to check your code
5. Update documentation

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

- Liquid Galaxy LAB for the amazing platform and support
- Google Summer of Code 2026 program
- Flutter team for the excellent framework
- Riverpod community for state management guidance
- Contributors and testers who helped improve this application

## Contact

For questions or support:
- Open an issue on GitHub
- Contact the Liquid Galaxy LAB team
- Join the LG community discussions

---

<div align="center">

**Built for Google Summer of Code 2026**

[Documentation](docs/) | [Examples](examples/) | [Contributing](CONTRIBUTING.md)

</div>
