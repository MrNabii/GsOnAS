// ============================================================
//  UnitStats.as — Система статов юнита
// ============================================================

// ---------- Базовая структура статов ----------
class UnitStatsData {
    // Атрибуты
    float strength;         // Сила
    float strengthPct;      // % Сила
    float agility;          // Ловкость
    float agilityPct;       // % Ловкость
    float intelligence;     // Разум
    float intelligencePct;  // % Разум
    float mainStat;         // Основной стат
    float mainStatPct;      // % Основной стат

    // Здоровье / Мана
    float hp;               // Хп
    float hpPct;            // % Хп
    float mp;               // Мп
    float mpPct;            // % Мп
    float hpRegen;          // Регенерация хп
    float hpRegenPct;       // % Регенерация хп
    float hpRegenPercent;   // Процент регенерации хп
    float mpRegen;          // Регенерация мп
    float mpRegenPct;       // % Регенерация мп

    // Атака
    float damage;           // Атака
    float damagePct;        // % Атака
    float attackSpeed;      // Скорость атаки
    float attackSpeedPct;   // % Скорость атаки
    float critDamage;       // Крит Урон
    float critChance;       // Крит Шанс
    float stunChance;       // Шанс стана
    float stunDuration;     // Время стана

    // Защита
    float armor;            // Защита
    float armorPct;         // % Защита
    float block;            // Блокирование
    float resistMagic;      // Сопротивление маг. урону
    float resistPhysical;   // Сопротивление физ. урону
    float resistAll;        // Сопротивление урону

    // Урон (множители)
    float bonusPhysDamage;  // Увеличение физ. урона
    float bonusMagDamage;   // Увеличение маг. урона
    float bonusAllDamage;   // Увеличение всего урона

    // Хил
    float healReceived;     // Получаемый хил
    float healOutput;       // Исходящий хил

    // Прочее
    float moveSpeed;        // Скорость бега
    float moveSpeedPct;     // % Скорость бега
    float radius;           // Радиус
    float radiusPct;        // % Радиус
    float detection;        // Обнаружение
    float detectionPct;     // % Обнаружение
    float luck;             // Удача
    float luckPct;          // % Удача

    void Reset() {
        strength = 0;    strengthPct = 0;
        agility = 0;     agilityPct = 0;
        intelligence = 0; intelligencePct = 0;
        mainStat = 0;    mainStatPct = 0;
        hp = 0;          hpPct = 0;
        mp = 0;          mpPct = 0;
        hpRegen = 0;     hpRegenPct = 0;    hpRegenPercent = 0;
        mpRegen = 0;     mpRegenPct = 0;
        damage = 0;      damagePct = 0;
        attackSpeed = 0; attackSpeedPct = 0;
        critDamage = 0;  critChance = 0;  stunChance = 0;  stunDuration = 0;
        armor = 0;       armorPct = 0;    block = 0;
        resistMagic = 0; resistPhysical = 0;  resistAll = 0;
        bonusPhysDamage = 0;  bonusMagDamage = 0;  bonusAllDamage = 0;
        healReceived = 0;     healOutput = 0;
        moveSpeed = 0;   moveSpeedPct = 0;
        radius = 0;      radiusPct = 0;
        detection = 0;   detectionPct = 0;
        luck = 0;        luckPct = 0;
    }

    void Add(const UnitStatsData &in o) {
        strength       += o.strength;        strengthPct      += o.strengthPct;
        agility        += o.agility;         agilityPct       += o.agilityPct;
        intelligence   += o.intelligence;    intelligencePct  += o.intelligencePct;
        mainStat       += o.mainStat;        mainStatPct      += o.mainStatPct;
        hp             += o.hp;              hpPct            += o.hpPct;
        mp             += o.mp;              mpPct            += o.mpPct;
        hpRegen        += o.hpRegen;         hpRegenPct       += o.hpRegenPct;
        hpRegenPercent += o.hpRegenPercent;
        mpRegen        += o.mpRegen;         mpRegenPct       += o.mpRegenPct;
        damage         += o.damage;          damagePct        += o.damagePct;
        attackSpeed    += o.attackSpeed;     attackSpeedPct   += o.attackSpeedPct;
        critDamage     += o.critDamage;
        critChance     += o.critChance;
        stunChance     += o.stunChance;
        stunDuration   += o.stunDuration;
        armor          += o.armor;           armorPct         += o.armorPct;
        block          += o.block;
        resistMagic    += o.resistMagic;
        resistPhysical += o.resistPhysical;
        resistAll      += o.resistAll;
        bonusPhysDamage += o.bonusPhysDamage;
        bonusMagDamage  += o.bonusMagDamage;
        bonusAllDamage  += o.bonusAllDamage;
        healReceived   += o.healReceived;
        healOutput     += o.healOutput;
        moveSpeed      += o.moveSpeed;      moveSpeedPct     += o.moveSpeedPct;
        radius         += o.radius;          radiusPct        += o.radiusPct;
        detection      += o.detection;       detectionPct     += o.detectionPct;
        luck           += o.luck;            luckPct          += o.luckPct;
    }

}

// ---------- Уровни очищения ----------
const int PURGE_NONE    = 0; // не очищается
const int PURGE_NORMAL  = 1; // обычное очищение
const int PURGE_STRONG  = 2; // сильное очищение
const int PURGE_DEMONIC = 3; // демоническое очищение

// ---------- Коэффициенты: бонус от 1 очка стата ----------
const float STR_TO_HP       = 20.0;  // 1 сила       = +20 хп
const float STR_TO_HPREGEN  = 0.05;  // 1 сила       = +0.05 реген хп
const float AGI_TO_ARMOR    = 0.3;   // 1 ловкость   = +0.3 защиты
const float AGI_TO_AS       = 0.02;  // 1 ловкость   = +0.02 скорость атаки
const float INT_TO_MP       = 15.0;  // 1 разум      = +15 маны
const float INT_TO_MPREGEN  = 0.05;  // 1 разум      = +0.05 реген маны
const float MAINSTAT_TO_DMG = 1.0;   // 1 основной стат = +1 урон

// ---------- Бафф (один тип — один экземпляр, не стакается) ----------
class Buff {
    int    buffTypeId;   // уникальный id типа баффа
    float  duration;     // оставшееся время (-1 = бессрочный)
    bool   isBuff;       // true = бафф, false = дебафф
    int    purgeLevel;   // PURGE_NONE / PURGE_NORMAL / PURGE_STRONG / PURGE_DEMONIC
    UnitStatsData stats; // бонусы от этого баффа
}

// ---------- Шаблон базовых статов предмета ----------
class ItemBaseTemplate {
    int    itemTypeId;
    int    itemLevel;
    int    abilityId;      // rawcode активной способности (0 = нет)
    float  abilityCooldown; // кд способности
    float  abilityManaCost; // мана кост способности
    UnitStatsData stats;
}

// ---------- Предмет, дающий статы ----------
class ItemStats {
    int    itemTypeId;
    int    itemHandleId;   // handle ID конкретного item в мире
    int    slot;           // слот инвентаря 0-17
    int    itemLevel;      // уровень предмета
    int    abilityId;      // rawcode активной способности (0 = нет)
    float  abilityCooldown; // кд способности
    float  abilityManaCost; // мана кост способности
    UnitStatsData stats;
}

// ---------- Данные юнита ----------
class UnitData {
    UnitStatsData  baseStats;      // базовые статы (уровень, начальные)
    UnitStatsData  totalStats;     // итоговые (readonly, пересчитываются)
    UnitStatsData  statDerived;    // бонусы, вычисленные из статов (Сила→ХП и т.д.)

    array<ItemStats@> items;       // предметы
    array<Buff@>      buffs;       // активные баффы

    // --- Предметы ---
    void AddItem(ItemStats@ itm, unit u) {
        if (itm is null) return;
        items.insertLast(itm);
        Recalc(u);
    }

    void RemoveItem(int slot, unit u) {
        for (uint i = 0; i < items.length(); i++) {
            if (items[i].slot == slot) {
                items.removeAt(i);
                Recalc(u);
                return;
            }
        }
    }

    void RemoveItemByHandle(int handleId, unit u) {
        for (uint i = 0; i < items.length(); i++) {
            if (items[i].itemHandleId == handleId) {
                items.removeAt(i);
                Recalc(u);
                return;
            }
        }
    }

    // --- Баффы (один тип не стакается — перезаписывается) ---
    void AddBuff(Buff@ b, unit u) {
        if (b is null) return;
        // если бафф такого типа уже есть — заменяем
        for (uint i = 0; i < buffs.length(); i++) {
            if (buffs[i].buffTypeId == b.buffTypeId) {
                @buffs[i] = b;
                Recalc(u);
                return;
            }
        }
        buffs.insertLast(b);
        Recalc(u);
    }

    void RemoveBuff(int buffTypeId, unit u) {
        for (uint i = 0; i < buffs.length(); i++) {
            if (buffs[i].buffTypeId == buffTypeId) {
                buffs.removeAt(i);
                Recalc(u);
                return;
            }
        }
    }

    bool HasBuff(int buffTypeId) {
        for (uint i = 0; i < buffs.length(); i++) {
            if (buffs[i].buffTypeId == buffTypeId)
                return true;
        }
        return false;
    }

    // --- Вычислить бонусы от статов (Сила→ХП, Ловкость→Защита и т.д.) ---
    void ComputeStatDerived() {
        statDerived.Reset();

        // Тип основного стата из базового шаблона (0=str, 1=agi, 2=int)
        int mainStatType = Jass::R2I(baseStats.mainStat);

        // mainStat бонус от предметов/баффов (без идентификатора из baseStats)
        float mainStatBonus = (totalStats.mainStat - baseStats.mainStat) * (1 + totalStats.mainStatPct / 100);

        // Эффективные значения статов (с учётом %)
        float effStr = totalStats.strength     * (1 + totalStats.strengthPct / 100);
        float effAgi = totalStats.agility      * (1 + totalStats.agilityPct / 100);
        float effInt = totalStats.intelligence * (1 + totalStats.intelligencePct / 100);

        // Добавить mainStat бонус к соответствующему стату
        if (mainStatType == 0)      effStr += mainStatBonus;
        else if (mainStatType == 1) effAgi += mainStatBonus;
        else                        effInt += mainStatBonus;

        // Сила → ХП, реген хп
        statDerived.hp      += effStr * STR_TO_HP;
        statDerived.hpRegen += effStr * STR_TO_HPREGEN;

        // Ловкость → Защита, скорость атаки
        statDerived.armor       += effAgi * AGI_TO_ARMOR;
        statDerived.attackSpeed += effAgi * AGI_TO_AS;

        // Разум → МП, реген маны
        statDerived.mp      += effInt * INT_TO_MP;
        statDerived.mpRegen += effInt * INT_TO_MPREGEN;

        // Основной стат → Урон
        float effMainTotal;
        if (mainStatType == 0)      effMainTotal = effStr;
        else if (mainStatType == 1) effMainTotal = effAgi;
        else                        effMainTotal = effInt;
        statDerived.damage += effMainTotal * MAINSTAT_TO_DMG;
    }

    // --- Пересчёт итоговых статов ---
    void Recalc(unit u) {
        totalStats.Reset();
        totalStats.Add(baseStats);

        // Только предметы в слотах 0-5 дают статы
        for (uint i = 0; i < items.length(); i++) {
            if (items[i].slot >= 0 && items[i].slot <= 5)
                totalStats.Add(items[i].stats);
        }

        for (uint i = 0; i < buffs.length(); i++)
            totalStats.Add(buffs[i].stats);

        // Вычислить и добавить бонусы от статов
        ComputeStatDerived();
        totalStats.Add(statDerived);

        ApplyToUnit(u);
    }

    // --- Получить или создать абилку на юните ---
    ability GetOrCreateAbil(unit u, int abilCode) {
        ability abil = Jass::GetUnitAbility(u, abilCode);
        if (abil == nil) {
            abil = Jass::CreateAbility(abilCode);
            Jass::SetAbilityOwner(abil, u);
        }
        return abil;
    }

    // --- Применить бонусные статы к юниту (зелёные) ---
    void ApplyToUnit(unit u) {
        if (u == nil) return;
        ability abil;
        // Бонус = total * (1 + pct/100) - base
        float bonusStr   = totalStats.strength    * (1 + totalStats.strengthPct / 100)    - baseStats.strength;
        float bonusAgi   = totalStats.agility     * (1 + totalStats.agilityPct / 100)     - baseStats.agility;
        float bonusInt   = totalStats.intelligence* (1 + totalStats.intelligencePct / 100) - baseStats.intelligence;
        float bonusArmor = totalStats.armor       * (1 + totalStats.armorPct / 100)       - baseStats.armor;
        float bonusDmg   = totalStats.damage      * (1 + totalStats.damagePct / 100)      - baseStats.damage;
        float bonusAS    = totalStats.attackSpeed  * (1 + totalStats.attackSpeedPct / 100) - baseStats.attackSpeed;
        float bonusHP    = totalStats.hp           * (1 + totalStats.hpPct / 100)          - baseStats.hp;
        float bonusMP    = totalStats.mp           * (1 + totalStats.mpPct / 100)          - baseStats.mp;
        float bonusHPR   = totalStats.hpRegen      * (1 + totalStats.hpRegenPct / 100)    - baseStats.hpRegen;
        float bonusMPR   = totalStats.mpRegen      * (1 + totalStats.mpRegenPct / 100)    - baseStats.mpRegen;
        float bonusMS    = totalStats.moveSpeed    * (1 + totalStats.moveSpeedPct / 100)  - baseStats.moveSpeed;

        // Сила + Ловкость + Разум (AIa1 — Attribute Bonus)
        abil = GetOrCreateAbil(u, 'AIa1');
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_STRENGTH_BONUS_ISTR, 0, Jass::R2I(bonusStr));
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_AGILITY_BONUS, 0, Jass::R2I(bonusAgi));
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_INTELLIGENCE_BONUS, 0, Jass::R2I(bonusInt));

        // Защита (AId1 — Defense Bonus)
        abil = GetOrCreateAbil(u, 'AId1');
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_DEFENSE_BONUS_IDEF, 0, Jass::R2I(bonusArmor));

        // Атака (AItg — Attack Bonus)
        abil = GetOrCreateAbil(u, 'AItg');
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_ATTACK_BONUS, 0, Jass::R2I(bonusDmg));

        // Скорость атаки (AIsx — Attack Speed Bonus)
        abil = GetOrCreateAbil(u, 'AIsx');
        Jass::SetAbilityRealLevelField(abil, Jass::ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, 0, bonusAS);

        // Макс хп (AIlf — Max Life Bonus) с сохранением % хп
        float curHP = Jass::GetUnitCurrentLife(u);
        float maxHP = Jass::GetUnitMaxLife(u);
        float hpRatio = (maxHP > 0) ? (curHP / maxHP) : 1.f;
        abil = GetOrCreateAbil(u, 'AIlf');
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_MAX_LIFE_GAINED, 1, Jass::R2I(bonusHP));
        Jass::SetUnitCurrentLife(u, hpRatio * Jass::GetUnitMaxLife(u));

        // Макс мп (напрямую, с сохранением % маны)
        float maxMana = Jass::GetUnitMaxMana(u);
        float manaRatio = (maxMana > 0) ? (Jass::GetUnitCurrentMana(u) / maxMana) : 1.f;
        Jass::SetUnitMaxMana(u, 100 + Jass::R2I(baseStats.mp + bonusMP));
        Jass::SetUnitCurrentMana(u, manaRatio * Jass::GetUnitMaxMana(u));

        // Хп реген (Arel)
        abil = GetOrCreateAbil(u, 'Arel');
        Jass::SetAbilityIntegerLevelField(abil, Jass::ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND, 1, Jass::R2I(bonusHPR));

        // Мп реген (напрямую)
        Jass::SetUnitManaRegen(u, 1 + bonusMPR);

        // Скорость бега (напрямую)
        Jass::SetUnitMoveSpeed(u, baseStats.moveSpeed + bonusMS);
        abil = nil;
    }

    // --- Очищение баффов/дебаффов по уровню очищения ---
    // purgeBuffs=true  — снимает баффы (положительные)
    // purgeBuffs=false — снимает дебаффы (отрицательные)
    // Сильное очищение снимает обычное + сильное
    // Демоническое очищение снимает ТОЛЬКО демоническое
    void Purge(int purgeLevel, bool purgeBuffs, unit u) {
        bool changed = false;
        for (int i = int(buffs.length()) - 1; i >= 0; i--) {
            if (buffs[i].isBuff != purgeBuffs) continue;
            if (buffs[i].purgeLevel == PURGE_NONE) continue;

            bool canPurge = false;
            if (buffs[i].purgeLevel == PURGE_DEMONIC)
                canPurge = (purgeLevel == PURGE_DEMONIC);
            else if (purgeLevel != PURGE_DEMONIC)
                canPurge = (purgeLevel >= buffs[i].purgeLevel);

            if (canPurge) {
                buffs.removeAt(uint(i));
                changed = true;
            }
        }
        if (changed) Recalc(u);
    }

    // --- Тик баффов (вызывать по таймеру) ---
    // Только удаляет истёкшие баффы. Recalc при следующем AddItem/AddBuff.
    void TickBuffs(float dt) {
        for (int i = int(buffs.length()) - 1; i >= 0; i--) {
            if (buffs[i].duration > 0) {
                buffs[i].duration -= dt;
                if (buffs[i].duration <= 0) {
                    buffs.removeAt(uint(i));
                }
            }
        }
    }
}

// ---------- Глобальное хранилище ----------
dictionary UnitDataMap;
dictionary BaseStatsMap;   // ключ: unitTypeId, значение: UnitBaseTemplate@
dictionary ItemStatsMap;   // ключ: itemTypeId, значение: ItemBaseTemplate@
hashtable UnitHandleHT = Jass::InitHashtable();  // хранит unit handle по handleId

// --- Шаблон базовых статов по типу юнита ---
class UnitBaseTemplate {
    int    unitTypeId;
    bool   isHero;
    UnitStatsData stats;
}

// Зарегистрировать базовые статы для типа юнита
void DefineBaseStats(int unitTypeId, bool isHero, UnitStatsData@ stats) {
    if (!isHero) {
        stats.strength = 0;
        stats.agility = 0;
        stats.intelligence = 0;
    }
    UnitBaseTemplate tpl;
    tpl.unitTypeId = unitTypeId;
    tpl.isHero = isHero;
    tpl.stats = stats;
    string key = "" + unitTypeId;
    BaseStatsMap.set(key, @tpl);
}

// Получить шаблон базовых статов по типу юнита
UnitBaseTemplate@ GetBaseTemplate(int unitTypeId) {
    string key = "" + unitTypeId;
    UnitBaseTemplate@ tpl;
    if (BaseStatsMap.get(key, @tpl))
        return tpl;
    return null;
}

// --- Быстрый хелпер для задания статов ---
UnitStatsData@ MakeStats(float hp, float mp, float damage, float armor, float attackSpeed,
                          float moveSpeed, float hpRegen, float mpRegen,
                          float str = 0, float agi = 0, float intel = 0, float mainSt = 0) {
    UnitStatsData s;
    s.Reset();
    s.hp = hp;  s.mp = mp;
    s.damage = damage;  s.armor = armor;
    s.attackSpeed = attackSpeed;  s.moveSpeed = moveSpeed;
    s.hpRegen = hpRegen;  s.mpRegen = mpRegen;
    s.strength = str;  s.agility = agi;  s.intelligence = intel;
    s.mainStat = mainSt;
    return s;
}

// --- Регистрация шаблона предмета ---
void DefineItemStats(int itemTypeId, int itemLevel, UnitStatsData@ stats,
                     int abilityId = 0, float abilityCooldown = 0, float abilityManaCost = 0) {
    ItemBaseTemplate tpl;
    tpl.itemTypeId = itemTypeId;
    tpl.itemLevel = itemLevel;
    tpl.abilityId = abilityId;
    tpl.abilityCooldown = abilityCooldown;
    tpl.abilityManaCost = abilityManaCost;
    tpl.stats = stats;
    string key = "" + itemTypeId;
    ItemStatsMap.set(key, @tpl);
}

// Получить шаблон предмета по типу
ItemBaseTemplate@ GetItemTemplate(int itemTypeId) {
    string key = "" + itemTypeId;
    ItemBaseTemplate@ tpl;
    if (ItemStatsMap.get(key, @tpl))
        return tpl;
    return null;
}

// Создать ItemStats из шаблона для конкретного слота
ItemStats@ CreateItemFromTemplate(int itemTypeId, int slot, int handleId = 0) {
    ItemBaseTemplate@ tpl = GetItemTemplate(itemTypeId);
    if (tpl is null) return null;
    ItemStats itm;
    itm.itemTypeId = itemTypeId;
    itm.itemHandleId = handleId;
    itm.slot = slot;
    itm.itemLevel = tpl.itemLevel;
    itm.abilityId = tpl.abilityId;
    itm.abilityCooldown = tpl.abilityCooldown;
    itm.abilityManaCost = tpl.abilityManaCost;
    itm.stats.Reset();
    itm.stats.Add(tpl.stats);
    return itm;
}

// ---------- Инициализация базовых статов героев ----------
// MainStat: 0 = str, 1 = agi, 2 = int
void InitBaseStats() {
    // N000 — Инженер
    DefineBaseStats('N000', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 2
    ));
    // N100 — Инженер (скин)
    DefineBaseStats('N100', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 2
    ));
    // H006 — Подрывник
    DefineBaseStats('H006', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 40, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 250, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 2
    ));
    // H005 — Пулемётчик
    DefineBaseStats('H005', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 1
    ));
    // H004 — Снайпер
    DefineBaseStats('H004', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 15, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 1
    ));
    // H104 — Снайпер (скин)
    DefineBaseStats('H104', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 15, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 1
    ));
    // H003 — Ракетчик
    DefineBaseStats('H003', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 42, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 200, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 0
    ));
    // H002 — Медик
    DefineBaseStats('H002', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 2
    ));
    // H001 — Пироманьяк
    DefineBaseStats('H001', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 30, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 230, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 0
    ));
    // H000 — Сталкер
    DefineBaseStats('H000', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 0, /*agi*/ 0, /*int*/ 0, /*mainSt*/ 0
    ));
}

// ---------- Инициализация шаблонов предметов ----------
void InitItemTemplates() {
    UnitStatsData s;

    // I02I — Броне-скафандр
    s.Reset();
    s.strength     = 15;
    s.agility      = 15;
    s.intelligence = 15;
    s.hp           = 250;
    s.damage       = 30;
    s.armor        = 3;
    s.resistAll    = 0.02;
    s.bonusAllDamage = 0.02;
    s.moveSpeed    = 20;
    DefineItemStats('I02I', 1, s);
}

UnitData@ GetUnitData(unit u) {
    string key = "" + Jass::GetHandleId(u);
    UnitData@ ud;
    if (UnitDataMap.get(key, @ud))
        return ud;
    return null;
}

void RegisterUnit(unit u) {
    string key = "" + Jass::GetHandleId(u);
    if (UnitDataMap.exists(key)) return;
    UnitData ud;
    ud.baseStats.Reset();

    // Загрузить базовые статы из шаблона по типу юнита
    int typeId = Jass::GetUnitTypeId(u);
    UnitBaseTemplate@ tpl = GetBaseTemplate(typeId);
    if (tpl !is null) {
        ud.baseStats.Add(tpl.stats);
    }

    ud.totalStats.Reset();
    ud.Recalc(u);
    UnitDataMap.set(key, @ud);
    Jass::SaveUnitHandle(UnitHandleHT, Jass::GetHandleId(u), 0, u);
}

void UnregisterUnit(unit u) {
    string key = "" + Jass::GetHandleId(u);
    Jass::FlushChildHashtable(UnitHandleHT, Jass::GetHandleId(u));
    UnitDataMap.delete(key);
}

// Тик всех баффов (вызывать глобально по таймеру)
void TickAllBuffs(float dt) {
    array<string> keys = UnitDataMap.getKeys();
    for (uint i = 0; i < keys.length(); i++) {
        UnitData@ ud;
        UnitDataMap.get(keys[i], @ud);
        bool changed = false;
        for (int j = int(ud.buffs.length()) - 1; j >= 0; j--) {
            if (ud.buffs[j].duration > 0) {
                ud.buffs[j].duration -= dt;
                if (ud.buffs[j].duration <= 0) {
                    ud.buffs.removeAt(uint(j));
                    changed = true;
                }
            }
        }
        if (changed) {
            int hId = Jass::S2I(keys[i]);
            unit u = Jass::LoadUnitHandle(UnitHandleHT, hId, 0);
            ud.Recalc(u);
            u = nil;
        }
    }
}

// ---------- Триггеры предметов ----------

// Найти слот предмета у юнита (0-17), -1 если не найден
int FindItemSlot(unit u, item itm) {
    for (int i = 0; i < 18; i++) {
        item slotItm = Jass::UnitItemInSlot(u, i);
        bool match = (slotItm == itm);
        slotItm = nil;
        if (match)
            return i;
    }
    return -1;
}

void OnItemPickup() {
    unit u = Jass::GetTriggerUnit();
    item itm = Jass::GetManipulatedItem();
    int itemTypeId = Jass::GetItemTypeId(itm);
    UnitData@ ud = GetUnitData(u);

    Jass::ConsolePrint("\nOnItemPickup: unit=" + Jass::GetUnitName(u) + ", item=" + Jass::GetItemName(itm));
    if (ud is null) { u = nil; itm = nil; return; }

    int slot = FindItemSlot(u, itm);
    if (slot < 0) { u = nil; itm = nil; return; }

    ItemStats@ itmStats = CreateItemFromTemplate(itemTypeId, slot, Jass::GetHandleId(itm));
    if (itmStats is null) { u = nil; itm = nil; return; }

    ud.AddItem(itmStats, u); // Recalc внутри, статы дадутся только если слот 0-5
    u = nil;
    itm = nil;
}

void OnItemDrop() {
    unit u = Jass::GetTriggerUnit();
    item itm = Jass::GetManipulatedItem();
    Jass::ConsolePrint("\nOnItemDrop: unit=" + Jass::GetUnitName(u) + ", item=" + Jass::GetItemName(itm));
    UnitData@ ud = GetUnitData(u);
    if (ud is null) { u = nil; itm = nil; return; }

    ud.RemoveItemByHandle(Jass::GetHandleId(itm), u);
    u = nil;
    itm = nil;
}

void InitItemTriggers() {
    trigger trg_ItemPickup = Jass::CreateTrigger();
    trigger trg_ItemDrop   = Jass::CreateTrigger();

    // Регистрируем для всех играющих игроков
    for (int i = 0; i < 10; i++) {
        Jass::TriggerRegisterPlayerUnitEvent(trg_ItemPickup, Jass::Player(i), Jass::EVENT_PLAYER_UNIT_PICKUP_ITEM, nil);
        Jass::TriggerRegisterPlayerUnitEvent(trg_ItemDrop,   Jass::Player(i), Jass::EVENT_PLAYER_UNIT_DROP_ITEM, nil);
    }

    Jass::TriggerAddAction(trg_ItemPickup, @OnItemPickup);
    Jass::TriggerAddAction(trg_ItemDrop,   @OnItemDrop);
    trg_ItemPickup = nil;
    trg_ItemDrop = nil;
}
