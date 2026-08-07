<div align="center">

# Enki

**A cross-platform online learning platform — Flutter client + FastAPI backend.**

[![Flutter](https://img.shields.io/badge/Flutter-3.10-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.136-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/license-Unlicensed-lightgrey)](#license)

</div>

---

## Overview

**Enki** is a full-stack e-learning platform that lets learners browse courses, watch structured video/article lectures, and track their progress module by module. It's built as two independent, deployable projects that share a database and communicate over a REST API:

| Project | Role | Stack |
|---|---|---|
| [`Enki/`](./Enki) | Client application (mobile, web, desktop) | Flutter, BLoC/Cubit, Clean Architecture |
| [`enkiBackEnd/`](./enkiBackEnd) | REST API & media server | FastAPI, PostgreSQL, uv |

Authentication is handled by **Supabase** (for SSO and session management), while all application data — courses, modules, lectures, and user progress — lives in a **PostgreSQL** database served by a custom FastAPI backend.

---

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [1. Database](#1-database)
  - [2. Backend setup](#2-backend-setup)
  - [3. Client setup](#3-client-setup)
- [API Overview](#api-overview)
- [Environment Variables](#environment-variables)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Architecture

Enki follows **Clean Architecture** on both ends of the stack, keeping domain logic independent from frameworks and infrastructure so features can be added without large-scale refactors.

```
┌─────────────────────────┐         REST / JSON          ┌──────────────────────────┐
│         Enki (Flutter)  │ ────────────────────────────▶ │     enkiBackEnd (FastAPI)│
│  presentation → domain  │ ◀──────────────────────────── │  api → domain → infra    │
│  → data                 │                                │  → PostgreSQL            │
└─────────────────────────┘                                └──────────────────────────┘
             │                                                          │
             └───────────────────────┬──────────────────────────────────┘
                                      ▼
                              ┌───────────────┐
                              │   Supabase    │
                              │  (Auth / SSO) │
                              └───────────────┘
```

- **Client (`Enki/`)** — each feature (`auth`, `enki`) is split into `data`, `domain`, and `presentation` layers, with `flutter_bloc` driving state and `get_it` handling dependency injection.
- **Backend (`enkiBackEnd/`)** — each request flows through `api → domain (entities/schemas) → infrastructure (models/repositories)`, backed by PostgreSQL via `psycopg`/`asyncpg`.
- **Auth** is delegated to Supabase rather than reimplemented, giving the app SSO support out of the box.

---

## Features

- 📚 **Course catalog** — browse top and beginner-friendly courses, search by title or author
- 🎬 **Structured lectures** — courses are broken into modules and ordered lectures (video or article)
- 🎞️ **Media streaming** — dedicated endpoints for streaming video, article, and image content
- 📈 **Progress tracking** — per-user, per-lecture completion tracking and "watched courses" history
- 👤 **User profiles** — editable profile with bio, workplace, and specialty
- 🛠️ **Admin tooling** — course creation and media upload endpoints, plus a bundled HTML admin console
- 🔐 **Authentication via Supabase** — SSO-ready auth layer, decoupled from the core backend
- 🖥️ **Truly cross-platform client** — one Flutter codebase targeting Android, iOS, Web, macOS, Linux, and Windows

---

## Tech Stack

**Client**
- [Flutter](https://flutter.dev) / Dart (SDK `^3.10`)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) — state management (BLoC/Cubit)
- [get_it](https://pub.dev/packages/get_it) — dependency injection / service locator
- [supabase_flutter](https://pub.dev/packages/supabase_flutter) — auth & backend client
- [fpdart](https://pub.dev/packages/fpdart) — functional programming primitives (`Either`, error handling)
- [media_kit](https://pub.dev/packages/media_kit) — video playback
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) — article/lecture rendering

**Backend**
- [FastAPI](https://fastapi.tiangolo.com) — async REST API framework
- [PostgreSQL](https://www.postgresql.org) — primary data store
- [asyncpg](https://github.com/MagicStack/asyncpg) / [psycopg](https://www.psycopg.org) — database drivers
- [fastapi-users](https://fastapi-users.github.io/fastapi-users/) — user management scaffolding
- [ImageKit](https://imagekit.io) — media handling/CDN
- [uv](https://github.com/astral-sh/uv) — dependency & environment management
- [Podman](https://podman.io) — containerized local PostgreSQL

---

## Project Structure

```
enki/
├── Enki/                      # Flutter client
│   ├── lib/
│   │   ├── core/              # Shared code: DI, error handling, theming, secrets
│   │   └── features/
│   │       ├── auth/          # Authentication feature (data/domain/presentation)
│   │       └── enki/          # Courses, lectures, progress (data/domain/presentation)
│   ├── android/ ios/ macos/ linux/ windows/ web/   # Platform targets
│   └── pubspec.yaml
│
└── enkiBackEnd/                # FastAPI backend
    ├── app/
    │   ├── api/v1/             # Route handlers (public, user, admin)
    │   ├── domain/             # Entities & Pydantic schemas
    │   ├── infrastructure/     # ORM models & repositories
    │   └── core/                # Settings & logging
    ├── enkiDataBase.sql        # PostgreSQL schema
    ├── enki_admin_v4.html      # Standalone admin console
    └── pyproject.toml
```

---

## Data Model

The backend is built around six core PostgreSQL tables:

| Table | Purpose |
|---|---|
| `users` | Learner profile data (name, workplace, bio, specialty) |
| `courses` | Course catalog entries (title, description, author, category, rating) |
| `modules` | Ordered groupings of lectures within a course |
| `lectures` | Individual video/article lecture units, with ordering and duration |
| `userprogress` | Tracks completion of a lecture per user |
| `useractivate` | Tracks course enrollment per user |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.10+`
- [Python](https://www.python.org) `3.14+`
- [uv](https://github.com/astral-sh/uv) package manager
- [Podman](https://podman.io) (or Docker) for local PostgreSQL
- A [Supabase](https://supabase.com) project (for auth)

### 1. Database

Spin up PostgreSQL locally with Podman:

```bash
podman run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=your_secure_password \
  -v pg_data:/var/lib/postgresql:Z \
  -p 5432:5432 \
  postgres
```

Load the schema:

```bash
podman exec -it my-postgres psql -U postgres -d enki -f enkiDataBase.sql
```

### 2. Backend setup

```bash
cd enkiBackEnd
cp .env.example .env        # then fill in DATABASE_URL and any other values
uv sync                     # install dependencies
uv run main.py               # starts the API on http://0.0.0.0:8000
```

### 3. Client setup

```bash
cd Enki
cp lib/core/secrets/app_secrets.example.dart lib/core/secrets/app_secrets.dart
# fill in your Supabase URL/anon key and the backend base URL
flutter pub get
flutter run
```

> **Note:** `.env` and `app_secrets.dart` are gitignored on purpose — they hold real credentials and should never be committed. See [Environment Variables](#environment-variables).

---

## API Overview

The backend exposes three router groups under `app/api/v1/`:

| Router | Examples |
|---|---|
| **Public** | `GET /courses/top`, `GET /courses/search`, `POST /progress/mark`, `GET /stream/video/{filename}` |
| **User** | `POST /users/{userid}` |
| **Admin** | `POST /courses/create`, `POST /upload/video/{course_id}`, `POST /upload/markdown/{course_id}` |

Interactive API docs are available at `/docs` once the server is running (FastAPI's built-in Swagger UI).

---

## Environment Variables

**`enkiBackEnd/.env`**

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string, e.g. `postgresql://user:password@host:port/dbname` |

**`Enki/lib/core/secrets/app_secrets.dart`**

| Constant | Description |
|---|---|
| `supabaseUrl` | Your Supabase project URL |
| `supabaseAnnonKey` | Your Supabase anonymous/public API key |
| `apiBaseUrl` | Base URL of the running `enkiBackEnd` API |
| `mediaBaseUrl` | Base URL used for streaming media |

Both files are excluded from version control via `.gitignore`. Copy the corresponding `.example` templates and fill in real values locally.

---

## Roadmap

- [ ] Automated tests for backend repositories and routers
- [ ] CI pipeline (lint, format, test) via GitHub Actions
- [ ] Dockerfile / container image for the backend
- [ ] Push notifications for course updates

---

## Contributing

Contributions, issues, and feature requests are welcome. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Open a pull request

---

## License

No license has been specified yet for this project. All rights reserved by the author until a license is added.
