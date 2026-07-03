--[[
    Itemback: Shows inventory weapons/items as props on the player's back.
    Props are NOT removed on death or clothing reset; they disappear only when the item leaves inventory.
    Synced to other players via StateBag.

    POSITIONING HELP:
    Use tgiann-attachproptoplayereditor to find bone IDs and offsets visually:
    https://github.com/TGIANN/tgiann-attachproptoplayereditor
    Command: /prop <model> <boneID> [animDictionary] [animationName]
    Then copy the resulting x, y, z and x_rotation, y_rotation, z_rotation into BackItems below.
]]

Config.Itemback = Config.Itemback or {}
local C = Config.Itemback

C.Enabled = true
C.DefaultBackBone = 24818  -- spine2 (SKEL_Spine2). Common: 24818 spine2, 23553 ik_roots, 24817 spine1
C.DefaultOffset = { x = 0.0, y = -0.12, z = 0.08 }
C.DefaultRotation = { x = 0.0, y = -90.0, z = 0.0 }

-- Items to show on back: item name -> { model?, back_bone?, x, y, z, x_rotation, y_rotation, z_rotation }
-- For weapons: "model" is ignored (CreateWeaponObject + components + tint used). Only bone/offset/rotation apply.
-- Tip: Use tgiann-attachproptoplayereditor (/prop <model> <boneID>) to get exact values, then paste here.
C.BackItems = {
    ["weapon_assaultrifle"] = {
        back_bone = 24817,
        x = -0.14663731893245, y = -0.15214347614469, z = 0,
        x_rotation = 0.0, y_rotation = 0, z_rotation = 0,
    },
    ["pickaxe"] = {
        model = "prop_tool_pickaxe",
        back_bone = 24817,
        x = -0.34663731893245, y = -0.15214347614469, z = -0.09,
        x_rotation = 6.10335945038, y_rotation = 67.019758396717, z_rotation = -2.3882603902086,
    },
    ["weapon_assaultrifle_mk2"] = {
        back_bone = 24817,
        x = -0.14663731893245, y = -0.15214347614469, z = 0,
        x_rotation = 0.0, y_rotation = 0, z_rotation = 0,
    },
    ["repairkit"] = {
        model = "ch_prop_toolbox_01a",
        back_bone = 23553,
        x = -0.15, y = -0.2, z = 0.05,
        x_rotation = 0.0, y_rotation = -265.3, z_rotation = -4.6,
    },
    ["weapon_pistol"] = {
        back_bone = 23553,
        x = -0.11291546476646, y = 0.011921562445348, z = -0.21318421103931,
        x_rotation = 76.163541827244, y_rotation = -6.4030676225829, z_rotation = -179.59571965468,
    },
    ["medkit"] = {
        model = "prop_ld_health_pack",
        back_bone = 23553,
        x = -0.11821274010645, y = -0.1655190127547, z = -0.05762513088957,
        x_rotation = 6.10335945038, y_rotation = 67.019758396717, z_rotation = -2.3882603902086,
    },
}

-- Weapon world models (used only for non-weapon fallback; weapons use CreateWeaponObject)
C.WeaponModels = {
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
}

-- Attachment prop models for non-weapon back items (item name -> { model }).
-- Keys must match config_weapons.lua WeaponAttachments / WeaponAttachmentSlots.
-- Weapons use CreateWeaponObject + components, so this table is only for custom items that use world props.
C.WeaponAttachmentDisplay = {
    ["clip_attachment"]       = { model = "w_at_ar_extclip" },
    ["drum_attachment"]       = { model = "w_at_ar_extclip" },
    ["suppressor_attachment"] = { model = "w_at_ar_supp_02" },
    ["comp_attachment"]       = { model = "w_at_ar_supp_02" },
    ["barrel_attachment"]     = { model = "w_at_ar_supp_02" },
    ["flat_muzzle_brake"]     = { model = "w_at_ar_supp_02" },
    ["tactical_muzzle_brake"] = { model = "w_at_ar_supp_02" },
    ["fat_end_muzzle_brake"]  = { model = "w_at_ar_supp_02" },
    ["precision_muzzle_brake"] = { model = "w_at_ar_supp_02" },
    ["heavy_duty_muzzle_brake"] = { model = "w_at_ar_supp_02" },
    ["slanted_muzzle_brake"]  = { model = "w_at_ar_supp_02" },
    ["split_end_muzzle_brake"] = { model = "w_at_ar_supp_02" },
    ["squared_muzzle_brake"]  = { model = "w_at_ar_supp_02" },
    ["bellend_muzzle_brake"]  = { model = "w_at_ar_supp_02" },
    ["flashlight_attachment"] = { model = "w_at_ar_flsh" },
    ["smallscope_attachment"] = { model = "w_at_scope_small" },
    ["medscope_attachment"]   = { model = "w_at_scope_medium" },
    ["largescope_attachment"] = { model = "w_at_scope_large" },
    ["holoscope_attachment"]  = { model = "w_at_scope_small" },
    ["advscope_attachment"]   = { model = "w_at_scope_large" },
    ["nvscope_attachment"]    = { model = "w_at_scope_large" },
    ["thermalscope_attachment"] = { model = "w_at_scope_large" },
    ["grip_attachment"]       = { model = "w_at_ar_afgrip" },
}
