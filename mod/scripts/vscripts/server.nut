global function ServerStart

const float BASE_MOVE_SPEED_SCALE = 1.4;

void function EnsureWeapon( entity ent, string expected ) {
    entity active = ent.GetActiveWeapon();
    if ( IsValid( active ) && active.GetWeaponClassName() == "sp_weapon_arc_tool" ) return;

    array<entity> mainWpns = ent.GetMainWeapons();
    if ( mainWpns.len() != 1 || mainWpns[0].GetWeaponClassName() != expected ) {
        bool alreadyHave = false;
        foreach ( entity weapon in ent.GetMainWeapons() ) {
            if ( weapon.GetWeaponClassName() == expected ) {
                alreadyHave = true;
                continue;
            }

            if ( weapon.GetWeaponClassName() != "sp_weapon_arc_tool" )
                ent.TakeWeaponNow( weapon.GetWeaponClassName() )
        }

        if ( !alreadyHave ) ent.GiveWeapon( expected );

        active = ent.GetActiveWeapon();

        if ( IsValid( active ) ) {
            if ( active.GetWeaponClassName() == expected ) return;

            if ( pilotOrdnances.find(active.GetWeaponClassName()) ) return;
            if ( pilotOrdnances.find(active.GetWeaponClassName()) ) return;
            if ( pilotOrdnances.find(active.GetWeaponClassName()) ) return;

        }
        ent.SetActiveWeaponByName( expected );
    }
}

void function EnsureOffhand( entity ent, string expected, int slot ) {
    entity offhand = ent.GetOffhandWeapon( slot )
    if ( !IsValid( offhand ) || offhand.GetWeaponClassName() != expected ) {
        ent.TakeOffhandWeapon( slot )
        ent.GiveOffhandWeapon( expected, slot, [] )
    }
}

void function UpdatePilotSprint( entity player ) {
    bool isSprinting = player.IsSprinting();
    bool wasSprinting = pilotStates[player].isSprinting;

    if (isSprinting && !wasSprinting) {
        player.SetMoveSpeedScale(RandomFloatRange(BASE_MOVE_SPEED_SCALE-0.2, BASE_MOVE_SPEED_SCALE+0.8));
    } else if (wasSprinting && !isSprinting) {
        player.SetMoveSpeedScale(BASE_MOVE_SPEED_SCALE);
    }

    pilotStates[player].isSprinting = isSprinting;
}

void function UpdatePilotAbility( entity player ) {
    if ( GetMapName() == "sp_crashsite" )
        if (!IsValid( player.GetOffhandWeapon(PILOT_ABILITY) ))
            return;

    entity ability = player.GetOffhandWeapon(PILOT_ABILITY);

    if ( IsValid( ability ) && ability.GetWeaponClassName() == "mp_ability_timeshift" )
        return;

    EnsureOffhand( player, pilotStates[player].ability, PILOT_ABILITY );

    if ( !IsValid( ability ) ) return;

    bool isActive = !ability.IsReadyToFire();
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
    UpdatePilotSprint( player );
}

void function UpdateTitan( entity BT ) {
    if ( !IsValid( BT ) || ! BT.IsEntAlive() ) return;
    if (!(BT in titanStates)) {
        titanStates[BT] <- RandTitanLoadout();
    }

    entity soul = BT.GetTitanSoul();

    float currCoreMeter = soul.GetNextCoreChargeAvailable();
    float prevCoreMeter = titanStates[BT].coreMeter;

    bool coreActivated = currCoreMeter == 0 && prevCoreMeter != 0;
    if ( coreActivated ) {
        titanStates[BT].coreActive = true;
        titanStates[BT].coreExpireTime = soul.GetCoreChargeExpireTime();
    } else if (Time() >= titanStates[BT].coreExpireTime) {
        titanStates[BT].coreActive = false;
        titanStates[BT].coreExpireTime = 0;
    }

    titanStates[BT].coreMeter = currCoreMeter;

    //printt("CORE ACTIVE?", titanStates[BT].coreActive);

    // changing weapons when core is active causes many weird bugs
    if ( !titanStates[BT].coreActive && GetMapName() != "sp_crashsite" ) {
        EnsureWeapon( BT, titanStates[BT].primary );
        EnsureOffhand( BT, titanStates[BT].offensive, TITAN_OFFENSIVE );
        EnsureOffhand( BT, titanStates[BT].tactical,  TITAN_TACTICAL  );

        entity defensive = BT.GetOffhandWeapon( TITAN_DEFENSIVE );
        if ( !IsValid( defensive ) || defensive.GetWeaponClassName() != "mp_titanability_timeshift" )
            EnsureOffhand( BT, titanStates[BT].defensive, TITAN_DEFENSIVE );
    }

    BT.SetMoveSpeedScale(BASE_MOVE_SPEED_SCALE);
    SetBTLoadoutsUnlockedBitfield( 0 );
}

void function Loop( entity player ) {
    while ( true ) {
        if ( !IsActive() ) {
            wait 1.0;
            continue;
        }

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
    if ( IsActive() && attacker.IsPlayer() ) {
        entity player = attacker; // just for clarity

        var dmgType = DamageInfo_GetDamageType(damageInfo);
        printt("DAMAGE TYPE", dmgType);

        if ( player.IsTitan() ){
            if ( titanStates[player].coreActive ) return;
            if ( GetMapName() == "sp_crashsite" ) return;
            if ( victim.IsTitan() ) {
                GiveRandomTitanLoadout( player );
            } else {
                switch (RandomInt(3)) {
                case 0: GiveRandomTitanOffensive( player ); break;
                case 1: GiveRandomTitanDefensive( player ); break;
                case 2: GiveRandomTitanTactical ( player ); break;
                }
            }
        } else {
            // NOTE: i know about DamageInfo_GetWeapon, but it just isn't working and i have no idea why
            //       it just always returns null so i'll stick to this ugly-but-working approach

            bool isGranade = (dmgType == 32) && pilotStates[player].primary != "mp_weapon_softball";
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
    SyncMods();

    //PrecacheModel( $"models/weapons/at_satchel_charge/at_satchel_charge.mdl" );
    foreach ( string id in pilotWeapons )    PrecacheIfNeeded( id );
    foreach ( string id in pilotOrdnances )  PrecacheIfNeeded( id );
    foreach ( string id in pilotAbilities )  PrecacheIfNeeded( id );
    foreach ( string id in pilotMelees )     PrecacheIfNeeded( id );
    foreach ( string id in titanWeapons )    PrecacheIfNeeded( id );
    foreach ( string id in titanOffensives ) PrecacheIfNeeded( id );
    foreach ( string id in titanDefensives ) PrecacheIfNeeded( id );
    foreach ( string id in titanTacticals )  PrecacheIfNeeded( id );
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
