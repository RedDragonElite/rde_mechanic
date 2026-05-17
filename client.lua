-- ╔════════════════════════════════════════════════════════════╗
-- ║  RDE | Core | 🔺 NEXT-GEN MECHANIC & TUNER                 ║
-- ║  CLIENT v2.4 – Camera · Preview · Multiplayer StateBag     ║
-- ║  by ᛋᛅᚱᛒᛅᚾᛁᛋ ᛒᛁᛞᛅ (SerpentsByte)                              ║
-- ╚════════════════════════════════════════════════════════════╝

local RESOURCE_NAME = GetCurrentResourceName()

-- ============================================
-- 🎯 STATE
-- ============================================
local State = {
    mechanics        = {},    -- [id] = { ped, blip, coords, heading }
    knownIds         = {},
    currentVehicle   = nil,
    isRepairing      = false,
    menuOpen         = false,
    tuningActive     = false,
    lastMenuCall     = nil,
    particleEffects  = {},
    soundIds         = {},
    ready            = false,
    -- Camera
    tuningCam        = nil,
    -- Preview
    previewOriginals = {},    -- [vehicleNetId] = snap table (for statebag-received previews)
    -- Wheel tracking
    originalWheelType  = nil,
    wheelTypePurchased = false,
}

local WHEEL_EMOJI = {
    [0]='🏎️',[1]='💪',[2]='⬇️',[3]='🚙',[4]='🌲',
    [5]='⚡',[6]='🏍️',[7]='👑',[8]='🌟',[9]='💎',
    [10]='🏁',[11]='🚗',[12]='🏆',[13]='💨',[14]='🌿',
}

-- ============================================
-- 🛠️ UTILITIES
-- ============================================
local function Log(msg, level)
    if not Config or not Config.Debug or not Config.Debug.enabled then return end
    print(('[^3RDE^7][%s] %s'):format(level or 'INFO', tostring(msg)))
end

local function L(key, ...)
    local lang = (Config and Config.DefaultLanguage) or 'en'
    local t    = Config and Config.Languages and Config.Languages[lang]
    local str  = (t and t[key]) or key
    if select('#', ...) > 0 then return string.format(str, ...) end
    return str
end

local function Notify(ntype, msg, icon)
    lib.notify({
        title       = L(ntype),
        description = msg,
        type        = ntype,
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
-- 🔄 TUNING SESSION
-- ============================================
local function TrackMenu(fn, ...)
    local args = {...}
    State.lastMenuCall = function()
        if State.currentVehicle and DoesEntityExist(State.currentVehicle) then
            fn(table.unpack(args))
        end
    end
end

local function ReopenTuningMenu()
    if not State.tuningActive or not State.lastMenuCall then return end
    if not State.currentVehicle or not DoesEntityExist(State.currentVehicle) then return end
    CreateThread(function()
        Wait(150)
        if State.tuningActive and State.lastMenuCall then
            State.lastMenuCall()
        end
    end)
end

-- ============================================
-- 📸 KAMERA SYSTEM – Orbit während Tuning-Menü
-- ============================================

-- Kein Preset-Wahnsinn mehr. Die Kamera kreist einfach ums Auto.
-- Alle Werte kommen aus Config.TuningCamera (config.lua).

local function StartOrbitCamera(vehicle)
    local cfg = Config.TuningCamera
    if not cfg or not cfg.enabled then return end
    if not DoesEntityExist(vehicle) then return end
    if State.tuningCam then return end  -- läuft bereits

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
    SetCamFov(cam, cfg.fov)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, cfg.fadeInMs, true, true)
    State.tuningCam = cam

    -- Startwinkel
    local angle = cfg.startAngle or 160.0

    CreateThread(function()
        while State.tuningCam and DoesCamExist(State.tuningCam) do
            if not DoesEntityExist(vehicle) then break end

            -- Fahrzeugmittelpunkt leicht erhöht als Orbit-Zentrum
            local center = GetEntityCoords(vehicle)
            center = vector3(center.x, center.y, center.z + (cfg.height * 0.4))

            -- Kamera-Position im Kreis um das Auto
            local rad    = math.rad(angle)
            local cx     = center.x + cfg.radius * math.sin(rad)
            local cy     = center.y + cfg.radius * math.cos(rad)
            local cz     = center.z + cfg.height

            SetCamCoord(State.tuningCam, cx, cy, cz)
            PointCamAtCoord(State.tuningCam, center.x, center.y, center.z)

            -- Winkel weiterschieben
            angle = (angle + cfg.degreesPerSec / 60.0) % 360.0  -- 60 fps

            Wait(0)
        end
    end)
end

local function StopOrbitCamera()
    if not State.tuningCam then return end
    local cfg = Config.TuningCamera
    local fadeMs = (cfg and cfg.fadeOutMs) or 600
    RenderScriptCams(false, true, fadeMs, true, true)
    local cam = State.tuningCam
    State.tuningCam = nil
    SetTimeout(fadeMs + 100, function()
        pcall(function() DestroyCam(cam, false) end)
    end)
end

-- Kompat-Wrapper damit alter Code der SetupTuningCamera/RestoreGameplayCamera
-- aufruft nicht bricht. Die presetName-Parameter werden einfach ignoriert.
local function SetupTuningCamera(vehicle, _presetName)
    StartOrbitCamera(vehicle)
end

local function RestoreGameplayCamera()
    StopOrbitCamera()
end


-- ============================================
-- 🌍 GROUND DETECTION
-- ============================================
local function GetGroundZ(x, y, z)
    local found, gz = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    if found and math.abs(gz - z) < 10.0 then return gz end
    return z - 0.05
end

local function GetSafeCoords(coords, heading)
    return vector3(coords.x, coords.y, GetGroundZ(coords.x, coords.y, coords.z)), heading
end

-- ============================================
-- 🏷️ NATIVE MOD NAMES
-- ============================================
local function GetNativeModName(vehicle, modType, modIndex)
    if DoesEntityExist(vehicle) then
        local label = GetModTextLabel(vehicle, modType, modIndex)
        if label and label ~= '' then
            local name = GetLabelText(label)
            if name and name ~= '' and name ~= 'NULL' then return name end
        end
    end
    if Config.InteriorModNames
        and Config.InteriorModNames[modType]
        and Config.InteriorModNames[modType][modIndex] then
        return Config.InteriorModNames[modType][modIndex]
    end
    return L('level', modIndex + 1)
end

local function GetNativeWheelName(vehicle, wheelType, modIndex)
    if DoesEntityExist(vehicle) then
        local label = GetModTextLabel(vehicle, 23, modIndex)
        if label and label ~= '' then
            local name = GetLabelText(label)
            if name and name ~= '' and name ~= 'NULL' then return name end
        end
    end
    if Config.WheelNames and Config.WheelNames[wheelType] and Config.WheelNames[wheelType][modIndex] then
        return Config.WheelNames[wheelType][modIndex]
    end
    return ('Wheel %d'):format(modIndex + 1)
end

local function GetColorName(id)
    if Config.ColorNames and Config.ColorNames[id] then return Config.ColorNames[id] end
    return ('Color %d'):format(id)
end

local function GetWheelTypeLabel(wtype)
    for _, wt in ipairs(Config.WheelTypes) do
        if wt.id == wtype then return L(wt.label) end
    end
    return ('Type %d'):format(wtype)
end

-- ============================================
-- 🚗 VEHICLE PROPERTIES SAVE
-- ============================================
local function SaveVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then return false end
    local props = lib.getVehicleProperties(vehicle)
    if not props then return false end
    TriggerServerEvent('rde_mechanic:saveVehicleProperties', netId, props)
    return true
end

-- ============================================
-- 💰 PRICE HELPER
-- ============================================
local function GetMultiplier(vehicle)
    if not DoesEntityExist(vehicle) then return 1.0 end
    return Config.VehicleClassMultipliers[GetVehicleClass(vehicle)] or 1.0
end

-- ============================================
-- 🎨 PARTICLES & SOUNDS
-- ============================================
local function PlayParticle(vehicle, duration)
    if not Config.Particles.enabled then return end
    local cfg = Config.Particles.sparks
    CreateThread(function()
        RequestNamedPtfxAsset(cfg.dict)
        while not HasNamedPtfxAssetLoaded(cfg.dict) do Wait(10) end
        UseParticleFxAssetNextCall(cfg.dict)
        local c   = GetEntityCoords(vehicle)
        local off = cfg.offset
        local fx  = StartParticleFxLoopedAtCoord(
            cfg.name,
            c.x + off.x, c.y + off.y, c.z + off.z,
            0.0, 0.0, 0.0, cfg.scale,
            false, false, false, false
        )
        table.insert(State.particleEffects, fx)
        if duration then
            SetTimeout(duration, function()
                if DoesParticleFxLoopedExist(fx) then StopParticleFxLooped(fx, false) end
            end)
        end
    end)
end

local function StopAllParticles()
    for _, fx in ipairs(State.particleEffects) do
        if DoesParticleFxLoopedExist(fx) then StopParticleFxLooped(fx, false) end
    end
    State.particleEffects = {}
end

local function PlaySnd(cfg)
    if not Config.Sounds.enabled or not cfg then return end
    local id = GetSoundId()
    PlaySoundFrontend(id, cfg.name, cfg.dict, true)
    table.insert(State.soundIds, id)
end

local function StopAllSounds()
    for _, id in ipairs(State.soundIds) do StopSound(id) ReleaseSoundId(id) end
    State.soundIds = {}
end

-- ============================================
-- 🔍 PREVIEW SYSTEM
-- Capture current mod/color state, apply locally as preview,
-- sync via vehicle statebag so passengers and bystanders see it.
-- Confirm dialog → buy or revert.
-- ============================================

-- Snapshot the current mod/color state for later restoration
local function CaptureVehicleModState(vehicle, modType, isToggle, wheelType, colorType)
    if not DoesEntityExist(vehicle) then return nil end
    if colorType then
        local p, s         = GetVehicleColours(vehicle)
        local pearl, wheel = GetVehicleExtraColours(vehicle)  -- (pearlescentColor, wheelColor)
        local intColor     = GetVehicleInteriorColour(vehicle)
        local dashColor    = GetVehicleDashboardColour(vehicle)
        return {
            isColor = true, colorType = colorType,
            p = p, s = s, pearl = pearl, wheel = wheel,
            intColor = intColor, dashColor = dashColor,
        }
    elseif isToggle then
        return { modType = modType, isToggle = true, origValue = IsToggleModOn(vehicle, modType) }
    elseif wheelType ~= nil then
        return {
            modType = modType, isToggle = false, hasWheel = true,
            origWheelType = GetVehicleWheelType(vehicle),
            origValue     = GetVehicleMod(vehicle, modType),
        }
    else
        return { modType = modType, isToggle = false, origValue = GetVehicleMod(vehicle, modType) }
    end
end

-- Apply a preview mod locally (no server event, no payment)
local function ApplyPreviewMod(vehicle, modType, modValue, wheelType, isToggle)
    if not DoesEntityExist(vehicle) then return end
    SetVehicleModKit(vehicle, 0)
    if wheelType then
        SetVehicleWheelType(vehicle, tonumber(wheelType))
        Wait(50)
    end
    if isToggle then
        ToggleVehicleMod(vehicle, modType, modValue)
    else
        SetVehicleMod(vehicle, modType, tonumber(modValue), false)
    end
end

-- Apply a preview color locally
local function ApplyPreviewColor(vehicle, colorType, colorId)
    if not DoesEntityExist(vehicle) then return end
    local p, s         = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)  -- (pearlescentColor, wheelColor)
    if     colorType == 'primary'     then SetVehicleColours(vehicle, colorId, s)
    elseif colorType == 'secondary'   then SetVehicleColours(vehicle, p, colorId)
    elseif colorType == 'pearlescent' then SetVehicleExtraColours(vehicle, colorId, wheel)
    elseif colorType == 'wheel'       then SetVehicleExtraColours(vehicle, pearl, colorId)
    elseif colorType == 'interior'    then SetVehicleInteriorColour(vehicle, colorId)
    elseif colorType == 'dashboard'   then SetVehicleDashboardColour(vehicle, colorId)
    end
end

-- Restore from a captured snapshot
local function RestoreFromCapture(vehicle, snap)
    if not DoesEntityExist(vehicle) or not snap then return end
    if snap.isColor then
        SetVehicleColours(vehicle, snap.p, snap.s)
        SetVehicleExtraColours(vehicle, snap.pearl, snap.wheel)
        SetVehicleInteriorColour(vehicle, snap.intColor)
        SetVehicleDashboardColour(vehicle, snap.dashColor)
    elseif snap.isToggle then
        ToggleVehicleMod(vehicle, snap.modType, snap.origValue)
    else
        if snap.hasWheel then
            SetVehicleWheelType(vehicle, snap.origWheelType)
            Wait(50)
        end
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, snap.modType, snap.origValue, false)
    end
end

-- Tell server to set preview statebag on vehicle (all nearby clients will apply)
local function SyncPreviewStateBag(vehicleNetId, previewData)
    TriggerServerEvent('rde_mechanic:setPreviewMod', vehicleNetId, previewData)
end

local function ClearPreviewStateBag(vehicleNetId)
    TriggerServerEvent('rde_mechanic:setPreviewMod', vehicleNetId, false)
end

-- ============================================
-- 📡 STATEBAG HANDLERS
-- ============================================

-- Watch preview statebag on ALL vehicles
-- When another client sets a preview on a vehicle, we see and apply it locally
AddStateBagChangeHandler(Config.StateBags.previewMod, nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if not entity or not DoesEntityExist(entity) then return end
    if not IsEntityAVehicle(entity) then return end

    local netId    = NetworkGetNetworkIdFromEntity(entity)
    local myServId = GetPlayerServerId(PlayerId())

    if value and value ~= false then
        -- Store original for this vehicle (used if we need to restore on clear)
        State.previewOriginals[netId] = value.snap

        -- Don't re-apply locally if WE are the one previewing (we already applied it)
        if value.previewBy == myServId then return end

        SetVehicleModKit(entity, 0)
        if value.isColor then
            ApplyPreviewColor(entity, value.colorType, value.colorValue)
        elseif value.isToggle then
            ToggleVehicleMod(entity, value.modType, value.modValue)
        else
            if value.wheelType then
                SetVehicleWheelType(entity, value.wheelType)
            end
            SetVehicleMod(entity, value.modType, value.modValue, false)
        end
    else
        -- Restore from stored snapshot
        local snap = State.previewOriginals[netId]
        if snap and DoesEntityExist(entity) then
            RestoreFromCapture(entity, snap)
        end
        State.previewOriginals[netId] = nil
    end
end)

-- Watch GlobalState mechanic repair phase
-- GlobalState bags have bagName == 'global' in FiveM
-- Second param must be nil (no entity filter) — not the string 'global'
AddStateBagChangeHandler(Config.StateBags.mechanicStatus, nil, function(bagName, key, value)
    if bagName ~= 'global' then return end  -- nur GlobalState-Bag interessiert uns
    if not value then return end

    for idStr, status in pairs(value) do
        local id = tonumber(idStr)
        local m  = State.mechanics[id]
        if not m or not DoesEntityExist(m.ped) then goto nextMech end

        local phase = status.phase
        local data  = status.data or {}

        if phase == 'walking' then
            FreezeEntityPosition(m.ped, false)
            SetPedCanRagdoll(m.ped, false)
            SetPedFleeAttributes(m.ped, 0, true)
            SetPedCombatAttributes(m.ped, 17, true)
            if data.tx and data.ty and data.tz then
                TaskFollowNavMeshToCoord(m.ped, data.tx, data.ty, data.tz, 1.2, -1, 1.4, false, 0)
            end

        elseif phase == 'repairing' then
            local animCfg = Config.MechanicBehavior.animations[1]
            CreateThread(function()
                if not lib.requestAnimDict(animCfg.dict, 5000) then return end
                if DoesEntityExist(m.ped) then
                    TaskPlayAnim(m.ped, animCfg.dict, animCfg.name,
                        8.0, -8.0, -1, 1, 0, false, false, false)
                end
            end)

        elseif phase == 'returning' then
            ClearPedTasks(m.ped)
            FreezeEntityPosition(m.ped, false)
            TaskFollowNavMeshToCoord(m.ped, m.coords.x, m.coords.y, m.coords.z, 1.0, -1, 1.0, false, 0)

        elseif phase == 'idle' then
            ClearPedTasks(m.ped)
            FreezeEntityPosition(m.ped, Config.MechanicBehavior.freezePosition)
            if DoesEntityExist(m.ped) then SetEntityHeading(m.ped, m.heading) end
        end

        ::nextMech::
    end
end)

-- ============================================
-- 🎭 NPC MANAGEMENT
-- ============================================
local function SpawnMechanic(id, data)
    if State.mechanics[id] then return end
    if not data then return end

    local coords  = vector3(data.x, data.y, data.z)
    local safeCoords, safeHeading = GetSafeCoords(coords, data.heading or 0.0)

    local blip = AddBlipForCoord(safeCoords.x, safeCoords.y, safeCoords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, Config.Blip.shortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.name)
    EndTextCommandSetBlipName(blip)

    local modelHash = joaat(data.model or Config.MechanicModels[1])
    lib.requestModel(modelHash, 10000)

    local ped = CreatePed(4, modelHash, safeCoords.x, safeCoords.y, safeCoords.z, safeHeading, false, true)
    if not DoesEntityExist(ped) then
        Log('Failed to create ped for mechanic #' .. tostring(id), 'ERROR')
        RemoveBlip(blip)
        SetModelAsNoLongerNeeded(modelHash)
        return
    end

    SetEntityInvincible(ped, Config.MechanicBehavior.invincible)
    FreezeEntityPosition(ped, Config.MechanicBehavior.freezePosition)
    SetBlockingOfNonTemporaryEvents(ped, Config.MechanicBehavior.blockEvents)
    SetPedCanRagdoll(ped, Config.MechanicBehavior.canRagdoll)
    SetEntityAsMissionEntity(ped, true, true)
    PlaceObjectOnGroundProperly(ped)
    SetModelAsNoLongerNeeded(modelHash)

    State.mechanics[id] = {
        ped     = ped,
        blip    = blip,
        coords  = safeCoords,
        heading = safeHeading,
    }

    exports.ox_target:addLocalEntity(ped, {
        {
            name      = 'mechanic_repair_' .. id,
            label     = L('target_repair'),
            icon      = 'wrench',
            iconColor = '#10b981',
            distance  = Config.Distances.interactionRange,
            canInteract = function()
                local veh  = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.Distances.vehicleDetectionRange, true)
                if not veh or veh == 0 then return false end
                local busy = Entity(veh).state[Config.StateBags.vehicleRepairing]
                return not State.isRepairing and not busy
            end,
            onSelect = function()
                local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.Distances.vehicleDetectionRange, true)
                if not veh or veh == 0 then
                    Notify('error', L('no_vehicle'), 'car-off'); return
                end
                local busy = Entity(veh).state[Config.StateBags.vehicleRepairing]
                if busy then Notify('warning', L('vehicle_busy'), 'alert-triangle'); return end
                local eng  = GetVehicleEngineHealth(veh)
                local body = GetVehicleBodyHealth(veh)
                if eng >= Config.Repair.engineHealthThreshold and body >= Config.Repair.bodyHealthThreshold then
                    Notify('info', L('vehicle_not_damaged'), 'car'); return
                end
                local vClass = GetVehicleClass(veh)
                local mult   = Config.VehicleClassMultipliers[vClass] or 1.0
                local damage = (2000 - eng - body) / 2
                local price  = math.floor(
                    math.min(Config.Repair.basePrice + damage * Config.Repair.pricePerDamage, Config.Repair.maxPrice)
                    * mult
                )
                TriggerServerEvent('rde_mechanic:requestRepair',
                    NetworkGetNetworkIdFromEntity(veh), id, price, vClass)
            end
        },
        {
            name      = 'mechanic_modify_' .. id,
            label     = L('target_modify'),
            icon      = 'palette',
            iconColor = '#3b82f6',
            distance  = Config.Distances.interactionRange,
            canInteract = function()
                local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.Distances.vehicleDetectionRange, true)
                return veh ~= 0 and not State.isRepairing
            end,
            onSelect = function()
                local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.Distances.vehicleDetectionRange, true)
                if not veh or veh == 0 then
                    Notify('error', L('no_vehicle'), 'car-off'); return
                end
                State.currentVehicle = veh
                OpenMainMenu(veh)
            end
        },
        {
            name      = 'mechanic_admin_' .. id,
            label     = L('target_admin'),
            icon      = 'shield',
            iconColor = '#8b5cf6',
            distance  = Config.Distances.interactionRange,
            canInteract = function()
                return lib.callback.await('rde_mechanic:isAdmin', false)
            end,
            onSelect = function() OpenAdminMenu(id) end
        },
    })

    Log(('Mechanic #%d spawned at %.1f %.1f %.1f'):format(id, safeCoords.x, safeCoords.y, safeCoords.z), 'SUCCESS')
end

local function DespawnMechanic(id)
    local m = State.mechanics[id]
    if not m then return end
    if DoesEntityExist(m.ped) then
        exports.ox_target:removeLocalEntity(m.ped)
        DeleteEntity(m.ped)
    end
    if DoesBlipExist(m.blip) then RemoveBlip(m.blip) end
    State.mechanics[id] = nil
    Log('Mechanic #' .. tostring(id) .. ' despawned', 'INFO')
end

-- ============================================
-- 📡 PROXIMITY LOOP
-- ============================================
CreateThread(function()
    local cfg = Config.Performance
    while not State.ready do Wait(100) end
    Log('Proximity loop started', 'SUCCESS')

    while true do
        Wait(cfg.proximityTick)

        local playerCoords = GetEntityCoords(cache.ped)
        local gs           = GlobalState.rde_mechanics

        local gsIds = {}
        if gs then
            for idStr, _ in pairs(gs) do gsIds[tonumber(idStr)] = true end
        end

        for id, _ in pairs(State.mechanics) do
            if not gsIds[id] then DespawnMechanic(id) end
        end

        State.knownIds = gsIds
        if not gs then goto continue end

        local spawned = 0
        for idStr, data in pairs(gs) do
            local id   = tonumber(idStr)
            local mPos = vector3(data.x, data.y, data.z)
            local dist = #(playerCoords - mPos)

            if State.mechanics[id] then
                if dist > cfg.despawnDistance then DespawnMechanic(id) end
            else
                if dist <= cfg.renderDistance and spawned < cfg.maxVisibleMechanics then
                    SpawnMechanic(id, data)
                    spawned = spawned + 1
                end
            end
        end

        ::continue::
    end
end)

-- ============================================
-- 🔧 REPAIR SEQUENCE
-- Phase transitions are broadcast to GlobalState so all nearby
-- clients can animate their local mechanic ped.
-- ============================================
local function ExecuteRepair(mechanicId, vehicleNetId, price)

    local vehicle, vAttempts = 0, 0
    repeat
        vehicle   = NetworkGetEntityFromNetworkId(vehicleNetId)
        vAttempts = vAttempts + 1
        if not DoesEntityExist(vehicle) then Wait(200) end
    until DoesEntityExist(vehicle) or vAttempts >= 20

    if not DoesEntityExist(vehicle) then
        Notify('error', 'Vehicle not found', 'car-off')
        TriggerServerEvent('rde_mechanic:repairComplete', vehicleNetId)
        return
    end

    local mech, mAttempts = nil, 0
    repeat
        mech      = State.mechanics[mechanicId]
        mAttempts = mAttempts + 1
        if not mech or not DoesEntityExist(mech.ped) then Wait(200) end
    until (mech and DoesEntityExist(mech.ped)) or mAttempts >= 15

    if not mech or not DoesEntityExist(mech.ped) then mech = nil end

    State.isRepairing    = true
    State.currentVehicle = vehicle

    local ped         = mech and mech.ped
    local homeCoords  = mech and vector3(mech.coords.x, mech.coords.y, mech.coords.z)
    local homeHeading = mech and mech.heading or 0.0

    local function WalkPedTo(p, x, y, z, spd, stopDist, timeout_ms)
        if not DoesEntityExist(p) then return end
        TaskFollowNavMeshToCoord(p, x, y, z, spd, -1, stopDist, false, 0)
        local t = GetGameTimer() + (timeout_ms or 30000)
        while GetGameTimer() < t do
            if not DoesEntityExist(p) then break end
            if #(GetEntityCoords(p) - vector3(x, y, z)) < (stopDist + 0.3) then break end
            if GetScriptTaskStatus(p, 0x7D8F4411) == 7 then break end
            Wait(100)
        end
        if DoesEntityExist(p) then ClearPedTasks(p) end
        Wait(80)
    end

    CreateThread(function()

        -- PHASE 1: Walk to vehicle hood (linke Seite der Motorhaube, Fahrerseite)
        if ped and DoesEntityExist(ped) then
            FreezeEntityPosition(ped, false)
            SetPedCanRagdoll(ped, false)
            SetPedFleeAttributes(ped, 0, true)
            SetPedCombatAttributes(ped, 17, true)

            local vehCoords = GetEntityCoords(vehicle)
            local vehFwd    = GetEntityForwardVector(vehicle)
            -- Ziel: ca. 1.5m seitlich links neben der Motorhaube (Fahrerseite)
            local rightX = vehFwd.y   -- lokale +X Achse (nach rechts) = (fwd.y, -fwd.x)
            local rightY = -vehFwd.x
            -- Fahrerseite = -right → also minus rechts-Vektor
            local tx = vehCoords.x + vehFwd.x * 1.8 - rightX * 1.2
            local ty = vehCoords.y + vehFwd.y * 1.8 - rightY * 1.2
            local tz = GetGroundZ(tx, ty, vehCoords.z)

            -- Broadcast: walking
            TriggerServerEvent('rde_mechanic:repairPhase', mechanicId, 'walking', { tx=tx, ty=ty, tz=tz })
            Notify('info', L('mechanic_walking'), 'user-round')
            WalkPedTo(ped, tx, ty, tz, 1.2, 1.2, 28000)
        end

        -- PHASE 2: Mechanic dreht sich zur Motorhaube, dann Haube öffnen
        if ped and DoesEntityExist(ped) then
            local vehCoords = GetEntityCoords(vehicle)
            local vehFwd    = GetEntityForwardVector(vehicle)
            -- Look-At = Punkt direkt an der Motorhaube (vorne-mitte des Fahrzeugs)
            local hoodLookX = vehCoords.x + vehFwd.x * 2.2
            local hoodLookY = vehCoords.y + vehFwd.y * 2.2
            -- Drehen und warten bis Animation fertig
            TaskTurnPedToFaceCoord(ped, hoodLookX, hoodLookY, vehCoords.z, 1000)
            Wait(1000)
            FreezeEntityPosition(ped, true)
        end

        if DoesEntityExist(vehicle) then
            SetVehicleDoorOpen(vehicle, 4, false, false)
            PlaySnd(Config.Sounds.hood_open)
            Notify('info', L('hood_opened'), 'door-open')
        end
        -- Kurze Pause damit Haube aufgeht bevor Animation startet
        Wait(1200)

        -- PHASE 3: Repair animation + progressive health restore
        local startEng  = DoesEntityExist(vehicle) and GetVehicleEngineHealth(vehicle) or 0.0
        local startBody = DoesEntityExist(vehicle) and GetVehicleBodyHealth(vehicle) or 0.0
        local damage    = math.max(0.0, (2000.0 - startEng - startBody) / 2.0)
        local duration  = math.max(
            Config.Repair.minRepairTime,
            math.min(
                Config.Repair.minRepairTime + damage * Config.Repair.damageTimeMultiplier,
                Config.Repair.maxRepairTime
            )
        )

        local animCfg = Config.MechanicBehavior.animations[1]
        local tool    = nil

        if ped and DoesEntityExist(ped) then
            -- Broadcast: repairing
            TriggerServerEvent('rde_mechanic:repairPhase', mechanicId, 'repairing', {})

            lib.requestAnimDict(animCfg.dict, 5000)

            local toolHash = joaat(animCfg.tool)
            lib.requestModel(toolHash, 5000)
            tool = CreateObject(toolHash, 0, 0, 0, true, true, false)
            AttachEntityToEntity(
                tool, ped, GetPedBoneIndex(ped, animCfg.bone),
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                true, true, false, true, 1, true
            )

            local loops   = animCfg.loops or 3
            local loopDur = math.max(1000, math.floor(duration / loops))
            CreateThread(function()
                for i = 1, loops do
                    if not DoesEntityExist(ped) then break end
                    TaskPlayAnim(ped, animCfg.dict, animCfg.name,
                        8.0, -8.0, loopDur, 1, 0, false, false, false)
                    Wait(loopDur)
                end
                if DoesEntityExist(ped) then ClearPedTasks(ped) end
            end)
        end

        if DoesEntityExist(vehicle) then PlayParticle(vehicle, duration) end

        local steps    = 10
        local stepDur  = math.max(100, math.floor(duration / steps))
        local engStep  = (1000.0 - startEng)  / steps
        local bodyStep = (1000.0 - startBody) / steps
        CreateThread(function()
            for i = 1, steps do
                if not DoesEntityExist(vehicle) then break end
                SetVehicleEngineHealth(vehicle, math.min(startEng  + engStep  * i, 1000.0))
                SetVehicleBodyHealth(vehicle,   math.min(startBody + bodyStep * i, 1000.0))
                if i % 3 == 0 then SetVehicleDeformationFixed(vehicle) end
                Wait(stepDur)
            end
        end)

        lib.progressBar({
            duration     = duration,
            label        = '🔧 ' .. L('repair_in_progress', 0),
            useWhileDead = false,
            canCancel    = false,
            disable      = { move = true, car = true, combat = true },
        })

        -- PHASE 4: Finalize repair
        StopAllParticles()
        if tool and DoesEntityExist(tool) then DeleteObject(tool) end
        if ped  and DoesEntityExist(ped)  then ClearPedTasks(ped)  end
        Wait(400)

        if DoesEntityExist(vehicle) then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleEngineHealth(vehicle,     1000.0)
            SetVehicleBodyHealth(vehicle,       1000.0)
            SetVehiclePetrolTankHealth(vehicle, 1000.0)
            SetVehicleDirtLevel(vehicle,        0.0)
            for i = 0, 3 do SetVehicleDoorShut(vehicle, i, false) end
            for i = 5, 7 do SetVehicleDoorShut(vehicle, i, false) end
        end

        TriggerServerEvent('rde_mechanic:repairComplete', vehicleNetId)

        -- PHASE 5: Mechanic tritt einen Schritt zurück (weg vom Motorraum), dann Haube zu
        if ped and DoesEntityExist(ped) then
            FreezeEntityPosition(ped, false)
            -- Broadcast: returning (Phase für andere Clients)
            TriggerServerEvent('rde_mechanic:repairPhase', mechanicId, 'returning', {})

            -- Einen Schritt weg vom Fahrzeug (in Richtung woher er kam)
            local vehCoords = GetEntityCoords(vehicle)
            local pedCoords = GetEntityCoords(ped)
            -- Richtung weg vom Fahrzeug = ped → fahrzeugmitte invertiert
            local awayX = pedCoords.x - vehCoords.x
            local awayY = pedCoords.y - vehCoords.y
            local awayLen = math.sqrt(awayX*awayX + awayY*awayY)
            if awayLen > 0.01 then
                awayX = awayX / awayLen
                awayY = awayY / awayLen
            end
            local stepX = pedCoords.x + awayX * 1.0
            local stepY = pedCoords.y + awayY * 1.0
            local stepZ = GetGroundZ(stepX, stepY, pedCoords.z)
            WalkPedTo(ped, stepX, stepY, stepZ, 0.8, 0.4, 3000)
            FreezeEntityPosition(ped, true)
        end

        -- Haube schließen NACHDEM Mechanic zurückgetreten ist
        Wait(300)
        if DoesEntityExist(vehicle) then
            SetVehicleDoorShut(vehicle, 4, false)
            PlaySnd(Config.Sounds.hood_close)
            Notify('info', L('hood_closed'), 'door-closed')
        end

        Wait(1200)
        if DoesEntityExist(vehicle) then SaveVehicleProperties(vehicle) end
        Notify('success', L('repair_completed'), 'check-circle')

        -- PHASE 6: Walk back to spawn post (unfreeze, navigate, refreeze + heading)
        if ped and DoesEntityExist(ped) and homeCoords then
            FreezeEntityPosition(ped, false)
            Notify('info', L('mechanic_returning'), 'arrow-left')
            WalkPedTo(ped, homeCoords.x, homeCoords.y, homeCoords.z, 1.0, 0.8, 35000)

            if DoesEntityExist(ped) then
                -- Ped dreht sich in seine ursprüngliche Spawn-Richtung
                TaskTurnPedToFaceCoord(
                    ped,
                    homeCoords.x + math.sin(math.rad(homeHeading)),
                    homeCoords.y + math.cos(math.rad(homeHeading)),
                    homeCoords.z, 800
                )
                Wait(800)
                SetEntityHeading(ped, homeHeading)
                FreezeEntityPosition(ped, Config.MechanicBehavior.freezePosition)
            end
        end

        -- Broadcast: idle
        TriggerServerEvent('rde_mechanic:repairPhase', mechanicId, 'idle', {})

        State.isRepairing    = false
        State.currentVehicle = nil
        Log('Repair complete netId=' .. tostring(vehicleNetId), 'SUCCESS')
    end)
end

-- ============================================
-- 📡 REPAIR EVENTS
-- ============================================
RegisterNetEvent('rde_mechanic:startRepair', function(mechanicId, vehicleNetId, price)
    ExecuteRepair(tonumber(mechanicId), tonumber(vehicleNetId), tonumber(price))
end)

RegisterNetEvent('rde_mechanic:applyRepair', function(vehicleNetId)
    local veh = NetworkGetEntityFromNetworkId(tonumber(vehicleNetId))
    if not DoesEntityExist(veh) then return end
    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    SetVehiclePetrolTankHealth(veh, 1000.0)
    SetVehicleDirtLevel(veh, 0.0)
    for i = 0, 5 do SetVehicleDoorShut(veh, i, false) end
    SaveVehicleProperties(veh)
    Log('applyRepair received as vehicle owner', 'SUCCESS')
end)

-- ============================================
-- 🎨 MOD / COLOR / NEON / EXTRA APPLY EVENTS
-- ============================================
RegisterNetEvent('rde_mechanic:applyMod', function(netId, modType, modValue, wheelType, isToggle)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId))
    if not DoesEntityExist(veh) then return end

    SetVehicleModKit(veh, 0)
    if wheelType then
        SetVehicleWheelType(veh, tonumber(wheelType))
        Wait(50)
    end
    if isToggle then
        ToggleVehicleMod(veh, tonumber(modType), modValue)
    else
        SetVehicleMod(veh, tonumber(modType), tonumber(modValue), false)
    end

    SaveVehicleProperties(veh)
    PlaySnd(Config.Sounds.purchase)
    PlayParticle(veh, 1200)
    Notify('success', L('purchase_success'), 'check-circle')
    ReopenTuningMenu()
end)

-- FIX: pearlescent and wheel colors were swapped.
-- GetVehicleExtraColours returns (pearlescentColor, wheelColor).
-- SetVehicleExtraColours(veh, pearlescentColor, wheelColor).
RegisterNetEvent('rde_mechanic:applyColor', function(netId, colorType, colorId)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId))
    if not DoesEntityExist(veh) then return end

    local p, s         = GetVehicleColours(veh)
    local pearl, wheel = GetVehicleExtraColours(veh)  -- (pearlescentColor, wheelColor)
    local intColor     = GetVehicleInteriorColour(veh)
    local dashColor    = GetVehicleDashboardColour(veh)

    if     colorType == 'primary'     then SetVehicleColours(veh, tonumber(colorId), s)
    elseif colorType == 'secondary'   then SetVehicleColours(veh, p, tonumber(colorId))
    elseif colorType == 'pearlescent' then SetVehicleExtraColours(veh, tonumber(colorId), wheel)  -- FIXED
    elseif colorType == 'wheel'       then SetVehicleExtraColours(veh, pearl, tonumber(colorId))  -- FIXED
    elseif colorType == 'interior'    then SetVehicleInteriorColour(veh, tonumber(colorId))
    elseif colorType == 'dashboard'   then SetVehicleDashboardColour(veh, tonumber(colorId))
    end

    SaveVehicleProperties(veh)
    Notify('success', L('purchase_success'), 'palette')
    ReopenTuningMenu()
end)

RegisterNetEvent('rde_mechanic:applyNeon', function(netId, r, g, b)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId))
    if not DoesEntityExist(veh) then return end

    if r == -1 then
        for i = 0, 3 do SetVehicleNeonLightEnabled(veh, i, false) end
        Notify('success', L('disable_neon'), 'zap-off')
    else
        SetVehicleNeonLightsColour(veh, tonumber(r), tonumber(g), tonumber(b))
        for i = 0, 3 do SetVehicleNeonLightEnabled(veh, i, true) end
        Notify('success', L('purchase_success'), 'lightbulb')
    end

    SaveVehicleProperties(veh)
    ReopenTuningMenu()
end)

RegisterNetEvent('rde_mechanic:applyExtra', function(netId, extraId, state)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId))
    if not DoesEntityExist(veh) then return end
    SetVehicleExtra(veh, tonumber(extraId), not state)
    SaveVehicleProperties(veh)
    Notify('success', L('purchase_success'), 'package')
    ReopenTuningMenu()
end)

-- ============================================
-- 🎯 TUNING SESSION
-- ============================================
local function EndTuningSession()
    -- Restore wheel type if user exited without purchasing
    if State.originalWheelType and not State.wheelTypePurchased
       and State.currentVehicle and DoesEntityExist(State.currentVehicle) then
        SetVehicleWheelType(State.currentVehicle, State.originalWheelType)
    end
    State.originalWheelType  = nil
    State.wheelTypePurchased = false

    RestoreGameplayCamera()
    State.tuningActive = false
    State.menuOpen     = false
    State.lastMenuCall = nil
end

-- ============================================
-- 🎯 TUNING MENUS
-- ============================================
local function ModEmoji(mod) return mod and mod.emoji or '🔧' end
local function ModColor(mod) return mod and mod.color or '#3b82f6' end
local function CatEmoji(cat) return cat and cat.emoji or '⚙️' end
local function CatColor(cat) return cat and cat.color or '#3b82f6' end

local function NeonEmoji(r, g, b)
    if r > 200 and g < 100 and b < 100 then return '🔴' end
    if r < 100 and g > 200 and b < 100 then return '🟢' end
    if r < 100 and g < 100 and b > 200 then return '🔵' end
    if r > 200 and g > 200 and b < 100 then return '🟡' end
    if r > 200 and g < 100 and b > 200 then return '🟣' end
    if r < 100 and g > 200 and b > 200 then return '🩵' end
    if r > 200 and g > 150 and b < 100 then return '🟠' end
    if r > 200 and g > 200 and b > 200 then return '⚪' end
    return '💡'
end

function OpenMainMenu(vehicle)
    if not DoesEntityExist(vehicle) then return end

    State.menuOpen       = true
    State.tuningActive   = true
    State.currentVehicle = vehicle
    TrackMenu(OpenMainMenu, vehicle)

    -- Camera: overview on main menu
    SetupTuningCamera(vehicle, 'overview')

    local vName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local options = {}

    for _, cat in ipairs(Config.ModCategories) do
        local count = cat.mods and #cat.mods or (cat.colors and #cat.colors or 0)
        table.insert(options, {
            title       = CatEmoji(cat) .. '  ' .. L(cat.label),
            description = count .. ' ' .. L('options'),
            icon        = cat.icon or 'settings',
            iconColor   = CatColor(cat),
            onSelect    = function() OpenCategoryMenu(vehicle, cat) end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_main',
        title   = '🚗  ' .. L('menu_title') .. (vName ~= 'NULL' and ('  •  ' .. vName) or ''),
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_main')

    -- Distance watchdog
    CreateThread(function()
        while State.menuOpen do
            if not DoesEntityExist(vehicle)
                or #(GetEntityCoords(cache.ped) - GetEntityCoords(vehicle)) > Config.Distances.maxMenuDistance then
                lib.hideContext()
                EndTuningSession()
                Notify('warning', L('vehicle_too_far'), 'alert-triangle')
                break
            end
            Wait(1000)
        end
    end)
end

function OpenCategoryMenu(vehicle, category)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenCategoryMenu, vehicle, category)

    SetupTuningCamera(vehicle)

    local multiplier = GetMultiplier(vehicle)
    local options    = {}

    if category.mods then
        for _, mod in ipairs(category.mods) do
            local mColor = ModColor(mod)
            local mEmoji = ModEmoji(mod)

            if mod.special == 'neon' then
                local price = math.floor((Config.Prices.neon or 0) * multiplier)
                table.insert(options, {
                    title       = (mod.emoji or '🌈') .. '  ' .. L('neon_lights'),
                    description = '💰 $' .. price .. '  •  14 ' .. L('colors'),
                    icon        = mod.icon or 'lamp',
                    iconColor   = mod.color or '#8b5cf6',
                    onSelect    = function() OpenNeonMenu(vehicle) end,
                })

            elseif mod.special == 'extras' then
                table.insert(options, {
                    title       = (mod.emoji or '🎁') .. '  ' .. L('extras'),
                    description = L('toggle_extra'),  -- FIX: was nil before (missing lang key)
                    icon        = mod.icon or 'package-plus',
                    iconColor   = mod.color or '#f59e0b',
                    onSelect    = function() OpenExtrasMenu(vehicle) end,
                })

            elseif mod.wheelTypes then
                local curTypeLabel = GetWheelTypeLabel(GetVehicleWheelType(vehicle))
                local curTypeEmoji = WHEEL_EMOJI[GetVehicleWheelType(vehicle)] or '🔵'
                local price = math.floor((Config.Prices[mod.type] or 0) * multiplier)
                table.insert(options, {
                    title       = mEmoji .. '  ' .. L(mod.label),
                    description = '💰 $' .. price .. '  •  ' .. curTypeEmoji .. ' ' .. curTypeLabel,
                    icon        = mod.icon or 'circle',
                    iconColor   = mColor,
                    onSelect    = function() OpenWheelTypeMenu(vehicle, mod.type) end,
                })

            elseif mod.toggle then
                local active = IsToggleModOn(vehicle, mod.type)
                local price  = math.floor((Config.Prices[mod.type] or 0) * multiplier)
                local netId  = NetworkGetNetworkIdFromEntity(vehicle)
                local vClass = GetVehicleClass(vehicle)
                table.insert(options, {
                    title       = mEmoji .. '  ' .. L(mod.label),
                    description = ('💰 $%d  •  %s'):format(
                        price, active and ('✅ ' .. L('installed')) or ('❌ ' .. L('not_installed'))),
                    icon        = active and 'toggle-right' or 'toggle-left',
                    iconColor   = active and '#10b981' or '#64748b',
                    onSelect    = function()
                        -- Toggle mods: show preview + confirm
                        local snap      = CaptureVehicleModState(vehicle, mod.type, true, nil, nil)
                        local newValue  = not active
                        ApplyPreviewMod(vehicle, mod.type, newValue, nil, true)
                        local previewBy = GetPlayerServerId(PlayerId())
                        SyncPreviewStateBag(netId, {
                            modType=mod.type, modValue=newValue, isToggle=true,
                            snap=snap, previewBy=previewBy,
                        })
                        CreateThread(function()
                            local confirmed = lib.alertDialog({
                                header   = '🔧 ' .. L(mod.label),
                                content  = ('💰 **$%d**\n\n' .. L('preview_desc')):format(price),
                                centered = true,
                                cancel   = true,
                                labels   = { confirm = L('preview_confirm', price), cancel = L('preview_cancel') },
                            })
                            if confirmed == 'confirm' then
                                TriggerServerEvent('rde_mechanic:purchaseMod',
                                    netId, mod.type, newValue, price, nil, true, vClass)
                                ClearPreviewStateBag(netId)
                            else
                                RestoreFromCapture(vehicle, snap)
                                ClearPreviewStateBag(netId)
                                OpenCategoryMenu(vehicle, category)
                            end
                        end)
                    end,
                })

            else
                local numMods = GetNumVehicleMods(vehicle, mod.type)
                if numMods > 0 then
                    local current = GetVehicleMod(vehicle, mod.type)
                    local price   = math.floor((Config.Prices[mod.type] or 0) * multiplier)
                    local curName = current == -1
                        and ('⭕ ' .. L('stock'))
                        or GetNativeModName(vehicle, mod.type, current)
                    table.insert(options, {
                        title       = mEmoji .. '  ' .. L(mod.label),
                        description = ('💰 $%d  •  %d %s  •  %s'):format(
                            price, numMods, L('options'), curName),
                        icon        = mod.icon or 'settings',
                        iconColor   = mColor,
                        onSelect    = function() OpenModOptions(vehicle, mod, mod.label) end,
                    })
                end
            end
        end
    end

    if category.colors then
        for _, col in ipairs(category.colors) do
            local price = math.floor((Config.Prices['color_' .. col.type] or 0) * multiplier)
            table.insert(options, {
                title       = (col.emoji or '🎨') .. '  ' .. L(col.label),
                description = ('💰 $%d  •  160 %s'):format(price, L('colors')),
                icon        = col.icon or 'palette',
                iconColor   = col.color or '#ec4899',
                onSelect    = function() OpenColorMenu(vehicle, col.type) end,
            })
        end
    end

    if #options == 0 then
        options = {{ title = 'ℹ️  ' .. L('info'), description = 'No upgrades available', icon = 'info', disabled = true }}
    end

    lib.registerContext({
        id      = 'rde_mechanic_category',
        title   = CatEmoji(category) .. '  ' .. L(category.label),
        menu    = 'rde_mechanic_main',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_category')
end

function OpenModOptions(vehicle, mod, label)
    if not DoesEntityExist(vehicle) then return end
    local modType = type(mod) == 'table' and mod.type or mod
    local mEmoji  = type(mod) == 'table' and ModEmoji(mod) or '🔧'
    local mColor  = type(mod) == 'table' and ModColor(mod) or '#3b82f6'

    TrackMenu(OpenModOptions, vehicle, mod, label)

    SetupTuningCamera(vehicle)

    local current    = GetVehicleMod(vehicle, modType)
    local numMods    = GetNumVehicleMods(vehicle, modType)
    local multiplier = GetMultiplier(vehicle)
    local price      = math.floor((Config.Prices[modType] or 0) * multiplier)
    local netId      = NetworkGetNetworkIdFromEntity(vehicle)
    local vClass     = GetVehicleClass(vehicle)
    local previewBy  = GetPlayerServerId(PlayerId())
    local options    = {}

    -- Stock option
    table.insert(options, {
        title       = '⭕  ' .. L('stock'),
        description = current == -1 and ('✅ ' .. L('installed')) or ('🆓 ' .. L('free')),
        icon        = current == -1 and 'check-circle' or 'refresh-cw',
        iconColor   = current == -1 and '#10b981' or '#64748b',
        onSelect    = function()
            if current == -1 then return end  -- already stock
            local snap = CaptureVehicleModState(vehicle, modType, false, nil, nil)
            ApplyPreviewMod(vehicle, modType, -1, nil, false)
            SyncPreviewStateBag(netId, {
                modType=modType, modValue=-1, isToggle=false,
                snap=snap, previewBy=previewBy,
            })
            CreateThread(function()
                local confirmed = lib.alertDialog({
                    header   = '⭕ ' .. L('stock'),
                    content  = '🆓 **FREE**\n\n' .. L('preview_desc'),
                    centered = true,
                    cancel   = true,
                    labels   = { confirm = '✅ ' .. L('yes'), cancel = L('preview_cancel') },
                })
                if confirmed == 'confirm' then
                    TriggerServerEvent('rde_mechanic:purchaseMod', netId, modType, -1, 0, nil, false, vClass)
                    ClearPreviewStateBag(netId)
                else
                    RestoreFromCapture(vehicle, snap)
                    ClearPreviewStateBag(netId)
                    OpenModOptions(vehicle, mod, label)
                end
            end)
        end,
    })

    for i = 0, numMods - 1 do
        local name     = GetNativeModName(vehicle, modType, i)
        local selected = (i == current)
        table.insert(options, {
            title       = (selected and '✅  ' or mEmoji .. '  ') .. name,
            description = selected and ('✅ ' .. L('installed')) or ('💰 $%d'):format(price),
            icon        = selected and 'check-circle' or 'circle',
            iconColor   = selected and '#10b981' or mColor,
            onSelect    = function()
                if selected then return end  -- already installed
                local snap = CaptureVehicleModState(vehicle, modType, false, nil, nil)
                ApplyPreviewMod(vehicle, modType, i, nil, false)
                SyncPreviewStateBag(netId, {
                    modType=modType, modValue=i, isToggle=false,
                    snap=snap, previewBy=previewBy,
                })
                CreateThread(function()
                    local confirmed = lib.alertDialog({
                        header   = mEmoji .. ' ' .. name,
                        content  = ('💰 **$%d**\n\n' .. L('preview_desc')):format(price),
                        centered = true,
                        cancel   = true,
                        labels   = { confirm = L('preview_confirm', price), cancel = L('preview_cancel') },
                    })
                    if confirmed == 'confirm' then
                        TriggerServerEvent('rde_mechanic:purchaseMod', netId, modType, i, price, nil, false, vClass)
                        ClearPreviewStateBag(netId)
                    else
                        RestoreFromCapture(vehicle, snap)
                        ClearPreviewStateBag(netId)
                        OpenModOptions(vehicle, mod, label)
                    end
                end)
            end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_mods',
        title   = mEmoji .. '  ' .. L(label),
        menu    = 'rde_mechanic_category',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_mods')
end

function OpenWheelTypeMenu(vehicle, modType)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenWheelTypeMenu, vehicle, modType)

    -- Save original wheel type on first entry to wheel menus
    if not State.originalWheelType then
        State.originalWheelType  = GetVehicleWheelType(vehicle)
        State.wheelTypePurchased = false
    end

    SetupTuningCamera(vehicle, 'wheel_fl')

    local currentType = GetVehicleWheelType(vehicle)
    local multiplier  = GetMultiplier(vehicle)

    -- Rim-Counts für alle WheelTypes in einem Durchlauf vorab lesen
    local rimCounts = {}
    for _, wt in ipairs(Config.WheelTypes) do
        SetVehicleWheelType(vehicle, wt.id)
        rimCounts[wt.id] = GetNumVehicleMods(vehicle, modType)
    end
    SetVehicleWheelType(vehicle, currentType)  -- exakt einmal restaurieren

    local options = {}

    for _, wt in ipairs(Config.WheelTypes) do
        local selected = (wt.id == currentType)
        local wEmoji   = WHEEL_EMOJI[wt.id] or '🔵'
        local numRims  = rimCounts[wt.id] or 0

        table.insert(options, {
            title       = wEmoji .. '  ' .. L(wt.label),
            description = selected
                and ('✅ ' .. L('current') .. '  •  ' .. numRims .. ' ' .. L('rims'))
                or  ('💰 $%d  •  %d %s'):format(
                    math.floor((Config.Prices[modType] or 0) * multiplier), numRims, L('rims')),
            icon        = 'circle',
            iconColor   = selected and '#10b981' or '#6366f1',
            onSelect    = function() OpenWheelModsMenu(vehicle, modType, wt.id) end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_wheeltypes',
        title   = '🔵  ' .. L('mod_wheels'),
        menu    = 'rde_mechanic_category',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_wheeltypes')
end

function OpenWheelModsMenu(vehicle, modType, wheelType)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenWheelModsMenu, vehicle, modType, wheelType)

    -- Einmalig WheelType setzen, Daten lesen, sofort zurück — kein Flipping in der Loop
    local currentWheelType = GetVehicleWheelType(vehicle)
    SetVehicleWheelType(vehicle, wheelType)
    local numMods = GetNumVehicleMods(vehicle, modType)
    local current = GetVehicleMod(vehicle, modType)
    -- Alle Rim-Namen in einem Durchlauf lesen bevor WheelType restauriert wird
    local rimNames = {}
    for i = 0, numMods - 1 do
        rimNames[i] = GetNativeWheelName(vehicle, wheelType, i)
    end
    SetVehicleWheelType(vehicle, currentWheelType)

    local multiplier = GetMultiplier(vehicle)
    local price      = math.floor((Config.Prices[modType] or 0) * multiplier)
    local netId      = NetworkGetNetworkIdFromEntity(vehicle)
    local vClass     = GetVehicleClass(vehicle)
    local wEmoji     = WHEEL_EMOJI[wheelType] or '🔵'
    local previewBy  = GetPlayerServerId(PlayerId())
    local options    = {}

    SetupTuningCamera(vehicle, 'wheel_fl')

    for i = 0, numMods - 1 do
        local name     = rimNames[i] or ('Wheel %d'):format(i + 1)
        local selected = (i == current and wheelType == currentWheelType)
        table.insert(options, {
            title       = (selected and '✅  ' or wEmoji .. '  ') .. name,
            description = selected and ('✅ ' .. L('installed')) or ('💰 $%d'):format(price),
            icon        = selected and 'check-circle' or 'circle',
            iconColor   = selected and '#10b981' or '#6366f1',
            onSelect    = function()
                if selected then return end
                local snap = CaptureVehicleModState(vehicle, modType, false, wheelType, nil)
                ApplyPreviewMod(vehicle, modType, i, wheelType, false)
                SyncPreviewStateBag(netId, {
                    modType=modType, modValue=i, wheelType=wheelType, isToggle=false,
                    snap=snap, previewBy=previewBy,
                })
                CreateThread(function()
                    local confirmed = lib.alertDialog({
                        header   = wEmoji .. ' ' .. name,
                        content  = ('💰 **$%d**\n\n' .. L('preview_desc')):format(price),
                        centered = true,
                        cancel   = true,
                        labels   = { confirm = L('preview_confirm', price), cancel = L('preview_cancel') },
                    })
                    if confirmed == 'confirm' then
                        State.wheelTypePurchased = true
                        TriggerServerEvent('rde_mechanic:purchaseMod',
                            netId, modType, i, price, wheelType, false, vClass)
                        ClearPreviewStateBag(netId)
                    else
                        RestoreFromCapture(vehicle, snap)
                        ClearPreviewStateBag(netId)
                        OpenWheelModsMenu(vehicle, modType, wheelType)
                    end
                end)
            end,
        })
    end

    if #options == 0 then
        options = {{ title = 'ℹ️  No rims for this type', icon = 'info', disabled = true }}
    end

    lib.registerContext({
        id      = 'rde_mechanic_wheelmods',
        title   = wEmoji .. '  ' .. GetWheelTypeLabel(wheelType),
        menu    = 'rde_mechanic_wheeltypes',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_wheelmods')
end

function OpenColorMenu(vehicle, colorType)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenColorMenu, vehicle, colorType)

    -- Camera: color-type-specific preset
    SetupTuningCamera(vehicle)

    local typeEmoji = {
        primary='🔴', secondary='🔵', pearlescent='🌟',
        wheel='⚫', interior='🪑', dashboard='📊',
    }

    local options = {}
    for i, cat in ipairs(Config.ColorCategories) do
        local count = cat.range[2] - cat.range[1] + 1
        -- FIX: cat.name already has emoji stripped — no longer embed extra emoji
        local catEmoji = ({'⬛','🪨','✨','🎨','🌫️','💎','🔮'})[i] or '🎨'
        table.insert(options, {
            title       = catEmoji .. '  ' .. cat.name,
            description = count .. ' ' .. L('colors'),
            icon        = cat.icon or 'palette',
            iconColor   = '#ec4899',
            onSelect    = function() OpenColorRange(vehicle, colorType, cat.range, cat.name) end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_colors',
        title   = (typeEmoji[colorType] or '🎨') .. '  ' .. L(colorType .. '_color'),
        menu    = 'rde_mechanic_category',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_colors')
end

function OpenColorRange(vehicle, colorType, range, categoryName)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenColorRange, vehicle, colorType, range, categoryName)

    local multiplier = GetMultiplier(vehicle)
    local price      = math.floor((Config.Prices['color_' .. colorType] or 0) * multiplier)
    local netId      = NetworkGetNetworkIdFromEntity(vehicle)
    local vClass     = GetVehicleClass(vehicle)
    local previewBy  = GetPlayerServerId(PlayerId())

    local p, s         = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)  -- (pearlescentColor, wheelColor)
    local intColor     = GetVehicleInteriorColour(vehicle)
    local dashColor    = GetVehicleDashboardColour(vehicle)

    -- FIX: pearl = pearlescentColor, wheel = wheelColor (confusingly named by GTA API)
    local currentId =
        colorType == 'primary'     and p     or
        colorType == 'secondary'   and s     or
        colorType == 'pearlescent' and pearl or  -- FIXED: was using 'wheel' (wrong)
        colorType == 'wheel'       and wheel or  -- FIXED: was using 'pearl' (wrong)
        colorType == 'interior'    and intColor  or
        colorType == 'dashboard'   and dashColor or
        -1

    local options = {}
    for i = range[1], range[2] do
        local name     = GetColorName(i)
        local selected = (i == currentId)
        table.insert(options, {
            title       = (selected and '✅  ' or '🎨  ') .. name,
            description = selected and ('✅ ' .. L('current')) or ('💰 $%d'):format(price),
            icon        = selected and 'check-circle' or 'circle',
            iconColor   = selected and '#10b981' or '#ec4899',
            onSelect    = function()
                if selected then return end
                local snap = CaptureVehicleModState(vehicle, nil, false, nil, colorType)
                ApplyPreviewColor(vehicle, colorType, i)
                SyncPreviewStateBag(netId, {
                    isColor=true, colorType=colorType, colorValue=i,
                    snap=snap, previewBy=previewBy,
                })
                CreateThread(function()
                    local confirmed = lib.alertDialog({
                        header   = '🎨 ' .. name,
                        content  = ('💰 **$%d**\n\n' .. L('preview_desc')):format(price),
                        centered = true,
                        cancel   = true,
                        labels   = { confirm = L('preview_confirm', price), cancel = L('preview_cancel') },
                    })
                    if confirmed == 'confirm' then
                        TriggerServerEvent('rde_mechanic:purchaseColor', netId, colorType, i, price, vClass)
                        ClearPreviewStateBag(netId)
                    else
                        RestoreFromCapture(vehicle, snap)
                        ClearPreviewStateBag(netId)
                        OpenColorRange(vehicle, colorType, range, categoryName)
                    end
                end)
            end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_colorrange',
        title   = '🎨  ' .. (categoryName or ''),
        menu    = 'rde_mechanic_colors',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_colorrange')
end

function OpenNeonMenu(vehicle)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenNeonMenu, vehicle)

    local multiplier = GetMultiplier(vehicle)
    local price      = math.floor((Config.Prices.neon or 0) * multiplier)
    local netId      = NetworkGetNetworkIdFromEntity(vehicle)
    local vClass     = GetVehicleClass(vehicle)

    local options = {
        {
            title       = '❌  ' .. L('disable_neon'),
            description = 'Turn off all neon lights',
            icon        = 'zap-off',
            iconColor   = '#ef4444',
            onSelect    = function()
                TriggerServerEvent('rde_mechanic:purchaseNeon', netId, -1, -1, -1, 0, vClass)
            end,
        }
    }

    for _, col in ipairs(Config.NeonColors) do
        local emoji = NeonEmoji(col.r, col.g, col.b)
        table.insert(options, {
            title       = emoji .. '  ' .. col.name,
            description = ('💰 $%d  •  RGB(%d, %d, %d)'):format(price, col.r, col.g, col.b),
            icon        = 'lightbulb',
            iconColor   = ('#%02x%02x%02x'):format(col.r, col.g, col.b),
            onSelect    = function()
                TriggerServerEvent('rde_mechanic:purchaseNeon', netId, col.r, col.g, col.b, price, vClass)
            end,
        })
    end

    lib.registerContext({
        id      = 'rde_mechanic_neon',
        title   = '🌈  ' .. L('neon_lights'),
        menu    = 'rde_mechanic_category',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_neon')
end

function OpenExtrasMenu(vehicle)
    if not DoesEntityExist(vehicle) then return end
    TrackMenu(OpenExtrasMenu, vehicle)

    local multiplier = GetMultiplier(vehicle)
    local price      = math.floor((Config.Prices.extras or 0) * multiplier)
    local netId      = NetworkGetNetworkIdFromEntity(vehicle)
    local vClass     = GetVehicleClass(vehicle)
    local options    = {}

    for i = 0, 20 do
        if DoesExtraExist(vehicle, i) then
            local isOn = IsVehicleExtraTurnedOn(vehicle, i)
            table.insert(options, {
                title       = (isOn and '✅  ' or '❌  ') .. L('extra', i),
                description = ('💰 $%d  •  %s'):format(
                    price, isOn and L('installed') or L('not_installed')),
                icon        = isOn and 'toggle-right' or 'toggle-left',
                iconColor   = isOn and '#10b981' or '#64748b',
                onSelect    = function()
                    TriggerServerEvent('rde_mechanic:purchaseExtra', netId, i, not isOn, price, vClass)
                end,
            })
        end
    end

    if #options == 0 then
        options = {{ title = 'ℹ️  ' .. L('info'), description = 'No extras available', icon = 'info', disabled = true }}
    end

    lib.registerContext({
        id      = 'rde_mechanic_extras',
        title   = '🎁  ' .. L('extras'),
        menu    = 'rde_mechanic_category',
        options = options,
        onExit  = function() EndTuningSession() end,
    })
    lib.showContext('rde_mechanic_extras')
end

function OpenAdminMenu(mechanicId)
    lib.registerContext({
        id      = 'rde_mechanic_admin',
        title   = '👑  ' .. L('admin_panel'),
        options = {
            {
                title       = '🗑️  ' .. L('delete_mechanic'),
                description = ('Mechanic #%d'):format(mechanicId),
                icon        = 'trash-2',
                iconColor   = '#ef4444',
                onSelect    = function()
                    local confirm = lib.alertDialog({
                        header   = '⚠️ ' .. L('confirm_delete'),
                        content  = L('confirm_delete_msg', mechanicId),
                        centered = true,
                        cancel   = true,
                        labels   = { confirm = L('yes'), cancel = L('no') },
                    })
                    if confirm == 'confirm' then
                        TriggerServerEvent('rde_mechanic:deleteMechanic', mechanicId)
                    end
                end,
            },
        },
    })
    lib.showContext('rde_mechanic_admin')
end

-- ============================================
-- 🚀 INIT
-- ============================================
CreateThread(function()
    while not Config or not lib or not cache do Wait(100) end
    State.ready = true
    Log('Client ready — proximity loop active', 'SUCCESS')
end)

-- ============================================
-- 🔧 COMMANDS
-- ============================================
RegisterCommand('mechanics', function()
    local isAdmin = lib.callback.await('rde_mechanic:isAdmin', false)
    if not isAdmin then Notify('error', L('no_permission'), 'shield-x') return end

    lib.registerContext({
        id      = 'rde_mechanic_admin_panel',
        title   = L('admin_panel'),
        options = {
            {
                title       = L('create_mechanic'),
                description = 'Spawn mechanic at current position',
                icon        = 'user-plus',
                iconColor   = '#10b981',
                onSelect    = function()
                    local coords  = GetEntityCoords(cache.ped)
                    local heading = GetEntityHeading(cache.ped)
                    TriggerServerEvent('rde_mechanic:createMechanic', coords, heading)
                end,
            },
        },
    })
    lib.showContext('rde_mechanic_admin_panel')
end, false)

RegisterCommand('debugmechanics', function()
    local gs      = GlobalState.rde_mechanics
    local gsCount = 0
    if gs then for _ in pairs(gs) do gsCount = gsCount + 1 end end

    local spawned = 0
    for id, m in pairs(State.mechanics) do
        spawned = spawned + 1
        local exists = DoesEntityExist(m.ped)
        local c = exists and GetEntityCoords(m.ped) or vector3(0, 0, 0)
        Log(('Mechanic #%d | Ped: %d | Exists: %s | Pos: %.1f %.1f %.1f')
            :format(id, m.ped, tostring(exists), c.x, c.y, c.z), 'INFO')
    end

    local status = GlobalState[Config.StateBags.mechanicStatus] or {}
    local statusCount = 0
    for _ in pairs(status) do statusCount = statusCount + 1 end

    Notify('info', ('GS: %d | Spawned: %d | Active repairs: %d — F8 for details')
        :format(gsCount, spawned, statusCount), 'info')
end, false)

-- ============================================
-- 🧹 CLEANUP
-- ============================================
AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE_NAME then return end
    for id, _ in pairs(State.mechanics) do DespawnMechanic(id) end
    RestoreGameplayCamera()
    StopAllParticles()
    StopAllSounds()
end)
