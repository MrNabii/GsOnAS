// ============================================================
//  HeroPodr.as — Подрывник (Saboteur) — герой H006
// ============================================================
// Скиллы: Q(A19W) Самоподрыв, W(A0Q5) Телепортация-взрыв,
//          E(A1A2) Прыжок в лагерь, R(A19P) Динамит, T(A0KI) Ядерная бомба
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Podr {

// ==================== Параметры скиллов ====================

// --- Q (A19W) Самоподрыв ---
float Q_int               = 40.0;     // множитель INT для урона
int   Q_Range             = 375;      // радиус взрыва
int   Q_Stack             = 4;        // макс стаков (2 ур.)
float Q_MD                = 0.04;     // бонус MagicAD за стак
float Q_Duration          = 6.0;      // длительность стаков
float Q_UpDuration        = 3.0;      // длительность бонуса при полных стаках
float Q_UpMD              = 0.15;     // доп. MagicAD при макс стаках (3 ур.)

// --- W (A0Q5) Телепортация-взрыв ---
float W_int               = 4.0;      // множитель INT для урона
float W_CastTime1         = 0.2;      // время каста (1 ур.)
float W_CastTime2         = 0.1;      // время каста (2 ур.)
float W_CastTime3         = 0.01;     // время каста (3 ур.)
int   W_CastDistance1     = 500;      // дистанция (1 ур.)
int   W_CastDistance2     = 650;      // дистанция (2 ур.)
int   W_CastDistance3     = 800;      // дистанция (3 ур.)
float W_invul             = 0.8;      // длит. неуязвимости
float W_Stun1             = 0.3;      // стан (запас)
float W_Stun2             = 0.85;     // стан (3 ур.)
float W_MD                = 0.12;     // бонус MagicAD (3 ур.)

// --- E (A1A2) Прыжок ---
float E_int1              = 2.25;     // множитель INT для урона (1 ур.)
float E_int2              = 4.5;      // множитель INT для урона (2 ур.)
float E_int3              = 9.0;      // множитель INT для урона (3 ур.)
int   E_Stack             = 5;        // стаков для активации
float E_Duration          = 6.0;      // длительность стака
float E_MP_Res            = 0.45;     // восстановление маны (%)

// --- R (A19P) Динамит ---
float R_int               = 11.0;     // множитель INT для урона шашки
float R_time              = 10.0;     // время перезарядки шашки
int   R_Stack             = 3;        // макс шашек
float R_Q                 = 10.0;     // снижение КД Q при 3 стаках (2 ур.)
float R_d_pr              = 0.05;     // дебафф MR
int   R_d_ThenInt         = 400;      // скейлинг MR от INT
float R_d_pr_Duration     = 5.0;      // длительность MR дебаффа

// --- T (A0KI) Ядерная бомба ---
float T_int               = 90.0;     // множитель INT для урона
float T_time              = 2.0;      // задержка взрыва
int   T_MaxRange1         = 800;      // радиус (1-2 ур.)
int   T_MaxRange2         = 1600;     // радиус (3 ур.)
float T_d_MS_Duration1    = 1.5;      // длит. замедления (2 ур.)
float T_d_mr_Duration1    = 4.5;      // длит. MR дебаффа (2 ур.)
float T_d_mr1             = 0.07;     // MR дебафф (2 ур.)
int   T_d_mr1_Then        = 300;      // скейлинг MR от INT (2 ур.)
float T_d_MS_Duration2    = 3.0;      // длит. замедления (3 ур.)
float T_d_mr_Duration2    = 6.0;      // длит. MR дебаффа (3 ур.)
float T_d_mr2             = 0.0931;   // MR дебафф (3 ур.) ≈ T_d_mr1*1.33
int   T_d_mr2_Then        = 200;      // скейлинг MR от INT (3 ур.)
float T_Stun              = 1.0;      // стан (3 ур.)
int   R_TimerParent       = 'PDRT';

// ==================== Общая логика: вызывается при каждом скилле ====================

void AllPodrSkills(unit u) {
    // E>=2: добавить стак E
    if (Jass::GetUnitAbilityLevel(u, 'A1A2') >= 2) {
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::TimerStart(t, E_Duration, false, @E_StackEnd);
        HSetAbilityCharges(u, 'A1A2', HGetAbilityCharges(u, 'A1A2') + 1);
    }

    // Q>=2: добавить стак Q + MagicAD бафф
    if (Jass::GetUnitAbilityLevel(u, 'A19W') >= 2) {
        int maxSt = (Jass::GetUnitAbilityLevel(u, 'A19W') == 2) ? Q_Stack : 999;
        int qch = HMinInt(HGetAbilityCharges(u, 'A19W') + 1, maxSt);
        HSetAbilityCharges(u, 'A19W', qch);

        timer t2 = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t2), 0, u);
        Jass::TimerStart(t2, Q_Duration, false, @Q_StackEnd);

        // MagicAD бафф
        float md = Q_MD * float(qch);
        if (qch >= Q_Stack && Jass::GetUnitAbilityLevel(u, 'A19W') >= 3) {
            md = Q_MD * float(qch) + Q_UpMD;
        }
        HAddBuff_MagicAD(u, 'A19W', md, Q_Duration);
    }
}

void Q_StackEnd() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    int ch = HGetAbilityCharges(u, 'A19W');
    if (ch > 0) HSetAbilityCharges(u, 'A19W', ch - 1);
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void E_StackEnd() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    int ch = HGetAbilityCharges(u, 'A1A2');
    if (ch > 0) HSetAbilityCharges(u, 'A1A2', ch - 1);
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

// ==================== Q (A19W) — Самоподрыв ====================

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float dmg = Q_int * float(Jass::GetHeroInt(u, true));
    float scale = 1.0;

    // Сбросить КД W
    HReduceCooldown(u, 'A0Q5', 999.0);

    // Добавить заряд R
    HSetAbilityCharges(u, 'A19P', HMinInt(HGetAbilityCharges(u, 'A19P') + 1, R_Stack));

    // Эффект взрыва + AOE спелл-урон
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    unit fx = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'e011', x, y, 0.0);
    Jass::SetUnitScale(fx, scale, 0.0, 0.0);
    Jass::UnitApplyTimedLife(fx, 'BTLF', 5.0);
    Jass::DestroyEffect(Jass::AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl", fx, "origin"));

    HAOESpellDmg(u, x, y, float(Q_Range) * scale, dmg);

    AllPodrSkills(u);
}

// ==================== W (A0Q5) — Телепортация-взрыв ====================

void W_Vul() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    Jass::SetUnitInvulnerable(u, false);

    // 3 ур.: стан + MagicAD
    if (Jass::GetUnitAbilityLevel(u, 'A0Q5') >= 3) {
        HAOEStun(Jass::GetUnitX(u), Jass::GetUnitY(u), u, 200.0, W_Stun2);
        HAddBuff_MagicAD(u, 'A0Q5', W_MD, 2.0);
    }

    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Неуязвимость
    Jass::SetUnitInvulnerable(u, true);
    timer t = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::TimerStart(t, W_invul, false, @W_Vul);

    // Стаки W → заряд R
    int wStacks = Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), 'A0Q5') + 1;
    Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'A0Q5', wStacks);

    if (wStacks >= 2) {
        HSetAbilityCharges(u, 'A19P', HMinInt(HGetAbilityCharges(u, 'A19P') + 1, R_Stack));
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'A0Q5', 0);
    }

    AllPodrSkills(u);
}

// ==================== E (A1A2) — Прыжок в лагерь ====================

void E_JumpTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit portal = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    int tick = Jass::LoadInteger(SkillHT, th, 2) + 1;
    Jass::SaveInteger(SkillHT, th, 2, tick);
    int lvl = Jass::GetUnitAbilityLevel(hero, 'A1A2');

    if (tick == 22) {
        Jass::SetUnitAnimation(portal, "death");
    }

    if (tick >= 25) {
        // Выход из прыжка
        if (lvl >= 2) {
            HAOESpellDmg(hero, Jass::GetUnitX(hero), Jass::GetUnitY(hero), 325.0,
                         E_int3 * float(Jass::GetHeroInt(hero, true)));
        }
        Jass::ShowUnit(hero, true);
        Jass::PauseUnit(hero, false);
        Jass::SetUnitInvulnerable(hero, false);
        Jass::KillUnit(portal);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    // Отправить бомбу
    float px = Jass::GetUnitX(portal);
    float py = Jass::GetUnitY(portal);
    float dist;
    float angle;
    float bx;
    float by;

    if (tick % 2 == 0) {
        // Четный тик: попробовать найти врага
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, px, py, 700.0, nil);
        unit u2 = nil;
        unit tempU = Jass::FirstOfGroup(g);
        while (tempU != nil) {
            Jass::GroupRemoveUnit(g, tempU);
            if (Jass::IsUnitAlive(tempU) && Jass::IsUnitEnemy(tempU, Jass::GetOwningPlayer(hero))) {
                u2 = tempU;
                break;
            }
            tempU = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);

        if (u2 != nil) {
            bx = Jass::GetUnitX(u2);
            by = Jass::GetUnitY(u2);
        } else {
            float maxDist = (lvl >= 3) ? 700.0 : 500.0;
            dist = Jass::GetRandomReal(0.0, maxDist);
            angle = Jass::GetRandomReal(0.0, 360.0);
            bx = px + dist * Jass::MathCosDeg(angle);
            by = py + dist * Jass::MathSinDeg(angle);
        }
    } else {
        float maxDist = (lvl >= 3) ? 700.0 : 500.0;
        dist = Jass::GetRandomReal(0.0, maxDist);
        angle = Jass::GetRandomReal(0.0, 360.0);
        bx = px + dist * Jass::MathCosDeg(angle);
        by = py + dist * Jass::MathSinDeg(angle);
    }

    // Выбор типа бомбы
    int bombId = (Jass::GetRandomInt(1, 30) <= 18) ? 'h04M' : 'h04O';
    unit bomb = Jass::CreateUnit(Jass::GetOwningPlayer(portal), bombId, px, py, 0.0);
    Jass::UnitApplyTimedLife(bomb, 'BTLF', 1.0);
    Jass::IssuePointOrder(bomb, "attack", bx, by);

    Jass::TimerStart(t, 0.20, false, @E_JumpTick);
}

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Проверка стаков для активации бонуса
    if (HGetAbilityCharges(u, 'A1A2') >= E_Stack) {
        // Восстановить ману
        float maxMana = Jass::GetUnitState(u, Jass::UNIT_STATE_MAX_MANA);
        HGiveMana(u, maxMana * E_MP_Res);
        // 3 ур.: сброс КД Q и W, восстановить заряды R
        if (abilvl >= 3) {
            HReduceCooldown(u, 'A19W', 999.0);
            HReduceCooldown(u, 'A0Q5', 999.0);
            HSetAbilityCharges(u, 'A19P', R_Stack);
        }
        HSetAbilityCharges(u, 'A1A2', 0);
    }

    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // Скрыть и запустить прыжок
    Jass::PauseUnit(u, true);
    Jass::SetUnitInvulnerable(u, true);
    Jass::ShowUnit(u, false);

    // Портал
    unit portal = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h04Q', x, y, 0.0);
    Jass::UnitApplyTimedLife(portal, 'BTLF', 5.0);
    Jass::SetUnitAnimation(portal, "birth");

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, portal);
    Jass::SaveUnitHandle(SkillHT, th, 1, u);
    Jass::SaveInteger(SkillHT, th, 2, 0); // tick counter
    Jass::TimerStart(t, 0.20, false, @E_JumpTick);

    AllPodrSkills(u);
}

// ==================== R (A19P) — Динамит ====================

void R_ExplodeDynamite() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    float ex = Jass::LoadReal(SkillHT, th, 1);
    float ey = Jass::LoadReal(SkillHT, th, 2);
    float dmgMul = Jass::LoadReal(SkillHT, th, 3);
    float stunDur = Jass::LoadReal(SkillHT, th, 4);

    float dmg = dmgMul * (float(Jass::GetHeroInt(hero, true)) * R_int);
    float range = 175.0;

    HAOESpellDmg(hero, ex, ey, range, dmg);
    if (stunDur > 0.0) {
        HAOEStun(ex, ey, hero, range, stunDur);
    }

    // R>=2: проверить стак дебаффа
    int debuffFlag = Jass::LoadInteger(SkillHT, Jass::GetHandleId(hero), 'h00R');
    if (debuffFlag == 1) {
        // Применить MR дебафф AOE
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, ex, ey, range, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(hero))) {
                float mrDebuff = -(R_d_pr + float(Jass::GetHeroInt(hero, true)) / float(R_d_ThenInt));
                HAddBuff_MR(u2, 'h00R', mrDebuff, R_d_pr_Duration);
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(hero), 'h00R', 0);
    }

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int charges = HGetAbilityCharges(u, 'A19P');
    if (charges == 0) return;

    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // 2 ур.: стаки → сброс КД Q + MR дебафф
    if (abilvl >= 2) {
        int rStacks = Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), 'A19P') + 1;
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'A19P', rStacks);
        if (rStacks >= 3) {
            HReduceCooldown(u, 'A19W', R_Q);
            Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'A19P', 0);
            Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'h00R', 1);
        }
    }

    // Уменьшить заряды
    HSetAbilityCharges(u, 'A19P', charges - 1);

    // Дамми-шашка
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h00R', x, y, 270.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 3.0);
    Jass::IssuePointOrder(dummy, "attack", targX, targY);

    // Таймер: взрыв по прибытии
    float dist = Jass::SquareRoot((targX - x) * (targX - x) + (targY - y) * (targY - y));
    float delay = dist / 700.0 + 0.25;
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveReal(SkillHT, th, 1, targX);
    Jass::SaveReal(SkillHT, th, 2, targY);
    Jass::SaveReal(SkillHT, th, 3, 1.0); // dmg multiplier
    Jass::SaveReal(SkillHT, th, 4, 0.0); // stun duration
    Jass::TimerStart(t, delay, false, @R_ExplodeDynamite);

    AllPodrSkills(u);
}

// Перезарядка шашек (вызывается при инициализации героя)
void R_AddCharges() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pid = Jass::LoadInteger(SkillHT, th, 1);

    if (u == nil || Jass::GetUnitTypeId(u) == 0 || Jass::GetPlayerId(Jass::GetOwningPlayer(u)) != pid || Jass::GetUnitAbilityLevel(u, 'A19P') <= 0) {
        Jass::RemoveSavedHandle(SkillHT, R_TimerParent, pid);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        t = nil;
        u = nil;
        return;
    }

    HSetAbilityCharges(u, 'A19P', HMinInt(HGetAbilityCharges(u, 'A19P') + 1, R_Stack));

    t = nil;
    u = nil;
}

void R_SetCharges(unit u) {
    if (u == nil) return;

    int pid = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    timer existed = Jass::LoadTimerHandle(SkillHT, R_TimerParent, pid);
    if (existed != nil) {
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(existed), 0, u);
        existed = nil;
        return;
    }

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveInteger(SkillHT, th, 1, pid);
    Jass::SaveTimerHandle(SkillHT, R_TimerParent, pid, t);
    Jass::TimerStart(t, R_time, true, @R_AddCharges);
    t = nil;
}

// ==================== T (A0KI) — Ядерная бомба ====================

void T_BoomDamage() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit bomb = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 1);
    int abilvl = Jass::LoadInteger(SkillHT, th, 2);

    if (HIsUnitDead(bomb)) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    float bx = Jass::GetUnitX(bomb);
    float by = Jass::GetUnitY(bomb);
    float range = (abilvl >= 3) ? float(T_MaxRange2) : float(T_MaxRange1);
    float slowTime = (abilvl >= 3) ? T_d_MS_Duration2 : T_d_MS_Duration1;
    float heroInt = float(Jass::GetHeroInt(hero, true));

    // 2 ур.: дебаффы врагам в зоне
    if (abilvl >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, bx, by, range, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(hero))) {
                // MR дебафф ближним (range*0.2)
                float dx = Jass::GetUnitX(u2) - bx;
                float dy = Jass::GetUnitY(u2) - by;
                float d = Jass::SquareRoot(dx * dx + dy * dy);
                if (d <= range * 0.2) {
                    if (abilvl == 2) {
                        HAddBuff_MR(u2, 'A0KI', -(T_d_mr1 + heroInt / float(T_d_mr1_Then)), T_d_mr_Duration1);
                    } else {
                        HAddBuff_MR(u2, 'A0KI', -(T_d_mr2 + heroInt / float(T_d_mr2_Then)), T_d_mr_Duration2);
                    }
                }
                HAddBuff_MS(u2, 'A0KI', 0, -0.7, slowTime);
                // 3 ур.: стан
                if (abilvl >= 3) {
                    StunUnit(u2, T_Stun);
                }
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }

    // Урон по зонам: ядро (100%), средняя (75%), край (50%)
    float coreDmg = T_int * heroInt;
    float midDmg = 0.75 * T_int * heroInt;
    float edgeDmg = 0.5 * T_int * heroInt;

    // Нанести зональный урон
    group g2 = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g2, bx, by, range, nil);
    unit u3 = Jass::FirstOfGroup(g2);
    while (u3 != nil) {
        Jass::GroupRemoveUnit(g2, u3);
        if (Jass::IsUnitAlive(u3) && Jass::IsUnitEnemy(u3, Jass::GetOwningPlayer(hero))) {
            float dx = Jass::GetUnitX(u3) - bx;
            float dy = Jass::GetUnitY(u3) - by;
            float d = Jass::SquareRoot(dx * dx + dy * dy);
            if (d <= range * 0.3) {
                HDealSpellDmg(hero, u3, coreDmg);
            } else if (d <= range * 0.5) {
                HDealSpellDmg(hero, u3, midDmg);
            } else {
                HDealSpellDmg(hero, u3, edgeDmg);
            }
        }
        u3 = Jass::FirstOfGroup(g2);
    }
    Jass::DestroyGroup(g2);

    // Убить бомбу
    Jass::KillUnit(bomb);
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Создать бомбу
    unit bomb = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'h040', targX, targY, 0.0);
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, bomb);
    Jass::SaveUnitHandle(SkillHT, th, 1, u);
    Jass::SaveInteger(SkillHT, th, 2, abilvl);
    Jass::TimerStart(t, T_time, false, @T_BoomDamage);

    AllPodrSkills(u);
}

// ==================== Регистрация ====================

void InitPodrSkills() {
    RegisterAbilityCastHandler('A19W', @Q_Cast);
    RegisterAbilityCastHandler('A0Q5', @W_Cast);
    RegisterAbilityCastHandler('A1A2', @E_Cast);
    RegisterAbilityCastHandler('A19P', @R_Cast);
    RegisterAbilityCastHandler('A0KI', @T_Cast);
    Jass::ConsolePrint("Podr skills initialized.");
}

} // namespace Podr
