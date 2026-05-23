# 🔧 RDE Mechanic — Next-Gen Vehicle Mechanic & Tuner System

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-red?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-RDE%20Black%20Flag%20v6.66-black?style=for-the-badge)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=for-the-badge)
![ox_lib](https://img.shields.io/badge/ox__lib-Required-blue?style=for-the-badge)
![Free](https://img.shields.io/badge/price-FREE%20FOREVER-brightgreen?style=for-the-badge)

**Full GTA Online mod support. GlobalState sync. Proximity-loaded peds. Server-verified transactions. Zero bullshit.**  
NPC mechanic peds, animated repairs, 60+ mod types, vehicle weapons, neon, wheels, colors — all proximity-loaded, zero CNetObj overhead.

Built on ox\_lib · ox\_inventory · ox\_target · oxmysql

*Built by [Red Dragon Elite](https://rd-elite.com) | SerpentsByte*

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Dependencies](#-dependencies)
- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [How It Works](#-how-it-works)
- [Admin System](#-admin-system)
- [Developer API](#-developer-api)
- [Database](#-database)
- [Performance](#-performance)
- [Troubleshooting](#-troubleshooting)
- [Changelog](#-changelog)
- [License](#-license)

---

## 🎯 Overview

**RDE Mechanic** is a production-grade vehicle mechanic and tuner system for FiveM. Admins spawn NPC mechanic peds at any location — players interact via ox_target to repair or fully tune their vehicle. Mechanic positions are synced via **GlobalState** and peds are **proximity-loaded** client-side — zero server entities, zero CNetObj limits, instant sync for late-joining players with zero join-events needed.

The tuning menu covers every GTA Online mod type: engine, brakes, transmission, suspension, armor, turbo, body parts, wheels (15 types + 190 sport variants), paint (primary, secondary, pearlescent, wheel, interior, dashboard), neon, window tint, livery, interior mods, extras, and vehicle weapons. Prices are validated server-side. Transactions are protected by rate limiting and cooldowns.

### Why RDE Mechanic?

| Feature | Generic Mechanic Scripts | RDE Mechanic |
|---|---|---|
| Sync method | Network events per player | ✅ GlobalState — instant, zero join-events |
| Ped loading | All peds always loaded | ✅ Proximity-based LOD |
| Server entities | 1 per mechanic ped | ✅ Zero — client-side local peds |
| CNetObj usage | 1 per ped | ✅ 0 |
| Mod coverage | Limited | ✅ All 60+ GTA Online mod types |
| Vehicle weapons | ❌ | ✅ MG, Missiles, Flamethrower, Minigun, Railgun, Laser |
| Price validation | Client-side | ✅ Server-side exploit-proof |
| Dynamic pricing | ❌ Fixed | ✅ Class multipliers (22 classes) |
| Tuning session | Closes after buy | ✅ Persistent — menu stays open |
| Wheel selection | Basic | ✅ 15 types, 190 sport names, native label fallback |
| Color system | Basic | ✅ 166 colors, 7 categories, pearlescent + wheel |
| Multi-language | ❌ | ✅ EN + DE built-in |
| Nostr logging | ❌ | ✅ rde_nostr_log integration |
| Anti-exploit | ❌ | ✅ Rate limit + cooldown + server validation |
| ox_core | Required | ✅ Optional — works without it |
| Performance | Variable | ✅ < 0.01ms idle |

---

## ✨ Features

### 🎮 Gameplay
- **NPC Mechanic Peds** — Spawned by admins at any location, persistent across restarts via MySQL, proximity-loaded client-side
- **Animated Repairs** — Mechanic walks to vehicle, opens hood, plays repair animation with sparks, closes hood and walks back to post
- **Dynamic Repair Pricing** — Base price + damage multiplier + vehicle class multiplier (22 GTA vehicle classes)
- **Full Tuning Menu** — All 60+ GTA Online mod types organized in 7 categories with Lucide icons
- **Vehicle Weapons** — Machine Gun, Missiles, Flamethrower, Minigun, Railgun, Laser — toggle-based, server-priced
- **Wheel System** — 15 wheel types, 190 Sport variants with native GTA label fallback
- **Color System** — 166 colors across 7 categories (Classic, Matte, Metallic, Utility, Worn, Special, Chrome), plus pearlescent, wheel, interior, dashboard
- **Neon Lights** — 14 preset neon colors, enable/disable, RGB display in menu
- **Window Tint** — 6 tint options
- **Extras** — Dynamic extra detection per vehicle
- **Persistent Tuning Session** — Menu reopens after every purchase, only closed explicitly with X

### 🚀 Technical
- **GlobalState Sync** — Single `GlobalState.rde_mechanics` key replaces all per-player join events. Late-joining players auto-receive full mechanic state, no `requestSync` needed
- **Proximity Loading** — Client proximity loop reads GlobalState every tick, spawns peds within `renderDistance`, despawns beyond `despawnDistance` — hysteresis prevents flicker
- **Client-Side Peds** — Zero server entities, zero CNetObj limits, no network entity spawning
- **Server-Side Price Validation** — Client sends mod type + vehicle class, server calculates and validates final price — no spoofing
- **StateBag Coordination** — `rde:repairing`, `rde:tuner`, `rde:busy` prevent double-repairs and menu conflicts
- **Rate Limiting** — Max 15 purchases/minute per player, configurable
- **Ground Detection** — `GetGroundZFor_3dCoord` + `PlaceObjectOnGroundProperly` for correct ped placement
- **Async Model Streaming** — `lib.requestModel` before spawn, never blocks
- **ox_lib Vehicle Properties** — `lib.getVehicleProperties` / `lib.setVehicleProperties` for correct mod persistence

### 🌍 Quality of Life
- **Multi-Language** — English + German built-in, easily expandable
- **Lucide Icons** — Clean, consistent icon set throughout all menus
- **Smart Notifications** — Contextual feedback with color-coded icons via ox_lib
- **Debug Mode** — `/debugmechanics` shows GlobalState count vs. locally spawned count
- **Blip System** — Configurable map blip per mechanic
- **Sound Effects** — Hood open/close, purchase confirmation
- **Repair Particles** — Wrench sparks during repair animation

---

## 📦 Dependencies

| Resource | Required | Notes |
|---|---|---|
| [oxmysql](https://github.com/communityox/oxmysql) | ✅ Required | Mechanic position persistence |
| [ox_lib](https://github.com/communityox/ox_lib) | ✅ Required | UI, callbacks, notifications, context menus |
| [ox_inventory](https://github.com/communityox/ox_inventory) | ✅ Required | Money item (`money`) for transactions |
| [ox_target](https://github.com/communityox/ox_target) | ✅ Required | Ped interaction |

**Optional:**

| Resource | Notes |
|---|---|
| [ox_core](https://github.com/communityox/ox_core) | Group-based admin checking — not required |
| [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) | Event logging — auto-detected, silent if missing |

---

## 🚀 Installation

### 1. Clone the repository

```bash
cd resources
git clone https://github.com/RedDragonElite/rde_mechanic.git rde_mechanic
```

### 2. Add to `server.cfg`

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure rde_mechanic

# Optional
ensure ox_core

# Optional: ACE admin permissions
add_ace group.admin rde.mechanic.admin allow
add_ace group.superadmin rde.mechanic.admin allow
```

> **Order matters.** `rde_mechanic` must start **after** all its dependencies.

### 3. Database

The `rde_mechanics` table is created automatically on first start. No manual SQL import needed.

### 4. Configure (Optional)

Edit `config.lua` to adjust language, prices, distances, proximity ranges, and admin permissions.

### 5. Restart & Spawn

```
restart rde_mechanic
```

In-game as admin: `/mechanics` → **Create Mechanic** — spawns at your current position.

---

## ⚙️ Configuration

### Language & Debug

```lua
Config.DefaultLanguage = 'en'   -- 'en' or 'de'

Config.Debug = {
    enabled         = false,
    logRepairs      = true,
    logPurchases    = true,
    logAdminActions = true,
}
```

### Proximity & Performance

```lua
Config.Performance = {
    renderDistance      = 150.0,  -- spawn ped within this range
    despawnDistance     = 200.0,  -- despawn beyond this (50m hysteresis gap)
    proximityTick       = 1000,   -- check interval in ms
    maxVisibleMechanics = 20,     -- cap on simultaneously rendered peds
}
```

### Distances

```lua
Config.Distances = {
    interactionRange      = 8.0,
    vehicleDetectionRange = 5.0,
    repairPositionOffset  = 2.5,
    minMechanicDistance   = 25.0,
    maxMenuDistance       = 10.0,
}
```

### Repair

```lua
Config.Repair = {
    basePrice             = 500,
    pricePerDamage        = 0.5,
    maxPrice              = 10000,
    engineHealthThreshold = 950.0,
    bodyHealthThreshold   = 950.0,
    minRepairTime         = 5000,
    maxRepairTime         = 30000,
    damageTimeMultiplier  = 10,
}
```

### Security

```lua
Config.Security = {
    maxPurchasesPerMinute    = 15,
    repairCooldown           = 5,
    mechanicSpawnCooldown    = 60,
    validatePricesServerSide = true,  -- never disable this
}
```

### Admin

```lua
Config.Admin = {
    acePermission = 'rde.mechanic.admin',
    oxGroups      = { 'admin', 'superadmin', 'moderator', 'owner', 'dev' },
}
```

---

## 🎮 How It Works

### For Players

1. **Walk up to a mechanic ped** — ox_target activates within interaction range
2. **Repair Vehicle** — Mechanic walks over, opens hood, animates with sparks, repairs progressively, closes hood, returns to post. Price scales with damage and vehicle class
3. **Modify Vehicle** — Opens the full 7-category tuning menu. Menu stays open after every purchase
4. **Pay with cash** — `money` item via ox_inventory

### For Admins

- **`/mechanics`** — Admin panel → Create Mechanic at current position
- **`/debugmechanics`** — GlobalState count vs. spawned count (F8 console)

### Architecture

```
┌─────────────────┐      GlobalState.rde_mechanics       ┌──────────────────┐
│     SERVER       │ ──────────────────────────────────→  │     CLIENT       │
│                  │                                      │                  │
│  • MySQL DB      │                                      │  • Proximity     │
│  • BroadcastM()  │                                      │    Loop (1s)     │
│  • Price valid.  │                                      │  • SpawnMechanic │
│  • Rate limit    │                                      │  • DespawnMechanic│
│  • Admin auth    │                                      │  • ox_target     │
└─────────────────┘                                      └──────────────────┘
```

**Server** stores data only — no entities, no network peds.  
One `GlobalState:set('rde_mechanics', flat, true)` on every create/delete.  
**Client** proximity loop reads GlobalState every tick and handles all spawning.  
Late-joining players need zero special handling — GlobalState is always current.

### Sync Flow

```
Admin creates mechanic
  → Server: DB insert → BroadcastMechanics() → GlobalState updated
  → All clients: proximity loop sees new ID on next tick
  → Nearby clients: SpawnMechanic() → local ped + blip + ox_target
  → Far clients: ID noted, ped spawns when player gets close

Player joins server
  → Proximity loop starts
  → GlobalState.rde_mechanics already populated — no event needed
  → First tick: all nearby mechanics spawn automatically
```

---

## 🛡️ Admin System

Admin access is verified server-side via two methods:

### Method 1: ACE Permissions (Recommended)

```cfg
add_ace group.admin rde.mechanic.admin allow
```

### Method 2: ox_core Groups (Optional)

```lua
Config.Admin.oxGroups = { 'admin', 'superadmin', 'moderator', 'owner', 'dev' }
```

Every admin action (create, delete) is validated server-side before execution.

---

## 🔧 Developer API

### GlobalState (any client or server)

```lua
-- Read all mechanic positions
local mechanics = GlobalState.rde_mechanics
-- Returns: { ['1'] = { x, y, z, heading, model }, ['2'] = { ... }, ... }
```

---

## 🗄️ Database

```sql
CREATE TABLE IF NOT EXISTS rde_mechanics (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    coords_x   FLOAT        NOT NULL,
    coords_y   FLOAT        NOT NULL,
    coords_z   FLOAT        NOT NULL,
    heading    FLOAT        NOT NULL,
    model      VARCHAR(50)  DEFAULT 's_m_m_autoshop_01',
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coords (coords_x, coords_y, coords_z)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

All positions loaded on server start, pushed to GlobalState. Zero per-player DB queries.

---

## ⚡ Performance

### Architecture Advantages

| Aspect | Traditional Approach | RDE Mechanic |
|---|---|---|
| Entity type | Server-side network peds | ✅ Client-side local peds |
| CNetObj usage | 1 per mechanic ped | ✅ 0 |
| Sync on join | Network event per player | ✅ GlobalState — automatic |
| Rendering | All peds always loaded | ✅ Proximity-based LOD |

### Benchmarks

| Mechanic Peds | Client Impact | Server Impact |
|---|---|---|
| 10 | Negligible | < 0.01ms |
| 50 | Negligible (only nearby spawned) | < 0.01ms |
| 100 | < 0.5% FPS | < 0.02ms |

### Why So Fast?

- **Zero server entities** — Client creates local peds, no server overhead
- **Proximity culling** — Only peds within `renderDistance` are spawned
- **Hysteresis** — 50m gap between render/despawn prevents flicker
- **GlobalState** — Single statebag update replaces N network events (N = player count)
- **1s tick** — Static NPCs don't need sub-second proximity checks

---

## 🐛 Troubleshooting

**Mechanic peds not spawning after server restart?**
Check that `oxmysql` starts before `rde_mechanic`. Enable `Config.Debug.enabled = true` and look for `GlobalState broadcast — X mechanics` in txAdmin console.

**Mechanic spawns but immediately despawns?**
Player is outside `renderDistance`. Check `Config.Performance` — `renderDistance` must be less than `despawnDistance`.

**ox_target options not showing?**
Ensure `ox_target` starts before `rde_mechanic`. Use `/debugmechanics` to confirm ped exists locally.

**Repair animation but vehicle stays broken?**
If buyer ≠ vehicle owner, server relays `applyRepair` to the owner. Verify both players are in the same session. Check F8 for network errors.

**Price validation mismatch warnings in console?**
Enable debug to see `Price mismatch` messages. Server auto-corrects to the real price — no action needed unless mismatches are frequent.

**Admin target not showing?**
Admin status checked via `lib.callback` on target hover. Verify ACE or ox_core group config. If ox_core is not running, only ACE is checked.

---

## 📋 Commands

| Command | Access | Description |
|---|---|---|
| `/mechanics` | Admin | Open admin panel — create mechanic at current position |
| `/debugmechanics` | Debug | Print GlobalState count and locally spawned peds |

---

## 📝 Changelog

### v2.0.0 — Current
- **GlobalState sync** — replaced per-player `requestSync`/`syncMechanics` events entirely
- **Proximity loading** — client-side spawn/despawn loop with configurable render/despawn distance and hysteresis
- **Zero server entities** — peds are local-only, zero CNetObj overhead
- **Late-join zero-event** — joining players auto-receive mechanic state from GlobalState
- `Config.Performance` block added (renderDistance, despawnDistance, proximityTick, maxVisibleMechanics)
- `DespawnMechanic()` — correct cleanup for local peds + removed ox_target on despawn
- `debugmechanics` updated — shows GlobalState count vs. spawned count
- fxmanifest version bumped to 2.0.0

### v1.0.0
- Initial release
- NPC mechanic peds with animated 6-phase repair sequence
- Full 60+ mod type tuning menus with Lucide icons
- Server-side price validation + rate limiting + cooldowns
- StateBag coordination for repair conflict prevention
- Vehicle weapons support (MG, Missiles, Flamethrower, Minigun, Railgun, Laser)
- Multi-language EN + DE
- Nostr logging integration
- MySQL persistence with auto-table creation

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m 'Add your feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

Guidelines: follow existing Lua conventions, comment complex logic, test on a live server before PR, update docs if adding features.

---

## 📜 License

```
###################################################################################
#                                                                                 #
#      .:: RED DRAGON ELITE (RDE)  -  BLACK FLAG SOURCE LICENSE v6.66 ::.         #
#                                                                                 #
#   PROJECT:    RDE_MECHANIC v2.0.0 (VEHICLE MECHANIC & TUNER FOR FIVEM)          #
#   ARCHITECT:  .:: RDE ⧌ Shin [△ ᛋᛅᚱᛒᛅᚾᛏᛋ ᛒᛁᛏᛅ ▽] ::. | https://rd-elite.com     #
#   ORIGIN:     https://github.com/RedDragonElite                                 #
#                                                                                 #
#   WARNING: THIS CODE IS PROTECTED BY DIGITAL VOODOO AND PURE HATRED FOR LEAKERS #
#                                                                                 #
#   [ THE RULES OF THE GAME ]                                                     #
#                                                                                 #
#   1. // THE "FUCK GREED" PROTOCOL (FREE USE)                                    #
#      You are free to use, edit, and abuse this code on your server.             #
#      Learn from it. Break it. Fix it. That is the hacker way.                   #
#      Cost: 0.00€. If you paid for this, you got scammed by a rat.               #
#                                                                                 #
#   2. // THE TEBEX KILL SWITCH (COMMERCIAL SUICIDE)                              #
#      Listen closely, you parasites:                                             #
#      If I find this script on Tebex, Patreon, or in a paid "Premium Pack":      #
#      > I will DMCA your store into oblivion.                                    #
#      > I will publicly shame your community.                                    #
#      > I hope your server lag spikes to 9999ms every time you blink.            #
#      SELLING FREE WORK IS THEFT. AND I AM THE JUDGE.                            #
#                                                                                 #
#   3. // THE CREDIT OATH                                                         #
#      Keep this header. If you remove my name, you admit you have no skill.      #
#      You can add "Edited by [YourName]", but never erase the original creator.  #
#      Don't be a skid. Respect the architecture.                                 #
#                                                                                 #
#   4. // THE CURSE OF THE COPY-PASTE                                             #
#      This code uses GlobalState, proximity loading, and server-side validation. #
#      If you just copy-paste without reading, it WILL break.                     #
#      Don't come crying to my DMs. RTFM or learn to code.                        #
#                                                                                 #
#   --------------------------------------------------------------------------    #
#   "We build the future on the graves of paid resources."                        #
#   "REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY."                          #
#   --------------------------------------------------------------------------    #
###################################################################################
```

**TL;DR:**
- ✅ Free forever — use it, edit it, learn from it
- ✅ Keep the header — credit where it's due
- ❌ Don't sell it — commercial use = instant DMCA
- ❌ Don't be a skid — copy-paste without reading won't work anyway

---

## 📁 File Structure

```
rde_mechanic/
├── fxmanifest.lua    # Resource manifest
├── config.lua        # All configuration, languages, prices, categories
├── client.lua        # GlobalState listener, proximity loop, ped management, tuning menus
├── server.lua        # GlobalState broadcast, DB, price validation, economy, admin
├── LICENSE           # RDE Black Flag Source License v6.66
└── README.md         # You're reading it
```

---

## 🌐 Community & Support

| | |
|---|---|
| 🐙 GitHub | [RedDragonElite](https://github.com/RedDragonElite) |
| 🌍 Website | [rd-elite.com](https://rd-elite.com) |
| 🔵 Nostr (RDE) | [RedDragonElite](https://primal.net/p/nprofile1qqsv8km2w8yr0sp7mtk3t44qfw7wmvh8caqpnrd7z6ll6mn9ts03teg9ha4rl) |
| 🔵 Nostr (Shin) | [SerpentsByte](https://primal.net/p/nprofile1qqs8p6u423fappfqrrmxful5kt95hs7d04yr25x88apv7k4vszf4gcqynchct) |
| 😴 RDE Sleep | [rde_sleep](https://github.com/RedDragonElite/rde_sleep) |
| 🎮 RDE Props | [rde_props](https://github.com/RedDragonElite/rde_props) |
| 🚪 RDE Doors | [rde_doors](https://github.com/RedDragonElite/rde_doors) |
| 🎯 RDE Skills | [rde_skills](https://github.com/RedDragonElite/rde_skills) |
| 📡 RDE Nostr Log | [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) |

**When asking for help, always include:**
- Full error from server console or txAdmin
- Your `server.cfg` resource start order
- ox_lib / ox_inventory / ox_target versions
- Output of `/debugmechanics` in-game

---

<div align="center">

*"We build the future on the graves of paid resources."*

**REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY.**

🐉 Made with 🔥 by [Red Dragon Elite](https://rd-elite.com)

[⬆ Back to Top](#-rde-mechanic--next-gen-vehicle-mechanic--tuner-system)

</div>
