trigger LOOL_LeaveTrigger = nil;

bool LOOL_IsActiveUser(player p) {
    if (p == nil) return false;

    int pid = Jass::GetPlayerId(p);
    if (pid < 0 || pid > 9) return false;

    return Jass::GetPlayerSlotState(p) == Jass::PLAYER_SLOT_STATE_PLAYING
        && Jass::GetPlayerController(p) == Jass::MAP_CONTROL_USER;
}

bool LOOL_IsImportantAdminUnit(unit u) {
    int typeId = Jass::GetUnitTypeId(u);
    return typeId == 'h01A'
        || typeId == 'h01O'
        || typeId == 'h05G'
        || typeId == 'h075'
        || typeId == 'h02J'
        || typeId == 'h02F'
        || typeId == 'h02B';
}

bool LOOL_IsStructureTransferAllowed(unit u, player leaver) {
    if (u == nil) return false;
    if (Jass::GetOwningPlayer(u) != leaver) return false;
    if (!Jass::IsUnitType(u, Jass::UNIT_TYPE_STRUCTURE)) return false;

    int typeId = Jass::GetUnitTypeId(u);
    if (typeId == 'h01O' || typeId == 'h02J' || typeId == 'h02F' || typeId == 'h01A') {
        return false;
    }

    return true;
}

void LOOL_RemoveHeroConsumables(unit hero) {
    if (hero == nil) return;

    for (int i = 0; i < 6; i++) {
        item it = Jass::UnitItemInSlot(hero, i);
        if (it == nil) continue;

        if (Jass::GetItemTypeId(it) == 'I046') {
            Jass::RemoveItem(it);
            it = nil;
            continue;
        }

        itemtype itType = Jass::GetItemType(it);
        if (itType == Jass::ITEM_TYPE_CHARGED || itType == Jass::ITEM_TYPE_CAMPAIGN) {
            Jass::UnitRemoveItemFromSlot(hero, i);
        }

        it = nil;
    }
}

int LOOL_CountAliveGoblins() {
    int aliveCount = 0;

    for (int i = 0; i < Jass::GroupGetCount(Goblinzz); i++) {
        unit u = Jass::GroupGetUnitByIndex(Goblinzz, i);
        if (u != nil && Jass::IsUnitAlive(u)) {
            aliveCount += 1;
        }
    }

    return aliveCount;
}

void LOOL_ShareLeaverLumber(player leaver) {
    int aliveCount = LOOL_CountAliveGoblins();
    if (aliveCount <= 0) return;

    int lumber = Jass::GetPlayerState(leaver, Jass::PLAYER_STATE_RESOURCE_LUMBER);
    if (lumber <= 0) return;

    int share = lumber / aliveCount;
    if (share <= 0) return;

    for (int i = 0; i < Jass::GroupGetCount(Goblinzz); i++) {
        unit u = Jass::GroupGetUnitByIndex(Goblinzz, i);
        if (u == nil || !Jass::IsUnitAlive(u)) continue;

        player owner = Jass::GetOwningPlayer(u);
        int ownerLumber = Jass::GetPlayerState(owner, Jass::PLAYER_STATE_RESOURCE_LUMBER);
        Jass::SetPlayerState(owner, Jass::PLAYER_STATE_RESOURCE_LUMBER, ownerLumber + share);
        owner = nil;
    }
}

player LOOL_FindFallbackOwner() {
    for (int i = 0; i < int(GoblinUnit.length()); i++) {
        unit g = GoblinUnit[i];
        if (g != nil && Jass::IsUnitAlive(g)) {
            return Jass::Player(i);
        }
    }

    return nil;
}

void LOOL_ReassignLeaverStructures(player leaver) {
    player fallback = LOOL_FindFallbackOwner();
    if (fallback == nil) return;

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRect(g, mapInitialPlayableArea, nil);

    for (int i = 0; i < Jass::GroupGetCount(g); i++) {
        unit u = Jass::GroupGetUnitByIndex(g, i);
        if (LOOL_IsStructureTransferAllowed(u, leaver)) {
            Jass::SetUnitOwner(u, fallback, true);
        }
    }

    Jass::GroupClear(g);
    Jass::DestroyGroup(g);
    g = nil;
    fallback = nil;
}

void LOOL_HandleLeaverHero(unit hero, player leaver) {
    if (hero == nil) return;

    int pid = Jass::GetPlayerId(leaver);

    if (Jass::IsUnitInGroup(hero, Goblinzz)) {
        Jass::GroupRemoveUnit(Goblinzz, hero);
    }

    if (pid >= 0 && pid < int(GoblinUnit.length()) && GoblinUnit[pid] == hero) {
        GoblinUnit[pid] = nil;
    }

    LOOL_RemoveHeroConsumables(hero);
    LOOL_ShareLeaverLumber(leaver);

    Jass::SetPlayerState(leaver, Jass::PLAYER_STATE_RESOURCE_LUMBER, 0);
    Jass::SetPlayerState(leaver, Jass::PLAYER_STATE_RESOURCE_GOLD, 0);

    Jass::PingMinimap(Jass::GetUnitX(hero), Jass::GetUnitY(hero), 3.00);
    Jass::KillUnit(hero);
}

void LOOL_CleanupOwnedUnits(player leaver) {
    group g = Jass::CreateGroup();
    unit hero = nil;

    Jass::GroupEnumUnitsOfPlayer(g, leaver, nil);

    for (int i = 0; i < Jass::GroupGetCount(g); i++) {
        unit u = Jass::GroupGetUnitByIndex(g, i);
        if (u == nil) continue;

        if (Jass::GetUnitTypeId(u) == 'h076') {
            Jass::RemoveUnit(u);
            continue;
        }

        if (hero == nil && Jass::IsUnitType(u, Jass::UNIT_TYPE_HERO) && Jass::IsUnitInGroup(u, Goblinzz)) {
            hero = u;
        }
    }

    if (hero != nil) {
        LOOL_HandleLeaverHero(hero, leaver);
    }

    Jass::GroupClear(g);
    Jass::DestroyGroup(g);
    g = nil;

    LOOL_ReassignLeaverStructures(leaver);

    if (GameStarted) {
        DisplayTextToPlayers("TRIGSTR_326");
    }

    if (LOOL_CountAliveGoblins() <= 0) {
        DisplayTextToPlayers("TRIGSTR_008");
    }

    hero = nil;
}

void LOOL_AdminRightsPass() {
    timer t = Jass::GetExpiredTimer();
    if (t != nil) {
        Jass::DestroyTimer(t);
        t = nil;
    }

    player oldAdmin = Admin_Player;
    player newAdmin = nil;

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (LOOL_IsActiveUser(p)) {
            newAdmin = p;
            p = nil;
            break;
        }
        p = nil;
    }

    if (newAdmin == nil) {
        oldAdmin = nil;
        return;
    }

    if (oldAdmin != nil && oldAdmin != newAdmin) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsOfPlayer(g, oldAdmin, nil);

        for (int i = 0; i < Jass::GroupGetCount(g); i++) {
            unit u = Jass::GroupGetUnitByIndex(g, i);
            if (LOOL_IsImportantAdminUnit(u)) {
                Jass::SetUnitOwner(u, newAdmin, true);
            }
        }

        Jass::GroupClear(g);
        Jass::DestroyGroup(g);
        g = nil;
    }

    Admin_Player = newAdmin;
    DisplayTextToPlayers("|c00FF0000Главой экспедиции назначается: |r" + Jass::GetPlayerName(Admin_Player));

    oldAdmin = nil;
    newAdmin = nil;
}

void LOOL_StartAdminRightsPass() {
    Jass::TimerStart(Jass::CreateTimer(), 2.00, false, @LOOL_AdminRightsPass);
}

void LOOL_LeaverCleanup(player p) {
    if (p == nil) return;

    Jass::ForceRemovePlayer(PlayerForces, p);
    LOOL_CleanupOwnedUnits(p);

    if (!GameStarted && g_ready_players > 0) {
        g_ready_players -= 1;
    }

    if (Admin_Player == p) {
        LOOL_StartAdminRightsPass();
    }

    p = nil;
}

void LOOL_OnLeaveEvent() {
    player p = Jass::GetTriggerPlayer();

    DisplayTextToPlayers("Игрок " + Jass::GetPlayerName(p) + " покидает игру.");
    LOOL_LeaverCleanup(p);

    p = nil;
}

void InitLeaverOutOfListAS() {
    LOOL_LeaveTrigger = Jass::CreateTrigger();

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        Jass::TriggerRegisterPlayerEvent(LOOL_LeaveTrigger, p, Jass::EVENT_PLAYER_LEAVE);
        Jass::TriggerRegisterPlayerEvent(LOOL_LeaveTrigger, p, Jass::EVENT_PLAYER_DEFEAT);
        Jass::TriggerRegisterPlayerEvent(LOOL_LeaveTrigger, p, Jass::EVENT_PLAYER_VICTORY);
        p = nil;
    }

    Jass::TriggerAddAction(LOOL_LeaveTrigger, @LOOL_OnLeaveEvent);

    // Keep AS admin selection valid from game start.
    LOOL_StartAdminRightsPass();
}
