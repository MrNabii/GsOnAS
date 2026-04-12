//import UnitStats.as

#include "UnitStats.as"
array<unit> GoblinUnit;
array<unit> BunkerUnit;
group Goblinzz;
group Ores;
int Gliba_Counter = 0;
void OnUnitEnterMap() {
    unit u = Jass::GetTriggerUnit();
    int typeId = Jass::GetUnitTypeId(u);
    RegisterUnit(u);

    if(Jass::IsUnitHero(u) && Jass::GetPlayerId(Jass::GetOwningPlayer(u)) < 10) {
        GoblinUnit[Jass::GetPlayerId(Jass::GetOwningPlayer(u))] = u;
        Jass::GroupAddUnit(Goblinzz, u);
    }

    // Враги — добавить в группу мобов для портального pathfinding
    int ownerId = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if (ownerId >= 10 && ownerId <= 11 && !Jass::IsUnitHero(u) && Jass::GetUnitMoveSpeed(u) > 0) {
        PP_AddMob(u);
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
