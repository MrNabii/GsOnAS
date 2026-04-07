// ============================================================
//  HeroPulik.as — Пулемётчик (Gunner) — герой H005
// ============================================================
// Скиллы: Q(A0U5) Казнь, W(A0CT) Огневая поддержка,
//          E(A19R/A0P7) Харизма/Эго, R(A19Z) Сотрудничество,
//          T(A0CS) Ультиматив-аура
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Pulik {

// ==================== Параметры скиллов ====================

// --- Q (A0U5) Казнь ---
float Q_AD                = 0.25;     // бонус AD
float Q_agi               = 1.2;      // множитель AGI
float Q_AD2               = 0.08;     // бонус AD2
float Q_d_MS              = 0.45;     // дебафф MS (2 ур.)
float Q_AS_MS             = 0.7;      // бонус AS/MS для ближних юнитов (3 ур.)

// --- W (A0CT) Огневая поддержка ---
float W_StartAD           = 0.10;     // стартовый бонус TotalAD
int   W_ThenAD            = 200;      // скейлинг от суммы статов
float W_StartHP           = 0.05;     // стартовый бонус HP%
int   W_ThenHP            = 200;      // скейлинг от суммы статов
float W_StartCapAS        = 0.10;     // стартовый бонус CapAS (2 ур.)
int   W_ThenCapAS         = 200;      // скейлинг от суммы статов
float W2_MaxHp            = 0.15;     // щит (% от макс. HP) (2 ур.)
float W_Cooldown          = 0.15;     // снижение КД цели (3 ур.)

// --- E (A19R/A0P7) Харизма/Эго ---
float E_StartH_AD         = 0.04;     // TotalAD аура для союзников
int   E_ThenH_AD          = 275;      // скейлинг от суммы статов
float E_StartE_AD         = 0.10;     // TotalAD бафф себе (Эго)
int   E_ThenE_AD          = 200;      // скейлинг от суммы статов
float E_StartCapAS        = 0.10;     // CapAS бафф себе (2 ур.)
int   E_ThenCapAS         = 200;      // скейлинг от AGI
float E_HPRegen           = 0.45;     // бонус HP regen аура (2 ур.)
float E_StartHP           = 0.05;     // бонус HP% аура (2 ур.)
int   E_ThenHP            = 1000;     // скейлинг от суммы статов
float E_CapAS             = 0.01;     // CapAS за атаку (3 ур.)
float E_CapAS_Duration    = 5.0;      // длительность стакающегося CapAS
int   E_H_Active          = 45;       // атак для активации Обороны (3 ур.)
int   E_H_A_Duration      = 8;        // тиков обороны
float E_H_A_dr            = 0.12;     // бонус DR обороны

// --- R (A19Z) Сотрудничество ---
float R_AD1               = 0.05;     // базовый TotalAD
float R_AD2               = 0.02;     // TotalAD за каждого союзника
int   R_Range             = 450;      // радиус проверки союзников
float R_d_AD              = 0.015;    // дебафф DR на врагах (2 ур.)
float R_Cooldown          = 0.15;     // снижение КД разн. союзникам (3 ур.)

// --- T (A0CS) Ультиматив ---
float T_agi               = 2.75;     // множитель AGI
float T_AD                = 1.5;      // множитель AD
float T_Chance            = 0.35;     // шанс
float T_agi2              = 13.0;
float T_b_dmg             = 0.45;     // бонус урона
float T_b_dr              = 0.1;      // DR аура
float T_b_dr2             = 0.3;      // DR аура (харизма вкл.)
float T_d_dr1             = 0.15;     // дебафф DR при атаке
int   T_d_Stack           = 6;        // макс стаков дебаффа
float T_d_dr2             = 0.08;     // дебафф DR за стак (запас)
float T_d_MS              = 0.5;      // дебафф MS

// ==================== Внутренние данные ====================
array<bool> CharizmaOn(10);  // Режим: true=Харизма, false=Эго

// ==================== Q (A0U5) — Казнь ====================

void Q_Start() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit tgt = Jass::LoadUnitHandle(SkillHT, th, 1);

    // Перенаправить ближних юнитов на цель + бафф MS/CapAS
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), 500.0, nil);
    unit u1 = Jass::FirstOfGroup(g);
    while (u1 != nil) {
        Jass::GroupRemoveUnit(g, u1);
        if (Jass::IsUnitAlive(u1) && Jass::IsUnitAlly(u1, Jass::GetOwningPlayer(u))) {
            Jass::IssueTargetOrder(u1, "attack", tgt);
            HAddBuff_MS(u1, 'A0U5', 0, Q_AS_MS, 10.0);
            HAddBuff_CapAS(u1, 'A0U5', Q_AS_MS, 10.0);
        }
        u1 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // 2 ур.: дебафф MS на цель
    if (abilvl >= 2 && target != nil) {
        HAddBuff_MS(target, 'A0U5', 0, -Q_d_MS, 5.0);
    }

    // 3 ур.: перенаправить и бафнуть ближних юнитов
    if (abilvl >= 3 && target != nil) {
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 1, target);
        Jass::TimerStart(t, 0.11, false, @Q_Start);
    }
}

// ==================== W (A0CT) — Огневая поддержка ====================

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil) return;
    int allStats = HGetAllStats(u);

    // TotalAD бафф
    float adBuff = (W_StartAD * 100.0 + float(allStats) / float(W_ThenAD)) / 100.0;
    HAddBuff_TotalAD(target, 'A0CT', adBuff, 10.0);

    // HP% бафф
    float hpBuff = (W_StartHP * 100.0 + float(allStats) / float(W_ThenHP)) / 100.0;
    HAddBuff_HP(target, 'A0CT', 0, hpBuff, 10.0);

    // 2 ур.: CapAS + щит
    if (abilvl >= 2) {
        float casBuff = (W_StartCapAS * 100.0 + float(allStats) / float(W_ThenCapAS)) / 100.0;
        HAddBuff_CapAS(target, 'A0CT', casBuff, 10.0);
        // Щит (HP бафф)
        float shield = Jass::GetUnitMaxLife(target) * W2_MaxHp;
        HAddBuff_HP(target, 'B091', shield, 0, 10.0);
    }

    // 3 ур.: снижение КД цели
    if (abilvl >= 3 && target != u) {
        // Снизить КД всех способностей цели
        // (упрощённо: снижаем КД основных 5 способностей)
        // TODO: реализовать ReduceAllAbilityCooldown для цели
    }
}

// ==================== E (A19R/A0P7) — Харизма / Эго ====================

// Пассивная аура Харизмы (вызывается по таймеру)
void E_CharizmaAura() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(hero));

    if (HIsUnitDead(hero) || !CharizmaOn[pn]) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A19R');
    int allStats = HGetAllStats(hero);

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(hero), Jass::GetUnitY(hero), 700.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && u2 != hero
            && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))) {
            float adBuff = (E_StartH_AD * 100.0 + float(allStats) / float(E_ThenH_AD)) / 100.0;
            HAddBuff_TotalAD(u2, 'A19R', adBuff, 1.05);
            if (abilvl >= 2) {
                float hpBuff = (E_StartHP * 100.0 + float(allStats) / float(E_ThenHP)) / 100.0;
                HAddBuff_HP(u2, 'A19R', 0, hpBuff, 1.05);
                HAddBuff_HPRegen(u2, 'A19R', 0, E_HPRegen, 1.05);
            }
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// Режим Эго: каждый тик даёт TotalAD + CapAS
void E_EgoTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(hero));

    // Если бафф истёк — вернуться в режим Харизмы
    // (упрощённо: проверяем наличие буффа через длительность)
    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A19R');
    int allStats = HGetAllStats(hero);

    float adBuff = (E_StartE_AD * 100.0 + float(allStats) / float(E_ThenE_AD)) / 100.0;
    HAddBuff_TotalAD(hero, 'A19R', adBuff, 1.05);
    if (abilvl >= 2) {
        float casBuff = (E_StartCapAS * 100.0 + float(Jass::GetHeroAgi(hero, true)) / float(E_ThenCapAS)) / 100.0;
        HAddBuff_CapAS(hero, 'A19R', casBuff, 1.05);
    }
}

// E1: Активировать Эго (выключить Харизму)
void E1_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if (!CharizmaOn[pn]) return;

    CharizmaOn[pn] = false;
    int allStats = HGetAllStats(u);

    // Баффы Эго
    float adBuff = (E_StartE_AD * 100.0 + float(allStats) / float(E_ThenE_AD)) / 100.0;
    HAddBuff_TotalAD(u, 'A19R', adBuff, 1.05);
    if (abilvl >= 2) {
        float casBuff = (E_StartCapAS * 100.0 + float(allStats) / float(E_ThenCapAS)) / 100.0;
        HAddBuff_CapAS(u, 'A19R', casBuff, 1.05);
    }

    // 3 ур.: on-attack стаки → CapAS
    if (abilvl >= 3) {
        HSetAbilityCharges(u, 'A19R', 0);
        HRegisterOnAttack(u, 'A19R', @E_OnAttack, 0);
    }

    // Таймер: периодический бафф Эго
    timer t = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::TimerStart(t, 1.0, true, @E_EgoTick);
}

// E2: Активировать Оборону (3 ур., при 45 стаках)
void E2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // Заменить A0P7 → A19R
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0P7', false);
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A19R', true);
    HSetAbilityCharges(u, 'A19R', 0);

    // AOE DR для союзников (E_H_A_Duration тиков)
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveInteger(SkillHT, th, 1, E_H_A_Duration * 11);
    Jass::TimerStart(t, 0.0, false, @E_DefenceTick);
}

void E_DefenceTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    int remaining = Jass::LoadInteger(SkillHT, th, 1) - 1;

    if (remaining <= 0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }
    Jass::SaveInteger(SkillHT, th, 1, remaining);

    // DR бафф ближним союзникам
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(hero), Jass::GetUnitY(hero), 500.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))) {
            HAddBuff_DR(u2, 'A19R', E_H_A_dr, 1.05);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    Jass::TimerStart(t, 0.1, false, @E_DefenceTick);
}

void E_OnAttack(unit attacker, unit target) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(attacker));
    int stacks = HGetAbilityCharges(attacker, 'A19R') + 1;
    HSetAbilityCharges(attacker, 'A19R', stacks);

    // Стакающийся CapAS
    HAddBuff_CapAS(attacker, 'A19F', E_CapAS * float(stacks), 0);

    // При 45 стаках: разблокировать A0P7
    if (stacks >= E_H_Active) {
        Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(attacker), 'A19R', false);
        if (Jass::GetUnitAbility(attacker, 'A0P7') == nil) {
            Jass::UnitAddAbility(attacker, 'A0P7');
        }
        Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(attacker), 'A0P7', true);
    }
}

// ==================== R (A19Z) — Сотрудничество ====================

void R_BuffCheck() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);

    // Подсчёт союзников в радиусе
    int allyCount = 0;
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), float(R_Range), nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (u2 != u && Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(u))) {
            allyCount++;
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);

    // TotalAD бафф
    float ad = R_AD1 + R_AD2 * float(allyCount);
    HAddBuff_TotalAD(u, 'B056', ad, 1.0);
}

void R_OnAttackDeBuff(unit attacker, unit target) {
    // Стакающийся DR дебафф на цели
    // Создаём/обновляем дебафф
    HAddBuff_DR(target, 'B07X', -R_d_AD, 5.0);
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Бафф всех союзников в 2000
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), 2000.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (u2 != u && Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(u))) {
            // Бафф юнита + таймер
            HAddBuff_TotalAD(u2, 'B056', R_AD1, 10.0);
            timer t = Jass::CreateTimer();
            Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u2);
            Jass::TimerStart(t, 1.0, true, @R_BuffCheck);

            // 2 ур.: on-attack дебафф
            if (abilvl >= 2) {
                HRegisterOnAttack(u2, 'B056', @R_OnAttackDeBuff, 10.0);
            }
            // 3 ур.: снижение КД
            if (abilvl >= 3 && u2 != u) {
                // TODO: ReduceAllAbilityCooldown для u2
            }
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// ==================== T (A0CS) — Ультиматив ====================

void T_AuraTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(hero));

    if (HIsUnitDead(hero)) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    // DR аура для союзников в 800
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(hero), Jass::GetUnitY(hero), 800.0, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitAlly(u2, Jass::GetOwningPlayer(hero))) {
            float dr = CharizmaOn[pn] ? (T_b_dr + T_b_dr2) : T_b_dr;
            HAddBuff_DR(u2, 'A0CS', dr, 1.05);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));

    // AS бафф
    HAddBuff_AS(u, 'B03Y', 4.0, 10.1);

    // Аура-таймер
    timer t = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
    Jass::TimerStart(t, 1.0, true, @T_AuraTick);
}

// ==================== Регистрация ====================

void InitPulikSkills() {
    // Инициализация режима Харизмы
    for (int i = 0; i < 10; i++) CharizmaOn[i] = true;

    RegisterAbilityCastHandler('A0U5', @Q_Cast);
    RegisterAbilityCastHandler('A0CT', @W_Cast);
    RegisterAbilityCastHandler('A19R', @E1_Cast);
    RegisterAbilityCastHandler('A0P7', @E2_Cast);
    RegisterAbilityCastHandler('A19Z', @R_Cast);
    RegisterAbilityCastHandler('A0CS', @T_Cast);
    Jass::ConsolePrint("Pulik skills initialized.");
}

} // namespace Pulik
