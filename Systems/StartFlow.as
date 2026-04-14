timerdialog SG_StartTimerDialog = nil;
bool SG_StartFinalized = false;

item SG_AddItemToHero(unit hero, int itemTypeId) {
    item it = CreateRegisteredItem(itemTypeId, Jass::GetUnitX(hero), Jass::GetUnitY(hero));
    Jass::UnitAddItem(hero, it);
    return it;
}

void SG_RefreshHeroItemDropFlags(unit hero) {
    int invSize = Jass::UnitInventorySize(hero);
    for (int i = 0; i < invSize; i++) {
        item it = Jass::UnitItemInSlot(hero, i);
        if (it == nil) continue;

        if (Jass::GetItemTypeId(it) == 'I046') {
            Jass::SetItemDroppable(it, false);
        } else {
            Jass::SetItemDroppable(it, true);
        }

        it = nil;
    }
}

void SG_EnsureStarterItems(unit hero, int playerIndex) {
    if (hero == nil) return;
    if (Jass::GetHeroLevel(hero) != 1) return;

    item slot0 = Jass::UnitRemoveItemFromSlot(hero, 0);
    item token = SG_AddItemToHero(hero, 'I046');

    if (slot0 != nil) {
        Jass::UnitAddItem(hero, slot0);
        slot0 = nil;
    }

    if (token != nil) {
        
        Jass::SetItemDroppable(token, false);
        token = nil;
    }

    item slot1 = Jass::UnitRemoveItemFromSlot(hero, 1);
    SG_AddItemToHero(hero, 'I02I');

    if (slot1 != nil) {
        Jass::UnitAddItem(hero, slot1);
        slot1 = nil;
    }

    SG_RefreshHeroItemDropFlags(hero);
}

void SG_PrepareHero(unit hero, int playerIndex) {
    if (hero == nil) return;

    Jass::SetUnitState(hero, Jass::UNIT_STATE_LIFE, Jass::GetUnitState(hero, Jass::UNIT_STATE_MAX_LIFE));
    Jass::SetUnitState(hero, Jass::UNIT_STATE_MANA, Jass::GetUnitState(hero, Jass::UNIT_STATE_MAX_MANA));
    Jass::IssueImmediateOrder(hero, "stop");
    Jass::SetUnitInvulnerable(hero, false);
    float x = Jass::GetRandomReal(-5280.0+50.,-4864.0-50.);
    float y = Jass::GetRandomReal( 4896.0+50., 5600.0-50.);
    Jass::SetUnitX(hero, x);
    Jass::SetUnitY(hero, y);
    Jass::SetUnitFacing(hero, Jass::GetRandomReal(0., 360.));

    SG_EnsureStarterItems(hero, playerIndex);
}

int SG_CountReadyHeroes() {
    int ready = 0;

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (!Jass::IsPlayerInForce(p, PlayerForces)) {
            p = nil;
            continue;
        }

        unit hero = GoblinUnit[i];
        if (hero != nil && Jass::GetUnitTypeId(hero) != 0 && Jass::IsUnitAlive(hero)) {
            ready += 1;
        }

        hero = nil;
        p = nil;
    }

    return ready;
}

bool SG_CanSkipStart() {
    int playersCount = CountPlayersInForce(PlayerForces);
    if (playersCount <= 0) return false;
    return SG_CountReadyHeroes() >= playersCount;
}

void SG_DestroyStartTimerDialog() {
    if (SG_StartTimerDialog != nil) {
        Jass::TimerDialogDisplay(SG_StartTimerDialog, false);
        Jass::DestroyTimerDialog(SG_StartTimerDialog);
        SG_StartTimerDialog = nil;
    }
}

void SG_ApplyWaveStartState() {
    if (udg_Wave_Number_TP != udg_Wave_Number) {
        udg_Wave_Number = udg_Wave_Number_TP;
    }

    if (udg_Wave_next_time < 120) {
        udg_Wave_next_time = 120;
    }
}

void SG_FinalizeStartNow() {
    if (SG_StartFinalized) return;

    SG_StartFinalized = true;

    SG_DestroyStartTimerDialog();

    if (GameStartTimer != nil) {
        Jass::PauseTimer(GameStartTimer);
        Jass::DestroyTimer(GameStartTimer);
        GameStartTimer = nil;
    }

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (!Jass::IsPlayerInForce(p, PlayerForces)) {
            p = nil;
            continue;
        }

        unit hero = GoblinUnit[i];
        if (hero != nil && Jass::GetUnitTypeId(hero) != 0) {
            SG_PrepareHero(hero, i);
        }

        hero = nil;
        p = nil;
    }

    SG_ApplyWaveStartState();

    GameStarted = true;
    DisplayTextToPlayers("TRIGSTR_382");
}

void SG_OnStartTimerExpired() {
    SG_FinalizeStartNow();
}

void SG_InitStartTimer() {
    SG_StartFinalized = false;

    SG_DestroyStartTimerDialog();

    if (GameStartTimer != nil) {
        Jass::PauseTimer(GameStartTimer);
        Jass::DestroyTimer(GameStartTimer);
        GameStartTimer = nil;
    }

    GameStartTimer = Jass::CreateTimer();
    Jass::TimerStart(GameStartTimer, 120.00, false, @SG_OnStartTimerExpired);

    SG_StartTimerDialog = Jass::CreateTimerDialog(GameStartTimer);
    Jass::TimerDialogSetTitle(SG_StartTimerDialog, "До старта");
    Jass::TimerDialogDisplay(SG_StartTimerDialog, true);
}

void SG_SetStartTimerTo10() {
    if (GameStarted || SG_StartFinalized) return;

    if (GameStartTimer == nil) {
        SG_FinalizeStartNow();
        return;
    }

    float remaining = Jass::TimerGetRemaining(GameStartTimer);
    if (remaining > 10.0) {
        Jass::PauseTimer(GameStartTimer);
        Jass::TimerStart(GameStartTimer, 10.00, false, @SG_OnStartTimerExpired);
    } else {
        Jass::ResumeTimer(GameStartTimer);
    }
}

void SG_PauseStartTimer() {
    if (GameStarted || SG_StartFinalized) return;
    if (GameStartTimer != nil) {
        Jass::PauseTimer(GameStartTimer);
    }
}

void SG_ResumeStartTimer() {
    if (GameStarted || SG_StartFinalized) return;
    if (GameStartTimer != nil) {
        Jass::ResumeTimer(GameStartTimer);
    }
}
