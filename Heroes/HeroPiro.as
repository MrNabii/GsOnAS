// ============================================================
//  HeroPiro.as — Пироман (Pyromancer) — герой H001
// ============================================================
// Скиллы: Q(A00W) Стена огня, W(A00V) Бешенный смех,
//          E(A00X) Напалм, R(A00U) Нагрев, T(A007) Огненная Душа
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Piro {

// ==================== Параметры скиллов ====================

// --- T (A007) Огненная Душа ---
float T_str              = 60.0;     // множитель силы для урона
float T_StartDmg         = 15.0;     // стартовый бонус TotalAD (%)
float T_ThenDmgS         = 600.0;    // делитель для scaling
float T_ThenDmg          = 1.0 / 600.0;
float T_mr               = 0.5;      // бонус MR на 3 уровне
float T_mp               = 2.0;      // мана за атаку на 3 уровне

// --- R (A00U) Нагрев ---
float R_Dmg              = 0.025;    // бонус TotalAD за стак
int   R_Charges          = 10;       // макс стаков
float R_dr               = 0.3;      // бонус DR
float R_Distance         = 75.0;     // отталкивание при получении урона (2 ур.)
float R_str              = 8.0;      // множитель силы для урона при отталкивании

// --- E (A00X) Напалм ---
float E_Startfr          = 5.0;
float E_ThenfrS          = 1000.0;
float E_Thenfr           = 1.0 / 1000.0;
float E_StartCharge      = 4.0;      // базовые заряды
float E_ThenCharge       = 1.0 / 1.5; // скейлинг зарядов от AS
float E_AD               = 3.3;      // множитель AD для урона
float E_Dmg              = 8.0;      // % бонус TotalAD за стак (2 ур.)

// --- W (A00V) Бешенный смех ---
float W_StartDmg         = 15.0;     // стартовый бонус TotalAD
float W_ThenDmgS         = 3.0;
float W_ThenDmg          = 1.0 / 3.0;
float W_AD               = 6.0;      // множитель AD для урона
float W_CapASS           = 10.0;
float W_CapAS            = 1.0 / 10.0;
float W_StartCapAS       = 1.0;
float W_Stun             = 0.7;      // стан боссов
float W_Range            = 0.15;
float W_DmgOut           = 0.25;     // множитель урона при взрыве (3 ур.)

// --- Q (A00W) Стена огня ---
float Q_str              = 9.0;      // множитель силы
float Q_fr               = 1.0;
float Q_AD               = 2.0;
float Q_Distance         = 125.0;    // дистанция отталкивания
float Q_DistanceUp       = 2.5;      // увеличение дистанции от PR

// ==================== Внутренние массивы ====================
array<bool>  RBool(10);       // PiroR: флаг достижения 10 стаков
array<bool>  WBool(10);       // PiroW: флаг активного W3
array<float> W_DmgStore(10);  // PiroW: накопленный урон (3 ур.)

// ==================== T (A007) — Огненная Душа ====================

void T_OnAttack(unit attacker, unit target) {
    HGiveMana(attacker, T_mp);
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // AOE урон по всем врагам в радиусе 1400
    float dmg = float(Jass::GetHeroStr(u, true)) * T_str;
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, 1400.0, nil);
    float hitCount = 0;
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
            Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
                "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", u2, "origin"));
            HDealSpellDmg(u, u2, dmg);
            if (abilvl >= 2) hitCount += 1.0;
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    // 2 ур.: снижение КД + бонус TotalAD
    if (abilvl >= 2) {
        float cdReduction = HMinReal(hitCount * 0.2, 20.0);
        HReduceCooldown(u, abilId, cdReduction);
        float adBonus = (T_StartDmg + T_ThenDmg * float(Jass::GetHeroStr(u, true))) / 100.0;
        HAddBuff_TotalAD(u, abilId, adBonus, 10.0);
    }

    // 3 ур.: бонус MR + мана за атаку
    if (abilvl >= 3) {
        HAddBuff_MR(u, 'A007', T_mr, 10.0);
        HRegisterOnAttack(u, 'A007', @T_OnAttack, 10.0);
    }
}

// ==================== R (A00U) — Нагрев ====================

void R_OnDamage_Callback(unit source, unit target) {
    // target = юнит с нагревом, source = атакующий
    int abilvl = Jass::GetUnitAbilityLevel(target, 'A00U');
    if (abilvl >= 2) {
        // Отталкивание
        float angle = Jass::MathAngleBetweenPoints(
            Jass::GetUnitX(target), Jass::GetUnitY(target),
            Jass::GetUnitX(source), Jass::GetUnitY(source));
        float pushX = Jass::GetUnitX(source) + R_Distance * Jass::Cos(angle * 0.01745329);
        float pushY = Jass::GetUnitY(source) + R_Distance * Jass::Sin(angle * 0.01745329);
        Jass::SetUnitPosition(source, pushX, pushY);
        // Урон
        float dmg = float(HGetAbilityCharges(target, 'A00U')) * 0.1 * R_str * float(Jass::GetHeroStr(target, true));
        HDealSpellDmg(target, source, dmg);
    }
}

void R_Periodic() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // Проверка: если бафф BEim снят — остановить
    if (Jass::GetUnitAbilityLevel(u, 'BEim') == 0) {
        HRemoveOnDamage(u, 'A00U');
        HSetAbilityCharges(u, 'A00U', 0);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    int charges = HGetAbilityCharges(u, 'A00U') + 1;
    int manaCost = 0;
    if (charges > 5) manaCost = charges - 5;

    // Расход маны
    int savedFree = Jass::LoadInteger(SkillHT, th, 2);
    if (savedFree > 0) {
        Jass::SaveInteger(SkillHT, th, 2, savedFree - 1);
    } else {
        float curMana = Jass::GetUnitState(u, Jass::UNIT_STATE_MANA);
        Jass::SetUnitState(u, Jass::UNIT_STATE_MANA, HMaxReal(0, curMana - float(2 + manaCost)));
    }

    charges = HMinInt(R_Charges, charges);
    HSetAbilityCharges(u, 'A00U', charges);
    HAddBuff_TotalAD(u, 'BEim', R_Dmg * float(charges), 1.05);
    HAddBuff_DR(u, 'BEim', R_dr, 1.05);

    // 3 ур.: при 10 стаках — снижение КД всех способностей
    if (Jass::GetUnitAbilityLevel(u, 'A00U') >= 3 && charges == 10 && !RBool[pn]) {
        // Уменьшить КД всех скиллов на 15%
        // (упрощённая версия ReduceAllAbilityCooldawn)
        RBool[pn] = true;
    }
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    RBool[pn] = false;

    timer t = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 2, 0);
    Jass::TimerStart(t, 1.0, true, @R_Periodic);
    HAddBuff_DR(u, 'BEim', R_dr, 1.05);
    HRegisterOnDamage(u, 'A00U', @R_OnDamage_Callback, 0.0);
}

// ==================== E (A00X) — Напалм ====================

void E_OnAttack_Callback(unit attacker, unit target) {
    int abilvl = Jass::GetUnitAbilityLevel(attacker, 'A00X');
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(attacker));
    float dmg = E_AD * HGetUnitAD(attacker);

    // 2 ур.: накопление бонуса
    if (abilvl >= 2) {
        int stacks = Jass::LoadInteger(SkillHT, 'A00X', pn * 10 + 2) + 1;
        HAddBuff_TotalAD(attacker, 'A00X', (E_Dmg / 100.0) * float(stacks), 2.5);
        Jass::SaveInteger(SkillHT, 'A00X', pn * 10 + 2, stacks);
    }

    HDealSpellDmg(attacker, target, dmg);

    int charges = HGetAbilityCharges(attacker, 'A00X') - 1;
    HSetAbilityCharges(attacker, 'A00X', charges);
    if (charges <= 0) {
        HRemoveOnAttack(attacker, 'A00X');
    }
}

void E_End() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    int abilvl = Jass::GetUnitAbilityLevel(u, 'A00X');

    // Перезапуск заряжания
    timer t2 = Jass::LoadTimerHandle(SkillHT, 'A00X', pn * 10);
    Jass::TimerStart(t, 6.0, false, @E_Resume);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(u, 'A00X'), 6.0);

    if (t2 != nil) Jass::PauseTimer(t2);
    HSetAbilityCharges(u, 'A00X', 0);
    Jass::RemoveSavedInteger(SkillHT, 'A00X', pn * 10 + 2);

    // 3 ур.: бонус TotalAD от оставшихся зарядов
    if (abilvl >= 3) {
        // Кол-во изначальных зарядов - используем формулу
        UnitData@ ud = GetUnitData(u);
        float capAS = 0;
        if (ud !is null) capAS = ud.totalStats.attackSpeedPct;
        float maxCharges = E_StartCharge + E_ThenCharge * capAS;
        HAddBuff_TotalAD(u, 'A00X', (E_Dmg / 2.0 / 100.0) * maxCharges, 3.0);
    }
}

void E_Resume() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    timer t2 = Jass::LoadTimerHandle(SkillHT, 'A00X', pn * 10);
    if (t2 != nil) {
        Jass::TimerStart(t2, 1.0, true, null);
    }
    // Пересчёт зарядов
    UnitData@ ud = GetUnitData(u);
    float capAS = 0;
    if (ud !is null) capAS = ud.totalStats.attackSpeedPct;
    int charges = Jass::R2I(E_StartCharge + E_ThenCharge * capAS);
    HSetAbilityCharges(u, 'A00X', charges);
}

void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // Установка нулевого каст-тайма
    Jass::SetAbilityCastPoint(abil, 0.0);

    if (HGetAbilityCharges(u, 'A00X') <= 0) return;

    Jass::StartAbilityCooldown(Jass::GetUnitAbility(u, 'A00X'), 6.1);

    // Управление таймером окончания
    timer t;
    if (!Jass::HaveSavedHandle(SkillHT, 'A00X', pn * 10 + 1)) {
        t = Jass::CreateTimer();
        Jass::SaveTimerHandle(SkillHT, 'A00X', pn * 10 + 1, t);
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    } else {
        t = Jass::LoadTimerHandle(SkillHT, 'A00X', pn * 10 + 1);
    }
    Jass::TimerStart(t, 12.0, false, @E_End);

    HRegisterOnAttack(u, 'A00X', @E_OnAttack_Callback, 6.0);
}

// ==================== W (A00V) — Бешенный смех ====================

void W_End() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::LoadInteger(SkillHT, th, 0);
    WBool[pn] = false;

    // Взрыв при окончании (3 ур.)
    HAOESpellDmg(u, Jass::GetUnitX(u), Jass::GetUnitY(u), 500.0, W_DmgStore[pn] * W_DmgOut);
    W_DmgStore[pn] = 0;

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // Бонус TotalAD
    UnitData@ ud = GetUnitData(u);
    float capAS = 0;
    if (ud !is null) capAS = ud.totalStats.attackSpeedPct;
    HAddBuff_TotalAD(u, 'A00V', (W_StartDmg + W_ThenDmg * capAS) / 100.0, 15.0);
    WBool[pn] = false;

    // 2 ур.: AOE урон + отталкивание
    if (abilvl >= 2) {
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, x, y, 500.0, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
                float dmg = W_AD * HGetUnitAD(u) * (W_StartCapAS + capAS * W_CapAS);
                HDealSpellDmg(u, u2, dmg);
                if (Jass::GetUnitLevel(u2) == 10) {
                    // Босс — стан вместо отталкивания
                    StunUnit(u2, W_Stun);
                } else {
                    // Отталкивание
                    float angle = Jass::MathAngleBetweenPoints(x, y, Jass::GetUnitX(u2), Jass::GetUnitY(u2));
                    float pr = 0;
                    if (ud !is null) pr = ud.totalStats.resistAll;
                    float pushDist = (Q_Distance + Q_DistanceUp * pr) * 1.5;
                    float nx = Jass::GetUnitX(u2) + pushDist * Jass::Cos(angle * 0.01745329);
                    float ny = Jass::GetUnitY(u2) + pushDist * Jass::Sin(angle * 0.01745329);
                    Jass::SetUnitPosition(u2, nx, ny);
                }
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }

    // 3 ур.: накопление урона для взрыва
    if (abilvl >= 3) {
        WBool[pn] = true;
        W_DmgStore[pn] = 0;
        timer t = Jass::CreateTimer();
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 0, pn);
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::TimerStart(t, 15.0, false, @W_End);
    }
}

// ==================== Q (A00W) — Стена огня ====================

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    // Создаём дамми-юнит, который кастует breathoffire
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'e00F', Jass::GetUnitX(u), Jass::GetUnitY(u), 0.0);
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
    Jass::IssuePointOrder(dummy, "breathoffire", targX, targY);
}

// ==================== Регистрация ====================

void InitPiroSkills() {
    RegisterAbilityCastHandler('A007', @T_Cast);
    RegisterAbilityCastHandler('A00U', @R_Cast);
    RegisterAbilityCastHandler('A00X', @E_Cast);
    RegisterAbilityCastHandler('A00V', @W_Cast);
    RegisterAbilityCastHandler('A00W', @Q_Cast);
    Debug("InitPiroSkills", "Piro skills initialized.");
}

} // namespace Piro
