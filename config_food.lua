-- Edible / drinkable items. Durability is only used for items defined here.
-- On E (EatAndDrink) key press, quickslot 1 item is used; item appears as prop in hand and stays until animation ends.
FoodConfig = {}

-- Food: item name -> { durabilityDecrease, hunger, anim, prop, duration, propOffset, propRot }
-- durabilityDecrease: amount deducted from durability per use (E) (0-100)
-- hunger: how much hunger is restored
-- anim: { dict = "anim_dict", name = "anim_name" }
-- prop: model name shown in hand (nil = no prop, animation only)
-- duration: animation duration (ms), default 3000 if nil
-- propOffset: position on left hand { x, y, z } (forward, right, up)
-- propRot: rotation in hand { pitch, roll, yaw } (degrees)
FoodConfig.Food = {
    ["sandwich"] = {
        durabilityDecrease = 25,
        hunger = 15,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_cs_burger_01",
        duration = 4500,
        propOffset = { 0.13, 0.05, 0.02 },
        propRot = { -60.0, 0.0, 0.0 },
    },
    ["burger"] = {
        durabilityDecrease = 20,
        hunger = 18,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_cs_burger_01",
        duration = 4500,
        propOffset = { 0.13, 0.04, 0.02 },
        propRot = { -58.0, 0.0, 2.0 },
    },
    ["hamburger"] = {
        durabilityDecrease = 22,
        hunger = 20,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_food_bs_burger1",
        duration = 4500,
        propOffset = { 0.12, 0.045, 0.01 },
        propRot = { -55.0, 0.0, 0.0 },
    },
    ["donut"] = {
        durabilityDecrease = 50,
        hunger = 10,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_amb_donut",
        duration = 3000,
        propOffset = { 0.06, 0.04, 0.02 },
        propRot = { -45.0, 0.0, 0.0 },
    },
    ["taco"] = {
        durabilityDecrease = 33,
        hunger = 14,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_taco_01",
        duration = 4000,
        propOffset = { 0.10, 0.04, 0.02 },
        propRot = { -50.0, 0.0, 5.0 },
    },
    ["hotdog"] = {
        durabilityDecrease = 25,
        hunger = 16,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_food_hotdog01",
        duration = 4200,
        propOffset = { 0.11, 0.035, 0.01 },
        propRot = { -52.0, 0.0, 0.0 },
    },
    ["pizza"] = {
        durabilityDecrease = 15,
        hunger = 12,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_food_pizza",
        duration = 3500,
        propOffset = { 0.12, 0.05, 0.00 },
        propRot = { -48.0, 0.0, 0.0 },
    },
    ["chips"] = {
        durabilityDecrease = 20,
        hunger = 8,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_food_bs_chips",
        duration = 3000,
        propOffset = { 0.08, 0.03, 0.02 },
        propRot = { -40.0, 0.0, 0.0 },
    },
    ["candy"] = {
        durabilityDecrease = 33,
        hunger = 5,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_candy_pqs",
        duration = 2500,
        propOffset = { 0.06, 0.03, 0.02 },
        propRot = { -42.0, 0.0, 0.0 },
    },
    ["bread"] = {
        durabilityDecrease = 20,
        hunger = 12,
        anim = { dict = "mp_player_inteat@burger", name = "mp_player_int_eat_burger" },
        prop = "prop_cs_burger_01",
        duration = 4000,
        propOffset = { 0.12, 0.04, 0.01 },
        propRot = { -50.0, 0.0, 0.0 },
    },
}

-- Water / drinks (left hand; propRot set so bottle sits in hand for sip)
FoodConfig.Water = {
    ["water_bottle"] = {
        durabilityDecrease = 33,
        thirst = 20,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_ld_flow_bottle",
        duration = 2500,
        propOffset = { 0.03, 0.03, 0.02 },
        propRot = { 0.0, 0.0, -130.0 },
    },
    ["water"] = {
        durabilityDecrease = 33,
        thirst = 22,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_ld_flow_bottle",
        duration = 2500,
        propOffset = { 0.03, 0.03, 0.02 },
        propRot = { 0.0, 0.0, -130.0 },
    },
    ["ecola"] = {
        durabilityDecrease = 25,
        thirst = 18,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_ecola_can",
        duration = 2200,
        propOffset = { 0.02, 0.02, 0.01 },
        propRot = { 0.0, 0.0, -125.0 },
    },
    ["sprunk"] = {
        durabilityDecrease = 25,
        thirst = 18,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_ld_can_01",
        duration = 2200,
        propOffset = { 0.025, 0.02, 0.01 },
        propRot = { 0.0, 0.0, -128.0 },
    },
    ["coffee"] = {
        durabilityDecrease = 20,
        thirst = 15,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_food_bs_coffee",
        duration = 2800,
        propOffset = { 0.04, 0.02, 0.01 },
        propRot = { 0.0, 0.0, -120.0 },
    },
    ["juice"] = {
        durabilityDecrease = 25,
        thirst = 16,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_food_juice01",
        duration = 2400,
        propOffset = { 0.03, 0.025, 0.02 },
        propRot = { 0.0, 0.0, -132.0 },
    },
    ["energy_drink"] = {
        durabilityDecrease = 33,
        thirst = 20,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_energy_drink",
        duration = 2600,
        propOffset = { 0.025, 0.02, 0.01 },
        propRot = { 0.0, 0.0, -126.0 },
    },
    ["beer"] = {
        durabilityDecrease = 20,
        thirst = 12,
        anim = { dict = "mp_player_intdrink", name = "loop_bottle" },
        prop = "prop_amb_beer_bottle",
        duration = 2500,
        propOffset = { 0.04, 0.02, 0.00 },
        propRot = { 0.0, 0.0, -128.0 },
    },
}
