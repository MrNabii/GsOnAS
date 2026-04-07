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

// ==================== Q (A198) — Хим. выстрел ====================

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Дамми с атакой (h03J)
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h03J', Jass::GetUnitX(u), Jass::GetUnitY(u), 0.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
    if (target != nil) {
        Jass::IssueTargetOrder(dummy, "attack", target);
    } else {
        Jass::IssuePointOrder(dummy, "attack", targX, targY);
    }

    // TODO: Дополнительный урон — дамми h03J наносит урон Q_int*GetHeroInt
    // DR дебафф по попадании дамми реализуется через OnHit системы дамми
}

// ==================== W (A0VI/A001) — Газ ====================

void W_End() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    Jass::UnitRemoveAbility(u, 'A001');
    // Вернуть доступность A0VI
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0VI', true);
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void W_Start() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    // Переключить на A001
    Jass::UnitAddAbility(u, 'A001');
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0VI', false);
    Jass::TimerStart(t, 10.0, false, @W_End);
}

void W1_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // 3 ур.: задержка → переключение способности
    if (abilvl == 3) {
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::TimerStart(t, 0.1, false, @W_Start);
    }
}

void W2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Переместить компаньона (h031) к целевой точке
    unit companion = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(u), 'h031');
    if (companion != nil) {
        // Плавное перемещение компаньона
        Jass::SetUnitPosition(companion, targX, targY);
    }
}

// ==================== E (A0JV) — Инъекция ====================

void E_InjectionEnd() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit tgt = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit caster = Jass::LoadUnitHandle(SkillHT, th, 1);
    float endDmg = Jass::LoadReal(SkillHT, th, 2);

    // 3 ур.: взрыв со станом
    if (Jass::GetUnitAbilityLevel(caster, 'A0JV') >= 3) {
        Jass::DestroyEffect(Jass::AddSpecialEffect(
            "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl",
            Jass::GetUnitX(tgt), Jass::GetUnitY(tgt)));
        HAOEStun(Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), caster, 500.0, E_Stun);
        HAOESpellDmg(caster, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 500.0, endDmg);
    }

    // Очистить таймеры
    timer t2 = Jass::LoadTimerHandle(SkillHT, th, 3);
    if (t2 != nil) {
        Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t2));
        Jass::PauseTimer(t2);
        Jass::DestroyTimer(t2);
    }

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void E_PeriodicDmg() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit caster = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit tgt = Jass::LoadUnitHandle(SkillHT, th, 1);
    float dmg = Jass::LoadReal(SkillHT, th, 2);

    if (!HIsUnitDead(tgt)) {
        HAOESpellDmg(caster, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 350.0, dmg);
    }

    // 2 ур.: AOE замедление
    if (Jass::GetUnitAbilityLevel(caster, 'A0JV') >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(tgt), Jass::GetUnitY(tgt), 350.0, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(caster))) {
                HAddBuff_MS(u2, 'A0JV', 0, -0.25, 1.05);
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }
}

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil) return;

    float heroInt = float(Jass::GetHeroInt(u, true));

    // Союзник: лечение + HP реген
    if (Jass::IsUnitAlly(target, Jass::GetOwningPlayer(u))) {
        // Хил
        float heal = heroInt * E_Heal_int;
        Jass::SetUnitState(target, Jass::UNIT_STATE_LIFE,
            HMinReal(Jass::GetUnitState(target, Jass::UNIT_STATE_LIFE) + heal,
                     Jass::GetUnitMaxLife(target)));

        // 2 ур.: бонус HP regen
        if (abilvl >= 2) {
            HAddBuff_HPRegen(target, 'A0JV', heroInt * E_Hp_Regen_int, 0, E_time);
        }
        // 3 ур.: очистить дебаффы
        // TODO: CleanUnit не доступна из AS, используем удаление баффов
        return;
    }

    // Враг: периодический урон
    float dmg = heroInt * E_dmg_int;

    // Создать таймер периодического урона
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveUnitHandle(SkillHT, th, 1, target);
    Jass::SaveReal(SkillHT, th, 2, dmg);
    Jass::TimerStart(t, 1.0, true, @E_PeriodicDmg);

    // Таймер окончания
    timer t2 = Jass::CreateTimer();
    int th2 = Jass::GetHandleId(t2);
    Jass::SaveUnitHandle(SkillHT, th2, 0, target);
    Jass::SaveUnitHandle(SkillHT, th2, 1, u);
    Jass::SaveReal(SkillHT, th2, 2, dmg * 4.0); // урон взрыва (3 ур.)
    Jass::SaveTimerHandle(SkillHT, th2, 3, t); // ссылка на периодический таймер
    Jass::TimerStart(t2, E_time, false, @E_InjectionEnd);
}

// ==================== R (A19D) — Живая химия ====================

void R_AuraTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit companion = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A19D');

    if (HIsUnitDead(hero)) {
        Jass::KillUnit(companion);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
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
                    HAddBuff_Str(u2, 'A19D', 0, R_MainStat, 1.05);
                }
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int uh = Jass::GetHandleId(u);

    // Проверить существующего компаньона
    unit companion = Jass::LoadUnitHandle(SkillHT, uh, 'A19D');
    if (companion == nil || HIsUnitDead(companion)) {
        // Создать нового
        companion = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h07H', x, y, 0.0);
        Jass::SetUnitInvulnerable(companion, true);
        Jass::SetUnitPathing(companion, false);
        Jass::SaveUnitHandle(SkillHT, uh, 'A19D', companion);
        // Сохранить ссылку на companion для W
        Jass::SaveUnitHandle(SkillHT, uh, 'h031', companion);

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

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // Бафф DR
    HAddBuff_DR(u, 'A19L', T_dr, 10.0);

    // AOE бафф союзников в 1200
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, 1200.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(u))
            && Jass::IsUnitType(u2, Jass::UNIT_TYPE_HERO)) {
            // % бонус главного стата
            HAddBuff_Str(u2, 'A19L', 0, T_Procent, 10.0);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// ==================== Регистрация ====================

void InitMedicSkills() {
    RegisterAbilityCastHandler('A198', @Q_Cast);
    RegisterAbilityCastHandler('A0VI', @W1_Cast);
    RegisterAbilityCastHandler('A001', @W2_Cast);
    RegisterAbilityCastHandler('A0JV', @E_Cast);
    RegisterAbilityCastHandler('A19D', @R_Cast);
    RegisterAbilityCastHandler('A19L', @T_Cast);
    Jass::ConsolePrint("Medic skills initialized.");
}

} // namespace Medic
