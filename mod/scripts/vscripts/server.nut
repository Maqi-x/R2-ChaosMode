global function ServerStart

void function EnsureWeapon( entity ent, string expected ) {
    array<entity> mainWpns = ent.GetMainWeapons();
    if ( mainWpns.len() != 1 || mainWpns[0].GetWeaponClassName() != expected ) {
        bool alreadyHave = false;
        foreach ( entity weapon in ent.GetMainWeapons() ) {
            if ( weapon.GetWeaponClassName() == expected ) {
                alreadyHave = true;
                continue;
            }
            ent.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        if ( !alreadyHave ) ent.GiveWeapon( expected );
        ent.SetActiveWeaponByName( expected );
    }
}

void function UpdatePilot( entity player ) {
    if ( !IsValid( player ) || !player.IsEntAlive() ) return;
    if (!(player in pilotStates)) {
        pilotStates[player] <- RandPilotLoadout();
    }

    EnsureWeapon( player, pilotStates[player].primary );

    entity offhandWpn = player.GetOffhandWeapon(PILOT_ORDNANCE);
    if ( IsValid( offhandWpn ) ) {
        if ( offhandWpn.GetWeaponClassName() != pilotStates[player].offhand || player.GetWeaponAmmoLoaded(offhandWpn) == 0 ) {
            player.TakeOffhandWeapon(PILOT_ORDNANCE);
            player.GiveOffhandWeapon( pilotStates[player].offhand, PILOT_ORDNANCE, [] );
        }
    }

    entity wpn = player.GetMainWeapons()[0];
    wpn.SetWeaponPrimaryAmmoCount(wpn.GetWeaponPrimaryClipCountMax());
}

void function UpdateTitan( entity BT ) {
    if (!(BT in titanStates)) {
        titanStates[BT] <- RandTitanLoadout();
    }
    EnsureWeapon( BT, titanStates[BT].primary );
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

    thread Loop( player );
}

void function OnNPCKilled( entity victim, entity attacker, var damageInfo ) {
    if ( attacker.IsPlayer() ) {
        entity player = attacker; // just for clarity

        var dmgType = DamageInfo_GetDamageType(damageInfo);
        printt("DAMAGE TYPE", dmgType);
        
        if ( player.IsTitan() ){
            GiveRandomTitanLoadout( player );
        } else {
            bool isGranade = dmgType == 32;
            if ( pilotStates[player].offhand == "mp_weapon_thermite_grenade" && dmgType == 96 ) {
                isGranade = true;
            } else if ( pilotStates[player].offhand == "mp_weapon_grenade_sonar" && dmgType == 0 ) {
                isGranade = true;
            }

            if (isGranade)
                GiveRandomPilotGrenade( player );
            else
                GiveRandomPilotWeapon( player );
        }
    }
}

void function PrecacheEverything() {
    //PrecacheModel( $"models/weapons/at_satchel_charge/at_satchel_charge.mdl" );
    foreach ( string id in pilotWeapons )
        if (!WeaponIsPrecached(id))
            PrecacheWeapon(id);
    foreach ( string id in pilotOrdnances )
        if (!WeaponIsPrecached(id))
            PrecacheWeapon(id);
}

void function ServerStart() {
    print( "Hello from titanfall 2" );
    PrecacheEverything();
    //SetWeaponDropsEnabled( false );

    AddCallback_OnNPCKilled( OnNPCKilled );
    AddCallback_OnPlayerRespawned( InitLoop );
    //foreach (ord in pilotOrdnances) {
    //    AddSpawnCallback(ord, OnGrenadeThrown);
    //}
}