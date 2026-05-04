//import UnitStats.as

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
const int DAMAGE_DUMMY_ID = 'hdum';
array<unit> DamageDummy(16);

// Зарегистрированные on-hit пассивки
array<OnHitCallbackFn@> OnHitCallbacks;

void RegisterOnHit(OnHitCallbackFn@ cb) {
    if (cb !is null) OnHitCallbacks.insertLast(@cb);
}

bool DS_IsUnitMedicHero(unit u) {
    if (u == nil) return false;
    int id = Jass::GetUnitTypeId(u);
    return id == 'H002' || id == 'H102';
}

unit DS_FindReadyMedicSaver(unit target) {
    if (target == nil) return nil;

    unit result = nil;
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(target), Jass::GetUnitY(target), 750.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2)
            && DS_IsUnitMedicHero(u2)
            && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(target))
            && Jass::GetUnitAbilityLevel(u2, 'A19L') >= 3) {
            ability medUlt = Jass::GetUnitAbility(u2, 'A19L');
            if (medUlt != nil && Jass::GetAbilityRemainingCooldown(medUlt) <= 0.01) {
                result = u2;
                medUlt = nil;
                break;
            }
            medUlt = nil;
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
    g = nil;

    return result;
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
    unit target   = Jass::GetEventDamageTarget();
    unit source   = Jass::GetEventDamageSource();
    float rawDmg  = Jass::GetEventDamage();
    float TargetCurrentHp = Jass::GetUnitCurrentLife(target);

    // Для триггерного урона (через DamageDummy) rawDmg может прийти как 0,
    // поэтому ранний выход делаем только для обычного (не-триггерного) урона.
    bool isTrigger        = gDmg_IsTrigger;

    if (rawDmg <= 0 && !isTrigger) { target = nil; source = nil; return; }

    // --- UjAPI: информация о событии ---
    bool isAttack         = Jass::GetEventIsAttack();
    damagetype evDamage   = Jass::GetEventDamageType();

    // --- Определяем источник и тип ---
    unit realSource       = isTrigger ? gDmg_RealSource : source;
    float amount          = isTrigger ? gDmg_Amount     : rawDmg;
    DamageCallbackFn@ cb  = gDmg_Callback;


    UnitData@ DummyData = GetUnitData(realSource);
    bool isDummy = (DummyData !is null) ? DummyData.IsDummy : false;
    DamageCallbackFn@ DummyCb = (DummyData !is null) ? DummyData.dummyDamageCallback : null;
    float DummyDamage = (DummyData !is null) ? DummyData.dummyDamage : 0; 
    damagetype dummyDmgType = (DummyData !is null) ? DummyData.dmgType : evDamage;
    float finalDamage;
    bool CanOnHit = (DummyData !is null) ? DummyData.CanOnHit : false;

    if (isDummy && DummyData.DummySource != nil && CanOnHit) {
        realSource = DummyData.DummySource; // для коллбека "пустышки" источник — это её DummySource, который должен быть установлен перед атакой
    }

    damagetype dtWC3 = isTrigger ? gDmg_Type : evDamage;
    int dmgType = WC3DamageTypeToLocal(dtWC3);

    UnitData@ srcData = GetUnitData(realSource);
    UnitData@ tgtData = GetUnitData(target);

    if (Jass::IsUnitInGroup(target, Ores)) {
        finalDamage = 500;
        bool isEngineer = false;
        if(IsUnitEngineer(source)) {
            finalDamage = 250;
            isEngineer = true;
            if(UnitHaveBuff(source, 'A0M8')){
                finalDamage *= 0.8; // 20% меньше урона от руды, если есть бафф от E
            }
        }
        Jass::SetEventDamage(finalDamage);

        if (!isEngineer) return;
        int Oretype = tgtData.OreType;
        int ItemTypeId;
        int ItemNumber = 1; 


        if(Oretype == 1) {
            ItemTypeId = 'I001';
        } else if(Oretype == 2) {
            ItemTypeId = 'I002';
        } else if(Oretype == 3) {
            ItemTypeId = 'I003';
        } else {
            ItemTypeId = 'I000';
        }
        for(int i = 0; i < ItemNumber; i++) {
            CreateItemCustom(ItemTypeId, Jass::GetUnitX(source), Jass::GetUnitY(source));
        }
        float randomChance = Jass::GetRandomReal(0, 100);
        Debug("OnUnitDamaged", "\nRandom Chance for Bonus Item: " + Jass::R2S(randomChance) + "% (Luck: " + Jass::R2S(srcData.totalStats.luck) + ")");
        if(randomChance < Engineer::E_ChanceStart * (srcData.totalStats.luck/Engineer::E_ChanceLuck + 1)) {
            int RandomItem = Jass::GetRandomInt(1, 6);
            if(RandomItem == 1) {
                ItemTypeId = 'I051';
            } else if(RandomItem == 2) {
                ItemTypeId = 'I050';
            } else if(RandomItem == 3) {
                ItemTypeId = 'I04Z';
            } else if(RandomItem == 4) {
                ItemTypeId = 'I04Y';
            } else if(RandomItem == 5) {
                ItemTypeId = 'I04X';
            } else if(RandomItem == 6) {
                ItemTypeId = 'I052';
            }
            for(int i = 0; i < ItemNumber; i++) {
                CreateItemCustom(ItemTypeId, Jass::GetUnitX(source), Jass::GetUnitY(source));
            }
        }
        return;
    }
    
    if (isDummy) {
        // Даммик вызывает коллбек, который должен вернуть finalDamage через gDmg_Amount
        if (DummyCb !is null) DummyCb(realSource, target, amount);
        Jass::SetEventDamageType(dummyDmgType);
        finalDamage = CalcDamage(srcData, tgtData, DummyDamage, dummyDmgType);
    }
    else
        finalDamage = CalcDamage(srcData, tgtData, amount, dmgType);
    if (srcData !is null && srcData.totalStats.critChance > 0) {
        if (Jass::GetRandomReal(0, 100) < srcData.totalStats.critChance)
            finalDamage *= (1 + srcData.totalStats.critDamage / 100);
    }   

    if(Jass::GetUnitAbilityLevel(target, 'B092') > 0 && Jass::GetUnitAbilityLevel(target, 'A05N') >= 2) {
        if(HGetAbilityCharges(target, 'A05N') > 0) {
            finalDamage *= 0.7; // 30% меньше урона, если есть хотя бы 1 заряд от R   
            HSetAbilityCharges(target, 'A05N', 0);
        }
        if(srcData !is null && srcData.isMinik) {
            finalDamage *= 0.7; // дополнительно 30% меньше урона для миников
        }
        if(TargetCurrentHp <= finalDamage+3) { // если удар должен убить юнита
            if(Jass::GetUnitAbilityLevel(target, 'A05N') >= 3 && Jass::GetAbilityRemainingCooldown(Jass::GetUnitAbility(target, 'A05N')) <= 0) {
                Jass::StartAbilityCooldown(Jass::GetUnitAbility(target, 'A05N'), 120);
                Jass::SetUnitCurrentLife(target, Jass::GetUnitMaxLife(target)); // оставляем 1 HP, чтобы юнит не умер
                finalDamage = 0;
            }
        }
    }

    // Медик T3: спасение отмеченной цели и автоспас рядом с медиком с готовой ультой.
    if (finalDamage > 0 && TargetCurrentHp <= finalDamage + 3) {
        int targetHandle = Jass::GetHandleId(target);
        bool wasSaved = false;

        if (Jass::LoadInteger(SkillHT, targetHandle, 'A0SZ') == 1) {
            unit saver = Jass::LoadUnitHandle(SkillHT, targetHandle, 'A19K');
            if (saver != nil
                && Jass::IsUnitAlive(saver)
                && Jass::IsUnitAlly(saver, Jass::GetOwningPlayer(target))
                && Jass::LoadInteger(SkillHT, Jass::GetHandleId(saver), 'A0SZ') > 0) {
                Jass::SaveInteger(SkillHT, Jass::GetHandleId(saver), 'A0SZ', 0);
                Jass::RemoveSavedInteger(SkillHT, targetHandle, 'A0SZ');
                Jass::RemoveSavedHandle(SkillHT, targetHandle, 'A19K');
                Jass::UnitRemoveAbility(target, 'A0SZ');
                Jass::SetUnitCurrentLife(target, Jass::GetUnitMaxLife(target));
                Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
                    "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", target, "origin"));
                Debug("OnUnitDamaged", "Medic T3 save consumed: target=" + Jass::GetUnitName(target) + ", saver=" + Jass::GetUnitName(saver));
                finalDamage = 0;
                wasSaved = true;
            }
            saver = nil;
        }

        if (!wasSaved) {
            unit med = DS_FindReadyMedicSaver(target);
            if (med != nil) {
                ability medUlt = Jass::GetUnitAbility(med, 'A19L');
                if (medUlt != nil) {
                    Jass::StartAbilityCooldown(medUlt, 60.0);
                }
                Jass::SetUnitCurrentLife(target, Jass::GetUnitMaxLife(target));
                Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
                    "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", target, "origin"));
                Debug("OnUnitDamaged", "Medic auto-save triggered: target=" + Jass::GetUnitName(target) + ", medic=" + Jass::GetUnitName(med));
                finalDamage = 0;
                medUlt = nil;
            }
            med = nil;
        }
    }
















    bool drawText = false;
    if(drawText) {
        Jass::SetTextTagColor(CreateTextTagTimed("" + int(amount), target, 0.02, 2.0), 100, 255, 100, 255);
    }

    Jass::SetEventDamage(finalDamage);
    Debug("OnUnitDamaged", "\nDealing damage: " + finalDamage + " from " + ((source != nil) ? Jass::GetUnitName(source) : "nil") + " to " + ((target != nil) ? Jass::GetUnitName(target) : "nil"));






    if (isTrigger) {
        if (cb !is null) cb(realSource, target, finalDamage);
    } else if (isAttack || CanOnHit) {
        for (uint i = 0; i < OnHitCallbacks.length(); i++)
            OnHitCallbacks[i](realSource, target, finalDamage);
        // Hero skill on-attack callbacks
        HFireOnAttack(realSource, target);
    }
    // Hero skill on-damage callbacks (при любом входящем уроне)
    HFireOnDamage(realSource, target);

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

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, source);
    Jass::SaveUnitHandle(SkillHT, th, 1, target);
    Jass::SaveReal(SkillHT, th, 0, amount);
    Jass::SaveDamageTypeHandle(SkillHT, th, 2, dmgType);
    Jass::TimerStart(t, 0.01, false, function() {
        timer t = Jass::GetExpiredTimer();
        int th = Jass::GetHandleId(t);
        unit source = Jass::LoadUnitHandle(SkillHT, th, 0);
        unit target = Jass::LoadUnitHandle(SkillHT, th, 1);
        float amount = Jass::LoadReal(SkillHT, th, 0);
        damagetype dmgType = Jass::LoadDamageTypeHandle(SkillHT, th, 2);
        attacktype atcType = Jass::ATTACK_TYPE_CHAOS; // по умолчанию, можно переопределить в коллбеке
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);

        int pid = 15;
        if (source != nil)
        {
        pid = Jass::GetPlayerId(Jass::GetOwningPlayer(source));
        atcType = Jass::GetUnitAttackTypeByIndex(source, 0);
        }
        

        // Установить глобальные флаги ДО UnitDamageTarget,
        // чтобы OnUnitDamaged знал, что это триггерный урон от source
        bool prevTrigger     = gDmg_IsTrigger;
        damagetype prevType  = gDmg_Type;
        unit prevSource      = gDmg_RealSource;
        float prevAmount     = gDmg_Amount;
        DamageCallbackFn@ prevCb = gDmg_Callback;

        gDmg_IsTrigger  = true;
        gDmg_Type       = dmgType;
        gDmg_RealSource = source;
        gDmg_Amount     = amount;
        @gDmg_Callback  = null;
        Debug("DealDamage", "\nDealing trigger damage: " + amount + " from " + ((DamageDummy[pid] != nil) ? Jass::GetUnitName(DamageDummy[pid]) : "nil") + " to " + ((target != nil) ? Jass::GetUnitName(target) : "nil"));
        Jass::UnitDamageTarget(DamageDummy[pid], target, amount, true, false,
        atcType, dmgType, Jass::WEAPON_TYPE_WHOKNOWS);

        gDmg_IsTrigger  = prevTrigger;
        gDmg_Type       = prevType;
        gDmg_RealSource = prevSource;
        gDmg_Amount     = prevAmount;
        @gDmg_Callback  = @prevCb;
    });
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
    Debug("InitDamageSystem", "Damage system initialized.");
}
