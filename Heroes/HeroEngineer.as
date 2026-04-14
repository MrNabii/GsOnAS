// ==================== W2 (A0KS) — Привязка маячка ====================

// ============================================================
//  HeroEngineer.as — Инженер (Engineer) — герой N000/N100
// ============================================================
// Скиллы: Q(A0KQ) Ракетный Шквал, W(A0SB) Маячки,
//          E(A0M8) Рудокоп, R(A05N) Мобилизация, T(A01F) Реактор
// Зависит от: HeroHelpers.as, DamageSystem.as, AbilitySystem.as

namespace Engineer {

// --- WW (A0SB) Глыба ---
// WW_MS1, WW_MS2 уже объявлены выше
// --- R (A05N) Мобилизация ---
// Параметры для R объявлены ниже в коде

// ==================== Параметры скиллов ====================

// --- Q (A0KQ) Ракетный Шквал ---
float Q_int               = 1.35;     // множитель INT
float Q_Chance            = 20.0;     // шанс удвоения (2 ур.)
int   Q_MPRes             = 10;       // восстановление маны при удвоении (2 ур.)
int   Q_StackN            = 5;        // стаков для крита (3 ур.)
float Q_Crit              = 2.0;      // множитель крита (3 ур.)
int   Q_DummyId           = 'e00G';   // ID дамми-бомбы
int  Q_AbilityId          = 'A0KQ';   // ID способности для стаков

// ==================== Q (A0KQ) — Ракетный Шквал ====================

void Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);

    int maxRockets = 4;
    float critMul = 1.0;

    // 2 ур.: шанс удвоения
    if (abilvl >= 2 && Jass::GetRandomInt(0, 100) <= int(Q_Chance)) {
        maxRockets = 8;
        HGiveMana(u, float(Q_MPRes));
    }

    // 3 ур.: стаки → крит
    if (abilvl >= 3) {
        int stacks = HGetAbilityCharges(u, 'A0KQ') + 1;
        if (stacks > Q_StackN) {
            critMul = Q_Crit;
            HSetAbilityCharges(u, 'A0KQ', 0);
            // Уничтожить сохранённый таймер
        } else {
            HSetAbilityCharges(u, 'A0KQ', stacks);
            // Создать/обновить таймер очистки стаков
            timer t = Jass::LoadTimerHandle(SkillHT, Jass::GetHandleId(u), 'A0KQ');
            if (t == nil) {t = Jass::CreateTimer(); Jass::SaveTimerHandle(SkillHT, Jass::GetHandleId(u), 'A0KQ', t);}
            Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, u);
            Jass::TimerStart(t, 2.0, false, function() {
                timer t = Jass::GetExpiredTimer();
                unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
                HSetAbilityCharges(u, 'A0KQ', 0);
                Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
                Jass::DestroyTimer(t);
            });
        }
    }

    // Создать ракеты
    for (int i = 0; i < maxRockets; i++) {
        unit rocket = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'e003', x, y, 0.0);
        Jass::UnitApplyTimedLife(rocket, 'BTLF', 2.0);
        RegisterUnit(rocket);
        UnitData@ ud = GetUnitData(rocket);
        if (ud !is null) {
            ud.IsDummy = true;
            ud.dummyDamage = Jass::GetHeroInt(u, true) * Q_int * critMul;
            ud.dmgType = Jass::DAMAGE_TYPE_MAGIC;
        }
        float dist = Jass::GetRandomReal(0.0, 100.0);
        float angle = Jass::GetRandomReal(0.0, 360.0);
        float rx = targX + dist * Jass::MathCosDeg(angle);
        float ry = targY + dist * Jass::MathSinDeg(angle);
        IssuePointOrderEx1(rocket, "attack", rx, ry, Jass::Player(11), 1.0, 1.0); 
    }
}

// --- W (A0SB) Маячки ---
float W_main              = 0.08;     // бонус HP% от маячка
float W_Start             = 0.05;     // стартовый бонус DR
int   W_Then              = 500;      // скейлинг DR от суммы статов
float WQ_int              = 4.5;      // множитель INT для взрыва маячка
float WQ_Stun             = 0.75;     // стан при взрыве
float WQ_dr               = 0.09;     // дебафф DR при взрыве
float WW_MS1              = 0.3;      // бонус MS (1-2 ур.)
float WW_MS2              = 0.6;      // бонус MS (3 ур.)

// ==================== W (A0SB) — Маячки ====================

void W_MayakTick() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit hero = Jass::LoadUnitHandle(SkillHT, th, 0);
    int abilvl = Jass::GetUnitAbilityLevel(hero, 'A0SB');

    if (HIsUnitDead(hero)) {
        // Убить маячки
        for (int i = 1; i <= 4; i++) {
            unit beacon = Jass::LoadUnitHandle(SkillHT, th, i);
            if (beacon != nil) Jass::KillUnit(beacon);
        }
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        return;
    }

    float hx = Jass::GetUnitX(hero);
    float hy = Jass::GetUnitY(hero);
    int angle = Jass::LoadInteger(SkillHT, th, 5) + 1;
    if (angle >= 360) angle = 0;
    Jass::SaveInteger(SkillHT, th, 5, angle);

    // Для каждого маячка: орбита вокруг героя
    for (int i = 1; i <= 4; i++) {
        unit beacon = Jass::LoadUnitHandle(SkillHT, th, i);
        if (beacon == nil || HIsUnitDead(beacon)) continue;

        int beaconState = Jass::LoadInteger(SkillHT, Jass::GetHandleId(hero), 'A0KS' + i); // 0=orbit, 1=attached, 2-free
        if (beaconState == 0) {
            // Орбита
            float bAngle = float(angle + (i - 1) * 90);
            float dist = 100.0;
            float bx = hx + dist * Jass::MathCosDeg(bAngle);
            float by = hy + dist * Jass::MathSinDeg(bAngle);
            Jass::SetUnitX(beacon, bx);
            Jass::SetUnitY(beacon, by);
        } else {
            unit attached = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(hero), 'A0KS' + i);
            if (attached != nil && !HIsUnitDead(attached)) {
                int intt = Jass::GetHeroInt(hero, true);
                UnitData@ ud = GetUnitData(attached);
                UnitStatsData s;
                string str = "" + W_main * 100 + "% от максимального HP";
                float bAngle = float(angle + (i - 1) * 90);
                float dist = 100.0;
                float bx = Jass::GetUnitX(attached) + dist * Jass::MathCosDeg(bAngle);
                float by = Jass::GetUnitY(attached) + dist * Jass::MathSinDeg(bAngle);
                Jass::SetUnitX(beacon, bx);
                Jass::SetUnitY(beacon, by);
                s.Reset();
                s.hpPct = W_main;
                if (abilvl >= 2) {
                    float drBuff = W_Start + float(intt) / float(W_Then) / 100.0;
                    s.resistAll = drBuff;
                    str += ", уменьшение всего урона на " + (drBuff * 100) + "%";
                }
                if (abilvl >= 3) {
                    float mrBuff = W_Start + float(intt) / float(W_Then) / 100.0;
                    s.resistMagic = mrBuff;
                    str += ", уменьшение магического урона на " + (mrBuff * 100) + "%";
                }
                Buff@ b = Buff("Страховка Инженера", str, "ReplaceableTextures\\CommandButtons\\BTNWisp.blp", 'A0KS', 3., s, true, PURGE_NONE, 0, 0, true);
                ud.AddBuff(b, attached);
            }
        }
    }
}

// Добавить условие, что перед стартом не нажимается
void W_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    

    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveTimerHandle(SkillHT, Jass::GetHandleId(u), 'A0SB', t);

    for (int i = 1; i <= 4; i++) {
        unit beacon = Jass::CreateUnit(Jass::GetOwningPlayer(u), 'e005', x, y, 0.0);
        Jass::SaveUnitHandle(SkillHT, th, i, beacon);
        Jass::SaveInteger(SkillHT, th, 'A0KS' + i, 0); // state=orbit
    }
    Jass::SaveInteger(SkillHT, th, 5, 0); // angle

    // Отключить кнопку W до окончания
    Jass::DisableAbility(abil, true, true);
    Jass::UnitAddAbility(u, 'A0KS'); 
    //Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), 'A0SB', false);

    Jass::TimerStart(t, 0.02, true, @W_MayakTick);
}


//*A0KS
void W2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    if(!Jass::IsUnitHero(target)) {
        return;
    }
    timer t = Jass::LoadTimerHandle(SkillHT, Jass::GetHandleId(u), 'A0SB');
    for(int i = 1; i <= 4; i++) {
        unit beacon = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), i);
        if(beacon != nil && (Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), 'A0KS' + i) == 0 || Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), 'A0KS' + i) == 2)) {
            Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(u), 'A0KS' + i, target);
            Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), 'A0KS' + i, 1); // state=attached
            break;
        }
    }
}

void W2Q_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    if(Jass::GetUnitCurrentMana(GoblinUnit[pn]) < 3) return;
    Jass::SetUnitCurrentMana(GoblinUnit[pn], Jass::GetUnitCurrentMana(GoblinUnit[pn]) - 3);
    Jass::StartAbilityCooldown(abil, 15.0);
    Jass::DestroyEffect(Jass::AddSpecialEffect("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", Jass::GetUnitX(u), Jass::GetUnitY(u)));
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), 450.0, nil);
    ForGroupAction(g, u, function(unit source, unit target) {
        int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(source));
        if (Jass::IsUnitAlive(target) && Jass::IsUnitEnemy(target, Jass::GetOwningPlayer(source))) {
            HDealSpellDmg(source, target, float(Q_Chance) * Q_Chance / 100.0);
        }
        if(Jass::GetUnitAbilityLevel(GoblinUnit[pn], 'A024') >= 2) {
            StunUnit(target, WQ_Stun);
        }
        if(Jass::GetUnitAbilityLevel(GoblinUnit[pn], 'A024') >= 3) {
            // 'attached' is not defined in this scope, so skip or replace with target
            UnitData@ ud = GetUnitData(target);
            UnitStatsData s;
            s.Reset();
            s.resistAll = WQ_dr;
            Buff@ b = Buff("Взрыв маячка", "Увеличивает получаемый урон на " + (WQ_dr * 100) + "%", "ReplaceableTextures\\CommandButtons\\BTNWisp.blp",
            'A0KS', 1., s, false, PURGE_NONE, 0, 0, false);
            ud.AddBuff(b, target);
        }
    });
    Jass::DestroyGroup(g);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(u, 'A024'), 15.0);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(u, 'A025'), 10.0);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(u, 'A02F'), 10.0);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(GoblinUnit[pn], 'A0SB'), 10.0);
    Jass::StartAbilityCooldown(Jass::GetUnitAbility(GoblinUnit[pn], 'A0KS'), 10.0);
}
float tempdist = 0.0;
float mindist = 90000.0;
unit tempUnit = nil;
void W2W_Cast(unit u, int abilId, int abillvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    mindist = 90000.0;
    tempUnit = nil;
    ForGroupAction(Ores, u, function(unit source, unit target) {
        tempdist = Jass::MathDistanceBetweenPoints(Jass::GetUnitX(source), Jass::GetUnitY(source), Jass::GetUnitX(target), Jass::GetUnitY(target));
        if(tempdist < mindist) {
            mindist = tempdist;
            tempUnit = target;
        }
    });
    if(tempUnit != nil) {
        Jass::IssueTargetOrder(u, "move", tempUnit);
    }
}


void W2E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    timer t = Jass::LoadTimerHandle(SkillHT, Jass::GetHandleId(GoblinUnit[pn]), 'A0SB');
    for(int i = 1; i <= 4; i++) {
        if(u == Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), i)) {
            Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(GoblinUnit[pn]), 'A0KS' + i, nil);
            Jass::SaveInteger(SkillHT, Jass::GetHandleId(GoblinUnit[pn]), 'A0KS' + i, 0); // state=free
            break;
        }
    }
}

// --- E (A0M8) Рудокоп ---
float E_ChanceStart       = 4.0;      // шанс
int   E_ChanceLuck        = 10;       // скейлинг от удачи
float E_CapAS             = 0.5;      // бонус CapAS
float E_LessDmgGliba      = 0.2;     // снижение урона
float E_Stun              = 0.2;      // стан при атаке
float E_dr1               = 0.1;      // бонус DR (2 ур.)
float E_dr2               = 0.15;     // бонус DR (3 ур.)
float E_int               = 1.35;     // множитель INT для on-attack урона (2 ур.)

void E_OnAttack(unit attacker, unit target) {
    StunUnit(target, E_Stun);
    // 2 ур.: бонусный спелл-урон
    unit hero = attacker;
    Jass::ConsolePrint("\nE_OnAttack triggered by " + Jass::GetUnitName(attacker) + " on " + Jass::GetUnitName(target));
    Jass::ConsolePrint("\nE_OnAttack AbilityLevel: " + Jass::GetUnitAbilityLevel(attacker, 'A0M8'));
    if (Jass::GetUnitAbilityLevel(hero, 'A0M8') >= 2) {
        float dmg = float(Jass::GetHeroInt(hero, true)) * E_int;
        HDealSpellDmg(hero, target, dmg);
    }
}

//A0M8
void E_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil){
    UnitData@ ud = GetUnitData(u);
    UnitStatsData s;
    string str;
    s.Reset();
    s.attackSpeedPct = E_CapAS;
    str = "Увеличивает процент скорости атаки на " + (E_CapAS * 100) + "%";
    if(abilvl == 2) {
        s.resistAll = E_dr1;
        str += ", уменьшает получаемый урон на " + (E_dr1 * 100) + "%";
    }
    if(abilvl == 3) {
        s.resistAll = E_dr2;
        str += ", уменьшает получаемый урон на " + (E_dr2 * 100) + "%";
    }
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), 500.0, nil);
    Jass::GroupRemoveUnit(g, u); // исключить себя из группы
    ForGroupAction(g, u, function(unit source, unit target) {
        if (Jass::IsUnitAlly(target, Jass::GetOwningPlayer(source)) && Jass::IsUnitInGroup(target, Goblinzz)) {
            UnitData@ ud = GetUnitData(source);
            UnitStatsData s;
            string str;
            int abilvl = Jass::GetUnitAbilityLevel(source, 'A0M8');
            s.Reset();
            s.attackSpeedPct = E_CapAS;
            str = "Увеличивает процент скорости атаки на " + (E_CapAS * 100) + "%";
            if(abilvl == 2) {
                s.resistAll = E_dr1;
                str += ", уменьшает получаемый урон на " + (E_dr1 * 100) + "%";
            }
            if(abilvl == 3) {
                s.resistAll = E_dr2;
                str += ", уменьшает получаемый урон на " + (E_dr2 * 100) + "%";
            }
            Buff@ b = Buff("Рудокоп", str, "ReplaceableTextures\\CommandButtons\\BTNGatherGold_Vol3.blp",
            'A0M8', 5., s, true, PURGE_NONE, 0, 0, true);
            ud.AddBuff(b, target);
        }
    });
    Jass::DestroyGroup(g);
    Buff@ b = Buff("Рудокоп", str, "ReplaceableTextures\\CommandButtons\\BTNGatherGold_Vol3.blp",
            'A0M8', 5., s, true, PURGE_NONE, 0, 0, true);
    ud.AddBuff(b, u);
    // On-attack колбэк
    HRegisterOnAttack(u, 'A0M8', @E_OnAttack, 5.1);
}

// --- R (A05N) Мобилизация ---
int   R_agr_Range         = 500;      // радиус
int   R_Stack             = 10;       // стаков ярости (2 ур.)
int   R_Stack2            = 20;       // стаков ярости (3 ур.)
float R_int               = 7.0;      // множитель INT
float R_Stun              = 0.6;      // стан

// ==================== R (A05N) — Мобилизация ====================

void R_Agr() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);

    // Проверить бафф B092
    if (Jass::GetUnitAbilityLevel(u, 'B092') <= 0) {
        // Восстановить масштаб
        float scale = Jass::LoadReal(SkillHT, th, 2);
        Jass::SetUnitScale(u, scale, scale, scale);
        Jass::FlushChildHashtable(SkillHT, th);
        Jass::DestroyTimer(t);
        HRemoveOnDamage(u, 'A0M8');
        return;
    }
    UnitData@ ud = GetUnitData(u);
    UnitStatsData s;
    s.Reset();
    s.moveSpeedPct = -1.0;
    Buff@ b = Buff("Живой щит", "Уменьшает атаку Врагов на 35%, но уменьшает скорость передвижения на 100%", "ReplaceableTextures\\CommandButtons\\BTNSlow.blp",
    'A05N', 1., s, false, PURGE_NONE, 0, 0, false);
    ud.AddBuff(b, u);

    // Таунт: заставить врагов атаковать героя
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(u), Jass::GetUnitY(u), R_agr_Range, nil);
    ForGroupAction(g, u, function(unit source, unit target) {
        if (Jass::IsUnitAlive(target) && Jass::IsUnitEnemy(target, Jass::GetOwningPlayer(source))) {
            UnitStatsData debuff;
            debuff.Reset();
            debuff.damagePct = -0.35;
            Buff@ b2 = Buff("Провокация Инженера", "Заставляет атаковать Инженера, и уменьшает атаку на 35%", "ReplaceableTextures\\CommandButtons\\BTNSlow.blp",
            'A05N', 1., debuff, false, PURGE_NORMAL, 0, 0, true);
            GetUnitData(target).AddBuff(b2, target);
            // Дебафф AD
            Jass::IssueTargetOrder(target, "attack", source);
        }
    });
}

void R_GiveStack() {
    timer t = Jass::GetExpiredTimer();
    unit u = Jass::LoadUnitHandle(SkillHT, Jass::GetHandleId(t), 0);
    HSetAbilityCharges(u, 'A05N', 1);
    Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(t));
    Jass::DestroyTimer(t);
}

void R_OnDamage(unit source, unit target) {
    // target = наш герой, получающий урон
    // 2 ур.: стак ярости при получении урона
    int ch = HGetAbilityCharges(target, 'A05N');
    if (ch == 0) {
        timer t = Jass::CreateTimer();
        Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t), 0, target);
        Jass::TimerStart(t, 0.33, false, @R_GiveStack);
    }
}

void R_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    // Замедление MS (immobilize)
    HAddBuff_MS(u, 'A05N', 0, -1.0, 0);

    // Увеличить масштаб
    float curScale = 1.0; // Исходный масштаб
    Jass::SetUnitScale(u, curScale * 1.5, curScale * 1.5, curScale * 1.5);

    // Аура-таймер
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveReal(SkillHT, th, 2, curScale); // сохранить масштаб
    Jass::TimerStart(t, 0.5, true, @R_Agr);

    // 2 ур.: on-damage стаки ярости
    if (abilvl >= 2) {
        HRegisterOnDamage(u, 'A0M8', @R_OnDamage, 0);
    }
}

// --- T (A01F) Реактор ---
float T_AD                = 0.65;     // бонус AD%
float T_AuraDr            = 0.15;     // DR аура
float T_AuraAllStatsStart = 0.03;     // бонус всех статов
int   T_AuraAllStatsThen  = 300;      // скейлинг от суммы статов
float T_AuraReg           = 150;     // бонус HP regen
float T_Duration          = 15.0;     // длительность бонуса T (3 ур.)

// ==================== T (A01F) — Реактор ====================

void T_End() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int abilTypeId = Jass::LoadInteger(SkillHT, th, 1);
    // Восстановить доступность основной способности
    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), abilTypeId, true);
    Jass::UnitRemoveAbility(u, 'A01A');
    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void T_Start() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    unit u = Jass::LoadUnitHandle(SkillHT, th, 0);
    int abilTypeId = Jass::LoadInteger(SkillHT, th, 1);
    int abilvl = Jass::GetUnitAbilityLevel(u, abilTypeId);
    UnitStatsData auraStats;
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    string desc = "";
    float AllStatsPrc = T_AuraAllStatsStart + float(Jass::GetHeroStr(u, true) + Jass::GetHeroAgi(u, true) + Jass::GetHeroInt(u, true)) / float(T_AuraAllStatsThen) / 100.0;
    auraStats.Reset();
    auraStats.strengthPct = AllStatsPrc;
    auraStats.intelligencePct = AllStatsPrc;
    auraStats.agilityPct = AllStatsPrc;
    desc += ", увеличивает все характеристики на " + auraStats.strengthPct * 100 + "% от суммы характеристик";
    if(abilvl >= 2) {
        auraStats.resistAll = T_AuraDr;
        desc += ", уменьшает получаемый урон на " + (T_AuraDr * 100) + "%";
        auraStats.hpRegen = T_AuraReg;
        desc += ", восстанавливает " + T_AuraReg + " HP в секунду";
    }
    ApplyAuraToNearby(BunkerUnit[pn], "Аура Бункера", desc,
        "ReplaceableTextures\\CommandButtons\\BTNTrollBurrow.blp",
        'A01F', auraStats, true, 600.0, PURGE_NONE, 1);

    Jass::SetPlayerAbilityAvailable(Jass::GetOwningPlayer(u), abilTypeId, false);
    Jass::UnitAddAbility(u, 'A01A');
    timer t2 = Jass::CreateTimer();
    Jass::SaveUnitHandle(SkillHT, Jass::GetHandleId(t2), 0, u);
    Jass::SaveInteger(SkillHT, Jass::GetHandleId(t2), 1, abilTypeId);
    Jass::TimerStart(t2, T_Duration, false, @T_End);

    Jass::FlushChildHashtable(SkillHT, th);
    Jass::DestroyTimer(t);
}

void T_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    timer t = Jass::CreateTimer();
    int th = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(SkillHT, th, 0, u);
    Jass::SaveInteger(SkillHT, th, 1, Jass::GetAbilityTypeId(abil));
    Jass::TimerStart(t, 0.01, false, @T_Start);
}

void T2_Cast(unit u, int abilId, int abilvl, unit target, float targX, float targY, ability abil) {
    int pn = Jass::GetPlayerId(Jass::GetOwningPlayer(u));
    UnitData@ ud = GetUnitData(u);
    UnitStatsData s;
    string str;
    s.Reset();
    s.attackSpeedPct = 2.;
    str = "Увеличивает процент скорости атаки на " + (E_CapAS * 100) + "%";
    Buff@ b = Buff("Рудокоп", str, "ReplaceableTextures\\CommandButtons\\BTNFire.blp",
    'A01A', 5., s, true, PURGE_NONE, 0, 0, true);
    ud.AddBuff(b, GoblinUnit[pn]);
    Jass::UnitApplyTimedLife(GoblinUnit[pn], 'BTLF', 5.1);
}

// ==================== Регистрация ====================

// ==================== Описания скиллов (AS) ====================
void InitEngineerSkillTexts() {
    // Q (A0KQ) — Ракетный Шквал
    Jass::SetAbilityBaseStringLevelFieldById('A0KQ', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Инженер выпускает 4 ракеты, каждая из которых наносит магический урон врагам.\n"
        + (Q_int * 100) + "% от РАЗУМА.");

    Jass::SetAbilityBaseStringLevelFieldById('A0KQ', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Инженер выпускает 4 ракеты, каждая из которых наносит магический урон врагам. "
        + Q_Chance + "% шанс пустить дополнительный пак ракеток при касте и восстановить " + Q_MPRes + " МП.\n"
        + (Q_int * 100) + "% от РАЗУМА.");

    Jass::SetAbilityBaseStringLevelFieldById('A0KQ', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Инженер выпускает 4 ракеты, каждая из которых наносит магический урон врагам. "
        + Q_Chance + "% шанс пустить дополнительный пак ракеток при касте и восстановить " + Q_MPRes + " МП. Дальность увеличена. Каждый каст скилла дает стак, до " + Q_StackN + " стаков. Спадает за 2 сек. При достижений " + Q_StackN + " стака, следующая пачка нанесет в " + Q_Crit + " раза больше урона.\n"
        + (Q_int * 100) + "% от РАЗУМА.");

    // W (A0SB) — Маячки
    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Инженер создает 4 маячки, которые постоянно находятся возле инженера.\n"
        + "Сцепление маячка (W)\n"
        + "Использование по цели закрепляет маячка у цели, увеличивая им Хп на " + (W_main * 100) + "%.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Инженер создает 4 маячки, которые постоянно находятся возле инженера.\n"
        + "Сцепление маячка (W)\n"
        + "Использование по цели закрепляет маячка у цели, увеличивая им Хп на " + (W_main * 100) + "% и др на (" + (W_Start * 100) + "+ Интелект/" + W_Then + ")%.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Инженер создает 4 маячки, которые постоянно находятся возле инженера.\n"
        + "Сцепление маячка (W)\n"
        + "Использование по цели закрепляет маячка у цели, увеличивая им Хп на " + (W_main * 100) + "%, др на (" + (W_Start * 100) + " + Интелект/" + W_Then + ")%, маг резист на (" + (W_Start * 100) + " + Интелект/" + W_Then + ")%.");

    // WQ — Взрыв маячка (A0SB, 2-я способность или отдельная)
    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Взрывает врагов вокруг и наносит магический урон. После взрыва, все скиллы не доступны в течений 10 секунд.\n\n"
        + (WQ_int * 100) + "% от РАЗУМА\n\nПерезарядка: 15 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Взрывает врагов вокруг и наносит магический урон и станит на " + WQ_Stun + " сек. После взрыва, все скиллы не доступны в течений 10 секунд.\n\n"
        + (WQ_int * 100) + "% от РАЗУМА\n\nПерезарядка: 15 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Взрывает врагов вокруг и наносит магический урон и станит на " + WQ_Stun + " сек, увеличивает получаемый урон на " + (WQ_dr * 100) + "%. После взрыва, все скиллы не доступны в течений 10 секунд.\n\n"
        + (WQ_int * 100) + "% от РАЗУМА\n\nПерезарядка: 15 секунд.");

    // WW — Глыба (A0SB, 3-я способность или отдельная)
    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Начинает идти к сторону глыбы и выбирает цвет глыбы. \n\nПерезарядка: 10 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Начинает идти к сторону глыбы и выбирает цвет глыбы. Увеличивая скорость бега на " + (WW_MS1 * 100) + "%.\n    \nПерезарядка: 15 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0SB', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Начинает идти к сторону глыбы и выбирает цвет глыбы. Увеличивая скорость бега на " + (WW_MS1 * 100) + "%.\n\nПерезарядка: 15 секунд.");

    // E (A0M8) — Рудокоп
    Jass::SetAbilityBaseStringLevelFieldById('A0M8', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00(Пассив):\nДобывает руду с глыб, а также с шансом в " + E_ChanceStart + "*(1+удача/" + E_ChanceLuck + ")% выбивает рандомный самоцвет.\n(Актив): \nУвеличивает кап скорости атаки на " + (E_CapAS * 100) + "% и увеличивает точность Инженера, нанося на " + (E_LessDmgGliba * 100) + "% меньше урона по глыбам. А так же, каждый удар инженера станит цели на " + E_Stun + " сек. Действует 5 секунд. \n\nПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0M8', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00(Пассив):\nДобывает руду с глыб, а также с шансом в " + E_ChanceStart + "*(1+удача/" + E_ChanceLuck + ")% выбивает рандомный самоцвет.\n(Актив): \nУвеличивает кап скорости атаки на " + (E_CapAS * 100) + "% и увеличивает точность Инженера, нанося на " + (E_LessDmgGliba * 100) + "% меньше урона по глыбам. А так же, каждый удар инженера станит цели на " + E_Stun + " сек, наносит магический урон и уменьшает получаемый урон Инженера на " + (E_dr1 * 100) + "%. Действует 5 секунд.\n\n" + (E_int * 100) + "% от РАЗУМА\n\nПерезарядка: 20 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A0M8', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00(Пассив):\nДобывает руду с глыб, а также с шансом в " + E_ChanceStart + "*(1+удача/" + E_ChanceLuck + ")% выбивает рандомный самоцвет.\n(Актив): \nУвеличивает кап скорости атаки на " + (E_CapAS * 100) + "% и увеличивает точность Инженера, нанося на " + (E_LessDmgGliba * 100) + "% меньше урона по глыбам. А так же, каждый удар инженера станит цели на " + E_Stun + " сек, наносит магический урон и уменьшает получаемый урон вокруг на " + (E_dr2 * 100) + "%. Действует 5 секунд. \n\n" + (E_int * 100) + "% от РАЗУМА\n\nПерезарядка: 20 секунд.");

    // R (A05N) — Мобилизация
    Jass::SetAbilityBaseStringLevelFieldById('A05N', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Инженер правит свой экзоскелет, делая его массивным, устрашающим и провакокационным, уменьшая атаку врагам и агря их на себя. Но нерасчитал свои возможности, что даже с места сдвинутся теперь не может.");

    Jass::SetAbilityBaseStringLevelFieldById('A05N', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Инженер правит свой экзоскелет, делая его массивным, устрашающим и провакокационным, уменьшая атаку врагам и агря их на себя. Экзоскелет имеет дополнительную функцию создавать барьер раз в 0.33 секунд, уменьшающий полученный урон. А также получает меньше урона от миников. Но нерасчитал свои возможности, что даже с места сдвинутся теперь не может.");

    Jass::SetAbilityBaseStringLevelFieldById('A05N', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Инженер правит свой экзоскелет, делая его массивным, устрашающим и провакокационным, уменьшая атаку врагам и агря их на себя. Экзоскелет имеет дополнительную функцию создавать барьер раз в 0.33 секунд, уменьшающий полученный урон. А также получает меньше урона от миников. Но нерасчитал свои возможности, что даже с места сдвинутся теперь не может.\nИнженер добавил функцию экстренного ремонтного набора, который полностью восстанавливает хп Инженеру, но набор восстанавливается 120 секунд");

    // T (A01F) — Реактор
    Jass::SetAbilityBaseStringLevelFieldById('A01F', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 0,
        "|cff00ff00Создает бункер на 20 секунд. Каждый выстрел бункера наносит физический урон. Скорость выстрелов бункера зависит от капа скорости выстрелов Инженера. Выстрел бункера считается, как выстрел Инженера, что прокает пассивки при атаке. \n(Аура): Уменьшение получаемого урона на " + (T_AuraDr * 100) + "%, увеличивает все статы на (" + (T_AuraAllStatsStart * 100) + "+РАЗУМ/" + T_AuraAllStatsThen + ")%\n\n" + (T_AD * 100) + "% от АТАКИ\n\nПерезарядка: 60 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A01F', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1,
        "|cff00ff00Создает бункер на 20 секунд. Каждый выстрел бункера наносит физический урон. Скорость выстрелов бункера зависит от капа скорости выстрелов Инженера. Выстрел бункера считается, как выстрел Инженера, что прокает пассивки при атаке. \n(Аура): Уменьшение получаемого урона на " + (T_AuraDr * 100) + "%, увеличивает все статы на (" + (T_AuraAllStatsStart * 100) + "+РАЗУМ/" + T_AuraAllStatsThen + ")%, восстановление " + T_AuraReg + "% от МАКС хп в секунду.\n\n" + (T_AD * 100) + "% от АТАКИ\n\nПерезарядка: 60 секунд.");

    Jass::SetAbilityBaseStringLevelFieldById('A01F', Jass::ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 2,
        "|cff00ff00Создает бункер на 20 секунд. Каждый выстрел бункера наносит физический урон. Скорость выстрелов бункера зависит от капа скорости выстрелов Инженера. Выстрел бункера считается, как выстрел Инженера, что прокает пассивки при атаке. \n(Аура): Уменьшение получаемого урона на " + (T_AuraDr * 100) + "%, увеличивает все статы на (" + (T_AuraAllStatsStart * 100) + "+РАЗУМ/" + T_AuraAllStatsThen + ")%, восстановление " + T_AuraReg + "% от МАКС хп в секунду.\nПри использований скилл временно заменяется на другой, активация которого увеличит скорость атаки бункера в 2 раза, но бункер сломается через 3 секунды.\n\n" + (T_AD * 100) + "% от АТАКИ\n\nПерезарядка: 60 секунд.");
}

void InitEngineerSkills() {
    RegisterAbilityCastHandler('A0KQ', @Q_Cast);
    RegisterAbilityCastHandler('A0SB', @W_Cast);
    RegisterAbilityCastHandler('A0KS', @W2_Cast);
    RegisterAbilityCastHandler('A024', @W2Q_Cast);
    RegisterAbilityCastHandler('A025', @W2W_Cast);
    RegisterAbilityCastHandler('A02F', @W2E_Cast);
    RegisterAbilityCastHandler('A0M8', @E_Cast);
    RegisterAbilityCastHandler('A05N', @R_Cast);
    RegisterAbilityCastHandler('A01F', @T_Cast);
    RegisterAbilityCastHandler('A01A', @T2_Cast);
    InitEngineerSkillTexts();
    Jass::ConsolePrint("Engineer skills initialized.");
}

} // namespace Engineer
