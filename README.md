# UniSphere – Event Discovery & Management Platform

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

**UniSphere** is a cross-platform event discovery and management application designed for university students and young adults. It connects event attendees with organizers through a centralized, social, and transparent platform.

**Coursework Project:** Software Engineering Theory and Practice (M30819) – University of Portsmouth

---

## 📋 Table of Contents

- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Usage](#-usage)
- [Team & Contributions](#-team--contributions)
- [Development Roadmap](#-development-roadmap)
- [License](#-license)

---

## ✨ Key Features

### 🎯 For Attendees

- **Centralized Discovery**: Browse events from multiple sources in one place
- **Smart Filtering**: Filter by location, price, category, and distance
- **Social Integration**: See which friends are attending and share events
- **Transparent Pricing**: All fees displayed upfront with no hidden charges
- **Calendar Sync**: One-click addition to Google/Apple/Outlook calendars
- **Personalized Recommendations**: AI-powered suggestions based on interests

### 🛠️ For Organizers

- **Easy Event Creation**: Simple form for creating both small and large events
- **Analytics Dashboard**: Track ticket sales, views, demographics, and engagement
- **Communication Tools**: Send updates and reminders to attendees
- **Payment Integration**: Sell tickets with clear fee breakdowns
- **Capacity Management**: Set guest limits and track RSVPs

---

## 🛠️ Tech Stack

| Layer                | Technology                           | Purpose                                        |
| -------------------- | ------------------------------------ | ---------------------------------------------- |
| **Frontend**         | Flutter (Dart)                       | Cross-platform mobile app (iOS & Android)      |
| **Backend**          | Firebase / PostgreSQL                | Flexible backend options based on requirements |
| **Database**         | Firestore (NoSQL) / PostgreSQL (SQL) | Real-time vs relational data modeling          |
| **Authentication**   | Firebase Auth / Custom OAuth         | Quick integration vs custom security workflows |
| **Maps & Location**  | Google Maps API                      | Event location visualization and geofencing    |
| **State Management** | Provider/Riverpod                    | Efficient state propagation in Flutter         |
| **Version Control**  | Git & GitHub                         | Collaborative development and versioning       |
| **CI/CD**            | GitHub Actions                       | Automated testing, building, and deployment    |

### Technology Decision Rationale

#### **Frontend: Flutter**

We selected **Flutter** for its:

- **Cross-platform capabilities**: Single codebase for iOS and Android
- **Rapid development**: Hot reload for fast iteration
- **Expressive UI**: Rich widget library and customizability
- **Team familiarity**: Existing expertise accelerates development

#### **Backend Options: Firebase vs PostgreSQL**

We maintain flexibility between two backend approaches:

**🔥 Firebase (Serverless)**

- _Pros_: Rapid setup, real-time updates, managed services (Auth, Firestore, Functions)
- _Best for_: Prototyping, real-time features, scaling without server management
- _Use case_: Initial development phase and features requiring instant updates

**🗄️ PostgreSQL (Relational)**

- _Pros_: Strong consistency, complex queries, transaction support, schema control
- _Best for_: Complex data relationships, reporting, financial transactions
- _Use case_: Advanced analytics, payment processing, data integrity requirements

#### **Hybrid Approach Strategy**

Our development plan accommodates both:

1. **Phase 1 (Prototyping)**: Firebase for rapid feature development
2. **Phase 2 (Scaling)**: Evaluate need for PostgreSQL integration
3. **Final Decision**: Driven by specific requirements:
   - **Firebase preferred for**: NFR3 (Performance), FR3 (Notifications), real-time social features
   - **PostgreSQL considered for**: FR5 (Analytics), payment transactions, complex reporting

#### **Other Technologies**

- **Google Maps API**: Essential for location-based features (UR-A3)
- **Provider/Riverpod**: Flutter-recommended state management solutions
- **GitHub Actions**: Enables CI/CD pipelines for quality assurance

This flexible technology strategy ensures we can meet all functional (FR1-FR15) and non-functional (NFR1-NFR8) requirements while adapting to evolving project needs.

---

## 📁 Project Structure

```
unisphere-app/
├── android/ # Android-specific configuration and code
├── ios/ # iOS-specific configuration and code
├── lib/ # Main Dart/Flutter source code
│ └── main.dart # Application entry point
├── linux/ # Linux desktop support
├── macos/ # macOS desktop support
├── test/ # Unit and widget tests
├── web/ # Web platform support
├── windows/ # Windows desktop support
├── .dart_tool/ # Dart build system cache
├── .idea/ # IDE configuration (Android Studio/IntelliJ)
├── .gitignore # Git ignore rules
├── .metadata # Flutter IDE metadata
├── analysis_options.yaml # Dart static analysis configuration
├── pubspec.lock # Locked dependency versions
├── pubspec.yaml # Project dependencies and metadata
└── README.md # This documentation file
```

---

## ⚙️ Installation

### Prerequisites

- **Flutter SDK** (v3.0.0+): [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Firebase Account**: [Create Project](https://console.firebase.google.com/)
- **Git**: [Download Git](https://git-scm.com/downloads)

### Setup Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/UniSpheree/unisphere-app.git
   cd unisphere-app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a new project in [Firebase Console](https://console.firebase.google.com/)
   - Add iOS and Android apps to your project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in `android/app/` and `ios/Runner/` respectively

4. **Run the application**

   ```bash
   # For iOS
   flutter run -d ios

   # For Android
   flutter run -d android
   ```

---

## 🚀 Usage

### Development Commands

```bash
# Run the app in debug mode
flutter run

# Run tests
flutter test

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Analyze code for issues
flutter analyze

# Format code
flutter format lib/
```

### Key Development Workflows

1. **Feature Development**: Create a new branch from `main`
2. **Testing**: Write unit/widget tests for new features
3. **Code Review**: Submit pull requests for team review
4. **Integration**: Merge to `main` after approval

---

### Team & Contributions

| Name      | Role                            | Key Contributions                                                                      |
| --------- | ------------------------------- | -------------------------------------------------------------------------------------- |
| Achilleas | Project Coordinator & Tech Lead | Requirements oversight, use case diagrams, implementation setup, GitHub org management |
| Marinos   | Design Co-Lead                  | Use case diagrams, system requirements oversight                                       |
| Lily      | Requirements Analyst            | User requirements documentation                                                        |
| Alecxis   | Systems Analyst                 | System requirements specification                                                      |
| Akim      | System Modeller                 | System models & technical diagrams                                                     |
| Jim       | Architecture Designer           | Architectural design & component diagrams                                              |
| Nikol     | Documentation Lead              | Final report compilation & editing                                                     |

**Project Coordination:** Achilleas coordinates deliverables, deadlines, and technical integration across all phases.

### Contribution Guidelines

1. **Branch Naming**: `feat/description`, `fix/issue-name`, `docs/update-readme`
2. **Commit Messages**: Use Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
3. **Code Standards**: Follow Dart/Flutter best practices
4. **Review Process**: All PRs require at least one approval
5. **Testing**: New features must include unit/widget tests

---

## 🗺️ Development Roadmap

### Phase 1 (Current – Dec 2025)

- ✅ Project setup and repository initialization
- ✅ Requirements analysis and documentation
- ✅ Basic Flutter project structure
- 🔄 Core event browsing functionality

### Phase 2 (Jan–Mar 2026)

- User authentication implementation
- Event creation and management
- Basic social features (friends, sharing)
- Initial testing framework

### Phase 3 (Apr–May 2026)

- Advanced analytics for organizers
- Payment integration
- Performance optimization
- Final testing and deployment

### Known Limitations (v1.0)

- iOS notifications require Apple Developer account
- Offline functionality limited to cached events
- Advanced analytics require Firebase Blaze plan for scaling

---

## 📄 License

This project is developed for educational purposes as part of the **Software Engineering Theory and Practice (M30819)** module at the University of Portsmouth.

**Academic Integrity Notice**: All team members certify that this work is original and properly referenced. Any third-party code or resources are appropriately cited in accordance with APA 7 guidelines.

---

## 📞 Contact

**Module Coordinator**: Dr Claudia Iacob – claudia.iacob@port.ac.uk  
**GitHub Organization**: [github.com/UniSpheree](https://github.com/UniSpheree)  
**Course**: M30819 Software Engineering Theory and Practice
