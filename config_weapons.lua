
WeaponsConfig = WeaponsConfig or {}

WeaponsConfig.ReloadTime = math.random(4000, 6000)
WeaponsConfig.DurabilityBlockedWeapons = {
    'weapon_stungun', 'weapon_nightstick', 'weapon_flashlight', 'weapon_unarmed',
}
WeaponsConfig.AmmoTypes = {
    pistol_ammo  = { ammoType = 'AMMO_PISTOL', amount = 30 },
    rifle_ammo   = { ammoType = 'AMMO_RIFLE', amount = 200 },
    smg_ammo     = { ammoType = 'AMMO_SMG', amount = 30 },
    shotgun_ammo = { ammoType = 'AMMO_SHOTGUN', amount = 10 },
    mg_ammo      = { ammoType = 'AMMO_MG', amount = 30 },
    snp_ammo     = { ammoType = 'AMMO_SNIPER', amount = 10 },
    emp_ammo     = { ammoType = 'AMMO_EMPLAUNCHER', amount = 10 },
}
-- ESX fallback: weapon name (lowercase) -> ammo type when DEVIX.GetSharedWeapon returns nil
WeaponsConfig.WeaponAmmoType = WeaponsConfig.WeaponAmmoType or {
    -- AMMO_PISTOL
    weapon_pistol = "AMMO_PISTOL", weapon_pistol_mk2 = "AMMO_PISTOL", weapon_combatpistol = "AMMO_PISTOL",
    weapon_appistol = "AMMO_PISTOL", weapon_pistol50 = "AMMO_PISTOL", weapon_snspistol = "AMMO_PISTOL",
    weapon_heavypistol = "AMMO_PISTOL", weapon_vintagepistol = "AMMO_PISTOL", weapon_revolver = "AMMO_PISTOL",
    weapon_doubleaction = "AMMO_PISTOL", weapon_ceramicpistol = "AMMO_PISTOL", weapon_navyrevolver = "AMMO_PISTOL",
    weapon_gadgetpistol = "AMMO_PISTOL",
    -- AMMO_SMG
    weapon_microsmg = "AMMO_SMG", weapon_smg = "AMMO_SMG", weapon_smg_mk2 = "AMMO_SMG",
    weapon_assaultsmg = "AMMO_SMG", weapon_combatpdw = "AMMO_SMG", weapon_machinepistol = "AMMO_SMG",
    weapon_minismg = "AMMO_SMG",
    -- AMMO_RIFLE
    weapon_assaultrifle = "AMMO_RIFLE", weapon_assaultrifle_mk2 = "AMMO_RIFLE", weapon_carbinerifle = "AMMO_RIFLE",
    weapon_carbinerifle_mk2 = "AMMO_RIFLE", weapon_advancedrifle = "AMMO_RIFLE", weapon_specialcarbine = "AMMO_RIFLE",
    weapon_specialcarbine_mk2 = "AMMO_RIFLE", weapon_bullpuprifle = "AMMO_RIFLE", weapon_bullpuprifle_mk2 = "AMMO_RIFLE",
    weapon_compactrifle = "AMMO_RIFLE", weapon_militaryrifle = "AMMO_RIFLE", weapon_heavyrifle = "AMMO_RIFLE",
    weapon_tacticalrifle = "AMMO_RIFLE",
    -- AMMO_SHOTGUN
    weapon_pumpshotgun = "AMMO_SHOTGUN", weapon_sawnoffshotgun = "AMMO_SHOTGUN", weapon_assaultshotgun = "AMMO_SHOTGUN",
    weapon_bullpupshotgun = "AMMO_SHOTGUN", weapon_heavyshotgun = "AMMO_SHOTGUN", weapon_dbshotgun = "AMMO_SHOTGUN",
    weapon_autoshotgun = "AMMO_SHOTGUN", weapon_pumpshotgun_mk2 = "AMMO_SHOTGUN", weapon_combatshotgun = "AMMO_SHOTGUN",
    -- AMMO_MG
    weapon_mg = "AMMO_MG", weapon_combatmg = "AMMO_MG", weapon_combatmg_mk2 = "AMMO_MG",
    weapon_gusenberg = "AMMO_MG", weapon_minigun = "AMMO_MG",
    -- AMMO_SNIPER
    weapon_sniperrifle = "AMMO_SNIPER", weapon_heavysniper = "AMMO_SNIPER", weapon_heavysniper_mk2 = "AMMO_SNIPER",
    weapon_marksmanrifle = "AMMO_SNIPER", weapon_marksmanrifle_mk2 = "AMMO_SNIPER", weapon_precisionrifle = "AMMO_SNIPER",
}
WeaponsConfig.Throwables = {
    'ball', 'bzgas', 'flare', 'grenade', 'molotov', 'pipebomb', 'proxmine',
    'smokegrenade', 'snowball', 'stickybomb',
}
WeaponsConfig.WeapDraw = {
    variants = { 130, 122, 3, 6, 8 },
    weapons = {
        'WEAPON_PISTOL', 'WEAPON_PISTOL_MK2', 'WEAPON_COMBATPISTOL', 'WEAPON_APPISTOL',
        'WEAPON_PISTOL50', 'WEAPON_REVOLVER', 'WEAPON_SNSPISTOL', 'WEAPON_HEAVYPISTOL', 'WEAPON_VINTAGEPISTOL',
    },
}
-- Repair item: when used, repairs the weapon in hand (durability/quality 100). If no weapon in hand or already 100, item is not consumed. Broken weapon can be equipped (cannot shoot) then use this item to repair.
WeaponsConfig.RepairItem = "repairkit"
-- Durability points subtracted per shot (0–100). Value is used as-is: 0.01 = 0.01 per shot (~10000 shots 100→0), 0.15 = 0.15 per shot (~666 shots). Weapons not in list use 0.15.
WeaponsConfig.DurabilityMultiplier = {
    weapon_pistol = 0.15, weapon_combatpistol = 0.15, weapon_appistol = 0.15,
    weapon_smg = 0.15, weapon_microsmg = 0.15, weapon_assaultrifle = 10.0,
    weapon_carbinerifle = 0.15, weapon_pumpshotgun = 0.15, weapon_sniperrifle = 0.15,
    weapon_mg = 0.15, weapon_combatmg = 0.15, weapon_marksmanrifle = 0.15,
    weapon_heavysniper = 0.15, weapon_rpg = 0.15, weapon_grenadelauncher = 0.15,
    weapon_minigun = 0.15, weapon_knife = 0.15, weapon_bat = 0.15, weapon_pistol50 = 0.15,
}
-- Attachment list. Pistol suppressor: inventory must have "suppressor_attachment" item; component matches (COMPONENT_AT_PI_SUPP_02).
-- Most slots: weapon_assaultrifle / weapon_carbinerifle (scope, magazine, barrel supp/flash, grip = 4 slots).
WeaponsConfig.WeaponAttachments = WeaponsConfig.WeaponAttachments or {
    clip_attachment = {
        weapon_pistol = `COMPONENT_PISTOL_CLIP_02`, weapon_combatpistol = `COMPONENT_COMBATPISTOL_CLIP_02`,
        weapon_appistol = `COMPONENT_APPISTOL_CLIP_02`, weapon_smg = `COMPONENT_SMG_CLIP_02`,
        weapon_assaultrifle = `COMPONENT_ASSAULTRIFLE_CLIP_02`, weapon_carbinerifle = `COMPONENT_CARBINERIFLE_CLIP_02`,
    },
    suppressor_attachment = {
        weapon_pistol = `COMPONENT_AT_PI_SUPP_02`, weapon_combatpistol = `COMPONENT_AT_PI_SUPP`,
        weapon_appistol = `COMPONENT_AT_PI_SUPP`, weapon_smg = `COMPONENT_AT_PI_SUPP`,
        weapon_assaultrifle = `COMPONENT_AT_AR_SUPP_02`, weapon_carbinerifle = `COMPONENT_AT_AR_SUPP_02`,
    },
    flashlight_attachment = {
        weapon_pistol = `COMPONENT_AT_PI_FLSH`, weapon_combatpistol = `COMPONENT_AT_PI_FLSH`,
        weapon_smg = `COMPONENT_AT_AR_FLSH`, weapon_assaultrifle = `COMPONENT_AT_AR_FLSH`,
        weapon_carbinerifle = `COMPONENT_AT_AR_FLSH`,
    },
    holoscope_attachment = {
        weapon_assaultrifle = `COMPONENT_AT_SCOPE_MACRO`, weapon_carbinerifle = `COMPONENT_AT_SCOPE_MEDIUM`,
    },
    grip_attachment = {
        weapon_assaultrifle = `COMPONENT_AT_AR_AFGRIP`, weapon_carbinerifle = `COMPONENT_AT_AR_AFGRIP`,
    },
}

-- Tint: parça menüsünde slot olarak (diğer attachment'lar gibi) konuma bağlı gösterilir. Item tüketilmez; silah info.tint olarak kaydedilir.
WeaponsConfig.WeaponTintIndices = WeaponsConfig.WeaponTintIndices or { 0, 1, 2, 3, 4, 5, 6, 7 }
-- MK2 silahlar için tint indeksleri (qb-core weapontint_mk2_0 .. weapontint_mk2_32)
WeaponsConfig.WeaponTintIndicesMk2 = WeaponsConfig.WeaponTintIndicesMk2 or (function()
    local t = {}
    for i = 0, 32 do t[#t + 1] = i end
    return t
end)()

-- UI slot groups: which part goes to which arm in cross menu (scope=top, magazine=bottom, barrel=left, grip=right)
WeaponsConfig.WeaponAttachmentSlots = WeaponsConfig.WeaponAttachmentSlots or {
    scope = {
        "smallscope_attachment", "medscope_attachment", "largescope_attachment",
        "holoscope_attachment", "advscope_attachment", "nvscope_attachment", "thermalscope_attachment",
    },
    magazine = {
        "clip_attachment", "drum_attachment",
    },
    barrel = {
        "suppressor_attachment", "comp_attachment", "barrel_attachment",
        "flat_muzzle_brake", "tactical_muzzle_brake", "fat_end_muzzle_brake", "precision_muzzle_brake",
        "heavy_duty_muzzle_brake", "slanted_muzzle_brake", "split_end_muzzle_brake", "squared_muzzle_brake", "bellend_muzzle_brake",
    },
    flash = {
        "flashlight_attachment",
    },
    -- Grip: only grip_attachment can be equipped (carbinerifle / assaultrifle etc.)
    grip = {
        "grip_attachment",
    },
}

-- 3D parts menu: left-click pan sensitivity (same speed as mouse; increase to speed up).
WeaponsConfig.WeaponAttachmentPanSensitivity = WeaponsConfig.WeaponAttachmentPanSensitivity or 0.0006

-- 3D parts menu: scroll = object distance from screen (negative = back, positive = forward). Min/Max limits.
WeaponsConfig.WeaponAttachmentDepthMin = WeaponsConfig.WeaponAttachmentDepthMin or -0.35
WeaponsConfig.WeaponAttachmentDepthMax = WeaponsConfig.WeaponAttachmentDepthMax or 0.75

-- 3D parts menu: ammo count for CreateWeaponObject (0 can fail on some builds; use 1 or 120).
WeaponsConfig.WeaponAttachmentPreviewAmmo = WeaponsConfig.WeaponAttachmentPreviewAmmo or 1

-- 3D parts menu: UI sticks to weapon bones; does not separate from weapon. Uses offset if bone missing.
-- Value: number = bone index (0 = root), string = bone name (e.g. "wpn_scope"). Empty/nil = use offset.
WeaponsConfig.WeaponAttachmentSlotBones = WeaponsConfig.WeaponAttachmentSlotBones or {
    scope    = "",   -- empty = use WeaponAttachmentSlotOffsets
    magazine = "",
    barrel   = "",
    grip     = "",
    tint     = "",
    flash    = "",
}
-- Offset (when bone missing or invalid): entity offset X=right, Y=forward, Z=up
WeaponsConfig.WeaponAttachmentSlotOffsets = WeaponsConfig.WeaponAttachmentSlotOffsets or {
    scope    = { 0.0,  0.08,  0.12 },
    magazine = { 0.0,  0.0,  -0.12 },
    barrel   = { 0.0,  0.15,  0.0 },
    grip     = { 0.0, -0.12,  0.0 },
    tint     = { 0.0,  0.0,  -0.18 },
    -- Flashlight slot: slightly closer to weapon and a bit lower so barrel & flash don't overlap visually
    flash    = { 0.0,  0.10, -0.04 },
}
WeaponsConfig.WeaponWorldModels = WeaponsConfig.WeaponWorldModels or {
    weapon_pistol = "w_pi_pistol",
    weapon_pistol_mk2 = "w_pi_pistol_mk2",
    weapon_combatpistol = "w_pi_combatpistol",
    weapon_appistol = "w_pi_appistol",
    weapon_stungun = "w_pi_stungun",
    weapon_pistol50 = "w_pi_pistol50",
    weapon_snspistol = "w_pi_sns_pistol",
    weapon_heavypistol = "w_pi_heavypistol",
    weapon_vintagepistol = "w_pi_vintage_pistol",
    weapon_revolver = "w_pi_revolver",
    weapon_smg = "w_sb_smg",
    weapon_microsmg = "w_sb_microsmg",
    weapon_assaultrifle = "w_ar_assaultrifle",
    weapon_carbinerifle = "w_ar_carbinerifle",
    weapon_advancedrifle = "w_ar_advancedrifle",
    weapon_mg = "w_mg_mg",
    weapon_combatmg = "w_mg_combatmg",
    weapon_pumpshotgun = "w_sg_pumpshotgun",
    weapon_sawnoffshotgun = "w_sg_sawnoff",
    weapon_assaultshotgun = "w_sg_assaultshotgun",
    weapon_bullpupshotgun = "w_sg_bullpupshotgun",
    weapon_sniperrifle = "w_sr_sniperrifle",
    weapon_heavysniper = "w_sr_heavysniper",
    weapon_marksmanrifle = "w_sr_marksmanrifle",
    weapon_rpg = "w_lr_rpg",
    weapon_grenadelauncher = "w_lr_grenadelauncher",
    weapon_minigun = "w_mg_minigun",
    weapon_firework = "w_lr_firework",
    weapon_railgun = "w_ar_railgun",
    weapon_hominglauncher = "w_lr_homing",
    weapon_compactlauncher = "w_lr_compactgl",
    weapon_flaregun = "w_pi_flaregun",
    weapon_doubleaction = "w_pi_doubleaction",
    weapon_kacks1 = "w_pi_kacks1",
}

-- Weapon draw/holster animations (per-job + per-weapon).
-- Used in client/weapons.lua via local WC = WeaponsConfig or {}.
-- Jobs considered "police" for animation profile:
WeaponsConfig.WeaponPoliceJobs = WeaponsConfig.WeaponPoliceJobs or {
    "police",
    "sheriff",
}

-- Default animation profiles; per-weapon overrides can be added:
--   WeaponsConfig.Weapons["weapon_pistol"] = {
--       civilian = {
--           draw    = { dict = "reaction@intimidation@1h", anim = "intro",  durationMs = 900 },
--           holster = { dict = "reaction@intimidation@1h", anim = "outro", durationMs = 1200 },
--       },
--       police = {
--           draw    = { dict = "reaction@intimidation@1h", anim = "intro",  durationMs = 800 },
--           holster = { dict = "reaction@intimidation@1h", anim = "outro", durationMs = 1100 },
--       },
--   }
WeaponsConfig.Weapons = WeaponsConfig.Weapons or {}
WeaponsConfig.Weapons.default = WeaponsConfig.Weapons.default or {
    civilian = {
        draw = {
            dict = "reaction@intimidation@1h",
            anim = "intro",
            durationMs = 1000,
        },
        holster = {
            dict = "reaction@intimidation@1h",
            anim = "outro",
            durationMs = 1400,
        },
    },
    police = {
        draw = {
            dict = "reaction@intimidation@1h",
            anim = "intro",
            durationMs = 1000,
        },
        holster = {
            dict = "reaction@intimidation@1h",
            anim = "outro",
            durationMs = 1400,
        },
    },
}

-- Example per-weapon override for pistol (can be edited freely)
WeaponsConfig.Weapons["weapon_pistol"] = WeaponsConfig.Weapons["weapon_pistol"] or {
    civilian = {
        draw    = { dict = "reaction@intimidation@1h", anim = "intro",  durationMs = 900 },
        holster = { dict = "reaction@intimidation@1h", anim = "outro", durationMs = 1200 },
    },
    police = {
        draw    = { dict = "reaction@intimidation@1h", anim = "intro",  durationMs = 800 },
        holster = { dict = "reaction@intimidation@1h", anim = "outro", durationMs = 1100 },
    },
}

-- Weapon durability + jam settings (shared with server/main.lua and client/weapons.lua via Config bridge).
WeaponsConfig.WeaponDurability = (WeaponsConfig.WeaponDurability ~= nil) and WeaponsConfig.WeaponDurability or true
WeaponsConfig.WeaponJam = WeaponsConfig.WeaponJam or {
    Enabled = true,
    Threshold = 30,       -- Jam chance activates for weapons below this percent
    Chance = 0.20,        -- 0.0–1.0 range; 0.20 = 20%
    JamDurationMs = 1500, -- Duration (ms) during which weapon cannot fire on jam
}
