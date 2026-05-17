# 🐉 rde_mechanic

[![Version](https://img.shields.io/badge/version-2.1.0-red?style=for-the-badge)](https://github.com/RedDragonElite/rde_mechanic)
[![License](https://img.shields.io/badge/license-RDE%20Black%20Flag-black?style=for-the-badge)](https://github.com/RedDragonElite/rde_mechanic/blob/main/LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue?style=for-the-badge)](https://fivem.net)
[![ox_core](https://img.shields.io/badge/Framework-ox__core-blue?style=for-the-badge)](https://github.com/overextended/ox_core)
[![Nostr](https://img.shields.io/badge/Nostr-Decentralized-purple?style=for-the-badge)](https://github.com/RedDragonElite/rde_nostr_log)
[![Quality](https://img.shields.io/badge/Quality-Production-gold?style=for-the-badge)](https://github.com/RedDragonElite)

**🔧 RDE MECHANIC | Next-Gen Vehicle Mechanic & Tuner for FiveM ox_core | Full Mod Preview | Orbit Camera | StateBag-Synced | Nostr-Logged | Production-Ready**

*Built by [Red Dragon Elite](https://rd-elite.com) | Free Forever | No Paywalls | No Legacy*

[📖 Installation](#-installation) • [⚙️ Configuration](#️-configuration) • [🌍 Locales](#-locales) • [🐉 Nostr Logging](#-nostr-logging) • [📡 Events & Callbacks](#-events--callbacks) • [🐛 Troubleshooting](#-troubleshooting) • [🌐 Website](https://rd-elite.com)

---

## 🔥 Why This Destroys Every Other Mechanic Script

Every other mechanic/tuner script is either paid, ESX/QB-only, or a static menu with zero preview and brain-dead ped behavior.

We said no.

| ❌ Other Mechanic Scripts | ✅ rde_mechanic |
|---|---|
| Static menus, no preview | Live mod preview with confirm/cancel on every part |
| Camera goes nowhere useful | Smooth orbit camera circles the car during tuning |
| Ped teleports to engine | Mechanic walks to the hood, faces it, opens it, animates, closes it, walks back |
| ESX / QBCore bloat | ox_core only — the future, not the past |
| Discord webhooks (deletable) | Decentralized Nostr logging — permanent & uncensorable |
| One language | Full EN / DE multilanguage out of the box |
| Paid or locked down | 100% free forever — RDE Black Flag |

---

### 🎯 Key Features

- 🔧 **Full Mechanic Animation Sequence** — walks to hood, faces it, opens it, animates with tool prop, closes hood, steps back, walks home. Zero teleports.
- 👁️ **Live Mod Preview** — every single mod, wheel, color, neon: preview it on the car before paying. Cancel = instant revert.
- 📸 **Orbit Camera** — during tuning the camera slowly circles the car. Fully configurable speed, radius, height, FOV. Maus stays free for the menu.
- 🔄 **StateBag Multiplayer Sync** — repair state, preview state, mechanic phase — all synced via StateBags to every nearby client in real time
- 🐉 **Nostr Logging** — decentralized, cryptographically signed, uncensorable purchase & repair logs
- 💰 **Dynamic Pricing** — vehicle class multipliers, high-end tier pricing, separate color/wheel pricing
- 🛡️ **Server-Side Authority** — all purchases and repairs validated server-side. No client-sided exploit possible.
- 📦 **Full Mod Coverage** — 65+ mod types, 15 wheel categories with named rims, 7 color categories, neon with 14 RGB presets, window tint, extras, liveries
- 🌍 **Multilanguage** — EN / DE out of the box, add any language in minutes
- ⚙️ **Zero-Config Start** — sensible defaults, DB tables auto-create, no SQL import needed
- 🔑 **Admin Panel** — in-game mechanic creation & deletion with ACE/ox_core group auth

---

## 📸 Screenshots

> Coming soon — drop a PR with your screenshots!

---

## 📦 Dependencies

```
oxmysql        → https://github.com/overextended/oxmysql
ox_lib         → https://github.com/overextended/ox_lib
ox_core        → https://github.com/overextended/ox_core
ox_inventory   → https://github.com/overextended/ox_inventory
ox_target      → https://github.com/overextended/ox_target

optional:
rde_nostr_log  → https://github.com/RedDragonElite/rde_nostr_log
```

---

## 🚀 Installation

### Step 1: Clone or download

```bash
cd resources
git clone https://github.com/RedDragonElite/rde_mechanic.git
```

### Step 2: Add to server.cfg

```
# Dependencies first — order matters!
ensure oxmysql
ensure ox_lib
ensure ox_core
ensure ox_inventory
ensure ox_target

# Optional: Nostr logging (highly recommended)
ensure rde_nostr_log

# The mechanic & tuner
ensure rde_mechanic
```

### Step 3: Configure

Edit `config.lua` — sensible defaults work out of the box. See [Configuration](#️-configuration).

### Step 4: Start your server

That's it. No SQL import needed — tables auto-create on first run. Walk up to the ox_target zone at any mechanic NPC and press `E`.

---

## ⚙️ Configuration

`config.lua` is fully self-documented. Every block has comments. Key sections:

### Language & Debug

```lua
Config.DefaultLanguage = 'en'   -- 'en' or 'de'

Config.Debug = {
    enabled   = false,          -- set true to enable console logging
    logLevel  = 'INFO',         -- 'INFO' | 'WARN' | 'ERROR'
}
```

### Repair

```lua
Config.Repair = {
    basePrice             = 500,
    pricePerDamage        = 0.5,
    maxPrice              = 10000,
    engineHealthThreshold = 950.0,   -- below this = damaged
    bodyHealthThreshold   = 950.0,
    minRepairTime         = 5000,    -- ms
    maxRepairTime         = 30000,   -- ms
    damageTimeMultiplier  = 10,      -- more damage = longer repair
}
```

### Orbit Camera

```lua
Config.TuningCamera = {
    enabled       = true,    -- false = normal gameplay cam stays
    radius        = 7.0,     -- distance from vehicle center (meters)
    height        = 1.8,     -- height above vehicle center (meters)
    fov           = 55.0,    -- field of view in degrees
    degreesPerSec = 18.0,    -- rotation speed (positive = counter-clockwise from above)
    startAngle    = 160.0,   -- starting angle (0 = behind car, 90 = left side, 180 = front)
    fadeInMs      = 800,     -- camera fade-in duration (ms)
    fadeOutMs     = 600,     -- camera fade-out duration (ms)
}
```

### Mechanic Behavior

```lua
Config.MechanicBehavior = {
    invincible     = true,
    freezePosition = true,
    blockEvents    = true,
    canRagdoll     = false,
    walkSpeed      = 1.0,
    animations     = {
        { dict='mini@repair', name='fixing_a_ped', tool='prop_tool_spanner02', bone=28422, loops=3 },
    }
}
```

### Admin

```lua
Config.Admin = {
    acePermission = 'rde.mechanic.admin',
    oxGroups      = { 'admin', 'superadmin', 'moderator', 'owner', 'dev' },
}
```

### Nostr Config

```lua
Config.NostrLog = {
    enabled            = true,
    logPurchases       = true,
    logRepairs         = true,
    logAdminCreate     = true,
    logAdminDelete     = true,
    expensiveThreshold = 5000,   -- log to Nostr if mod costs more than this
    serverTag          = 'rde_mechanic',
}
```

---

## 🌍 Locales

All user-facing text lives in `Config.Languages` inside `config.lua`. Switch language:

```lua
Config.DefaultLanguage = 'de'   -- config.lua
```

**Add a new language:**

1. Copy the `en` block inside `Config.Languages`
2. Rename the key to your language code (e.g. `fr`)
3. Translate all values — keep the keys!
4. Set `Config.DefaultLanguage = 'fr'`

Currently supported:

| Code | Language |
|---|---|
| `en` | 🇬🇧 English |
| `de` | 🇩🇪 Deutsch |

---

## 📸 Orbit Camera

During any tuning session the camera automatically starts orbiting the vehicle. No extra setup needed.

| Setting | Default | Effect |
|---|---|---|
| `radius` | `7.0` | How far from the car (meters). Bigger = more overview. |
| `height` | `1.8` | How high above the car center. Higher = more top-down. |
| `fov` | `55.0` | Field of view. Lower = zoom, higher = wide-angle. |
| `degreesPerSec` | `18.0` | One full rotation every ~20 seconds. Raise to spin faster. |
| `startAngle` | `160.0` | Where the camera starts. 0 = rear, 90 = left, 180 = front. |
| `enabled` | `true` | Set `false` to revert to default GTA gameplay camera. |

The camera **never touches mouse input** — the ox_lib context menu is fully usable with the mouse while the camera orbits. The orbit stops automatically when the tuning menu closes.

---

## 🔧 Mechanic Animation Sequence

The mechanic NPC follows a strict 6-phase sequence with no teleports:

| Phase | What happens |
|---|---|
| **1 – Walk** | Ped walks from spawn post to the driver-side hood position |
| **2 – Face & freeze** | Ped turns to face the hood center, then freezes in place |
| **3 – Hood open** | Hood opens with sound effect, 1.2s pause for the animation |
| **4 – Repair** | Tool prop attached, repair animation loops, vehicle health restored progressively |
| **5 – Step back & hood close** | Ped unfreezes, steps away from the vehicle, hood closes |
| **6 – Walk home** | Ped walks back to spawn coordinates, turns to original heading, freezes again |

---

## 🐉 Nostr Logging

rde_mechanic ships with **first-class [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) integration**.

Every critical event is logged to the decentralized Nostr network — permanent, cryptographically signed, uncensorable. No Discord. No rate limits. No single point of failure.

### Events logged automatically

| Event | Toggle Key |
|---|---|
| Vehicle repaired | `logRepairs` |
| Mod purchased | `logPurchases` |
| Expensive purchase (above threshold) | `logPurchases` |
| Mechanic NPC created by admin | `logAdminCreate` |
| Mechanic NPC deleted by admin | `logAdminDelete` |

### Disable Nostr completely

```lua
Config.NostrLog.enabled = false
```

Zero overhead. Zero side effects. The system runs normally without it.

---

## 📡 Events & Callbacks

### Server Events (triggered from client)

```lua
-- Request a repair from a mechanic
TriggerServerEvent('rde_mechanic:requestRepair', vehicleNetId, mechanicId, clientPrice, vClass)

-- Signal repair phase change (walking / repairing / returning / idle)
TriggerServerEvent('rde_mechanic:repairPhase', mechanicId, phase, data)

-- Confirm repair complete
TriggerServerEvent('rde_mechanic:repairComplete', vehicleNetId)

-- Purchase a vehicle mod
TriggerServerEvent('rde_mechanic:purchaseMod', netId, modType, modValue, price, wheelType, isToggle, vClass)

-- Purchase a color change
TriggerServerEvent('rde_mechanic:purchaseColor', netId, colorType, colorId, price, vClass)

-- Purchase neon
TriggerServerEvent('rde_mechanic:purchaseNeon', netId, r, g, b, price, vClass)

-- Toggle an extra
TriggerServerEvent('rde_mechanic:purchaseExtra', netId, extraId, extraState, price, vClass)

-- Save vehicle properties after session
TriggerServerEvent('rde_mechanic:saveVehicleProperties', vehicleNetId, properties)

-- Admin: create mechanic NPC
TriggerServerEvent('rde_mechanic:createMechanic', coords, heading)

-- Admin: delete mechanic NPC
TriggerServerEvent('rde_mechanic:deleteMechanic', id)

-- Sync preview state to other clients
TriggerServerEvent('rde_mechanic:setPreviewMod', vehicleNetId, previewData)
```

### lib.callback

```lua
-- Check if player is admin (returns bool)
lib.callback('rde_mechanic:isAdmin', false, function(result) end)
```

### StateBag Keys

```lua
-- Vehicle currently being repaired (playerId or false)
Entity(vehicle).state['rde:repairing']

-- Vehicle currently being tuned (playerId or false)
Entity(vehicle).state['rde:tuner']

-- Player is busy (bool)
Player(source).state['rde:busy']

-- Active mod preview data (table or false)
Entity(vehicle).state['rde:preview']

-- GlobalState mechanic repair phase sync
GlobalState['rde:mech_status']
```

---

## 🗂 Folder Structure

```
rde_mechanic/
├── fxmanifest.lua       ← Resource manifest, dependencies
├── config.lua           ← Full configuration (camera, prices, mods, behavior, locales)
├── client.lua           ← All client logic: ped spawning, camera, preview, menus
├── server.lua           ← All server logic: auth, purchases, repair validation, Nostr
└── README.md
```

---

## 🔧 Debug

Enable with `Config.Debug.enabled = true` in `config.lua`, then check your server console and F8 client console for `[RDE][HH:MM:SS]` prefixed output.

| What to check | Where |
|---|---|
| Resource not starting | `luac5.4 -p client.lua` and `luac5.4 -p server.lua` in bash |
| Mechanic not spawning | Server console — look for `[RDE]` spawn/DB errors |
| Purchase rejected | Server console — price validation logs the mismatch |
| Camera not working | `Config.TuningCamera.enabled` — confirm it's `true` |
| Mod preview not reverting | Check `Entity(veh).state['rde:preview']` in client console |

---

## 🛡 Security

- All purchases **validated server-side** — mod type, price, vehicle ownership
- Rate limiting: `Config.Security.maxPurchasesPerMinute = 15`
- Repair cooldown: `Config.Security.repairCooldown = 5` seconds
- Admin actions gated by ACE permission **and** ox_core group check
- StateBags used for sync — no polling, no `TriggerClientEvent` spam
- Nostr logs are cryptographically signed — tamper-proof by design

---

## 🐛 Troubleshooting

### Resource fails to start

Run `luac5.4 -p client.lua` and `luac5.4 -p server.lua` in bash. Any Lua syntax error will print the exact line. Fix it, restart.

### Mechanic NPC doesn't spawn

1. Enable debug and check server console for `[RDE]` DB errors
2. Confirm `oxmysql` is running and connected
3. Make sure the `mechanic_locations` table exists (auto-created on first start)
4. Walk within `Config.Distances.interactionRange` (default 8.0m) of the target zone

### Mod preview doesn't revert on cancel

The preview state lives in `Entity(vehicle).state['rde:preview']`. If the cancel callback fires but the mod stays:
1. Confirm the vehicle entity is still valid (`DoesEntityExist`)
2. Check client console for `[RDE] RestoreFromCapture` output
3. Open an issue with F8 logs

### Camera orbits but looks wrong (too high/low/far)

Tune `Config.TuningCamera` in `config.lua`:
- Too far away → lower `radius`
- Looking at the sky → lower `height`
- Too zoomed in → raise `fov`
- Spinning too fast → lower `degreesPerSec`

### Nostr logger not connecting

```
[RDE | Mechanic | Nostr] ✗ Resource "rde_nostr_log" not found
```

Install [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) and ensure it starts **before** rde_mechanic. The mechanic system continues to function normally without it.

### Purchase rejected with "Not enough money"

ox_inventory is used for money checks. Confirm:
1. `ox_inventory` is running and started before `rde_mechanic`
2. The player has `money` item in their inventory
3. `Config.Security.validatePricesServerSide = true` — client-sent price is validated against server-side calculation

---

## 📚 Tech Stack

```
ox_core        → Player & group management, admin auth
ox_lib         → UI, context menus, progress bars, notifications, callbacks
ox_inventory   → Inventory & money management
ox_target      → Interaction zones on mechanic NPCs
oxmysql        → Async database (mechanic locations persist)
StateBags      → Realtime vehicle & player state sync across all clients
rde_nostr_log  → Decentralized logging (optional)
```

---

## 🤝 Contributing

PRs are always welcome.

1. **Fork** the repository
2. **Create** a branch: `git checkout -b feature/your-feature`
3. **Test** on a live server before submitting
4. **Commit**: `git commit -m 'feat: your feature description'`
5. **Push**: `git push origin feature/your-feature`
6. **Open** a Pull Request with a clear description

**Guidelines:**

- ✅ Keep the RDE header in all files
- ✅ Follow existing code style — ox_core, ox_lib, StateBags
- ✅ Run `luac5.4 -p` on every modified `.lua` file before pushing
- ✅ Test on a live server before PR — don't ship syntax errors
- ❌ No telemetry, no paywalls, no ESX/QBCore
- ❌ Don't downgrade security — server-side validation stays
- ❌ Don't hardcode user-facing strings — use `L('key')` and add to all locale blocks in `config.lua`

---

## 📜 License

**RDE Black Flag Source License v6.66**

```
###################################################################################
#                                                                                 #
#      .:: RED DRAGON ELITE (RDE)  -  BLACK FLAG SOURCE LICENSE v6.66 ::.         #
#                                                                                 #
#   PROJECT:    RDE_MECHANIC (NEXT-GEN VEHICLE MECHANIC & TUNER FOR FIVEM OX_CORE)#
#   ARCHITECT:  .:: RDE ⧌ Shin [△ ᛋᛅᚱᛒᛅᚾᛁᛋ ᛒᛁᛞᛅ ▽] ::. | https://rd-elite.com     #
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
#      If I find this script on any paid store, Patreon, or "Premium Pack":       #
#      > I will DMCA your store into oblivion.                                    #
#      > I will publicly shame your community on Nostr. Permanently.              #
#      > I hope every mod menu opens to the wrong vehicle forever.                #
#      SELLING FREE WORK IS THEFT. AND I AM THE JUDGE.                            #
#                                                                                 #
#   3. // THE CREDIT OATH                                                         #
#      Keep this header. If you remove my name, you admit you have no skill.      #
#      You can add "Edited by [YourName]", but never erase the original creator.  #
#      Don't be a skid. Respect the architecture.                                 #
#                                                                                 #
#   4. // THE CURSE OF THE COPY-PASTE                                             #
#      This code implements real StateBag sync, server-side price validation,     #
#      live preview with full revert, and animated ped sequences. If you          #
#      copy-paste without understanding, you WILL break something expensive.      #
#      Don't come crying to my DMs. RTFM.                                         #
#                                                                                 #
#   --------------------------------------------------------------------------    #
#   "We build the future on the graves of paid resources."                        #
#   "REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY."                          #
#   --------------------------------------------------------------------------    #
###################################################################################
```

**TL;DR:**

- ✅ **Free forever** — use it, edit it, learn from it
- ✅ **Keep the header** — credit where it's due
- ❌ **Don't sell it** — commercial use = instant DMCA + public shaming on Nostr
- ❌ **Don't be a skid** — copy-paste without reading will break things

---

## ⚡ Related Projects

| Resource | Description |
|---|---|
| [rde_aipd](https://github.com/RedDragonElite/rde_aipd) | Ultimate AI Police System — StateBag-synced, Nostr-logged |
| [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) | Decentralized FiveM logging via Nostr — replace Discord forever |
| [awesome-ox-rde](https://github.com/RedDragonElite/awesome-ox-rde) | Curated list of the best ox_core resources |

---

## 🌐 Community & Support

| | |
|---|---|
| 🌍 **Website** | [rd-elite.com](https://rd-elite.com) |
| 🔭 **Nostr Terminal** | [rd-elite.com/Files/NOSTR/Terminal](https://rd-elite.com/Files/NOSTR/Terminal/) |
| 🐙 **GitHub** | [github.com/RedDragonElite](https://github.com/RedDragonElite) |
| 🟣 **Nostr** | `npub1wr4e24zn6zzjqx8kvnelfvktf0pu6l2gx4gvw06zead2eqyn23sq9tsd94` |

**Before opening an issue:**

- ✅ Read this README fully
- ✅ Check the [Troubleshooting](#-troubleshooting) section
- ✅ Include your server console output and F8 client logs
- ❌ Don't open issues without logs — we can't help without them

---

**Made with 🔥 and zero tolerance for paid garages by [Red Dragon Elite](https://rd-elite.com)**

*The future is ours. We are already inside.*

**REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY.**

**RDE FOREVER. SYSTEM FAILURE. ⚡777⚡**

[![Website](https://img.shields.io/badge/Website-Visit-red?style=for-the-badge&logo=google-chrome)](https://rd-elite.com)
[![Nostr](https://img.shields.io/badge/Nostr-Follow-purple?style=for-the-badge&logo=rss)](https://primal.net/p/npub1wr4e24zn6zzjqx8kvnelfvktf0pu6l2gx4gvw06zead2eqyn23sq9tsd94)
[![Terminal](https://img.shields.io/badge/Terminal-Live-green?style=for-the-badge&logo=gnome-terminal)](https://rd-elite.com/Files/NOSTR/)