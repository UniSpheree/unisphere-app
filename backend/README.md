# UniSphere API (Backend)

The UniSphere Backend is a lightweight, persistent REST API built with **Express.js** and **SQLite**. It serves as the data layer for the UniSphere Flutter application, handling user authentication, event management, and ticket transactions.

## 🚀 Key Responsibilities

- **User Management**: Registration, Login (with password hashing), and Profile management.
- **Event Lifecycle**: Creation, editing, deletion, and discovery of university events.
- **Ticket System**: Persistent storage of purchased tickets and attendance tracking.
- **Media Storage**: Handling binary image uploads for event banners (stored in `backend/storage/uploads`).
- **Data Persistence**: A robust SQLite database (`unisphere.db`) ensures all data remains available across sessions.

## � Data Persistence Guarantee

✅ **All data is permanently saved** to the SQLite database (`backend/unisphere.db`):

- User accounts and profiles are saved automatically on registration/update
- Events created by organisers are persisted permanently
- Purchased tickets are stored with full transaction history
- Banner images are stored on disk
- **Data survives app restarts** — when you reload the application, all users, events, and tickets are automatically restored
- **No automatic data loss** — data only gets deleted when users explicitly delete their account or an event

To verify your data is saved:

```bash
npm run verify
```

## 🛠️ Requirements

- **Node.js 22+**
- **NPM** (bundled with Node.js)

## ⚙️ Installation & Setup

1. **Navigate to the backend directory**:

   ```bash
   cd backend
   ```

2. **Install dependencies**:

   ```bash
   npm install
   ```

3. **Start the API server**:
   ```bash
   npm start
   ```

The API will be available at: `http://127.0.0.1:8000`

On startup, the server will display a data persistence status showing the number of saved users, events, and tickets.

## 📡 API Endpoints Summary

| Method   | Endpoint          | Description                              |
| :------- | :---------------- | :--------------------------------------- |
| `GET`    | `/health`         | Check API status                         |
| `POST`   | `/register`       | Create a new user account                |
| `POST`   | `/login`          | Authenticate user and retrieve profile   |
| `GET`    | `/events`         | Retrieve all public events               |
| `POST`   | `/events`         | Create a new event (Organizer only)      |
| `PUT`    | `/events/:id`     | Update an existing event                 |
| `DELETE` | `/events/:id`     | Delete an event and its associated media |
| `POST`   | `/tickets`        | Purchase a ticket for an event           |
| `GET`    | `/tickets/:email` | Retrieve all tickets for a specific user |

## 📱 Connecting with Flutter

When running the Flutter application, ensure the backend is running first. Use the following command to point the app to your local API:

```bash
flutter run -d chrome
```

_Note: If you need to specify a different API URL, use the `--dart-define` flag:_

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://your-api-url:8000
```

---

_UniSphere Backend v1.1.0 - Optimized for Coursework Submission_
