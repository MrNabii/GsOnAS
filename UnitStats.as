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
    int    itemLevel;      // требуемый уровень героя
    int    maxStack;       // макс. кол-во предметов этого типа, дающих статы (0 = без лимита)
    int    saveId;         // ID для save/load системы (0 = нет)
    int    allowedClass;   // класс героя (0 = любой, иначе битовая маска классов)
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
    int    itemLevel;      // требуемый уровень героя
    int    maxStack;       // макс. кол-во предметов этого типа, дающих статы
    int    saveId;         // ID для save/load системы
    int    allowedClass;   // класс героя (0 = любой)
    int    ownerPlayerId;  // ID владельца (-1 = ничей, может подобрать любой)
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

        // Предметы: слот 0-5, проверка уровня, класса, стакабельности
        int heroLvl = Jass::GetHeroLevel(u);
        int typeId = Jass::GetUnitTypeId(u);
        UnitBaseTemplate@ baseTpl = GetBaseTemplate(typeId);
        int heroClass = (baseTpl !is null) ? baseTpl.heroClass : 0;
        dictionary stackCount; // подсчёт по itemTypeId
        for (uint i = 0; i < items.length(); i++) {
            if (items[i].slot < 0 || items[i].slot > 5) continue;
            // Проверка уровня
            if (items[i].itemLevel > 0 && heroLvl < items[i].itemLevel) continue;
            // Проверка класса
            if (items[i].allowedClass != 0 && heroClass != 0) {
                if ((items[i].allowedClass & heroClass) == 0) continue;
            }
            // Проверка стакабельности
            if (items[i].maxStack > 0) {
                string sKey = "" + items[i].itemTypeId;
                int cnt = 0;
                stackCount.get(sKey, cnt);
                if (cnt >= items[i].maxStack) continue;
                stackCount.set(sKey, cnt + 1);
            }
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
    int    heroClass;     // класс героя (0 = любой)
    UnitStatsData stats;
}

// Зарегистрировать базовые статы для типа юнита
void DefineBaseStats(int unitTypeId, bool isHero, UnitStatsData@ stats, int heroClass = 0) {
    if (!isHero) {
        stats.strength = 0;
        stats.agility = 0;
        stats.intelligence = 0;
    }
    UnitBaseTemplate tpl;
    tpl.unitTypeId = unitTypeId;
    tpl.isHero = isHero;
    tpl.heroClass = heroClass;
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
                     int maxStack = 0, int saveId = 0, int allowedClass = 0,
                     int abilityId = 0, float abilityCooldown = 0, float abilityManaCost = 0) {
    ItemBaseTemplate tpl;
    tpl.itemTypeId = itemTypeId;
    tpl.itemLevel = itemLevel;
    tpl.maxStack = maxStack;
    tpl.saveId = saveId;
    tpl.allowedClass = allowedClass;
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
ItemStats@ CreateItemFromTemplate(int itemTypeId, int slot, int handleId = 0, int ownerPlayerId = -1) {
    ItemBaseTemplate@ tpl = GetItemTemplate(itemTypeId);
    if (tpl is null) return null;
    ItemStats itm;
    itm.itemTypeId = itemTypeId;
    itm.itemHandleId = handleId;
    itm.slot = slot;
    itm.itemLevel = tpl.itemLevel;
    itm.maxStack = tpl.maxStack;
    itm.saveId = tpl.saveId;
    itm.allowedClass = tpl.allowedClass;
    itm.ownerPlayerId = ownerPlayerId;
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
        /*str*/ 15, /*agi*/ 0, /*int*/ 25, /*mainSt*/ 2
    ));
    // N100 — Инженер (скин)
    DefineBaseStats('N100', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 0, /*int*/ 25, /*mainSt*/ 2
    ));
    // H006 — Подрывник
    DefineBaseStats('H006', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 40, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 250, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 0, /*int*/ 25, /*mainSt*/ 2
    ));
    // H005 — Пулемётчик
    DefineBaseStats('H005', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 25, /*int*/ 0, /*mainSt*/ 1
    ));
    // H004 — Снайпер
    DefineBaseStats('H004', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 15, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 25, /*int*/ 0, /*mainSt*/ 1
    ));
    // H104 — Снайпер (скин)
    DefineBaseStats('H104', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 15, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 25, /*int*/ 0, /*mainSt*/ 1
    ));
    // H003 — Ракетчик
    DefineBaseStats('H003', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 42, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 200, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 25, /*agi*/ 15, /*int*/ 0, /*mainSt*/ 0
    ));
    // H002 — Медик
    DefineBaseStats('H002', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 15, /*agi*/ 0, /*int*/ 25, /*mainSt*/ 2
    ));
    // H001 — Пироманьяк
    DefineBaseStats('H001', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 30, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 230, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 25, /*agi*/ 15, /*int*/ 0, /*mainSt*/ 0
    ));
    // H000 — Сталкер
    DefineBaseStats('H000', true, MakeStats(
        /*hp*/ 0, /*mp*/ 0, /*dmg*/ 20, /*armor*/ 0, /*as*/ 0,
        /*ms*/ 270, /*hpReg*/ 0, /*mpReg*/ 0,
        /*str*/ 25, /*agi*/ 15, /*int*/ 0, /*mainSt*/ 0
    ));
}

// ---------- Хелпер для регистрации предмета одной строкой ----------
void DefItem(int id, int lvl,
    float str = 0, float agi = 0, float intel = 0,
    float mainSt = 0,
    float hp = 0, float mp = 0,
    float dmg = 0, float armor = 0,
    float as = 0, float ms = 0,
    float hpReg = 0, float hpRegPct = 0, float mpReg = 0,
    float critDmg = 0, float critCh = 0, float blk = 0,
    float resMag = 0, float resPhys = 0, float resAll = 0,
    float bonusPhys = 0, float bonusMag = 0, float bonusAll = 0,
    float luck = 0,
    float healRecv = 0, float healOut = 0,
    float stunCh = 0, float stunDur = 0,
    float radius = 0, float detection = 0,
    int maxStack = 0, int saveId = 0, int allowedClass = 0,
    int abilId = 0, float abilCD = 0, float abilMana = 0) {
    UnitStatsData s;
    s.Reset();
    s.strength = str;  s.agility = agi;  s.intelligence = intel;
    s.mainStat = mainSt;
    s.hp = hp;  s.mp = mp;
    s.damage = dmg;  s.armor = armor;
    s.attackSpeed = as;  s.moveSpeed = ms;
    s.hpRegen = hpReg;  s.hpRegenPercent = hpRegPct;  s.mpRegen = mpReg;
    s.critDamage = critDmg;  s.critChance = critCh;  s.block = blk;
    s.resistMagic = resMag;  s.resistPhysical = resPhys;  s.resistAll = resAll;
    s.bonusPhysDamage = bonusPhys;  s.bonusMagDamage = bonusMag;  s.bonusAllDamage = bonusAll;
    s.luck = luck;
    s.healReceived = healRecv;  s.healOutput = healOut;
    s.stunChance = stunCh;  s.stunDuration = stunDur;
    s.radius = radius;  s.detection = detection;
    DefineItemStats(id, lvl, s, maxStack, saveId, allowedClass, abilId, abilCD, abilMana);
}

// ---------- Сгенерировано из Google таблицы ----------
void InitItemTemplates() {
    DefItem('I09H', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1001); // Деревянная удочка | А: Шанс выудить рыбку - 40%
    DefItem('I0AA', 10, 0, 0, 0, 0, 350, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.3, 0, 0, 0, 0, 0, 0, 0, 1, 1005); // Арканитовая удочка | А: Шанс выудить рыбку - 100%, чаще вылавливает редкую рыбку
    DefItem('I01J', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 350, 0, 1, 1006); // Железная оптика
    DefItem('I01L', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500, 0, 1, 1007); // Серебряная оптика
    DefItem('I01K', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 700, 0, 1, 1008); // Ториевая оптика
    DefItem('I01M', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 900, 0, 1, 1009); // Арканитовая оптика
    DefItem('I01T', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Железные боеприпасы
    DefItem('I01U', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Серебряные боеприпасы
    DefItem('I01V', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Ториевые боеприпасы
    DefItem('I01W', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Арканитовые боеприпасы
    DefItem('I047', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Серебряная пыль | А: Позволяет обнаруживать скрытые предметы вокруг пользователя
    DefItem('I048', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1010); // Сырный Двигатель
    DefItem('I123', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1199); // Генератор
    DefItem('I049', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1011); // Железный меха-гоблин
    DefItem('I04A', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1012); // Серебряный меха-гоблин
    DefItem('I04B', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1013); // Ториевый меха-гоблин
    DefItem('I04C', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1014); // Арканитовый меха-гоблин
    DefItem('I07G', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1015); // Танк-нигдеход
    DefItem('I07H', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Движок MТ II
    DefItem('I07I', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Нагревательный блок
    DefItem('I07J', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Гигантская лупа
    DefItem('I07K', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Корпус "Буро"
    DefItem('I07L', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // 2 пары шагателей
    DefItem('I07M', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1); // Набор деталей
    DefItem('I024', 1); // Грибная настойка | А: Дает 2 еды и восстанавливает 3% хп
    DefItem('I02T', 1); // Грибной бульон | А: Дает 2 еды и восстанавливает 5% хп
    DefItem('I036', 1); // Грибной спирт | А: Дает 2 еды и восстанавливает 3% мп
    DefItem('I037', 1); // Грибная самогонка | А: Дает 2 еды и восстанавливает 5% мп
    DefItem('I06Y', 1); // Слабый энергетик | А: Дает 2 еды и восстанавливает 10% хп и мп в течений 10 сек
    DefItem('I06Z', 1); // Энергетик | А: Дает 2 еды и восстанавливает 15% хп и мп в течений 10 сек
    DefItem('I070', 1); // Сильный энергетик | А: Дает 2 еды и восстанавливает 20% хп и мп в течений 10 сек
    DefItem('I004', 1, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1015); // Гоблинский шлем-котелок
    DefItem('I009', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1016); // Гоблинский бронежилет
    DefItem('I00A', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1017); // Гоблинские сапоги
    DefItem('I00B', 1, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1018); // Гоблинские перчатки
    DefItem('I014', 1, 0, 0, 0, 0, 180, 0, 25, 2, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1019); // Гоблинский комбинезон
    DefItem('I00H', 1, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1020); // Кожаная накидка
    DefItem('I00I', 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1021); // Железный нагрудник
    DefItem('I00J', 1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1022); // Льняной плащ
    DefItem('I017', 1, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1023); // Экспедиционный костюмчик
    DefItem('I00K', 1, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1024); // Каска взрывника
    DefItem('I00L', 1, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1025); // Шапка
    DefItem('I00M', 1, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1026); // Маска
    DefItem('I01B', 1, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1027); // Каско-шлемо-маска
    DefItem('I02H', 1, 5, 5, 5, 0, 250, 0, 30, 3, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1028); // Броне-комбез
    DefItem('I02I', 1, 15, 15, 15, 0, 250, 0, 30, 3, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0.02, 0, 0, 0.02, 0, 0, 0, 0, 0, 0, 0, 2, 1029); // Броне-скафандр
    DefItem('I005', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1030); // Магический амулет
    DefItem('I006', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1031); // Красивая подвеска
    DefItem('I015', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1032); // Серебряная подвеска
    DefItem('I016', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1033); // Серебряный амулет
    DefItem('I02X', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1034); // Полуфилософский камень
    DefItem('I02Y', 1, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 3, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1035); // Философский камень | А: Превратить в золото.
    DefItem('I0FB', 10, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1036); // Книга Времени (1й том)
    DefItem('I0OB', 1); // Мультисталь
    DefItem('I00C', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1061, 136); // Ружьё
    DefItem('I00D', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1062, 16); // Базука
    DefItem('I00E', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1063, 64); // Огнемет
    DefItem('I00F', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1064, 4); // Пулемёт
    DefItem('I00G', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1065, 2); // Питарды
    DefItem('I012', 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1066, 33); // Шарострел
    DefItem('I01P', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1067, 136); // Арканитовое ружье
    DefItem('I01N', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1068, 16); // Арканитовая ракетница
    DefItem('I01Q', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1069, 64); // Арканитовый огнемёт
    DefItem('I01R', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1070, 4); // Арканитовый пулемёт
    DefItem('I01S', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1071, 2); // Арканитовые гранаты
    DefItem('I01O', 5, 0, 0, 0, 15, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1072, 33); // Арканитовый шарострел
    DefItem('I03V', 10, 0, 0, 0, 30, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 20, 0.05, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1073, 128); // Самозарядный дробовик
    DefItem('I03W', 10, 0, 0, 0, 30, 0, 0, 20, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.03, 0, 0, 0, 0, 0, 0, 0, 300, 0, 1, 1074, 8); // Элитная снайперка | А: Повышает скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.
    DefItem('I03X', 10, 0, 0, 0, 30, 0, 0, 60, 3, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1075, 16); // Базука бомбера
    DefItem('I03Y', 10, 0, 0, 0, 30, 0, 0, 0, 3, 0.2, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 100, 0, 1, 1076, 1); // Мехо-пак | А: Призыв Дирижабля. Атака = Разум х2, Хп = Инженер/2, Аура (урона) +4% | Аура: (регенерация хп зданиям) +5
    DefItem('I03Z', 10, 0, 0, 0, 30, 300, 0, 0, 2, 0, 0, 0, 0, 0.1, 0, 0, 0, 0.07, 0, 0, 0, 0, 0, 1, 0, 0.05, 0, 0, 100, 0, 1, 1077, 32); // Переносная мед-станция | П: Автохил союзника на 500 Хп раз в 8 сек. | А: Восстановить 750 хп в АоЕ. Кд 10 сек.
    DefItem('I040', 10, 0, 0, 0, 30, 0, 10, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1078, 2); // Ядер-магическая бомба | П: Каждый каст скилла дает 2 маны.
    DefItem('I041', 10, 0, 0, 0, 30, 0, 0, 40, 2, 0.3, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1079, 4); // Пулемётная лента | Аура: (увеличение атаки) 3% всем, себе и подконтрольным юнитам в 2 раза больше
    DefItem('I042', 10, 0, 0, 0, 30, 0, 0, 0, 3, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1080, 64); // Огнемётное охлаждение | П: Увеличивает кап скорости атаки на 5%. 5% шанс при атаке восполнить 30 хп
    DefItem('I053', 5, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1082); // Рубиновое колечко
    DefItem('I055', 10, 0, 0, 0, 0, 175, 0, 0, 0, 0, 0, 3, 0.07, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1083); // Рубиновое кольцо
    DefItem('I056', 15, 0, 0, 0, 0, 250, 0, 0, 0, 0, 0, 4, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1084); // Рубиновый перстень
    DefItem('I057', 5, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1085); // Сапфировое колечко
    DefItem('I054', 10, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1086); // Сапфировое кольцо
    DefItem('I058', 15, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1087); // Сапфировый перстень
    DefItem('I05I', 5, 0, 0, 0, 0, 0, 0, 30, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1088); // Алмазное колечко
    DefItem('I05J', 10, 0, 0, 0, 0, 0, 0, 45, 0, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1089); // Алмазное кольцо
    DefItem('I05K', 15, 0, 0, 0, 0, 0, 0, 60, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1090); // Алмазный перстень
    DefItem('I05C', 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.03, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1091); // Аметистовое колечко
    DefItem('I05D', 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.15, 0.04, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1092); // Аметистовое кольцо
    DefItem('I05E', 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1093); // Аметистовый перстень
    DefItem('I05F', 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 1, 1094); // Топазовое колечко | П: Каждые 25 сек даёт Щит на 100 ед.
    DefItem('I05G', 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 0, 1, 1095); // Топазовое кольцо | П: Каждые 25 сек даёт Щит на 250 ед.
    DefItem('I05H', 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 0, 1, 1096); // Топазовый перстень | П: Каждые 25 сек даёт Щит на 350 ед.
    DefItem('I059', 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0.02, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1097); // Изумрудное колечко
    DefItem('I05A', 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0.04, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1098); // Изумрудное кольцо
    DefItem('I05B', 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0.06, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1099); // Изумрудный перстень
    DefItem('I08X', 10, 25, 25, 25, 0, 150, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1100); // Радужный камень | А: Превратить в золото
    DefItem('I08Y', 20, 40, 40, 40, 0, 350, 0, 50, 5, 0, 30, 5, 0, 0.1, 0, 0, 0, 0, 0, 0.04, 0, 0, 0.04, 1, 0, 0, 0, 0, 0, 0, 1, 1101); // Радужный скелет | А: Превратить в золото (Тройная сила)
    DefItem('I08W', 5, 15, 15, 15, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1102); // Мультицвет
    DefItem('I00O', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1040); // Лапа гигантского арахнида
    DefItem('I00N', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1041); // Голова гигантского арахнида
    DefItem('I00P', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1042); // Клешня гигантского арахнида
    DefItem('I0OF', 1, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1043, 172); // Жало гигантского арахнида
    DefItem('I00Q', 10, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1044); // Бронежилет с лапой арахнида
    DefItem('I00R', 10, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1045); // Бронежилет с головой арахнида
    DefItem('I00S', 10, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1046); // Бронежилет с клешней арахнида
    DefItem('I01Z', 10, 0, 0, 0, 0, 0, 0, 55, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1047); // Арахнидские перчатки | А: Повышает скорость атаки на 0.3 на 5 сек. Кд 18 сек.
    DefItem('I020', 10, 0, 0, 0, 20, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1048); // Арахнидские сапоги | А: Повышает скорость бега на 70 на 5 сек. Кд 18 сек.
    DefItem('I021', 10, 0, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 0, 1, 1049); // Арахнидский шлем | А: Восстанавливает 400 хп и 10 мп. Кд 18 сек.
    DefItem('I0OG', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1037); // Заготовка для амулета
    DefItem('I0OH', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1038); // Заготовка для кольца
    DefItem('I0OI', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1039); // Заготовка для талисмана
    DefItem('I0OJ', 10, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1050); // Амулет из головы арахнида | А: Накладывает щит на 800 хп на союзника на 15 сек. Кд 30 сек. | Аура: (Скорость бега) +10. (Процент регенерации хп) +0,15
    DefItem('I0OK', 10, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1051); // Кольцо из клешни арахнида | А: Увеличивает исходящий урон на 10%. Длительность 5 сек.  Кд 25 сек
    DefItem('I0OL', 10, 0, 0, 0, 0, 400, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1052); // Талисман из лапы арахнида
    DefItem('I023', 10, 0, 30, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1053); // Арахнидский доспех
    DefItem('I0CT', 10, 30, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1054); // Каменный доспех
    DefItem('I0GA', 10, 0, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1055); // Доспех Паучьего Жреца
    DefItem('I0OP', 10, 20, 20, 20, 0, 500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1059); // Реликварий Арахнидов(1)
    DefItem('I022', 10, 35, 35, 35, 0, 0, 0, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 0, 1, 1060); // Сет Арахнида | Аура: (Скорость атаки) +0,1. (Скорость бега) +30
    DefItem('I0FD', 15, 0, 0, 0, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1081); // Книга Времени (2й том)
    DefItem('I02R', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 150, 0, 1103); // Свечка рабовладельца
    DefItem('I0OY', 1, 0, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1104); // Рабские оковы | А: Заковывает в кандалы цель, не позволяя ей передвигаться на 5 сек. кд 30. Не работает на боссов
    DefItem('I0OZ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1105, 66); // Одеколон "Потный" | А: Владелец откупоривает сосуд, создавая на 4 секунд облако вонючего газа с радиусом 200, которое наносит (Основной стат Х 3) магического урона каждые 0.5 сек. кд 25 сек.
    DefItem('I02Q', 1, 0, 0, 0, 30, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1106, 1); // Кирка рабовладельца
    DefItem('I02P', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1107); // Перчатка рабовладельца
    DefItem('I0P0', 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1108); // Кольцо рабовладельца | А: Призывает раба с (основной стат) урон, и (50% от макс хп) хп на 15 сек. кд 30 | Аура: Уменьшение получаемого урона 5%
    DefItem('I0P1', 20, 35, 35, 35, 0, 800, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1109); // Реликварий Арахнидов(2)
    DefItem('I0P2', 20, 35, 35, 35, 0, 0, 0, 40, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1110); // Реликварий Рабовладельца(2) | П: Уменьшает базовый интервал атак на 0.05
    DefItem('I0OM', 15, 0, 40, 0, 0, 0, 0, 0, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1056); // Грозный Арахнидский доспех | П: Каждая атака раз в 0.5 сек дает стак, при достижений 10й стаков, предмет можно будет активировать. Увеличивает скорость атаки на 20% на 3 сек.
    DefItem('I0ON', 15, 40, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1057); // Грозный Каменный доспех | А: Увеличивает хп-реген на 30% на 7 сек. Кд 25 сек.
    DefItem('I0OO', 15, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1058); // Грозный Доспех Паучьего Жреца | П: Раз в 10 секунд дает стак. Максимум 6 стаков. | А: Увеличивает мп реген на (1 х стак) всем союзникам в радиусе 300. на 3 сек.
    DefItem('I0FF', 15, 0, 0, 0, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1111); // Арахнидский кастет | П: Каждые 6 сек. усиливает атаку: Усиленная атака наносит Основной стат х4 + Атака х0.33 урона в 150 АОЕ
    DefItem('I02S', 20, 55, 55, 55, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 20, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 0, 1112); // Сет Рабовладельца | А: Заковывает в кандалы цель, не позволяя ей передвигаться, увеличивает ее наносимый урон на 10%, и уменьшает получаемый на 20% на 7 сек. кд 30. Дебафф не запрещает передвигаться боссу.
    DefItem('I0BB', 20, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1113, 64); // Зажигалка | П: Атаки под усилением E дополнительно наносят 15% урона в радиусе 75
    DefItem('I0BC', 20, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1114, 16); // Бум-Стик А-2 | П: При атаке с шансом 10% может сработать эффект Q с 50% уроном
    DefItem('I0BG', 20, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1115, 32); // Мед-Протез | П: Увеличивает радиус Q на 75
    DefItem('I0P3', 20, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1116, 1); // Мультикирка | П: Кол-во добываемой руды +1
    DefItem('I02W', 20, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1117, 2); // Потная граната | П: Увеличивает радиус Q на 20% и урон Q на 10%
    DefItem('I0P4', 20, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1118, 128); // Колючий шлем | П: Применение Q накладывает на владельца слабое развеивание
    DefItem('I0P5', 20, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1119, 8); // Снайперка "Скорпион" | П: Увеличивает урон Q на 30%.
    DefItem('I04H', 20, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1120, 4); // Ручной акселератор | П: Эффективность Е +10%
    DefItem('I0FG', 15, 0, 0, 0, 0, 300, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 150, 100, 1, 1121); // Лампа из черепа | Аура: Регенерация хп +10
    DefItem('I0GX', 20, 35, 35, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 200, 150, 1, 1122); // Священный свет | А: Призыв арахнида-целителя
    DefItem('I0BE', 20, 0, 0, 0, 0, 0, 0, 100, 0, 0.2, 0, 0, 0, 0, 0.3, 0.02, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1123); // Перчатка Власти
    DefItem('I0FH', 25, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1124); // Книга Времени (3й том)
    DefItem('I029', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1125); // Руна
    DefItem('I0P6', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126); // Плазма
    DefItem('I00Z', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1127); // Броня Стража
    DefItem('I00X', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1128); // Щит Стража
    DefItem('I010', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1129); // Душа Стража
    DefItem('I00Y', 1, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1130, 34); // Посох Стража
    DefItem('I0P7', 25, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1131); // Амулет Стража | А: Создает барьер в виде купола радиусом 300 на 10 сек., который поглощает 30% получаемого гоблинами урона в сумме до (Макс.хп), после чего он исчезает. Кд 35 сек. | Аура: (Скорость бега) +15. (Процент регенерации хп) +0,25
    DefItem('I011', 30, 85, 85, 85, 20, 0, 0, 0, 0, 0, 25, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132); // Сет Стража | А: Запечатывает выбраного гоблина на 5 сек и создает в радиусе 250 от него на окружности равномерно три руны так же на 5 сек. При подборе руна восстанавливает 15 маны и 10% хп. Пока гоблин запечатан, он получает неуязвимость, но становится оглушен. Если подобрать все три руны, то с гоблина моментально спадет статус запечатан. Кд 75 сек.
    DefItem('I0P8', 30, 35, 0, 0, 0, 400, 0, 0, 4, 0, -15, 0, 0, 0, 0, 0, 0, 0.07, 0.07, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1133); // Броня Хранителя | А: Накладывает на владельца слабое развеивание и дает щит на 15% от Макс. ХП. Длительность щита 8 сек, Кд 35 сек.
    DefItem('I0P9', 25, 25, 25, 25, 0, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1134); // Статический браслет | А: Выпускает разряд, который наносит (Основной стат Х 20) маг урона в радиусе 300 и отталкивающий противников на 200 от гоблина. Кд 35
    DefItem('I0PA', 25, 0, 0, 0, 15, 0, 0, 0, 0, 0, 35, 0, 0, 0, 0, 0, 0, 0.05, 0, 0, 0, 0.35, 0, 0, 0, 0, 0, 0, 0, 200, 0, 1135); // Сапоги призрака | А: Гоблин на 5 сек входит в астрал, с увеличенным на 20% мс но уменьшенным на 40% сопротивлением к магии и возможностью проходить сквозь существ. Кд 35
    DefItem('I0PB', 25, 0, 0, 0, 0, 400, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 35, 0, 0, 0, 0, 0, 0, 0, 0.07, 0.07, 0, 0, 0, 0, 0, 1136); // Восковой доспех | П: После получения атаки, уменьшает ас атакующего на 0.1 и мс на 10%
    DefItem('I0PC', 30, 55, 55, 55, 0, 1100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1137); // Реликварий Арахнидов(3)
    DefItem('I0PD', 30, 55, 55, 55, 0, 0, 0, 75, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1138); // Реликварий Рабовладельца(3) | П: Уменьшает базовый интервал атак на 0.075
    DefItem('I0PE', 30, 55, 55, 55, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0.35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1139); // Реликварий Стража(3) | А: Восполняет ману до максимума. Кд 75 сек.
    DefItem('I032', 25, 0, 20, 0, 0, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1140); // Усилитель | П: Каждые 6 сек усиливает гоблина. Дает ему 20% увеличение всего урона до его следующей атаки или нажатой способности.
    DefItem('I0Q4', 25, 0, 0, 0, 0, 650, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.6, 0, 0, 0, 0, 0, 0, 0, 0, 1197); // Мультиудочка | А: Шанс выудить рыбку - 100%. Может выловить некоторые ресурсы.
    DefItem('I0OC', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1141); // Обогощенный Арахнидский сплав
    DefItem('I076', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1142); // Зелье защиты | А: На 30 сек дает 20% сопротивления урону. КД 300 и общее между всеми зельями.
    DefItem('I077', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1143); // Зелье ловкости | А: На 30 сек дает 20% к ловкости. КД 300 и общее между всеми зельями.
    DefItem('I0PF', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1144); // Зелье скорости | А: На 30 сек дает 100 скорости передвижения и 0.5 ас. КД 300 и общее между всеми зельями.
    DefItem('I0PG', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1145); // Зелье жизни | А: На 30 сек дает +20% ХП. КД 300 и общее между всеми зельями.
    DefItem('I072', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1146); // Зелье интеллекта | А: На 30 сек дает +20% к интеллекту. КД 300 и общее между всеми зельями.
    DefItem('I078', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1147); // Зелье урона | А: На 30 сек дает  +20% увеличение физ. урона. КД 300 и общее между всеми зельями.
    DefItem('I073', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1148); // Зелье силы | А: На 30 сек дает +20% силы. КД 300 и общее между всеми зельями.
    DefItem('I0LA', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1149); // Зелье магии | А: На 30 сек дает +20% увеличение маг. урона. КД 300 и общее между всеми зельями.
    DefItem('I08Z', 30, 0, 0, 0, 75, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 55, 0.1, 0.1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 200, 0, 1, 1150, 128); // Каратель
    DefItem('I090', 30, 0, 0, 0, 75, 0, 0, 0, 2, 0.4, 0, 0, 0, 0, 0.3, 0.08, 0, 0, 0, 0, 0.07, 0, 0, 2, 0, 0, 0, 0, 500, 0, 1, 1151, 8); // Безмолвный палач | А: Повышает кап ас на 40% и скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.
    DefItem('I091', 30, 0, 0, 0, 75, 0, 0, 110, 4, 0.6, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 200, 0, 1, 1152, 4); // Лютый | Аура: (Увеличение Атаки и ХП) 8% всем, себе и своим подконтрольным юнитам в 2 раза больше.
    DefItem('I092', 30, 0, 0, 0, 75, 650, 0, 0, 6, 0, 0, 0, 0, 0.15, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 4, 0, 0.15, 0, 0, 200, 0, 1, 1153, 32); // HealPack-3000 | П: Автохил союзника на 1400 раз в 8 сек. | А: Восстановить 1500 хп в АОЕ. кд 10 сек
    DefItem('I093', 30, 0, 0, 0, 75, 0, 0, 0, 8, 0.4, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 200, 0, 1, 1154, 1); // Тех-Протез | П: Добыча руды +1 | А: Призыв Ылитного Дирижабля | Аура: Регенерация техники +1 и Атаки техники +50%
    DefItem('I094', 30, 0, 0, 0, 75, 0, 20, 0, 7, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 2, 0, 0, 0, 0, 200, 0, 1, 1155, 2); // Бумер | П: Каждый каст скилла дает стак на 3 сек(каждый стак имеет свое время, а не обновляется). Кажлый каст спелла дает (стак х 1) маны.
    DefItem('I095', 30, 0, 0, 0, 75, 0, 10, 0, 8, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 200, 0, 1, 1156, 64); // Mr. Пламень | П: При каждой атаке получает стак на 5 сек. Получение стака обновляет время действия. Каждый стак увеличивает скорость атаки на 0.03 и кап ас на 0.01 вплоть до 20 стаков. Также при атаке 5% шанс восполнить 100 хп
    DefItem('I096', 30, 0, 30, 0, 75, 0, 0, 160, 6, 0.4, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 200, 0, 1, 1157, 16); // Большой Сэм
    DefItem('I0FI', 40, 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158); // Книга Времени (4й том)
    DefItem('I03C', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1159); // Аккумуляторная кислота
    DefItem('I03A', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1160); // Ториевый обломок генератора
    DefItem('I03B', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1161); // Кусок ториевой гусеницы
    DefItem('I0PI', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1162); // Заржавевший арканитовый ковш
    DefItem('I0PJ', 40, 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1163, 12); // Патронташ
    DefItem('I0PK', 40, 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1164, 128); // Армированная пластина
    DefItem('I0PL', 40, 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1165, 1); // Тангенциальный вращатель
    DefItem('I0PM', 40, 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1166, 64); // Топливный бак
    DefItem('I03C', 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1167); // Магическое ультра-горючее
    DefItem('I03D', 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1168); // Ториевый нейро-генератор
    DefItem('I03E', 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1169); // Доспех из ториевой гусеницы
    DefItem('I0PN', 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1170); // Арканитовый ковш-шлем
    DefItem('I03K', 35, 75, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1171); // Ториевая циркулярная пила | А: Наносит (Основной Стат х40) физ урона противникам в радиусе 250 вокруг себя. Кд 20 сек | Аура: -5% защиты  противникам в радиусе 250
    DefItem('I03L', 40, 110, 110, 110, 0, 550, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1172); // Экзоскелет КУС-500rmk | А: Активирует экзоскелет позволяя превратиться в форму трактора на 15 сек. Пока форма активна, дает +20% мр, +15 защиты, +1 скорости атаки, но снижает скорость передвижения на 150. Кд 60 сек
    DefItem('I0PO', 35, 60, 60, 60, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 1173); // Талисман конструктора | А: Строит неуязвимый маячек на полу. Если маячек уже стоит, то уничтожает его и телепортирует владельца на его местоположение
    DefItem('I0PP', 40, 85, 85, 85, 0, 1450, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1174); // Реликварий Арахнидов(4)
    DefItem('I0PQ', 40, 85, 85, 85, 0, 0, 0, 120, 0, 0.4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1175); // Реликварий Рабовладельца(4) | П: Уменьшает базовый интервал атак на 0.1
    DefItem('I0PR', 40, 85, 85, 85, 0, 0, 30, 0, 0, 0, 0, 0, 0, 0.45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1176); // Реликварий Стража(4) | А: Восполняет ману до максимума. Кд 75 сек.
    DefItem('I0PS', 40, 85, 85, 85, 0, 0, 0, 0, 15, 0, -30, 0, 0, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1177); // Реликварий Трактора(4)
    DefItem('I0BN', 35, 0, 0, 75, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1178); // Кислотная граната | А: Бросает в точку гранату, которая наносит (Основной Стат х20) маг урона противникам в радиусе 250, а также снимает 10 защиты всем юнитам (включая союзным) в области действия на 10 сек. При попадании по уязвимой постройке, наносит ей (50% от ее Макс ХП) урона. Кд 30 сек.
    DefItem('I0BO', 40, 30, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0.15, 0, 0, 0, 0, 0.15, 0, 0, 0, 0, 0, 0, 0.15, 0.15, 0, 0, -250, 0, 1, 1179); // Хим-костюм
    DefItem('I0BQ', 40, 0, 60, 0, 60, 450, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1180); // Гусеничные сапоги
    DefItem('I063', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1181, 64); // Цветное огниво | П: При использовании Q через 3 секунды дополнительно срабатывает аналогичный ему эффект из той же точки каста с эффективностью 50%.
    DefItem('I0BL', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1182, 2); // Осколочный миноукладчик | П: Увеличивает максимальное количество взрывчаток R до 4. Так же позволяет генерировать взрывчатку при атаке раз в 10 сек.
    DefItem('I04I', 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1183, 4); // ЭлектроПулемет | П: При применении W на союзника, так же применяет W на владельца. Увеличивает кд W на 50%.
    DefItem('I0G9', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1184, 1); // Виварий | П: Раз в 1 секунд при атаке вызывает срабатывание Q в ближайшего противника без затрат маны (не наносит урон глыбам). Увеличивает урон Q На 60%
    DefItem('I0GC', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1185, 16); // Ворчун | П: Увеличивает урон, радиус и количество выстрелов T вдвое
    DefItem('I0BP', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1186, 128); // Шипованный доспех | П: После использования W в месте появления владелец агрит всех противников в радиусе 350 на 3 сек.
    DefItem('I0PT', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1187, 32); // Плазмокоагулятор | П: Лечение от W увеличивается на 5% каждую секунду. В конце эффекта облако взрывается нанося урон равный 1000% суммарного лечения всем противникам в радиусе облака.
    DefItem('I06N', 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1188, 8); // Бронебойная снайперка | П: T теперь заряжается 5 секунд, за каждую секунду зарядки наносит на 10% больше урона и станит на 10% дольше. Во время зарядки можно поворачивать сторону выстрела и отпустить раньше.
    DefItem('I0PU', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1189, 64); // Зажигалка v2 | П: Атаки под усилением E дополнительно наносят 50% урона в радиусе 150.
    DefItem('I0PV', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1190, 16); // Бум-Стик А-2 v2 | П: При атаке с шансом 10% может сработать эффект Q с 80% уроном. Каждое такое срабатывание уменьшает кд Q на 0.5 сек.
    DefItem('I0PW', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1191, 32); // Мед-Протез v2 | П: Увеличивает радиус Q на 75. Попадание по союзнику дает 20% мр на 3 секунды. Попадание по противнику снижает 20% мр на 5 секунд.
    DefItem('I0PX', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1192, 1); // Мультикирка v2 | П: Кол-во добываемой руды +2, количество добываемых самоцветов +1
    DefItem('I0PY', 40, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1193, 2); // Потная граната v2 | П: Увеличивает радиус Q на 30% и урон Q на 40%
    DefItem('I0PZ', 40, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1194, 128); // Колючий шлем v2 | П: Применение Q накладывает на владельца слабое развеивание. Уменьшает кд Q на 1 сек за каждый снятый дебафф
    DefItem('I0Q0', 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 8); // Снайперка "Скорпион" v2 | П: Увеличивает урон Q на 40% Каждый 6 выстрел по одному таргету кастует Q в него без затрат маны.
    DefItem('I0Q1', 40, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 4); // Ручной акселератор v2 | П: Эффективность Е +20%
    DefItem('I0D4', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1198); // Эссенция Огня | П: Эссенция чистой демонической силы манит владельца использовать ее. Если она будет в инвентаре минуту, то она автоматически используется. | А: Убивает владельца, после чего дает ему невообразимую мощь на 15 секунд.
    DefItem('I07N', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 900, 300, 0, 1200); // Око демона | А: Высвобождает око, позваоляющее видеть через препятствия в течении 8 сек. Кд 25 сек.
    DefItem('I07P', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 1201); // Ярость | Аура: Скорость атаки +0.7
    DefItem('I07R', 40, 150, 150, 150, 0, -1650, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, 0, 0, 0, 0, 0, 0, 0, 1202); // Мощь
    DefItem('I0AR', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.3, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1204); // Аметистовое ожерелье
    DefItem('I0B6', 40, 0, 0, 0, 0, 0, 30, 0, 0, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1205); // Сапфировое ожерелье
    DefItem('I0B7', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1206); // Изумрудное ожерелье
    DefItem('I0B8', 40, 0, 0, 0, 0, 1000, 0, 0, 0, 0, 0, 25, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1207); // Рубиновое ожерелье
    DefItem('I0B9', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 0, 0, 1208); // Топазовое ожерелье | П: Каждые 25 сек даёт Щит на 1050 ед.
    DefItem('I0BA', 40, 0, 0, 0, 0, 0, 0, 300, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1209); // Алмазное ожерелье
    DefItem('I0CV', 35, 0, 0, 0, 0, 1050, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.9, 0, 0, 0, 0, 0, 0, 0, 0, 1210); // Демоническая удочка | А: Шанс выудить рыбку - 100%. Вылавливает ресурсы качеством выше.
    DefItem('I0CX', 40, 0, 0, 0, 0, 1000, 30, 0, 0, 0, 0, 25, 0.15, 0.2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1211); // Ожерелье "Фиалка" | А: Восстановить 40% хп и 30% мп. Кд 40 сек
    DefItem('I0CY', 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, 0, 6, 0, 0, 0, 0, 250, 100, 0, 1212); // Ожерелье "Лайм" | П: Каждые 25 сек даёт Щит на 1050 ед.
    DefItem('I0CZ', 40, 0, 0, 0, 0, 0, 0, 300, 0, 0.3, 0, 0, 0, 0, 0.3, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1213); // Ожерелье "Индиго" | П: Увеличивает баффы от ожерелья на 50%, если владелец не получал урона в течении последних 4 секунд.
    DefItem('I0FJ', 1, 0, 0, 0, 100); // Книга Времени (5й том)
    DefItem('I04D', 1); // Венец Похоти
    DefItem('I04E', 1); // Нагрудник Похоти
    DefItem('I04F', 1); // Наручники Похоти
    DefItem('I04J', 1); // Алебарда Похоти
    DefItem('I04G', 1); // Сет Похоти
    DefItem('I0BR', 1); // Корона Похоти
    DefItem('I0BS', 1); // Царь скорпионов
    DefItem('I0BT', 1); // Похотливая броня
    DefItem('I0BU', 1); // Охотник на ведьм
    DefItem('I0BW', 1); // Накидка амазонки
    DefItem('I07O', 1); // Ненависть
    DefItem('I07S', 1); // Доспехи Порчи
    DefItem('I0GM', 1); // Царская Любовь
    DefItem('I0DF', 1); // Сет Рабовладельца v2.0
    DefItem('I0DJ', 1); // Циркулярка v2.0
    DefItem('I0DK', 1); // Экзоскелет КУС-500 v2.0
    DefItem('I0DL', 1); // Арахнидский Камень v2.0
    DefItem('I0DM', 1); // Радужный скелет v2.0
    DefItem('I01E', 1); // Сет Хранителя v2.0
    DefItem('I01F', 1); // Сет Стража v2.0
    DefItem('I064', 1); // Освещенная антиграната
    DefItem('I07X', 1); // Священный Индиго
    DefItem('I0AJ', 1); // Священная Фиалка
    DefItem('I0AZ', 1); // Священный Лайм
    DefItem('I0FJ', 1); // Книга Времени (5й том)
    DefItem('I0FK', 1); // Книга Времени (6й том)
    DefItem('I0GF', 1); // Книга Времени (7й том)
    DefItem('I0GH', 1); // Книга Времени (8й том)
    DefItem('I0GI', 1); // Книга Времени (9й том)
    DefItem('I04P', 1); // Железная гаубица
    DefItem('I04Q', 1); // Перчатки Бомбса
    DefItem('I04R', 1); // Труба Аккуратерса
    DefItem('I04S', 1); // Бронежилет Бомбса
    DefItem('I04T', 1); // Мешок взрывчатки
    DefItem('I0GB', 1); // Конвертер O.R.E
    DefItem('I065', 1); // Акселератор электронов
    DefItem('I0H5', 1); // Пылающий восполнитель
    DefItem('I04V', 1); // Сет Бомбса
    DefItem('I04W', 1); // Сет Сапёра
    DefItem('I05S', 1); // Сет Аккуратерса
    DefItem('I0BV', 1); // Похотливые перчатки
    DefItem('I0D5', 1); // Сет Аккуратерса v2.0
    DefItem('I0D7', 1); // Сет Бомбса v2.0
    DefItem('I0DG', 1); // Сет Сапёра v2.0
    DefItem('I0GC', 1); // Ворчун
    DefItem('I01G', 1); // Взрывное одеяние жреца
    DefItem('I084', 1); // Перстень Алчности
    DefItem('I086', 1); // Коготь Алчности
    DefItem('I085', 1); // Ожерелье Алчности
    DefItem('I060', 1); // Крылья Алчности
    DefItem('I087', 1); // Сет Алчности
    DefItem('I0C0', 1); // Амулет продажности
    DefItem('I0BY', 1); // Философский перстень
    DefItem('I0BZ', 1); // Алла
    DefItem('I0C1', 1); // Жажда наживы
    DefItem('I067', 1); // Укладчик Взрывчаток
    DefItem('I06R', 1); // Огненное извержение
    DefItem('I0C2', 1); // Когтистая броня
    DefItem('I0H6', 1); // Когти антиматерии
    DefItem('I0FT', 1); // Льстец
    DefItem('I0HL', 1); // Шипастые сапоги
    DefItem('I0BX', 1); // Сила Демона
    DefItem('I01H', 1); // Ангельский свет
    DefItem('I08S', 1); // Телепортатор
    DefItem('I08T', 1); // Стазис-кружка
    DefItem('I08U', 1); // Очки Хазула
    DefItem('I07T', 1); // Сет Хазула
    DefItem('I0HJ', 1); // Нестабильный конвертер
    DefItem('I0BM', 1); // Нейро-балон
    DefItem('I0DD', 1); // Сет Хазула v2.0
    DefItem('I0NN', 1); // Радиационный костюм
    DefItem('I089', 1); // Повреждённый техно-модуль
    DefItem('I08A', 1); // Повреждённая силовая броня
    DefItem('I08B', 1); // Повреждённый реактор
    DefItem('I08C', 1); // Повреждённый окуляр
    DefItem('I08D', 1); // Повреждённый воспламенитель
    DefItem('I08E', 1); // Повреждённый ускоритель частиц
    DefItem('I08F', 1); // Повреждённая ракетница
    DefItem('I08G', 1); // Повреждённый преобразователь
    DefItem('I08J', 1); // Техно-модуль
    DefItem('I08H', 1); // Силовая броня
    DefItem('I08I', 1); // Ядерный Реактор
    DefItem('I08K', 1); // Магический Окуляр
    DefItem('I08L', 1); // Воспламенитель
    DefItem('I08M', 1); // Ускоритель частиц
    DefItem('I08N', 1); // Ракетная Установка
    DefItem('I08O', 1); // Преобразователь маны
    DefItem('I0EV', 1); // MEGA-HealPack
    DefItem('I0EW', 1); // Mr. Жаров
    DefItem('I0EX', 1); // Ледяная кара
    DefItem('I0EY', 1); // Сэмюэль Старший
    DefItem('I0EZ', 1); // Крашер
    DefItem('I0F0', 1); // Охотник
    DefItem('I0MF', 1); // Охотник
    DefItem('I0F1', 1); // Бешеный
    DefItem('I0F2', 1); // Чудо техники
    DefItem('I07Z', 1); // Адская Фиалка
    DefItem('I06U', 1); // Адский Индиго
    DefItem('I0AV', 1); // Адский Лайм
    DefItem('I0B1', 1); // Обсидиановая Фиалка
    DefItem('I0B0', 1); // Обсидиановый Индиго
    DefItem('I0B2', 1); // Обсидиановый Лайм
    DefItem('I0GS', 1); // Колючий Преградитель
    DefItem('I0D6', 1); // Сет Алчности v2.0
    DefItem('I0DN', 1); // Сила Демона v2.0
    DefItem('I0DA', 1); // Сет Похоти v2.0
    DefItem('I0M3', 1); // Демоническое одеяние жреца
    DefItem('I080', 1); // Пояс Страха
    DefItem('I09F', 1); // Глаза Страха
    DefItem('I09G', 1); // Язык Страха
    DefItem('I0FL', 1); // Когти Страха
    DefItem('I0FM', 1); // Наплечники Страха
    DefItem('I07W', 1); // Сет Страха
    DefItem('I0DC', 1); // Сет Страха v2
    DefItem('I0C5', 1); // Глотатель Страха
    DefItem('I0C6', 1); // Смотрящая в душу
    DefItem('I0C7', 1); // Медальон Кошмаров
    DefItem('I0H4', 1); // Загребушка-700
    DefItem('I0FN', 1); // Кости Страха
    DefItem('I0FO', 1); // Страхоискатель
    DefItem('I07Q', 1); // Подрыватель Страха
    DefItem('I0FS', 1); // Вдова
    DefItem('I0FU', 1); // Пугатель
    DefItem('I0GZ', 1); // Похотливый Ужас
    DefItem('I0HD', 1); // Очки обмана
    DefItem('I0H0', 1); // Испивающий душу
    DefItem('I0HE', 1); // Алмазные когти
    DefItem('I0HM', 1); // Доспех дознавателя
    DefItem('I0HN', 1); // Техбрат-25Т
    DefItem('I0HO', 1); // Душежог-3000-G
    DefItem('I0HP', 1); // Пытатель-135-F
    DefItem('I0I8', 1); // Пылающий пронзатель
    DefItem('I0CM', 1); // Доспехи Легиона
    DefItem('I0MQ', 1); // Осколок тьмы
    DefItem('I0MR', 1); // Осколок чистоты
    DefItem('I0MP', 1); // Очищающее зелье
    DefItem('I0AE', 1); // Порванная сеть
    DefItem('I0AH', 1); // Помятый серебряный ошейник
    DefItem('I0AF', 1); // Сломанная булава
    DefItem('I0AD', 1); // Ошейник Дрессировщика
    DefItem('I0AG', 1); // Сете-пушка Дрессировщика
    DefItem('I0AI', 1); // Электро-булава Дрессировщика
    DefItem('I0BI', 1); // Сет Дрессировщика
    DefItem('I0D8', 1); // Сет Дрессировщика v2.0
    DefItem('I0MG', 1); // Первая деталь экзотики
    DefItem('I0MH', 1); // Вторая деталь экзотики
    DefItem('I0GE', 1); // Экзотика
    DefItem('I0MI', 1); // Первая деталь бесстрашного война
    DefItem('I0MJ', 1); // Вторая деталь бесстрашного война
    DefItem('I0GY', 1); // Бесстрашный воин
    DefItem('I0MK', 1); // Первая деталь шокового устройства
    DefItem('I0ML', 1); // Вторая деталь шокового устройства
    DefItem('I0H2', 1); // Шоковое устройство
    DefItem('I0H9', 1); // Ошейник Подчинения
    DefItem('I0MM', 1); // Первая деталь навязчивого пламени
    DefItem('I0MN', 1); // Вторая деталь навязчивого пламени
    DefItem('I0II', 1); // Навязчивое пламя
    DefItem('I0H3', 1); // Электрическая клешня
    DefItem('I0MT', 1); // Деталь Сапогов Зоофила
    DefItem('I0MS', 1); // Сапоги Зоофила
    DefItem('I0MV', 1); // Деталь Призрака
    DefItem('I0MU', 1); // Призрак
    DefItem('I0MW', 1); // Астральная сетка
    DefItem('I0MX', 1); // Пища гоба
    DefItem('I0MY', 1); // Глаз-Алмаз
    DefItem('I0MZ', 1); // Шторм
    DefItem('I09U', 1); // Сердце Зависти
    DefItem('I0AL', 1); // Клык Зависти
    DefItem('I0AM', 1); // Цепь Зависти
    DefItem('I0AO', 1); // Резак Зависти
    DefItem('I0AP', 1); // Рог Зависти
    DefItem('I0AN', 1); // Сет Зависти
    DefItem('I0D9', 1); // Сет Зависти v2.0
    DefItem('I0N0', 1); // Спец-костюм
    DefItem('I0N1', 1); // Деталь украденного света
    DefItem('I0N2', 1); // Украденный свет
    DefItem('I0HC', 1); // Полыхалка R-13
    DefItem('I0N3', 1); // Пустота
    DefItem('I0N4', 1); // Розовые Очки
    DefItem('I0H7', 1); // Сонный парализатор
    DefItem('I0N5', 1); // Платиновые Когти
    DefItem('I0HB', 1); // Ожерелье Достатка
    DefItem('I0CA', 1); // Порочный мультицвет
    DefItem('I0CB', 1); // Душитель Х-8
    DefItem('I0CC', 1); // Кандалы Зависти
    DefItem('I0CE', 1); // Острейший Рогоклык
    DefItem('I0CF', 1); // Вероломный шлем
    DefItem('I0NH', 1); // 1- Нестабильный реактор
    DefItem('I0NI', 1); // 2- Нестабильный реактор
    DefItem('I0NG', 1); // Нестабильный реактор
    DefItem('I0HG', 1); // Непрощающий
    DefItem('I0HH', 1); // Словарь Демонов
    DefItem('I0N6', 1); // 1-Деталь Доспеха Инквизитора
    DefItem('I0N7', 1); // 2-Деталь Доспеха Инквизитора
    DefItem('I0I9', 1); // Доспех Инквизитора
    DefItem('I0N8', 1); // 1-Деталь Духа проклятого Зверя
    DefItem('I0N9', 1); // 2-Деталь Духа проклятого Зверя
    DefItem('I0NA', 1); // 3-Деталь Духа проклятого Зверя
    DefItem('I0IG', 1); // Дух проклятого Зверя
    DefItem('I0H8', 1); // Продавец душ
    DefItem('I0DI', 1); // Доспехи Легиона v2.0
    DefItem('I0BH', 1); // Нано-кирка
    DefItem('I0HZ', 1); // Амулет Изгнания
    DefItem('I0HV', 1); // Печать врат
    DefItem('I06A', 1); // Драконья Слеза
    DefItem('I06B', 1); // Драконье Дыхание
    DefItem('I06C', 1); // Драконий Коготь
    DefItem('I0NJ', 1); // Драконий Коготь-2
    DefItem('I06D', 1); // Драконий Характер
    DefItem('I06E', 1); // Драконье Око
    DefItem('I06F', 1); // Драконья Душа
    DefItem('I0NK', 1); // Драконья Душа-2
    DefItem('I06G', 1); // Драконий Крик
    DefItem('I06H', 1); // Драконий Разум
    DefItem('I0I0', 1); // Дракончик
    DefItem('I0I1', 1); // Дракон
    DefItem('I0I2', 1); // Боевой дракон
    DefItem('I0I3', 1); // Яйцо дракона
    DefItem('I06I', 1); // Доспехи Дракона
    DefItem('I0NL', 1); // Драконье одеяние жреца
    DefItem('I06J', 1); // Свет Жизни
    DefItem('I0BD', 1); // Восполнитель
    DefItem('I0BF', 1); // Перчатка Уничтожения
    DefItem('I013', 1); // Сет Хранителя
    DefItem('I035', 1); // Антиграната
    DefItem('I0BK', 1); // Восполнитель Тьмы
    DefItem('I0CU', 1); // Демоническая кирка
}

// ---------- Описания предметов ----------

void DefItemDesc(int id, string name, string desc) {
    Jass::SetBaseItemStringFieldById(id, Jass::ITEM_SF_TOOLTIP_NORMAL, name);
    Jass::SetBaseItemStringFieldById(id, Jass::ITEM_SF_TOOLTIP_EXTENDED, desc);
    Jass::SetBaseItemStringFieldById(id, Jass::ITEM_SF_NAME, name);
    Jass::SetBaseItemStringFieldById(id, Jass::ITEM_SF_DESCRIPTION, desc);
}

void InitItemDescriptions() {
    DefItemDesc('I09H', "Деревянная удочка", "|cff00ccff(Актив): Шанс выудить рыбку - 40%|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0AA', "Арканитовая удочка", "Хп +350|nУвеличение всего урона -30%|n|cff00ccff(Актив): Шанс выудить рыбку - 100%, чаще вылавливает редкую рыбку|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01J', "Железная оптика", "Радиус +350|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01L', "Серебряная оптика", "Радиус +500|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01K', "Ториевая оптика", "Радиус +700|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01M', "Арканитовая оптика", "Радиус +900|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01T', "Железные боеприпасы", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01U', "Серебряные боеприпасы", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01V', "Ториевые боеприпасы", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01W', "Арканитовые боеприпасы", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I047', "Серебряная пыль", "|cff00ccff(Актив): Позволяет обнаруживать скрытые предметы вокруг пользователя|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I048', "Сырный Двигатель", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I123', "Генератор", "");
    DefItemDesc('I049', "Железный меха-гоблин", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04A', "Серебряный меха-гоблин", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04B', "Ториевый меха-гоблин", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04C', "Арканитовый меха-гоблин", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07G', "Танк-нигдеход", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07H', "Движок MТ II", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07I', "Нагревательный блок", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07J', "Гигантская лупа", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07K', "Корпус \"Буро\"", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07L', "2 пары шагателей", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07M', "Набор деталей", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I024', "Грибная настойка", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 3% хп|r");
    DefItemDesc('I02T', "Грибной бульон", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 5% хп|r");
    DefItemDesc('I036', "Грибной спирт", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 3% мп|r");
    DefItemDesc('I037', "Грибная самогонка", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 5% мп|r");
    DefItemDesc('I06Y', "Слабый энергетик", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 10% хп и мп в течений 10 сек|r");
    DefItemDesc('I06Z', "Энергетик", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 15% хп и мп в течений 10 сек|r");
    DefItemDesc('I070', "Сильный энергетик", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 20% хп и мп в течений 10 сек|r");
    DefItemDesc('I004', "Гоблинский шлем-котелок", "Хп +130|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I009', "Гоблинский бронежилет", "Защита +1|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00A', "Гоблинские сапоги", "Скорость бега +10|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00B', "Гоблинские перчатки", "Атака +25|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I014', "Гоблинский комбинезон", "Хп +180|nАтака +25|nЗащита +2|nСкорость бега +15|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00H', "Кожаная накидка", "Ловкость +5|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00I', "Железный нагрудник", "Сила +5|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00J', "Льняной плащ", "Разум +5|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I017', "Экспедиционный костюмчик", "Все статы +5|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00K', "Каска взрывника", "Сила +8|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00L', "Шапка", "Ловкость +8|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00M', "Маска", "Разум +8|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01B', "Каско-шлемо-маска", "Все статы +10|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02H', "Броне-комбез", "Все статы +5|nХп +250|nАтака +30|nЗащита +3|nСкорость бега +15|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02I', "Броне-скафандр", "Все статы +15|nХп +250|nАтака +30|nЗащита +3|nСкорость бега +20|nСопротивление урону +2%|nУвеличение всего урона +2%|n|cffff0000Не более 2 шт.|r");
    DefItemDesc('I005', "Магический амулет", "Регенерация мп +0.15|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I006', "Красивая подвеска", "Регенерация хп +2|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I015', "Серебряная подвеска", "Регенерация хп +3|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I016', "Серебряный амулет", "Регенерация мп +0.2|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02X', "Полуфилософский камень", "Регенерация хп +3|nРегенерация мп +0.2|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02Y', "Философский камень", "Хп +100|nРегенерация хп +3|nРегенерация мп +0.2|n|cff00ccff(Актив): Превратить в золото.|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FB', "Книга Времени (1й том)", "Основной стат +20|nУдача +1|n|cffff0000Доступен с 10 уровня|r");
    DefItemDesc('I0OB', "Мультисталь", "");
    DefItemDesc('I00C', "Ружьё", "Основной стат +5|n|cffff0000Только для: Снайпер и Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00D', "Базука", "Основной стат +5|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00E', "Огнемет", "Основной стат +5|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00F', "Пулемёт", "Основной стат +5|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00G', "Питарды", "Основной стат +5|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I012', "Шарострел", "Основной стат +5|n|cffff0000Только для: Медик и Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01P', "Арканитовое ружье", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Снайпер и Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01N', "Арканитовая ракетница", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01Q', "Арканитовый огнемёт", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01R', "Арканитовый пулемёт", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01S', "Арканитовые гранаты", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01O', "Арканитовый шарострел", "Основной стат +15|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Медик и Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03V', "Самозарядный дробовик", "Основной стат +30|nЗащита +6|nБлокирование +20|nСопротивление маг. урону +5%|nСопротивление физ. урону +5%|nРадиус +100|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03W', "Элитная снайперка", "Основной стат +30|nАтака +20|nСкорость атаки +0.2|nУвеличение физ. урона +3%|nРадиус +300|n|cff00ccff(Актив): Повышает скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Снайпер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03X', "Базука бомбера", "Основной стат +30|nАтака +60|nЗащита +3|nСкорость атаки +0.2|nСопротивление физ. урону +5%|nРадиус +100|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03Y', "Мехо-пак", "Основной стат +30|nЗащита +3|nСкорость атаки +0.2|nСкорость бега +20|nУдача +2|nРадиус +100|n|cff00ccff(Актив): Призыв Дирижабля. Атака = Разум х2, 
Хп = Инженер/2, Аура (урона) +4%|r|n|cffffff00(Аура): (регенерация хп зданиям) +5|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03Z', "Переносная мед-станция", "Основной стат +30|nХп +300|nЗащита +2|nРегенерация мп +0.1|nСопротивление маг. урону +7%|nИсходящий хил +5%|nУдача +1|nРадиус +100|n|cff00ff00(Пассив): Автохил союзника на 500 Хп раз в 8 сек.|r|n|cff00ccff(Актив): Восстановить 750 хп в АоЕ. Кд 10 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Медик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I040', "Ядер-магическая бомба", "Основной стат +30|nМп +10|nЗащита +3|nУвеличение маг. урона +5%|nРадиус +100|n|cff00ff00(Пассив): Каждый каст скилла дает 2 маны.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I041', "Пулемётная лента", "Основной стат +30|nАтака +40|nЗащита +2|nСкорость атаки +0.3|nСкорость бега +20|nРадиус +100|n|cffffff00(Аура): (увеличение атаки) 3% всем, себе и подконтрольным юнитам в 2 раза больше|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I042', "Огнемётное охлаждение", "Основной стат +30|nЗащита +3|nСкорость атаки +0.2|nРадиус +100|n|cff00ff00(Пассив): Увеличивает кап скорости атаки на 5%. 5% шанс при атаке восполнить 30 хп|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I053', "Рубиновое колечко", "Хп +100|nРегенерация хп +2|nПроцент регенерации хп +5%|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I055', "Рубиновое кольцо", "Хп +175|nРегенерация хп +3|nПроцент регенерации хп +7%|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I056', "Рубиновый перстень", "Хп +250|nРегенерация хп +4|nПроцент регенерации хп +10%|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I057', "Сапфировое колечко", "Мп +5|nРегенерация мп +0.05|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I054', "Сапфировое кольцо", "Мп +10|nРегенерация мп +0.1|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I058', "Сапфировый перстень", "Мп +15|nРегенерация мп +0.15|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05I', "Алмазное колечко", "Атака +30|nСкорость атаки +0.1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05J', "Алмазное кольцо", "Атака +45|nСкорость атаки +0.15|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05K', "Алмазный перстень", "Атака +60|nСкорость атаки +0.2|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05C', "Аметистовое колечко", "Крит Урон +10%|nКрит Шанс +3%|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05D', "Аметистовое кольцо", "Крит Урон +15%|nКрит Шанс +4%|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05E', "Аметистовый перстень", "Крит Урон +20%|nКрит Шанс +5%|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05F', "Топазовое колечко", "Радиус +100|n|cff00ff00(Пассив): Каждые 25 сек даёт Щит на 100 ед.|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05G', "Топазовое кольцо", "Радиус +200|n|cff00ff00(Пассив): Каждые 25 сек даёт Щит на 250 ед.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05H', "Топазовый перстень", "Радиус +300|n|cff00ff00(Пассив): Каждые 25 сек даёт Щит на 350 ед.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I059', "Изумрудное колечко", "Скорость бега +10|nСопротивление урону +2%|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05A', "Изумрудное кольцо", "Скорость бега +15|nСопротивление урону +4%|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05B', "Изумрудный перстень", "Скорость бега +20|nСопротивление урону +6%|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08X', "Радужный камень", "Все статы +25|nХп +150|nЗащита +3|nРегенерация хп +3|nУдача +1|n|cff00ccff(Актив): Превратить в золото|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08Y', "Радужный скелет", "Все статы +40|nХп +350|nАтака +50|nЗащита +5|nСкорость бега +30|nРегенерация хп +5|nРегенерация мп +0.1|nСопротивление урону +4%|nУвеличение всего урона +4%|nУдача +1|n|cff00ccff(Актив): Превратить в золото (Тройная сила)|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08W', "Мультицвет", "Все статы +15|nЗащита +3|nУдача +1|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00O', "Лапа гигантского арахнида", "");
    DefItemDesc('I00N', "Голова гигантского арахнида", "");
    DefItemDesc('I00P', "Клешня гигантского арахнида", "");
    DefItemDesc('I0OF', "Жало гигантского арахнида", "Основной стат +20|n|cffff0000Только для: Сталкер, Медик, Снайпер, Пулеметчик|r");
    DefItemDesc('I00Q', "Бронежилет с лапой арахнида", "Ловкость +20|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00R', "Бронежилет с головой арахнида", "Разум +20|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00S', "Бронежилет с клешней арахнида", "Сила +20|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01Z', "Арахнидские перчатки", "Атака +55|nСкорость атаки +0.1|n|cff00ccff(Актив): Повышает скорость атаки на 0.3 на 5 сек. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I020', "Арахнидские сапоги", "Основной стат +20|nСкорость бега +25|n|cff00ccff(Актив): Повышает скорость бега на 70 на 5 сек. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I021', "Арахнидский шлем", "Хп +200|nРадиус +250|n|cff00ccff(Актив): Восстанавливает 400 хп и 10 мп. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OG', "Заготовка для амулета", "");
    DefItemDesc('I0OH', "Заготовка для кольца", "");
    DefItemDesc('I0OI', "Заготовка для талисмана", "");
    DefItemDesc('I0OJ', "Амулет из головы арахнида", "Защита +4|nУдача +1|n|cff00ccff(Актив): Накладывает щит на 800 хп на союзника на 15 сек. Кд 30 сек.|r|n|cffffff00(Аура): (Скорость бега) +10. (Процент регенерации хп) +0,15|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OK', "Кольцо из клешни арахнида", "Атака +100|n|cff00ccff(Актив): Увеличивает исходящий урон на 10%. Длительность 5 сек.  Кд 25 сек|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OL', "Талисман из лапы арахнида", "Хп +400|nРегенерация хп +10|nБлокирование +10|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I023', "Арахнидский доспех", "Ловкость +30|nСкорость атаки +0.1|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0CT', "Каменный доспех", "Сила +30|nЗащита +3|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0GA', "Доспех Паучьего Жреца", "Разум +30|nРегенерация мп +0.05|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OP', "Реликварий Арахнидов(1)", "Все статы +20|nХп +500|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I022', "Сет Арахнида", "Все статы +35|nАтака +80|nРадиус +300|n|cffffff00(Аура): (Скорость атаки) +0,1. (Скорость бега) +30|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FD', "Книга Времени (2й том)", "Основной стат +35|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02R', "Свечка рабовладельца", "Регенерация хп +2|nРадиус +100|nОбнаружение +150");
    DefItemDesc('I0OY', "Рабские оковы", "Хп +200|n|cff00ccff(Актив): Заковывает в кандалы цель, не позволяя ей передвигаться на 5 сек. кд 30. Не работает на боссов|r");
    DefItemDesc('I0OZ', "Одеколон \"Потный\"", "Регенерация мп +0.05|n|cff00ccff(Актив): Владелец откупоривает сосуд, создавая на 4 секунд облако вонючего газа с радиусом 200, которое наносит (Основной стат Х 3) магического урона каждые 0.5 сек. кд 25 сек.|r|n|cffff0000Только для: Пироманьяк, Подрывник, Рокетчик|r");
    DefItemDesc('I02Q', "Кирка рабовладельца", "Основной стат +30|nСкорость атаки +0.2|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I02P', "Перчатка рабовладельца", "Скорость атаки +0.1|nКрит Урон +10%");
    DefItemDesc('I0P0', "Кольцо рабовладельца", "|cff00ccff(Актив): Призывает раба с (основной стат) урон, и (50% от макс хп) хп на 15 сек. кд 30|r|n|cffffff00(Аура): Уменьшение получаемого урона 5%|r|n|cffff0000Доступен с 15 уровня|r");
    DefItemDesc('I0P1', "Реликварий Арахнидов(2)", "Все статы +35|nХп +800|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0P2', "Реликварий Рабовладельца(2)", "Все статы +35|nАтака +40|nСкорость атаки +0.2|n|cff00ff00(Пассив): Уменьшает базовый интервал атак на 0.05|r|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0OM', "Грозный Арахнидский доспех", "Ловкость +40|nСкорость атаки +0.3|n|cff00ff00(Пассив): Каждая атака раз в 0.5 сек дает стак, при достижений 10й стаков, предмет можно будет активировать. Увеличивает скорость атаки на 20% на 3 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0ON', "Грозный Каменный доспех", "Сила +40|nЗащита +7|n|cff00ccff(Актив): Увеличивает хп-реген на 30% на 7 сек. Кд 25 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OO', "Грозный Доспех Паучьего Жреца", "Разум +40|nРегенерация мп +0.1|n|cff00ff00(Пассив): Раз в 10 секунд дает стак. Максимум 6 стаков.|r|n|cff00ccff(Актив): Увеличивает мп реген на (1 х стак) всем союзникам в радиусе 300. на 3 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FF', "Арахнидский кастет", "Атака +60|n|cff00ff00(Пассив): Каждые 6 сек. усиливает атаку: Усиленная атака наносит Основной стат х4 + Атака х0.33 урона в 150 АОЕ|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02S', "Сет Рабовладельца", "Все статы +55|nРегенерация хп +20|nБлокирование +20|nСопротивление маг. урону +5%|nОбнаружение +200|n|cff00ccff(Актив): Заковывает в кандалы цель, не позволяя ей передвигаться, увеличивает ее наносимый урон на 10%, и уменьшает получаемый на 20% на 7 сек. кд 30. Дебафф не запрещает передвигаться боссу.|r|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0BB', "Зажигалка", "Сила +45|n|cff00ff00(Пассив): Атаки под усилением E дополнительно наносят 15% урона в радиусе 75|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0BC', "Бум-Стик А-2", "Сила +45|n|cff00ff00(Пассив): При атаке с шансом 10% может сработать эффект Q с 50% уроном|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0BG', "Мед-Протез", "Разум +45|n|cff00ff00(Пассив): Увеличивает радиус Q на 75|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I0P3', "Мультикирка", "Разум +45|n|cff00ff00(Пассив): Кол-во добываемой руды +1|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I02W', "Потная граната", "Разум +45|n|cff00ff00(Пассив): Увеличивает радиус Q на 20% и урон Q на 10%|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I0P4', "Колючий шлем", "Сила +45|n|cff00ff00(Пассив): Применение Q накладывает на владельца слабое развеивание|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0P5', "Снайперка \"Скорпион\"", "Ловкость +45|n|cff00ff00(Пассив): Увеличивает урон Q на 30%.|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I04H', "Ручной акселератор", "Ловкость +45|n|cff00ff00(Пассив): Эффективность Е +10%|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0FG', "Лампа из черепа", "Хп +300|nРадиус +150|nОбнаружение +100|n|cffffff00(Аура): Регенерация хп +10|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0GX', "Священный свет", "Все статы +35|nПроцент регенерации хп +20%|nУдача +3|nРадиус +200|nОбнаружение +150|n|cff00ccff(Актив): Призыв арахнида-целителя|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BE', "Перчатка Власти", "Атака +100|nСкорость атаки +0.2|nКрит Урон +30%|nКрит Шанс +2%|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FH', "Книга Времени (3й том)", "Основной стат +50|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I029', "Руна", "");
    DefItemDesc('I0P6', "Плазма", "");
    DefItemDesc('I00Z', "Броня Стража", "");
    DefItemDesc('I00X', "Щит Стража", "");
    DefItemDesc('I010', "Душа Стража", "");
    DefItemDesc('I00Y', "Посох Стража", "Основной стат +50|n|cffff0000Только для: Рокетчик, Подрывник, Медик|r");
    DefItemDesc('I0P7', "Амулет Стража", "Защита +10|nСопротивление маг. урону +5%|nУдача +2|n|cff00ccff(Актив): Создает барьер в виде купола радиусом 300 на 10 сек., который поглощает 30% получаемого гоблинами урона в сумме до (Макс.хп), после чего он исчезает. Кд 35 сек.|r|n|cffffff00(Аура): (Скорость бега) +15. (Процент регенерации хп) +0,25|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I011', "Сет Стража", "Все статы +85|nОсновной стат +20|nСкорость бега +25|nРегенерация мп +0.1|n|cff00ccff(Актив): Запечатывает выбраного гоблина на 5 сек и создает в радиусе 250 от него на окружности равномерно три руны так же на 5 сек. При подборе руна восстанавливает 15 маны и 10% хп. Пока гоблин запечатан, он получает неуязвимость, но становится оглушен. Если подобрать все три руны, то с гоблина моментально спадет статус запечатан. Кд 75 сек.|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0P8', "Броня Хранителя", "Сила +35|nХп +400|nЗащита +4|nСкорость бега -15|nСопротивление маг. урону +7%|nСопротивление физ. урону +7%|n|cff00ccff(Актив): Накладывает на владельца слабое развеивание и дает щит на 15% от Макс. ХП. Длительность щита 8 сек, Кд 35 сек.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0P9', "Статический браслет", "Все статы +25|nСкорость атаки +0.2|n|cff00ccff(Актив): Выпускает разряд, который наносит (Основной стат Х 20) маг урона в радиусе 300 и отталкивающий противников на 200 от гоблина. Кд 35|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PA', "Сапоги призрака", "Основной стат +15|nСкорость бега +35|nСопротивление маг. урону +5%|nУвеличение маг. урона +35%|nОбнаружение +200|n|cff00ccff(Актив): Гоблин на 5 сек входит в астрал, с увеличенным на 20% мс но уменьшенным на 40% сопротивлением к магии и возможностью проходить сквозь существ. Кд 35|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PB', "Восковой доспех", "Хп +400|nЗащита +3|nБлокирование +35|nПолучаемый хил +7%|nИсходящий хил +7%|n|cff00ff00(Пассив): После получения атаки, уменьшает ас атакующего на 0.1 и мс на 10%|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PC', "Реликварий Арахнидов(3)", "Все статы +55|nХп +1100|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0PD', "Реликварий Рабовладельца(3)", "Все статы +55|nАтака +75|nСкорость атаки +0.3|n|cff00ff00(Пассив): Уменьшает базовый интервал атак на 0.075|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0PE', "Реликварий Стража(3)", "Все статы +55|nМп +20|nРегенерация мп +0.35|n|cff00ccff(Актив): Восполняет ману до максимума. Кд 75 сек.|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I032', "Усилитель", "Ловкость +20|nАтака +150|nКрит Урон +15%|n|cff00ff00(Пассив): Каждые 6 сек усиливает гоблина. Дает ему 20% увеличение всего урона до его следующей атаки или нажатой способности.|r|n|cffff0000Доступен с 25 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0Q4', "Мультиудочка", "Хп +650|nУвеличение всего урона -60%|n|cff00ccff(Актив): Шанс выудить рыбку - 100%. Может выловить некоторые ресурсы.|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0OC', "Обогощенный Арахнидский сплав", "");
    DefItemDesc('I076', "Зелье защиты", "|cff00ccff(Актив): На 30 сек дает 20% сопротивления урону. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I077', "Зелье ловкости", "|cff00ccff(Актив): На 30 сек дает 20% к ловкости. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0PF', "Зелье скорости", "|cff00ccff(Актив): На 30 сек дает 100 скорости передвижения и 0.5 ас. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0PG', "Зелье жизни", "|cff00ccff(Актив): На 30 сек дает +20% ХП. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I072', "Зелье интеллекта", "|cff00ccff(Актив): На 30 сек дает +20% к интеллекту. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I078', "Зелье урона", "|cff00ccff(Актив): На 30 сек дает  +20% увеличение физ. урона. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I073', "Зелье силы", "|cff00ccff(Актив): На 30 сек дает +20% силы. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0LA', "Зелье магии", "|cff00ccff(Актив): На 30 сек дает +20% увеличение маг. урона. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I08Z', "Каратель", "Основной стат +75|nЗащита +12|nБлокирование +55|nСопротивление маг. урону +10%|nСопротивление физ. урону +10%|nУдача +2|nРадиус +200|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I090', "Безмолвный палач", "Основной стат +75|nЗащита +2|nСкорость атаки +0.4|nКрит Урон +30%|nКрит Шанс +8%|nУвеличение физ. урона +7%|nУдача +2|nРадиус +500|n|cff00ccff(Актив): Повышает кап ас на 40% и скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Снайпер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I091', "Лютый", "Основной стат +75|nАтака +110|nЗащита +4|nСкорость атаки +0.6|nСкорость бега +40|nУдача +2|nРадиус +200|n|cffffff00(Аура): (Увеличение Атаки и ХП) 8% всем, себе и своим подконтрольным юнитам в 2 раза больше.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I092', "HealPack-3000", "Основной стат +75|nХп +650|nЗащита +6|nРегенерация мп +0.15|nСопротивление маг. урону +10%|nИсходящий хил +15%|nУдача +4|nРадиус +200|n|cff00ff00(Пассив): Автохил союзника на 1400 раз в 8 сек.|r|n|cff00ccff(Актив): Восстановить 1500 хп в АОЕ. кд 10 сек|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Медик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I093', "Тех-Протез", "Основной стат +75|nЗащита +8|nСкорость атаки +0.4|nСкорость бега +40|nУдача +6|nРадиус +200|n|cff00ff00(Пассив): Добыча руды +1|r|n|cff00ccff(Актив): Призыв Ылитного Дирижабля|r|n|cffffff00(Аура): Регенерация техники +1 и Атаки техники +50%|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I094', "Бумер", "Основной стат +75|nМп +20|nЗащита +7|nРегенерация мп +0.1|nУвеличение маг. урона +10%|nУдача +2|nРадиус +200|n|cff00ff00(Пассив): Каждый каст скилла дает стак на 3 сек(каждый стак имеет свое время, а не обновляется). Кажлый каст спелла дает (стак х 1) маны.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I095', "Mr. Пламень", "Основной стат +75|nМп +10|nЗащита +8|nСкорость атаки +0.2|nУдача +2|nРадиус +200|n|cff00ff00(Пассив): При каждой атаке получает стак на 5 сек. Получение стака обновляет время действия. Каждый стак увеличивает скорость атаки на 0.03 и кап ас на 0.01 вплоть до 20 стаков. Также при атаке 5% шанс восполнить 100 хп|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I096', "Большой Сэм", "Ловкость +30|nОсновной стат +75|nАтака +160|nЗащита +6|nСкорость атаки +0.4|nСопротивление физ. урону +10%|nУдача +2|nРадиус +200|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FI', "Книга Времени (4й том)", "Основной стат +75|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I03C', "Аккумуляторная кислота", "");
    DefItemDesc('I03A', "Ториевый обломок генератора", "");
    DefItemDesc('I03B', "Кусок ториевой гусеницы", "");
    DefItemDesc('I0PI', "Заржавевший арканитовый ковш", "");
    DefItemDesc('I0PJ', "Патронташ", "Основной стат +75|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик, Снайпер|r");
    DefItemDesc('I0PK', "Армированная пластина", "Основной стат +75|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0PL', "Тангенциальный вращатель", "Основной стат +75|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0PM', "Топливный бак", "Основной стат +75|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I03C', "Магическое ультра-горючее", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03D', "Ториевый нейро-генератор", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03E', "Доспех из ториевой гусеницы", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I0PN', "Арканитовый ковш-шлем", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03K', "Ториевая циркулярная пила", "Сила +75|nРазум +75|nКрит Урон +50%|nСопротивление физ. урону +5%|n|cff00ccff(Актив): Наносит (Основной Стат х40) физ урона противникам в радиусе 250 вокруг себя. Кд 20 сек|r|n|cffffff00(Аура): -5% защиты  противникам в радиусе 250|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03L', "Экзоскелет КУС-500rmk", "Все статы +110|nХп +550|n|cff00ccff(Актив): Активирует экзоскелет позволяя превратиться в форму трактора на 15 сек. Пока форма активна, дает +20% мр, +15 защиты, +1 скорости атаки, но снижает скорость передвижения на 150. Кд 60 сек|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PO', "Талисман конструктора", "Все статы +60|nРегенерация хп +20|nБлокирование +50|nУдача +2|n|cff00ccff(Актив): Строит неуязвимый маячек на полу. Если маячек уже стоит, то уничтожает его и телепортирует владельца на его местоположение|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PP', "Реликварий Арахнидов(4)", "Все статы +85|nХп +1450|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PQ', "Реликварий Рабовладельца(4)", "Все статы +85|nАтака +120|nСкорость атаки +0.4|n|cff00ff00(Пассив): Уменьшает базовый интервал атак на 0.1|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PR', "Реликварий Стража(4)", "Все статы +85|nМп +30|nРегенерация мп +0.45|n|cff00ccff(Актив): Восполняет ману до максимума. Кд 75 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PS', "Реликварий Трактора(4)", "Все статы +85|nЗащита +15|nСкорость бега -30|nСопротивление маг. урону +20%|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BN', "Кислотная граната", "Разум +75|nОсновной стат +30|nУвеличение маг. урона +25%|n|cff00ccff(Актив): Бросает в точку гранату, которая наносит (Основной Стат х20) маг урона противникам в радиусе 250, а также снимает 10 защиты всем юнитам (включая союзным) в области действия на 10 сек. При попадании по уязвимой постройке, наносит ей (50% от ее Макс ХП) урона. Кд 30 сек.|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BO', "Хим-костюм", "Сила +30|nОсновной стат +75|nПроцент регенерации хп +15%|nСопротивление маг. урону +15%|nПолучаемый хил +15%|nИсходящий хил +15%|nРадиус -250|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BQ', "Гусеничные сапоги", "Ловкость +60|nОсновной стат +60|nХп +450|nСкорость бега +20|nКрит Шанс +5%|nУдача +1|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I063', "Цветное огниво", "Сила +100|n|cff00ff00(Пассив): При использовании Q через 3 секунды дополнительно срабатывает аналогичный ему эффект из той же точки каста с эффективностью 50%.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0BL', "Осколочный миноукладчик", "Разум +100|n|cff00ff00(Пассив): Увеличивает максимальное количество взрывчаток R до 4. Так же позволяет генерировать взрывчатку при атаке раз в 10 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I04I', "ЭлектроПулемет", "Ловкость +100|n|cff00ff00(Пассив): При применении W на союзника, так же применяет W на владельца. Увеличивает кд W на 50%.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0G9', "Виварий", "Разум +100|n|cff00ff00(Пассив): Раз в 1 секунд при атаке вызывает срабатывание Q в ближайшего противника без затрат маны (не наносит урон глыбам). Увеличивает урон Q На 60%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0GC', "Ворчун", "Сила +100|n|cff00ff00(Пассив): Увеличивает урон, радиус и количество выстрелов T вдвое|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0BP', "Шипованный доспех", "Сила +100|n|cff00ff00(Пассив): После использования W в месте появления владелец агрит всех противников в радиусе 350 на 3 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0PT', "Плазмокоагулятор", "Разум +100|n|cff00ff00(Пассив): Лечение от W увеличивается на 5% каждую секунду. В конце эффекта облако взрывается нанося урон равный 1000% суммарного лечения всем противникам в радиусе облака.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I06N', "Бронебойная снайперка", "Ловкость +100|n|cff00ff00(Пассив): T теперь заряжается 5 секунд, за каждую секунду зарядки наносит на 10% больше урона и станит на 10% дольше. Во время зарядки можно поворачивать сторону выстрела и отпустить раньше.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I0PU', "Зажигалка v2", "Сила +100|n|cff00ff00(Пассив): Атаки под усилением E дополнительно наносят 50% урона в радиусе 150.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0PV', "Бум-Стик А-2 v2", "Сила +100|n|cff00ff00(Пассив): При атаке с шансом 10% может сработать эффект Q с 80% уроном. Каждое такое срабатывание уменьшает кд Q на 0.5 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0PW', "Мед-Протез v2", "Разум +100|n|cff00ff00(Пассив): Увеличивает радиус Q на 75. Попадание по союзнику дает 20% мр на 3 секунды. Попадание по противнику снижает 20% мр на 5 секунд.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I0PX', "Мультикирка v2", "Разум +100|n|cff00ff00(Пассив): Кол-во добываемой руды +2, количество добываемых самоцветов +1|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0PY', "Потная граната v2", "Разум +100|n|cff00ff00(Пассив): Увеличивает радиус Q на 30% и урон Q на 40%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I0PZ', "Колючий шлем v2", "Сила +100|n|cff00ff00(Пассив): Применение Q накладывает на владельца слабое развеивание. Уменьшает кд Q на 1 сек за каждый снятый дебафф|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0Q0', "Снайперка \"Скорпион\" v2", "Ловкость +100|n|cff00ff00(Пассив): Увеличивает урон Q на 40%
Каждый 6 выстрел по одному таргету кастует Q в него без затрат маны.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I0Q1', "Ручной акселератор v2", "Ловкость +100|n|cff00ff00(Пассив): Эффективность Е +20%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0D4', "Эссенция Огня", "|cff00ff00(Пассив): Эссенция чистой демонической силы манит владельца использовать ее. Если она будет в инвентаре минуту, то она автоматически используется.|r|n|cff00ccff(Актив): Убивает владельца, после чего дает ему невообразимую мощь на 15 секунд.|r");
    DefItemDesc('I07N', "Око демона", "Крит Шанс +25%|nУдача -1|nРадиус +900|nОбнаружение +300|n|cff00ccff(Актив): Высвобождает око, позваоляющее видеть через препятствия в течении 8 сек. Кд 25 сек.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I07P', "Ярость", "Удача -1|n|cffffff00(Аура): Скорость атаки +0.7|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I07R', "Мощь", "Все статы +150|nХп -1650|nУдача -2|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0AR', "Аметистовое ожерелье", "Крит Урон +30%|nКрит Шанс +10%|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B6', "Сапфировое ожерелье", "Мп +30|nРегенерация мп +0.2|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B7', "Изумрудное ожерелье", "Скорость бега +40|nСопротивление урону +10%|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B8', "Рубиновое ожерелье", "Хп +1000|nРегенерация хп +25|nПроцент регенерации хп +15%|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B9', "Топазовое ожерелье", "Радиус +250|n|cff00ff00(Пассив): Каждые 25 сек даёт Щит на 1050 ед.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0BA', "Алмазное ожерелье", "Атака +300|nСкорость атаки +0.3|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CV', "Демоническая удочка", "Хп +1050|nУвеличение всего урона -90%|n|cff00ccff(Актив): Шанс выудить рыбку - 100%. Вылавливает ресурсы качеством выше.|r|n|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I0CX', "Ожерелье \"Фиалка\"", "Хп +1000|nМп +30|nРегенерация хп +25|nПроцент регенерации хп +15%|nРегенерация мп +0.2|n|cff00ccff(Актив): Восстановить 40% хп и 30% мп. Кд 40 сек|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CY', "Ожерелье \"Лайм\"", "Скорость бега +40|nСопротивление урону +10%|nУдача +6|nРадиус +250|nОбнаружение +100|n|cff00ff00(Пассив): Каждые 25 сек даёт Щит на 1050 ед.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CZ', "Ожерелье \"Индиго\"", "Атака +300|nСкорость атаки +0.3|nКрит Урон +30%|nКрит Шанс +10%|n|cff00ff00(Пассив): Увеличивает баффы от ожерелья на 50%, если владелец не получал урона в течении последних 4 секунд.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0FJ', "Книга Времени (5й том)", "Основной стат +100");
    DefItemDesc('I04D', "Венец Похоти", "");
    DefItemDesc('I04E', "Нагрудник Похоти", "");
    DefItemDesc('I04F', "Наручники Похоти", "");
    DefItemDesc('I04J', "Алебарда Похоти", "");
    DefItemDesc('I04G', "Сет Похоти", "");
    DefItemDesc('I0BR', "Корона Похоти", "");
    DefItemDesc('I0BS', "Царь скорпионов", "");
    DefItemDesc('I0BT', "Похотливая броня", "");
    DefItemDesc('I0BU', "Охотник на ведьм", "");
    DefItemDesc('I0BW', "Накидка амазонки", "");
    DefItemDesc('I07O', "Ненависть", "");
    DefItemDesc('I07S', "Доспехи Порчи", "");
    DefItemDesc('I0GM', "Царская Любовь", "");
    DefItemDesc('I0DF', "Сет Рабовладельца v2.0", "Все статы +1|nСила +1|nЛовкость +1|nРазум +1|nОсновной стат +1|nХп +1|nМп +1|nАтака +1|nЗащита +1|nСкорость атаки +1|nСкорость бега +1|nРегенерация хп +1|nПроцент регенерации хп +100%|nРегенерация мп +1|nКрит Урон +100%|nКрит Шанс +100%|nБлокирование +1|nШанс стана +100%|nСопротивление маг. урону +100%|nСопротивление физ. урону +100%|nСопротивление урону +100%|nУвеличение физ. урона +100%|nУвеличение маг. урона +100%|nУвеличение всего урона +100%|nПолучаемый хил +100%|nИсходящий хил +100%|nУдача +1|nРадиус +1|nОбнаружение +1|n|cff00ff00(Пассив): 1|r|n|cff00ccff(Актив): 1|r|n|cffffff00(Аура): 1|r|n|cffff0000Только для: 1|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0DJ', "Циркулярка v2.0", "");
    DefItemDesc('I0DK', "Экзоскелет КУС-500 v2.0", "");
    DefItemDesc('I0DL', "Арахнидский Камень v2.0", "");
    DefItemDesc('I0DM', "Радужный скелет v2.0", "");
    DefItemDesc('I01E', "Сет Хранителя v2.0", "");
    DefItemDesc('I01F', "Сет Стража v2.0", "");
    DefItemDesc('I064', "Освещенная антиграната", "");
    DefItemDesc('I07X', "Священный Индиго", "");
    DefItemDesc('I0AJ', "Священная Фиалка", "");
    DefItemDesc('I0AZ', "Священный Лайм", "");
    DefItemDesc('I0FJ', "Книга Времени (5й том)", "");
    DefItemDesc('I0FK', "Книга Времени (6й том)", "");
    DefItemDesc('I0GF', "Книга Времени (7й том)", "");
    DefItemDesc('I0GH', "Книга Времени (8й том)", "");
    DefItemDesc('I0GI', "Книга Времени (9й том)", "");
    DefItemDesc('I04P', "Железная гаубица", "");
    DefItemDesc('I04Q', "Перчатки Бомбса", "");
    DefItemDesc('I04R', "Труба Аккуратерса", "");
    DefItemDesc('I04S', "Бронежилет Бомбса", "");
    DefItemDesc('I04T', "Мешок взрывчатки", "");
    DefItemDesc('I0GB', "Конвертер O.R.E", "");
    DefItemDesc('I065', "Акселератор электронов", "");
    DefItemDesc('I0H5', "Пылающий восполнитель", "");
    DefItemDesc('I04V', "Сет Бомбса", "");
    DefItemDesc('I04W', "Сет Сапёра", "");
    DefItemDesc('I05S', "Сет Аккуратерса", "");
    DefItemDesc('I0BV', "Похотливые перчатки", "");
    DefItemDesc('I0D5', "Сет Аккуратерса v2.0", "");
    DefItemDesc('I0D7', "Сет Бомбса v2.0", "");
    DefItemDesc('I0DG', "Сет Сапёра v2.0", "");
    DefItemDesc('I0GC', "Ворчун", "");
    DefItemDesc('I01G', "Взрывное одеяние жреца", "");
    DefItemDesc('I084', "Перстень Алчности", "");
    DefItemDesc('I086', "Коготь Алчности", "");
    DefItemDesc('I085', "Ожерелье Алчности", "");
    DefItemDesc('I060', "Крылья Алчности", "");
    DefItemDesc('I087', "Сет Алчности", "");
    DefItemDesc('I0C0', "Амулет продажности", "");
    DefItemDesc('I0BY', "Философский перстень", "");
    DefItemDesc('I0BZ', "Алла", "");
    DefItemDesc('I0C1', "Жажда наживы", "");
    DefItemDesc('I067', "Укладчик Взрывчаток", "");
    DefItemDesc('I06R', "Огненное извержение", "");
    DefItemDesc('I0C2', "Когтистая броня", "");
    DefItemDesc('I0H6', "Когти антиматерии", "");
    DefItemDesc('I0FT', "Льстец", "");
    DefItemDesc('I0HL', "Шипастые сапоги", "");
    DefItemDesc('I0BX', "Сила Демона", "");
    DefItemDesc('I01H', "Ангельский свет", "");
    DefItemDesc('I08S', "Телепортатор", "");
    DefItemDesc('I08T', "Стазис-кружка", "");
    DefItemDesc('I08U', "Очки Хазула", "");
    DefItemDesc('I07T', "Сет Хазула", "");
    DefItemDesc('I0HJ', "Нестабильный конвертер", "");
    DefItemDesc('I0BM', "Нейро-балон", "");
    DefItemDesc('I0DD', "Сет Хазула v2.0", "");
    DefItemDesc('I0NN', "Радиационный костюм", "");
    DefItemDesc('I089', "Повреждённый техно-модуль", "");
    DefItemDesc('I08A', "Повреждённая силовая броня", "");
    DefItemDesc('I08B', "Повреждённый реактор", "");
    DefItemDesc('I08C', "Повреждённый окуляр", "");
    DefItemDesc('I08D', "Повреждённый воспламенитель", "");
    DefItemDesc('I08E', "Повреждённый ускоритель частиц", "");
    DefItemDesc('I08F', "Повреждённая ракетница", "");
    DefItemDesc('I08G', "Повреждённый преобразователь", "");
    DefItemDesc('I08J', "Техно-модуль", "");
    DefItemDesc('I08H', "Силовая броня", "");
    DefItemDesc('I08I', "Ядерный Реактор", "");
    DefItemDesc('I08K', "Магический Окуляр", "");
    DefItemDesc('I08L', "Воспламенитель", "");
    DefItemDesc('I08M', "Ускоритель частиц", "");
    DefItemDesc('I08N', "Ракетная Установка", "");
    DefItemDesc('I08O', "Преобразователь маны", "");
    DefItemDesc('I0EV', "MEGA-HealPack", "");
    DefItemDesc('I0EW', "Mr. Жаров", "");
    DefItemDesc('I0EX', "Ледяная кара", "");
    DefItemDesc('I0EY', "Сэмюэль Старший", "");
    DefItemDesc('I0EZ', "Крашер", "");
    DefItemDesc('I0F0', "Охотник", "");
    DefItemDesc('I0MF', "Охотник", "");
    DefItemDesc('I0F1', "Бешеный", "");
    DefItemDesc('I0F2', "Чудо техники", "");
    DefItemDesc('I07Z', "Адская Фиалка", "");
    DefItemDesc('I06U', "Адский Индиго", "");
    DefItemDesc('I0AV', "Адский Лайм", "");
    DefItemDesc('I0B1', "Обсидиановая Фиалка", "");
    DefItemDesc('I0B0', "Обсидиановый Индиго", "");
    DefItemDesc('I0B2', "Обсидиановый Лайм", "");
    DefItemDesc('I0GS', "Колючий Преградитель", "");
    DefItemDesc('I0D6', "Сет Алчности v2.0", "");
    DefItemDesc('I0DN', "Сила Демона v2.0", "");
    DefItemDesc('I0DA', "Сет Похоти v2.0", "");
    DefItemDesc('I0M3', "Демоническое одеяние жреца", "");
    DefItemDesc('I080', "Пояс Страха", "");
    DefItemDesc('I09F', "Глаза Страха", "");
    DefItemDesc('I09G', "Язык Страха", "");
    DefItemDesc('I0FL', "Когти Страха", "");
    DefItemDesc('I0FM', "Наплечники Страха", "");
    DefItemDesc('I07W', "Сет Страха", "");
    DefItemDesc('I0DC', "Сет Страха v2", "");
    DefItemDesc('I0C5', "Глотатель Страха", "");
    DefItemDesc('I0C6', "Смотрящая в душу", "");
    DefItemDesc('I0C7', "Медальон Кошмаров", "");
    DefItemDesc('I0H4', "Загребушка-700", "");
    DefItemDesc('I0FN', "Кости Страха", "");
    DefItemDesc('I0FO', "Страхоискатель", "");
    DefItemDesc('I07Q', "Подрыватель Страха", "");
    DefItemDesc('I0FS', "Вдова", "");
    DefItemDesc('I0FU', "Пугатель", "");
    DefItemDesc('I0GZ', "Похотливый Ужас", "");
    DefItemDesc('I0HD', "Очки обмана", "");
    DefItemDesc('I0H0', "Испивающий душу", "");
    DefItemDesc('I0HE', "Алмазные когти", "");
    DefItemDesc('I0HM', "Доспех дознавателя", "");
    DefItemDesc('I0HN', "Техбрат-25Т", "");
    DefItemDesc('I0HO', "Душежог-3000-G", "");
    DefItemDesc('I0HP', "Пытатель-135-F", "");
    DefItemDesc('I0I8', "Пылающий пронзатель", "");
    DefItemDesc('I0CM', "Доспехи Легиона", "");
    DefItemDesc('I0MQ', "Осколок тьмы", "");
    DefItemDesc('I0MR', "Осколок чистоты", "");
    DefItemDesc('I0MP', "Очищающее зелье", "");
    DefItemDesc('I0AE', "Порванная сеть", "");
    DefItemDesc('I0AH', "Помятый серебряный ошейник", "");
    DefItemDesc('I0AF', "Сломанная булава", "");
    DefItemDesc('I0AD', "Ошейник Дрессировщика", "");
    DefItemDesc('I0AG', "Сете-пушка Дрессировщика", "");
    DefItemDesc('I0AI', "Электро-булава Дрессировщика", "");
    DefItemDesc('I0BI', "Сет Дрессировщика", "");
    DefItemDesc('I0D8', "Сет Дрессировщика v2.0", "");
    DefItemDesc('I0MG', "Первая деталь экзотики", "");
    DefItemDesc('I0MH', "Вторая деталь экзотики", "");
    DefItemDesc('I0GE', "Экзотика", "");
    DefItemDesc('I0MI', "Первая деталь бесстрашного война", "");
    DefItemDesc('I0MJ', "Вторая деталь бесстрашного война", "");
    DefItemDesc('I0GY', "Бесстрашный воин", "");
    DefItemDesc('I0MK', "Первая деталь шокового устройства", "");
    DefItemDesc('I0ML', "Вторая деталь шокового устройства", "");
    DefItemDesc('I0H2', "Шоковое устройство", "");
    DefItemDesc('I0H9', "Ошейник Подчинения", "");
    DefItemDesc('I0MM', "Первая деталь навязчивого пламени", "");
    DefItemDesc('I0MN', "Вторая деталь навязчивого пламени", "");
    DefItemDesc('I0II', "Навязчивое пламя", "");
    DefItemDesc('I0H3', "Электрическая клешня", "");
    DefItemDesc('I0MT', "Деталь Сапогов Зоофила", "");
    DefItemDesc('I0MS', "Сапоги Зоофила", "");
    DefItemDesc('I0MV', "Деталь Призрака", "");
    DefItemDesc('I0MU', "Призрак", "");
    DefItemDesc('I0MW', "Астральная сетка", "");
    DefItemDesc('I0MX', "Пища гоба", "");
    DefItemDesc('I0MY', "Глаз-Алмаз", "");
    DefItemDesc('I0MZ', "Шторм", "");
    DefItemDesc('I09U', "Сердце Зависти", "");
    DefItemDesc('I0AL', "Клык Зависти", "");
    DefItemDesc('I0AM', "Цепь Зависти", "");
    DefItemDesc('I0AO', "Резак Зависти", "");
    DefItemDesc('I0AP', "Рог Зависти", "");
    DefItemDesc('I0AN', "Сет Зависти", "");
    DefItemDesc('I0D9', "Сет Зависти v2.0", "");
    DefItemDesc('I0N0', "Спец-костюм", "");
    DefItemDesc('I0N1', "Деталь украденного света", "");
    DefItemDesc('I0N2', "Украденный свет", "");
    DefItemDesc('I0HC', "Полыхалка R-13", "");
    DefItemDesc('I0N3', "Пустота", "");
    DefItemDesc('I0N4', "Розовые Очки", "");
    DefItemDesc('I0H7', "Сонный парализатор", "");
    DefItemDesc('I0N5', "Платиновые Когти", "");
    DefItemDesc('I0HB', "Ожерелье Достатка", "");
    DefItemDesc('I0CA', "Порочный мультицвет", "");
    DefItemDesc('I0CB', "Душитель Х-8", "");
    DefItemDesc('I0CC', "Кандалы Зависти", "");
    DefItemDesc('I0CE', "Острейший Рогоклык", "");
    DefItemDesc('I0CF', "Вероломный шлем", "");
    DefItemDesc('I0NH', "1- Нестабильный реактор", "");
    DefItemDesc('I0NI', "2- Нестабильный реактор", "");
    DefItemDesc('I0NG', "Нестабильный реактор", "");
    DefItemDesc('I0HG', "Непрощающий", "");
    DefItemDesc('I0HH', "Словарь Демонов", "");
    DefItemDesc('I0N6', "1-Деталь Доспеха Инквизитора", "");
    DefItemDesc('I0N7', "2-Деталь Доспеха Инквизитора", "");
    DefItemDesc('I0I9', "Доспех Инквизитора", "");
    DefItemDesc('I0N8', "1-Деталь Духа проклятого Зверя", "");
    DefItemDesc('I0N9', "2-Деталь Духа проклятого Зверя", "");
    DefItemDesc('I0NA', "3-Деталь Духа проклятого Зверя", "");
    DefItemDesc('I0IG', "Дух проклятого Зверя", "");
    DefItemDesc('I0H8', "Продавец душ", "");
    DefItemDesc('I0DI', "Доспехи Легиона v2.0", "");
    DefItemDesc('I0BH', "Нано-кирка", "");
    DefItemDesc('I0HZ', "Амулет Изгнания", "");
    DefItemDesc('I0HV', "Печать врат", "");
    DefItemDesc('I06A', "Драконья Слеза", "");
    DefItemDesc('I06B', "Драконье Дыхание", "");
    DefItemDesc('I06C', "Драконий Коготь", "");
    DefItemDesc('I0NJ', "Драконий Коготь-2", "");
    DefItemDesc('I06D', "Драконий Характер", "");
    DefItemDesc('I06E', "Драконье Око", "");
    DefItemDesc('I06F', "Драконья Душа", "");
    DefItemDesc('I0NK', "Драконья Душа-2", "");
    DefItemDesc('I06G', "Драконий Крик", "");
    DefItemDesc('I06H', "Драконий Разум", "");
    DefItemDesc('I0I0', "Дракончик", "");
    DefItemDesc('I0I1', "Дракон", "");
    DefItemDesc('I0I2', "Боевой дракон", "");
    DefItemDesc('I0I3', "Яйцо дракона", "");
    DefItemDesc('I06I', "Доспехи Дракона", "");
    DefItemDesc('I0NL', "Драконье одеяние жреца", "");
    DefItemDesc('I06J', "Свет Жизни", "");
    DefItemDesc('I0BD', "Восполнитель", "");
    DefItemDesc('I0BF', "Перчатка Уничтожения", "");
    DefItemDesc('I013', "Сет Хранителя", "");
    DefItemDesc('I035', "Антиграната", "");
    DefItemDesc('I0BK', "Восполнитель Тьмы", "");
    DefItemDesc('I0CU', "Демоническая кирка", "");
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

    // Получить шаблон для проверок
    ItemBaseTemplate@ tpl = GetItemTemplate(itemTypeId);

    // --- Личный предмет: если есть владелец и это не наш --- выбросить
    int ownerPid = Jass::LoadInteger(UnitHandleHT, Jass::GetHandleId(itm), 'ownr');
    if (ownerPid > 0) {
        int myPid = Jass::GetPlayerId(Jass::GetOwningPlayer(u)) + 1;
        if (ownerPid != myPid) {
            // Выбросить чужой предмет
            Jass::UnitRemoveItem(u, itm);
            u = nil; itm = nil;
            return;
        }
    }

    ItemStats@ itmStats = CreateItemFromTemplate(itemTypeId, slot, Jass::GetHandleId(itm),
        (ownerPid > 0) ? ownerPid : -1);
    if (itmStats is null) { u = nil; itm = nil; return; }

    ud.AddItem(itmStats, u); // Recalc внутри, проверки уровня/класса/стака в Recalc
    u = nil;
    itm = nil;
}

// --- Назначить владельца предмету (playerId 1-based, 0 = ничей) ---
void SetItemOwner(item itm, int playerId) {
    Jass::SaveInteger(UnitHandleHT, Jass::GetHandleId(itm), 'ownr', playerId);
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
