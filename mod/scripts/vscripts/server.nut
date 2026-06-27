global function ServerStart

struct PilotState {
    string primary // one of pilotWeapons
    string offhand // one of grenades
}

table<entity, PilotState> pilotStates;

void function GiveRandomWeapon( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;
    print( "GiveRandomWeapon() called" );

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

void function GiveRandomGrenade( entity player ) {
    if ( !IsValid( player ) || player.IsTitan() ) return;

    if ( IsValid( player.GetOffhandWeapon(0) ) )
        player.TakeWeaponNow( player.GetOffhandWeapon(0).GetWeaponClassName() );

    string chosenOrd;
    do {
        chosenOrd = grenades[ RandomInt( grenades.len() ) ];
    } while ( chosenOrd == pilotStates[player].offhand );

    pilotStates[player].offhand = chosenOrd;
    player.GiveOffhandWeapon( chosenOrd, 0, [] );
}

void function UpdatePilot( entity player ) {
    array<entity> mainWpns = player.GetMainWeapons();
    if ( mainWpns.len() != 1 || mainWpns[0].GetWeaponClassName() != pilotStates[player].primary ) {
        bool alreadyHave = false;
        foreach ( entity weapon in player.GetMainWeapons() ) {
            if ( weapon.GetWeaponClassName() == pilotStates[player].primary ) {
                alreadyHave = true;
                continue;
            }
            player.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        if ( !alreadyHave ) player.GiveWeapon( pilotStates[player].primary );
        player.SetActiveWeaponByName( pilotStates[player].primary );
    }
    entity offhandWpn = player.GetOffhandWeapon(0);
    if ( IsValid( offhandWpn ) ) {
        if ( offhandWpn.GetWeaponClassName() != pilotStates[player].offhand || player.GetWeaponAmmoLoaded(offhandWpn) == 0 ) {
            player.TakeOffhandWeapon(0);
            player.GiveOffhandWeapon( pilotStates[player].offhand, 0, [] );
        }
    }
}

void function UpdateTitan( entity BT ) {
    // TODO
}

void function Loop( entity player ) {
    while ( true ) {
        if ( player.IsTitan() ) {
            UpdateTitan( player );
        } else {
            UpdatePilot( player );
        }
        wait 0.1;
    }
}

void function InitLoop( entity player ) {
    if ( !player.IsPlayer() || !IsValid( player ) ) return;

    PilotState randomLoadout;
    randomLoadout.primary = pilotWeapons[ RandomInt( pilotWeapons.len() ) ];
    randomLoadout.offhand = grenades[ RandomInt( grenades.len() ) ];
    pilotStates[player] <- randomLoadout;

    thread Loop( player );
}

void function OnNPCKilled( entity victim, entity attacker, var damageInfo ) {
    if ( attacker.IsPlayer() ) {
        entity player = attacker; // just for clarity

        var dmgType = DamageInfo_GetDamageType(damageInfo);
        printt("DAMAGE TYPE", dmgType);
        
        if ( player.IsTitan() ){
            // TODO
        } else {
            bool isGranade = dmgType == 32;
            if ( pilotStates[player].offhand == "mp_weapon_thermite_grenade" && dmgType == 96 ) {
                isGranade = true;
            } else if ( pilotStates[player].offhand == "mp_weapon_grenade_sonar" && dmgType == 0 ) {
                isGranade = true;
            }

            if (isGranade)
                GiveRandomGrenade( player );
            else
                GiveRandomWeapon( player );
        }
    }
}

void function PrecacheEverything() {
    //PrecacheModel( $"models/weapons/at_satchel_charge/at_satchel_charge.mdl" );
    foreach ( string id in pilotWeapons )
        if (!WeaponIsPrecached(id))
            PrecacheWeapon(id);
    foreach ( string id in grenades )
        if (!WeaponIsPrecached(id))
            PrecacheWeapon(id);
}

void function ServerStart() {
    print( "Hello from titanfall 2" );
    PrecacheEverything();
    //SetWeaponDropsEnabled( false );

    AddCallback_OnNPCKilled( OnNPCKilled );
    AddCallback_OnPlayerRespawned( InitLoop );
    //foreach (ord in grenades) {
    //    AddSpawnCallback(ord, OnGrenadeThrown);
    //}
}