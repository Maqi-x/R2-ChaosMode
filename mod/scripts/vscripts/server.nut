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

void function UpdatePilotAbility( entity player ) {
    entity actualAbility = player.GetOffhandWeapon(PILOT_ABILITY);
    if ( !IsValid( actualAbility ) || actualAbility.GetWeaponClassName() != pilotStates[player].ability) {
        player.TakeOffhandWeapon(PILOT_ABILITY);
        player.GiveOffhandWeapon( pilotStates[player].ability, PILOT_ABILITY, [] );
    }

    bool isActive = !player.GetOffhandWeapon(PILOT_ABILITY).IsReadyToFire();
    bool wasActive = pilotStates[player].abilityActive;

    if (wasActive && !isActive) {
        GiveRandomPilotAbility( player );
    }
    pilotStates[player].abilityActive = isActive;
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

    UpdatePilotAbility( player );
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
    if ( player in pilotStates ) return; // to prevent spawning multiple threads for one player

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
            // NOTE: i know about DamageInfo_GetWeapon, but it just isn't working and i have no idea why
            //       it just always returns null so i'll stick to this ugly-but-working approach

            bool isGranade = dmgType == 32;
            if ( pilotStates[player].offhand == "mp_weapon_thermite_grenade" && dmgType == 96 ) {
                isGranade = true;
            } else if ( pilotStates[player].offhand == "mp_weapon_grenade_sonar" && dmgType == 0 ) {
                isGranade = true;
            }

            bool isMelee = dmgType == 536870912;
            printt("IS_MELEE", isMelee);

            if (isGranade)
                GiveRandomPilotGrenade( player );
            else if (isMelee)
                GiveRandomPilotMelee( player );
            else
                GiveRandomPilotWeapon( player );
        }
    }
}

void function PrecacheIfNeeded( string id ) {
    if ( !WeaponIsPrecached( id ) )
        PrecacheWeapon( id );
}

void function PrecacheEverything() {
    //PrecacheModel( $"models/weapons/at_satchel_charge/at_satchel_charge.mdl" );
    foreach ( string id in pilotWeapons )   PrecacheIfNeeded( id );
    foreach ( string id in pilotOrdnances ) PrecacheIfNeeded( id );
    foreach ( string id in pilotAbilities ) PrecacheIfNeeded( id );
    foreach ( string id in pilotMelees )    PrecacheIfNeeded( id );
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
