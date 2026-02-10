# House Rental App — Architecture & Design Document

> **Status:** Pending Approval | **Version:** 1.0 | **Date:** Feb 10, 2025

---

## 1. Requirements Analysis

### 1.1 Core Problem
Current rental apps lack **smart matching** and **AI-driven assistance**. Users spend excessive time filtering and comparing listings without personalized guidance.

### 1.2 Solution Summary
A cross-platform app with:
- **AI recommendations** based on user preferences and behavior
- **Natural language search** (e.g., "2bhk for students near college under 12k")
- **Real-time rental data** via Firestore
- **Price prediction** for fair rent estimation
- **Fraud detection** for safer marketplace
- **Offline-first** support with SQLite sync

### 1.3 Functional Requirements Matrix

| # | Feature | Priority | Layer | Notes |
|---|---------|----------|-------|-------|
| F1 | User registration/login | P0 | Auth | Firebase Auth (email, Google) |
| F2 | Browse listings | P0 | Core | Paginated, filters |
| F3 | Search (keyword + filters) | P0 | Core | Firestore queries |
| F4 | Natural language search | P1 | AI | NLP → query params |
| F5 | AI recommendations | P1 | AI | Budget, area, views, saved |
| F6 | Price prediction | P1 | AI | Location, sqft, bedrooms |
| F7 | Fraud detection | P1 | AI | Heuristics + ML signals |
| F8 | Save/favorite listings | P0 | Core | Per-user |
| F9 | View listing details | P0 | Core | Images, map, contact |
| F10 | Owner: Create/Edit/Delete listing | P0 | Core | CRUD + validation |
| F11 | In-app messaging (optional) | P2 | Core | Firestore subcollection |
| F12 | Push notifications | P1 | Infra | FCM |
| F13 | Offline mode | P1 | Data | SQLite + sync |
| F14 | Dark mode | P1 | UI | Theme toggle |
| F15 | Multi-language | P2 | UI | i18n |
| F16 | Barcode/QR scanning | P2 | Bonus | Lease docs |
| F17 | Voice assistant | P2 | Bonus | Voice → NL search |

### 1.4 Non-Functional Requirements
- **Scalability:** Support 10k+ listings, 1k+ concurrent users
- **Performance:** < 2s cold start, < 500ms search
- **Security:** Input validation, auth checks, secure API keys
- **Maintainability:** Clean Architecture, SOLID, clear boundaries

---

## 2. System Architecture

### 2.1 High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP (Cross-platform)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Presentation│  │   Domain    │  │    Data     │  │   Riverpod State    │ │
│  │ (UI, Pages) │──│ (Entities,  │──│(Repos Impl, │──│   Management        │ │
│  │             │  │ Use Cases)  │  │ Remote/Local│  │                     │ │
│  └─────────────┘  └─────────────┘  └──────┬──────┘  └─────────────────────┘ │
└───────────────────────────────────────────┼──────────────────────────────────┘
                                            │
          ┌─────────────────────────────────┼─────────────────────────────────┐
          │                                 │                                 │
          ▼                                 ▼                                 ▼
┌─────────────────────┐         ┌─────────────────────┐         ┌─────────────────────┐
│      Firebase       │         │  Python FastAPI      │         │  SQLite (Offline)   │
│ Auth | Firestore |  │         │  AI Microservice     │         │  Local cache/sync   │
│ Storage | FCM      │         │  - NL Search         │         │                     │
│                     │         │  - Recommendations   │         │                     │
│                     │         │  - Price Prediction  │         │                     │
│                     │         │  - Fraud Detection   │         │                     │
└─────────────────────┘         └─────────────────────┘         └─────────────────────┘
```

### 2.2 Clean Architecture Layers

| Layer | Responsibility | Dependencies |
|-------|----------------|--------------|
| **Presentation** | UI, widgets, Riverpod providers, routing | Domain |
| **Domain** | Entities, use cases, repository interfaces | None (pure Dart) |
| **Data** | Repository implementations, data sources, mappers | Domain, Firebase, SQLite, API client |

### 2.3 AI Microservice Responsibilities
- **Natural Language Search:** Parse query → structured filters + **semantic similarity** (query embedding matched to listing embeddings before Firestore filtering)
- **Recommendations:** Input: userId + **user_activity** (views, saves, dwell_time) → preference vectors + collaborative filtering → ranked listing IDs
- **Price Prediction:** Input: location, sqft, bedrooms, amenities + **market_stats** baseline → predicted rent ± confidence
- **Fraud Detection:** Input: listing data + **market_stats** baseline → risk score + signals (too cheap vs median, duplicate images, etc.)

### 2.4 Search Indexing Strategy (Semantic Search)
Listings are indexed for hybrid search: **keyword** (searchTokens) + **semantic** (embeddings).

**Flow:**
1. **Indexing:** On listing create/update, AI service generates `searchTokens` (tokenized title+description) and `embedding` (sentence-transformers) → stored in Firestore
2. **Query:** User submits NL query → AI service returns (a) structured filters, (b) query embedding
3. **Retrieval:** Flutter fetches listings from Firestore with filters; AI service ranks by cosine similarity between query embedding and listing embeddings
4. **Result:** Combined ranking: filters + semantic score

---

## 3. Folder Structure

```
house_rental/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                           # Shared across layers
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── firestore_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   └── extensions.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   └── router/
│   │       └── app_router.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       ├── sign_up_usecase.dart
│   │   │   │       └── sign_out_usecase.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── listings/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── listing_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── listing_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_listings_usecase.dart
│   │   │   │       ├── get_listing_by_id_usecase.dart
│   │   │   │       ├── create_listing_usecase.dart
│   │   │   │       ├── update_listing_usecase.dart
│   │   │   │       └── delete_listing_usecase.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── listing_remote_datasource.dart
│   │   │   │   │   └── listing_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── listing_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── listing_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── search/
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── recommendations/
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── ai_services/                    # AI API client & use cases
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── nl_search_result.dart
│   │   │   │   │   ├── recommendation_result.dart
│   │   │   │   │   ├── price_prediction.dart
│   │   │   │   │   └── fraud_report.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── ai_service_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── natural_language_search_usecase.dart
│   │   │   │       ├── get_recommendations_usecase.dart
│   │   │   │       ├── predict_price_usecase.dart
│   │   │   │       └── check_fraud_usecase.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── ai_api_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── ai_service_repository_impl.dart
│   │   │   └── presentation/
│   │   │       └── providers/
│   │   │
│   │   ├── favorites/
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── user_profile/
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   └── settings/
│   │       ├── domain/
│   │       ├── data/
│   │       └── presentation/
│   │
│   └── shared/
│       └── widgets/                       # Reusable UI components
│
├── ai_service/                            # Python FastAPI microservice
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── api/
│   │   │   ├── routes/
│   │   │   │   ├── search.py
│   │   │   │   ├── recommendations.py
│   │   │   │   ├── price_prediction.py
│   │   │   │   └── fraud.py
│   │   │   └── deps.py
│   │   ├── services/
│   │   │   ├── nl_search_service.py
│   │   │   ├── recommendation_service.py
│   │   │   ├── price_prediction_service.py
│   │   │   └── fraud_detection_service.py
│   │   ├── models/
│   │   │   └── schemas.py
│   │   └── core/
│   │       ├── security.py
│   │       └── firebase_admin.py           # Verify Firebase tokens
│   ├── requirements.txt
│   └── Dockerfile
│
├── assets/
│   ├── images/
│   ├── lottie/
│   └── fonts/
│
├── l10n/                                  # Localization
│   ├── app_en.arb
│   └── app_hi.arb
│
├── test/
│   └── ... (mirror lib structure)
│
├── pubspec.yaml
├── analysis_options.yaml
└── DESIGN_DOCUMENT.md
```

---

## 4. Database Schema

### 4.1 Firestore Collections

#### `users` (Firestore)
| Field | Type | Description |
|-------|------|-------------|
| uid | string | Firebase Auth UID (document ID) |
| email | string | User email |
| displayName | string | Display name |
| photoUrl | string? | Profile picture URL |
| phone | string? | Phone number |
| role | string | `"renter"` \| `"owner"` \| `"both"` |
| preferredAreas | array\<string\> | For recommendations |
| maxBudget | number? | For recommendations |
| fcmToken | string? | Push notifications |
| createdAt | timestamp | |
| updatedAt | timestamp | |

#### `listings` (Firestore)
| Field | Type | Description |
|-------|------|-------------|
| id | string | Document ID |
| ownerId | string | Reference to users |
| title | string | |
| description | string | |
| price | number | Monthly rent (INR) |
| currency | string | "INR" |
| propertyType | string | `"apartment"` \| `"house"` \| `"pg"` \| etc. |
| bedrooms | number | BHK count |
| bathrooms | number | |
| sqft | number | Square feet |
| address | map | `{street, city, state, pincode, lat, lng}` |
| amenities | array\<string\> | e.g. `["wifi","parking","ac"]` |
| images | array\<string\> | Storage URLs |
| **searchTokens** | **array\<string\>** | **Tokenized text for keyword search** (title + description + area) |
| **embedding** | **array\<number\>** | **Semantic vector from sentence-transformers** (384 or 768 dim) |
| status | string | `"active"` \| `"inactive"` \| `"flagged"` |
| fraudRiskScore | number? | 0-100, from AI |
| fraudSignals | array\<string\>? | Human-readable signals |
| createdAt | timestamp | |
| updatedAt | timestamp | |

**Indexes (Composite):**
- `(status, price)` — for filtered browse
- `(status, city)` — for location-based
- `(status, bedrooms, price)` — for search

#### `favorites` (Firestore subcollection under `users/{uid}/favorites`)
| Field | Type |
|-------|------|
| listingId | string |
| addedAt | timestamp |

#### `view_history` (Firestore subcollection under `users/{uid}/view_history`)
| Field | Type |
|-------|------|
| listingId | string |
| viewedAt | timestamp |

#### `user_activity` (Firestore) — Behavioral events for recommendations
| Field | Type | Description |
|-------|------|-------------|
| id | string | Document ID (auto) |
| userId | string | Firebase UID |
| eventType | string | `view_listing` \| `save_listing` \| `contact_owner` \| `search_query` \| `dwell_time` |
| listingId | string? | For view/save/contact |
| searchQuery | string? | For search_query |
| dwellTimeSeconds | number? | For dwell_time (time on listing page) |
| metadata | map? | Extra context (e.g. filters used) |
| timestamp | timestamp | Event time |

**Indexes:** `(userId, timestamp)`, `(userId, eventType, timestamp)` — for recommendation engine to compute preference vectors and collaborative filtering.

#### `market_stats` (Firestore) — Baseline for price prediction & fraud detection
| Field | Type | Description |
|-------|------|-------------|
| id | string | Document ID: `{city}_{bhk}_{sqft_range}` e.g. `bangalore_2_1000-1500` |
| city | string | City name (normalized) |
| bhk | number | Bedroom count (1, 2, 3, ...) |
| sqftRange | string | e.g. `"1000-1500"` |
| medianPrice | number | Median rent in INR |
| minPrice | number | 25th percentile |
| maxPrice | number | 75th percentile |
| sampleCount | number | Listings used for stats |
| updatedAt | timestamp | Last aggregation run |

**Usage:** Fraud detection compares listing price to `medianPrice`; price prediction uses as baseline before model inference.

#### `price_history` (optional, for ML training)
| Field | Type |
|-------|------|
| listingId | string |
| price | number |
| sqft | number |
| bedrooms | number |
| city | string |
| recordedAt | timestamp |

### 4.2 SQLite (Offline) Schema

```sql
-- Mirrors Firestore for offline use
CREATE TABLE listings (
  id TEXT PRIMARY KEY,
  owner_id TEXT,
  title TEXT,
  description TEXT,
  price REAL,
  property_type TEXT,
  bedrooms INTEGER,
  bathrooms INTEGER,
  sqft REAL,
  city TEXT,
  state TEXT,
  pincode TEXT,
  lat REAL,
  lng REAL,
  amenities TEXT,        -- JSON array
  images TEXT,           -- JSON array
  status TEXT,
  synced_at INTEGER,
  is_dirty INTEGER DEFAULT 0
);

CREATE TABLE favorites (
  user_id TEXT,
  listing_id TEXT,
  added_at INTEGER,
  PRIMARY KEY (user_id, listing_id)
);

CREATE TABLE view_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  listing_id TEXT,
  viewed_at INTEGER
);

CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation TEXT,        -- create, update, delete
  collection TEXT,
  doc_id TEXT,
  payload TEXT,          -- JSON
  created_at INTEGER
);
```

### 4.3 ER Diagram (Conceptual)

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│    users     │       │     listings     │       │   favorites  │
├──────────────┤       ├──────────────────┤       ├──────────────┤
│ uid (PK)     │───┐   │ id (PK)          │───┐   │ user_id (FK) │
│ email        │   │   │ owner_id (FK) ───┼───┘   │ listing_id   │
│ displayName  │   │   │ title            │   └───│ (FK)         │
│ preferredAreas│  │   │ price            │       │ added_at     │
│ maxBudget    │   │   │ searchTokens[]   │       └──────────────┘
└──────────────┘   │   │ embedding[]      │
                   │   │ city, sqft, ...  │       ┌──────────────────┐
                   │   └──────────────────┘       │  user_activity   │
                   │                              ├──────────────────┤
                   │   ┌──────────────────┐       │ user_id (FK)     │
                   └───│   view_history   │       │ eventType        │
                       ├──────────────────┤       │ listingId, ...   │
                       │ user_id (FK)     │       └──────────────────┘
                       │ listing_id (FK)  │
                       │ viewed_at        │       ┌──────────────────┐
                       └──────────────────┘       │   market_stats   │
                                                 ├──────────────────┤
                                                 │ city, bhk, sqft   │
                                                 │ medianPrice       │
                                                 └──────────────────┘
```

---

## 5. API Contracts (AI Microservice)

Base URL: `https://your-ai-service.com/api/v1` (configurable)

### 5.1 Authentication & Security
- **Firebase ID Token:** All requests require `Authorization: Bearer <Firebase_ID_Token>`
- **Verification:** AI service verifies token using **Firebase Admin SDK**; rejects unauthenticated/invalid tokens with `401 Unauthorized`
- **Per-User Rate Limiting:** Each user (identified by Firebase UID) is rate-limited per endpoint (e.g. 60 req/min for search, 20 req/min for recommendations). Returns `429 Too Many Requests` when exceeded.

### 5.2 Endpoints

#### POST `/search/natural-language`
**Request:**
```json
{
  "query": "2bhk for students near college under 12k",
  "user_id": "optional-for-personalization"
}
```

**Response:**
```json
{
  "success": true,
  "filters": {
    "bedrooms": 2,
    "max_price": 12000,
    "keywords": ["students", "college"],
    "area_keywords": ["college"]
  },
  "query_embedding": [0.12, -0.34, ...],
  "suggested_query": "2 BHK near college, under ₹12,000"
}
```
*Client uses `filters` for Firestore query; `query_embedding` for cosine-similarity ranking against listing embeddings.*

---

#### POST `/recommendations`
**Request:**
```json
{
  "user_id": "firebase_uid",
  "budget_max": 15000,
  "preferred_areas": ["Indiranagar", "Koramangala"],
  "limit": 10
}
```
*Server fetches `user_activity` (view_listing, save_listing, dwell_time, search_query) from Firestore for preference vectors and collaborative filtering.*

**Response:**
```json
{
  "success": true,
  "listing_ids": ["id1", "id2", "id3", ...],
  "scores": [0.95, 0.87, 0.82, ...]
}
```

---

#### POST `/price/predict`
**Request:**
```json
{
  "city": "Bangalore",
  "area": "Koramangala",
  "sqft": 1200,
  "bedrooms": 2,
  "bathrooms": 2,
  "amenities": ["wifi", "parking", "ac"]
}
```

**Response:**
```json
{
  "success": true,
  "predicted_price": 18500,
  "confidence": 0.85,
  "range": {
    "min": 16500,
    "max": 20500
  },
  "factors": ["location premium", "sqft", "amenities"]
}
```

---

#### POST `/fraud/analyze`
**Request:**
```json
{
  "listing_id": "abc123",
  "price": 5000,
  "sqft": 1500,
  "bedrooms": 3,
  "city": "Bangalore",
  "images": ["url1", "url2"],
  "owner_id": "xyz"
}
```

**Response:**
```json
{
  "success": true,
  "risk_score": 72,
  "risk_level": "high",
  "signals": [
    "Price significantly below market (expected ~₹25k)",
    "Possible duplicate images across listings"
  ],
  "recommendation": "Flag for manual review"
}
```

---

### 5.3 Error Response (Standard)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": { "field": "bedrooms", "reason": "Must be positive" }
  }
}
```

---

## 6. Implementation Order (After Approval)

| Phase | Modules | Estimated Effort |
|-------|---------|------------------|
| 1 | Project setup, core layer, Firebase config | 1-2 days |
| 2 | Auth feature (domain, data, presentation) | 1-2 days |
| 3 | Listings CRUD + Firestore + basic UI | 2-3 days |
| 4 | Search + filters + Favorites | 1-2 days |
| 5 | AI microservice skeleton + NL search | 2 days |
| 6 | Recommendations + Price prediction + Fraud | 2-3 days |
| 7 | Offline SQLite + sync | 1-2 days |
| 8 | Push notifications, Dark mode, i18n | 1-2 days |
| 9 | Polish, animations, validations | 1-2 days |
| 10 | Documentation, UML, APK | 1 day |

---

## 7. Security Considerations

- **Firebase Rules:** Restrict reads/writes per collection (e.g., users can only write to own doc)
- **AI Service — Token Verification:** Use **Firebase Admin SDK** to verify ID token on every request; reject with `401` if missing, expired, or invalid
- **AI Service — Rate Limiting:** Per-user rate limiting by Firebase UID; `429` when limit exceeded
- **Input Validation:** Both client (Dart) and server (Pydantic)
- **Secrets:** API keys, Firebase service account JSON in env/flavor, never in repo

---

## 8. Approval Checklist

Before proceeding to implementation, please confirm:

- [ ] Architecture aligns with your understanding
- [ ] Folder structure is acceptable
- [ ] Database schema meets requirements (any additions?)
- [ ] API contracts are clear (any changes?)
- [ ] Implementation order works for you

**Once approved, we will implement module by module, starting with Phase 1.**
