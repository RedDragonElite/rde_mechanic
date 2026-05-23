-- ╔════════════════════════════════════════════════════════════╗
-- ║  RDE | Core | 🔺 NEXT-GEN MECHANIC & TUNER               ║
-- ║  SERVER v2.2 – GlobalState | StateBags | Repair Sync      ║
-- ╠════════════════════════════════════════════════════════════╣
-- ║  FIX LOG v2.2:                                             ║
-- ║  [#1] SaveVehicleToDB: NetworkGetEntityFromNetworkId ist   ║
-- ║       server-seitig unzuverlässig → plate aus properties   ║
-- ║       (vom Client gesendet) wird jetzt direkt genutzt.     ║
-- ║  [#2] Config.VehicleProperties.useOxVehicle = true wurde   ║
-- ║       komplett ignoriert → Raw SQL wurde immer geschrieben. ║
-- ║       Fix: ox_vehicles:setVehicleProperties() wird jetzt   ║
-- ║       korrekt aufgerufen wenn useOxVehicle = true.         ║
-- ║  [#3] Plate-Normalisierung (trim + uppercase) damit SQL-    ║
-- ║       Fallback auch bei Leerzeichen-Plates matched.        ║
-- ╚════════════════════════════════════════════════════════════╝

local RESOURCE_NAME <const> = GetCurrentResourceName()

local State = {
    mechanics          = {},
    repairPending      = {},   -- [vehicleNetId] = { buyer=src, owner=src }
    purchaseTimestamps = {},
    cooldowns          = {},
    playerPreviews     = {},   -- [src] = vehicleNetId  (for cleanup on drop)
    ready              = false,
}

-- ============================================
-- 🛠️ UTILITIES
-- ============================================
local function Log(msg, level)
    if not Config or not Config.Debug or not Config.Debug.enabled then return end
    print(('[^3RDE^7][%s][%s] %s'):format(os.date('%H:%M:%S'), level or 'INFO', tostring(msg)))
end

local function L(key, ...)
    local lang = (Config and Config.DefaultLanguage) or 'en'
    local t    = Config and Config.Languages and Config.Languages[lang]
    local str  = (t and t[key]) or key
    if select('#', ...) > 0 then return string.format(tostring(str), ...) end
    return tostring(str)
end

local function Notify(src, ntype, msg, icon)
    if not src or src == 0 then return end
    TriggerClientEvent('ox_lib:notify', src, {
        title       = L(ntype),
        description = tostring(msg),
        type        = tostring(ntype),
        position    = Config.Notification.position,
        duration    = Config.Notification.duration,
        icon        = icon or 'info',
        iconColor   = ntype == 'success' and '#10b981'
                   or ntype == 'error'   and '#ef4444'
                   or ntype == 'warning' and '#f59e0b'
                   or '#3b82f6',
    })
end

-- ============================================
-- 📡 GLOBALSTATE BROADCAST
-- ============================================
local function BroadcastMechanics()
    local flat = {}
    for id, m in pairs(State.mechanics) do
        flat[tostring(id)] = {
            x       = m.coords.x,
            y       = m.coords.y,
            z       = m.coords.z,
            heading = m.heading,
            model   = m.model,
        }
    end
    GlobalState:set('rde_mechanics', flat, true)
    local count = 0
    for _ in pairs(flat) do count = count + 1 end
    Log(('GlobalState updated — %d mechanics'):format(count), 'INFO')
end

-- Mechanic repair phase sync — all clients animate their local ped accordingly
local function BroadcastMechanicStatus(mechanicId, phase, data)
    local current = GlobalState[Config.StateBags.mechanicStatus] or {}
    local updated = {}
    for k, v in pairs(current) do updated[k] = v end  -- shallow copy to avoid shared state mutation

    if phase == 'idle' or not phase then
        updated[tostring(mechanicId)] = nil
    else
        updated[tostring(mechanicId)] = { phase = phase, data = data or {} }
    end
    GlobalState:set(Config.StateBags.mechanicStatus, updated, true)
end

-- ============================================
-- 🐉 NOSTR LOGGING
-- ============================================
local function NostrLog(message, tags)
    if not Config.NostrLog or not Config.NostrLog.enabled then return end
    if GetResourceState('rde_nostr_log') ~= 'started' then return end
    local fullTags = tags or {}
    table.insert(fullTags, {'server', Config.NostrLog.serverTag or 'rde_mechanic'})
    local ok, err = pcall(function()
        exports['rde_nostr_log']:postLog(message, fullTags)
    end)
    if not ok then Log('NostrLog error: ' .. tostring(err), 'WARN') end
end

-- ============================================
-- 💰 ECONOMY
-- ============================================
local function HasMoney(src, amount)
    if amount <= 0 then return true end
    local ok, count = pcall(function()
        return exports.ox_inventory:GetItemCount(src, 'money')
    end)
    if not ok then return false end
    return (tonumber(count) or 0) >= tonumber(amount)
end

local function RemoveMoney(src, amount)
    if amount <= 0 then return true end
    local ok, result = pcall(function()
        return exports.ox_inventory:RemoveItem(src, 'money', tonumber(amount))
    end)
    if not ok then return false end
    if result then Log(('💰 %s paid $%d'):format(GetPlayerName(src), amount), 'INFO') end
    return result
end

-- ============================================
-- 🔐 PERMISSIONS
-- FIX: was using undefined `Ox` global and wrong method `getGroups()`
-- Correct: exports.ox_core:getPlayer(src) returns player object
-- with player.getGroup(groupName) → returns grade or nil
-- ============================================
local function IsAdmin(src)
    if not src or src == 0 then return false end
    if IsPlayerAceAllowed(src, Config.Admin.acePermission) then return true end
    local ok, result = pcall(function()
        local player = exports.ox_core:getPlayer(src)
        if not player then return false end
        for _, g in ipairs(Config.Admin.oxGroups) do
            if player.getGroup(g) then return true end
        end
        return false
    end)
    return ok and result or false
end

lib.callback.register('rde_mechanic:isAdmin', function(src)
    return IsAdmin(src)
end)

-- ============================================
-- 🛡️ ANTI-EXPLOIT
-- ============================================
local function CheckRate(src)
    local now = GetGameTimer()
    State.purchaseTimestamps[src] = State.purchaseTimestamps[src] or {}
    local clean = {}
    for _, ts in ipairs(State.purchaseTimestamps[src]) do
        if now - ts <= 60000 then table.insert(clean, ts) end
    end
    State.purchaseTimestamps[src] = clean
    if #clean >= (Config.Security.maxPurchasesPerMinute or 15) then
        Log('Rate limit: ' .. GetPlayerName(src), 'WARN')
        return false
    end
    table.insert(State.purchaseTimestamps[src], now)
    return true
end

local function CheckCooldown(src, cdType)
    local now = os.time()
    local cd  = tonumber(Config.Security[cdType .. 'Cooldown']) or 60
    State.cooldowns[src] = State.cooldowns[src] or {}
    if State.cooldowns[src][cdType] and now - State.cooldowns[src][cdType] < cd then
        return false
    end
    State.cooldowns[src][cdType] = now
    return true
end

-- ============================================
-- 💰 PRICE VALIDATION
-- ============================================
local function ValidatePrice(vClass, priceKey, clientPrice)
    if not Config.Security.validatePricesServerSide then
        return tonumber(clientPrice) or 0
    end
    -- priceKey can be a number (mod type) or string (color_primary etc.)
    local base = tonumber(Config.Prices[priceKey]) or 0
    local mult = tonumber(Config.VehicleClassMultipliers[tonumber(vClass)]) or 1.0
    local real = math.floor(base * mult)
    local got  = tonumber(clientPrice) or 0
    -- Allow 10% tolerance for rounding
    if real > 0 and math.abs(got - real) > math.floor(real * 0.1) + 1 then
        Log(('Price mismatch key=%s expected=%d got=%d'):format(tostring(priceKey), real, got), 'WARN')
        return real
    end
    return got
end

-- ============================================
-- 💾 DATABASE
-- ============================================
local function InitDB()
    local ok, err = pcall(function()
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS rde_mechanics (
                id         INT AUTO_INCREMENT PRIMARY KEY,
                coords_x   FLOAT        NOT NULL,
                coords_y   FLOAT        NOT NULL,
                coords_z   FLOAT        NOT NULL,
                heading    FLOAT        NOT NULL,
                model      VARCHAR(50)  DEFAULT 's_m_m_autoshop_01',
                created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_coords (coords_x, coords_y, coords_z)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
    end)
    if not ok then Log('DB init failed: ' .. tostring(err), 'ERROR') return false end
    Log('Database ready', 'SUCCESS')
    return true
end

local function LoadMechanics()
    local ok, rows = pcall(function()
        return MySQL.query.await('SELECT * FROM rde_mechanics ORDER BY id ASC')
    end)
    if not ok or not rows then
        Log('Failed to load mechanics: ' .. tostring(rows), 'ERROR')
        return
    end
    -- FIX: #rows is unreliable on oxmysql result sets — use explicit counter
    local count = 0
    for _, row in ipairs(rows) do
        local id = tonumber(row.id)
        State.mechanics[id] = {
            coords  = vector3(tonumber(row.coords_x), tonumber(row.coords_y), tonumber(row.coords_z)),
            heading = tonumber(row.heading) or 0,
            model   = row.model or Config.MechanicModels[1],
        }
        count = count + 1
    end
    Log(('%d mechanics loaded from DB'):format(count), 'SUCCESS')
end

local function SaveMechanic(coords, heading, model)
    local ok, id = pcall(function()
        return MySQL.insert.await(
            'INSERT INTO rde_mechanics (coords_x, coords_y, coords_z, heading, model) VALUES (?,?,?,?,?)',
            { coords.x, coords.y, coords.z, heading, model }
        )
    end)
    if not ok then Log('SaveMechanic error: ' .. tostring(id), 'ERROR') return nil end
    return tonumber(id)
end

local function DeleteMechanicDB(id)
    local ok = pcall(function()
        MySQL.query.await('DELETE FROM rde_mechanics WHERE id = ?', { tonumber(id) })
    end)
    return ok
end

-- ============================================
-- 💾 VEHICLE PROPERTIES
-- ============================================
local function SaveVehicleToDB(vehicleNetId, properties)
    -- FIX: NetworkGetEntityFromNetworkId is unreliable server-side — the entity
    -- handle is only valid in the owning client's scope. We use the plate from
    -- properties (sent by the client via lib.getVehicleProperties) instead.
    --
    -- FIX: Config.VehicleProperties.useOxVehicle = true was being ignored.
    -- The code always fell through to raw SQL, which does NOT persist mods in
    -- ox_vehicles garage setups. Now correctly calls ox_vehicles:setVehicleProperties.

    if not properties or type(properties) ~= 'table' then return false end

    local plate = properties.plate
    if not plate or plate == '' then
        -- fallback: try entity (may work if vehicle is in server scope)
        local veh = NetworkGetEntityFromNetworkId(tonumber(vehicleNetId))
        if DoesEntityExist(veh) then
            plate = GetVehicleNumberPlateText(veh)
        end
    end
    if not plate or plate == '' then
        Log('SaveVehicleToDB: no plate for netId ' .. tostring(vehicleNetId), 'WARN')
        return false
    end

    plate = string.upper(string.gsub(plate, '%s+', ''))  -- normalise: trim + uppercase

    -- Primary path: ox_vehicles (correct for ox_core garage setups)
    if Config.VehicleProperties and Config.VehicleProperties.useOxVehicle then
        local ok, err = pcall(function()
            exports.ox_vehicles:setVehicleProperties(plate, properties)
        end)
        if ok then
            Log('ox_vehicles saved props: ' .. plate, 'SUCCESS')
            return true
        else
            Log('ox_vehicles:setVehicleProperties failed (' .. tostring(err) .. ') falling back to SQL for ' .. plate, 'WARN')
        end
    end

    -- Fallback: raw SQL (non-ox_vehicles garage frameworks)
    local jsonOk, encoded = pcall(json.encode, properties)
    if not jsonOk or not encoded then return false end

    local saved = pcall(function()
        MySQL.update.await([[
            UPDATE vehicles
            SET `data` = JSON_SET(COALESCE(`data`,'{}'), '$.properties', ?)
            WHERE UPPER(REPLACE(plate,' ','')) = ?
        ]], { encoded, plate })
    end)

    if saved then Log('SQL saved vehicle properties: ' .. plate, 'SUCCESS') end
    return saved
end

-- ============================================
-- 📡 NETWORK EVENTS
-- ============================================

-- ──────────────────────────────────────────
-- 🔧 REPAIR
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:requestRepair', function(vehicleNetId, mechanicId, clientPrice, vClass)
    local src   = source
    local netId = tonumber(vehicleNetId)
    if not src or src == 0 then return end

    if not CheckCooldown(src, 'repair') then
        Notify(src, 'warning', L('please_wait'), 'clock')
        return
    end
    if State.repairPending[netId] then
        Notify(src, 'warning', L('vehicle_busy'), 'alert-triangle')
        return
    end

    local classMultiplier = Config.VehicleClassMultipliers[tonumber(vClass)] or 1.0
    local minPrice  = math.floor(Config.Repair.basePrice * classMultiplier)
    local maxPrice  = math.floor(Config.Repair.maxPrice  * classMultiplier)
    local realPrice = math.max(minPrice, math.min(tonumber(clientPrice) or minPrice, maxPrice))

    if not HasMoney(src, realPrice) then
        Notify(src, 'error', L('not_enough_money'), 'wallet')
        return
    end
    if not RemoveMoney(src, realPrice) then
        Notify(src, 'error', L('purchase_failed'), 'x-circle')
        return
    end

    local veh   = NetworkGetEntityFromNetworkId(netId)
    local owner = (DoesEntityExist(veh) and NetworkGetEntityOwner(veh)) or src
    State.repairPending[netId] = { buyer = src, owner = owner }

    pcall(function()
        if DoesEntityExist(veh) then
            Entity(veh).state:set(Config.StateBags.vehicleRepairing, src, true)
        end
    end)

    TriggerClientEvent('rde_mechanic:startRepair', src, tonumber(mechanicId), netId, realPrice)

    Log(('Repair: %s | NetId=%d | $%d'):format(GetPlayerName(src), netId, realPrice), 'INFO')

    if Config.NostrLog and Config.NostrLog.logRepairs then
        NostrLog(('🔧 Repair by %s | $%d | Class %d'):format(GetPlayerName(src), realPrice, vClass or 0), {
            {'event', 'vehicle_repair'}, {'player', GetPlayerName(src)}, {'price', tostring(realPrice)},
        })
    end

    -- Safety timeout — clears stuck repair state after 2 minutes
    SetTimeout(120000, function()
        if State.repairPending[netId] then
            pcall(function()
                local v = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(v) then
                    Entity(v).state:set(Config.StateBags.vehicleRepairing, false, true)
                end
            end)
            BroadcastMechanicStatus(tonumber(mechanicId), 'idle')
            State.repairPending[netId] = nil
        end
    end)
end)

RegisterNetEvent('rde_mechanic:repairComplete', function(vehicleNetId)
    local src     = source
    local netId   = tonumber(vehicleNetId)
    local pending = State.repairPending[netId]

    pcall(function()
        local veh = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(veh) then
            Entity(veh).state:set(Config.StateBags.vehicleRepairing, false, true)
        end
    end)
    State.repairPending[netId] = nil

    if not pending then return end

    local owner = pending.owner
    if owner and owner ~= src and owner ~= 0 then
        TriggerClientEvent('rde_mechanic:applyRepair', owner, netId)
        Log(('Repair relayed: buyer=%d owner=%d vehicle=%d'):format(src, owner, netId), 'INFO')
    end
end)

-- ──────────────────────────────────────────
-- 📡 REPAIR PHASE SYNC  (NEW)
-- Client broadcasts its current repair phase so all nearby
-- players can animate their local mechanic ped accordingly.
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:repairPhase', function(mechanicId, phase, data)
    local src = source
    if not src or src == 0 then return end

    -- Validate: this src must actually be the one doing a repair
    local isRepairingBuyer = false
    for _, pending in pairs(State.repairPending) do
        if pending.buyer == src then
            isRepairingBuyer = true
            break
        end
    end
    -- Also allow clearing (idle) even if repairPending was already cleaned up
    if not isRepairingBuyer and phase ~= 'idle' then return end

    BroadcastMechanicStatus(tonumber(mechanicId), phase, data)
    Log(('Mechanic #%d phase → %s (by src=%d)'):format(tonumber(mechanicId), phase, src), 'INFO')
end)

-- ──────────────────────────────────────────
-- 🔍 PREVIEW MOD STATEBAG RELAY  (NEW)
-- Client sets a preview mod on the vehicle statebag.
-- All nearby clients receive it and apply the mod locally
-- so passengers and bystanders see the same preview.
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:setPreviewMod', function(vehicleNetId, previewData)
    local src   = source
    local netId = tonumber(vehicleNetId)
    if not src or src == 0 or not netId then return end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(veh) then return end

    if previewData then
        -- Track which vehicle this player is previewing for cleanup
        State.playerPreviews[src] = netId
        Entity(veh).state:set(Config.StateBags.previewMod, previewData, true)
    else
        State.playerPreviews[src] = nil
        Entity(veh).state:set(Config.StateBags.previewMod, false, true)
    end
end)

-- ──────────────────────────────────────────
-- 🎨 MOD PURCHASE
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:purchaseMod', function(netId, modType, modValue, price, wheelType, isToggle, vClass)
    local src = source
    if not src or src == 0 then return end

    if not CheckRate(src) then
        Notify(src, 'warning', L('too_many_requests'), 'alert-triangle')
        return
    end

    local realPrice = ValidatePrice(vClass, modType, price)

    if realPrice > 0 and not HasMoney(src, realPrice) then
        Notify(src, 'error', L('not_enough_money'), 'wallet')
        return
    end
    if realPrice > 0 and not RemoveMoney(src, realPrice) then
        Notify(src, 'error', L('purchase_failed'), 'x-circle')
        return
    end

    -- Clear any preview before applying the real mod
    local veh   = NetworkGetEntityFromNetworkId(tonumber(netId))
    if DoesEntityExist(veh) then
        Entity(veh).state:set(Config.StateBags.previewMod, false, true)
    end

    local owner = DoesEntityExist(veh) and NetworkGetEntityOwner(veh) or src
    TriggerClientEvent('rde_mechanic:applyMod', owner, tonumber(netId), modType, modValue, wheelType, isToggle)

    Log(('Mod: %s | Type=%s Value=%s $%d'):format(GetPlayerName(src), tostring(modType), tostring(modValue), realPrice), 'INFO')

    if Config.NostrLog and Config.NostrLog.logPurchases
        and realPrice >= (Config.NostrLog.expensiveThreshold or 5000) then
        NostrLog(('🎨 Mod by %s | Type=%s | $%d'):format(GetPlayerName(src), tostring(modType), realPrice), {
            {'event', 'mod_purchase'}, {'player', GetPlayerName(src)},
            {'mod_type', tostring(modType)}, {'price', tostring(realPrice)},
        })
    end
end)

-- ──────────────────────────────────────────
-- 🎨 COLOR PURCHASE
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:purchaseColor', function(netId, colorType, colorId, price, vClass)
    local src = source
    if not src or src == 0 then return end

    if not CheckRate(src) then
        Notify(src, 'warning', L('too_many_requests'), 'alert-triangle')
        return
    end

    local realPrice = ValidatePrice(vClass, 'color_' .. tostring(colorType), price)

    if realPrice > 0 and not HasMoney(src, realPrice) then
        Notify(src, 'error', L('not_enough_money'), 'wallet')
        return
    end
    if realPrice > 0 and not RemoveMoney(src, realPrice) then
        Notify(src, 'error', L('purchase_failed'), 'x-circle')
        return
    end

    local veh   = NetworkGetEntityFromNetworkId(tonumber(netId))
    if DoesEntityExist(veh) then
        Entity(veh).state:set(Config.StateBags.previewMod, false, true)
    end

    local owner = DoesEntityExist(veh) and NetworkGetEntityOwner(veh) or src
    TriggerClientEvent('rde_mechanic:applyColor', owner, tonumber(netId), tostring(colorType), tonumber(colorId))

    Log(('Color: %s | Type=%s ID=%d $%d'):format(GetPlayerName(src), tostring(colorType), tonumber(colorId), realPrice), 'INFO')
end)

-- ──────────────────────────────────────────
-- 💡 NEON PURCHASE
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:purchaseNeon', function(netId, r, g, b, price, vClass)
    local src = source
    if not src or src == 0 then return end

    if not CheckRate(src) then
        Notify(src, 'warning', L('too_many_requests'), 'alert-triangle')
        return
    end

    local realPrice = ValidatePrice(vClass, 'neon', price)

    if realPrice > 0 and not HasMoney(src, realPrice) then
        Notify(src, 'error', L('not_enough_money'), 'wallet')
        return
    end
    if realPrice > 0 and not RemoveMoney(src, realPrice) then
        Notify(src, 'error', L('purchase_failed'), 'x-circle')
        return
    end

    local veh   = NetworkGetEntityFromNetworkId(tonumber(netId))
    local owner = DoesEntityExist(veh) and NetworkGetEntityOwner(veh) or src
    TriggerClientEvent('rde_mechanic:applyNeon', owner, tonumber(netId), tonumber(r), tonumber(g), tonumber(b))

    Log(('Neon: %s | RGB(%d,%d,%d) $%d'):format(GetPlayerName(src), tonumber(r), tonumber(g), tonumber(b), realPrice), 'INFO')
end)

-- ──────────────────────────────────────────
-- 🎁 EXTRA TOGGLE
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:purchaseExtra', function(netId, extraId, extraState, price, vClass)
    local src = source
    if not src or src == 0 then return end

    if not CheckRate(src) then
        Notify(src, 'warning', L('too_many_requests'), 'alert-triangle')
        return
    end

    local realPrice = ValidatePrice(vClass, 'extras', price)

    if realPrice > 0 and not HasMoney(src, realPrice) then
        Notify(src, 'error', L('not_enough_money'), 'wallet')
        return
    end
    if realPrice > 0 and not RemoveMoney(src, realPrice) then
        Notify(src, 'error', L('purchase_failed'), 'x-circle')
        return
    end

    local veh   = NetworkGetEntityFromNetworkId(tonumber(netId))
    local owner = DoesEntityExist(veh) and NetworkGetEntityOwner(veh) or src
    TriggerClientEvent('rde_mechanic:applyExtra', owner, tonumber(netId), tonumber(extraId), extraState)

    Log(('Extra: %s | ID=%d State=%s $%d'):format(GetPlayerName(src), tonumber(extraId), tostring(extraState), realPrice), 'INFO')
end)

-- ──────────────────────────────────────────
-- 💾 SAVE VEHICLE PROPERTIES
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:saveVehicleProperties', function(vehicleNetId, properties)
    local src = source
    if not src or src == 0 or not vehicleNetId or not properties then return end
    SaveVehicleToDB(tonumber(vehicleNetId), properties)
end)

-- ──────────────────────────────────────────
-- 🏗️ ADMIN – CREATE MECHANIC
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:createMechanic', function(coords, heading)
    local src = source
    if not src or src == 0 then return end

    if not IsAdmin(src) then
        Notify(src, 'error', L('no_permission'), 'shield-x')
        return
    end
    if not CheckCooldown(src, 'mechanicSpawn') then
        Notify(src, 'warning', L('please_wait'), 'clock')
        return
    end
    if type(coords) ~= 'vector3' or type(heading) ~= 'number' then
        Notify(src, 'error', L('invalid_coords'), 'map-pin-off')
        return
    end

    for _, m in pairs(State.mechanics) do
        if #(coords - m.coords) < (Config.Distances.minMechanicDistance or 25.0) then
            Notify(src, 'error', L('mechanic_too_close'), 'alert-triangle')
            return
        end
    end

    local model = Config.MechanicModels[math.random(#Config.MechanicModels)]
    local id    = SaveMechanic(coords, heading, model)
    if not id then
        Notify(src, 'error', L('database_error'), 'database')
        return
    end

    State.mechanics[id] = { coords = coords, heading = heading, model = model }
    BroadcastMechanics()
    Notify(src, 'success', L('mechanic_created'), 'check-circle')
    Log(('Mechanic #%d created by %s'):format(id, GetPlayerName(src)), 'SUCCESS')

    if Config.NostrLog and Config.NostrLog.logAdminCreate then
        NostrLog(('👑 Mechanic #%d created by %s'):format(id, GetPlayerName(src)), {
            {'event', 'mechanic_created'}, {'admin', GetPlayerName(src)}, {'mechanic_id', tostring(id)},
        })
    end
end)

-- ──────────────────────────────────────────
-- 🗑️ ADMIN – DELETE MECHANIC
-- ──────────────────────────────────────────
RegisterNetEvent('rde_mechanic:deleteMechanic', function(id)
    local src   = source
    local numId = tonumber(id)
    if not src or src == 0 then return end

    if not IsAdmin(src) then
        Notify(src, 'error', L('no_permission'), 'shield-x')
        return
    end
    if not State.mechanics[numId] then
        Notify(src, 'error', L('mechanic_not_found'), 'search-x')
        return
    end
    if not DeleteMechanicDB(numId) then
        Notify(src, 'error', L('database_error'), 'database')
        return
    end

    -- Clear any in-progress status for this mechanic
    BroadcastMechanicStatus(numId, 'idle')

    State.mechanics[numId] = nil
    BroadcastMechanics()
    Notify(src, 'success', L('mechanic_deleted'), 'trash-2')
    Log(('Mechanic #%d deleted by %s'):format(numId, GetPlayerName(src)), 'SUCCESS')

    if Config.NostrLog and Config.NostrLog.logAdminDelete then
        NostrLog(('🗑️ Mechanic #%d deleted by %s'):format(numId, GetPlayerName(src)), {
            {'event', 'mechanic_deleted'}, {'admin', GetPlayerName(src)}, {'mechanic_id', tostring(numId)},
        })
    end
end)

-- ============================================
-- 🚀 INIT
-- ============================================
CreateThread(function()
    Wait(500)
    local ok = InitDB()
    if not ok then
        print('[^1RDE^7] Database initialization failed!')
        return
    end
    LoadMechanics()
    State.ready = true

    -- Initialize mechanic status GlobalState as empty
    GlobalState:set(Config.StateBags.mechanicStatus, {}, true)
    BroadcastMechanics()

    local count = 0
    for _ in pairs(State.mechanics) do count = count + 1 end
    Log(('Server ready | %d mechanics in GlobalState'):format(count), 'SUCCESS')

    if Config.NostrLog and Config.NostrLog.enabled then
        NostrLog('🚀 rde_mechanic server started', {
            {'event', 'server_start'}, {'resource', RESOURCE_NAME},
        })
    end
end)

-- ============================================
-- 🧹 CLEANUP
-- ============================================
AddEventHandler('playerDropped', function()
    local src = source

    -- Clear any preview statebag this player had active
    local previewVehicleNetId = State.playerPreviews[src]
    if previewVehicleNetId then
        local veh = NetworkGetEntityFromNetworkId(previewVehicleNetId)
        if DoesEntityExist(veh) then
            pcall(function()
                Entity(veh).state:set(Config.StateBags.previewMod, false, true)
            end)
        end
        State.playerPreviews[src] = nil
    end

    -- Clear any stuck repair phase this player was responsible for
    for netId, pending in pairs(State.repairPending) do
        if pending.buyer == src then
            pcall(function()
                local veh = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(veh) then
                    Entity(veh).state:set(Config.StateBags.vehicleRepairing, false, true)
                end
            end)
            State.repairPending[netId] = nil
        end
    end

    State.purchaseTimestamps[src] = nil
    State.cooldowns[src]          = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE_NAME then return end
    GlobalState:set(Config.StateBags.mechanicStatus, {}, true)
    Log('Resource stopping – cleanup done', 'INFO')
end)
