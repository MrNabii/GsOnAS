// ============================================================
//  DamageSystem.as — Система нанесения и обработки урона
// ============================================================
// Зависит от: UnitStats.as (UnitData, GetUnitData, UnitStatsData)
// Использует UjAPI: BlzGetEventIsAttack, GetEventDamageType,
//   GetEventAttackType, SetEventAttackType, SetEventDamageType,
//   BlzSetEventDamage, GetEventDamageSource, BlzGetEventDamageTarget

// --- Тип урона ---
#include "UnitStats.as"
const int DMG_PHYSICAL = 0;  // физический (бонус: bonusPhysDamage; уменьш.: броня + resistPhysical)
const int DMG_MAGIC    = 1;  // магический (бонус: bonusMagDamage; уменьш.: resistMagic)
const int DMG_PURE     = 2;  // чистый (игнорирует все модификаторы)

// Мап WC3 damagetype → наш DMG_*
int WC3DamageTypeToLocal(damagetype dt) {
    int id = Jass::GetHandleId(dt);
    // DAMAGE_TYPE_MAGIC=14, DAMAGE_TYPE_FIRE=8, DAMAGE_TYPE_COLD=9,
    // DAMAGE_TYPE_LIGHTNING=10, DAMAGE_TYPE_MIND=19, DAMAGE_TYPE_PLANT=20,
    // DAMAGE_TYPE_SONIC=15, DAMAGE_TYPE_ACID=16, DAMAGE_TYPE_FORCE=17
    if (id == 14 || id == 8 || id == 9 || id == 10 ||
        id == 19 || id == 20 || id == 15 || id == 16 || id == 17)
        return DMG_MAGIC;
    // Всё остальное (NORMAL=4, ENHANCED=5, и т.д.) = физический
    return DMG_PHYSICAL;
}

// --- Callback триггерного урона (вызывается ПОСЛЕ нанесения) ---
funcdef void DamageCallbackFn(unit source, unit target, float finalDamage);

// --- Callback on-hit пассивок (при атаке юнита, НЕ при триггерном уроне) ---
funcdef void OnHitCallbackFn(unit attacker, unit target, float finalDamage);

// --- Глобальное состояние текущего урона ---
bool                gDmg_IsTrigger = false;
damagetype          gDmg_Type;
unit                gDmg_RealSource;
float               gDmg_Amount    = 0;
DamageCallbackFn@   gDmg_Callback  = null;

// Даммики для триггерного урона — по одному на каждого игрока (rawcode настроить в OE)
const int DAMAGE_DUMMY_ID = 'dumm';
array<unit> DamageDummy(16);

// Зарегистрированные on-hit пассивки
array<OnHitCallbackFn@> OnHitCallbacks;

void RegisterOnHit(OnHitCallbackFn@ cb) {
    if (cb !is null) OnHitCallbacks.insertLast(@cb);
}

// ---------- Расчёт урона ----------

// Рассчитать финальный урон с учётом модификаторов (без армора — его считает WC3)
float CalcDamage(UnitData@ src, UnitData@ tgt, float raw, int dmgType) {
    float dmg = raw;
    if (dmgType == DMG_PURE) return (dmg < 0) ? 0 : dmg;

    // --- Бонусы атакующего ---
    if (src !is null) {
        float bonus = src.totalStats.bonusAllDamage;
        if (dmgType == DMG_PHYSICAL) bonus += src.totalStats.bonusPhysDamage;
        else                         bonus += src.totalStats.bonusMagDamage;
        dmg *= (1 + bonus);
    }

    // --- Защита цели ---
    if (tgt !is null) {
        // Резисты
        float resist = tgt.totalStats.resistAll;
        if (dmgType == DMG_PHYSICAL) resist += tgt.totalStats.resistPhysical;
        else                          resist += tgt.totalStats.resistMagic;
        dmg *= (1 - resist);
        // Блокирование (плоское)
        dmg -= tgt.totalStats.block;
    }

    return (dmg < 0) ? 0 : dmg;
}

// ---------- Обработчик EVENT_PLAYER_UNIT_DAMAGED ----------
// Срабатывает ПОСЛЕ армора WC3. GetEventDamage() = урон после армора.
void OnUnitDamaged() {
    unit target   = Jass::BlzGetEventDamageTarget();
    unit source   = Jass::GetEventDamageSource();
    float rawDmg  = Jass::GetEventDamage();

    if (rawDmg <= 0) { target = nil; source = nil; return; }

    // --- UjAPI: информация о событии ---
    bool isAttack         = Jass::GetEventIsAttack();
    damagetype evDamage   = Jass::GetEventDamageType();

    // --- Определяем источник и тип ---
    bool isTrigger        = gDmg_IsTrigger;
    unit realSource       = isTrigger ? gDmg_RealSource : source;
    float amount          = isTrigger ? gDmg_Amount     : rawDmg;
    DamageCallbackFn@ cb  = gDmg_Callback;

    damagetype dtWC3 = isTrigger ? gDmg_Type : evDamage;
    int dmgType = WC3DamageTypeToLocal(dtWC3);

    UnitData@ srcData = GetUnitData(realSource);
    UnitData@ tgtData = GetUnitData(target);

    float finalDamage = CalcDamage(srcData, tgtData, amount, dmgType);

    // Крит — только при обычной атаке (isAttack && !триггерный)
    if (isAttack && !isTrigger && srcData !is null && srcData.totalStats.critChance > 0) {
        if (Jass::GetRandomReal(0, 100) < srcData.totalStats.critChance)
            finalDamage *= (1 + srcData.totalStats.critDamage / 100);
    }

    Jass::SetEventDamage(finalDamage);

    if (isTrigger) {
        if (cb !is null) cb(realSource, target, finalDamage);
    } else if (isAttack) {
        for (uint i = 0; i < OnHitCallbacks.length(); i++)
            OnHitCallbacks[i](realSource, target, finalDamage);
    }

    @cb = null;
    realSource = nil;
    target = nil;
    source = nil;
    dtWC3 = nil;
    evDamage = nil;
}

// ---------- API нанесения урона ----------

// Нанести триггерный урон (от скиллов/предметов, НЕ вызывает on-hit пассивки)
// source    — реальный источник (герой/кастер), его bonusDamage применятся
// target    — цель
// amount    — базовый урон (ДО модификаторов)
// dmgType   — Jass::DAMAGE_TYPE_NORMAL / DAMAGE_TYPE_MAGIC / DAMAGE_TYPE_UNIVERSAL и т.д.
// cb        — callback после нанесения (null = не нужен)
void DealDamage(unit source, unit target, float amount, damagetype dmgType, DamageCallbackFn@ cb = null) {
    if (target == nil || amount <= 0) return;

    // Сохранить предыдущее состояние (для вложенных вызовов из callback)
    bool prevTrigger                = gDmg_IsTrigger;
    damagetype prevType             = gDmg_Type;
    unit prevSource                 = gDmg_RealSource;
    float prevAmount                = gDmg_Amount;
    DamageCallbackFn@ prevCb        = gDmg_Callback;

    gDmg_IsTrigger  = true;
    gDmg_Type       = dmgType;
    gDmg_RealSource = source;
    gDmg_Amount     = amount;
    @gDmg_Callback  = @cb;

    // Даммик источника (по владельцу source, fallback = Player(15))
    int pid = 15;
    if (source != nil)
        pid = Jass::GetPlayerId(Jass::GetOwningPlayer(source));

    // attacktype берём из source (его первая атака, index 0)
    attacktype srcAtk = Jass::ATTACK_TYPE_CHAOS;
    if (source != nil)
        srcAtk = Jass::GetUnitAttackTypeByIndex(source, 0);

    Jass::UnitDamageTarget(DamageDummy[pid], target, amount, true, false,
        srcAtk, dmgType, Jass::WEAPON_TYPE_WHOKNOWS);

    // Восстановить контекст
    gDmg_IsTrigger  = prevTrigger;
    gDmg_Type       = prevType;
    gDmg_RealSource = prevSource;
    gDmg_Amount     = prevAmount;
    @gDmg_Callback  = @prevCb;
    srcAtk = nil;
    prevType = nil;
    prevSource = nil;
    @prevCb = null;
}

// Инициализация системы урона (вызвать в main init)
void InitDamageSystem() {
    for (int i = 0; i < 16; i++) {
        DamageDummy[i] = Jass::CreateUnit(Jass::Player(i), DAMAGE_DUMMY_ID, 0, 0, 0);
        Jass::ShowUnit(DamageDummy[i], false);
    }

    trigger trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++)
        Jass::TriggerRegisterPlayerUnitEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_UNIT_DAMAGED, nil);
    Jass::TriggerAddAction(trg, @OnUnitDamaged);
    trg = nil;
    Jass::ConsolePrint("Damage system initialized.");
}
