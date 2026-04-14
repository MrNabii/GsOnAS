//import UnitStats.as

#include "UnitStats.as"



funcdef void OnSpawnCallback(unit u);

// Мап: abilityId → callback
dictionary g_OnSpawnHandlers;

// Регистрация обработчика для способности
void RegisterOnSpawnHandler(int abilityId, OnSpawnCallback@ cb) {
	if (cb is null) return;
	g_OnSpawnHandlers["" + abilityId] = @cb;
}

array<unit> GoblinUnit;
array<unit> BunkerUnit;
group Goblinzz;
group Ores;
int Gliba_Counter = 0;
int OSA_STALKER_E_TIMER_PARENT = 'OSE0';

void OSA_ApplyHeroItemOwnership(unit u) {
    int ownerPlayerId = Jass::GetPlayerId(Jass::GetOwningPlayer(u)) + 1;
    int invSize = Jass::UnitInventorySize(u);
    for (int slot = 0; slot < invSize; slot++) {
        item it = Jass::UnitItemInSlot(u, slot);
        if (it == nil) continue;
        SetItemOwner(it, ownerPlayerId);
        Jass::SetItemDroppable(it, false);
        it = nil;
    }
}

void OSA_StalkerEChargeTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pid = Jass::LoadInteger(SkillHT, th, 1);

    if (u == nil || Jass::GetUnitTypeId(u) == 0 || Jass::GetPlayerId(Jass::GetOwningPlayer(u)) != pid) {
        Jass::RemoveSavedHandle(SkillHT, OSA_STALKER_E_TIMER_PARENT, pid);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        t = nil;
        u = nil;
        return;
    }

    int abilvl = Jass::GetUnitAbilityLevel(u, 'A0OR');
    if (abilvl >= 2 && Jass::IsUnitAlive(u)) {
        int maxCharges = (abilvl >= 3) ? Stalker::E_Stack2 : Stalker::E_Stack1;
        int charges = HGetAbilityCharges(u, 'A0OR');
        if (charges < maxCharges) {
            HSetAbilityCharges(u, 'A0OR', charges + 1);
        }
    }

    float nextTick = Stalker::E_cd1;
    if (abilvl == 2) {
        nextTick = Stalker::E_cd2;
    } else if (abilvl >= 3) {
        nextTick = Stalker::E_cd3;
    }
    if (nextTick < 0.10) {
        nextTick = 0.10;
    }

    Jass::TimerStart(t, nextTick, false, @OSA_StalkerEChargeTick);
    t = nil;
    u = nil;
}

void OSA_StartStalkerECharge(unit u) {
    if (Jass::GetUnitAbilityLevel(u, 'A0OR') <= 0) return;

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    timer existed = Jass::LoadTimerHandle(SkillHT, OSA_STALKER_E_TIMER_PARENT, pid);
    if (existed != nil) {
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(existed), 0, u);
        existed = nil;
        return;
    }

    HSetAbilityCharges(u, 'A0OR', 0);

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveInteger(SkillHT, th, 1, pid);
    Jass::SaveTimerHandle(SkillHT, OSA_STALKER_E_TIMER_PARENT, pid, t);
    Jass::TimerStart(t, 0.10, false, @OSA_StalkerEChargeTick);
    t = nil;
}

void OSA_PiroA00XPassiveTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pid = Jass::LoadInteger(SkillHT, th, 1);

    if (u == nil || Jass::GetUnitTypeId(u) == 0 || Jass::GetPlayerId(Jass::GetOwningPlayer(u)) != pid) {
        Jass::RemoveSavedHandle(SkillHT, 'A00X', pid * 10);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        t = nil;
        u = nil;
        return;
    }

    if (!Jass::IsUnitAlive(u)) {
        t = nil;
        u = nil;
        return;
    }

    int charges = HGetAbilityCharges(u, 'A00X');
    int missing = 3 - charges;
    if (missing < 0) {
        missing = 0;
    } else if (missing > 2) {
        missing = 2;
    }

    float pr = ((Piro::E_Startfr + Piro::E_Thenfr * float(Jass::GetHeroStr(u, true))) * (1.0 + float(missing) * 0.5)) / 100.0;
    HAddBuff_PR(u, 'A00X', pr, 1.05);

    t = nil;
    u = nil;
}

void OSA_StartPiroA00XPassive(unit u) {
    if (Jass::GetUnitAbilityLevel(u, 'A00X') <= 0) return;

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    if (!Jass::HaveSavedHandle(SkillHT, 'A00X', pid * 10)) {
        timer t = Jass::CreateTimer();
        int th = Jass::GetHandleId(t);
        Jass::SaveUnitHandle(SkillHT, th, 0, u);
        Jass::SaveInteger(SkillHT, th, 1, pid);
        Jass::SaveTimerHandle(SkillHT, 'A00X', pid * 10, t);
        Jass::TimerStart(t, 1.0, true, @OSA_PiroA00XPassiveTick);
        t = nil;
    }

    UnitData@ ud = GetUnitData(u);
    float capAS = 0.0;
    if (ud !is null) {
        capAS = ud.totalStats.attackSpeedPct;
    }

    int startCharges = Jass::R2I(Piro::E_StartCharge + Piro::E_ThenCharge * capAS);
    if (startCharges < 0) {
        startCharges = 0;
    }
    HSetAbilityCharges(u, 'A00X', startCharges);
}

void InitHeroSkills(unit u) {
    if (u == nil || !Jass::IsUnitHero(u)) return;
    if (Jass::GetUnitTypeId(u) == 'h04I' || Jass::IsUnitIllusion(u)) return;

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if (pid < 0 || pid >= 10) return;

    Jass::RemoveUnit(g_HeroTaker[pid]);
    Jass::RemoveUnit(g_HeroTaker2[pid]);
    g_HeroTaker[pid] = nil;
    g_HeroTaker2[pid] = nil;

    OSA_ApplyHeroItemOwnership(u);

    if (IsUnitEngineer(u)) {
        Jass::SetPlayerState(Jass::GetOwningPlayer(u), Jass::PLAYER_STATE_RESOURCE_GOLD, 1000);
    }
    if(false)
        OSA_StartStalkerECharge(u);

    if (Jass::GetUnitAbilityLevel(u, 'A19P') > 0) {
        Podr::R_SetCharges(u);
    }
    if(false)
        OSA_StartPiroA00XPassive(u);
}

void OnUnitEnterMap() {
    unit u = Jass::GetTriggerUnit();
    int typeId = Jass::GetUnitTypeId(u);
    RegisterUnit(u);
    string key = "" + typeId;

    if (g_OnSpawnHandlers.exists(key)) {
		OnSpawnCallback@ cb = cast<OnSpawnCallback@>(g_OnSpawnHandlers[key]);
		if (cb !is null) {
			cb(u);
		}
	}

    if(Jass::IsUnitHero(u) && !Jass::IsUnitIllusion(u) && Jass::GetUnitTypeId(u) != 'h04I' && Jass::GetPlayerId(Jass::GetOwningPlayer(u)) < 10) {
        GoblinUnit[Jass::GetPlayerId(Jass::GetOwningPlayer(u))] = u;
        Jass::GroupAddUnit(Goblinzz, u);
        InitHeroSkills(u);
    }

    for(int i = 0; i <= 5; i++) {
        UnitData@ ud = GetUnitData(u);

        if(typeId == g_Gliba[i]) {
            Jass::GroupAddUnit(Ores, u);
            Gliba_Counter++;
            Jass::ConsolePrint("\nGliba Counter: " + Gliba_Counter);
            if(Gliba_Counter <= 5) {
                ud.OreType = 0;
            } else if(Gliba_Counter <= 9) {
                ud.OreType = 1;
            } else if(Gliba_Counter <= 11) {
                ud.OreType = 2;
            } else if(Gliba_Counter <= 12) {
                ud.OreType = 3;
                Gliba_Counter = 0;
            }
            break;
        }
    }

    if(typeId == 'o000') {
        int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
        BunkerUnit[pn] = u;
        UnitData@ ud = GetUnitData(u);
        ud.CanOnHit = true;
        ud.DummySource = GoblinUnit[pn]; 
        ud.dummyDamage = HGetUnitAD(GoblinUnit[pn]) * 0.65;
        ud.dmgType = Jass::DAMAGE_TYPE_MAGIC;
        ud.IsDummy = true;
    }
    u = nil;
}

void InitSpawnTrigger() {
    region reg = Jass::CreateRegion();
    Jass::RegionAddRect(reg, mapInitialPlayableArea);

    trigger trg_OnEnterMap = Jass::CreateTrigger();
    Jass::TriggerRegisterEnterRegion(trg_OnEnterMap, reg, nil);
    Jass::TriggerAddAction(trg_OnEnterMap, @OnUnitEnterMap);
    trg_OnEnterMap = nil;
    reg = nil;

    GoblinUnit.resize(10);
    BunkerUnit.resize(10);
    Goblinzz = Jass::CreateGroup();
    Ores = Jass::CreateGroup();
}
