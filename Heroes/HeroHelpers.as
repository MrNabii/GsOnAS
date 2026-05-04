// ============================================================
//  HeroHelpers.as — Общие утилиты для скиллов героев
// ============================================================
// Зависит от: DamageSystem.as (DealDamage), API/General.as (StunUnit),
//             UnitStats.as (UnitData, GetUnitData, Buff)

// Хэштейбл для данных скиллов (таймеры, промежуточные значения)
hashtable SkillHT = Jass::InitHashtable();

// ===================== Получение статов =====================

void IssuePointOrderEx1(unit u, string order, float x, float y, player p, float lifetime, float ownertime)
{
    unit dummy;
    int abi_to_add = 'Apiv';
    if (order == "attack")
    {
        abi_to_add = 'Avul';
    }
    dummy = Jass::CreateUnit(p, 'e013', x, y, 0.0);
    Jass::UnitAddAbility(dummy, abi_to_add);
    Jass::SetUnitX(dummy, x);
    Jass::SetUnitY(dummy, y);
    Jass::SetUnitCurrentSight(dummy, 120);
    Jass::UnitShareVision(dummy, Jass::GetOwningPlayer(u), true);
    Jass::UnitApplyTimedLife(dummy, 'BFig', lifetime);
    Jass::UnitShareVision(dummy, Jass::GetOwningPlayer(u), true);
    Jass::IssueTargetOrder(u, order, dummy);
}

float GetUnitStatePercent( unit whichUnit, unitstate whichState, unitstate whichMaxState )
{
    float maxValue = Jass::GetUnitState( whichUnit, whichMaxState );

    if ( whichUnit == nil || maxValue == 0 )
    {
        return .0f;
    }

    float value = Jass::GetUnitState( whichUnit, whichState );

    return value / maxValue * 100.0f;
}

int CountUnitInGroupOfPlayer( player p, int id, group g = GroupFilter )
{
    int count = 0;

    Jass::GroupClear( g );
    Jass::GroupEnumUnitsOfPlayer( g, p, nil );

    for ( int i = 0; i < Jass::GroupGetCount( g ); i++ )
    {
        unit u = Jass::GroupGetUnitByIndex( g, i );

        if ( Jass::IsUnitAlive( u ) && Jass::GetUnitTypeId( u ) == id )
        {
            count++;
        }
    }

    Jass::GroupClear( g );

    return count;
}

void GroupEnumUnitsInLine( group g, float x, float y, float angle, float dist, float aoe, group gFilter = GroupFilter )
{
    Jass::GroupClear( g );
    Jass::GroupClear( gFilter );
    for ( float moved = .0f; moved < dist; moved += aoe )
    {
        Jass::GroupEnumUnitsInRange( gFilter, x, y, aoe, nil );

        for ( unit u = Jass::GroupForEachUnit( gFilter ); u != nil; u = Jass::GroupForEachUnit( gFilter ) )
        {
            if ( !Jass::IsUnitInGroup( u, g ) )
            {
                Jass::GroupAddUnit( g, u );
            }
        }

        x = Jass::MathPointProjectionX( x, angle, aoe );
        y = Jass::MathPointProjectionY( y, angle, aoe );
    }
}

void AddBuffTimed( unit u, uint bid, float time, bool isAdd = true )
{
    if ( Jass::IsUnitDead( u ) ) { return; }

    buff buf = Jass::GetUnitBuff( u, bid );
    float prevTime = .0f;

    if ( buf == nil )
    {
        buf = Jass::UnitAddBuffById( u, bid );
    }
    else
    {
        prevTime = Jass::GetBuffRemainingDuration( buf );
    }

    Jass::SetBuffRemainingDuration( buf, isAdd ? prevTime + time : time );
}

void StunUnit( unit u, float time )
{
    AddBuffTimed( u, 'BPSE', time );
}

float GetUnitDistance( unit source, unit target )
{
    return Jass::MathDistanceBetweenPoints( Jass::GetUnitX( source ), Jass::GetUnitY( source ), Jass::GetUnitX( target ), Jass::GetUnitY( target ) );
}

float HGetUnitAD(unit u) {
    return float(Jass::GetUnitBaseDamageByIndex(u, 0) + Jass::GetUnitBonusDamageByIndex(u, 0));
}

// ===================== Нанесение урона =====================

// Магический урон по одной цели
void HDealSpellDmg(unit src, unit tgt, float dmg) {
    DealDamage(src, tgt, dmg, Jass::DAMAGE_TYPE_MAGIC);
}

// Физический урон по одной цели
void HDealPhysDmg(unit src, unit tgt, float dmg) {
    DealDamage(src, tgt, dmg, Jass::DAMAGE_TYPE_NORMAL);
}

funcdef void ForGroupAct(unit source, unit target);

void ForGroupAction(group g, unit src, ForGroupAct@ callback) {
    for(int i = 0; i < Jass::GroupGetCount(g); i++) {
        unit u2 = Jass::GroupGetUnitByIndex(g, i);
        if (Jass::IsUnitAlive(u2)) {
            callback(src, u2);
        }
    }
}

// AOE магический урон (только враги)
void HAOESpellDmg(unit src, float x, float y, float range, float dmg) {
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, range, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(src))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)) {
            DealDamage(src, u2, dmg, Jass::DAMAGE_TYPE_MAGIC);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// AOE физический урон (только враги)
void HAOEPhysDmg(unit src, float x, float y, float range, float dmg) {
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, range, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(src))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)) {
            DealDamage(src, u2, dmg, Jass::DAMAGE_TYPE_NORMAL);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// ===================== AOE стан =====================

void HAOEStun(float x, float y, unit src, float range, float time) {
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, x, y, range, nil);
    unit u2 = Jass::FirstOfGroup(g);
    while (u2 != nil) {
        Jass::GroupRemoveUnit(g, u2);
        if (Jass::IsUnitAlive(u2) && Jass::IsUnitEnemy(u2, Jass::GetOwningPlayer(src))
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_STRUCTURE)
            && !Jass::IsUnitType(u2, Jass::UNIT_TYPE_MAGIC_IMMUNE)) {
            StunUnit(u2, time);
        }
        u2 = Jass::FirstOfGroup(g);
    }
    Jass::DestroyGroup(g);
}

// ===================== Тайм-баффы (через Buff-систему) =====================

// Buff с bonusAllDamage (TotalAD)
void HAddBuff_TotalAD(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.bonusAllDamage = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с bonusPhysDamage (PhysAD)
void HAddBuff_PhysAD(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.bonusPhysDamage = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с bonusMagDamage (MagicAD)
void HAddBuff_MagicAD(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.bonusMagDamage = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с resistPhysical (DR - damage reduction)
void HAddBuff_DR(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.resistPhysical = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с resistMagic (MR)
void HAddBuff_MR(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.resistMagic = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с resistAll (PR)
void HAddBuff_PR(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.resistAll = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с attackSpeed (AS)
void HAddBuff_AS(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.attackSpeed = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с moveSpeed + moveSpeedPct (MS)
void HAddBuff_MS(unit u, int buffId, float flat, float pct, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.moveSpeed = flat;
    s.moveSpeedPct = pct;
    Buff@ b = Buff("", "", "", buffId, duration, s, true, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с hp / hpPct (HP)
void HAddBuff_HP(unit u, int buffId, float flat, float pct, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.hp = flat;
    s.hpPct = pct;
    Buff@ b = Buff("", "", "", buffId, duration, s, true, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с hpRegen / hpRegenPct (HP Regen)
void HAddBuff_HPRegen(unit u, int buffId, float flat, float pct, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.hpRegen = flat;
    s.hpRegenPct = pct;
    Buff@ b = Buff("", "", "", buffId, duration, s, true, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с strength (str)
void HAddBuff_Str(unit u, int buffId, float flat, float pct, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.strength = flat;
    s.strengthPct = pct;
    Buff@ b = Buff("", "", "", buffId, duration, s, true, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с attackSpeedPct (CapAS - attack speed cap bonus)
void HAddBuff_CapAS(unit u, int buffId, float value, float duration) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    UnitStatsData s;
    s.Reset();
    s.attackSpeedPct = value;
    Buff@ b = Buff("", "", "", buffId, duration, s, value > 0, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Buff с несколькими статами (Generic)
void HAddBuff_Custom(unit u, int buffId, UnitStatsData &in stats, float duration, bool isBuff = true) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    Buff@ b = Buff("", "", "", buffId, duration, stats, isBuff, PURGE_NORMAL, 0, 0, false);
    ud.AddBuff(b, u);
}

// Удалить бафф
void HRemoveBuff(unit u, int buffId) {
    UnitData@ ud = GetUnitData(u);
    if (ud is null) return;
    ud.RemoveBuff(buffId, u);
}

// ===================== Заряды способностей =====================
// Хранение в SkillHT: key = handleId юнита, subkey = abilId
// Второй набор зарядов: subkey = abilId + 1000000

framehandle AddChargeForAbility2(framehandle simple_btn, int abilId) {
    framehandle ChargeContent;
    framehandle ChargesBox;
    framehandle ChargesText;

    // Аналог CreateFrame("GlueWText", ...)
    ChargeContent = Jass::CreateFrame("GlueWText", simple_btn, 0, 1000000+abilId);
    ChargesBox = Jass::GetFrameChild(ChargeContent, 0);
    ChargesText = Jass::GetFrameChild(ChargeContent, 1);

    //Jass::SetFrameText(ChargesText, Jass::I2S(charges)); // если нужно выставить число
    Jass::SetFrameTexture(ChargesBox, "UI\\Widgets\\Console\\Human\\CommandButton\\human-button-lvls-overlay", 0, false);
    Jass::SetFrameSize(ChargeContent, .016/0.8, .016/0.6);
    Jass::SetFrameRelativePoint(ChargeContent, Jass::FRAMEPOINT_BOTTOMLEFT, simple_btn, Jass::FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0);
    Jass::ShowFrame(ChargeContent, false);
    Jass::SetFrameText(ChargesText, "100");

    //Jass::ConsolePrint("\nCharge frame created: " + Jass::GetFrameName(ChargeContent) + ", " + Jass::GetFrameName(ChargesBox) + ", " + Jass::GetFrameName(ChargesText));

    // Нет необходимости занулять ChargesBox/ChargeContent в AS
    return ChargesText;
}

framehandle AddChargeForAbility1(framehandle simple_btn, int abilId) {
    framehandle ChargeContent;
    framehandle ChargesBox;
    framehandle ChargesText;

    // Аналог CreateFrame("GlueWText", ...)
    ChargeContent = Jass::CreateFrame("GlueWText", simple_btn, 0, abilId);
    ChargesBox = Jass::GetFrameChild(ChargeContent, 0);
    ChargesText = Jass::GetFrameChild(ChargeContent, 1);

    //Jass::SetFrameText(ChargesText, Jass::I2S(charges)); // если нужно выставить число
    Jass::SetFrameTexture(ChargesBox, "UI\\Widgets\\Console\\Human\\CommandButton\\human-button-lvls-overlay", 0, false);
    Jass::SetFrameSize(ChargeContent, .016/0.8, .016/0.6);
    Jass::SetFrameRelativePoint(ChargeContent, Jass::FRAMEPOINT_BOTTOMRIGHT, simple_btn, Jass::FRAMEPOINT_BOTTOMRIGHT, 0.0, 0.0);
    Jass::ShowFrame(ChargeContent, false);
    Jass::SetFrameText(ChargesText, "100");

    //Jass::ConsolePrint("\nCharge frame created: " + Jass::GetFrameName(ChargeContent) + ", " + Jass::GetFrameName(ChargesBox) + ", " + Jass::GetFrameName(ChargesText));

    // Нет необходимости занулять ChargesBox/ChargeContent в AS
    return ChargesText;
}

int HGetAbilityX(int abilId) {
    return Jass::GetAbilityBaseIntegerFieldById(abilId, Jass::ABILITY_IF_BUTTON_POSITION_NORMAL_X);
}

int HGetAbilityY(int abilId) {
    return Jass::GetAbilityBaseIntegerFieldById(abilId, Jass::ABILITY_IF_BUTTON_POSITION_NORMAL_Y);
}

void HSetAbilityCharges(unit u, int abilId, int charges) {
    Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), abilId, charges);
    framehandle cf = Jass::GetFrameByName("GlueWText", abilId);
    if (cf == nil) {
        cf = AddChargeForAbility1(Jass::GetOriginFrame(Jass::ORIGIN_FRAME_COMMAND_BUTTON, HGetAbilityY(abilId)*4+HGetAbilityX(abilId) ), abilId);
    }
    framehandle cf_text = Jass::GetFrameChild(cf, 1);
    if (Jass::GetLocalPlayer() == Jass::GetOwningPlayer(u)) {
        Jass::SetFrameText(cf_text, Jass::I2S(charges));
        Jass::ShowFrame(cf, charges > 0);
    }
}

int HGetAbilityCharges(unit u, int abilId) {
    return Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), abilId);
}

void HSetAbility2Charges(unit u, int abilId, int charges) {
    Jass::SaveInteger(SkillHT, Jass::GetHandleId(u), abilId + 1000000, charges);
    framehandle cf = Jass::GetFrameByName("GlueWText", abilId);
    if (cf == nil) {
        cf = AddChargeForAbility2(Jass::GetOriginFrame(Jass::ORIGIN_FRAME_COMMAND_BUTTON, HGetAbilityY(abilId)*4+HGetAbilityX(abilId) ), abilId);
    }
    framehandle cf_text = Jass::GetFrameChild(cf, 1);
    if (Jass::GetLocalPlayer() == Jass::GetOwningPlayer(u)) {
        Jass::SetFrameText(cf_text, Jass::I2S(charges));
        Jass::ShowFrame(cf, charges > 0);
    }
}

int HGetAbility2Charges(unit u, int abilId) {
    return Jass::LoadInteger(SkillHT, Jass::GetHandleId(u), abilId + 1000000);
}

// ===================== Мана =====================

void HGiveMana(unit u, float amount) {
    float cur = Jass::GetUnitState(u, Jass::UNIT_STATE_MANA);
    float max = Jass::GetUnitState(u, Jass::UNIT_STATE_MAX_MANA);
    float newVal = cur + amount;
    if (newVal > max) newVal = max;
    if (newVal < 0) newVal = 0;
    Jass::SetUnitState(u, Jass::UNIT_STATE_MANA, newVal);
}

// ===================== On-Attack / On-Damage колбэки =====================
// Система привязанных к юниту колбэков (аналог Unit_Triggers в JASS)

funcdef void UnitEventCallback(unit source, unit target);

class UnitEventEntry {
    int abilId;                // ID способности (для идентификации)
    UnitEventCallback@ cb;     // колбэк
    float expireTime;          // когда истекает (game time); <= 0 = бессрочный
}

dictionary g_OnAttackCallbacks;   // key = handleId → array<UnitEventEntry@>
dictionary g_OnDamageCallbacks;   // key = handleId → array<UnitEventEntry@>

void HRegisterOnAttack(unit u, int abilId, UnitEventCallback@ cb, float duration = 0) {
    string key = "" + Jass::GetHandleId(u);
    array<UnitEventEntry@>@ list;
    if (!g_OnAttackCallbacks.get(key, @list)) {
        @list = array<UnitEventEntry@>();
        g_OnAttackCallbacks.set(key, @list);
    }
    // Удаляем старый с таким же abilId
    for (uint i = 0; i < list.length(); i++) {
        if (list[i].abilId == abilId) {
            list.removeAt(i);
            break;
        }
    }
    UnitEventEntry@ e = UnitEventEntry();
    e.abilId = abilId;
    @e.cb = cb;
    e.expireTime = duration > 0 ? Jass::TimerGetElapsed(Jass::CreateTimer()) + duration : 0;
    // Для duration используем SkillHT + таймер
    if (duration > 0) {
        timer t = Jass::CreateTimer();
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 0, Jass::GetHandleId(u));
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 1, abilId);
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 2, 1); // 1 = attack
        Jass::TimerStart(t, duration, false, function() {
            timer tmr = Jass::GetExpiredTimer();
            int uid = Jass::LoadInteger(SkillHT, Jass::GetHandleId(tmr), 0);
            int aid = Jass::LoadInteger(SkillHT, Jass::GetHandleId(tmr), 1);
            string k = "" + uid;
            array<UnitEventEntry@>@ lst;
            if (g_OnAttackCallbacks.get(k, @lst)) {
                for (uint i = 0; i < lst.length(); i++) {
                    if (lst[i].abilId == aid) {
                        lst.removeAt(i);
                        break;
                    }
                }
            }
            Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(tmr));
            Jass::DestroyTimer(tmr);
        });
    }
    list.insertLast(e);
}

void HRemoveOnAttack(unit u, int abilId) {
    string key = "" + Jass::GetHandleId(u);
    array<UnitEventEntry@>@ list;
    if (g_OnAttackCallbacks.get(key, @list)) {
        for (uint i = 0; i < list.length(); i++) {
            if (list[i].abilId == abilId) {
                list.removeAt(i);
                return;
            }
        }
    }
}

void HRegisterOnDamage(unit u, int abilId, UnitEventCallback@ cb, float duration = 0) {
    string key = "" + Jass::GetHandleId(u);
    array<UnitEventEntry@>@ list;
    if (!g_OnDamageCallbacks.get(key, @list)) {
        @list = array<UnitEventEntry@>();
        g_OnDamageCallbacks.set(key, @list);
    }
    for (uint i = 0; i < list.length(); i++) {
        if (list[i].abilId == abilId) {
            list.removeAt(i);
            break;
        }
    }
    UnitEventEntry@ e = UnitEventEntry();
    e.abilId = abilId;
    @e.cb = cb;
    e.expireTime = 0;
    if (duration > 0) {
        timer t = Jass::CreateTimer();
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 0, Jass::GetHandleId(u));
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 1, abilId);
        Jass::SaveInteger(SkillHT, Jass::GetHandleId(t), 2, 2); // 2 = damage
        Jass::TimerStart(t, duration, false, function() {
            timer tmr = Jass::GetExpiredTimer();
            int uid = Jass::LoadInteger(SkillHT, Jass::GetHandleId(tmr), 0);
            int aid = Jass::LoadInteger(SkillHT, Jass::GetHandleId(tmr), 1);
            string k = "" + uid;
            array<UnitEventEntry@>@ lst;
            if (g_OnDamageCallbacks.get(k, @lst)) {
                for (uint i = 0; i < lst.length(); i++) {
                    if (lst[i].abilId == aid) {
                        lst.removeAt(i);
                        break;
                    }
                }
            }
            Jass::FlushChildHashtable(SkillHT, Jass::GetHandleId(tmr));
            Jass::DestroyTimer(tmr);
        });
    }
    list.insertLast(e);
}

void HRemoveOnDamage(unit u, int abilId) {
    string key = "" + Jass::GetHandleId(u);
    array<UnitEventEntry@>@ list;
    if (g_OnDamageCallbacks.get(key, @list)) {
        for (uint i = 0; i < list.length(); i++) {
            if (list[i].abilId == abilId) {
                list.removeAt(i);
                return;
            }
        }
    }
}

// Диспатчер on-attack: вызывается из DamageSystem при атаке
void HFireOnAttack(unit attacker, unit target) {
    string key = "" + Jass::GetHandleId(attacker);
    array<UnitEventEntry@>@ list;
    if (g_OnAttackCallbacks.get(key, @list)) {
        for (uint i = 0; i < list.length(); i++) {
            if (list[i].cb !is null) {
                list[i].cb(attacker, target);
            }
        }
    }
}

// Диспатчер on-damage: вызывается из DamageSystem при получении урона
void HFireOnDamage(unit source, unit target) {
    string key = "" + Jass::GetHandleId(target);
    array<UnitEventEntry@>@ list;
    if (g_OnDamageCallbacks.get(key, @list)) {
        for (uint i = 0; i < list.length(); i++) {
            if (list[i].cb !is null) {
                list[i].cb(source, target);
            }
        }
    }
}

// ===================== Прочие утилиты =====================

// Проверка мёртв ли юнит
bool HIsUnitDead(unit u) {
    return u == nil || Jass::IsUnitDead(u) || Jass::GetUnitState(u, Jass::UNIT_STATE_LIFE) <= 0;
}

// Сумма всех статов (str+agi+int)
int HGetAllStats(unit u) {
    return Jass::GetHeroStr(u, true) + Jass::GetHeroAgi(u, true) + Jass::GetHeroInt(u, true);
}

// Уменьшить оставшееся КД способности
void HReduceCooldown(unit u, int abilId, float amount) {
    ability abil = Jass::GetUnitAbility(u, abilId);
    if (abil == nil) return;
    float remaining = Jass::GetAbilityRemainingCooldown(abil);
    if (remaining > amount) {
        Jass::SetAbilityRemainingCooldown(abil, remaining - amount);
    } else {
        Jass::SetAbilityRemainingCooldown(abil, 0.01);
    }
}

// Минимум/максимум целых
int HMinInt(int a, int b) { return a < b ? a : b; }
int HMaxInt(int a, int b) { return a > b ? a : b; }
float HMinReal(float a, float b) { return a < b ? a : b; }
float HMaxReal(float a, float b) { return a > b ? a : b; }
