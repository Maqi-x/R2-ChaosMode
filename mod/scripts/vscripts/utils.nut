globalize_all_functions

PilotState function RandPilotLoadout() {
    PilotState loadout;
    loadout.primary = pilotWeapons[ RandomInt( pilotWeapons.len() ) ];
    loadout.offhand = pilotOrdnances[ RandomInt( pilotOrdnances.len() ) ];
    loadout.ability = pilotAbilities[ RandomInt( pilotAbilities.len() ) ];
    loadout.abilityActive = false;
    loadout.isSprinting = false;
    return loadout;
}

TitanState function RandTitanLoadout() {
    TitanState loadout;
    loadout.primary = titanWeapons[ RandomInt( titanWeapons.len() ) ];
    loadout.offensive    = titanOffensives[ RandomInt( titanOffensives.len() ) ];
    loadout.defensive    = titanDefensives[ RandomInt( titanDefensives.len() ) ];
    loadout.tactical     = titanTacticals[ RandomInt( titanTacticals.len() ) ];
    loadout.coreMeter = 0.0;
    loadout.coreActive = false;
    loadout.coreExpireTime = 0.0;
    return loadout;
}

bool function IsSmartAmmoWeapon( string weapon ) {
    // maybe there is some more accurate way to check it but this seems to work
    return weapon == "mp_titanweapon_predator_cannon"
        || weapon == "mp_titanweapon_shoulder_rockets";
}

array<string> function GetAllTitanWeapons( entity titan ) {
    array<string> result;

    foreach ( entity weapon in titan.GetMainWeapons() )
        if ( IsValid( weapon ) )
            result.push(weapon.GetWeaponClassName());

    foreach ( int slot in TITAN_OFFHAND_SLOTS ) {
        entity weapon = titan.GetOffhandWeapon( slot );
        if ( IsValid( weapon ) ) result.push( weapon.GetWeaponClassName() );
    }

    entity melee = titan.GetMeleeWeapon();
    if ( IsValid( melee ) )
        result.push( melee.GetWeaponClassName() );

    return result;
}

bool function HasAnySmartAmmoWeapons( entity titan ) {
    array<string> weapons = GetAllTitanWeapons( titan );

    foreach ( string weapon in weapons )
        if ( IsSmartAmmoWeapon( weapon ) )
            return true;

    return false;
}

string function GetRandomModFor( string weapon ) {
    Assert( weapon in weaponMods );

    array<string> mods = weaponMods[ weapon ];
    Assert( mods.len() > 0 );

    return mods[ RandomInt( mods.len() ) ];
}

array<string> function GetRandomModsFor( string weapon ) {
    // no mods available
    if ( !( weapon in weaponMods ) )
        return [];
    if ( weaponMods[ weapon ].len() == 0 )
        return [];

    // 30% no mods
    if ( RandomInt(10) < 3 )
        return [];

    // 80% (excluding the no mods case) one mod
    if ( RandomInt(10) < 8 )
        return [ GetRandomModFor( weapon ) ];

    // only one mod is available
    if ( weaponMods[ weapon ].len() == 1 )
        return [ GetRandomModFor( weapon ) ];

    // 20% (excluding the no mods case) two mods
    return [ GetRandomModFor( weapon ), GetRandomModFor( weapon ) ];
}

void function SetRandomMods( entity weapon ) {
    array<string> mods = GetRandomModsFor( weapon.GetWeaponClassName() );
    //print("Giving mods:");
    //print("-----------------------------");
    //foreach ( mod in mods ) printt( "Mod: ", mod );
    //print("-----------------------------");
    weapon.SetMods( mods );
}

string function GetRandomDistinctItem( array<string> pool, string currentItem ) {
    if ( pool.len() <= 1 ) return pool.getrandom();

    string chosen;
    do {
        chosen = pool[ RandomInt( pool.len() ) ];
    } while ( chosen == currentItem );

    return chosen;
}

// when titan ai has two smart ammo weapons at the same time the game crashes
string function GetRandomTitanWeapon_SmartAmmoAware( entity titan, array<string> pool, string currentItem ) {
    if ( ! HasAnySmartAmmoWeapons( titan ) )
        return GetRandomDistinctItem( pool, currentItem );

    string chosen;
    do {
        chosen = GetRandomDistinctItem( pool, currentItem );
    } while ( IsSmartAmmoWeapon( chosen ) );

    return chosen;
}

void function GiveRandomPilotWeapon( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;
    //print( "GiveRandomWeapon() called" );

    foreach ( entity weapon in player.GetMainWeapons() )
        if ( weapon.GetWeaponClassName() != "sp_weapon_arc_tool" )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosenWeapon = GetRandomDistinctItem( pilotWeapons, pilotStates[player].primary );
    pilotStates[player].primary = chosenWeapon;

    player.GiveWeapon( pilotStates[player].primary );

    entity active = player.GetActiveWeapon();
    if ( !IsValid( active ) || active.GetWeaponClassName() != "sp_weapon_arc_tool" )
        player.SetActiveWeaponByName( pilotStates[player].primary );

    active = player.GetActiveWeapon();
    Assert( active.GetWeaponClassName() == chosen );
    SetRandomMods( active );
}

void function GiveRandomPilotGrenade( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;

    if ( IsValid( player.GetOffhandWeapon(PILOT_ORDNANCE) ) )
        player.TakeWeaponNow( player.GetOffhandWeapon(PILOT_ORDNANCE).GetWeaponClassName() );

    string chosenOrd = GetRandomDistinctItem( pilotOrdnances, pilotStates[player].offhand );
    pilotStates[player].offhand = chosenOrd;
    player.GiveOffhandWeapon( chosenOrd, PILOT_ORDNANCE, [] );
}

void function GiveRandomPilotAbility( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;

    if ( IsValid( player.GetOffhandWeapon(PILOT_ABILITY) ) )
        if ( player.GetOffhandWeapon(PILOT_ABILITY).GetWeaponClassName() != "mp_ability_timeshift" )
            player.TakeWeaponNow( player.GetOffhandWeapon(PILOT_ABILITY).GetWeaponClassName() );

    string chosenAbility = GetRandomDistinctItem( pilotAbilities, pilotStates[player].ability );
    pilotStates[player].ability = chosenAbility;
    player.GiveOffhandWeapon( chosenAbility, PILOT_ABILITY, [] );
}

void function GiveRandomPilotMelee( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;

    if ( IsValid( player.GetMeleeWeapon() ) )
        player.TakeWeaponNow( player.GetMeleeWeapon().GetWeaponClassName() );

    string chosenMelee = GetRandomDistinctItem( pilotMelees, pilotStates[player].melee );
    pilotStates[player].melee = chosenMelee;
    player.GiveOffhandWeapon( chosenMelee, OFFHAND_MELEE, [] );
}

void function GiveRandomTitanLoadout( entity titan ) {
    GiveRandomTitanWeapon   ( titan );
    GiveRandomTitanOffensive( titan );
    GiveRandomTitanDefensive( titan );
    GiveRandomTitanTactical ( titan );
}

void function GiveRandomTitanWeapon( entity titan ) {
    if ( !IsValid( titan ) || !titan.IsTitan() ) return;

    foreach ( entity weapon in titan.GetMainWeapons() )
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosen = GetRandomTitanWeapon_SmartAmmoAware( titan, titanWeapons, titanStates[titan].primary );
    titanStates[titan].primary = chosen;
    titan.GiveWeapon( chosen );
    titan.SetActiveWeaponByName( chosen );

    entity active = titan.GetActiveWeapon();
    Assert( active.GetWeaponClassName() == chosen );
    SetRandomMods( active );
}

void function GiveRandomTitanOffhand( entity titan, int slot, array<string> weaponList, string curr ) {
    if ( !IsValid( titan ) || !titan.IsTitan() ) return;

    entity offWeapon = titan.GetOffhandWeapon( slot );
    if ( IsValid( offWeapon ) )
        titan.TakeWeaponNow( offWeapon.GetWeaponClassName() );

    string chosen = GetRandomTitanWeapon_SmartAmmoAware( titan, weaponList, curr );
    switch ( slot ) {
    case TITAN_OFFENSIVE: titanStates[titan].offensive = chosen; break;
    case TITAN_DEFENSIVE: titanStates[titan].defensive = chosen; break;
    case TITAN_TACTICAL:  titanStates[titan].tactical = chosen;  break;
    }

    titan.GiveOffhandWeapon( chosen, slot, [] );
}

void function GiveRandomTitanOffensive( entity titan ) {
    GiveRandomTitanOffhand( titan, TITAN_OFFENSIVE, titanOffensives, titanStates[titan].offensive );
}
void function GiveRandomTitanDefensive( entity titan ) {
    entity current = titan.GetOffhandWeapon( TITAN_DEFENSIVE );
    if ( IsValid( current ) && current.GetWeaponClassName() == "mp_titanability_timeshift" )
        return;

    GiveRandomTitanOffhand( titan, TITAN_DEFENSIVE, titanDefensives, titanStates[titan].defensive );
}
void function GiveRandomTitanTactical( entity titan ) {
    GiveRandomTitanOffhand( titan, TITAN_TACTICAL, titanTacticals, titanStates[titan].tactical );
}
