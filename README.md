# IP Activities Assignment

A Ruby on Rails implementation that efficiently handles large-scale IP activity logs using smart limiting and a reusable filter system. Designed to work with 100M+ records, prioritizing performance, maintainability, and scalability.

---

## Setup

```bash
# Clone the project
git clone https://github.com/rizwanbinnawaz/fundingpips.git
cd fundingpips

# Install dependencies
bundle install

# Set up PostgreSQL (Ensure it's running on localhost:5432)
rails db:create db:migrate db:seed

# Start server
rails s
```

---

## Task 1: Smart Limiting for IP Activities

### Goal
Return a smartly limited set of user IP activities:
- Up to **10** `kyc` records
- Up to **1000** `login` records
- Remaining (up to a total of **3000**) filled with `trade` records

### Implementation

- `IpActivity.latest_activities_for_user(user)`:
  - Uses `.for_user(user)` to load both user and trading-account activities
  - Applies `.limit` per activity type
  - Combines `kyc`, `login`, and `trade` IDs and re-fetches ordered results
- Avoids scanning all records or heavy joins
- Uses `includes` to preload `user`, `trading_account`, and `ip_address_record`

### Benefits

- Handles 100M+ records efficiently
- Prioritizes relevant activity types
- All logic is model-scoped and encapsulated

---

## Task 2: Reusable Filter Component Architecture

### Goal
Create a flexible, reusable filter system for multiple models (`IpActivity`, `User`, `TradingAccount`)

### Components

#### `FilterEngine` (Service Class)

- Accepts:
  - ActiveRecord scope
  - Filter parameters (e.g., `created_at_from`, `activity_type`)
- Applies filters like:
  - Date ranges
  - Enum matches
  - Exact matches (e.g., login)
- Easily extendable by adding `apply_#{key}` methods

#### `Filter` Model (for saving filter sets)

```ruby
# Schema
t.references :user
t.string :entity_type       # e.g. "IpActivity"
t.string :name              # e.g. "My Login Filter"
t.jsonb :params             # e.g. { activity_type: "login", created_at_from: "2024-01-01" }
```

---

## 🖥 API Endpoints

### IP Activities

```http
GET /api/users/:user_id/ip_activities
GET /api/users/:user_id/ip_activities/filter_metadata
```

### Filters

```http
GET  /api/filters?entity_type=IpActivity     # List saved filters
POST /api/filters                            # Save a new filter
```

---

## Example Saved Filter JSON

```json
{
  "name": "Last 7 Days Trade Activity",
  "entity_type": "IpActivity",
  "params": {
    "activity_type": "trade",
    "created_at_from": "2025-07-20",
    "created_at_to": "2025-07-27"
  }
}
```

---

## Testing

```bash
bin/rspec
```

---

## Author

Rizwan  
 rizwanbinnwaz@gmail.com
