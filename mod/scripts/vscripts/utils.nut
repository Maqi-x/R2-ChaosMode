globalize_all_functions

PilotState function RandPilotLoadout() {
    PilotState loadout;
    loadout.primary = pilotWeapons[ RandomInt( pilotWeapons.len() ) ];
    loadout.offhand = pilotOrdnances[ RandomInt( pilotOrdnances.len() ) ];
    loadout.ability = pilotAbilities[ RandomInt( pilotAbilities.len() ) ];
    return loadout;
}

TitanState function RandTitanLoadout() {
    TitanState loadout;
    loadout.primary = titanWeapons[ RandomInt( titanWeapons.len() ) ];
    return loadout;
}

string function GetRandomDistinctItem( array<string> pool, string currentItem ) {
    if ( pool.len() <= 1 ) return pool.getrandom();

    string chosen;
    do {
        chosen = pool[ RandomInt( pool.len() ) ];
    } while ( chosen == currentItem );

    return chosen;
}

void function GiveRandomPilotWeapon( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;
    //print( "GiveRandomWeapon() called" );

    foreach ( entity weapon in player.GetMainWeapons() )
        player.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosenWeapon = GetRandomDistinctItem( pilotWeapons, pilotStates[player].primary );
    pilotStates[player].primary = chosenWeapon;
    player.GiveWeapon( pilotStates[player].primary );
    player.SetActiveWeaponByName( pilotStates[player].primary );
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

// giving only the primary weapon in the campaign actually sets the whole loadout
void function GiveRandomTitanLoadout( entity titan ) {
    if ( !IsValid( titan ) || !titan.IsTitan() ) return;

    foreach ( entity weapon in titan.GetMainWeapons() )
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosenWeapon = GetRandomDistinctItem( titanWeapons, titanStates[titan].primary );
    titanStates[titan].primary = chosenWeapon;
    titan.GiveWeapon( titanStates[titan].primary );
    titan.SetActiveWeaponByName( titanStates[titan].primary );
}
