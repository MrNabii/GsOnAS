//import BuffSystem.as

#include "BuffSystem.as"

class HeroGameData {
    int ArchLevel = 0;  
}

// ---------- Базовая структура статов ----------
hashtable SHT = Jass::InitHashtable();  // хранит UnitData по unit handle
dictionary UnitDataMap;
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

    void Add(UnitStatsData o) {
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
const float AGI_TO_ARMOR    = 0.3;   // 1 ловкость   = +0.3 защиты
const float AGI_TO_AS       = 0.02;  // 1 ловкость   = +0.02 скорость атаки
const float INT_TO_MP       = 15.0;  // 1 разум      = +15 маны
const float INT_TO_MPREGEN  = 0.05;  // 1 разум      = +0.05 реген маны
// HP: mainStat*3 + str*8  (для всех классов одинаково)
// AD и HPRegen: зависят от heroClass (см. ComputeStatDerived)

// ---------- Бафф (один тип — один экземпляр, не стакается) ----------
#include "BuffSystem.as"

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
    private timer     buffTimer;    // таймер для тика баффов
    bool          IsDummy;  // флаг, указывающий, является ли юнит "пустышкой" (без статов, для триггеров и т.п.)
    float        dummyDamage; // временное хранилище для урона от "пустышки", который должен быть обработан коллбеком
    damagetype dmgType;  //Jass::DAMAGE_TYPE_NORMAL / DAMAGE_TYPE_MAGIC / DAMAGE_TYPE_UNIVERSAL и т.д.
    DamageCallbackFn@ dummyDamageCallback; // коллбек для обработки урона от "пустышки"
    bool CanOnHit = false; // флаг, указывающий, должны ли срабатывать on-hit пассивки при атаке этим юнитом (обычно false для "пустышек")
    unit DummySource; // временное хранилище для источника урона от "пустышки", который должен быть обработан коллбеком
    int OreType = -1; // 0 - железо, 1 - серебро, 2 - ториевая руда, 3 - арканитовая руда 
    bool isMinik = false; // флаг, указывающий, является ли юнит миником (для особой обработки в некоторых механиках)
    bool isMiniBoss2 = false; // флаг, указывающий, является ли юнит мини-боссом второго типа
    HeroGameData heroGameData; // данные, специфичные для героя (например, уровень архетипа)

    void SetDamageCallback(DamageCallbackFn@ cb) {
        @dummyDamageCallback = cb;
    }
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

    // --- Тик баффов (вызывать по таймеру) ---
    // Удаляет истёкшие баффы и проверяет ауры по дальности.
    void TickBuffs(float dt, unit u) {
        int i = 0;
        int max = int(buffs.length());
        bool changed = false;
        int uid = Jass::GetHandleId(u);
        while (i < max) {
            // Аура: проверка дальности от источника
            if (buffs[i].isAura) {
                if (buffs[i].auraSourceId == uid) {
                    // Этот юнит — источник ауры: тикаем ауру (добавляем/удаляем у окружающих)
                    TickAuras(u, buffs[i].name, buffs[i].description, buffs[i].iconPath,
                        buffs[i].buffTypeId, buffs[i].stats, buffs[i].isBuff, buffs[i].auraRadius,
                        buffs[i].purgeLevel, buffs[i].level);
                } else {
                    // Получатель ауры: проверяем жив ли source и в радиусе ли мы
                    unit src = Jass::LoadUnitHandle(SHT, buffs[i].auraSourceId, 'asrc');
                    if (src == nil || Jass::GetUnitState(src, Jass::UNIT_STATE_LIFE) <= 0) {
                        buffs.removeAt(i);
                        max--;
                        changed = true;
                        continue;
                    }
                    float dx = Jass::GetUnitX(u) - Jass::GetUnitX(src);
                    float dy = Jass::GetUnitY(u) - Jass::GetUnitY(src);
                    if (dx*dx + dy*dy > buffs[i].auraRadius * buffs[i].auraRadius) {
                        buffs.removeAt(i);
                        max--;
                        changed = true;
                        continue;
                    }
                }
            }
            // Обычный бафф: уменьшение длительности
            else if (buffs[i].duration > 0) {
                buffs[i].duration -= dt;
                if (buffs[i].duration <= 0) {
                    buffs.removeAt(i);
                    max--;
                    changed = true;
                    continue;
                }
            }
            i++;
        }
        if (changed) Recalc(u);
    }

    // --- Баффы (один тип не стакается — перезаписывается) ---
    void AddBuff(Buff@ b, unit u) {
        if (b is null) return;
        // если бафф такого типа уже есть — заменяем
        for (uint i = 0; i < buffs.length(); i++) {
            if (buffs[i].buffTypeId == b.buffTypeId) {
                if (buffs[i].level <= b.level) {
                    @buffs[i] = b;
                    Recalc(u);
                    return;
                } else {
                    // Существующий бафф выше по уровню, не заменяем, просто обновляем время
                    buffs[i].duration = b.duration;
                    return;
                }
                
            }
        }
        buffs.insertLast(b);
        Jass::ConsolePrint("\n[AddBuff] Buff added");
        if (buffs.length() == 1) {
            // если это первый бафф, запускаем таймер для тика
            if(buffTimer == nil) buffTimer = Jass::CreateTimer();
            Jass::SaveUnitHandle(SHT, Jass::GetHandleId(buffTimer), 0, u);
            Jass::TimerStart(buffTimer, 0.33, true, function() {
                unit u = Jass::LoadUnitHandle(SHT, Jass::GetHandleId(Jass::GetExpiredTimer()), 0);
                string key = "" + Jass::GetHandleId(u);
                UnitData@ ud;
                if (UnitDataMap.get(key, @ud))
                    ud.TickBuffs(0.33, u);
                else
                {
                    Jass::ConsolePrint("Error: UnitData not found for unit in Buff Timer Tick, Registering Unit");
                    RegisterUnit(u);
                }
                    
            });
        }
        Recalc(u);
    }

    void RemoveBuff(int buffTypeId, unit u) {
        for (uint i = 0; i < buffs.length(); i++) {
            if (buffs[i].buffTypeId == buffTypeId) {
                if (buffs.length() == 1) {
                    // если это последний бафф, останавливаем таймер
                    if(buffTimer != nil) {
                        Jass::PauseTimer(buffTimer);
                        Jass::DestroyTimer(buffTimer);
                        buffTimer = nil;
                    }
                }
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

    // --- Вычислить бонусы от статов (зависит от героя) ---
    void ComputeStatDerived(int heroClass) {
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
        if (mainStatType == 0)      { effStr += mainStatBonus; statDerived.strength += mainStatBonus; }
        else if (mainStatType == 1) { effAgi += mainStatBonus; statDerived.agility += mainStatBonus; }
        else                        { effInt += mainStatBonus; statDerived.intelligence += mainStatBonus; }

        float effMainTotal;
        if (mainStatType == 0)      effMainTotal = effStr;
        else if (mainStatType == 1) effMainTotal = effAgi;
        else                        effMainTotal = effInt;

        // ХП: mainStat*3 + str*8 (одинаково для всех)
        statDerived.hp += effMainTotal * 3.0 + effStr * 8.0;

        // Реген ХП: зависит от типа основного стата
        if (mainStatType == 2) {
            // int-герои (Инженер, Медик, Подрывник): int * 0.05
            statDerived.hpRegen += effInt * 0.05;
        } else if (mainStatType == 0) {
            // str-герои (Сталкер, Пироманьяк, Ракетчик): mainStat * 0.03 + int * 0.015
            statDerived.hpRegen += effMainTotal * 0.03 + effInt * 0.015;
        } else {
            // agi-герои (Снайпер, Пулемётчик): mainStat * 0.015 + int * 0.03
            statDerived.hpRegen += effMainTotal * 0.015 + effInt * 0.03;
        }

        // Атака: зависит от класса героя
        if (heroClass == 1) {
            // Инженер: mainStat/2 + agi
            statDerived.damage += effMainTotal * 0.5 + effAgi;
        } else if (heroClass == 32) {
            // Медик: mainStat/3 + agi
            statDerived.damage += effMainTotal / 3.0 + effAgi;
        } else if (heroClass == 128) {
            // Сталкер: mainStat/2.5 + agi
            statDerived.damage += effMainTotal * 0.4 + effAgi;
        } else {
            // Подрывник, Пулемётчик, Снайпер, Ракетчик, Пироманьяк: agi + mainStat
            statDerived.damage += effAgi + effMainTotal;
        }

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
            if (items[i].slot < 0 || items[i].slot > 5) { Jass::ConsolePrint("[Recalc] skip slot=" + Jass::I2S(items[i].slot)); continue; }
            // Проверка уровня (lvl=1 — без ограничения)
            if (items[i].itemLevel > 1 && heroLvl < items[i].itemLevel) { Jass::ConsolePrint("[Recalc] skip lvl=" + Jass::I2S(items[i].itemLevel)); continue; }
            // Проверка класса
            if (items[i].allowedClass != 0 && heroClass != 0) {
                if ((items[i].allowedClass & heroClass) == 0) { Jass::ConsolePrint("[Recalc] skip class=" + Jass::I2S(items[i].allowedClass)); continue; }
            }
            // Проверка стакабельности
            if (items[i].maxStack > 0) {
                string sKey = "" + items[i].itemTypeId;
                int cnt = 0;
                if (stackCount.exists(sKey))
                    stackCount.get(sKey, cnt);
                if (cnt >= items[i].maxStack) { Jass::ConsolePrint("[Recalc] skip stack cnt=" + Jass::I2S(cnt) + " max=" + Jass::I2S(items[i].maxStack)); continue; }
                stackCount.set(sKey, cnt + 1);
            }
            Jass::ConsolePrint("[Recalc] ADD item typeId=" + Jass::I2S(items[i].itemTypeId) + " str=" + Jass::R2S(items[i].stats.strength));
            totalStats.Add(items[i].stats);
        }

        for (uint i = 0; i < buffs.length(); i++)
            totalStats.Add(buffs[i].stats);

        // Вычислить и добавить бонусы от статов
        ComputeStatDerived(heroClass);
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
        float bonusStr   = totalStats.strength    * (1 + totalStats.strengthPct)    - baseStats.strength;
        float bonusAgi   = totalStats.agility     * (1 + totalStats.agilityPct)     - baseStats.agility;
        float bonusInt   = totalStats.intelligence* (1 + totalStats.intelligencePct) - baseStats.intelligence;
        float bonusArmor = totalStats.armor       * (1 + totalStats.armorPct)       - baseStats.armor;
        float bonusDmg   = totalStats.damage      * (1 + totalStats.damagePct)      - baseStats.damage;
        float bonusAS    = (1 + totalStats.attackSpeed)  * (1 + totalStats.attackSpeedPct) - 1 - baseStats.attackSpeed;
        float bonusHP    = totalStats.hp           * (1 + totalStats.hpPct)          - baseStats.hp;
        float bonusMP    = totalStats.mp           * (1 + totalStats.mpPct)          - baseStats.mp;
        float bonusHPR   = totalStats.hpRegen      * (1 + totalStats.hpRegenPct)    - baseStats.hpRegen;
        float bonusMPR   = totalStats.mpRegen      * (1 + totalStats.mpRegenPct)    - baseStats.mpRegen;
        float finalMS    = 0.f;

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
        float baseMS = baseStats.moveSpeed;
        if (baseMS <= 0.f) {
            baseMS = Jass::GetUnitDefaultMoveSpeed(u);
        }

        float flatMSBonus = totalStats.moveSpeed - baseStats.moveSpeed;
        finalMS = (baseMS + flatMSBonus) * (1 + totalStats.moveSpeedPct);

        bool hardRoot = (totalStats.moveSpeedPct >= -1.001f && totalStats.moveSpeedPct <= -0.999f);
        if (!hardRoot && finalMS <= 0.f) {
            float currentMS = Jass::GetUnitMoveSpeed(u);
            finalMS = (currentMS > 0.f) ? currentMS : baseMS;
        }

        if (finalMS < 0.f) {
            finalMS = 0.f;
        }
        Jass::SetUnitMoveSpeed(u, finalMS);
        abil = nil;
    }

}

// ---------- Глобальное хранилище ----------

dictionary BaseStatsMap;   // ключ: unitTypeId, значение: UnitBaseTemplate@
dictionary ItemStatsMap;   // ключ: itemTypeId, значение: ItemBaseTemplate@
dictionary ItemInstanceMap; // ключ: itemHandleId, значение: ItemStats@

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

int NormalizeItemOwnerPlayerId(int ownerPlayerId) {
    if (ownerPlayerId > 0) {
        return ownerPlayerId;
    }
    return -1;
}

int ItemOwnerToLegacyStorage(int ownerPlayerId) {
    if (ownerPlayerId > 0) {
        return ownerPlayerId;
    }
    return 0;
}

ItemStats@ CreateBasicItemStats(int itemTypeId, int slot, int handleId, int ownerPlayerId = -1) {
    ItemStats itm;
    itm.itemTypeId = itemTypeId;
    itm.itemHandleId = handleId;
    itm.slot = slot;
    itm.itemLevel = 1;
    itm.maxStack = 0;
    itm.saveId = 0;
    itm.allowedClass = 0;
    itm.ownerPlayerId = NormalizeItemOwnerPlayerId(ownerPlayerId);
    itm.abilityId = 0;
    itm.abilityCooldown = 0;
    itm.abilityManaCost = 0;
    itm.stats.Reset();
    return itm;
}

ItemStats@ GetRegisteredItemDataByHandleId(int itemHandleId) {
    ItemStats@ itmData;
    if (ItemInstanceMap.get("" + itemHandleId, @itmData)) {
        return itmData;
    }
    return null;
}

ItemStats@ GetRegisteredItemData(item itm) {
    if (itm == nil) {
        return null;
    }
    return GetRegisteredItemDataByHandleId(Jass::GetHandleId(itm));
}

ItemStats@ RegisterItemInstance(item itm, int ownerPlayerId = -1, int slot = -1) {
    if (itm == nil) {
        return null;
    }

    int handleId = Jass::GetHandleId(itm);
    int itemTypeId = Jass::GetItemTypeId(itm);
    string key = "" + handleId;

    int normalizedOwner = NormalizeItemOwnerPlayerId(ownerPlayerId);
    if (normalizedOwner < 0) {
        ItemStats@ existingData = GetRegisteredItemDataByHandleId(handleId);
        if (existingData !is null && existingData.ownerPlayerId > 0) {
            normalizedOwner = existingData.ownerPlayerId;
        } else {
            int legacyOwner = Jass::LoadInteger(UnitHandleHT, handleId, 'ownr');
            if (legacyOwner > 0) {
                normalizedOwner = legacyOwner;
            }
        }
    }

    ItemStats@ itmData = GetRegisteredItemDataByHandleId(handleId);
    if (itmData is null) {
        @itmData = CreateItemFromTemplate(itemTypeId, slot, handleId, normalizedOwner);
        if (itmData is null) {
            @itmData = CreateBasicItemStats(itemTypeId, slot, handleId, normalizedOwner);
        }
        ItemInstanceMap.set(key, @itmData);
    } else {
        itmData.itemTypeId = itemTypeId;
        itmData.itemHandleId = handleId;
        if (slot >= 0) {
            itmData.slot = slot;
        }

        ItemBaseTemplate@ tpl = GetItemTemplate(itemTypeId);
        if (tpl !is null) {
            itmData.itemLevel = tpl.itemLevel;
            itmData.maxStack = tpl.maxStack;
            itmData.saveId = tpl.saveId;
            itmData.allowedClass = tpl.allowedClass;
            itmData.abilityId = tpl.abilityId;
            itmData.abilityCooldown = tpl.abilityCooldown;
            itmData.abilityManaCost = tpl.abilityManaCost;
            itmData.stats.Reset();
            itmData.stats.Add(tpl.stats);
        }
    }

    if (slot >= 0) {
        itmData.slot = slot;
    }
    itmData.ownerPlayerId = normalizedOwner;
    Jass::SaveInteger(UnitHandleHT, handleId, 'ownr', ItemOwnerToLegacyStorage(itmData.ownerPlayerId));
    return itmData;
}

int GetItemOwnerPlayerId(item itm) {
    ItemStats@ itmData = RegisterItemInstance(itm);
    if (itmData is null) {
        return -1;
    }
    return itmData.ownerPlayerId;
}

item CreateRegisteredItem(int itemTypeId, float x, float y, int ownerPlayerId = -1) {
    item itm = Jass::CreateItem(itemTypeId, x, y);
    RegisterItemInstance(itm, ownerPlayerId);
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

// ---------- Сгенерировано из Google таблицы ----------
void InitItemDescriptions() {
    DefItemDesc('I09H', "|cff00ff00Деревянная удочка|r", "|cff00ccff(Актив): Шанс выудить рыбку - 40%|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0AA', "|cff00ff00Арканитовая удочка|r", "|cff00ff00Хп +350|r|n|cff00ff00Увеличение всего урона -30%|r|n|cff00ccff(Актив): Шанс выудить рыбку - 100%, чаще вылавливает редкую рыбку|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01J', "|cff00ff00Железная оптика|r", "|cff00ff00Радиус +350|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01L', "|cff00ff00Серебряная оптика|r", "|cff00ff00Радиус +500|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01K', "|cff00ff00Ториевая оптика|r", "|cff00ff00Радиус +700|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01M', "|cff00ff00Арканитовая оптика|r", "|cff00ff00Радиус +900|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01T', "|cff00ff00Железные боеприпасы|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01U', "|cff00ff00Серебряные боеприпасы|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01V', "|cff00ff00Ториевые боеприпасы|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01W', "|cff00ff00Арканитовые боеприпасы|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I047', "|cff00ff00Серебряная пыль|r", "|cff00ccff(Актив): Позволяет обнаруживать скрытые предметы вокруг пользователя|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I048', "|cff00ff00Сырный Двигатель|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I123', "|cff00ff00Генератор|r", "");
    DefItemDesc('I049', "|cff00ff00Железный меха-гоблин|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04A', "|cff00ff00Серебряный меха-гоблин|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04B', "|cff00ff00Ториевый меха-гоблин|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I04C', "|cff00ff00Арканитовый меха-гоблин|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07G', "|cff00ff00Танк-нигдеход|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07H', "|cff00ff00Движок MТ II|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07I', "|cff00ff00Нагревательный блок|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07J', "|cff00ff00Гигантская лупа|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07K', "|cff00ff00Корпус \"Буро\"|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07L', "|cff00ff002 пары шагателей|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I07M', "|cff00ff00Набор деталей|r", "|cffff0000Не более 1 шт.|r");
    DefItemDesc('I024', "|cff00ff00Грибная настойка|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 3% хп|r");
    DefItemDesc('I02T', "|cff00ff00Грибной бульон|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 5% хп|r");
    DefItemDesc('I036', "|cff00ff00Грибной спирт|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 3% мп|r");
    DefItemDesc('I037', "|cff00ff00Грибная самогонка|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 5% мп|r");
    DefItemDesc('I06Y', "|cff00ff00Слабый энергетик|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 10% хп и мп в течений 10 сек|r");
    DefItemDesc('I06Z', "|cff00ff00Энергетик|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 15% хп и мп в течений 10 сек|r");
    DefItemDesc('I070', "|cff00ff00Сильный энергетик|r", "|cff00ccff(Актив): Дает 2 еды и восстанавливает 20% хп и мп в течений 10 сек|r");
    DefItemDesc('I004', "|cff00ff00Гоблинский шлем-котелок|r", "|cff00ff00Хп +130|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I009', "|cff00ff00Гоблинский бронежилет|r", "|cff00ff00Защита +1|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00A', "|cff00ff00Гоблинские сапоги|r", "|cff00ff00Скорость бега +10|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00B', "|cff00ff00Гоблинские перчатки|r", "|cff00ff00Атака +25|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I014', "|cff00ff00Гоблинский комбинезон|r", "|cff00ff00Хп +180|r|n|cff00ff00Атака +25|r|n|cff00ff00Защита +2|r|n|cff00ff00Скорость бега +15|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00H', "|cff00ff00Кожаная накидка|r", "|cff00ff00Ловкость +5|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00I', "|cff00ff00Железный нагрудник|r", "|cff00ff00Сила +5|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00J', "|cff00ff00Льняной плащ|r", "|cff00ff00Разум +5|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I017', "|cff00ff00Экспедиционный костюмчик|r", "|cff00ff00Все статы +5|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00K', "|cff00ff00Каска взрывника|r", "|cff00ff00Сила +8|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00L', "|cff00ff00Шапка|r", "|cff00ff00Ловкость +8|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00M', "|cff00ff00Маска|r", "|cff00ff00Разум +8|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01B', "|cff00ff00Каско-шлемо-маска|r", "|cff00ff00Все статы +10|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02H', "|cff00ff00Броне-комбез|r", "|cff00ff00Все статы +5|r|n|cff00ff00Хп +250|r|n|cff00ff00Атака +30|r|n|cff00ff00Защита +3|r|n|cff00ff00Скорость бега +15|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02I', "|cff00ff00Броне-скафандр|r", "|cff00ff00Все статы +15|r|n|cff00ff00Хп +250|r|n|cff00ff00Атака +30|r|n|cff00ff00Защита +3|r|n|cff00ff00Скорость бега +20|r|n|cff00ff00Сопротивление урону +2%|r|n|cff00ff00Увеличение всего урона +2%|r|n|cffff0000Не более 2 шт.|r");
    DefItemDesc('I005', "|cff00ff00Магический амулет|r", "|cff00ff00Регенерация мп +0.15|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I006', "|cff00ff00Красивая подвеска|r", "|cff00ff00Регенерация хп +2|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I015', "|cff00ff00Серебряная подвеска|r", "|cff00ff00Регенерация хп +3|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I016', "|cff00ff00Серебряный амулет|r", "|cff00ff00Регенерация мп +0.2|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02X', "|cff00ff00Полуфилософский камень|r", "|cff00ff00Регенерация хп +3|r|n|cff00ff00Регенерация мп +0.2|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02Y', "|cff00ff00Философский камень|r", "|cff00ff00Хп +100|r|n|cff00ff00Регенерация хп +3|r|n|cff00ff00Регенерация мп +0.2|r|n|cff00ccff(Актив): Превратить в золото.|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FB', "|cff00ff00Книга Времени (1й том)|r", "|cff00ff00Основной стат +20|r|n|cff00ff00Удача +1|r|n|cffff0000Доступен с 10 уровня|r");
    DefItemDesc('I0OB', "|cff00ff00Мультисталь|r", "");
    DefItemDesc('I00C', "|cff00ff00Ружьё|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Снайпер и Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00D', "|cff00ff00Базука|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00E', "|cff00ff00Огнемет|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00F', "|cff00ff00Пулемёт|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00G', "|cff00ff00Питарды|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I012', "|cff00ff00Шарострел|r", "|cff00ff00Основной стат +5|r|n|cffff0000Только для: Медик и Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01P', "|cff00ff00Арканитовое ружье|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Снайпер и Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01N', "|cff00ff00Арканитовая ракетница|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01Q', "|cff00ff00Арканитовый огнемёт|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01R', "|cff00ff00Арканитовый пулемёт|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01S', "|cff00ff00Арканитовые гранаты|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01O', "|cff00ff00Арканитовый шарострел|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Только для: Медик и Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03V', "|cff00ff00Самозарядный дробовик|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Защита +6|r|n|cff00ff00Блокирование +20|r|n|cff00ff00Сопротивление маг. урону +5%|r|n|cff00ff00Сопротивление физ. урону +5%|r|n|cff00ff00Радиус +100|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03W', "|cff00ff00Элитная снайперка|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Атака +20|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Увеличение физ. урона +3%|r|n|cff00ff00Радиус +300|r|n|cff00ccff(Актив): Повышает скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Снайпер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03X', "|cff00ff00Базука бомбера|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Атака +60|r|n|cff00ff00Защита +3|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Сопротивление физ. урону +5%|r|n|cff00ff00Радиус +100|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03Y', "|cff00ff00Мехо-пак|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Защита +3|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Скорость бега +20|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +100|r|n|cff00ccff(Актив): Призыв Дирижабля. Атака = Разум х2, 
Хп = Инженер/2, Аура (урона) +4%|r|n|cffffff00(Аура): (регенерация хп зданиям) +5|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03Z', "|cff00ff00Переносная мед-станция|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Хп +300|r|n|cff00ff00Защита +2|r|n|cff00ff00Регенерация мп +0.1|r|n|cff00ff00Сопротивление маг. урону +7%|r|n|cff00ff00Исходящий хил +5%|r|n|cff00ff00Удача +1|r|n|cff00ff00Радиус +100|r|n|cffffcc00(Пассив): Автохил союзника на 500 Хп раз в 8 сек.|r|n|cff00ccff(Актив): Восстановить 750 хп в АоЕ. Кд 10 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Медик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I040', "|cff00ff00Ядер-магическая бомба|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Мп +10|r|n|cff00ff00Защита +3|r|n|cff00ff00Увеличение маг. урона +5%|r|n|cff00ff00Радиус +100|r|n|cffffcc00(Пассив): Каждый каст скилла дает 2 маны.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I041', "|cff00ff00Пулемётная лента|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Атака +40|r|n|cff00ff00Защита +2|r|n|cff00ff00Скорость атаки +0.3|r|n|cff00ff00Скорость бега +20|r|n|cff00ff00Радиус +100|r|n|cffffff00(Аура): (увеличение атаки) 3% всем, себе и подконтрольным юнитам в 2 раза больше|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I042', "|cff00ff00Огнемётное охлаждение|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Защита +3|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Радиус +100|r|n|cffffcc00(Пассив): Увеличивает кап скорости атаки на 5%. 5% шанс при атаке восполнить 30 хп|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I053', "|cff00ff00Рубиновое колечко|r", "|cff00ff00Хп +100|r|n|cff00ff00Регенерация хп +2|r|n|cff00ff00Процент регенерации хп +5%|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I055', "|cff00ff00Рубиновое кольцо|r", "|cff00ff00Хп +175|r|n|cff00ff00Регенерация хп +3|r|n|cff00ff00Процент регенерации хп +7%|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I056', "|cff00ff00Рубиновый перстень|r", "|cff00ff00Хп +250|r|n|cff00ff00Регенерация хп +4|r|n|cff00ff00Процент регенерации хп +10%|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I057', "|cff00ff00Сапфировое колечко|r", "|cff00ff00Мп +5|r|n|cff00ff00Регенерация мп +0.05|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I054', "|cff00ff00Сапфировое кольцо|r", "|cff00ff00Мп +10|r|n|cff00ff00Регенерация мп +0.1|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I058', "|cff00ff00Сапфировый перстень|r", "|cff00ff00Мп +15|r|n|cff00ff00Регенерация мп +0.15|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05I', "|cff00ff00Алмазное колечко|r", "|cff00ff00Атака +30|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05J', "|cff00ff00Алмазное кольцо|r", "|cff00ff00Атака +45|r|n|cff00ff00Скорость атаки +0.15|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05K', "|cff00ff00Алмазный перстень|r", "|cff00ff00Атака +60|r|n|cff00ff00Скорость атаки +0.2|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05C', "|cff00ff00Аметистовое колечко|r", "|cff00ff00Крит Урон +10%|r|n|cff00ff00Крит Шанс +3%|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05D', "|cff00ff00Аметистовое кольцо|r", "|cff00ff00Крит Урон +15%|r|n|cff00ff00Крит Шанс +4%|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05E', "|cff00ff00Аметистовый перстень|r", "|cff00ff00Крит Урон +20%|r|n|cff00ff00Крит Шанс +5%|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05F', "|cff00ff00Топазовое колечко|r", "|cff00ff00Радиус +100|r|n|cffffcc00(Пассив): Каждые 25 сек даёт Щит на 100 ед.|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05G', "|cff00ff00Топазовое кольцо|r", "|cff00ff00Радиус +200|r|n|cffffcc00(Пассив): Каждые 25 сек даёт Щит на 250 ед.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05H', "|cff00ff00Топазовый перстень|r", "|cff00ff00Радиус +300|r|n|cffffcc00(Пассив): Каждые 25 сек даёт Щит на 350 ед.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I059', "|cff00ff00Изумрудное колечко|r", "|cff00ff00Скорость бега +10|r|n|cff00ff00Сопротивление урону +2%|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05A', "|cff00ff00Изумрудное кольцо|r", "|cff00ff00Скорость бега +15|r|n|cff00ff00Сопротивление урону +4%|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I05B', "|cff00ff00Изумрудный перстень|r", "|cff00ff00Скорость бега +20|r|n|cff00ff00Сопротивление урону +6%|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08X', "|cff00ff00Радужный камень|r", "|cff00ff00Все статы +25|r|n|cff00ff00Хп +150|r|n|cff00ff00Защита +3|r|n|cff00ff00Регенерация хп +3|r|n|cff00ff00Удача +1|r|n|cff00ccff(Актив): Превратить в золото|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08Y', "|cff00ff00Радужный скелет|r", "|cff00ff00Все статы +40|r|n|cff00ff00Хп +350|r|n|cff00ff00Атака +50|r|n|cff00ff00Защита +5|r|n|cff00ff00Скорость бега +30|r|n|cff00ff00Регенерация хп +5|r|n|cff00ff00Регенерация мп +0.1|r|n|cff00ff00Сопротивление урону +4%|r|n|cff00ff00Увеличение всего урона +4%|r|n|cff00ff00Удача +1|r|n|cff00ccff(Актив): Превратить в золото (Тройная сила)|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I08W', "|cff00ff00Мультицвет|r", "|cff00ff00Все статы +15|r|n|cff00ff00Защита +3|r|n|cff00ff00Удача +1|r|n|cffff0000Доступен с 5 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00O', "|cff00ff00Лапа гигантского арахнида|r", "");
    DefItemDesc('I00N', "|cff00ff00Голова гигантского арахнида|r", "");
    DefItemDesc('I00P', "|cff00ff00Клешня гигантского арахнида|r", "");
    DefItemDesc('I0OF', "|cff00ff00Жало гигантского арахнида|r", "|cff00ff00Основной стат +20|r|n|cffff0000Только для: Сталкер, Медик, Снайпер, Пулеметчик|r");
    DefItemDesc('I00Q', "|cff00ff00Бронежилет с лапой арахнида|r", "|cff00ff00Ловкость +20|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00R', "|cff00ff00Бронежилет с головой арахнида|r", "|cff00ff00Разум +20|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I00S', "|cff00ff00Бронежилет с клешней арахнида|r", "|cff00ff00Сила +20|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I01Z', "|cff00ff00Арахнидские перчатки|r", "|cff00ff00Атака +55|r|n|cff00ff00Скорость атаки +0.1|r|n|cff00ccff(Актив): Повышает скорость атаки на 0.3 на 5 сек. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I020', "|cff00ff00Арахнидские сапоги|r", "|cff00ff00Основной стат +20|r|n|cff00ff00Скорость бега +25|r|n|cff00ccff(Актив): Повышает скорость бега на 70 на 5 сек. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I021', "|cff00ff00Арахнидский шлем|r", "|cff00ff00Хп +200|r|n|cff00ff00Радиус +250|r|n|cff00ccff(Актив): Восстанавливает 400 хп и 10 мп. Кд 18 сек.|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OG', "|cff00ff00Заготовка для амулета|r", "");
    DefItemDesc('I0OH', "|cff00ff00Заготовка для кольца|r", "");
    DefItemDesc('I0OI', "|cff00ff00Заготовка для талисмана|r", "");
    DefItemDesc('I0OJ', "|cff00ff00Амулет из головы арахнида|r", "|cff00ff00Защита +4|r|n|cff00ff00Удача +1|r|n|cff00ccff(Актив): Накладывает щит на 800 хп на союзника на 15 сек. Кд 30 сек.|r|n|cffffff00(Аура): (Скорость бега) +10. (Процент регенерации хп) +0,15|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OK', "|cff00ff00Кольцо из клешни арахнида|r", "|cff00ff00Атака +100|r|n|cff00ccff(Актив): Увеличивает исходящий урон на 10%. Длительность 5 сек.  Кд 25 сек|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OL', "|cff00ff00Талисман из лапы арахнида|r", "|cff00ff00Хп +400|r|n|cff00ff00Регенерация хп +10|r|n|cff00ff00Блокирование +10|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I023', "|cff00ff00Арахнидский доспех|r", "|cff00ff00Ловкость +30|r|n|cff00ff00Скорость атаки +0.1|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0CT', "|cff00ff00Каменный доспех|r", "|cff00ff00Сила +30|r|n|cff00ff00Защита +3|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0GA', "|cff00ff00Доспех Паучьего Жреца|r", "|cff00ff00Разум +30|r|n|cff00ff00Регенерация мп +0.05|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OP', "|cff00ff00Реликварий Арахнидов(1)|r", "|cff00ff00Все статы +20|r|n|cff00ff00Хп +500|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I022', "|cff00ff00Сет Арахнида|r", "|cff00ff00Все статы +35|r|n|cff00ff00Атака +80|r|n|cff00ff00Радиус +300|r|n|cffffff00(Аура): (Скорость атаки) +0,1. (Скорость бега) +30|r|n|cffff0000Доступен с 10 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FD', "|cff00ff00Книга Времени (2й том)|r", "|cff00ff00Основной стат +35|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02R', "|cff00ff00Свечка рабовладельца|r", "|cff00ff00Регенерация хп +2|r|n|cff00ff00Радиус +100|r|n|cff00ff00Обнаружение +150|r");
    DefItemDesc('I0OY', "|cff00ff00Рабские оковы|r", "|cff00ff00Хп +200|r|n|cff00ccff(Актив): Заковывает в кандалы цель, не позволяя ей передвигаться на 5 сек. кд 30. Не работает на боссов|r");
    DefItemDesc('I0OZ', "|cff00ff00Одеколон \"Потный\"|r", "|cff00ff00Регенерация мп +0.05|r|n|cff00ccff(Актив): Владелец откупоривает сосуд, создавая на 4 секунд облако вонючего газа с радиусом 200, которое наносит (Основной стат Х 3) магического урона каждые 0.5 сек. кд 25 сек.|r|n|cffff0000Только для: Пироманьяк, Подрывник, Рокетчик|r");
    DefItemDesc('I02Q', "|cff00ff00Кирка рабовладельца|r", "|cff00ff00Основной стат +30|r|n|cff00ff00Скорость атаки +0.2|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I02P', "|cff00ff00Перчатка рабовладельца|r", "|cff00ff00Скорость атаки +0.1|r|n|cff00ff00Крит Урон +10%|r");
    DefItemDesc('I0P0', "|cff00ff00Кольцо рабовладельца|r", "|cff00ccff(Актив): Призывает раба с (основной стат) урон, и (50% от макс хп) хп на 15 сек. кд 30|r|n|cffffff00(Аура): Уменьшение получаемого урона 5%|r|n|cffff0000Доступен с 15 уровня|r");
    DefItemDesc('I0P1', "|cff00ff00Реликварий Арахнидов(2)|r", "|cff00ff00Все статы +35|r|n|cff00ff00Хп +800|r|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0P2', "|cff00ff00Реликварий Рабовладельца(2)|r", "|cff00ff00Все статы +35|r|n|cff00ff00Атака +40|r|n|cff00ff00Скорость атаки +0.2|r|n|cffffcc00(Пассив): Уменьшает базовый интервал атак на 0.05|r|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0OM', "|cff00ff00Грозный Арахнидский доспех|r", "|cff00ff00Ловкость +40|r|n|cff00ff00Скорость атаки +0.3|r|n|cffffcc00(Пассив): Каждая атака раз в 0.5 сек дает стак, при достижений 10й стаков, предмет можно будет активировать. Увеличивает скорость атаки на 20% на 3 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0ON', "|cff00ff00Грозный Каменный доспех|r", "|cff00ff00Сила +40|r|n|cff00ff00Защита +7|r|n|cff00ccff(Актив): Увеличивает хп-реген на 30% на 7 сек. Кд 25 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0OO', "|cff00ff00Грозный Доспех Паучьего Жреца|r", "|cff00ff00Разум +40|r|n|cff00ff00Регенерация мп +0.1|r|n|cffffcc00(Пассив): Раз в 10 секунд дает стак. Максимум 6 стаков.|r|n|cff00ccff(Актив): Увеличивает мп реген на (1 х стак) всем союзникам в радиусе 300. на 3 сек.|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FF', "|cff00ff00Арахнидский кастет|r", "|cff00ff00Атака +60|r|n|cffffcc00(Пассив): Каждые 6 сек. усиливает атаку: Усиленная атака наносит Основной стат х4 + Атака х0.33 урона в 150 АОЕ|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I02S', "|cff00ff00Сет Рабовладельца|r", "|cff00ff00Все статы +55|r|n|cff00ff00Регенерация хп +20|r|n|cff00ff00Блокирование +20|r|n|cff00ff00Сопротивление маг. урону +5%|r|n|cff00ff00Обнаружение +200|r|n|cff00ccff(Актив): Заковывает в кандалы цель, не позволяя ей передвигаться, увеличивает ее наносимый урон на 10%, и уменьшает получаемый на 20% на 7 сек. кд 30. Дебафф не запрещает передвигаться боссу.|r|n|cffff0000Доступен с 20 уровня|r");
    DefItemDesc('I0BB', "|cff00ff00Зажигалка|r", "|cff00ff00Сила +45|r|n|cffffcc00(Пассив): Атаки под усилением E дополнительно наносят 15% урона в радиусе 75|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0BC', "|cff00ff00Бум-Стик А-2|r", "|cff00ff00Сила +45|r|n|cffffcc00(Пассив): При атаке с шансом 10% может сработать эффект Q с 50% уроном|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0BG', "|cff00ff00Мед-Протез|r", "|cff00ff00Разум +45|r|n|cffffcc00(Пассив): Увеличивает радиус Q на 75|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I0P3', "|cff00ff00Мультикирка|r", "|cff00ff00Разум +45|r|n|cffffcc00(Пассив): Кол-во добываемой руды +1|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I02W', "|cff00ff00Потная граната|r", "|cff00ff00Разум +45|r|n|cffffcc00(Пассив): Увеличивает радиус Q на 20% и урон Q на 10%|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I0P4', "|cff00ff00Колючий шлем|r", "|cff00ff00Сила +45|r|n|cffffcc00(Пассив): Применение Q накладывает на владельца слабое развеивание|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0P5', "|cff00ff00Снайперка \"Скорпион\"|r", "|cff00ff00Ловкость +45|r|n|cffffcc00(Пассив): Увеличивает урон Q на 30%.|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I04H', "|cff00ff00Ручной акселератор|r", "|cff00ff00Ловкость +45|r|n|cffffcc00(Пассив): Эффективность Е +10%|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0FG', "|cff00ff00Лампа из черепа|r", "|cff00ff00Хп +300|r|n|cff00ff00Радиус +150|r|n|cff00ff00Обнаружение +100|r|n|cffffff00(Аура): Регенерация хп +10|r|n|cffff0000Доступен с 15 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0GX', "|cff00ff00Священный свет|r", "|cff00ff00Все статы +35|r|n|cff00ff00Процент регенерации хп +20%|r|n|cff00ff00Удача +3|r|n|cff00ff00Радиус +200|r|n|cff00ff00Обнаружение +150|r|n|cff00ccff(Актив): Призыв арахнида-целителя|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BE', "|cff00ff00Перчатка Власти|r", "|cff00ff00Атака +100|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Крит Урон +30%|r|n|cff00ff00Крит Шанс +2%|r|n|cffff0000Доступен с 20 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FH', "|cff00ff00Книга Времени (3й том)|r", "|cff00ff00Основной стат +50|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I029', "|cff00ff00Руна|r", "");
    DefItemDesc('I0P6', "|cff00ff00Плазма|r", "");
    DefItemDesc('I00Z', "|cff00ff00Броня Стража|r", "");
    DefItemDesc('I00X', "|cff00ff00Щит Стража|r", "");
    DefItemDesc('I010', "|cff00ff00Душа Стража|r", "");
    DefItemDesc('I00Y', "|cff00ff00Посох Стража|r", "|cff00ff00Основной стат +50|r|n|cffff0000Только для: Рокетчик, Подрывник, Медик|r");
    DefItemDesc('I0P7', "|cff00ff00Амулет Стража|r", "|cff00ff00Защита +10|r|n|cff00ff00Сопротивление маг. урону +5%|r|n|cff00ff00Удача +2|r|n|cff00ccff(Актив): Создает барьер в виде купола радиусом 300 на 10 сек., который поглощает 30% получаемого гоблинами урона в сумме до (Макс.хп), после чего он исчезает. Кд 35 сек.|r|n|cffffff00(Аура): (Скорость бега) +15. (Процент регенерации хп) +0,25|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I011', "|cff00ff00Сет Стража|r", "|cff00ff00Все статы +85|r|n|cff00ff00Основной стат +20|r|n|cff00ff00Скорость бега +25|r|n|cff00ff00Регенерация мп +0.1|r|n|cff00ccff(Актив): Запечатывает выбраного гоблина на 5 сек и создает в радиусе 250 от него на окружности равномерно три руны так же на 5 сек. При подборе руна восстанавливает 15 маны и 10% хп. Пока гоблин запечатан, он получает неуязвимость, но становится оглушен. Если подобрать все три руны, то с гоблина моментально спадет статус запечатан. Кд 75 сек.|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0P8', "|cff00ff00Броня Хранителя|r", "|cff00ff00Сила +35|r|n|cff00ff00Хп +400|r|n|cff00ff00Защита +4|r|n|cff00ff00Скорость бега -15|r|n|cff00ff00Сопротивление маг. урону +7%|r|n|cff00ff00Сопротивление физ. урону +7%|r|n|cff00ccff(Актив): Накладывает на владельца слабое развеивание и дает щит на 15% от Макс. ХП. Длительность щита 8 сек, Кд 35 сек.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0P9', "|cff00ff00Статический браслет|r", "|cff00ff00Все статы +25|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ccff(Актив): Выпускает разряд, который наносит (Основной стат Х 20) маг урона в радиусе 300 и отталкивающий противников на 200 от гоблина. Кд 35|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PA', "|cff00ff00Сапоги призрака|r", "|cff00ff00Основной стат +15|r|n|cff00ff00Скорость бега +35|r|n|cff00ff00Сопротивление маг. урону +5%|r|n|cff00ff00Увеличение маг. урона +35%|r|n|cff00ff00Обнаружение +200|r|n|cff00ccff(Актив): Гоблин на 5 сек входит в астрал, с увеличенным на 20% мс но уменьшенным на 40% сопротивлением к магии и возможностью проходить сквозь существ. Кд 35|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PB', "|cff00ff00Восковой доспех|r", "|cff00ff00Хп +400|r|n|cff00ff00Защита +3|r|n|cff00ff00Блокирование +35|r|n|cff00ff00Получаемый хил +7%|r|n|cff00ff00Исходящий хил +7%|r|n|cffffcc00(Пассив): После получения атаки, уменьшает ас атакующего на 0.1 и мс на 10%|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0PC', "|cff00ff00Реликварий Арахнидов(3)|r", "|cff00ff00Все статы +55|r|n|cff00ff00Хп +1100|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0PD', "|cff00ff00Реликварий Рабовладельца(3)|r", "|cff00ff00Все статы +55|r|n|cff00ff00Атака +75|r|n|cff00ff00Скорость атаки +0.3|r|n|cffffcc00(Пассив): Уменьшает базовый интервал атак на 0.075|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I0PE', "|cff00ff00Реликварий Стража(3)|r", "|cff00ff00Все статы +55|r|n|cff00ff00Мп +20|r|n|cff00ff00Регенерация мп +0.35|r|n|cff00ccff(Актив): Восполняет ману до максимума. Кд 75 сек.|r|n|cffff0000Доступен с 30 уровня|r");
    DefItemDesc('I032', "|cff00ff00Усилитель|r", "|cff00ff00Ловкость +20|r|n|cff00ff00Атака +150|r|n|cff00ff00Крит Урон +15%|r|n|cffffcc00(Пассив): Каждые 6 сек усиливает гоблина. Дает ему 20% увеличение всего урона до его следующей атаки или нажатой способности.|r|n|cffff0000Доступен с 25 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0Q4', "|cff00ff00Мультиудочка|r", "|cff00ff00Хп +650|r|n|cff00ff00Увеличение всего урона -60%|r|n|cff00ccff(Актив): Шанс выудить рыбку - 100%. Может выловить некоторые ресурсы.|r|n|cffff0000Доступен с 25 уровня|r");
    DefItemDesc('I0OC', "|cff00ff00Обогощенный Арахнидский сплав|r", "");
    DefItemDesc('I076', "|cff00ff00Зелье защиты|r", "|cff00ccff(Актив): На 30 сек дает 20% сопротивления урону. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I077', "|cff00ff00Зелье ловкости|r", "|cff00ccff(Актив): На 30 сек дает 20% к ловкости. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0PF', "|cff00ff00Зелье скорости|r", "|cff00ccff(Актив): На 30 сек дает 100 скорости передвижения и 0.5 ас. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0PG', "|cff00ff00Зелье жизни|r", "|cff00ccff(Актив): На 30 сек дает +20% ХП. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I072', "|cff00ff00Зелье интеллекта|r", "|cff00ccff(Актив): На 30 сек дает +20% к интеллекту. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I078', "|cff00ff00Зелье урона|r", "|cff00ccff(Актив): На 30 сек дает  +20% увеличение физ. урона. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I073', "|cff00ff00Зелье силы|r", "|cff00ccff(Актив): На 30 сек дает +20% силы. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I0LA', "|cff00ff00Зелье магии|r", "|cff00ccff(Актив): На 30 сек дает +20% увеличение маг. урона. КД 300 и общее между всеми зельями.|r");
    DefItemDesc('I08Z', "|cff00ff00Каратель|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Защита +12|r|n|cff00ff00Блокирование +55|r|n|cff00ff00Сопротивление маг. урону +10%|r|n|cff00ff00Сопротивление физ. урону +10%|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +200|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Сталкер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I090', "|cff00ff00Безмолвный палач|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Защита +2|r|n|cff00ff00Скорость атаки +0.4|r|n|cff00ff00Крит Урон +30%|r|n|cff00ff00Крит Шанс +8%|r|n|cff00ff00Увеличение физ. урона +7%|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +500|r|n|cff00ccff(Актив): Повышает кап ас на 40% и скорость атаки до максимума на 4 атаки, но понижает скорость бега на 100%. Кд 25.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Снайпер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I091', "|cff00ff00Лютый|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Атака +110|r|n|cff00ff00Защита +4|r|n|cff00ff00Скорость атаки +0.6|r|n|cff00ff00Скорость бега +40|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +200|r|n|cffffff00(Аура): (Увеличение Атаки и ХП) 8% всем, себе и своим подконтрольным юнитам в 2 раза больше.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Пулеметчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I092', "|cff00ff00HealPack-3000|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Хп +650|r|n|cff00ff00Защита +6|r|n|cff00ff00Регенерация мп +0.15|r|n|cff00ff00Сопротивление маг. урону +10%|r|n|cff00ff00Исходящий хил +15%|r|n|cff00ff00Удача +4|r|n|cff00ff00Радиус +200|r|n|cffffcc00(Пассив): Автохил союзника на 1400 раз в 8 сек.|r|n|cff00ccff(Актив): Восстановить 1500 хп в АОЕ. кд 10 сек|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Медик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I093', "|cff00ff00Тех-Протез|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Защита +8|r|n|cff00ff00Скорость атаки +0.4|r|n|cff00ff00Скорость бега +40|r|n|cff00ff00Удача +6|r|n|cff00ff00Радиус +200|r|n|cffffcc00(Пассив): Добыча руды +1|r|n|cff00ccff(Актив): Призыв Ылитного Дирижабля|r|n|cffffff00(Аура): Регенерация техники +1 и Атаки техники +50%|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Инженер|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I094', "|cff00ff00Бумер|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Мп +20|r|n|cff00ff00Защита +7|r|n|cff00ff00Регенерация мп +0.1|r|n|cff00ff00Увеличение маг. урона +10%|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +200|r|n|cffffcc00(Пассив): Каждый каст скилла дает стак на 3 сек(каждый стак имеет свое время, а не обновляется). Кажлый каст спелла дает (стак х 1) маны.|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Подрывник|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I095', "|cff00ff00Mr. Пламень|r", "|cff00ff00Основной стат +75|r|n|cff00ff00Мп +10|r|n|cff00ff00Защита +8|r|n|cff00ff00Скорость атаки +0.2|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +200|r|n|cffffcc00(Пассив): При каждой атаке получает стак на 5 сек. Получение стака обновляет время действия. Каждый стак увеличивает скорость атаки на 0.03 и кап ас на 0.01 вплоть до 20 стаков. Также при атаке 5% шанс восполнить 100 хп|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Пироманьяк|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I096', "|cff00ff00Большой Сэм|r", "|cff00ff00Ловкость +30|r|n|cff00ff00Основной стат +75|r|n|cff00ff00Атака +160|r|n|cff00ff00Защита +6|r|n|cff00ff00Скорость атаки +0.4|r|n|cff00ff00Сопротивление физ. урону +10%|r|n|cff00ff00Удача +2|r|n|cff00ff00Радиус +200|r|n|cffff0000Доступен с 30 уровня|r|n|cffff0000Только для: Ракетчик|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0FI', "|cff00ff00Книга Времени (4й том)|r", "|cff00ff00Основной стат +75|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I03C', "|cff00ff00Аккумуляторная кислота|r", "");
    DefItemDesc('I03A', "|cff00ff00Ториевый обломок генератора|r", "");
    DefItemDesc('I03B', "|cff00ff00Кусок ториевой гусеницы|r", "");
    DefItemDesc('I0PI', "|cff00ff00Заржавевший арканитовый ковш|r", "");
    DefItemDesc('I0PJ', "|cff00ff00Патронташ|r", "|cff00ff00Основной стат +75|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик, Снайпер|r");
    DefItemDesc('I0PK', "|cff00ff00Армированная пластина|r", "|cff00ff00Основной стат +75|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0PL', "|cff00ff00Тангенциальный вращатель|r", "|cff00ff00Основной стат +75|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0PM', "|cff00ff00Топливный бак|r", "|cff00ff00Основной стат +75|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I03C', "|cff00ff00Магическое ультра-горючее|r", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03D', "|cff00ff00Ториевый нейро-генератор|r", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03E', "|cff00ff00Доспех из ториевой гусеницы|r", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I0PN', "|cff00ff00Арканитовый ковш-шлем|r", "|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I03K', "|cff00ff00Ториевая циркулярная пила|r", "|cff00ff00Сила +75|r|n|cff00ff00Разум +75|r|n|cff00ff00Крит Урон +50%|r|n|cff00ff00Сопротивление физ. урону +5%|r|n|cff00ccff(Актив): Наносит (Основной Стат х40) физ урона противникам в радиусе 250 вокруг себя. Кд 20 сек|r|n|cffffff00(Аура): -5% защиты  противникам в радиусе 250|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I03L', "|cff00ff00Экзоскелет КУС-500rmk|r", "|cff00ff00Все статы +110|r|n|cff00ff00Хп +550|r|n|cff00ccff(Актив): Активирует экзоскелет позволяя превратиться в форму трактора на 15 сек. Пока форма активна, дает +20% мр, +15 защиты, +1 скорости атаки, но снижает скорость передвижения на 150. Кд 60 сек|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PO', "|cff00ff00Талисман конструктора|r", "|cff00ff00Все статы +60|r|n|cff00ff00Регенерация хп +20|r|n|cff00ff00Блокирование +50|r|n|cff00ff00Удача +2|r|n|cff00ccff(Актив): Строит неуязвимый маячек на полу. Если маячек уже стоит, то уничтожает его и телепортирует владельца на его местоположение|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PP', "|cff00ff00Реликварий Арахнидов(4)|r", "|cff00ff00Все статы +85|r|n|cff00ff00Хп +1450|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PQ', "|cff00ff00Реликварий Рабовладельца(4)|r", "|cff00ff00Все статы +85|r|n|cff00ff00Атака +120|r|n|cff00ff00Скорость атаки +0.4|r|n|cffffcc00(Пассив): Уменьшает базовый интервал атак на 0.1|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PR', "|cff00ff00Реликварий Стража(4)|r", "|cff00ff00Все статы +85|r|n|cff00ff00Мп +30|r|n|cff00ff00Регенерация мп +0.45|r|n|cff00ccff(Актив): Восполняет ману до максимума. Кд 75 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0PS', "|cff00ff00Реликварий Трактора(4)|r", "|cff00ff00Все статы +85|r|n|cff00ff00Защита +15|r|n|cff00ff00Скорость бега -30|r|n|cff00ff00Сопротивление маг. урону +20%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BN', "|cff00ff00Кислотная граната|r", "|cff00ff00Разум +75|r|n|cff00ff00Основной стат +30|r|n|cff00ff00Увеличение маг. урона +25%|r|n|cff00ccff(Актив): Бросает в точку гранату, которая наносит (Основной Стат х20) маг урона противникам в радиусе 250, а также снимает 10 защиты всем юнитам (включая союзным) в области действия на 10 сек. При попадании по уязвимой постройке, наносит ей (50% от ее Макс ХП) урона. Кд 30 сек.|r|n|cffff0000Доступен с 35 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BO', "|cff00ff00Хим-костюм|r", "|cff00ff00Сила +30|r|n|cff00ff00Основной стат +75|r|n|cff00ff00Процент регенерации хп +15%|r|n|cff00ff00Сопротивление маг. урону +15%|r|n|cff00ff00Получаемый хил +15%|r|n|cff00ff00Исходящий хил +15%|r|n|cff00ff00Радиус -250|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0BQ', "|cff00ff00Гусеничные сапоги|r", "|cff00ff00Ловкость +60|r|n|cff00ff00Основной стат +60|r|n|cff00ff00Хп +450|r|n|cff00ff00Скорость бега +20|r|n|cff00ff00Крит Шанс +5%|r|n|cff00ff00Удача +1|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I063', "|cff00ff00Цветное огниво|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): При использовании Q через 3 секунды дополнительно срабатывает аналогичный ему эффект из той же точки каста с эффективностью 50%.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0BL', "|cff00ff00Осколочный миноукладчик|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Увеличивает максимальное количество взрывчаток R до 4. Так же позволяет генерировать взрывчатку при атаке раз в 10 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I04I', "|cff00ff00ЭлектроПулемет|r", "|cff00ff00Ловкость +100|r|n|cffffcc00(Пассив): При применении W на союзника, так же применяет W на владельца. Увеличивает кд W на 50%.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0G9', "|cff00ff00Виварий|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Раз в 1 секунд при атаке вызывает срабатывание Q в ближайшего противника без затрат маны (не наносит урон глыбам). Увеличивает урон Q На 60%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0GC', "|cff00ff00Ворчун|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): Увеличивает урон, радиус и количество выстрелов T вдвое|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0BP', "|cff00ff00Шипованный доспех|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): После использования W в месте появления владелец агрит всех противников в радиусе 350 на 3 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0PT', "|cff00ff00Плазмокоагулятор|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Лечение от W увеличивается на 5% каждую секунду. В конце эффекта облако взрывается нанося урон равный 1000% суммарного лечения всем противникам в радиусе облака.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I06N', "|cff00ff00Бронебойная снайперка|r", "|cff00ff00Ловкость +100|r|n|cffffcc00(Пассив): T теперь заряжается 5 секунд, за каждую секунду зарядки наносит на 10% больше урона и станит на 10% дольше. Во время зарядки можно поворачивать сторону выстрела и отпустить раньше.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I0PU', "|cff00ff00Зажигалка v2|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): Атаки под усилением E дополнительно наносят 50% урона в радиусе 150.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пироманьяк|r");
    DefItemDesc('I0PV', "|cff00ff00Бум-Стик А-2 v2|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): При атаке с шансом 10% может сработать эффект Q с 80% уроном. Каждое такое срабатывание уменьшает кд Q на 0.5 сек.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Ракетчик|r");
    DefItemDesc('I0PW', "|cff00ff00Мед-Протез v2|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Увеличивает радиус Q на 75. Попадание по союзнику дает 20% мр на 3 секунды. Попадание по противнику снижает 20% мр на 5 секунд.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Медик|r");
    DefItemDesc('I0PX', "|cff00ff00Мультикирка v2|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Кол-во добываемой руды +2, количество добываемых самоцветов +1|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Инженер|r");
    DefItemDesc('I0PY', "|cff00ff00Потная граната v2|r", "|cff00ff00Разум +100|r|n|cffffcc00(Пассив): Увеличивает радиус Q на 30% и урон Q на 40%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Подрывник|r");
    DefItemDesc('I0PZ', "|cff00ff00Колючий шлем v2|r", "|cff00ff00Сила +100|r|n|cffffcc00(Пассив): Применение Q накладывает на владельца слабое развеивание. Уменьшает кд Q на 1 сек за каждый снятый дебафф|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Сталкер|r");
    DefItemDesc('I0Q0', "|cff00ff00Снайперка \"Скорпион\" v2|r", "|cff00ff00Ловкость +100|r|n|cffffcc00(Пассив): Увеличивает урон Q на 40%
Каждый 6 выстрел по одному таргету кастует Q в него без затрат маны.|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Снайпер|r");
    DefItemDesc('I0Q1', "|cff00ff00Ручной акселератор v2|r", "|cff00ff00Ловкость +100|r|n|cffffcc00(Пассив): Эффективность Е +20%|r|n|cffff0000Доступен с 40 уровня|r|n|cffff0000Только для: Пулеметчик|r");
    DefItemDesc('I0D4', "|cff00ff00Эссенция Огня|r", "|cffffcc00(Пассив): Эссенция чистой демонической силы манит владельца использовать ее. Если она будет в инвентаре минуту, то она автоматически используется.|r|n|cff00ccff(Актив): Убивает владельца, после чего дает ему невообразимую мощь на 15 секунд.|r");
    DefItemDesc('I07N', "|cff00ff00Око демона|r", "|cff00ff00Крит Шанс +25%|r|n|cff00ff00Удача -1|r|n|cff00ff00Радиус +900|r|n|cff00ff00Обнаружение +300|r|n|cff00ccff(Актив): Высвобождает око, позваоляющее видеть через препятствия в течении 8 сек. Кд 25 сек.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I07P', "|cff00ff00Ярость|r", "|cff00ff00Удача -1|r|n|cffffff00(Аура): Скорость атаки +0.7|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I07R', "|cff00ff00Мощь|r", "|cff00ff00Все статы +150|r|n|cff00ff00Хп -1650|r|n|cff00ff00Удача -2|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0AR', "|cff00ff00Аметистовое ожерелье|r", "|cff00ff00Крит Урон +30%|r|n|cff00ff00Крит Шанс +10%|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B6', "|cff00ff00Сапфировое ожерелье|r", "|cff00ff00Мп +30|r|n|cff00ff00Регенерация мп +0.2|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B7', "|cff00ff00Изумрудное ожерелье|r", "|cff00ff00Скорость бега +40|r|n|cff00ff00Сопротивление урону +10%|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B8', "|cff00ff00Рубиновое ожерелье|r", "|cff00ff00Хп +1000|r|n|cff00ff00Регенерация хп +25|r|n|cff00ff00Процент регенерации хп +15%|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0B9', "|cff00ff00Топазовое ожерелье|r", "|cff00ff00Радиус +250|r|n|cffffcc00(Пассив): Каждые 25 сек даёт Щит на 1050 ед.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0BA', "|cff00ff00Алмазное ожерелье|r", "|cff00ff00Атака +300|r|n|cff00ff00Скорость атаки +0.3|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CV', "|cff00ff00Демоническая удочка|r", "|cff00ff00Хп +1050|r|n|cff00ff00Увеличение всего урона -90%|r|n|cff00ccff(Актив): Шанс выудить рыбку - 100%. Вылавливает ресурсы качеством выше.|r|n|cffff0000Доступен с 35 уровня|r");
    DefItemDesc('I0CX', "|cff00ff00Ожерелье \"Фиалка\"|r", "|cff00ff00Хп +1000|r|n|cff00ff00Мп +30|r|n|cff00ff00Регенерация хп +25|r|n|cff00ff00Процент регенерации хп +15%|r|n|cff00ff00Регенерация мп +0.2|r|n|cff00ccff(Актив): Восстановить 40% хп и 30% мп. Кд 40 сек|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CY', "|cff00ff00Ожерелье \"Лайм\"|r", "|cff00ff00Скорость бега +40|r|n|cff00ff00Сопротивление урону +10%|r|n|cff00ff00Удача +6|r|n|cff00ff00Радиус +250|r|n|cff00ff00Обнаружение +100|r|n|cffffcc00(Пассив): Каждые 25 сек даёт Щит на 1050 ед.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0CZ', "|cff00ff00Ожерелье \"Индиго\"|r", "|cff00ff00Атака +300|r|n|cff00ff00Скорость атаки +0.3|r|n|cff00ff00Крит Урон +30%|r|n|cff00ff00Крит Шанс +10%|r|n|cffffcc00(Пассив): Увеличивает баффы от ожерелья на 50%, если владелец не получал урона в течении последних 4 секунд.|r|n|cffff0000Доступен с 40 уровня|r");
    DefItemDesc('I0FJ', "|cff00ff00Книга Времени (5й том)|r", "|cff00ff00Основной стат +100|r");
    DefItemDesc('I04D', "|cff00ff00Венец Похоти|r", "");
    DefItemDesc('I04E', "|cff00ff00Нагрудник Похоти|r", "");
    DefItemDesc('I04F', "|cff00ff00Наручники Похоти|r", "");
    DefItemDesc('I04J', "|cff00ff00Алебарда Похоти|r", "");
    DefItemDesc('I04G', "|cff00ff00Сет Похоти|r", "");
    DefItemDesc('I0BR', "|cff00ff00Корона Похоти|r", "");
    DefItemDesc('I0BS', "|cff00ff00Царь скорпионов|r", "");
    DefItemDesc('I0BT', "|cff00ff00Похотливая броня|r", "");
    DefItemDesc('I0BU', "|cff00ff00Охотник на ведьм|r", "");
    DefItemDesc('I0BW', "|cff00ff00Накидка амазонки|r", "");
    DefItemDesc('I07O', "|cff00ff00Ненависть|r", "");
    DefItemDesc('I07S', "|cff00ff00Доспехи Порчи|r", "");
    DefItemDesc('I0GM', "|cff00ff00Царская Любовь|r", "");
    DefItemDesc('I0DF', "|cff00ff00Сет Рабовладельца v2.0|r", "|cff00ff00Все статы +1|r|n|cff00ff00Сила +1|r|n|cff00ff00Ловкость +1|r|n|cff00ff00Разум +1|r|n|cff00ff00Основной стат +1|r|n|cff00ff00Хп +1|r|n|cff00ff00Мп +1|r|n|cff00ff00Атака +1|r|n|cff00ff00Защита +1|r|n|cff00ff00Скорость атаки +1|r|n|cff00ff00Скорость бега +1|r|n|cff00ff00Регенерация хп +1|r|n|cff00ff00Процент регенерации хп +100%|r|n|cff00ff00Регенерация мп +1|r|n|cff00ff00Крит Урон +100%|r|n|cff00ff00Крит Шанс +100%|r|n|cff00ff00Блокирование +1|r|n|cff00ff00Шанс стана +100%|r|n|cff00ff00Сопротивление маг. урону +100%|r|n|cff00ff00Сопротивление физ. урону +100%|r|n|cff00ff00Сопротивление урону +100%|r|n|cff00ff00Увеличение физ. урона +100%|r|n|cff00ff00Увеличение маг. урона +100%|r|n|cff00ff00Увеличение всего урона +100%|r|n|cff00ff00Получаемый хил +100%|r|n|cff00ff00Исходящий хил +100%|r|n|cff00ff00Удача +1|r|n|cff00ff00Радиус +1|r|n|cff00ff00Обнаружение +1|r|n|cffffcc00(Пассив): 1|r|n|cff00ccff(Актив): 1|r|n|cffffff00(Аура): 1|r|n|cffff0000Только для: 1|r|n|cffff0000Не более 1 шт.|r");
    DefItemDesc('I0DJ', "|cff00ff00Циркулярка v2.0|r", "");
    DefItemDesc('I0DK', "|cff00ff00Экзоскелет КУС-500 v2.0|r", "");
    DefItemDesc('I0DL', "|cff00ff00Арахнидский Камень v2.0|r", "");
    DefItemDesc('I0DM', "|cff00ff00Радужный скелет v2.0|r", "");
    DefItemDesc('I01E', "|cff00ff00Сет Хранителя v2.0|r", "");
    DefItemDesc('I01F', "|cff00ff00Сет Стража v2.0|r", "");
    DefItemDesc('I064', "|cff00ff00Освещенная антиграната|r", "");
    DefItemDesc('I07X', "|cff00ff00Священный Индиго|r", "");
    DefItemDesc('I0AJ', "|cff00ff00Священная Фиалка|r", "");
    DefItemDesc('I0AZ', "|cff00ff00Священный Лайм|r", "");
    DefItemDesc('I0FJ', "|cff00ff00Книга Времени (5й том)|r", "");
    DefItemDesc('I0FK', "|cff00ff00Книга Времени (6й том)|r", "");
    DefItemDesc('I0GF', "|cff00ff00Книга Времени (7й том)|r", "");
    DefItemDesc('I0GH', "|cff00ff00Книга Времени (8й том)|r", "");
    DefItemDesc('I0GI', "|cff00ff00Книга Времени (9й том)|r", "");
    DefItemDesc('I04P', "|cff00ff00Железная гаубица|r", "");
    DefItemDesc('I04Q', "|cff00ff00Перчатки Бомбса|r", "");
    DefItemDesc('I04R', "|cff00ff00Труба Аккуратерса|r", "");
    DefItemDesc('I04S', "|cff00ff00Бронежилет Бомбса|r", "");
    DefItemDesc('I04T', "|cff00ff00Мешок взрывчатки|r", "");
    DefItemDesc('I0GB', "|cff00ff00Конвертер O.R.E|r", "");
    DefItemDesc('I065', "|cff00ff00Акселератор электронов|r", "");
    DefItemDesc('I0H5', "|cff00ff00Пылающий восполнитель|r", "");
    DefItemDesc('I04V', "|cff00ff00Сет Бомбса|r", "");
    DefItemDesc('I04W', "|cff00ff00Сет Сапёра|r", "");
    DefItemDesc('I05S', "|cff00ff00Сет Аккуратерса|r", "");
    DefItemDesc('I0BV', "|cff00ff00Похотливые перчатки|r", "");
    DefItemDesc('I0D5', "|cff00ff00Сет Аккуратерса v2.0|r", "");
    DefItemDesc('I0D7', "|cff00ff00Сет Бомбса v2.0|r", "");
    DefItemDesc('I0DG', "|cff00ff00Сет Сапёра v2.0|r", "");
    DefItemDesc('I0GC', "|cff00ff00Ворчун|r", "");
    DefItemDesc('I01G', "|cff00ff00Взрывное одеяние жреца|r", "");
    DefItemDesc('I084', "|cff00ff00Перстень Алчности|r", "");
    DefItemDesc('I086', "|cff00ff00Коготь Алчности|r", "");
    DefItemDesc('I085', "|cff00ff00Ожерелье Алчности|r", "");
    DefItemDesc('I060', "|cff00ff00Крылья Алчности|r", "");
    DefItemDesc('I087', "|cff00ff00Сет Алчности|r", "");
    DefItemDesc('I0C0', "|cff00ff00Амулет продажности|r", "");
    DefItemDesc('I0BY', "|cff00ff00Философский перстень|r", "");
    DefItemDesc('I0BZ', "|cff00ff00Алла|r", "");
    DefItemDesc('I0C1', "|cff00ff00Жажда наживы|r", "");
    DefItemDesc('I067', "|cff00ff00Укладчик Взрывчаток|r", "");
    DefItemDesc('I06R', "|cff00ff00Огненное извержение|r", "");
    DefItemDesc('I0C2', "|cff00ff00Когтистая броня|r", "");
    DefItemDesc('I0H6', "|cff00ff00Когти антиматерии|r", "");
    DefItemDesc('I0FT', "|cff00ff00Льстец|r", "");
    DefItemDesc('I0HL', "|cff00ff00Шипастые сапоги|r", "");
    DefItemDesc('I0BX', "|cff00ff00Сила Демона|r", "");
    DefItemDesc('I01H', "|cff00ff00Ангельский свет|r", "");
    DefItemDesc('I08S', "|cff00ff00Телепортатор|r", "");
    DefItemDesc('I08T', "|cff00ff00Стазис-кружка|r", "");
    DefItemDesc('I08U', "|cff00ff00Очки Хазула|r", "");
    DefItemDesc('I07T', "|cff00ff00Сет Хазула|r", "");
    DefItemDesc('I0HJ', "|cff00ff00Нестабильный конвертер|r", "");
    DefItemDesc('I0BM', "|cff00ff00Нейро-балон|r", "");
    DefItemDesc('I0DD', "|cff00ff00Сет Хазула v2.0|r", "");
    DefItemDesc('I0NN', "|cff00ff00Радиационный костюм|r", "");
    DefItemDesc('I089', "|cff00ff00Повреждённый техно-модуль|r", "");
    DefItemDesc('I08A', "|cff00ff00Повреждённая силовая броня|r", "");
    DefItemDesc('I08B', "|cff00ff00Повреждённый реактор|r", "");
    DefItemDesc('I08C', "|cff00ff00Повреждённый окуляр|r", "");
    DefItemDesc('I08D', "|cff00ff00Повреждённый воспламенитель|r", "");
    DefItemDesc('I08E', "|cff00ff00Повреждённый ускоритель частиц|r", "");
    DefItemDesc('I08F', "|cff00ff00Повреждённая ракетница|r", "");
    DefItemDesc('I08G', "|cff00ff00Повреждённый преобразователь|r", "");
    DefItemDesc('I08J', "|cff00ff00Техно-модуль|r", "");
    DefItemDesc('I08H', "|cff00ff00Силовая броня|r", "");
    DefItemDesc('I08I', "|cff00ff00Ядерный Реактор|r", "");
    DefItemDesc('I08K', "|cff00ff00Магический Окуляр|r", "");
    DefItemDesc('I08L', "|cff00ff00Воспламенитель|r", "");
    DefItemDesc('I08M', "|cff00ff00Ускоритель частиц|r", "");
    DefItemDesc('I08N', "|cff00ff00Ракетная Установка|r", "");
    DefItemDesc('I08O', "|cff00ff00Преобразователь маны|r", "");
    DefItemDesc('I0EV', "|cff00ff00MEGA-HealPack|r", "");
    DefItemDesc('I0EW', "|cff00ff00Mr. Жаров|r", "");
    DefItemDesc('I0EX', "|cff00ff00Ледяная кара|r", "");
    DefItemDesc('I0EY', "|cff00ff00Сэмюэль Старший|r", "");
    DefItemDesc('I0EZ', "|cff00ff00Крашер|r", "");
    DefItemDesc('I0F0', "|cff00ff00Охотник|r", "");
    DefItemDesc('I0MF', "|cff00ff00Охотник|r", "");
    DefItemDesc('I0F1', "|cff00ff00Бешеный|r", "");
    DefItemDesc('I0F2', "|cff00ff00Чудо техники|r", "");
    DefItemDesc('I07Z', "|cff00ff00Адская Фиалка|r", "");
    DefItemDesc('I06U', "|cff00ff00Адский Индиго|r", "");
    DefItemDesc('I0AV', "|cff00ff00Адский Лайм|r", "");
    DefItemDesc('I0B1', "|cff00ff00Обсидиановая Фиалка|r", "");
    DefItemDesc('I0B0', "|cff00ff00Обсидиановый Индиго|r", "");
    DefItemDesc('I0B2', "|cff00ff00Обсидиановый Лайм|r", "");
    DefItemDesc('I0GS', "|cff00ff00Колючий Преградитель|r", "");
    DefItemDesc('I0D6', "|cff00ff00Сет Алчности v2.0|r", "");
    DefItemDesc('I0DN', "|cff00ff00Сила Демона v2.0|r", "");
    DefItemDesc('I0DA', "|cff00ff00Сет Похоти v2.0|r", "");
    DefItemDesc('I0M3', "|cff00ff00Демоническое одеяние жреца|r", "");
    DefItemDesc('I080', "|cff00ff00Пояс Страха|r", "");
    DefItemDesc('I09F', "|cff00ff00Глаза Страха|r", "");
    DefItemDesc('I09G', "|cff00ff00Язык Страха|r", "");
    DefItemDesc('I0FL', "|cff00ff00Когти Страха|r", "");
    DefItemDesc('I0FM', "|cff00ff00Наплечники Страха|r", "");
    DefItemDesc('I07W', "|cff00ff00Сет Страха|r", "");
    DefItemDesc('I0DC', "|cff00ff00Сет Страха v2|r", "");
    DefItemDesc('I0C5', "|cff00ff00Глотатель Страха|r", "");
    DefItemDesc('I0C6', "|cff00ff00Смотрящая в душу|r", "");
    DefItemDesc('I0C7', "|cff00ff00Медальон Кошмаров|r", "");
    DefItemDesc('I0H4', "|cff00ff00Загребушка-700|r", "");
    DefItemDesc('I0FN', "|cff00ff00Кости Страха|r", "");
    DefItemDesc('I0FO', "|cff00ff00Страхоискатель|r", "");
    DefItemDesc('I07Q', "|cff00ff00Подрыватель Страха|r", "");
    DefItemDesc('I0FS', "|cff00ff00Вдова|r", "");
    DefItemDesc('I0FU', "|cff00ff00Пугатель|r", "");
    DefItemDesc('I0GZ', "|cff00ff00Похотливый Ужас|r", "");
    DefItemDesc('I0HD', "|cff00ff00Очки обмана|r", "");
    DefItemDesc('I0H0', "|cff00ff00Испивающий душу|r", "");
    DefItemDesc('I0HE', "|cff00ff00Алмазные когти|r", "");
    DefItemDesc('I0HM', "|cff00ff00Доспех дознавателя|r", "");
    DefItemDesc('I0HN', "|cff00ff00Техбрат-25Т|r", "");
    DefItemDesc('I0HO', "|cff00ff00Душежог-3000-G|r", "");
    DefItemDesc('I0HP', "|cff00ff00Пытатель-135-F|r", "");
    DefItemDesc('I0I8', "|cff00ff00Пылающий пронзатель|r", "");
    DefItemDesc('I0CM', "|cff00ff00Доспехи Легиона|r", "");
    DefItemDesc('I0MQ', "|cff00ff00Осколок тьмы|r", "");
    DefItemDesc('I0MR', "|cff00ff00Осколок чистоты|r", "");
    DefItemDesc('I0MP', "|cff00ff00Очищающее зелье|r", "");
    DefItemDesc('I0AE', "|cff00ff00Порванная сеть|r", "");
    DefItemDesc('I0AH', "|cff00ff00Помятый серебряный ошейник|r", "");
    DefItemDesc('I0AF', "|cff00ff00Сломанная булава|r", "");
    DefItemDesc('I0AD', "|cff00ff00Ошейник Дрессировщика|r", "");
    DefItemDesc('I0AG', "|cff00ff00Сете-пушка Дрессировщика|r", "");
    DefItemDesc('I0AI', "|cff00ff00Электро-булава Дрессировщика|r", "");
    DefItemDesc('I0BI', "|cff00ff00Сет Дрессировщика|r", "");
    DefItemDesc('I0D8', "|cff00ff00Сет Дрессировщика v2.0|r", "");
    DefItemDesc('I0MG', "|cff00ff00Первая деталь экзотики|r", "");
    DefItemDesc('I0MH', "|cff00ff00Вторая деталь экзотики|r", "");
    DefItemDesc('I0GE', "|cff00ff00Экзотика|r", "");
    DefItemDesc('I0MI', "|cff00ff00Первая деталь бесстрашного война|r", "");
    DefItemDesc('I0MJ', "|cff00ff00Вторая деталь бесстрашного война|r", "");
    DefItemDesc('I0GY', "|cff00ff00Бесстрашный воин|r", "");
    DefItemDesc('I0MK', "|cff00ff00Первая деталь шокового устройства|r", "");
    DefItemDesc('I0ML', "|cff00ff00Вторая деталь шокового устройства|r", "");
    DefItemDesc('I0H2', "|cff00ff00Шоковое устройство|r", "");
    DefItemDesc('I0H9', "|cff00ff00Ошейник Подчинения|r", "");
    DefItemDesc('I0MM', "|cff00ff00Первая деталь навязчивого пламени|r", "");
    DefItemDesc('I0MN', "|cff00ff00Вторая деталь навязчивого пламени|r", "");
    DefItemDesc('I0II', "|cff00ff00Навязчивое пламя|r", "");
    DefItemDesc('I0H3', "|cff00ff00Электрическая клешня|r", "");
    DefItemDesc('I0MT', "|cff00ff00Деталь Сапогов Зоофила|r", "");
    DefItemDesc('I0MS', "|cff00ff00Сапоги Зоофила|r", "");
    DefItemDesc('I0MV', "|cff00ff00Деталь Призрака|r", "");
    DefItemDesc('I0MU', "|cff00ff00Призрак|r", "");
    DefItemDesc('I0MW', "|cff00ff00Астральная сетка|r", "");
    DefItemDesc('I0MX', "|cff00ff00Пища гоба|r", "");
    DefItemDesc('I0MY', "|cff00ff00Глаз-Алмаз|r", "");
    DefItemDesc('I0MZ', "|cff00ff00Шторм|r", "");
    DefItemDesc('I09U', "|cff00ff00Сердце Зависти|r", "");
    DefItemDesc('I0AL', "|cff00ff00Клык Зависти|r", "");
    DefItemDesc('I0AM', "|cff00ff00Цепь Зависти|r", "");
    DefItemDesc('I0AO', "|cff00ff00Резак Зависти|r", "");
    DefItemDesc('I0AP', "|cff00ff00Рог Зависти|r", "");
    DefItemDesc('I0AN', "|cff00ff00Сет Зависти|r", "");
    DefItemDesc('I0D9', "|cff00ff00Сет Зависти v2.0|r", "");
    DefItemDesc('I0N0', "|cff00ff00Спец-костюм|r", "");
    DefItemDesc('I0N1', "|cff00ff00Деталь украденного света|r", "");
    DefItemDesc('I0N2', "|cff00ff00Украденный свет|r", "");
    DefItemDesc('I0HC', "|cff00ff00Полыхалка R-13|r", "");
    DefItemDesc('I0N3', "|cff00ff00Пустота|r", "");
    DefItemDesc('I0N4', "|cff00ff00Розовые Очки|r", "");
    DefItemDesc('I0H7', "|cff00ff00Сонный парализатор|r", "");
    DefItemDesc('I0N5', "|cff00ff00Платиновые Когти|r", "");
    DefItemDesc('I0HB', "|cff00ff00Ожерелье Достатка|r", "");
    DefItemDesc('I0CA', "|cff00ff00Порочный мультицвет|r", "");
    DefItemDesc('I0CB', "|cff00ff00Душитель Х-8|r", "");
    DefItemDesc('I0CC', "|cff00ff00Кандалы Зависти|r", "");
    DefItemDesc('I0CE', "|cff00ff00Острейший Рогоклык|r", "");
    DefItemDesc('I0CF', "|cff00ff00Вероломный шлем|r", "");
    DefItemDesc('I0NH', "|cff00ff001- Нестабильный реактор|r", "");
    DefItemDesc('I0NI', "|cff00ff002- Нестабильный реактор|r", "");
    DefItemDesc('I0NG', "|cff00ff00Нестабильный реактор|r", "");
    DefItemDesc('I0HG', "|cff00ff00Непрощающий|r", "");
    DefItemDesc('I0HH', "|cff00ff00Словарь Демонов|r", "");
    DefItemDesc('I0N6', "|cff00ff001-Деталь Доспеха Инквизитора|r", "");
    DefItemDesc('I0N7', "|cff00ff002-Деталь Доспеха Инквизитора|r", "");
    DefItemDesc('I0I9', "|cff00ff00Доспех Инквизитора|r", "");
    DefItemDesc('I0N8', "|cff00ff001-Деталь Духа проклятого Зверя|r", "");
    DefItemDesc('I0N9', "|cff00ff002-Деталь Духа проклятого Зверя|r", "");
    DefItemDesc('I0NA', "|cff00ff003-Деталь Духа проклятого Зверя|r", "");
    DefItemDesc('I0IG', "|cff00ff00Дух проклятого Зверя|r", "");
    DefItemDesc('I0H8', "|cff00ff00Продавец душ|r", "");
    DefItemDesc('I0DI', "|cff00ff00Доспехи Легиона v2.0|r", "");
    DefItemDesc('I0BH', "|cff00ff00Нано-кирка|r", "");
    DefItemDesc('I0HZ', "|cff00ff00Амулет Изгнания|r", "");
    DefItemDesc('I0HV', "|cff00ff00Печать врат|r", "");
    DefItemDesc('I06A', "|cff00ff00Драконья Слеза|r", "");
    DefItemDesc('I06B', "|cff00ff00Драконье Дыхание|r", "");
    DefItemDesc('I06C', "|cff00ff00Драконий Коготь|r", "");
    DefItemDesc('I0NJ', "|cff00ff00Драконий Коготь-2|r", "");
    DefItemDesc('I06D', "|cff00ff00Драконий Характер|r", "");
    DefItemDesc('I06E', "|cff00ff00Драконье Око|r", "");
    DefItemDesc('I06F', "|cff00ff00Драконья Душа|r", "");
    DefItemDesc('I0NK', "|cff00ff00Драконья Душа-2|r", "");
    DefItemDesc('I06G', "|cff00ff00Драконий Крик|r", "");
    DefItemDesc('I06H', "|cff00ff00Драконий Разум|r", "");
    DefItemDesc('I0I0', "|cff00ff00Дракончик|r", "");
    DefItemDesc('I0I1', "|cff00ff00Дракон|r", "");
    DefItemDesc('I0I2', "|cff00ff00Боевой дракон|r", "");
    DefItemDesc('I0I3', "|cff00ff00Яйцо дракона|r", "");
    DefItemDesc('I06I', "|cff00ff00Доспехи Дракона|r", "");
    DefItemDesc('I0NL', "|cff00ff00Драконье одеяние жреца|r", "");
    DefItemDesc('I06J', "|cff00ff00Свет Жизни|r", "");
    DefItemDesc('I0BD', "|cff00ff00Восполнитель|r", "");
    DefItemDesc('I0BF', "|cff00ff00Перчатка Уничтожения|r", "");
    DefItemDesc('I013', "|cff00ff00Сет Хранителя|r", "");
    DefItemDesc('I035', "|cff00ff00Антиграната|r", "");
    DefItemDesc('I0BK', "|cff00ff00Восполнитель Тьмы|r", "");
    DefItemDesc('I0CU', "|cff00ff00Демоническая кирка|r", "");
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
    } else {
        // Для юнитов без шаблона не ломаем дефолтную скорость/ману.
        // Иначе ApplyToUnit выставляет скорость в 0.
        ud.baseStats.moveSpeed = Jass::GetUnitMoveSpeed(u);
        ud.baseStats.mp = Jass::GetUnitMaxMana(u) - 100;
        if (ud.baseStats.mp < 0) {
            ud.baseStats.mp = 0;
        }
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

dictionary CS_StackableItemTypes;
bool CS_StackableItemTypesInitialized = false;
item CS_AutoCollectTargetItem = nil;
int CS_AutoCollectTypeId = 0;
array<int> CS_NosUpgradeLevel(12);

void CS_SetNosUpgradeLevel(player p, int level) {
    if (p == nil) return;
    int pid = Jass::GetPlayerId(p) + 1;
    if (pid < 1 || pid >= int(CS_NosUpgradeLevel.length())) return;
    CS_NosUpgradeLevel[pid] = level;
}

void CS_AddStackableItemType(int itemTypeId) {
    CS_StackableItemTypes["" + itemTypeId] = true;
}

void CS_InitStackableItemTypes() {
    if (CS_StackableItemTypesInitialized) return;

    CS_AddStackableItemType('I0O5');
    CS_AddStackableItemType('I0O6');
    CS_AddStackableItemType('I0O7');
    CS_AddStackableItemType('I0OU');
    CS_AddStackableItemType('I0O4');
    CS_AddStackableItemType('I0OE');
    CS_AddStackableItemType('I0OA');
    CS_AddStackableItemType('I0OT');
    CS_AddStackableItemType('I0Q3');
    CS_AddStackableItemType('I0Q2');
    CS_AddStackableItemType('I0OB');
    CS_AddStackableItemType('I0O0');
    CS_AddStackableItemType('I0O1');
    CS_AddStackableItemType('I0O2');
    CS_AddStackableItemType('I0O3');
    CS_AddStackableItemType('I0NW');
    CS_AddStackableItemType('I0NX');
    CS_AddStackableItemType('I0NY');
    CS_AddStackableItemType('I0NZ');
    CS_AddStackableItemType('I0OD');
    CS_AddStackableItemType('I0OQ');
    CS_AddStackableItemType('I0OR');
    CS_AddStackableItemType('I0OS');
    CS_AddStackableItemType('I0O8');
    CS_AddStackableItemType('I0O9');
    CS_AddStackableItemType('I0KE');
    CS_AddStackableItemType('I0NB');
    CS_AddStackableItemType('I0MQ');
    CS_AddStackableItemType('I0MR');
    CS_AddStackableItemType('I0KB');
    CS_AddStackableItemType('I0CO');
    CS_AddStackableItemType('I02D');
    CS_AddStackableItemType('I0M6');
    CS_AddStackableItemType('I0KF');
    CS_AddStackableItemType('I0MA');
    CS_AddStackableItemType('I0MB');
    CS_AddStackableItemType('I0M7');
    CS_AddStackableItemType('I0CW');
    CS_AddStackableItemType('I0AK');
    CS_AddStackableItemType('I038');
    CS_AddStackableItemType('I09Z');
    CS_AddStackableItemType('I0AB');
    CS_AddStackableItemType('I0AC');
    CS_AddStackableItemType('I0A6');
    CS_AddStackableItemType('I0A5');
    CS_AddStackableItemType('I0A4');
    CS_AddStackableItemType('I0A3');
    CS_AddStackableItemType('I0A2');
    CS_AddStackableItemType('I0A1');
    CS_AddStackableItemType('I0A0');
    CS_AddStackableItemType('I09P');
    CS_AddStackableItemType('I09I');
    CS_AddStackableItemType('I09L');
    CS_AddStackableItemType('I09Q');
    CS_AddStackableItemType('I09M');
    CS_AddStackableItemType('I09K');
    CS_AddStackableItemType('I09O');
    CS_AddStackableItemType('I09W');
    CS_AddStackableItemType('I09X');
    CS_AddStackableItemType('I09S');
    CS_AddStackableItemType('I09R');
    CS_AddStackableItemType('I09V');
    CS_AddStackableItemType('I09Y');
    CS_AddStackableItemType('I061');
    CS_AddStackableItemType('I062');
    CS_AddStackableItemType('I001');
    CS_AddStackableItemType('I000');
    CS_AddStackableItemType('I002');
    CS_AddStackableItemType('I003');
    CS_AddStackableItemType('I00W');
    CS_AddStackableItemType('I00V');
    CS_AddStackableItemType('I00U');
    CS_AddStackableItemType('I00T');
    CS_AddStackableItemType('I008');
    CS_AddStackableItemType('I007');
    CS_AddStackableItemType('I01T');
    CS_AddStackableItemType('I01U');
    CS_AddStackableItemType('I01V');
    CS_AddStackableItemType('I01W');
    CS_AddStackableItemType('I01X');
    CS_AddStackableItemType('I024');
    CS_AddStackableItemType('I02T');
    CS_AddStackableItemType('I036');
    CS_AddStackableItemType('I037');
    CS_AddStackableItemType('I03I');
    CS_AddStackableItemType('I047');
    CS_AddStackableItemType('I050');
    CS_AddStackableItemType('I04Y');
    CS_AddStackableItemType('I052');
    CS_AddStackableItemType('I04Z');
    CS_AddStackableItemType('I051');
    CS_AddStackableItemType('I04X');
    CS_AddStackableItemType('I066');
    CS_AddStackableItemType('I0CQ');
    CS_AddStackableItemType('I02F');
    CS_AddStackableItemType('I02E');
    CS_AddStackableItemType('I02C');
    CS_AddStackableItemType('I02B');
    CS_AddStackableItemType('I02K');
    CS_AddStackableItemType('I048');
    CS_AddStackableItemType('I123');

    CS_StackableItemTypesInitialized = true;
}

bool CS_IsStackableItemType(int itemTypeId) {
    CS_InitStackableItemTypes();
    return CS_StackableItemTypes.exists("" + itemTypeId);
}

bool CS_IsUnitNos(unit u) {
    int typeId = Jass::GetUnitTypeId(u);
    return typeId == 'h02N'
        || typeId == 'h033'
        || typeId == 'h03B'
        || typeId == 'h03H'
        || typeId == 'h03P'
        || typeId == 'h03Q'
        || typeId == 'h047'
        || typeId == 'h04C';
}

bool CS_HasAutoCollectUpgrade(unit u) {
    if (!CS_IsUnitNos(u)) return false;
    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u)) + 1;
    if (pid >= 1 && pid < int(CS_NosUpgradeLevel.length()) && CS_NosUpgradeLevel[pid] >= 2) {
        return true;
    }
    return Jass::GetUnitAbilityLevel(u, 'A114') > 0;
}

item CS_FindSameItemInInventory(unit u, item excluded, int itemTypeId) {
    for (int i = 0; i < 18; i++) {
        item slotItm = Jass::UnitItemInSlot(u, i);
        if (slotItm != nil && slotItm != excluded && Jass::GetItemTypeId(slotItm) == itemTypeId) {
            return slotItm;
        }
    }
    return nil;
}

void CS_EnumNearbyItemsForStack() {
    item enumItem = Jass::GetEnumItem();
    if (enumItem == nil || CS_AutoCollectTargetItem == nil) {
        enumItem = nil;
        return;
    }

    if (enumItem != CS_AutoCollectTargetItem && Jass::GetItemTypeId(enumItem) == CS_AutoCollectTypeId) {
        int totalCharges = Jass::GetItemCharges(CS_AutoCollectTargetItem) + Jass::GetItemCharges(enumItem);
        Jass::SetItemCharges(CS_AutoCollectTargetItem, totalCharges);
        Jass::RemoveItem(enumItem);
    }

    enumItem = nil;
}

void CS_AutoCollectNearbySameItems(unit u, item stackTarget, int itemTypeId) {
    if (u == nil || stackTarget == nil) return;

    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    rect rc = Jass::Rect(x - 325.0, y - 325.0, x + 325.0, y + 325.0);

    CS_AutoCollectTargetItem = stackTarget;
    CS_AutoCollectTypeId = itemTypeId;
    Jass::EnumItemsInRect(rc, nil, @CS_EnumNearbyItemsForStack);

    CS_AutoCollectTargetItem = nil;
    CS_AutoCollectTypeId = 0;
    Jass::RemoveRect(rc);
    rc = nil;
}

void OnItemPickup() {
    unit u = Jass::GetTriggerUnit();
    item itm = Jass::GetManipulatedItem();
    int itemTypeId = Jass::GetItemTypeId(itm);
    UnitData@ ud = GetUnitData(u);

    if (ud is null) { u = nil; itm = nil; return; }

    int slot = FindItemSlot(u, itm);
    if (slot < 0) { u = nil; itm = nil; return; }

    if (CS_IsStackableItemType(itemTypeId)) {
        item existingStack = CS_FindSameItemInInventory(u, itm, itemTypeId);

        if (existingStack != nil) {
            int totalCharges = Jass::GetItemCharges(existingStack) + Jass::GetItemCharges(itm);
            Jass::SetItemCharges(existingStack, totalCharges);
            Jass::RemoveItem(itm);

            if (CS_HasAutoCollectUpgrade(u)) {
                CS_AutoCollectNearbySameItems(u, existingStack, itemTypeId);
            }

            existingStack = nil;
            u = nil;
            itm = nil;
            return;
        }

        if (CS_HasAutoCollectUpgrade(u)) {
            CS_AutoCollectNearbySameItems(u, itm, itemTypeId);
        }

        existingStack = nil;
    }

    ItemStats@ itmStats = RegisterItemInstance(itm, -1, slot);
    if (itmStats is null) { u = nil; itm = nil; return; }

    // --- Личный предмет: если есть владелец и это не наш --- выбросить
    int ownerPid = itmStats.ownerPlayerId;
    if (ownerPid > 0) {
        int myPid = Jass::GetPlayerId(Jass::GetOwningPlayer(u)) + 1;
        if (ownerPid != myPid) {
            // Выбросить чужой предмет
            Jass::UnitRemoveItem(u, itm);
            u = nil; itm = nil;
            return;
        }
    }

    // В UnitData добавляем только предметы с шаблоном статов.
    if (GetItemTemplate(itemTypeId) is null) { u = nil; itm = nil; return; }

    itmStats.slot = slot;
    Jass::ConsolePrint("\nOnItemPickup: unit=" + Jass::GetUnitName(u) + ", item=" + Jass::GetItemName(itm));
    ud.AddItem(itmStats, u); // Recalc внутри, проверки уровня/класса/стака в Recalc
    u = nil;
    itm = nil;
}

// --- Назначить владельца предмету (playerId 1-based, 0 = ничей) ---
void SetItemOwner(item itm, int playerId) {
    RegisterItemInstance(itm, playerId);
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
