# UniSphere – Event Discovery & Management Platform

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

**UniSphere** is a professional cross-platform event discovery and management application designed for university students. It connects event attendees with organizers through a centralized, persistent, and highly interactive platform.

**Coursework Project:** Software Engineering Theory and Practice (M30819) – University of Portsmouth

---

## 📋 Table of Contents

- [📸 Implementation Evidence](#-implementation-evidence)
- [✨ Key Features](#-key-features)
  - [🎯 For Attendees](#-for-attendees)
  - [🛠️ For Organizers](#️-for-organizers)
- [🛠️ Tech Stack](#️-tech-stack)
- [📁 Project Structure](#-project-structure)
- [⚙️ Installation](#️-installation)
- [🚀 Usage](#-usage)
- [👥 Team & Contributions](#-team--contributions)
- [🗺️ Development Roadmap](#-development-roadmap)
- [📄 License](#-license)

---

## 📸 Implementation Evidence

### **System Architecture & Persistence**
UniSphere has successfully migrated from a mock-based environment to a fully persistent **SQLite** architecture. All user accounts, event listings, and ticket purchases are stored securely in a local relational database, ensuring data integrity across application restarts.

### **UI Stability & Performance**
- ✅ **Zero-Overflow Design**: All screens have been optimized for diverse viewport sizes, resolving previous `RenderFlex` overflow issues.
- ✅ **Resilient Media Loading**: Implemented robust error handling for image decoding to prevent runtime crashes during media fetch.
- ✅ **Clean Data Environment**: System-wide filtering excludes legacy "Demo" artifacts, providing a production-ready user experience.

---

## ✨ Key Features

### 🎯 For Attendees
- **Live Event Discovery**: Interactive maps and smart filters to find nearby campus activities.
- **Persistent Ticketing**: Securely "purchase" and store tickets in a personal wallet.
- **Categorized Search**: Filter events by Technology, Music, Sports, Workshops, and more.
- **Personalized Dashboard**: Track upcoming events and recently viewed activities.

### 🛠️ For Organizers
- **Unified Event Management**: Create, edit, and delete events with a professional form-based interface.
- **Organiser Dashboard**: Overview of all hosted events with status tracking.
- **Interactive Calendar**: Weekly view of scheduled events for better planning.
- **Standardized Branding**: All organizer interactions are unified under the "UniSphere" umbrella for a premium feel.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | High-performance, cross-platform UI for Web & Desktop |
| **Backend** | Express.js (Node.js) | RESTful API for business logic and data routing |
| **Database** | SQLite | Persistent, relational storage for users, events, and tickets |
| **Media Handling** | ImagePicker & XFile | Seamless banner image uploads and binary storage |
| **Maps** | Flutter Map (OSM) | Real-time event location visualization |
| **State Management** | ChangeNotifier | Reactive UI updates across the application |

---

## ⚙️ Installation

### Prerequisites
- **Flutter SDK** (v3.24+)
- **Node.js** (v22+)

### Setup Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/UniSpheree/unisphere-app.git
   cd unisphere-app
   ```

2. **Initialize the Backend**:
   ```bash
   cd backend
   npm install
   npm start
   ```
   *Keep this terminal open.*

3. **Launch the Frontend**:
   *Open a new terminal in the project root.*
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

---

## 🗺️ Development Roadmap

### 🎯 Phase 1: Requirements & Design (COMPLETED)
- ✅ User & System Requirements Specification
- ✅ Use Case & Architectural Diagrams
- ✅ Project Initialization & GitHub Setup

### 🚀 Phase 2: Implementation & Persistence (COMPLETED)
- ✅ Core Authentication & Role Management
- ✅ **SQLite Integration**: Migration to persistent storage
- ✅ Media Handling: Binary storage for event banners
- ✅ **Organizer Tools**: Dashboard, Calendar, and Creation Suite

### 🛡️ Phase 3: Stabilization & Polish (COMPLETED)
- ✅ UI/UX Refinement: Resolving layout overflows and terminology cleanup
- ✅ Error Handling: Implementing resilient media decoding
- ✅ Professional Documentation & README updates

---

## 👥 Team & Contributions

### Team Structure

| Name          | Student ID | Role                                | Key Contributions                                                                |
| ------------- | ---------- | ----------------------------------- | -------------------------------------------------------------------------------- |
| **Achilleas** | 2258434    | **Project Coordinator & Tech Lead** | Requirements oversight, use case diagrams, GitHub setup, implementation strategy |
| **Marinos**   | 2266126    | **Design Co-Lead**                  | Use case diagrams, system requirements collaboration                             |
| **Lily**      | 2279849    | **Requirements Analyst**            | User requirements documentation                                |
| **Alecxis**   | 2278372    | **Systems Analyst**                 | System requirements specification                        |
| **Akim**      | 2306587    | **System Modeller**                 | System models & technical diagrams                                               |
| **Jim**       | 2281534    | **Architecture Designer**           | Architectural design & component diagrams                                        |
| **Nikol**     | 2265796    | **Documentation Lead**              | Final report compilation & editing                                               |

### Project Coordination

**Achilleas** coordinates deliverables, sets internal deadlines, and ensures alignment between requirements, design, and implementation phases. Regular team syncs track progress against the coursework timeline.

### Contribution Guidelines

1. **Branch Naming Convention**:

   - `feat/`: New features (e.g., `feat/event-discovery`)
   - `fix/`: Bug fixes (e.g., `fix/login-error`)
   - `docs/`: Documentation (e.g., `docs/update-readme`)
   - `refactor/`: Code refactoring
   - `test/`: Test additions

2. **Commit Messages**: Follow [Conventional Commits](https://www.conventionalcommits.org/)

   - Format: `type: description`
   - Example: `feat: add filtering by category and distance`

3. **Code Standards**:

   - Follow Dart/Flutter style guide
   - Run `dart format` before committing
   - Add comments for complex logic
   - Write unit tests for new functionality

4. **Review Process**:

   - All PRs require at least one team review
   - Reviewers check: functionality, code quality, testing, documentation
   - No direct pushes to `main` branch

5. **Testing Requirements**:
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for user flows
   - Minimum 80% test coverage for new features

---

## 🗺️ Development Roadmap

### 🎯 Coursework 1 (Dec 2025)

- ✅ **Project Setup**: GitHub organization, repository structure
- ✅ **Requirements**: User & system requirements documented
- ✅ **Design**: Use case diagrams
- ✅ **Architecture**: System modelling in progress
- ✅ **Implementation**: Flutter project initialized
- ✅ **Testing**: Test plans for NFRs under development
- ✅ **Report**: Final compilation pending

### 🚀 Coursework 2 (Jan–May 2026)

- **Phase 1**: Core features (event browsing, user authentication)
- **Phase 2**: Social features (friends, sharing, notifications)
- **Phase 3**: Organizer tools (event creation, analytics, payments)
- **Phase 4**: Optimization, testing, deployment

### ⚠️ Known Limitations

- **iOS Deployment**: Requires Apple Developer account ($99/year)
- **Firebase Limits**: Free tier constraints on database operations
- **Offline Support**: Basic caching implemented; full offline sync in roadmap
- **Payment Processing**: Initial integration with Stripe; additional providers planned

---

## 📄 License

### Academic Use

This project is developed for educational purposes as part of the **Software Engineering Theory and Practice (M30819)** module at the University of Portsmouth.

### Academic Integrity

All team members certify that:

1. This work is original and created by the team
2. All third-party code/resources are properly cited using APA 7 format
3. We adhere to the University's Student Conduct Policy
4. We have watched the University's Plagiarism video tutorial

### Copyright

**Copyright © 2025 UniSphere Development Team**. All rights reserved for original code and documentation. Third-party libraries and frameworks are used under their respective licenses.

### References

All references follow APA 7 format and are included in the final coursework report.

---

## 📞 Contact

### Academic Contacts

- **Module Coordinator**: Dr Claudia Iacob – claudia.iacob@port.ac.uk
- **Academic Tutor**: Eleni Noussi – eleni.noussi@port.ac.uk
- **Student Engagement Officer**: Ana Baker – ana.baker@port.ac.uk

### Project Resources

- **GitHub Organization**: [github.com/UniSpheree](https://github.com/UniSpheree)
- **Main Repository**: [github.com/UniSpheree/unisphere-app](https://github.com/UniSpheree/unisphere-app)
- **Module**: M30819 Software Engineering Theory and Practice
- **Institution**: University of Portsmouth

### Support Services

- **ASDAC**: Additional support for students with disabilities
- **Well-being Service**: Mental health and well-being support
- **Extenuating Circumstances**: For serious issues affecting submission

---

_Last Updated: December 2025_
_Version: 1.0.0 (Coursework 1 Release)_
