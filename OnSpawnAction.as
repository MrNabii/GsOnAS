// ============================================================
//  OnSpawnAction.as — Триггер входа юнита в игровую область
// ============================================================
//import UnitStats.as

#include "UnitStats.as"

void OnUnitEnterMap() {
    unit u = Jass::GetTriggerUnit();
    int typeId = Jass::GetUnitTypeId(u);
    RegisterUnit(u);

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
}
