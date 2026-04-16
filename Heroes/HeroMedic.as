// ============================================================
//  HeroMedic.as — Медик — герой H002
// ============================================================
// Скиллы: Q(A198) Хим. выстрел, W(A0VI/A001) Газ,
//          E(A0JV) Инъекция, R(A19D) Живая Химия, T(A19L) Концентрация
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Medic {

// ==================== Параметры скиллов ====================

// --- Q (A198) Хим. выстрел ---
float Q_int               = 3.5;      // множитель INT для урона дамми
float Q_dr                = 0.15;     // дебафф DR
float Q_dr_Duration       = 3.5;      // длительность дебаффа

// --- W (A0VI/A001) Газ ---
float W_int               = 0.7;      // множитель INT для урона облака

// --- E (A0JV) Инъекция ---
float E_time              = 6.0;      // длительность эффекта
float E_dmg_int           = 3.35;     // множитель INT для урона
float E_Heal_int          = 1.25;     // множитель INT для лечения
float E_Hp_Regen_int      = 0.35;     // множитель INT для HP реген (2 ур.)
float E_Stun              = 2.0;      // стан при взрыве (3 ур.)

// --- R (A19D) Живая химия ---
float R_str               = 1.0;      // множитель STR
float R_int               = 1.0;      // множитель INT
int   R_Range             = 600;      // радиус призыва
int   R_BuffRange         = 450;      // радиус ауры
int   R_MS                = 35;       // бонус MS
float R_HPRegenProc       = 0.3;      // % HP regen для союзников (2 ур.)
float R_MainStat          = 0.1;      // бонус основного стата (3 ур.)

// --- T (A19L) Концентрация ---
float T_Procent           = 0.03;     // бонус главного стата в %
float T_int               = 1.05;     // множитель INT
float T_dr                = 0.2;      // бонус DR

const int MED_SAVE_MARK_KEY = 'A0SZ'; // target/hero marker for T3 save
const int MED_SAVE_HERO_KEY = 'A19K'; // target -> medic hero link

const string FX_CHEMSHOT_IMPACT  = "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl";
const string FX_CLOUD_SPAWN      = "Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl";
const string FX_CLOUD_TICK       = "Abilities\\Spells\\Undead\\RegenerationAura\\ObsidianRegenAura.mdl";
const string FX_INJECTION_ALLY   = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl";
const string FX_INJECTION_ENEMY  = "Abilities\\Spells\\Undead\\DiseaseCloud\\DiseaseCloudTarget.mdl";
const string FX_LINK_HEAL        = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl";
const string FX_CONCENTRATE_CAST = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl";
const string FX_CONCENTRATE_TICK = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl";

bool IsMedicHero(unit u) {
    if (u == nil) return false;
    int id = Jass::GetUnitTypeId(u);
    return id == 'H002' || id == 'H102';
}

bool MedicHasItem(unit u, int itemTypeId) {
    if (u == nil) return false;
    int invSize = Jass::UnitInventorySize(u);
    for (int i = 0; i < invSize; i++) {
        item it = Jass::UnitItemInSlot(u, i);
        if (it != nil && Jass::GetItemTypeId(it) == itemTypeId) {
            it = nil;
            return true;
        }
        it = nil;
    }
    return false;
}

void MedicHealUnit(unit healer, unit target, float amount) {
    if (target == nil || amount <= 0 || HIsUnitDead(target)) return;
    float hp = Jass::GetUnitState(target, Jass::UNIT_STATE_LIFE);
    float maxHp = Jass::GetUnitMaxLife(target);
    Jass::SetUnitState(target, Jass::UNIT_STATE_LIFE, HMinReal(hp + amount, maxHp));
}

void MedicAddMainStatPctBuff(unit target, int buffId, float pct, float duration) {
    UnitData@ ud = GetUnitData(target);
    if (ud is null) return;

    UnitStatsData s;
    s.Reset();

    int mainStatType = Jass::R2I(ud.baseStats.mainStat);
    if (mainStatType == 0) {
        s.strengthPct = pct;
    } else if (mainStatType == 1) {
        s.agilityPct = pct;
    } else {
        s.intelligencePct = pct;
    }
    HAddBuff_Custom(target, buffId, s, duration, true);
}

// ==================== Q (A198) — Хим. выстрел ====================

void Q_PuddleTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit puddle = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    float heal = Jass::LoadReal(SkillHT, th, 2);
    int ticks = Jass::LoadInteger(SkillHT, th, 3);

    if (puddle == nil || hero == nil || HIsUnitDead(puddle) || HIsUnitDead(hero) || ticks <= 0) {
        if (puddle != nil && !HIsUnitDead(puddle)) {
            Jass::KillUnit(puddle);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    bool triggered = false;
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(puddle), Jass::GetUnitY(puddle), 150.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2)
            && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_ANCIENT)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MECHANICAL)) {
            MedicHealUnit(hero, u2, heal);
            triggered = true;
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    if (triggered) {
        if (!HIsUnitDead(puddle)) {
            Jass::KillUnit(puddle);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    Jass::SaveInteger(SkillHT, th, 3, ticks - 1);
}

void Q_CreatePuddle(unit hero, float x, float y, float healAmount) {
    unit puddle = Jass::CreateUnit(Jass::GetOwningPlayer(hero), 'h044', x, y, 0.0);
    Jass::UnitApplyTimedLife(puddle, 'BFig', 5.0);

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, puddle);
    Jass::SaveUnitHandle(SkillHT, th, 1, hero);
    Jass::SaveReal(SkillHT, th, 2, healAmount);
    Jass::SaveInteger(SkillHT, th, 3, 20);
    Jass::TimerStart(t, 0.25, true, @Q_PuddleTick);
}

void Q_Impact(unit hero, float x, float y, int abilvl, bool fromPointCast) {
    if (hero == nil || HIsUnitDead(hero)) return;

    float heroInt = float(Jass::GetHeroInt(hero, true));
    float heal = 200.0 + heroInt * Q_int;
    float dmg = heroInt * Q_int;
    float range = 200.0;
    if (MedicHasItem(hero, 'I0BG')) {
        range += 50.0;
    }

    Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CHEMSHOT_IMPACT, x, y));

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, range, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2)) {
            if (Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_ANCIENT)
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MECHANICAL)) {
                MedicHealUnit(hero, u2, heal);
                if (abilvl >= 2) {
                    HAddBuff_DR(u2, 'A198', Q_dr, Q_dr_Duration);
                }
            } else if (Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(hero))
                       && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)) {
                HDealSpellDmg(hero, u2, dmg);
                Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
                    "Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl", u2, "chest"));
            }
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    if (abilvl >= 3 && fromPointCast) {
        Q_CreatePuddle(hero, x, y, heal);
    }
}

void Q_ImpactTimer() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit target = Jass::LoadUnitHandle(SkillHT, th, 1);
    float x = Jass::LoadReal(SkillHT, th, 2);
    float y = Jass::LoadReal(SkillHT, th, 3);
    int abilvl = Jass::LoadInteger(SkillHT, th, 4);
    bool fromPointCast = Jass::LoadInteger(SkillHT, th, 5) == 1;

    if (target != nil && !HIsUnitDead(target)) {
        x = Jass::GetUnitX(target);
        y = Jass::GetUnitY(target);
    }
    Q_Impact(hero, x, y, abilvl, fromPointCast);

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    Debug("Medic::Q_Cast", "abilvl=" + Jass::I2S(abilvl) + ", target=" + ((target != nil) ? Jass::GetUnitName(target) : "point"));
    // Дамми с атакой (h03J)
    Jass::SetUnitAnimation(u, "spell");
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h03J', Jass::GetUnitX(u), Jass::GetUnitY(u), 0.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);

    float tx = (target != nil) ? Jass::GetUnitX(target) : targX;
    float ty = (target != nil) ? Jass::GetUnitY(target) : targY;
    float dist = Jass::MathDistanceBetweenPoints(Jass::GetUnitX(u), Jass::GetUnitY(u), tx, ty);
    float delay = HMinReal(0.45, 0.10 + dist / 1500.0);

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveUnitHandle(SkillHT, th, 1, target);
    Jass::SaveReal(SkillHT, th, 2, targX);
    Jass::SaveReal(SkillHT, th, 3, targY);
    Jass::SaveInteger(SkillHT, th, 4, abilvl);
    Jass::SaveInteger(SkillHT, th, 5, (target == nil) ? 1 : 0);
    Jass::TimerStart(t, delay, false, @Q_ImpactTimer);

    if (target != nil) {
        Jass::IssueTargetOrder(dummy, "attack", target);
    } else {
        IssuePointOrderEx1(dummy, "attack", targX, targY, Jass::Player(0), 2.0, 2.0);
    }
}

// ==================== W (A0VI/A001) — Газ ====================

float W_GetCloudRange(int abilvl) {
    if (abilvl >= 3) return 450.0;
    if (abilvl == 2) return 375.0;
    return 300.0;
}

unit W_GetCloud(unit hero) {
    unit cloud = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(hero), 'h031');
    if (cloud != nil && !HIsUnitDead(cloud)) {
        return cloud;
    }

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(hero), Jass::GetUnitY(hero), 2000.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::GetUnitTypeId(u2) == 'h031'
            && Jass::GetOwningPlayer(u2) == Jass::GetOwningPlayer(hero)
            && !HIsUnitDead(u2)) {
            cloud = u2;
            break;
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    if (cloud != nil) {
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(hero), 'h031', cloud);
    }
    return cloud;
}

void W_CloudTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit cloud = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    float remaining = Jass::LoadReal(SkillHT, th, 2);
    float flatBonus = Jass::LoadReal(SkillHT, th, 3);

    if (cloud == nil || hero == nil || HIsUnitDead(cloud) || HIsUnitDead(hero) || remaining <= 0.0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A0VI');
    float range = W_GetCloudRange(abilvl);
    float heal = float(Jass::GetHeroInt(hero, true)) * W_int + 20.0 + flatBonus;

    Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CLOUD_TICK, Jass::GetUnitX(cloud), Jass::GetUnitY(cloud)));

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(cloud), Jass::GetUnitY(cloud), range, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2)
            && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_ANCIENT)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MECHANICAL)) {
            MedicHealUnit(hero, u2, heal);
            if (abilvl >= 3 && !IsMedicHero(u2)) {
                HGiveMana(u2, 1.0);
            }
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    remaining -= 1.0;
    Jass::SaveReal(SkillHT, th, 2, remaining);
    if (remaining <= 0.0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
    }
}

void W_OnCloudSpawn(unit cloud) {
    if (cloud == nil || Jass::GetUnitTypeId(cloud) != 'h031') return;
    Debug("Medic::W_OnCloudSpawn", "cloud spawned");

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(cloud));
    if (pid < 0 || pid >= 10) return;

    unit hero = GoblinUnit[pid];
    if (hero == nil || HIsUnitDead(hero) || Jass::GetUnitAbilityLevel(hero, 'A0VI') <= 0) return;

    Jass::SetUnitAnimation(cloud, "birth");
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_CLOUD_SPAWN, cloud, "origin"));

    float scale = 1.8;
    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A0VI');
    if (abilvl == 2) {
        scale *= 1.25;
    } else if (abilvl >= 3) {
        scale *= 1.5;
    }
    Jass::SetUnitScale(cloud, scale, scale, scale);

    float duration = 10.1;
    float flatBonus = 0.0;
    if (MedicHasItem(hero, 'I0BM')) {
        flatBonus += 150.0;
        duration += 3.0;
    }
    if (MedicHasItem(hero, 'I08O')) {
        flatBonus += 180.0;
        duration += 3.0;
    }

    Jass::UnitApplyTimedLife(cloud, 'BFig', duration);
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(hero), 'h031', cloud);

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, cloud);
    Jass::SaveUnitHandle(SkillHT, th, 1, hero);
    Jass::SaveReal(SkillHT, th, 2, duration);
    Jass::SaveReal(SkillHT, th, 3, flatBonus);
    Jass::TimerStart(t, 1.0, true, @W_CloudTick);
}

void W_End() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    Jass::UnitRemoveAbility(u, 'A001');
    ability w = Jass::GetUnitAbility(u, 'A0VI');
    if (w != nil) {
        Jass::EnableAbility(w, true, true);
    }
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void W_Start() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    // Переключить на A001
    Jass::UnitAddAbility(u, 'A001');
    ability w = Jass::GetUnitAbility(u, 'A0VI');
    if (w != nil) {
        Jass::DisableAbility(w, true, true);
    }
    Jass::TimerStart(t, 10.0, false, @W_End);
}

void W1_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    Debug("Medic::W1_Cast", "abilvl=" + Jass::I2S(abilvl));
    // 3 ур.: задержка → переключение способности
    if (abilvl == 3) {
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::TimerStart(t, 0.1, false, @W_Start);
    }
}

void W2_StopActiveMove(unit cloud) {
    if (cloud == nil) return;

    int ch = Jass::GetHandleId(cloud);
    timer active = Jass::LoadTimerHandle(SkillHT, ch, 'A001');
    if (active == nil) return;

    int ath = Jass::GetHandleId(active);
    group hit = Jass::LoadGroupHandle(SkillHT, ath, 2);
    if (hit != nil) {
        Jass::DestroyGroup(hit);
    }

    Jass::FlushChildHashtable(SkillHT, ath);
    Jass::DestroyTimer(active);
    Jass::RemoveSavedHandle(SkillHT, ch, 'A001');
}

void W2_MoveTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);

    unit cloud = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    group hit = Jass::LoadGroupHandle(SkillHT, th, 2);
    float startX = Jass::LoadReal(SkillHT, th, 3);
    float startY = Jass::LoadReal(SkillHT, th, 4);
    float targetX = Jass::LoadReal(SkillHT, th, 5);
    float targetY = Jass::LoadReal(SkillHT, th, 6);
    float elapsed = Jass::LoadReal(SkillHT, th, 7);
    float duration = Jass::LoadReal(SkillHT, th, 8);
    float moveDmg = Jass::LoadReal(SkillHT, th, 9);
    float moveHeal = Jass::LoadReal(SkillHT, th, 10);

    if (cloud == nil || hero == nil || HIsUnitDead(cloud) || HIsUnitDead(hero)) {
        if (cloud != nil) {
            Jass::RemoveSavedHandle(SkillHT, Jass::GetHandleId(cloud), 'A001');
        }
        if (hit != nil) {
            Jass::DestroyGroup(hit);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    elapsed += 0.03;
    float progress = elapsed / duration;
    if (progress > 1.0) {
        progress = 1.0;
    }
    float eased = 1.0 - (1.0 - progress) * (1.0 - progress);
    float nx = startX + (targetX - startX) * eased;
    float ny = startY + (targetY - startY) * eased;

    Jass::SetUnitX(cloud, nx);
    Jass::SetUnitY(cloud, ny);

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, nx, ny, 300.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && !Jass::IsUnitInGroup(u2, hit)) {
            Jass::GroupAddUnit(hit, u2);
            if (Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_ANCIENT)
                && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MECHANICAL)) {
                MedicHealUnit(hero, u2, moveHeal);
                Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_CONCENTRATE_TICK, u2, "origin"));
            } else if (Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(hero))
                       && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)) {
                HDealSpellDmg(hero, u2, moveDmg);
                Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
                    "Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl", u2, "origin"));
            }
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    if (progress >= 1.0) {
        Jass::RemoveSavedHandle(SkillHT, Jass::GetHandleId(cloud), 'A001');
        if (hit != nil) {
            Jass::DestroyGroup(hit);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    Jass::SaveReal(SkillHT, th, 7, elapsed);
}

void W2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    Debug("Medic::W2_Cast", "move cloud to x=" + Jass::R2SW(targX, 0, 1) + ", y=" + Jass::R2SW(targY, 0, 1));
    unit cloud = W_GetCloud(u);
    if (cloud == nil || HIsUnitDead(cloud)) return;

    float x = Jass::GetUnitX(cloud);
    float y = Jass::GetUnitY(cloud);
    float dist = Jass::MathDistanceBetweenPoints(x, y, targX, targY);

    W2_StopActiveMove(cloud);

    if (dist < 25.0) {
        Jass::SetUnitPosition(cloud, targX, targY);
        return;
    }

    float moveDmg = float(Jass::GetHeroInt(u, true)) * 3.0;
    float moveHeal = Jass::GetUnitMaxLife(u) * 0.03;

    Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CLOUD_SPAWN, x, y));
    Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CLOUD_SPAWN, targX, targY));

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    group hit = Jass::CreateGroup();

    Jass::SaveUnitHandle(SkillHT, th, 0, cloud);
    Jass::SaveUnitHandle(SkillHT, th, 1, u);
    Jass::SaveGroupHandle(SkillHT, th, 2, hit);
    Jass::SaveReal(SkillHT, th, 3, x);
    Jass::SaveReal(SkillHT, th, 4, y);
    Jass::SaveReal(SkillHT, th, 5, targX);
    Jass::SaveReal(SkillHT, th, 6, targY);
    Jass::SaveReal(SkillHT, th, 7, 0.0);
    Jass::SaveReal(SkillHT, th, 8, 0.85);
    Jass::SaveReal(SkillHT, th, 9, moveDmg);
    Jass::SaveReal(SkillHT, th, 10, moveHeal);

    Jass::SaveTimerHandle(SkillHT, Jass::GetHandleId(cloud), 'A001', t);
    Jass::TimerStart(t, 0.03, true, @W2_MoveTick);
}

// ==================== E (A0JV) — Инъекция ====================
void E_AllyTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit caster = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit target = Jass::LoadUnitHandle(SkillHT, th, 1);
    float heal = Jass::LoadReal(SkillHT, th, 2);
    float remaining = Jass::LoadReal(SkillHT, th, 3);
    bool doClean = Jass::LoadInteger(SkillHT, th, 4) == 1;

    if (caster == nil || target == nil || HIsUnitDead(caster) || HIsUnitDead(target) || remaining <= 0.0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    MedicHealUnit(caster, target, heal);
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_INJECTION_ALLY, target, "origin"));
    if (doClean) {
        UnitData@ ud = GetUnitData(target);
        if (ud !is null) {
            ud.Purge(PURGE_NORMAL, false, target);
        }
    }

    remaining -= 1.0;
    Jass::SaveReal(SkillHT, th, 3, remaining);
    if (remaining <= 0.0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
    }
}

void E_EnemyTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit caster = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit tgt = Jass::LoadUnitHandle(SkillHT, th, 1);
    float dmg = Jass::LoadReal(SkillHT, th, 2);
    float remaining = Jass::LoadReal(SkillHT, th, 3);
    int abilvl = Jass::LoadInteger(SkillHT, th, 4);

    if (caster == nil || tgt == nil || HIsUnitDead(tgt) || HIsUnitDead(caster) || remaining <= 0.0) {
        if (tgt != nil) {
            Jass::RemoveSavedHandle(SkillHT, Jass::GetHandleId(tgt), 'A0JV');
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    HAOESpellDmg(caster, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 350.0, dmg);
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_INJECTION_ENEMY, tgt, "origin"));

    // 2 ур.: AOE замедление
    if (abilvl >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 350.0, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(caster))) {
                HAddBuff_MS(u2, 'A0JV', 0, -0.25, 1.05);
                HAddBuff_AS(u2, 'A0JV', -0.25, 1.05);
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }

    remaining -= 1.0;
    Jass::SaveReal(SkillHT, th, 3, remaining);
    if (remaining <= 0.0) {
        // 3 ур.: взрыв со станом
        if (abilvl >= 3) {
            Jass::DestroyEffect(Jass::AddSpecialEffect(
                "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl",
                Jass::GetUnitX(tgt), Jass::GetUnitY(tgt)));
            HAOEStun(Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), caster, 500.0, E_Stun);
            HAOESpellDmg(caster, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 500.0, dmg * 4.0);
        }

        Jass::RemoveSavedHandle(SkillHT, Jass::GetHandleId(tgt), 'A0JV');
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
    }
}

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil) return;

    bool isAlly = Jass::IsUnitAlly(target, Jass::GetOwningPlayer(u));
    Debug("Medic::E_Cast", "abilvl=" + Jass::I2S(abilvl) + ", mode=" + (isAlly ? "ally" : "enemy") + ", target=" + Jass::GetUnitName(target));

    Jass::SetUnitAnimation(u, "spell");

    float heroInt = float(Jass::GetHeroInt(u, true));

    // Союзник: периодическое лечение + HP реген + очищение
    if (isAlly) {
        Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_INJECTION_ALLY, target, "origin"));
        timer t = Jass::CreateTimer();
        int th = Jass::GetHandleId(t);
        Jass::SaveUnitHandle(SkillHT, th, 0, u);
        Jass::SaveUnitHandle(SkillHT, th, 1, target);
        Jass::SaveReal(SkillHT, th, 2, heroInt * E_Heal_int);
        Jass::SaveReal(SkillHT, th, 3, E_time);
        Jass::SaveInteger(SkillHT, th, 4, (abilvl >= 3) ? 1 : 0);
        Jass::TimerStart(t, 1.0, true, @E_AllyTick);

        // 2 ур.: бонус HP regen
        if (abilvl >= 2) {
            HAddBuff_HPRegen(target, 'A0JV', heroInt * E_Hp_Regen_int, 0, E_time);
        }
        return;
    }

    // Враг: периодический урон + дебаффы + взрыв
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_INJECTION_ENEMY, target, "origin"));
    float dmg = heroInt * E_dmg_int;

    timer t = Jass::LoadTimerHandle(SkillHT, Jass::GetHandleId(target), 'A0JV');
    if (t == nil) {
        t = Jass::CreateTimer();
        Jass::SaveTimerHandle(SkillHT, Jass::GetHandleId(target), 'A0JV', t);
    }
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveUnitHandle(SkillHT, th, 1, target);
    Jass::SaveReal(SkillHT, th, 2, dmg);
    Jass::SaveReal(SkillHT, th, 3, E_time);
    Jass::SaveInteger(SkillHT, th, 4, abilvl);
    Jass::TimerStart(t, 1.0, true, @E_EnemyTick);
}

// ==================== R (A19D) — Живая химия ====================

void R_LinkTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit companion = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);

    if (companion == nil || hero == nil || HIsUnitDead(companion) || HIsUnitDead(hero)) {
        if (companion != nil) {
            int ch = Jass::GetHandleId(companion);
            Jass::RemoveSavedHandle(SkillHT, ch, 'A0MA');
            Jass::RemoveSavedHandle(SkillHT, ch, 'A0MB');
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    int ch = Jass::GetHandleId(companion);
    unit target = Jass::LoadUnitHandle(SkillHT, ch, 'A0MA');
    if (target == nil || HIsUnitDead(target)) {
        Jass::RemoveSavedHandle(SkillHT, ch, 'A0MA');
        Jass::RemoveSavedHandle(SkillHT, ch, 'A0MB');
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    float dist = Jass::MathDistanceBetweenPoints(
        Jass::GetUnitX(companion), Jass::GetUnitY(companion),
        Jass::GetUnitX(target), Jass::GetUnitY(target));
    if (dist >= float(R_Range) + 25.0) {
        Jass::RemoveSavedHandle(SkillHT, ch, 'A0MA');
        Jass::RemoveSavedHandle(SkillHT, ch, 'A0MB');
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    if (Jass::GetUnitCurrentMana(hero) >= 1.0) {
        float heal = float(Jass::GetHeroStr(hero, true)) * R_str + float(Jass::GetHeroInt(hero, true)) * R_int;
        MedicHealUnit(hero, target, heal);
        Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_LINK_HEAL, companion, "origin"));
        Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_LINK_HEAL, target, "origin"));
        Jass::SetUnitCurrentMana(hero, Jass::GetUnitCurrentMana(hero) - 1.0);
    }
}

void A0MA_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil || u == nil) return;
    Debug("Medic::A0MA_Cast", "target=" + Jass::GetUnitName(target));

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if (pid < 0 || pid >= 10) return;
    unit hero = GoblinUnit[pid];
    if (hero == nil || HIsUnitDead(hero)) return;

    float heal = float(Jass::GetHeroStr(hero, true)) * R_str + float(Jass::GetHeroInt(hero, true)) * R_int;
    MedicHealUnit(hero, target, heal);
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_LINK_HEAL, u, "origin"));
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_LINK_HEAL, target, "origin"));

    int uh = Jass::GetHandleId(u);
    Jass::SaveUnitHandle(SkillHT, uh, 'A0MA', target);

    timer t = Jass::LoadTimerHandle(SkillHT, uh, 'A0MB');
    if (t == nil) {
        t = Jass::CreateTimer();
        Jass::SaveTimerHandle(SkillHT, uh, 'A0MB', t);
    }
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveUnitHandle(SkillHT, th, 1, hero);
    Jass::TimerStart(t, 2.0, true, @R_LinkTick);
}

void A011_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil || u == nil) return;
    Debug("Medic::A011_Cast", "target=" + Jass::GetUnitName(target));

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if (pid < 0 || pid >= 10) return;
    unit hero = GoblinUnit[pid];
    if (hero == nil || HIsUnitDead(hero)) return;

    if (Jass::GetUnitCurrentMana(hero) < 5.0) return;

    UnitData@ ud = GetUnitData(target);
    if (ud !is null) {
        ud.Purge(PURGE_NORMAL, false, target);
        Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
            "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", target, "origin"));
    }
    Jass::SetUnitCurrentMana(hero, Jass::GetUnitCurrentMana(hero) - 5.0);
}

void R_AuraTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit companion = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    if (companion == nil || hero == nil) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A19D');

    if (HIsUnitDead(hero)) {
        Jass::KillUnit(companion);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    UnitData@ heroData = GetUnitData(hero);
    if (heroData !is null) {
        HAddBuff_CapAS(companion, 'h07H', heroData.totalStats.attackSpeedPct * 0.75, 1.05);
    }

    // 2 ур.: аура для союзников
    if (abilvl >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(companion), Jass::GetUnitY(companion), float(R_BuffRange), nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))) {
                HAddBuff_HPRegen(u2, 'A19D', 0, R_HPRegenProc, 1.05);
                // 3 ур.: бонус главного стата
                if (abilvl >= 3) {
                    MedicAddMainStatPctBuff(u2, 'A19D', R_MainStat, 1.05);
                }
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }
}

void R_OnElementalSpawn(unit elemental) {
    if (elemental == nil || Jass::GetUnitTypeId(elemental) != 'h07H') return;
    Debug("Medic::R_OnElementalSpawn", "elemental spawned");

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(elemental));
    if (pid < 0 || pid >= 10) return;
    unit hero = GoblinUnit[pid];
    if (hero == nil || Jass::GetUnitAbilityLevel(hero, 'A19D') <= 0) return;

    Jass::SetUnitAnimation(elemental, "birth");
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_CLOUD_SPAWN, elemental, "origin"));
    Jass::UnitAddAbility(elemental, 'A0MA');
    Jass::UnitAddAbility(elemental, 'A011');
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(hero), 'A19D', elemental);
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    Debug("Medic::R_Cast", "abilvl=" + Jass::I2S(abilvl));
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int uh = Jass::GetHandleId(u);

    Jass::SetUnitAnimation(u, "spell");

    // Проверить существующего компаньона
    unit companion = Jass::LoadUnitHandle(SkillHT, uh, 'A19D');
    if (companion == nil || HIsUnitDead(companion)) {
        // Создать нового
        companion = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h07H', x, y, 0.0);
        Jass::SetUnitInvulnerable(companion, true);
        Jass::SetUnitPathing(companion, false);
        Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CLOUD_SPAWN, x, y));
        Jass::SaveUnitHandle(SkillHT, uh, 'A19D', companion);

        // Аура-таймер
        timer t = Jass::CreateTimer();
        int th = Jass::GetHandleId(t);
        Jass::SaveUnitHandle(SkillHT, th, 0, companion);
        Jass::SaveUnitHandle(SkillHT, th, 1, u);
        Jass::TimerStart(t, 1.0, true, @R_AuraTick);
    } else {
        // Переместить существующего
        Jass::SetUnitPosition(companion, x, y);
    }
}

// ==================== T (A19L) — Концентрация ====================

void T_ClearTargetSaveMark() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit target = Jass::LoadUnitHandle(SkillHT, th, 0);
    if (target != nil) {
        int uh = Jass::GetHandleId(target);
        Jass::RemoveSavedInteger(SkillHT, uh, MED_SAVE_MARK_KEY);
        Jass::RemoveSavedHandle(SkillHT, uh, MED_SAVE_HERO_KEY);
        Jass::UnitRemoveAbility(target, MED_SAVE_MARK_KEY);
    }
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void T_ClearHeroSaveCharge() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    if (hero != nil) {
        Jass::RemoveSavedInteger(SkillHT, Jass::GetHandleId(hero), MED_SAVE_MARK_KEY);
    }
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void T_TargetTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit target = Jass::LoadUnitHandle(SkillHT, th, 1);
    int abilvl = Jass::LoadInteger(SkillHT, th, 2);
    float remaining = Jass::LoadReal(SkillHT, th, 3);

    bool invalidUnits = (hero == nil || target == nil || HIsUnitDead(hero) || HIsUnitDead(target));
    if (invalidUnits || remaining <= 0.0) {
        if (invalidUnits && target != nil && abilvl >= 3) {
            int uh = Jass::GetHandleId(target);
            Jass::RemoveSavedInteger(SkillHT, uh, MED_SAVE_MARK_KEY);
            Jass::RemoveSavedHandle(SkillHT, uh, MED_SAVE_HERO_KEY);
            Jass::UnitRemoveAbility(target, MED_SAVE_MARK_KEY);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    float heal = Jass::GetUnitMaxLife(target) * T_Procent + float(Jass::GetHeroInt(hero, true)) * T_int;
    MedicHealUnit(hero, target, heal);
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_CONCENTRATE_TICK, target, "origin"));

    if (abilvl >= 2) {
        HAddBuff_DR(target, 'A19L', T_dr, 1.05);
    }
    if (abilvl >= 3) {
        float ms = IsMedicHero(target) ? 150.0 : 50.0;
        HAddBuff_MS(target, 'B05I', ms, 0, 1.05);
    }

    remaining -= 1.0;
    Jass::SaveReal(SkillHT, th, 3, remaining);
    if (remaining <= 0.0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
    }
}

void T_ApplyToTarget(unit hero, unit target, int abilvl) {
    if (hero == nil || target == nil || HIsUnitDead(target)) return;

    Jass::DestroyEffect(Jass::AddSpecialEffectTarget(FX_CONCENTRATE_TICK, target, "origin"));

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, hero);
    Jass::SaveUnitHandle(SkillHT, th, 1, target);
    Jass::SaveInteger(SkillHT, th, 2, abilvl);
    Jass::SaveReal(SkillHT, th, 3, 8.0);
    Jass::TimerStart(t, 1.0, true, @T_TargetTick);

    if (abilvl >= 3) {
        int uh = Jass::GetHandleId(target);
        Jass::SaveInteger(SkillHT, uh, MED_SAVE_MARK_KEY, 1);
        Jass::SaveUnitHandle(SkillHT, uh, MED_SAVE_HERO_KEY, hero);
        Jass::UnitAddAbility(target, MED_SAVE_MARK_KEY);

        timer clearMark = Jass::CreateTimer();
        int cth = Jass::GetHandleId(clearMark);
        Jass::SaveUnitHandle(SkillHT, cth, 0, target);
        Jass::TimerStart(clearMark, 8.2, false, @T_ClearTargetSaveMark);
    }
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    Debug("Medic::T_Cast", "abilvl=" + Jass::I2S(abilvl));
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    Jass::SetUnitAnimation(u, "spell");
    Jass::DestroyEffect(Jass::AddSpecialEffect(FX_CONCENTRATE_CAST, x, y));

    // AOE периодическое лечение союзников в 1200
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, 1200.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2)
            && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(u))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MECHANICAL)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MAGIC_IMMUNE)) {
            T_ApplyToTarget(u, u2, abilvl);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    if (abilvl >= 3) {
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), MED_SAVE_MARK_KEY, 1);
        timer clearHero = Jass::CreateTimer();
        int th = Jass::GetHandleId(clearHero);
        Jass::SaveUnitHandle(SkillHT, th, 0, u);
        Jass::TimerStart(clearHero, 8.2, false, @T_ClearHeroSaveCharge);
    } else {
        Jass::RemoveSavedInteger(SkillHT, Jass::GetHandleId(u), MED_SAVE_MARK_KEY);
    }
}

string PctText(float value) {
    return Jass::I2S(Jass::R2I(value * 100.0));
}

void InitMedicSkillDesc() {
    // Q
    Jass::SetAbilityBaseStringLevelFieldById('A198', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00При попадании исцеляет союзников и наносит врагам столько же магического урона.\n\n"
        + PctText(Q_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 8 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A198', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00При попадании исцеляет союзников и наносит врагам столько же магического урона. Уменьшает получаемый урон на "
        + PctText(Q_dr) + "% на " + Jass::R2SW(Q_dr_Duration, 0, 1) + " секунд.\n\n"
        + PctText(Q_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 8 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A198', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00При попадании исцеляет союзников и наносит врагам столько же магического урона. Уменьшает получаемый урон на "
        + PctText(Q_dr) + "% на " + Jass::R2SW(Q_dr_Duration, 0, 1)
        + " секунд. Оставляет на полу лужу, если нет цели, одноразово исцеляющую.\n\n"
        + PctText(Q_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 8 секунд.");

    // W
    Jass::SetAbilityBaseStringLevelFieldById('A0VI', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00На 10 секунд создает облако исцеляющего газа, лечащего союзников раз в секунду.\n\n"
        + PctText(W_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0VI', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00На 10 секунд создает облако исцеляющего газа, лечащего союзников раз в секунду. Увеличивает дальность каста и радиус облака газа.\n\n"
        + PctText(W_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0VI', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00На 10 секунд создает облако исцеляющего газа, лечащего союзников и восстанавливает 1 ману раз в секунду. "
        + "(Восстановление не работает медикам) Временно заменяется скилл, с кд 0.45 секунды, который двигает облако газа в точку каста. "
        + "При движении все союзные цели в пути исцеляются, а вражеские получают магический урон, равный 300% от РАЗУМА. "
        + "Увеличивает дальность каста и радиус облака газа.\n\n"
        + PctText(W_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    // E
    Jass::SetAbilityBaseStringLevelFieldById('A0JV', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Заражает указанного юнита вирусом, из-за чего все враги рядом с зараженным получают магический урон каждую секунду "
        + "в течение " + Jass::I2S(Jass::R2I(E_time)) + " секунд. Может заразить гоблина, из-за чего он восстанавливает здоровье каждую секунду.\n\n"
        + "Урон: " + PctText(E_dmg_int) + "% от РАЗУМА\n"
        + "Хилл: " + PctText(E_Heal_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0JV', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Заражает указанного юнита вирусом, из-за чего все враги рядом с зараженным получают магический урон каждую секунду "
        + "в течение " + Jass::I2S(Jass::R2I(E_time)) + " секунд. Уменьшает скорость атаки зараженным врагам. "
        + "Может заразить гоблина, из-за чего он восстанавливает здоровье каждую секунду и дает хп-реген.\n\n"
        + "Урон: " + PctText(E_dmg_int) + "% от РАЗУМА\n"
        + "Хилл: " + PctText(E_Heal_int) + "% от РАЗУМА\n"
        + "Хп-реген: " + PctText(E_Hp_Regen_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0JV', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Заражает указанного юнита вирусом, из-за чего все враги рядом с зараженным получают магический урон каждую секунду "
        + "в течение " + Jass::I2S(Jass::R2I(E_time)) + " секунд. После " + Jass::I2S(Jass::R2I(E_time))
        + " секунд происходит взрыв, наносящий в 4 раза больше основного магического урона и оглушающий на "
        + Jass::R2SW(E_Stun, 0, 1) + " секунды. Уменьшает скорость атаки зараженным врагам. "
        + "Может заразить гоблина, из-за чего он восстанавливает здоровье каждую секунду и дает хп-реген. "
        + "Раз в 0.1 секунды постоянно очищает союзную цель.\n\n"
        + "Урон: " + PctText(E_dmg_int) + "% от РАЗУМА\n"
        + "Хилл: " + PctText(E_Heal_int) + "% от РАЗУМА\n"
        + "Хп-реген: " + PctText(E_Hp_Regen_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 20 секунд.");

    // R
    Jass::SetAbilityBaseStringLevelFieldById('A19D', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Оживляет химического элементаля или призывает к себе.\n"
        + "Целебная Вода - выбирает цель, лечит здоровье раз в 2 секунды. Разрывается, если уйти дальше "
        + Jass::I2S(R_Range) + " радиуса или если поменять цель. Тратит 1 ману Медика за хилл.\n\n"
        + "Хилл: " + PctText(R_str) + "% от СИЛЫ и " + PctText(R_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 5 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A19D', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Оживляет химического элементаля или призывает к себе.\n"
        + "Целебная Вода - выбирает цель, лечит здоровье раз в 2 секунды. Разрывается, если уйти дальше "
        + Jass::I2S(R_Range) + " радиуса или если поменять цель. Тратит 1 ману Медика за хилл.\n"
        + "Аура: увеличение реген-хп " + PctText(R_HPRegenProc) + "%. АоЕ " + Jass::I2S(R_BuffRange) + ".\n\n"
        + "Хилл: " + PctText(R_str) + "% от СИЛЫ и " + PctText(R_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 5 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A19D', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Оживляет химического элементаля или призывает к себе.\n"
        + "Целебная Вода - выбирает цель, лечит здоровье раз в 2 секунды. Разрывается, если уйти дальше "
        + Jass::I2S(R_Range) + " радиуса или если поменять цель. Тратит 1 ману Медика за хилл.\n"
        + "Аура: увеличение реген-хп " + PctText(R_HPRegenProc) + "%. АоЕ " + Jass::I2S(R_BuffRange) + ".\n"
        + "Аура: увеличивает на " + PctText(R_MainStat) + "% основной стат. АоЕ " + Jass::I2S(R_BuffRange) + ".\n\n"
        + "Хилл: " + PctText(R_str) + "% от СИЛЫ и " + PctText(R_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 5 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0MA', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "Выбирает цель, лечит здоровье раз в 2 секунды. Разрывается если уйти дальше "
        + Jass::I2S(R_Range) + " радиуса или если поменять цель. Тратит 1 ману Медика за хилл.");

    Jass::SetAbilityBaseStringLevelFieldById('A011', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "Слабое Очищение. Очищает слабые дебаффы с цели.");

    // T
    Jass::SetAbilityBaseStringLevelFieldById('A19L', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00После небольшой подготовки выпускает в воздух облако концентрированного исцеляющего газа, "
        + "который исцеляет союзников каждую секунду. Эффект длится 8 секунд.\n\n"
        + PctText(T_Procent) + "% + " + PctText(T_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 60 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A19L', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00После небольшой подготовки выпускает в воздух облако концентрированного исцеляющего газа, "
        + "который исцеляет союзников каждую секунду и уменьшает получаемый урон на "
        + PctText(T_dr) + "%. Эффект длится 8 секунд.\n\n"
        + PctText(T_Procent) + "% + " + PctText(T_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 60 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A19L', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00После небольшой подготовки выпускает в воздух облако концентрированного исцеляющего газа, "
        + "который исцеляет союзников каждую секунду, уменьшает получаемый урон на " + PctText(T_dr) + "%. Эффект длится 8 секунд.\n"
        + "Под действием ульты спасает одного союзника от смерти, восстанавливая ему 100% здоровье. "
        + "Также может спасти союзника от смерти, если он находится возле Медика с готовым ультом, но ульта будет использована.\n"
        + "Медик получает 150 скорости бега, а остальные под баффом получают 50 скорости бега.\n"
        + PctText(T_Procent) + "% + " + PctText(T_int) + "% от РАЗУМА\n\n|cff6495edПерезарядка: 60 секунд.");
}

// ==================== Регистрация ====================

void InitMedicSkills() {
    RegisterAbilityCastHandler('A198', @Q_Cast);
    RegisterAbilityCastHandler('A0VI', @W1_Cast);
    RegisterAbilityCastHandler('A001', @W2_Cast);
    RegisterAbilityCastHandler('A0JV', @E_Cast);
    RegisterAbilityCastHandler('A19D', @R_Cast);
    RegisterAbilityCastHandler('A0MA', @A0MA_Cast);
    RegisterAbilityCastHandler('A011', @A011_Cast);
    RegisterAbilityCastHandler('A19L', @T_Cast);

    RegisterOnSpawnHandler('h031', @W_OnCloudSpawn);
    RegisterOnSpawnHandler('h07H', @R_OnElementalSpawn);

    InitMedicSkillDesc();
    Debug("InitMedicSkills", "Medic skills initialized.");
}

} // namespace Medic
