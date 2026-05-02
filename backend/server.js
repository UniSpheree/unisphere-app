const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const Database = require("better-sqlite3");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 8000;
const BASE_DIR = __dirname;
const STORAGE_DIR = path.join(BASE_DIR, "storage");
const UPLOADS_DIR = path.join(STORAGE_DIR, "uploads");
const DB_PATH = path.join(BASE_DIR, "unisphere.db");

fs.mkdirSync(UPLOADS_DIR, { recursive: true });

const db = new Database(DB_PATH);

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  role TEXT NOT NULL,
  university TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  is_approved INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  date TEXT NOT NULL,
  end_date TEXT,
  location TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  organizer_email TEXT NOT NULL,
  banner_image_path TEXT,
  visibility TEXT NOT NULL DEFAULT 'Public',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS tickets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_email TEXT NOT NULL,
  title TEXT NOT NULL,
  date TEXT NOT NULL,
  location TEXT NOT NULL,
  category TEXT NOT NULL,
  price TEXT NOT NULL DEFAULT '',
  event_id INTEGER,
  purchased_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);
`);

// Migration: Add visibility column if it doesn't exist
try {
  db.prepare(
    "ALTER TABLE events ADD COLUMN visibility TEXT NOT NULL DEFAULT 'Public'"
  ).run();
  console.log("✓ Added visibility column to events table");
} catch (err) {
  if (!err.message.includes("duplicate column name")) {
    console.log("Note: visibility column already exists or migration skipped");
  }
}

// Migration: Add event_id column to tickets table
try {
  db.prepare("ALTER TABLE tickets ADD COLUMN event_id INTEGER").run();
  console.log("✓ Added event_id column to tickets table");
} catch (err) {
  if (!err.message.includes("duplicate column name")) {
    console.log("Note: event_id column already exists or migration skipped");
  }
}

app.use(cors());
app.use(express.json({ limit: "25mb" }));
app.use("/uploads", express.static(UPLOADS_DIR));

function normalizeEmail(email) {
  return String(email || "")
    .trim()
    .toLowerCase();
}

function baseUrl(req) {
  return `${req.protocol}://${req.get("host")}`;
}

function toUserOut(row) {
  return {
    id: row.id,
    email: row.email,
    firstName: row.first_name,
    lastName: row.last_name,
    role: row.role,
    university: row.university,
    description: row.description,
    isApproved: !!row.is_approved,
    createdAt: row.created_at,
  };
}

function eventBannerUrl(req, bannerPath) {
  if (!bannerPath) return null;
  return `${baseUrl(req)}/uploads/${path.basename(bannerPath)}`;
}

function toEventOut(req, row) {
  return {
    id: row.id,
    title: row.title,
    date: row.date,
    endDate: row.end_date,
    location: row.location,
    category: row.category,
    description: row.description,
    organizerEmail: row.organizer_email,
    bannerImageUrl: eventBannerUrl(req, row.banner_image_path),
    visibility: row.visibility || "Public",
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function toTicketOut(row) {
  return {
    id: row.id,
    userEmail: row.user_email,
    title: row.title,
    date: row.date,
    location: row.location,
    category: row.category,
    price: row.price,
    purchasedAt: row.purchased_at,
    eventId: row.event_id,
  };
}

function saveBannerImage(base64Data, eventId) {
  if (!base64Data) return null;
  const raw = Buffer.from(base64Data, "base64");
  if (!raw || raw.length === 0) return null;
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const filename = `event_${eventId}_${stamp}.png`;
  const filePath = path.join(UPLOADS_DIR, filename);
  fs.writeFileSync(filePath, raw);
  return filePath;
}

app.get("/health", (req, res) => {
  res.json({ ok: true });
});

app.post("/auth/register", (req, res) => {
  const body = req.body || {};
  const email = normalizeEmail(body.email);
  const existing = db
    .prepare("SELECT id FROM users WHERE email = ?")
    .get(email);
  if (existing) {
    return res.status(400).json({ detail: "Email already exists" });
  }

  const passwordHash = bcrypt.hashSync(String(body.password || ""), 10);
  const stmt = db.prepare(`
    INSERT INTO users (email, password_hash, first_name, last_name, role, university, description, is_approved)
    VALUES (@email, @password_hash, @first_name, @last_name, @role, @university, @description, @is_approved)
  `);
  const info = stmt.run({
    email,
    password_hash: passwordHash,
    first_name: String(body.firstName || "").trim(),
    last_name: String(body.lastName || "").trim(),
    role: String(body.role || "Attendee").trim() || "Attendee",
    university: String(body.university || "").trim(),
    description: String(body.description || "").trim(),
    is_approved: body.isApproved ? 1 : 0,
  });

  const row = db
    .prepare("SELECT * FROM users WHERE id = ?")
    .get(info.lastInsertRowid);
  res.status(201).json(toUserOut(row));
});

app.post("/auth/login", (req, res) => {
  const body = req.body || {};
  const email = normalizeEmail(body.email);
  const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  if (
    !user ||
    !bcrypt.compareSync(String(body.password || ""), user.password_hash)
  ) {
    return res.status(401).json({ detail: "Invalid email or password" });
  }
  res.json(toUserOut(user));
});

app.post("/auth/forgot-password", (req, res) => {
  const email = normalizeEmail((req.body || {}).email);
  const user = db.prepare("SELECT id FROM users WHERE email = ?").get(email);
  res.json({ exists: !!user });
});

app.post("/auth/reset-password", (req, res) => {
  const body = req.body || {};
  const email = normalizeEmail(body.email);
  const user = db.prepare("SELECT id FROM users WHERE email = ?").get(email);
  if (!user) {
    return res.status(404).json({ detail: "User not found" });
  }
  const passwordHash = bcrypt.hashSync(String(body.newPassword || ""), 10);
  db.prepare("UPDATE users SET password_hash = ? WHERE email = ?").run(
    passwordHash,
    email
  );
  res.json({ ok: true });
});

app.get("/profiles/:email", (req, res) => {
  const email = normalizeEmail(req.params.email);
  const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  if (!user) {
    return res.status(404).json({ detail: "User not found" });
  }
  res.json(toUserOut(user));
});

app.put("/profiles/:email", (req, res) => {
  const email = normalizeEmail(req.params.email);
  const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  if (!user) {
    return res.status(404).json({ detail: "User not found" });
  }
  const body = req.body || {};
  db.prepare(
    `
    UPDATE users
    SET first_name = ?, last_name = ?, description = ?
    WHERE email = ?
  `
  ).run(
    String(body.firstName || "").trim(),
    String(body.lastName || "").trim(),
    String(body.description || "").trim(),
    email
  );
  const updated = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  res.json(toUserOut(updated));
});

app.put("/profiles/:email/role", (req, res) => {
  const email = normalizeEmail(req.params.email);
  const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  if (!user) {
    return res.status(404).json({ detail: "User not found" });
  }
  const role = String((req.body || {}).role || "").trim() || user.role;
  db.prepare("UPDATE users SET role = ? WHERE email = ?").run(role, email);
  const updated = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  res.json(toUserOut(updated));
});

app.get("/events", (req, res) => {
  const rows = db
    .prepare("SELECT * FROM events ORDER BY created_at DESC")
    .all();
  res.json(rows.map((row) => toEventOut(req, row)));
});

app.get("/events/:id", (req, res) => {
  const row = db
    .prepare("SELECT * FROM events WHERE id = ?")
    .get(Number(req.params.id));
  if (!row) {
    return res.status(404).json({ detail: "Event not found" });
  }
  res.json(toEventOut(req, row));
});

app.post("/events", (req, res) => {
  const body = req.body || {};
  const organizerEmail = normalizeEmail(body.organizerEmail);
  const organizer = db
    .prepare("SELECT id FROM users WHERE email = ?")
    .get(organizerEmail);
  if (!organizer) {
    return res.status(404).json({ detail: "Organizer not found" });
  }

  const stmt = db.prepare(`
    INSERT INTO events (title, date, end_date, location, category, description, organizer_email, visibility)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const info = stmt.run(
    String(body.title || "").trim(),
    String(body.date || ""),
    body.endDate ? String(body.endDate) : null,
    String(body.location || "").trim(),
    String(body.category || "").trim(),
    String(body.description || "").trim(),
    organizerEmail,
    String(body.visibility || "Public").trim()
  );

  const bannerImageBase64 = body.bannerImageBase64
    ? String(body.bannerImageBase64)
    : null;
  if (bannerImageBase64) {
    const filePath = saveBannerImage(bannerImageBase64, info.lastInsertRowid);
    db.prepare("UPDATE events SET banner_image_path = ? WHERE id = ?").run(
      filePath,
      info.lastInsertRowid
    );
  }

  const row = db
    .prepare("SELECT * FROM events WHERE id = ?")
    .get(info.lastInsertRowid);
  res.status(201).json(toEventOut(req, row));
});

app.put("/events/:id", (req, res) => {
  const id = Number(req.params.id);
  const row = db.prepare("SELECT * FROM events WHERE id = ?").get(id);
  if (!row) {
    return res.status(404).json({ detail: "Event not found" });
  }

  const body = req.body || {};
  const next = {
    title: body.title !== undefined ? String(body.title).trim() : row.title,
    date: body.date !== undefined ? String(body.date) : row.date,
    end_date:
      body.endDate !== undefined
        ? body.endDate
          ? String(body.endDate)
          : null
        : row.end_date,
    location:
      body.location !== undefined ? String(body.location).trim() : row.location,
    category:
      body.category !== undefined ? String(body.category).trim() : row.category,
    visibility:
      body.visibility !== undefined
        ? String(body.visibility).trim()
        : row.visibility,
    description:
      body.description !== undefined
        ? String(body.description).trim()
        : row.description,
    organizer_email:
      body.organizerEmail !== undefined
        ? normalizeEmail(body.organizerEmail)
        : row.organizer_email,
    updated_at: new Date().toISOString(),
  };

  db.prepare(
    `
    UPDATE events
    SET title = ?, date = ?, end_date = ?, location = ?, category = ?, visibility = ?, description = ?, organizer_email = ?, updated_at = ?
    WHERE id = ?
  `
  ).run(
    next.title,
    next.date,
    next.end_date,
    next.location,
    next.category,
    next.visibility,
    next.description,
    next.organizer_email,
    next.updated_at,
    id
  );

  if (body.bannerImageBase64 !== undefined) {
    if (row.banner_image_path) {
      try {
        fs.unlinkSync(row.banner_image_path);
      } catch (_) {}
    }
    const filePath = body.bannerImageBase64
      ? saveBannerImage(String(body.bannerImageBase64), id)
      : null;
    db.prepare("UPDATE events SET banner_image_path = ? WHERE id = ?").run(
      filePath,
      id
    );
  }

  const updated = db.prepare("SELECT * FROM events WHERE id = ?").get(id);
  res.json(toEventOut(req, updated));
});

app.delete("/events/:id", (req, res) => {
  const id = Number(req.params.id);
  const row = db.prepare("SELECT * FROM events WHERE id = ?").get(id);
  if (!row) {
    return res.status(404).json({ detail: "Event not found" });
  }
  if (row.banner_image_path) {
    try {
      fs.unlinkSync(row.banner_image_path);
    } catch (_) {}
  }
  // Cascade delete: remove linked tickets, including legacy rows without event_id
  db.prepare(
    "DELETE FROM tickets WHERE event_id = ? OR (event_id IS NULL AND title = ? AND date = ? AND location = ?)"
  ).run(id, row.title, row.date, row.location);
  db.prepare("DELETE FROM events WHERE id = ?").run(id);
  res.json({ ok: true });
});

// Delete a user and all their data (events, tickets, stored banners)
app.delete('/auth/users/:email', (req, res) => {
  try {
    const email = normalizeEmail(req.params.email || '');
    const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Delete tickets owned by this user
    db.prepare('DELETE FROM tickets WHERE user_email = ?').run(email);

    // Find events created by this user and delete associated banner files
    const events = db.prepare('SELECT * FROM events WHERE organizer_email = ?').all(email);
    for (const ev of events) {
      if (ev.banner_image_path) {
        try {
          if (fs.existsSync(ev.banner_image_path)) {
            fs.unlinkSync(ev.banner_image_path);
          }
        } catch (e) {
          console.error('Failed to delete banner:', ev.banner_image_path, e);
        }
      }

      // Delete any tickets associated to this event (by event_id or legacy match)
      if (ev.id) {
        db.prepare('DELETE FROM tickets WHERE event_id = ?').run(ev.id);
      }
      db.prepare('DELETE FROM tickets WHERE title = ? AND date = ? AND location = ?').run(ev.title, ev.date, ev.location);
    }

    // Delete events created by the user
    db.prepare('DELETE FROM events WHERE organizer_email = ?').run(email);

    // Finally delete the user record
    db.prepare('DELETE FROM users WHERE email = ?').run(email);

    res.json({ ok: true });
  } catch (e) {
    console.error('Error deleting user:', e);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

app.post("/tickets", (req, res) => {
  const body = req.body || {};
  const userEmail = normalizeEmail(body.userEmail);
  const user = db
    .prepare("SELECT id FROM users WHERE email = ?")
    .get(userEmail);
  if (!user) {
    return res.status(404).json({ detail: "User not found" });
  }

  const stmt = db.prepare(`
    INSERT INTO tickets (user_email, title, date, location, category, price, event_id)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);
  const info = stmt.run(
    userEmail,
    String(body.title || "").trim(),
    String(body.date || ""),
    String(body.location || "").trim(),
    String(body.category || "").trim(),
    String(body.price || "").trim(),
    body.eventId ? Number(body.eventId) : null
  );
  const row = db
    .prepare("SELECT * FROM tickets WHERE id = ?")
    .get(info.lastInsertRowid);
  res.status(201).json(toTicketOut(row));
});

app.delete('/tickets/:email/:id', (req, res) => {
  try {
    const email = normalizeEmail(req.params.email || '');
    const ticketId = Number(req.params.id);
    const ticket = db
      .prepare('SELECT * FROM tickets WHERE id = ? AND user_email = ?')
      .get(ticketId, email);

    if (!ticket) {
      return res.status(404).json({ error: 'Ticket not found' });
    }

    db.prepare('DELETE FROM tickets WHERE id = ?').run(ticketId);
    res.json({ ok: true });
  } catch (e) {
    console.error('Error deleting ticket:', e);
    res.status(500).json({ error: 'Failed to delete ticket' });
  }
});

app.get("/tickets/:email", (req, res) => {
  const email = normalizeEmail(req.params.email);

  db.prepare(
    `
      DELETE FROM tickets
      WHERE user_email = ?
        AND event_id IS NOT NULL
        AND event_id NOT IN (SELECT id FROM events)
    `
  ).run(email);

  db.prepare(
    `
      DELETE FROM tickets
      WHERE user_email = ?
        AND event_id IS NULL
        AND NOT EXISTS (
          SELECT 1
          FROM events
          WHERE events.title = tickets.title
            AND events.date = tickets.date
            AND events.location = tickets.location
        )
    `
  ).run(email);

  const rows = db
    .prepare(
      "SELECT * FROM tickets WHERE user_email = ? ORDER BY purchased_at DESC"
    )
    .all(email);
  res.json(rows.map(toTicketOut));
});

app.listen(PORT, () => {
  console.log(`UniSphere API running at http://127.0.0.1:${PORT}`);
});
