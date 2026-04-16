// ============================================================
//  HeroSniper.as — Снайпер — герой H004/H104
// ============================================================
// Скиллы: Q(A0TU) В яблочко!, W(A0TV) Метка, E(A0UG) Стрельба (пассив),
//          R(A0TW) Освещение, T(A0UK) Ультиматив
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Sniper {

// ==================== Параметры скиллов ====================

// --- Q (A0TU) В яблочко! ---
float Q_AD                = 5.0;      // множитель AD
float Q_Stun              = 0.75;     // стан (3 ур.)
float Q_AD2               = 0.75;     // периодический урон (3 ур.)

// --- W (A0TV) Метка ---
float W_d_Start_pr        = 0.04;     // стартовый дебафф PR
float W_d_Then_prS        = 200.0;
float W_d_Then_pr         = 1.0 / 200.0; // скейлинг от agi
float W_agi               = 5.0;
float W_d_dr              = 2.0;      // множитель для дополнительного дебаффа

// --- E (A0UG) Стрельба (пассив) ---
float E_UpAD              = 2.5;      // бонус AD
float E_Stun              = 0.2;
float E_ThenAD            = 5.0;
float E_AD                = 3.0;

// --- R (A0TW) Освещение ---
float R_Range1            = 800.0;
float R_Range2            = 1000.0;
float R_PD                = 0.15;     // бонус PhysAD
float R_Q_Buff            = 1.5;      // бонус урона Q по помеченным
float R_d_Duration        = 2.0;

// --- T (A0UK) Ультиматив ---
float T_Stun1             = 4.0;
float T_Stun2             = 6.0;
float T_AD                = 8.0;
float T_agi               = 35.0;
float T_AD2               = 0.95;
float T_mr_dr             = 0.03;

// ==================== Q (A0TU) — В яблочко! ====================

void Q_VistrelHit() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    float damage = Jass::LoadReal(SkillHT, th, 0);
    float damage2 = Jass::LoadReal(SkillHT, th, 3);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 1);
    unit p = Jass::LoadUnitHandle(SkillHT, th, 2);
    Jass::DestroyTimer(t);
    Jass::FlushChildHashtable(SkillHT, th);

    // Если цель помечена (B07W) и R >= 3 — бонус урона
    if (Jass::GetUnitAbilityLevel(p, 'B07W') > 0 && Jass::GetUnitAbilityLevel(u, 'A0TW') >= 3) {
        damage = damage * R_Q_Buff;
    }

    // Если цель помечена меткой (B03H) и W >= 3 — доп. замедление + PR дебафф
    if (Jass::GetUnitAbilityLevel(p, 'B03H') > 0 && Jass::GetUnitAbilityLevel(u, 'A0TV') >= 3) {
        HAddBuff_MS(p, 'A0TV', 0, -0.7, 2.0);
        float prDebuff = -(W_d_Start_pr + W_d_Then_pr * float(Jass::GetHeroAgi(u, true))) * W_d_dr;
        HAddBuff_PR(p, 'A0TV', prDebuff, 5.0);
    }

    HDealPhysDmg(u, p, damage);

    // 3 ур.: стан + периодический физ. урон
    if (Jass::GetUnitAbilityLevel(u, 'A0TU') >= 3) {
        StunUnit(p, Q_Stun);
        // Периодический урон (упрощённо: одноразовый через таймеры)
        timer t2 = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t2), 0, u);
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t2), 1, p);
        Jass::SaveReal(SkillHT, Jass::GetHandleId(t2), 2, damage2);
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t2), 3, 2); // 2 тика
        Jass::TimerStart(t2, 1.0, true, @Q_PeriodicDmg);
    }
}

void Q_PeriodicDmg() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    unit p = Jass::LoadUnitHandle(SkillHT, th, 1);
    float dmg = Jass::LoadReal(SkillHT, th, 2);
    int ticks = Jass::LoadInteger(SkillHT, th, 3) - 1;

    if (!HIsUnitDead(p)) HDealPhysDmg(u, p, dmg);

    if (ticks <= 0) {
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
    } else {
        Jass::SaveInteger(SkillHT, th, 3, ticks);
    }
}

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil) return;
    float damage = HGetUnitAD(u) * Q_AD;
    float damage2 = HGetUnitAD(u) * Q_AD2;

    // Создать снаряд-дамми
    unit dummy = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'hdum', Jass::GetUnitX(u), Jass::GetUnitY(u), 0.0);
    Jass::UnitAddAbility(dummy, 'A0B8');
    Jass::UnitApplyTimedLife(dummy, 'BTLF', 2.0);
    Jass::IssueTargetOrder(dummy, "thunderbolt", target);

    // Таймер для попадания (задержка = дистанция / скорость)
    float dist = GetUnitDistance(u, target);
    float delay = dist / 6000.0;
    if (delay < 0.01) delay = 0.01;

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveReal(SkillHT, th, 0, damage);
    Jass::SaveReal(SkillHT, th, 3, damage2);
    Jass::SaveUnitHandle(SkillHT, th, 1, u);
    Jass::SaveUnitHandle(SkillHT, th, 2, target);
    Jass::TimerStart(t, delay, false, @Q_VistrelHit);
}

// ==================== W (A0TV) — Метка ====================

void W_DeActivate() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u2 = Jass::LoadUnitHandle(SkillHT, th, 1);
    // Снять видимость (упрощённо: не реализуемо через AS без UnitShareVision)
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if (target == nil) return;
    float prDebuff = -(W_d_Start_pr + W_d_Then_pr * float(Jass::GetHeroAgi(u, true)));
    HAddBuff_PR(target, 'A0TV', prDebuff, 20.0);

    // 2 ур.: расшарить видимость для всех игроков
    if (abilvl >= 2) {
        for (int i = 0; i < 10; i++) {
            Jass::UnitShareVision(target, Jass::Player(i), true);
        }
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 1, target);
        Jass::TimerStart(t, 20.0, false, @W_DeActivate);
    }
}

// ==================== R (A0TW) — Освещение ====================

void R_DisableVision() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    player p = Jass::LoadPlayerHandle(SkillHT, th, 0);
    for (int i = 0; i < 9; i++) {
        Jass::SetPlayerAlliance(p, Jass::Player(i), Jass::ALLIANCE_SHARED_VISION, false);
    }
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    player p = Jass::GetOwningPlayer(u);
    // Расшарить видимость
    for (int i = 0; i < 9; i++) {
        Jass::SetPlayerAlliance(p, Jass::Player(i), Jass::ALLIANCE_SHARED_VISION, true);
    }
    timer t = Jass::CreateTimer();
    Jass::SavePlayerHandle(SkillHT, Jass::GetHandleId(t), 0, p);
    Jass::TimerStart(t, 10.0, false, @R_DisableVision);

    // 2 ур.: бонус PhysAD + дебафф врагов
    if (abilvl >= 2) {
        HAddBuff_PhysAD(u, 'A0TW', R_PD, 10.0);
        float range = (abilvl >= 3) ? R_Range2 : R_Range1;
        group g = Jass::CreateGroup();
        Jass::GroupEnumUnitsInRange(g, targX, targY, range, nil);
        unit u2 = Jass::FirstOfGroup(g);
        while (u2 != nil) {
            Jass::GroupRemoveUnit(g, u2);
            if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(u))) {
                Jass::UnitShareVision(u2, Jass::GetOwningPlayer(u), true);
            }
            u2 = Jass::FirstOfGroup(g);
        }
        Jass::DestroyGroup(g);
    }
}

// ==================== Регистрация ====================

void InitSniperSkills() {
    RegisterAbilityCastHandler('A0TU', @Q_Cast);
    RegisterAbilityCastHandler('A0TV', @W_Cast);
    RegisterAbilityCastHandler('A0TW', @R_Cast);
    // E(A0UG) — пассив, не регистрируется как каст
    // T(A0UK) — TODO: сложный ультиматив
    Debug("InitSniperSkills", "Sniper skills initialized.");
}

} // namespace Sniper
