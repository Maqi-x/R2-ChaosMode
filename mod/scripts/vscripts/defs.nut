global struct PilotState {
    string primary // one of pilotWeapons
    string offhand // one of pilotOrdnances
    string melee
    string ability
    bool abilityActive
    bool isSprinting
}
global struct TitanState {
    string primary
    string offensive
    string defensive
    string tactical
    float coreMeter
    bool  coreActive
    float coreExpireTime
    // TODO: offensive, defensive and tactical abilities
}

global table<entity, PilotState> pilotStates;
global table<entity, TitanState> titanStates;

global const int TITAN_OFFENSIVE = 0;
global const int TITAN_DEFENSIVE = 1;
global const int TITAN_TACTICAL  = 2;
global const int TITAN_CORE      = 3;

global const int PILOT_ORDNANCE = 0;
global const int PILOT_ABILITY  = 1;
global const int PILOT_MELEE    = 5;

global array<string> pilotWeapons = [
    // ar
    "mp_weapon_rspn101",
    "mp_weapon_vinson",
    "mp_weapon_g2",
    //"mp_weapon_hemlok", // idk why, but it crashes the game
    // smg
    "mp_weapon_r97",
    "mp_weapon_car",
    "mp_weapon_hemlok_smg",
    "mp_weapon_alternator_smg",
    // lmg
    "mp_weapon_lmg",
    "mp_weapon_lstar",
    "mp_weapon_esaw",
    //s niper
    "mp_weapon_sniper",
    "mp_weapon_doubletake",
    "mp_weapon_dmr",
    // explosive
    "mp_weapon_epg",
    "mp_weapon_pulse_lmg",
    "mp_weapon_softball",
    "mp_weapon_smr",
    // shotguns
    "mp_weapon_shotgun",
    "mp_weapon_mastiff",
    //"mp_weapon_peacekraber",
    // ???
    "mp_weapon_arc_launcher",
    // pistols
    "mp_weapon_wingman",
    "mp_weapon_wingman_n",
    "mp_weapon_shotgun_pistol",
    "mp_weapon_semipistol",
    "mp_weapon_autopistol",
]

global array<string> pilotOrdnances = [
    "mp_weapon_frag_grenade",
    "mp_weapon_thermite_grenade",
    "mp_weapon_grenade_gravity",
    "mp_weapon_grenade_emp",
    "mp_weapon_grenade_electric_smoke",

    // these two are kinda broken
    //"mp_weapon_grenade_sonar",
    //"mp_weapon_satchel",
];

global array<string> pilotAbilities = [
    "mp_ability_cloak",
    "mp_ability_heal",
    //"mp_ability_grapple",
    "mp_ability_shifter",
    //"mp_ability_holopilot",
];

global array<string> pilotMelees = [
    "melee_pilot_arena",
    "melee_pilot_emptyhanded",
    "melee_pilot_sword",
];

global array<string> titanWeapons = [
    "mp_titanweapon_xo16_shorty",
    "mp_titanweapon_sticky_40mm",
    "mp_titanweapon_rocketeer_rocketstream",
    "mp_titanweapon_meteor",
    "mp_titanweapon_particle_accelerator",
    "mp_titanweapon_leadwall",
    "mp_titanweapon_predator_cannon",
];

global array<string> titanOffensives = [
    "mp_titanweapon_laser_lite",
    "mp_titanweapon_flame_wall",
    "mp_titanweapon_shoulder_rockets",
    "mp_titanweapon_dumbfire_rockets",
    "mp_titanweapon_arc_wave",
    "mp_titanweapon_salvo_rockets"

    // crashes the game if current weapon isn't the predator cannon
    //"mp_titanability_power_shot",
    // useless if current loadout isnt tone
    //"mp_titanweapon_tracker_rockets",
];

global array<string> titanDefensives = [
    "mp_titanweapon_vortex_shield",
    "mp_titanweapon_heat_shield",
    "mp_titanability_tether_trap",
    "mp_titanability_basic_block",
    "mp_titanability_particle_wall",
    //"mp_titanability_gun_shield",
    "mp_titanweapon_stun_laser"
];

global array<string> titanTacticals = [
    "mp_titanability_laser_trip",
    "mp_titanability_slow_trap",
    "mp_titanability_hover",
    "mp_titanability_phase_dash",
    //"mp_titanability_ammo_swap",
    //"mp_titanability_rearm",
    "mp_titanability_electric_smoke",
];
