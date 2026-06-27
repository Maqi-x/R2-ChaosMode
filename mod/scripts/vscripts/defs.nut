global struct PilotState {
    string primary // one of pilotWeapons
    string offhand // one of pilotOrdnances
}
global struct TitanState {
    string primary
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

global array<string> pilotWeapons = [
    // ar
    "mp_weapon_rspn101",
    "mp_weapon_vinson",
    "mp_weapon_g2",
    "mp_weapon_hemlok",
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

global array<string> titanWeapons = [
    "mp_titanweapon_xo16_shorty",
    "mp_titanweapon_sticky_40mm",
    "mp_titanweapon_rocketeer_rocketstream",
    "mp_titanweapon_meteor",
    "mp_titanweapon_particle_accelerator",
    "mp_titanweapon_leadwall",
    "mp_titanweapon_predator_cannon",
];