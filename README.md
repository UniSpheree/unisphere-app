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

| Layer                | Technology           | Purpose                                                       |
| :------------------- | :------------------- | :------------------------------------------------------------ |
| **Frontend**         | Flutter (Dart)       | High-performance, cross-platform UI for Web & Desktop         |
| **Backend**          | Express.js (Node.js) | RESTful API for business logic and data routing               |
| **Database**         | SQLite               | Persistent, relational storage for users, events, and tickets |
| **Media Handling**   | ImagePicker & XFile  | Seamless banner image uploads and binary storage              |
| **Maps**             | Flutter Map (OSM)    | Real-time event location visualization                        |
| **State Management** | ChangeNotifier       | Reactive UI updates across the application                    |

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

   _Keep this terminal open._

3. **Launch the Frontend**:
   _Open a new terminal in the project root._
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

---

## 🗺️ Development Roadmap

### 🎯 Phase 1: Requirements & Design (COMPLETED – Coursework 1)

- ✅ User & System Requirements Specification
- ✅ Use Case & Architectural Diagrams
- ✅ Project Initialization & GitHub Setup
- ✅ System Architecture Models
- ✅ Problem specification and design documentation

### 🚀 Phase 2: Implementation & Persistence (COMPLETED – Coursework 1/2 Transition)

- ✅ Core Authentication & Role Management
- ✅ **SQLite Integration**: Migration to persistent storage
- ✅ Media Handling: Binary storage for event banners
- ✅ **Organizer Tools**: Dashboard, Calendar, and Creation Suite
- ✅ Event discovery with filtering and pagination
- ✅ Ticket management and user profiles

### 🛡️ Phase 3: Stabilization, Testing & Polish (COMPLETED – Coursework 2)

- ✅ UI/UX Refinement: Resolving layout overflows and terminology cleanup
- ✅ Error Handling: Implementing resilient media decoding
- ✅ Professional Documentation & README updates
- ✅ Comprehensive test plan (200+ test cases)
- ✅ Unit and widget test implementation
- ✅ Backend API and persistence verification

---

## 👥 Team & Contributions

### Team Structure

| Name          | Student ID | Role                                 | Key Contributions                                                                                                                          |
| ------------- | ---------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Achilleas** | 2258434    | **Full-Stack Developer & Tech Lead** | Flutter app scaffolding, core components, create event implementation, event discovery, SQLite persistence, backend integration, test plan |
| **Marinos**   | 2266126    | **Frontend Lead & QA**               | Authentication system (login/register/forgot password), event management UI, user profiles, comprehensive testing infrastructure           |
| **Lily**      | 2279849    | **Dashboard Developer**              | Dashboard implementation and code documentation                                                                                            |
| **Nikol**     | 2265796    | **UI/UX Lead**                       | Welcome page and landing page design, documentation                                                                                        |
| **Alecxis**   | 2278372    | **UI Developer**                     | Documentation and event details view implementation                                                                                        |
| **Jim**       | 2281534    | **UI Designer**                      | Profile page design and initial implementation, documentation                                                                              |

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

---

## � Coursework Submission Status

### ✅ Coursework 1 – SUBMITTED (17/12/2025)

**Focus**: Problem Specification (40%), Design (40%), Analysis (10%)

- ✅ Problem Specification: Requirements elicitation, user & system requirements documented
- ✅ Design: System architecture, use case diagrams, and design models
- ✅ Implementation: Version control, technology investigation, project scaffolding
- ✅ Testing: Test plan for non-functional requirements
- ✅ Critical Analysis: Leadership, progress monitoring, conflict resolution reflections
- ✅ Report: 10-12 pages submitted with contributions table

### 🚀 Coursework 2 – IN PROGRESS (Deadline: 13/05/2026)

**Focus**: Implementation (40%), Testing (40%), Analysis (10%)

- ✅ Problem Specification: Changes to initial requirements documented
- ✅ Design: Architecture and use case updates with rationale
- ✅ **Implementation (40%)**:
  - ✅ 3-5 minute system demo video (features: auth, event discovery, creation, management, ticketing)
  - ✅ Version control with branching, commits, and issue tracking
  - ✅ Code documentation and implementation evidence
  - ✅ Discussion of implementation challenges overcome
- ✅ **Testing (40%)**:
  - ✅ Complete test plan covering all units of code (200+ test cases)
  - ✅ Automated test cases with unit and widget test suites
  - ✅ Test coverage evidence and reports
- 🔄 Critical Analysis: Reflective account of leadership, progress monitoring, conflict resolution

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

_Last Updated: May 2026_
_Version: 2.0.0 (Coursework 2 Submission)_
