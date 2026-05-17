-- ╔════════════════════════════════════════════════════════════╗
-- ║  RDE | Core | 🔺 Next-Gen Vehicle Mechanic & Tuner         ║
-- ║  CONFIG v2.4 – Camera · Preview · Multiplayer Sync         ║
-- ╚════════════════════════════════════════════════════════════╝

Config = {}

Config.DefaultLanguage = 'en'

Config.Languages = {
    en = {
        success             = 'Success',
        error               = 'Error',
        warning             = 'Warning',
        info                = 'Info',
        yes                 = 'Yes',
        no                  = 'No',
        back                = 'Back',
        free                = 'FREE',
        stock               = 'Stock',
        installed           = 'Installed',
        not_installed       = 'Not Installed',
        current             = 'Current',
        level               = 'Level %d',
        options             = 'options',
        colors              = 'colors',
        rims                = 'rims',

        -- FIX: was missing, caused nil string in extras menu
        toggle_extra        = 'Toggle extra accessory',

        -- Preview system strings
        preview_title       = 'Preview Active',
        preview_confirm     = '✅ Buy – $%d',
        preview_cancel      = '❌ Cancel Preview',
        preview_desc        = '_Preview applied – confirm to purchase_',

        target_repair       = 'Repair Vehicle',
        target_modify       = 'Modify Vehicle',
        target_admin        = 'Admin Menu',

        no_vehicle          = 'No vehicle nearby!',
        vehicle_not_damaged = 'Vehicle is not damaged!',
        not_enough_money    = 'Not enough money!',
        vehicle_too_far     = 'Vehicle is too far away!',
        vehicle_busy        = 'This vehicle is already being worked on!',

        mechanic_walking    = 'Mechanic is on the way...',
        hood_opened         = 'Hood opened',
        hood_closed         = 'Hood closed',
        repair_in_progress  = 'Repairing... %d%%',
        repair_completed    = 'Repair completed!',
        repair_failed       = 'Repair failed!',
        mechanic_returning  = 'Mechanic is returning...',

        purchase_success    = 'Upgrade installed!',
        purchase_failed     = 'Purchase failed!',
        too_many_requests   = 'Too many requests – slow down!',

        menu_title          = 'Vehicle Modifications',

        category_performance = 'Engine & Performance',
        category_body        = 'Body & Exterior',
        category_paint       = 'Paint & Colors',
        category_wheels      = 'Wheels & Tires',
        category_lights      = 'Lights & Neon',
        category_interior    = 'Interior',
        category_misc        = 'Miscellaneous',
        category_weapons     = 'Vehicle Weapons',

        mod_spoiler         = 'Spoiler',
        mod_fbumper         = 'Front Bumper',
        mod_rbumper         = 'Rear Bumper',
        mod_skirt           = 'Side Skirts',
        mod_exhaust         = 'Exhaust',
        mod_frame           = 'Roll Cage',
        mod_grille          = 'Grille',
        mod_hood            = 'Hood',
        mod_fender          = 'Left Fender',
        mod_rfender         = 'Right Fender',
        mod_roof            = 'Roof',
        mod_engine          = 'Engine',
        mod_brakes          = 'Brakes',
        mod_transmission    = 'Transmission',
        mod_horns           = 'Horn',
        mod_suspension      = 'Suspension',
        mod_armor           = 'Armor',
        mod_turbo           = 'Turbo',
        mod_drift_tires     = 'Drift Tires',
        mod_customtires     = 'Custom Tires',
        mod_xenon           = 'Xenon Headlights',
        mod_wheels          = 'Wheels',
        mod_bwheels         = 'Back Wheels',
        mod_plateholder     = 'Plate Holder',
        mod_vanity          = 'Vanity Plates',
        mod_trimA           = 'Trim Design',
        mod_ornaments       = 'Ornaments',
        mod_dashboard       = 'Dashboard',
        mod_dial            = 'Speedometer',
        mod_door            = 'Door Interior',
        mod_seats           = 'Seats',
        mod_steering        = 'Steering Wheel',
        mod_shifter         = 'Shift Lever',
        mod_plaques         = 'Plaques',
        mod_speakers        = 'Speakers',
        mod_trunk           = 'Trunk',
        mod_hydraulics      = 'Hydraulics',
        mod_engineblock     = 'Engine Block',
        mod_airfilter       = 'Air Filter',
        mod_struts          = 'Strut Braces',
        mod_archcover       = 'Arch Covers',
        mod_aerials         = 'Antenna',
        mod_trimB           = 'Trim B',
        mod_tank            = 'Fuel Tank',
        mod_windows         = 'Window Tint',
        mod_livery          = 'Livery',
        mod_lightbar        = 'Light Bar',
        mod_stickerbomb     = 'Sticker Bomb',
        mod_interior_extra  = 'Interior Extra',

        mod_mg              = 'Machine Gun',
        mod_missiles        = 'Missiles',
        mod_flamethrower    = 'Flamethrower',
        mod_minigun         = 'Minigun',
        mod_railgun         = 'Railgun',
        mod_laser           = 'Laser',

        primary_color       = 'Primary Color',
        secondary_color     = 'Secondary Color',
        pearlescent_color   = 'Pearlescent Color',
        wheel_color         = 'Wheel Color',
        interior_color      = 'Interior Color',
        dashboard_color     = 'Dashboard Color',

        neon_lights         = 'Neon Lights',
        disable_neon        = 'Disable Neon',

        wheel_sport         = 'Sport',
        wheel_muscle        = 'Muscle',
        wheel_lowrider      = 'Lowrider',
        wheel_suv           = 'SUV',
        wheel_offroad       = 'Offroad',
        wheel_tuner         = 'Tuner',
        wheel_bike          = 'Bike',
        wheel_highend       = 'High End',
        wheel_bennys        = "Benny's Original",
        wheel_bespoke       = "Benny's Bespoke",
        wheel_openwheel     = 'Open Wheel',
        wheel_street        = 'Street',
        wheel_track         = 'Track',
        wheel_drift         = 'Drift',
        wheel_rally         = 'Rally',

        extras              = 'Extras',
        extra               = 'Extra %d',

        admin_panel         = 'Mechanic Admin Panel',
        create_mechanic     = 'Create Mechanic',
        delete_mechanic     = 'Delete Mechanic',
        mechanic_created    = 'Mechanic created!',
        mechanic_deleted    = 'Mechanic deleted!',
        mechanic_not_found  = 'Mechanic not found!',
        mechanic_too_close  = 'Too close to another mechanic!',
        no_permission       = 'No permission!',
        please_wait         = 'Please wait...',
        database_error      = 'Database error!',
        invalid_coords      = 'Invalid coordinates!',
        confirm_delete      = 'Confirm Deletion',
        confirm_delete_msg  = 'Delete mechanic #%s?',
        refresh_mechanics   = 'Refresh All Mechanics',
        mechanic_info       = 'Mechanic Info #%s',
        mechanic_busy       = 'Busy: %s',

        mod_dash_color      = 'Dashboard Color',
        mod_interior_color  = 'Interior Color',

        tint_none           = 'None',
        tint_pure_black     = 'Pure Black',
        tint_dark_smoke     = 'Dark Smoke',
        tint_light_smoke    = 'Light Smoke',
        tint_limo           = 'Limo',
        tint_green          = 'Green',

        neon_color          = 'Neon Color',
    },

    de = {
        success             = 'Erfolg',
        error               = 'Fehler',
        warning             = 'Warnung',
        info                = 'Info',
        yes                 = 'Ja',
        no                  = 'Nein',
        back                = 'Zurück',
        free                = 'KOSTENLOS',
        stock               = 'Standard',
        installed           = 'Installiert',
        not_installed       = 'Nicht installiert',
        current             = 'Aktuell',
        level               = 'Stufe %d',
        options             = 'Optionen',
        colors              = 'Farben',
        rims                = 'Felgen',

        toggle_extra        = 'Extra-Zubehör umschalten',

        preview_title       = 'Vorschau aktiv',
        preview_confirm     = '✅ Kaufen – $%d',
        preview_cancel      = '❌ Vorschau abbrechen',
        preview_desc        = '_Vorschau wird angezeigt – bestätigen zum Kaufen_',

        target_repair       = 'Fahrzeug reparieren',
        target_modify       = 'Fahrzeug modifizieren',
        target_admin        = 'Admin-Menü',

        no_vehicle          = 'Kein Fahrzeug in der Nähe!',
        vehicle_not_damaged = 'Fahrzeug ist nicht beschädigt!',
        not_enough_money    = 'Nicht genug Geld!',
        vehicle_too_far     = 'Fahrzeug ist zu weit entfernt!',
        vehicle_busy        = 'Dieses Fahrzeug wird gerade bearbeitet!',

        mechanic_walking    = 'Mechaniker kommt...',
        hood_opened         = 'Motorhaube geöffnet',
        hood_closed         = 'Motorhaube geschlossen',
        repair_in_progress  = 'Repariere... %d%%',
        repair_completed    = 'Reparatur abgeschlossen!',
        repair_failed       = 'Reparatur fehlgeschlagen!',
        mechanic_returning  = 'Mechaniker kehrt zurück...',

        purchase_success    = 'Upgrade erfolgreich installiert!',
        purchase_failed     = 'Kauf fehlgeschlagen!',
        too_many_requests   = 'Zu viele Anfragen – bitte langsamer!',

        menu_title          = 'Fahrzeugmodifikationen',

        category_performance = 'Motor & Leistung',
        category_body        = 'Karosserie & Außen',
        category_paint       = 'Lackierung & Farben',
        category_wheels      = 'Räder & Reifen',
        category_lights      = 'Lichter & Neon',
        category_interior    = 'Innenraum',
        category_misc        = 'Sonstiges',
        category_weapons     = 'Fahrzeugwaffen',

        mod_spoiler         = 'Spoiler',
        mod_fbumper         = 'Frontstoßstange',
        mod_rbumper         = 'Heckstoßstange',
        mod_skirt           = 'Seitenschweller',
        mod_exhaust         = 'Auspuff',
        mod_frame           = 'Überrollkäfig',
        mod_grille          = 'Kühlergrill',
        mod_hood            = 'Motorhaube',
        mod_fender          = 'Linker Kotflügel',
        mod_rfender         = 'Rechter Kotflügel',
        mod_roof            = 'Dach',
        mod_engine          = 'Motor',
        mod_brakes          = 'Bremsen',
        mod_transmission    = 'Getriebe',
        mod_horns           = 'Hupe',
        mod_suspension      = 'Fahrwerk',
        mod_armor           = 'Panzerung',
        mod_turbo           = 'Turbo',
        mod_drift_tires     = 'Drift-Reifen',
        mod_customtires     = 'Custom-Reifen',
        mod_xenon           = 'Xenon-Scheinwerfer',
        mod_wheels          = 'Räder',
        mod_bwheels         = 'Hinterräder',
        mod_plateholder     = 'Kennzeichenhalter',
        mod_vanity          = 'Sonderkennzeichen',
        mod_trimA           = 'Zierleisten A',
        mod_ornaments       = 'Verzierungen',
        mod_dashboard       = 'Armaturenbrett',
        mod_dial            = 'Tacho',
        mod_door            = 'Türverkleidung',
        mod_seats           = 'Sitze',
        mod_steering        = 'Lenkrad',
        mod_shifter         = 'Schalthebel',
        mod_plaques         = 'Plaketten',
        mod_speakers        = 'Lautsprecher',
        mod_trunk           = 'Kofferraum',
        mod_hydraulics      = 'Hydraulik',
        mod_engineblock     = 'Motorblock',
        mod_airfilter       = 'Luftfilter',
        mod_struts          = 'Domstreben',
        mod_archcover       = 'Radkastenabdeckung',
        mod_aerials         = 'Antenne',
        mod_trimB           = 'Zierleisten B',
        mod_tank            = 'Kraftstofftank',
        mod_windows         = 'Fenstertönung',
        mod_livery          = 'Lackdesign',
        mod_lightbar        = 'Lichtbalken',
        mod_stickerbomb     = 'Sticker-Bombe',
        mod_interior_extra  = 'Innenraum-Extra',

        mod_mg              = 'Maschinengewehr',
        mod_missiles        = 'Raketen',
        mod_flamethrower    = 'Flammenwerfer',
        mod_minigun         = 'Minigun',
        mod_railgun         = 'Schienengewehr',
        mod_laser           = 'Laser',

        primary_color       = 'Primärfarbe',
        secondary_color     = 'Sekundärfarbe',
        pearlescent_color   = 'Perlglanz-Farbe',
        wheel_color         = 'Felgenfarbe',
        interior_color      = 'Innenraumfarbe',
        dashboard_color     = 'Armaturenbrett-Farbe',

        neon_lights         = 'Neon-Lichter',
        disable_neon        = 'Neon deaktivieren',

        wheel_sport         = 'Sport',
        wheel_muscle        = 'Muscle',
        wheel_lowrider      = 'Lowrider',
        wheel_suv           = 'SUV',
        wheel_offroad       = 'Offroad',
        wheel_tuner         = 'Tuner',
        wheel_bike          = 'Bike',
        wheel_highend       = 'High End',
        wheel_bennys        = "Bennys Original",
        wheel_bespoke       = "Bennys Bespoke",
        wheel_openwheel     = 'Open Wheel',
        wheel_street        = 'Street',
        wheel_track         = 'Track',
        wheel_drift         = 'Drift',
        wheel_rally         = 'Rally',

        extras              = 'Extras',
        extra               = 'Extra %d',

        admin_panel         = 'Mechaniker Admin-Panel',
        create_mechanic     = 'Mechaniker erstellen',
        delete_mechanic     = 'Mechaniker löschen',
        mechanic_created    = 'Mechaniker erstellt!',
        mechanic_deleted    = 'Mechaniker gelöscht!',
        mechanic_not_found  = 'Mechaniker nicht gefunden!',
        mechanic_too_close  = 'Zu nah an einem anderen Mechaniker!',
        no_permission       = 'Keine Berechtigung!',
        please_wait         = 'Bitte warten...',
        database_error      = 'Datenbankfehler!',
        invalid_coords      = 'Ungültige Koordinaten!',
        confirm_delete      = 'Löschung bestätigen',
        confirm_delete_msg  = 'Mechaniker #%s löschen?',
        refresh_mechanics   = 'Alle Mechaniker aktualisieren',
        mechanic_info       = 'Mechaniker Info #%s',
        mechanic_busy       = 'Beschäftigt: %s',

        mod_dash_color      = 'Armaturenbrett-Farbe',
        mod_interior_color  = 'Innenraumfarbe',

        tint_none           = 'Keine',
        tint_pure_black     = 'Tiefschwarz',
        tint_dark_smoke     = 'Dunkel getönt',
        tint_light_smoke    = 'Leicht getönt',
        tint_limo           = 'Limo',
        tint_green          = 'Grün',

        neon_color          = 'Neon-Farbe',
    }
}

Config.Debug = {
    enabled         = false,
    logRepairs      = true,
    logPurchases    = true,
    logAdminActions = true,
}

Config.Performance = {
    renderDistance      = 150.0,
    despawnDistance     = 200.0,
    proximityTick       = 1000,
    maxVisibleMechanics = 20,
}

Config.Notification = {
    position = 'top-right',
    duration = 5000,
}

Config.Blip = {
    enabled    = true,
    sprite     = 446,
    scale      = 0.6,
    color      = 5,
    shortRange = true,
    name       = 'RDE Mechanic',
}

Config.MechanicModels = {
    's_m_y_construct_01',
    's_m_y_construct_02',
    's_m_m_autoshop_01',
    's_m_m_autoshop_02',
    's_m_y_xmech_01',
    's_m_y_xmech_02',
}

Config.MechanicBehavior = {
    invincible     = true,
    freezePosition = true,
    blockEvents    = true,
    canRagdoll     = false,
    walkSpeed      = 1.0,
    animations     = {
        {
            dict  = 'mini@repair',
            name  = 'fixing_a_ped',
            tool  = 'prop_tool_spanner02',
            bone  = 28422,
            loops = 3,
        },
        {
            dict  = 'mini@repair',
            name  = 'fixing_a_player',
            tool  = 'prop_tool_spanner02',
            bone  = 28422,
            loops = 3,
        },
    }
}

Config.Distances = {
    interactionRange      = 8.0,
    vehicleDetectionRange = 5.0,
    repairPositionOffset  = 2.5,
    minMechanicDistance   = 25.0,
    maxMenuDistance       = 10.0,
}

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

Config.Particles = {
    enabled = true,
    sparks  = {
        dict   = 'core',
        name   = 'ent_amb_fbi_door_sparks',
        offset = vector3(0.0, 1.0, 0.3),
        scale  = 0.8,
    }
}

Config.Sounds = {
    enabled    = true,
    hood_open  = { dict = 'DLC_HEIST_HACKING_SNAKE_SOUNDS', name = 'SUCCESS'  },
    hood_close = { dict = 'DLC_HEIST_HACKING_SNAKE_SOUNDS', name = 'Goal'     },
    purchase   = { dict = 'HUD_FRONTEND_DEFAULT_SOUNDSET',  name = 'PURCHASE' },
}

Config.Admin = {
    acePermission = 'rde.mechanic.admin',
    oxGroups      = { 'admin', 'superadmin', 'moderator', 'owner', 'dev' },
}

Config.Security = {
    maxPurchasesPerMinute    = 15,
    repairCooldown           = 5,
    mechanicSpawnCooldown    = 60,
    validatePricesServerSide = true,
}

Config.VehicleClassMultipliers = {
    [0]=1.0,[1]=1.2,[2]=1.4,[3]=1.6,[4]=1.8,[5]=2.0,[6]=2.2,[7]=2.4,
    [8]=2.6,[9]=1.1,[10]=1.3,[11]=1.5,[12]=1.7,[13]=1.0,[14]=2.8,
    [15]=3.0,[16]=3.2,[17]=1.0,[18]=2.5,[19]=1.0,[20]=3.5,[21]=1.0,
}

Config.Prices = {
    repair = 500,
    [11]=2500,[12]=1500,[13]=2000,[15]=1800,[16]=3000,[18]=5000,[62]=3500,
    [58]=25000,[59]=35000,[60]=30000,[61]=40000,[63]=50000,[64]=60000,
    [0]=500,[1]=600,[2]=600,[3]=800,[4]=400,[5]=300,[6]=350,
    [7]=700,[8]=300,[9]=400,[10]=800,
    [14]=500,[22]=1000,
    [23]=1200,[24]=1200,
    [25]=250,[26]=200,[27]=350,[28]=450,[29]=150,[30]=200,[31]=250,
    [32]=400,[33]=300,[34]=200,[35]=250,[36]=200,[37]=400,[38]=300,
    [39]=200,[40]=250,[41]=300,[42]=350,[43]=300,[44]=200,[45]=250,
    [46]=350,[47]=600,[48]=150,[49]=500,
    color_primary=800,color_secondary=800,color_pearlescent=1000,
    color_wheel=500,color_interior=600,color_dashboard=600,

    high_end = {
        [0]=1200,[1]=1500,[2]=1500,[3]=2000,[4]=1000,[5]=800,[6]=900,
        [7]=1800,[8]=800,[9]=900,[10]=2000,
        [25]=500,[27]=800,[28]=1000,[29]=400,[30]=500,[31]=600,
        [32]=1000,[33]=800,[34]=500,[35]=600,[36]=500,[37]=1000,
        [38]=800,[39]=500,[40]=600,[41]=800,[42]=900,[43]=600,
        [44]=500,[45]=600,[46]=800,[47]=1200,[48]=400,[49]=1000,
    },
    high_end_wheels = { [23]=2500, [24]=2500 },
    high_end_colors = {
        color_primary=1500, color_secondary=1500, color_pearlescent=2000,
        color_wheel=1000,   color_interior=1200,  color_dashboard=1200,
    },
    neon=1500,windowTint=500,extras=200,
}

Config.ModCategories = {
    {
        id='performance', label='category_performance',
        emoji='⚡', icon='zap', color='#f59e0b',
        mods={
            {type=11, label='mod_engine',       emoji='⚡', icon='zap',          color='#f59e0b'},
            {type=12, label='mod_brakes',        emoji='🛑', icon='disc',         color='#ef4444'},
            {type=13, label='mod_transmission',  emoji='⚙️', icon='settings-2',   color='#f97316'},
            {type=15, label='mod_suspension',    emoji='🔩', icon='move-vertical',color='#a78bfa'},
            {type=16, label='mod_armor',         emoji='🛡️', icon='shield-check', color='#6366f1'},
            {type=18, label='mod_turbo',         emoji='🌪️', icon='tornado',       color='#06b6d4', toggle=true},
            {type=20, label='mod_customtires',   emoji='🔘', icon='circle-dashed',color='#84cc16', toggle=true},
            {type=62, label='mod_drift_tires',   emoji='🏁', icon='flag',          color='#f43f5e', toggle=true},
        }
    },
    {
        id='weapons', label='category_weapons',
        emoji='💥', icon='crosshair', color='#ef4444',
        mods={
            {type=58, label='mod_mg',            emoji='🔫', icon='crosshair',    color='#ef4444', toggle=true},
            {type=59, label='mod_missiles',      emoji='🚀', icon='target',       color='#f97316', toggle=true},
            {type=60, label='mod_flamethrower',  emoji='🔥', icon='flame',        color='#f59e0b', toggle=true},
            {type=61, label='mod_minigun',       emoji='💥', icon='zap',          color='#ef4444', toggle=true},
            {type=63, label='mod_railgun',       emoji='⚡', icon='zap',          color='#8b5cf6', toggle=true},
            {type=64, label='mod_laser',         emoji='🔆', icon='scan-line',    color='#06b6d4', toggle=true},
        }
    },
    {
        id='body', label='category_body',
        emoji='🚗', icon='car', color='#3b82f6',
        mods={
            {type=0,  label='mod_spoiler',       emoji='💨', icon='wind',         color='#06b6d4'},
            {type=1,  label='mod_fbumper',       emoji='🛡️', icon='shield',       color='#3b82f6'},
            {type=2,  label='mod_rbumper',       emoji='🛡️', icon='shield',       color='#6366f1'},
            {type=3,  label='mod_skirt',         emoji='📐', icon='minus',        color='#8b5cf6'},
            {type=4,  label='mod_exhaust',       emoji='💨', icon='cloud',        color='#6b7280'},
            {type=5,  label='mod_frame',         emoji='🏗️', icon='grid-2x2',    color='#78716c'},
            {type=6,  label='mod_grille',        emoji='🔲', icon='grid-3x3',    color='#64748b'},
            {type=7,  label='mod_hood',          emoji='🚘', icon='box',          color='#3b82f6'},
            {type=8,  label='mod_fender',        emoji='🔧', icon='wrench',       color='#0ea5e9'},
            {type=9,  label='mod_rfender',       emoji='🔧', icon='wrench',       color='#0ea5e9'},
            {type=10, label='mod_roof',          emoji='🏠', icon='triangle',     color='#8b5cf6'},
            {type=47, label='mod_stickerbomb',   emoji='💣', icon='layers',       color='#f43f5e'},
            {type=48, label='mod_livery',        emoji='🎨', icon='image',        color='#ec4899'},
        }
    },
    {
        id='wheels', label='category_wheels',
        emoji='🔵', icon='circle', color='#6366f1',
        mods={
            {type=23, label='mod_wheels',        emoji='🔵', icon='circle',       color='#6366f1', wheelTypes=true},
            {type=24, label='mod_bwheels',       emoji='⚫', icon='circle-dot',   color='#374151'},
        }
    },
    {
        id='paint', label='category_paint',
        emoji='🎨', icon='palette', color='#ec4899',
        colors={
            {type='primary',     label='primary_color',     emoji='🔴', icon='palette',  color='#ef4444'},
            {type='secondary',   label='secondary_color',   emoji='🔵', icon='palette',  color='#3b82f6'},
            {type='pearlescent', label='pearlescent_color', emoji='🌟', icon='sparkles', color='#a78bfa'},
            {type='wheel',       label='wheel_color',       emoji='⚫', icon='circle',   color='#374151'},
            {type='interior',    label='interior_color',    emoji='🪑', icon='armchair', color='#8b5cf6'},
            {type='dashboard',   label='dashboard_color',   emoji='📊', icon='gauge',    color='#06b6d4'},
        }
    },
    {
        id='lights', label='category_lights',
        emoji='💡', icon='lightbulb', color='#fbbf24',
        mods={
            {type=22,       label='mod_xenon',  emoji='💡', icon='lightbulb',    color='#fbbf24', toggle=true},
            {special='neon',label='neon_lights',emoji='🌈', icon='lamp',         color='#8b5cf6'},
        }
    },
    {
        id='interior', label='category_interior',
        emoji='🪑', icon='armchair', color='#8b5cf6',
        mods={
            {type=27, label='mod_trimA',         emoji='🪑', icon='layers',        color='#8b5cf6'},
            {type=28, label='mod_ornaments',     emoji='💎', icon='gem',           color='#ec4899'},
            {type=29, label='mod_dashboard',     emoji='📊', icon='layout-dashboard',color='#06b6d4'},
            {type=30, label='mod_dial',          emoji='🔵', icon='gauge',         color='#3b82f6'},
            {type=31, label='mod_door',          emoji='🚪', icon='panel-left',    color='#84cc16'},
            {type=32, label='mod_seats',         emoji='🪑', icon='armchair',      color='#a78bfa'},
            {type=33, label='mod_steering',      emoji='🎮', icon='circle-dot',    color='#f97316'},
            {type=34, label='mod_shifter',       emoji='🔧', icon='move-up-right', color='#78716c'},
            {type=35, label='mod_plaques',       emoji='🏆', icon='award',         color='#fbbf24'},
            {type=36, label='mod_speakers',      emoji='🔊', icon='volume-2',      color='#ec4899'},
            {type=37, label='mod_trunk',         emoji='📦', icon='package',       color='#78716c'},
            {type=38, label='mod_hydraulics',    emoji='⬆️', icon='arrow-up-down', color='#10b981'},
            {type=39, label='mod_engineblock',   emoji='⚙️', icon='cpu',           color='#f59e0b'},
            {type=40, label='mod_airfilter',     emoji='🌬️', icon='wind',          color='#06b6d4'},
            {type=41, label='mod_struts',        emoji='🔩', icon='bar-chart-2',   color='#6366f1'},
            {type=42, label='mod_archcover',     emoji='🛡️', icon='shield',        color='#64748b'},
            {type=43, label='mod_aerials',       emoji='📡', icon='radio',         color='#10b981'},
            {type=44, label='mod_trimB',         emoji='🪑', icon='layers',        color='#8b5cf6'},
            {type=45, label='mod_tank',          emoji='🛢️', icon='cylinder',      color='#78716c'},
            {type=46, label='mod_windows',       emoji='🪟', icon='eye-off',       color='#0ea5e9'},
            {type=49, label='mod_interior_extra',emoji='✨', icon='sparkles',      color='#fbbf24'},
        }
    },
    {
        id='misc', label='category_misc',
        emoji='⚙️', icon='settings', color='#6b7280',
        mods={
            {type=14,        label='mod_horns',      emoji='📯', icon='bell',         color='#f59e0b'},
            {type=25,        label='mod_plateholder',emoji='🔲', icon='tag',          color='#6b7280'},
            {type=26,        label='mod_vanity',     emoji='🪪', icon='credit-card',  color='#6366f1'},
            {special='extras',label='extras',        emoji='🎁', icon='package-plus', color='#f59e0b'},
        }
    },
}

Config.WheelTypes = {
    {id=0, label='wheel_sport'},    {id=1, label='wheel_muscle'},
    {id=2, label='wheel_lowrider'}, {id=3, label='wheel_suv'},
    {id=4, label='wheel_offroad'},  {id=5, label='wheel_tuner'},
    {id=6, label='wheel_bike'},     {id=7, label='wheel_highend'},
    {id=8, label='wheel_bennys'},   {id=9, label='wheel_bespoke'},
    {id=10,label='wheel_openwheel'},{id=11,label='wheel_street'},
    {id=12,label='wheel_track'},    {id=13,label='wheel_drift'},
    {id=14,label='wheel_rally'},
}

Config.WheelNames = {
    [0]={
        [0]="Inferno",[1]="Deep Five",[2]="LozSpeed",[3]="Diamond Cut",[4]="Chrome Shadow",
        [5]="Feroci RR",[6]="GT One",[7]="Super Five",[8]="Endo v1",[9]="Split Six",
        [10]="Rally Master",[11]="Undercover",[12]="Slicer",[13]="Viper",[14]="Venom",
        [15]="Dash VIP",[16]="LozSpeed Ten",[17]="Supermesh",[18]="Cheetah R",[19]="Solar",
        [20]="Retro Solair",[21]="Classique",[22]="Turbine",[23]="Classic Ten",[24]="Classic Five",
        [25]="Dukati",[26]="Iced Out",[27]="Cognoscenti",[28]="Loafers",[29]="Dubbed",
        [30]="Six Star",[31]="El Jefe",[32]="Dollar",[33]="Triple Golds",[34]="Big Worm",
        [35]="Seven Fives",[36]="Splits",[37]="Fresh Mesh",[38]="Low Five",[39]="Meteorite",
        [40]="Scrapper",[41]="Liberty City",[42]="Static",[43]="Twist",[44]="Cutter",
        [45]="Upside Down",[46]="Wired",[47]="Solidus",[48]="Aero",[49]="Cheetah R",
        [50]="Super Five",[51]="Endo v2",[52]="Split Ten",[53]="Stockade",[54]="Warren",
        [55]="Scorcher",[56]="Dominator",[57]="Cutter",[58]="Uzer",[59]="GroundRide",
        [60]="S Racer",[61]="Venum",[62]="Flash",[63]="Stock",[64]="Slick",
    },
    [1]={
        [0]="Classic Five",[1]="Dukes",[2]="Muscle Freak",[3]="Kracka",[4]="Azrea",
        [5]="Mecha",[6]="Black Top",[7]="Drag SPL",[8]="Revolver",[9]="Classic Rod",
        [10]="Fairy",[11]="Spooner",[12]="Five Star",[13]="Old School",[14]="El Jefe",
    },
    [2]={
        [0]="Flare",[1]="Wired",[2]="Triple Golds",[3]="Big Worm",[4]="Seven Fives",
        [5]="Splits",[6]="Fresh Mesh",[7]="Low Five",[8]="Meteorite",[9]="Scrapper",
        [10]="Liberty City",[11]="Static",[12]="Twist",[13]="Cutter",[14]="Upside Down",
    },
    [3]={
        [0]="VIP",[1]="Benefactor",[2]="Cosmo",[3]="Bippu",[4]="Royals",
        [5]="Fagorme",[6]="Deluxe",[7]="Iced Out",[8]="Cognoscenti",[9]="Loafers",
        [10]="Dubbed",[11]="Six Star",
    },
    [4]={
        [0]="Raider",[1]="Mudslinger",[2]="Nevis",[3]="Cairngorm",[4]="Amazon",
        [5]="Challenger",[6]="Dune Basher",[7]="Five Star",[8]="Rock Crawler",
        [9]="Mil-Spec Steelie",[10]="Venum",
    },
    [5]={
        [0]="Cosmo",[1]="Super Mesh",[2]="Outlier",[3]="Rollas",[4]="Driff Meinlite",
        [5]="Slicer",[6]="El Quito",[7]="Cutters",[8]="Tuner Five",[9]="Peels",
        [10]="Wires",[11]="Street Special",
    },
    [6]={
        [0]="Speedway",[1]="Street Special",[2]="Racer",[3]="Track Star",[4]="Overlord",
        [5]="Trident",[6]="Triple Threat",[7]="Stiletto",[8]="Wires",[9]="Bobber",
        [10]="Solidus",
    },
    [7]={
        [0]="Shadow",[1]="Hyper",[2]="Blade",[3]="Diamond",[4]="Supa Gee",
        [5]="Chromatic Z",[6]="Mercie Chlip",[7]="Obbey RS",[8]="GT Chrome",[9]="Cheetah RR",
        [10]="Solar",[11]="Classic Ten",[12]="Dollar",[13]="Dukati",[14]="Iced Out",
    },
    [8]={
        [0]="Classic Five",[1]="Dukes",[2]="Muscle Freak",[3]="Kracka",[4]="Azrea",
        [5]="Mecha",[6]="Black Top",[7]="Drag SPL",[8]="Splits",[9]="Fresh Mesh",
    },
    [9]={
        [0]="Solidus",[1]="Aero",[2]="Cheetah R",[3]="Super Five",[4]="Endo v2",[5]="Split Ten",
    },
    [10]={[0]="Stockade",[1]="Warren",[2]="Scorcher",[3]="Dominator",[4]="Cutter"},
    [11]={[0]="Uzer",[1]="GroundRide",[2]="S Racer",[3]="Venum",[4]="Flash"},
    [12]={[0]="Stock",[1]="Slick"},
    [13]={[0]="Street Drift",[1]="Rally Drift"},
    [14]={[0]="Stock",[1]="Rally Master"},
}

Config.InteriorModNames = {
    [27]={[0]="Standard",[1]="Carbon",[2]="Alcantara",[3]="Leather",[4]="Cloth",[5]="Metal",[6]="Wood",[7]="Aluminum",[8]="Fine Wood",[9]="Chrome",[10]="Gold"},
    [28]={[0]="None",[1]="Diamond",[2]="Gold",[3]="Chrome",[4]="Wood",[5]="Steel",[6]="Copper",[7]="Bronze",[8]="Titanium",[9]="Platinum",[10]="Sapphire"},
    [29]={[0]="Standard",[1]="Carbon",[2]="Leather",[3]="Aluminum",[4]="Fine Wood",[5]="Chrome",[6]="Gold",[7]="Diamond",[8]="Alcantara",[9]="Copper",[10]="Titanium"},
    [30]={[0]="Standard",[1]="Sport",[2]="Luxury",[3]="Retro",[4]="Digital",[5]="Analog",[6]="Chrome",[7]="Gold",[8]="Carbon",[9]="Leather",[10]="Aluminum"},
    [31]={[0]="Standard",[1]="Leather",[2]="Cloth",[3]="Carbon",[4]="Alcantara",[5]="Wood",[6]="Metal",[7]="Chrome",[8]="Gold",[9]="Diamond",[10]="Steel"},
    [32]={[0]="Standard",[1]="Sport",[2]="Racing Bucket",[3]="Luxury",[4]="Carbon",[5]="Leather",[6]="Alcantara",[7]="Cloth",[8]="Metal",[9]="Chrome",[10]="Gold"},
    [33]={[0]="Standard",[1]="Sport",[2]="Luxury",[3]="Retro",[4]="Carbon",[5]="Leather",[6]="Alcantara",[7]="Chrome",[8]="Gold",[9]="Wood",[10]="Aluminum"},
    [34]={[0]="Standard",[1]="Short Shifter",[2]="Luxury",[3]="Carbon",[4]="Leather",[5]="Alcantara",[6]="Chrome",[7]="Gold",[8]="Wood",[9]="Aluminum",[10]="Steel"},
    [35]={[0]="None",[1]="Manufacturer",[2]="Tuner Badge",[3]="Custom",[4]="Race Team",[5]="Sponsor",[6]="Luxury",[7]="Retro",[8]="Carbon",[9]="Gold",[10]="Diamond"},
    [36]={[0]="Standard",[1]="Premium",[2]="Bass Box",[3]="Surround",[4]="High-End",[5]="Studio",[6]="Subwoofer",[7]="Luxury",[8]="Retro",[9]="Carbon",[10]="Gold"},
    [37]={[0]="Standard",[1]="Carbon",[2]="Leather",[3]="Steel",[4]="Chrome",[5]="Gold",[6]="Aluminum",[7]="Wood",[8]="Cloth",[9]="Luxury",[10]="Race"},
    [38]={[0]="None",[1]="Standard",[2]="Lowrider",[3]="Showroom",[4]="Luxury",[5]="Retro",[6]="Carbon",[7]="Gold",[8]="Chrome",[9]="Diamond",[10]="Titanium"},
    [39]={[0]="Standard",[1]="Chrome",[2]="Carbon",[3]="Gold",[4]="Aluminum",[5]="Titanium",[6]="Steel",[7]="Diamond",[8]="Copper",[9]="Bronze",[10]="Platinum"},
    [40]={[0]="Standard",[1]="Sport",[2]="Race Filter",[3]="Carbon",[4]="Luxury",[5]="Retro",[6]="Chrome",[7]="Gold",[8]="Aluminum",[9]="Titanium",[10]="Steel"},
    [41]={[0]="None",[1]="Standard",[2]="Carbon",[3]="Titanium",[4]="Chrome",[5]="Gold",[6]="Aluminum",[7]="Steel",[8]="Diamond",[9]="Luxury",[10]="Race"},
    [42]={[0]="Standard",[1]="Carbon",[2]="Chrome",[3]="Gold",[4]="Aluminum",[5]="Titanium",[6]="Steel",[7]="Diamond",[8]="Luxury",[9]="Retro",[10]="Race"},
    [43]={[0]="Standard",[1]="Short",[2]="Rod",[3]="Flag",[4]="Luxury",[5]="Carbon",[6]="Chrome",[7]="Gold",[8]="Diamond",[9]="Retro",[10]="Race"},
    [44]={[0]="Standard",[1]="Carbon",[2]="Alcantara",[3]="Leather",[4]="Wood",[5]="Metal",[6]="Chrome",[7]="Gold",[8]="Diamond",[9]="Aluminum",[10]="Titanium"},
    [45]={[0]="Standard",[1]="Chrome",[2]="Carbon",[3]="Gold",[4]="Aluminum",[5]="Titanium",[6]="Steel",[7]="Diamond",[8]="Luxury",[9]="Retro",[10]="Race"},
    [46]={[0]="None",[1]="Light Smoke",[2]="Dark Smoke",[3]="Limo",[4]="Green",[5]="Blue",[6]="Gold",[7]="Pink",[8]="Purple",[9]="Yellow",[10]="Orange"},
    [47]={[0]="None",[1]="Punk",[2]="Retro",[3]="Graffiti",[4]="Luxury",[5]="Carbon",[6]="Gold",[7]="Diamond",[8]="Chrome",[9]="Race",[10]="Custom"},
    [48]={[0]="Standard",[1]="Race Stripes",[2]="Sponsors",[3]="Custom Design",[4]="Retro",[5]="Luxury",[6]="Carbon",[7]="Gold",[8]="Diamond",[9]="Chrome",[10]="Race"},
    [49]={[0]="None",[1]="LED Lighting",[2]="Premium Seats",[3]="Sound System",[4]="Mini Fridge",[5]="Bar",[6]="Safe",[7]="Weapon Storage",[8]="Luxury Interior",[9]="Carbon Details",[10]="Gold Accents"},
}

Config.ColorCategories = {
    {name='Classic',   icon='circle', range={0,   11 }},
    {name='Matte',     icon='circle', range={12,  23 }},
    {name='Metallic',  icon='circle', range={24,  54 }},
    {name='Utility',   icon='circle', range={55,  94 }},
    {name='Worn',      icon='circle', range={95,  124}},
    {name='Special',   icon='circle', range={125, 159}},
    {name='Chrome',    icon='circle', range={160, 165}},
}

Config.NeonColors = {
    {name='White',        r=255,g=255,b=255},
    {name='Blue',         r=0,  g=0,  b=255},
    {name='Electric Blue',r=2,  g=21, b=255},
    {name='Mint Green',   r=50, g=255,b=155},
    {name='Lime Green',   r=0,  g=255,b=0  },
    {name='Yellow',       r=255,g=255,b=0  },
    {name='Golden',       r=204,g=204,b=0  },
    {name='Orange',       r=255,g=128,b=0  },
    {name='Red',          r=255,g=0,  b=0  },
    {name='Pink',         r=255,g=102,b=255},
    {name='Hot Pink',     r=255,g=0,  b=255},
    {name='Purple',       r=128,g=0,  b=128},
    {name='Blacklight',   r=153,g=0,  b=255},
    {name='Ice Blue',     r=102,g=255,b=255},
}

Config.VehicleProperties = {
    useOxVehicle = true,
    autoSave     = true,
    events = {
        repair = 'ox:vehicleRepaired',
        mod    = 'ox:vehicleModded',
        color  = 'ox:vehicleColored',
    },
}

-- ============================================
-- 📸 TUNING CAMERA
-- Läuft während das Tuning-Menü offen ist.
-- Die Kamera kreist langsam ums Auto, Maus bleibt frei fürs Menü.
-- ============================================
Config.TuningCamera = {
    enabled       = true,    -- false = komplett deaktiviert, normale Gameplay-Kamera bleibt

    -- Abstand vom Fahrzeugmittelpunkt (Meter)
    radius        = 7.0,

    -- Höhe über dem Fahrzeugmittelpunkt (Meter)
    -- 1.5 = leicht erhöht, gutes Seitenprofil sichtbar
    height        = 1.8,

    -- Sichtfeld (Field of View) in Grad
    -- Kleiner = mehr Zoom, größer = mehr Übersicht
    fov           = 55.0,

    -- Rotationsgeschwindigkeit in Grad pro Sekunde
    -- Positiv = gegen den Uhrzeigersinn (von oben gesehen), Negativ = andersrum
    degreesPerSec = 18.0,

    -- Startwinkel in Grad (0 = hinter dem Auto, 90 = linke Seite, 180 = vor dem Auto)
    startAngle    = 160.0,

    -- Interpolations-Dauer beim Ein-/Ausblenden in Millisekunden
    fadeInMs      = 800,
    fadeOutMs     = 600,
}


Config.StateBags = {
    vehicleRepairing = 'rde:repairing',    -- int (playerId) or false
    vehicleTuner     = 'rde:tuner',        -- int (playerId) or false
    playerBusy       = 'rde:busy',         -- bool
    previewMod       = 'rde:preview',      -- NEW: preview data table or false
    mechanicStatus   = 'rde:mech_status',  -- NEW: GlobalState key for repair phase sync
}

Config.NostrLog = {
    enabled            = true,
    logPurchases       = true,
    logRepairs         = true,
    logAdminCreate     = true,
    logAdminDelete     = true,
    expensiveThreshold = 5000,
    serverTag          = 'rde_mechanic',
}
