// ============================================================
//  HeroStalker.as — Сталкер — герой H000
// ============================================================
// Скиллы: Q(A0C9/A0KP) Воронка, W(A0TM) Блинк,
//          E(A0OR) Защита, R(A0TO) Боевой Раж, T(A0TJ) Ультимативная защита
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Stalker {

// ==================== Параметры скиллов ====================

// --- T (A0TJ) Ультимативная защита ---
float T_AD                = 15.0;
float T_Shield_HP         = 2.0;      // множитель макс.ХП для щита
int   T_Duration1         = 12;
int   T_Duration2         = 16;
float T_d_dr              = 0.09;     // дебафф DR врагам
float T_Stun              = 0.8;
float T2_Gain             = 0.3;      // бонус DR союзникам (2 ур.)
float T2_Protect          = 0.25;
float T3_Gain             = 0.45;     // бонус DR союзникам (3 ур.)
float T3_Protect          = 0.45;

// --- R (A0TO) Боевой Раж ---
float R_AD                = 3.0;
float R_dr                = 0.4;
float R_mr                = 0.15;
int   R_Stack             = 2;
int   R_Stack2            = 3;
float R_HP                = 0.3;
int   R_Armor             = 50;
float R_fr                = 0.1;      // бонус PhysAD
float R_fr2               = 0.3;      // бонус PR (2 ур.)
float R_Stun              = 0.33;     // AOE стан (3 ур.)

// --- E (A0OR) Защита ---
float E_AD                = 1.15;
float E_AD2               = 2.5;
float E_cd1               = 1.5;
float E_cd2               = 1.25;
float E_cd3               = 1.0;
float E_dr                = 0.05;
float E_dr2               = 0.07;
float E_HP_Reg            = 0.033;
int   E_MS1               = 25;
int   E_MS2               = 40;
float E_d_AD              = 0.15;
int   E_Stack1            = 1;
int   E_Stack2            = 2;

// --- W (A0TM) Блинк ---
float W_AD                = 1.7;
float W_mr                = 0.04;
float W_Stun              = 0.1;
int   W_Stack1            = 4;
int   W_Stack2            = 6;
float W_Shield            = 0.1;      // % макс.ХП для щита
float W_Duration          = 3.0;
float W_Duration2         = 4.0;
int   W_DebuffStr         = 250;
float W_Debuff            = 6.0;

// --- Q (A0C9/A0KP) Воронка ---
float Q_str               = 4.0;
float Q_fr_dr             = 2.5;
float Q_Shield            = 0.15;
float Q_Stun              = 0.8;

// ==================== Внутренние переменные ====================
array<bool>  UltActive(10);
array<int>   T_Number(10);

// ==================== T (A0TJ) — Ультимативная защита ====================

void T_OnAttack_Callback(unit attacker, unit target) {
    HRemoveOnAttack(attacker, 'A0TJ');
    HDealPhysDmg(attacker, target, T_AD * HGetUnitAD(attacker));
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    float maxHP = Jass::GetUnitMaxLife(u);
    int dur = (abilvl >= 3) ? T_Duration2 : T_Duration1;

    // Щит (все уровни)
    // В JASS: Apply_Shield(u, 'A0TJ', maxHP * T_Shield_HP, 'B01R', dur)
    // Упрощённо: используем бафф с HP бонусом
    HAddBuff_HP(u, 'B01R', maxHP * T_Shield_HP, 0, float(dur));

    if (abilvl >= 2) {
        // AOE стан
        HAOEStun(Jass::GetUnitX(u), Jass::GetUnitY(u), u, 300.0, T_Stun);

        // Дебафф DR врагов
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), 300.0, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
                HAddBuff_DR(u2, 'A0TJ', -T_d_dr, float(dur));
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);

        // Бафф союзникам
        float gain = (abilvl >= 3) ? T3_Gain : T2_Gain;
        group g2 = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g2, Jass::GetUnitX(u), Jass::GetUnitY(u), 750.0, nil);
        unit u3 = Jass::FirstOfGroup(g2);
        while (u3 != nil) {
            Jass::GroupRemoveUnit(g2, u3);
            if (Jass::IsUnitAlive(u3) && Jass::IsUnitAlly(u3, Jass::GetOwningPlayer(u)) && u3 != u) {
                HAddBuff_DR(u3, 'B08X', gain, float(dur));
            }
            u3 = Jass::FirstOfGroup(g2);
        }
        Jass::DestroyGroup(g2);
    }

    T_Number[pn] = 6;
    HSetAbilityCharges(u, 'A0TJ', T_Number[pn]);
    UltActive[pn] = true;
}

// ==================== R (A0TO) — Боевой Раж ====================

void R_OnAttack_Callback(unit attacker, unit target) {
    HAOESpellDmg(attacker, Jass::GetUnitX(target), Jass::GetUnitY(target), 225.0,
        R_AD * HGetUnitAD(attacker));
}

void R_OnDamage_Callback(unit source, unit target) {
    // target = герой со скиллом
    int charges = HGetAbilityCharges(target, 'A0TO');
    if (charges <= 0) {
        HRemoveOnDamage(target, 'A0TO');
        int abilvl = Jass::GetUnitAbilityLevel(target, 'A0TO');
        if (abilvl >= 2) {
            HAddBuff_PR(target, 'A0TO', R_fr2, 3.5);
        }
        if (abilvl >= 3) {
            HAOEStun(Jass::GetUnitX(target), Jass::GetUnitY(target), target, 250.0, R_Stun);
        }
        return;
    }
    HSetAbilityCharges(target, 'A0TO', charges - 1);
}

void R_End() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    HSetAbilityCharges(u, 'A0TO', 0);
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (abilvl >= 3) {
        HSetAbilityCharges(u, 'A0TO', R_Stack2);
        HAddBuff_MR(u, 'A0TO', R_mr, 10.0);
    } else {
        HSetAbilityCharges(u, 'A0TO', R_Stack);
    }

    timer t = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::TimerStart(t, 7.5, false, @R_End);

    HRegisterOnDamage(u, 'A0TO', @R_OnDamage_Callback, 7.5);
    HRegisterOnAttack(u, 'A0TO', @R_OnAttack_Callback, 7.5);
    HAddBuff_PhysAD(u, 'A0TO', R_fr, 7.5);
    HAddBuff_DR(u, 'A0TO', R_dr, 10.0);
}

// ==================== E (A0OR) — Защита (телепорт) ====================

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // Телепорт к точке (на 250 впереди от направления)
    float angle = Jass::MathAngleBetweenPoints(x, y, targX, targY);
    float nx = x + 250.0 * Jass::Cos(angle * 0.01745329);
    float ny = y + 250.0 * Jass::Sin(angle * 0.01745329);
    Jass::SetUnitPosition(u, nx, ny);

    // Заряды на 2-3 ур.
    if (abilvl >= 2) {
        int charges = HGetAbilityCharges(u, 'A0OR');
        if (charges > 0) {
            HSetAbilityCharges(u, 'A0OR', charges - 1);
            // Сбросить кулдаун
            Jass::SetAbilityRemainingCooldown(Jass::GetUnitAbility(u, 'A0OR'), 0.01);
        }
    }
}

// ==================== W (A0TM) — Блинк ====================

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    float maxHP = Jass::GetUnitMaxLife(u);

    // Баффы блинка (2 ур.)
    if (abilvl >= 2) {
        if (HGetAbilityCharges(u, 'A0TM') == 1) {
            HSetAbilityCharges(u, 'A0TM', 0);
            // Дебафф MR врагам
            group g = Jass::CreateGroup();
            Jass::GroupEnumUnitsInRange(g, x, y, 250.0, nil);
            int hitCount = 0;
            unit u2 = Jass::FirstOfGroup(g);
            while (u2 != nil) {
                Jass::GroupRemoveUnit(g, u2);
                if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
                    float mrDebuff = -0.01 * (W_Debuff + float(Jass::GetHeroStr(u, true)) / float(W_DebuffStr));
                    HAddBuff_MR(u2, 'B08Y', mrDebuff, 8.0);
                    hitCount++;
                }
                u2 = Jass::FirstOfGroup(g);
            }
            Jass::DestroyGroup(g);

            // 3 ур.: снижение КД + мана за хиты
            if (abilvl >= 3) {
                HReduceCooldown(u, 'A0C9', 4.0);
                HReduceCooldown(u, 'A0TO', 4.0);
                HGiveMana(u, float(HMinInt(hitCount, 12)));
            }
        } else {
            HSetAbilityCharges(u, 'A0TM', 1);
        }
    }

    float time = (abilvl >= 2) ? W_Duration2 : W_Duration;

    // Щит
    HAddBuff_HP(u, 'B07D', maxHP * W_Shield, 0, time);

    // AOE стан + дебаффы
    group g2 = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g2, x, y, 250.0, nil);
    unit u3 = Jass::FirstOfGroup(g2);
    while (u3 != nil) {
        Jass::GroupRemoveUnit(g2, u3);
        if (Jass::IsUnitAlive(u3) && Jass::IsUnitEnemy(u3, Jass::GetOwningPlayer(u))) {
            StunUnit(u3, W_Stun);
            HAddBuff_MS(u3, 'A0TM', 0, -0.1, time);
            HAddBuff_AS(u3, 'A0TM', -0.1, time);
        }
        u3 = Jass::FirstOfGroup(g2);
    }
    Jass::DestroyGroup(g2);
}

// ==================== Q (A0C9) — Воронка ====================

void Q1_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Первый каст: A0C9 → переключение на A0KP (вакуум)
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // Урон
    UnitData@ ud = GetUnitData(u);
    float dr = 0;
    float pr = 0;
    if (ud !is null) {
        dr = ud.totalStats.resistPhysical;
        pr = ud.totalStats.resistAll;
    }
    float dmg = float(Jass::GetHeroStr(u, true)) * Q_str * Q_fr_dr * (dr + pr + 1.0);

    // Скрыть A0C9, показать A0KP (через таймер)
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0C9', false);

    // Таймер для возврата к A0C9
    timer t = Jass::CreateTimer();
    Jass::SaveTimerHandle(SkillHT, 'A0KP', 'A0C9', t);
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::TimerStart(t, 3.0, false, function() {
        timer tmr = Jass::GetExpiredTimer();
        unit uu = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(tmr), 0);
        Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(uu), 'A0C9', true);
        Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(tmr));
        Jass::DestroyTimer(tmr);
    });

    // Щит на 3 ур.
    if (abilvl >= 3) {
        HAddBuff_HP(u, 'A0C9', Jass::GetUnitMaxLife(u) * Q_Shield, 0, 7.0);
    }

    // AOE магический урон
    HAOESpellDmg(u, x, y, 375.0, dmg);
    // AOE стан
    HAOEStun(x, y, u, 375.0, Q_Stun);
}

void Q2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Второй каст: A0KP → притягивание врагов
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // Убрать A0KP, вернуть A0C9
    timer oldT = Jass::LoadTimerHandle(SkillHT, 'A0KP', 'A0C9');
    if (oldT != nil) {
        Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(oldT));
        Jass::DestroyTimer(oldT);
    }
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0C9', true);

    // Притягивание врагов в радиусе 2000
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, targX, targY, 2000.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MAGIC_IMMUNE)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)) {
            if (abilvl >= 2) StunUnit(u2, 2.0);
            if (abilvl >= 3) {
                UnitData@ ud = GetUnitData(u);
                float dr = 0; float pr = 0;
                if (ud !is null) { dr = ud.totalStats.resistPhysical; pr = ud.totalStats.resistAll; }
                float dmg = float(Jass::GetHeroStr(u, true)) * Q_str * Q_fr_dr * (dr + pr + 1.0);
                HDealSpellDmg(u, u2, dmg);
            }
            Jass::SetUnitPosition(u2, x, y);
            Jass::IssueTargetOrder(u2, "attack", u);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// ==================== Регистрация ====================

void InitStalkerSkills() {
    RegisterAbilityCastHandler('A0TJ', @T_Cast);
    RegisterAbilityCastHandler('A0TO', @R_Cast);
    RegisterAbilityCastHandler('A0OR', @E_Cast);
    RegisterAbilityCastHandler('A0TM', @W_Cast);
    RegisterAbilityCastHandler('A0C9', @Q1_Cast);
    RegisterAbilityCastHandler('A0KP', @Q2_Cast);
    Debug("InitStalkerSkills", "Stalker skills initialized.");
}

} // namespace Stalker
