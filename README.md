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

| Name | Role | Key Contributions |
| :--- | :--- | :--- |
| **Achilleas** | **Tech Lead** | Architecture, SQLite Migration, UI Stabilization |
| **Marinos** | **Design Co-Lead** | UI Mockups & System Requirements |
| **Lily** | **Analyst** | User Requirements Documentation |
| **Alecxis** | **Analyst** | System Requirements Specification |
| **Akim** | **Modeller** | System Models & Technical Diagrams |
| **Jim** | **Architect** | Component Design & Diagrams |
| **Nikol** | **Documentation** | Final Report & Academic Editing |

---

_Last Updated: May 2026_
_Version: 2.0.0 (Final Stability Release)_
