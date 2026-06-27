global function GiveRandomPilotWeapon
global function GiveRandomPilotGrenade
global function GiveRandomTitanLoadout

global function RandPilotLoadout
global function RandTitanLoadout

PilotState function RandPilotLoadout() {
    PilotState loadout;
    loadout.primary = pilotWeapons[ RandomInt( pilotWeapons.len() ) ];
    loadout.offhand = pilotOrdnances[ RandomInt( pilotOrdnances.len() ) ];
    return loadout;
}

TitanState function RandTitanLoadout() {
    TitanState loadout;
    loadout.primary = titanWeapons[ RandomInt( titanWeapons.len() ) ];
    return loadout;
}

void function GiveRandomPilotWeapon( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;
    //print( "GiveRandomWeapon() called" );

    foreach ( entity weapon in player.GetMainWeapons() )
        player.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosenWeapon;
    do {
        chosenWeapon = pilotWeapons[ RandomInt( pilotWeapons.len() ) ];
    } while ( chosenWeapon == pilotStates[player].primary );

    pilotStates[player].primary = chosenWeapon;
    player.GiveWeapon( pilotStates[player].primary );
    player.SetActiveWeaponByName( pilotStates[player].primary );
}

void function GiveRandomPilotGrenade( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;

    if ( IsValid( player.GetOffhandWeapon(PILOT_ORDNANCE) ) )
        player.TakeWeaponNow( player.GetOffhandWeapon(PILOT_ORDNANCE).GetWeaponClassName() );

    string chosenOrd;
    do {
        chosenOrd = pilotOrdnances[ RandomInt( pilotOrdnances.len() ) ];
    } while ( chosenOrd == pilotStates[player].offhand );

    pilotStates[player].offhand = chosenOrd;
    player.GiveOffhandWeapon( chosenOrd, 0, [] );
}

// giving only the primary weapon in the campaign actually sets the whole loadout
void function GiveRandomTitanLoadout( entity titan ) {
    if ( !IsValid( titan ) || !titan.IsTitan() ) return;

    foreach ( entity weapon in titan.GetMainWeapons() )
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )

    string chosenWeapon;
    do {
        chosenWeapon = titanWeapons[ RandomInt( titanWeapons.len() ) ];
    } while ( chosenWeapon == titanStates[titan].primary );

    titanStates[titan].primary = chosenWeapon;
    titan.GiveWeapon( titanStates[titan].primary );
    titan.SetActiveWeaponByName( titanStates[titan].primary );
}