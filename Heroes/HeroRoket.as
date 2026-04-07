// ============================================================
//  HeroRoket.as — Ракетчик (Rocketeer) — герой H003
// ============================================================
// Скиллы: Q(A00T) Бомбы, W(A0CY) Оборона, E(A010) Вращение,
//          R(A01Y) Заряды, T(A0S9) Артиллерия
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Roket {

// ==================== Параметры скиллов ====================

// --- Q (A00T) Бомбы ---
float Q_AD                = 0.65;     // множитель AD снаряда
float Q_d_fr              = 0.1;      // дебафф PR
float Q_cd                = 2.5;      // снижение КД T за каст
float Q_Crit              = 0.5;      // бонус крит (3 ур., 33%)
float Q_Range             = 1.35;     // увеличение разброса (2 ур.)
float Q_Stun              = 0.25;     // стан
int Q_DummyId           = 'e00G';   // ID дамми-бомбы

// --- W (A0CY) Оборона ---
float W_fr                = 0.25;     // бонус PR
float W_cd                = 7.5;      // снижение КД T за каст
float W_cd2               = 10.0;     // (запас)
float W_str               = 8.0;      // множитель str для урона ракетой
float W_HPreg             = 0.5;      // бонус HP regen
float W_Stun              = 0.2;      // стан за каждое попадание
float W_LaunchStun        = 0.5;      // стан от ракеты (2 ур.)
float W_Duration          = 1.0;      // длительность замедления MS (3 ур.)

// --- E (A010) Вращение ---
float E_p_str             = 0.1;      // % бонус str
float E_CapAS             = 0.15;     // бонус CapAS (2 ур.)
float E_CapAS2            = 0.33;     // бонус CapAS (3 ур.)
float E_d_MS              = 0.33;     // дебафф MS (2 ур.)
float E_str               = 9.0;      // множитель str для урона ракетой
float E_Fr                = 1.5;      // дебафф PR от ракеты
float E_fr                = 0.015;    // E_Fr/100
float E_Stun              = 0.3;      // стан за удар (2 ур.)
float E_ADBonus           = 0.85;     // бонус AD (запас)
float E_AS                = 1.0;      // бонус AS (3 ур.)
float E_cd                = 7.5;      // снижение КД T за каст

// --- R (A01Y) Заряды ---
float R_HP                = 0.15;     // множитель HP для урона (A2 charges)
float R_AD                = 2.0;      // множитель AD для урона (A1 charges)
float R_MS_Duration       = 0.5;      // длительность доп. замедления за заряд (2 ур.)
float R_AA                = 0.1;      // множитель splash за заряд
float R_AS                = 0.1;      // бонус AS за заряд (3 ур.)
float R_d_dr              = 0.15;     // бонус DR (3 ур.)
float R_dr_Duration       = 0.35;     // длительность DR за A2 заряд
float R_Stun              = 1.5;      // стан (запас)
int   R_Q                 = 1;        // зарядов от Q
int   R_W                 = 1;        // зарядов от W
int   R_E                 = 1;        // зарядов от E
int   R_T                 = 10;       // зарядов от T

// --- T (A0S9) Артиллерия ---
float T_str               = 9.0;      // множитель str для урона
float T_AD                = 0.8;      // множитель AD
float T_Stun1             = 0.7;      // стан (2 ур.)
float T_Stun2             = 1.1;      // стан (3 ур.)

// ==================== Q (A00T) — Бомбы ====================

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    // R>=2: добавить заряды R (charges 1)
    if (Jass::GetUnitAbilityLevel(u, 'A01Y') >= 2) {
        HSetAbilityCharges(u, 'A01Y', HMinInt(HGetAbilityCharges(u, 'A01Y') + R_Q, 10));
    }
    // T>=3: снизить КД T
    if (Jass::GetUnitAbilityLevel(u, 'A0S9') >= 3) {
        HReduceCooldown(u, 'A0S9', Q_cd);
    }

    // Крит бонус (3 ур., 33% шанс)
    float critMul = 1.0;
    if (abilvl == 3 && Jass::GetRandomReal(0.0, 100.0) <= 33.3) {
        critMul = 1.0 + Q_Crit;
    }

    // Запомнить крит-множитель для дамми
    Jass::SaveReal(SkillHT, Jass::GetHandleId(u), Q_DummyId, critMul - 1.0);

    // Создать 10 бомб
    float maxDist = (abilvl >= 2) ? 200.0 * Q_Range : 200.0;
    for (int i = 0; i < 10; i++) {
        unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), Q_DummyId, x, y, 0.0);
        Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
        float dist = Jass::GetRandomReal(0.0, maxDist);
        float angle = Jass::GetRandomReal(0.0, 360.0);
        float bx = targX + dist * Jass::MathCosDeg(angle);
        float by = targY + dist * Jass::MathSinDeg(angle);
        Jass::IssuePointOrder(dummy, "attack", bx, by);
    }
}

// ==================== W (A0CY) — Оборона ====================

// Callback при получении урона: выпуск ракеты
void W_OnDamage(unit source, unit target) {
    // target = W-юнит (наш), source = атакующий
    int charges = HGetAbilityCharges(target, 'A0CY');
    if (charges == 0) {
        // Выпустить ракету
        float rocketDmg = W_str * float(Jass::GetHeroStr(target, true));
        unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(target), 'hdum', Jass::GetUnitX(target), Jass::GetUnitY(target), 0.0);
        Jass::UnitAddAbility(dummy, 'A0S7');
        Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
        Jass::IssueTargetOrder(dummy, "thunderbolt", source);

        // Таймер: урон по попадании
        timer t = Jass::CreateTimer();
        int th = Jass::GetHandleId(t);
        Jass::SaveUnitHandle(SkillHT, th, 0, target);
        Jass::SaveUnitHandle(SkillHT, th, 1, source);
        Jass::SaveReal(SkillHT, th, 2, rocketDmg);
        float delay = GetUnitDistance(target, source) / 800.0;
        if (delay < 0.05) delay = 0.05;
        Jass::TimerStart(t, delay, false, @W_RocketHit);
    }

    // 3 ур.: замедление атакующего
    if (Jass::GetUnitAbilityLevel(target, 'A0CY') >= 3) {
        HAddBuff_MS(source, 'A0CY', 0, -1.0, W_Duration);
    }
    StunUnit(source, W_Stun);

    // Уменьшить заряды CD-тайма
    if (charges == 0) {
        // Начать отсчёт зарядов
        int maxCharges = (Jass::GetUnitAbilityLevel(target, 'A0CY') >= 2) ? 3 : 2;
        HSetAbilityCharges(target, 'A0CY', maxCharges);
        timer ct = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(ct), 0, target);
        Jass::TimerStart(ct, 1.0, true, @W_ChargeTimer);
    }
}

void W_RocketHit() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit target = Jass::LoadUnitHandle(SkillHT, th, 1);
    float dmg = Jass::LoadReal(SkillHT, th, 2);

    HDealPhysDmg(hero, target, dmg);
    if (Jass::GetUnitAbilityLevel(hero, 'A0CY') >= 2) {
        StunUnit(target, W_LaunchStun);
    }
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void W_ChargeTimer() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    int ch = HGetAbilityCharges(u, 'A0CY') - 1;
    HSetAbilityCharges(u, 'A0CY', HMaxInt(ch, 0));

    if (ch <= 0) {
        Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
        Jass::DestroyTimer(t);
    }
}

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Бонус PR
    HAddBuff_PR(u, 'A0CY', W_fr, 10.0);
    HSetAbilityCharges(u, 'A0CY', 0);

    // R>=2: добавить заряды R (charges 2)
    if (Jass::GetUnitAbilityLevel(u, 'A01Y') >= 2) {
        HSetAbility2Charges(u, 'A01Y', HMinInt(HGetAbility2Charges(u, 'A01Y') + R_W, 10));
    }
    // T>=3: снизить КД T
    if (Jass::GetUnitAbilityLevel(u, 'A0S9') >= 3) {
        HReduceCooldown(u, 'A0S9', W_cd);
    }

    float dur = 10.0;
    if (abilvl == 3) dur = 12.5;

    HRegisterOnDamage(u, 'A0CY', @W_OnDamage, dur);

    // 3 ур.: щит (HP бафф)
    if (abilvl >= 3) {
        float shield = Jass::GetUnitMaxLife(u) * 0.12;
        HAddBuff_HP(u, 'A0CY', shield, 0, dur);
    }
}

// ==================== E (A010) — Вращение ====================

void E_OnAttack(unit attacker, unit target) {
    int charges = HGetAbilityCharges(attacker, 'A010') + 1;
    HSetAbilityCharges(attacker, 'A010', HMinInt(charges, 3));

    // 2 ур.: стан за удар
    if (Jass::GetUnitAbilityLevel(attacker, 'A010') >= 2) {
        StunUnit(target, E_Stun);
    }

    // 3 стака → выпустить ракету
    if (charges >= 3) {
        float rocketDmg = E_str * float(Jass::GetHeroStr(attacker, true));
        float pr = (Jass::GetUnitAbilityLevel(attacker, 'A010') >= 2) ? -E_fr : 0.0;

        // Ракета-дамми
        unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(attacker), 'hdum', Jass::GetUnitX(attacker), Jass::GetUnitY(attacker), 0.0);
        Jass::UnitAddAbility(dummy, 'A0S7');
        Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
        Jass::IssueTargetOrder(dummy, "thunderbolt", target);

        // Урон по попадании
        timer t = Jass::CreateTimer();
        int th = Jass::GetHandleId(t);
        Jass::SaveUnitHandle(SkillHT, th, 0, attacker);
        Jass::SaveUnitHandle(SkillHT, th, 1, target);
        Jass::SaveReal(SkillHT, th, 2, rocketDmg);
        Jass::SaveReal(SkillHT, th, 3, pr);
        float delay = GetUnitDistance(attacker, target) / 800.0;
        if (delay < 0.05) delay = 0.05;
        Jass::TimerStart(t, delay, false, @E_RocketHit);

        HSetAbilityCharges(attacker, 'A010', 0);
    }
}

void E_RocketHit() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit tgt = Jass::LoadUnitHandle(SkillHT, th, 1);
    float dmg = Jass::LoadReal(SkillHT, th, 2);
    float pr = Jass::LoadReal(SkillHT, th, 3);

    if (pr != 0.0) {
        HAddBuff_PR(tgt, 'A0S7', pr, 2.0);
    }
    HDealPhysDmg(hero, tgt, dmg);
    if (Jass::GetUnitAbilityLevel(hero, 'A0CY') >= 2) {
        StunUnit(tgt, W_LaunchStun);
    }
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // R>=3: добавить заряды R
    if (Jass::GetUnitAbilityLevel(u, 'A01Y') >= 3) {
        HSetAbilityCharges(u, 'A01Y', HMinInt(HGetAbilityCharges(u, 'A01Y') + R_E, 10));
    }
    // T>=3: снизить КД T
    if (Jass::GetUnitAbilityLevel(u, 'A0S9') >= 3) {
        HReduceCooldown(u, 'A0S9', E_cd);
    }

    float dur = 10.0;
    if (abilvl >= 3) dur = 12.5;

    // Бонус str
    HAddBuff_Str(u, 'A010', 10, E_p_str, dur);

    if (abilvl >= 2) {
        HAddBuff_CapAS(u, 'A010', (abilvl >= 3) ? E_CapAS2 : E_CapAS, dur);
        HAddBuff_MS(u, 'A010', 0, -E_d_MS, dur);
    }
    if (abilvl >= 3) {
        HAddBuff_AS(u, 'A010', E_AS, dur);
    }

    HRegisterOnAttack(u, 'A010', @E_OnAttack, dur);
}

// ==================== R (A01Y) — Заряды ====================

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int charges1 = HGetAbilityCharges(u, 'A01Y');
    int charges2 = HGetAbility2Charges(u, 'A01Y');

    // 2 ур.: модификация оружия (arc/splash)
    if (abilvl >= 2) {
        // Увеличить splash на время
        // Через SetUnitWeaponRealField — если доступен нативный вызов
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 1, charges1);
        Jass::TimerStart(t, 5.0, false, @R_RemoveBuff);
    }

    // 3 ур.: AS + DR
    if (abilvl >= 3) {
        HAddBuff_AS(u, 'A01Y', R_AS * float(charges1), 3.5);
        HAddBuff_DR(u, 'A01Y', R_d_dr, R_dr_Duration * float(charges2));
    }

    // AOE физ. урон (charges2 * R_HP * MaxHP)
    HAOEPhysDmg(u, x, y, 325.0, float(charges2) * R_HP * Jass::GetUnitMaxLife(u));

    // Дамми-ракета в точку
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'e00D', x, y, 0.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
    float scale = 1.5 * (1.0 + float(charges1) / 10.0);
    Jass::SetUnitScale(dummy, scale, scale, scale);
    Jass::IssuePointOrder(dummy, "attack", targX, targY);

    // AOE физ. урон в точке (charges1 * R_AD * AD)
    timer t2 = Jass::CreateTimer();
    int th = Jass::GetHandleId(t2);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveReal(SkillHT, th, 1, targX);
    Jass::SaveReal(SkillHT, th, 2, targY);
    Jass::SaveReal(SkillHT, th, 3, float(charges1) * R_AD * HGetUnitAD(u));
    Jass::SaveInteger(SkillHT, th, 4, charges1);
    // Задержка по дистанции
    float delayDist = Jass::SquareRoot((targX - x) * (targX - x) + (targY - y) * (targY - y));
    float delay = delayDist / 700.0 + 0.25;
    Jass::TimerStart(t2, delay, false, @R_Damage);

    // 2 ур.: замедление AOE
    // Запомнить charges для R_Damage

    // Обнулить заряды
    HSetAbilityCharges(u, 'A01Y', 0);
    HSetAbility2Charges(u, 'A01Y', 0);
}

void R_Damage() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    float tx = Jass::LoadReal(SkillHT, th, 1);
    float ty = Jass::LoadReal(SkillHT, th, 2);
    float dmg = Jass::LoadReal(SkillHT, th, 3);
    int ch = Jass::LoadInteger(SkillHT, th, 4);

    HAOEPhysDmg(u, tx, ty, 200.0, dmg);

    // 2 ур.: замедление
    if (Jass::GetUnitAbilityLevel(u, 'A01Y') >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, tx, ty, 245.0, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
                HAddBuff_MS(u2, 'A01Y', 0, -0.5, R_MS_Duration * float(ch));
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void R_RemoveBuff() {
    timer t = Jass::GetExpiredTimer();
    // Восстановить оригинальные параметры оружия
    // (Через UjAPI SetUnitWeaponRealField, если доступно)
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

// ==================== T (A0S9) — Артиллерия ====================

void T_TickAction() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    float tx = Jass::LoadReal(SkillHT, th, 1);
    float ty = Jass::LoadReal(SkillHT, th, 2);
    int remaining = Jass::LoadInteger(SkillHT, th, 3) - 1;

    if (remaining <= 0 || HIsUnitDead(hero)) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    Jass::SaveInteger(SkillHT, th, 3, remaining);

    float hx = Jass::GetUnitX(hero);
    float hy = Jass::GetUnitY(hero);

    // Стан по уровню
    float stun = 0.0;
    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A0S9');
    if (abilvl == 2) stun = T_Stun1;
    else if (abilvl >= 3) stun = T_Stun2;

    // Создать дамми-снаряд
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(hero), 'e002', hx, hy, 0.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 10.0);
    float angle = Jass::GetRandomReal(0.0, 360.0);
    float dx = tx + 200.0 * Jass::MathCosDeg(angle);
    float dy = ty + 200.0 * Jass::MathSinDeg(angle);
    Jass::IssuePointOrder(dummy, "attack", dx, dy);

    // Стан — запоминаем для дамми
    Jass::SaveReal(SkillHT, Jass::GetHandleId(hero), 'A0S9', stun);

    float delay = (abilvl >= 2) ? 0.25 : 0.5;
    Jass::TimerStart(t, delay, false, @T_TickAction);
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // R>=3: дать заряды R + сброс КД R
    if (Jass::GetUnitAbilityLevel(u, 'A01Y') >= 3) {
        HSetAbilityCharges(u, 'A01Y', HMinInt(HGetAbilityCharges(u, 'A01Y') + R_T, 10));
        HSetAbility2Charges(u, 'A01Y', HMinInt(HGetAbility2Charges(u, 'A01Y') + R_T, 10));
        HReduceCooldown(u, 'A01Y', 999.0);
    }

    int count = (abilvl >= 2) ? 15 : 10;

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveReal(SkillHT, th, 1, targX);
    Jass::SaveReal(SkillHT, th, 2, targY);
    Jass::SaveInteger(SkillHT, th, 3, count);

    float delay = (abilvl >= 2) ? 0.25 : 0.5;
    Jass::TimerStart(t, delay, false, @T_TickAction);
}

// ==================== Регистрация ====================

void InitRoketSkills() {
    RegisterAbilityCastHandler('A00T', @Q_Cast);
    RegisterAbilityCastHandler('A0CY', @W_Cast);
    RegisterAbilityCastHandler('A010', @E_Cast);
    RegisterAbilityCastHandler('A01Y', @R_Cast);
    RegisterAbilityCastHandler('A0S9', @T_Cast);
    Jass::ConsolePrint("Roket skills initialized.");
}

} // namespace Roket
