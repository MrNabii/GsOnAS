array<unit> Selectedunit(12);
class Buff {
    int    buffTypeId;   // уникальный id типа баффа
    float  duration;     // оставшееся время (-1 = бессрочный)
    float  maxDuration;  // максимальная длительность (для UI)
    bool   isBuff;       // true = бафф, false = дебафф
    int    purgeLevel;   // PURGE_NONE / PURGE_NORMAL / PURGE_STRONG / PURGE_DEMONIC
    int    level;        // Уровень баффа
    int    stack;        // Кол-во стаков
    UnitStatsData stats; // бонусы от этого баффа
    string  name;           // имя для отображения
    string  description;    // описание для отображения
    string  iconPath;      // путь к иконке для отображения
    bool   isVisible;      // отображать ли в UI
    // Аура
    bool   isAura;         // является ли аурой
    float  auraRadius;     // радиус действия ауры
    int    auraSourceId;   // handle ID источника ауры

    Buff(const string &in name, const string &in description, const string &in iconPath, int buffTypeId, float duration, UnitStatsData &in stats, bool isBuff, 
    int purgeLevel = PURGE_NONE, int level = 0, int stack = 0, bool isVisible = true) {
        this.buffTypeId = buffTypeId;
        this.duration = duration;
        this.maxDuration = duration;
        this.isBuff = isBuff;
        this.purgeLevel = purgeLevel;
        this.level = level;
        this.stack = stack;
        this.stats = stats;
        this.name = name;
        this.description = description;
        this.iconPath = iconPath;
        this.isVisible = isVisible;
        this.isAura = false;
        this.auraRadius = 0;
        this.auraSourceId = 0;
    }

    // --- Get/методы для полей (кроме строк и видимости) ---
    int get_buffTypeId() { return buffTypeId; }
    void set_buffTypeId(int v) { buffTypeId = v; }

    float get_duration() { return duration; }
    void set_duration(float v) { duration = v; }

    bool get_isBuff() { return isBuff; }
    void set_isBuff(bool v) { isBuff = v; }

    int get_purgeLevel() { return purgeLevel; }
    void set_purgeLevel(int v) { purgeLevel = v; }

    int get_level() { return level; }
    void set_level(int v) { level = v; }

    int get_stack() { return stack; }
    void set_stack(int v) { stack = v; }

    UnitStatsData@ get_stats() { return stats; }
    void set_stats(const UnitStatsData &in v) { stats = v; }

    float get_maxDuration() { return maxDuration; }
    void set_maxDuration(float v) { maxDuration = v; }

    bool get_isAura() { return isAura; }
    void set_isAura(bool v) { isAura = v; }

    float get_auraRadius() { return auraRadius; }
    void set_auraRadius(float v) { auraRadius = v; }

    int get_auraSourceId() { return auraSourceId; }
    void set_auraSourceId(int v) { auraSourceId = v; }
}

string FormatDuration(float dur) {
    if (dur < 0) return "";
    int s = Jass::R2I(dur);
    if (s >= 3600) return Jass::I2S(s / 3600) + "h";
    if (s >= 60) return Jass::I2S(s / 60) + "m";
    return Jass::I2S(s) + "s";
}

framehandle AddFrameTooltip(framehandle simple_btn, int id, int intVal, int frame_int) {
    framehandle tooltipBox;
    framehandle tooltipTitle;
    framehandle tooltipDesc;

    // background
    tooltipBox = Jass::CreateFrameByType("SIMPLEFRAME", "BuffTooltipBox", Jass::GetOriginFrame(Jass::ORIGIN_FRAME_CONSOLE_UI, 0), "", intVal);
    Jass::ClearFrameAllPoints(tooltipBox);
    Jass::SetFrameParent(tooltipBox, simple_btn);
    Jass::SetFrameTextureEx(tooltipBox, 0, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background", false, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-border", Jass::BORDER_FLAG_ALL);
    Jass::ShowFrame(tooltipBox, true);
    Jass::SetFramePriority(tooltipBox, 12);

    // title (название баффа)
    tooltipTitle = Jass::CreateFrameByType("SIMPLETEXT", "BuffTooltipTitle", tooltipBox, "", intVal);
    Jass::ClearFrameAllPoints(tooltipTitle);
    Jass::SetFrameParent(tooltipTitle, tooltipBox);
    Jass::SetFrameFont(tooltipTitle, "Fonts\\FRIZQT__.TTF", 0.010, 0);
    Jass::SetFrameRelativePoint(tooltipTitle, Jass::FRAMEPOINT_BOTTOM, simple_btn, Jass::FRAMEPOINT_TOP, 0, 0.020);
    Jass::SetFrameSize(tooltipTitle, 0.13, 0.0);
    Jass::SetFrameTextAlignment(tooltipTitle, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_LEFT);
    Jass::SetFramePriority(tooltipTitle, 13);
    Jass::SetFrameText(tooltipTitle, "BuffName");
    Jass::ShowFrame(tooltipTitle, true);

    // description (описание снизу)
    tooltipDesc = Jass::CreateFrameByType("SIMPLETEXT", "BuffTooltipDesc", tooltipBox, "", intVal);
    Jass::ClearFrameAllPoints(tooltipDesc);
    Jass::SetFrameParent(tooltipDesc, tooltipBox);
    Jass::SetFrameFont(tooltipDesc, "Fonts\\FRIZQT__.TTF", 0.009, 0);
    Jass::SetFrameRelativePoint(tooltipDesc, Jass::FRAMEPOINT_TOPLEFT, tooltipTitle, Jass::FRAMEPOINT_BOTTOMLEFT, 0, -0.004);
    Jass::SetFrameSize(tooltipDesc, 0.13, 0.0);
    Jass::SetFrameTextAlignment(tooltipDesc, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_LEFT);
    Jass::SetFramePriority(tooltipDesc, 13);
    Jass::SetFrameText(tooltipDesc, "");
    Jass::ShowFrame(tooltipDesc, true);

    Jass::SetFrameRelativePoint(tooltipBox, Jass::FRAMEPOINT_BOTTOMRIGHT, tooltipDesc, Jass::FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.005);
    Jass::SetFrameRelativePoint(tooltipBox, Jass::FRAMEPOINT_TOPLEFT, tooltipTitle, Jass::FRAMEPOINT_TOPLEFT, -0.007, 0.005);
    Jass::SetFrameTooltip(simple_btn, tooltipBox);

    return tooltipTitle;
}

void UpdateBuffSlot(framehandle b, int slotIdx, Buff@ buff) {
    Jass::SetFrameTexture(b, buff.iconPath, 1, true);
    Jass::ShowFrame(b, true);
    // Tooltip: название и описание
    Jass::SetFrameText(Jass::GetFrameByName("BuffTooltipTitle", slotIdx), buff.name);
    string descText = buff.description;
    if (buff.isAura) {
        descText += "\n|cffffcc00Радиус: " + Jass::I2S(Jass::R2I(buff.auraRadius)) + "|r";
    } else if (buff.duration > 0) {
        descText += "\n|cffffcc00Осталось: " + FormatDuration(buff.duration) + "|r";
    }
    Jass::SetFrameText(Jass::GetFrameByName("BuffTooltipDesc", slotIdx), descText);
    // Стаки (charge) — снизу справа
    framehandle cf = Jass::GetFrameByName("GlueWText", slotIdx);
    framehandle cf_text = Jass::GetFrameChild(cf, 1);
    if (buff.stack > 1) {
        Jass::SetFrameText(cf_text, "|cffE9D04F" + Jass::I2S(buff.stack) + "|r");
        Jass::ShowFrame(cf, true);
    } else {
        Jass::ShowFrame(cf, false);
    }
    // Длительность — по центру иконки
    framehandle df = Jass::GetFrameByName("BuffDurationText", slotIdx);
    if (buff.duration > 0) {
        Jass::SetFrameText(df, "|cFFE9DEA6" + FormatDuration(buff.duration) + "|r");
        Jass::ShowFrame(df, true);
    } else {
        Jass::ShowFrame(df, false);
    }
}

int ChargeFrameCounter = 0;

framehandle AddChargeForItem(framehandle simple_btn) {
    framehandle ChargeContent;
    framehandle ChargesBox;
    framehandle ChargesText;

    // Аналог CreateFrame("GlueWText", ...)
    ChargeContent = Jass::CreateFrame("GlueWText", simple_btn, 0, ChargeFrameCounter);
    ChargeFrameCounter++;
    ChargesBox = Jass::GetFrameChild(ChargeContent, 0);
    ChargesText = Jass::GetFrameChild(ChargeContent, 1);

    //Jass::SetFrameText(ChargesText, Jass::I2S(charges)); // если нужно выставить число
    Jass::SetFrameTexture(ChargesBox, "UI\\Widgets\\Console\\Human\\CommandButton\\human-button-lvls-overlay", 0, false);
    Jass::SetFrameSize(ChargeContent, .016/0.8/1.9, .016/0.8/2.2);
    Jass::SetFrameScale(ChargesText, 0.8);
    Jass::SetFrameScale(ChargesBox, 1.4);
    Jass::SetFrameRelativePoint(ChargeContent, Jass::FRAMEPOINT_BOTTOMRIGHT, simple_btn, Jass::FRAMEPOINT_BOTTOMRIGHT, 0.0, 0.0);
    Jass::ShowFrame(ChargeContent, false);
    Jass::SetFrameText(ChargesText, "100");

    //Jass::ConsolePrint("\nCharge frame created: " + Jass::GetFrameName(ChargeContent) + ", " + Jass::GetFrameName(ChargesBox) + ", " + Jass::GetFrameName(ChargesText));

    // Нет необходимости занулять ChargesBox/ChargeContent в AS
    return ChargesText;
}

void InitBuffSystem() {
    Jass::LoadTOCFile("war3mapImported\\SkillCharge.toc");
    Jass::EditBlackBorders(0., 0.);
    framehandle simple_btn;
    framehandle tooltipTitle;

    float width = .012/0.8;
    float height = .012/0.6;
    float x_offset = .001/0.8;
    float y_offset = .001/0.6;
    float x_margin = width * .01;
    float y_margin = height * .01;
    int MAX_COLUMNS = 19, MAX_ROWS = 2;
    float x = 0, y = 0;

    for (int i = 0; i <= MAX_COLUMNS * MAX_ROWS - 1; i++) {
        simple_btn = Jass::CreateFrameByType("SIMPLEBUTTON", "BuffSystem_BuffPlaceHolder", Jass::GetOriginFrame(Jass::ORIGIN_FRAME_GAME_UI, 0), "", i);
        Jass::ClearFrameAllPoints(simple_btn);
        Jass::SetFrameSize(simple_btn, width, height);
        x = 0.193 + x_offset + (Jass::MathIntegerModulo(i, MAX_COLUMNS) * width) + (Jass::MathIntegerModulo(i, MAX_COLUMNS) * x_margin);
        y = 0.140 + y_offset + (Jass::MathRealFloor(i / MAX_COLUMNS) * height) + (Jass::MathRealFloor(i / MAX_COLUMNS) * y_margin);
        Jass::SetFrameAbsolutePoint(simple_btn, Jass::FRAMEPOINT_TOPLEFT, x, y);
        Jass::SetFramePriority(simple_btn, 5);
        Jass::SetFrameTexture(simple_btn, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp", 1, true);
        Jass::ShowFrame(simple_btn, false);

        // Tooltip (название + описание)
        tooltipTitle = AddFrameTooltip(simple_btn, 0, i, 0);
        Jass::SetFrameText(tooltipTitle, "Buff/Debuff");

        // Charge text (стаки — снизу справа, как у предметов)
        framehandle chargeFrame = AddChargeForItem(simple_btn);
        // Duration text (время — по центру иконки)
        framehandle durFrame = Jass::CreateFrameByType("SIMPLETEXT", "BuffDurationText", simple_btn, "", i);
        Jass::ClearFrameAllPoints(durFrame);
        Jass::SetFrameParent(durFrame, simple_btn);
        Jass::SetFrameFont(durFrame, "Fonts\\FRIZQT__.TTF", 0.013, 0);
        if (i >= MAX_COLUMNS) 
            Jass::SetFrameRelativePoint(durFrame, Jass::FRAMEPOINT_BOTTOM, simple_btn, Jass::FRAMEPOINT_TOP, 0, 0.003);
        else 
            Jass::SetFrameRelativePoint(durFrame, Jass::FRAMEPOINT_TOP, simple_btn, Jass::FRAMEPOINT_BOTTOM, 0, -0.003);
        Jass::SetFrameTextAlignment(durFrame, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_CENTER);
        Jass::SetFramePriority(durFrame, 6);
        Jass::SetFrameText(durFrame, "");
        Jass::ShowFrame(durFrame, false);
    }

    // --- Триггеры на выделение и снятие выделения юнитов ---
    trigger trgSelect = Jass::CreateTrigger();
    trigger trgDeselect = Jass::CreateTrigger();
    for (int p = 0; p < 10; p++) {
        Jass::TriggerRegisterPlayerUnitEvent(trgSelect, Jass::Player(p), Jass::EVENT_PLAYER_UNIT_SELECTED, nil);
        Jass::TriggerRegisterPlayerUnitEvent(trgDeselect, Jass::Player(p), Jass::EVENT_PLAYER_UNIT_DESELECTED, nil);
    }
    Jass::TriggerAddAction(trgSelect, function() {
        unit u = Jass::GetTriggerUnit();
        Selectedunit[Jass::GetPlayerId(Jass::GetTriggerPlayer())] = u;
        // TODO: обработка выделения юнита (u)
        Jass::ConsolePrint("Selected: " + Jass::GetUnitName(u));
    });
    Jass::TriggerAddAction(trgDeselect, function() {
        Selectedunit[Jass::GetPlayerId(Jass::GetTriggerPlayer())] = nil;
        // TODO: обработка снятия выделения юнита (u)
        Jass::ConsolePrint("\nDeselected: " );
    });

    Jass::TimerStart(Jass::CreateTimer(), 0.33, true, function() {
        // Скрыть все слоты + overlay
        for (int i = 0; i < 38; i++) {
            framehandle b = Jass::GetFrameByName("BuffSystem_BuffPlaceHolder", i);
            Jass::ShowFrame(b, false);
            Jass::ShowFrame(Jass::GetFrameByName("GlueWText", i), false);
            Jass::ShowFrame(Jass::GetFrameByName("BuffDurationText", i), false);
        }
        // Обновить отображение баффов выделенного юнита каждого игрока
        for(int i = 0; i < 10; i++) {
            unit u = Selectedunit[i];
            if (u != nil) {
                string key = "" + Jass::GetHandleId(u);
                UnitData@ ud;
                if (UnitDataMap.get(key, @ud)) {
                    framehandle b;
                    uint buffIdx = 0;
                    uint debuffIdx = 0;
                    for (uint j = 0; j < ud.buffs.length(); j++) {
                        if (!ud.buffs[j].isVisible) continue;
                        if (ud.buffs[j].isBuff && buffIdx < 19) {
                            int slotIdx = int(buffIdx);
                            b = Jass::GetFrameByName("BuffSystem_BuffPlaceHolder", slotIdx);
                            if (Jass::GetLocalPlayer() == Jass::Player(i)) {
                                UpdateBuffSlot(b, slotIdx, ud.buffs[j]);
                            }
                            buffIdx++;
                        } else if (!ud.buffs[j].isBuff && debuffIdx < 19) {
                            int slotIdx = int(debuffIdx) + 19;
                            b = Jass::GetFrameByName("BuffSystem_BuffPlaceHolder", slotIdx);
                            if (Jass::GetLocalPlayer() == Jass::Player(i)) {
                                UpdateBuffSlot(b, slotIdx, ud.buffs[j]);
                            }
                            debuffIdx++;
                        }
                    }
                }
            }
        }
    });
    Jass::ConsolePrint("\nBuffSystemInitialized");
}

// ============================================================
//  Подсистема аур
// ============================================================

Buff@ CreateAuraBuff(const string &in name, const string &in desc, const string &in icon,
    int buffTypeId, UnitStatsData &in stats, bool isBuff, float auraRadius, unit source,
    int purgeLevel = PURGE_NONE, int level = 0) {
    Buff@ b = Buff(name, desc, icon, buffTypeId, -1.0, stats, isBuff, purgeLevel, level, 0, true);
    b.isAura = true;
    b.auraRadius = auraRadius;
    b.auraSourceId = Jass::GetHandleId(source);
    // Сохраняем source unit в хэштейбл для последующего извлечения в TickBuffs
    Jass::SaveUnitHandle(SHT, b.auraSourceId, 'asrc', source);
    return b;
}

void ApplyAuraToNearby(unit source, const string &in name, const string &in desc, const string &in icon,
    int buffTypeId, UnitStatsData &in stats, bool isBuff, float radius,
    int purgeLevel = PURGE_NONE, int level = 0) {
    int srcId = Jass::GetHandleId(source);
    Jass::SaveUnitHandle(SHT, srcId, 'asrc', source);

    // Применяем ауру и на самого источника
    string srcKey = "" + srcId;
    UnitData@ srcUd;
    if (UnitDataMap.get(srcKey, @srcUd)) {
        if (!srcUd.HasBuff(buffTypeId)) {
            Buff@ srcAura = CreateAuraBuff(name, desc, icon, buffTypeId, stats, isBuff, radius, source, purgeLevel, level);
            srcUd.AddBuff(srcAura, source);
        }
    }

    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(source), Jass::GetUnitY(source), radius, nil);

    unit u;
    while (true) {
        u = Jass::FirstOfGroup(g);
        if (u == nil) break;
        Jass::GroupRemoveUnit(g, u);

        if (u == source) continue;
        if (Jass::GetUnitState(u, Jass::UNIT_STATE_LIFE) <= 0) continue;

        string key = "" + Jass::GetHandleId(u);
        UnitData@ ud;
        if (UnitDataMap.get(key, @ud)) {
            if (!ud.HasBuff(buffTypeId)) {
                Buff@ auraBuff = CreateAuraBuff(name, desc, icon, buffTypeId, stats, isBuff, radius, source, purgeLevel, level);
                ud.AddBuff(auraBuff, u);
            }
        }
    }
    Jass::DestroyGroup(g);
}

void TickAuras(unit source, const string &in name, const string &in desc, const string &in icon,
    int buffTypeId, UnitStatsData &in stats, bool isBuff, float radius,
    int purgeLevel = PURGE_NONE, int level = 0) {
    int srcId = Jass::GetHandleId(source);
    Jass::SaveUnitHandle(SHT, srcId, 'asrc', source);

    // Источник ауры всегда должен иметь бафф на себе
    string srcKey = "" + srcId;
    UnitData@ srcUd;
    if (UnitDataMap.get(srcKey, @srcUd)) {
        if (!srcUd.HasBuff(buffTypeId)) {
            Buff@ srcAura = CreateAuraBuff(name, desc, icon, buffTypeId, stats, isBuff, radius, source, purgeLevel, level);
            srcUd.AddBuff(srcAura, source);
        }
    }

    // Проверяем юнитов в увеличенном радиусе: удаляем вышедших, добавляем вернувшихся
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRange(g, Jass::GetUnitX(source), Jass::GetUnitY(source), radius + 100, nil);

    unit u;
    while (true) {
        u = Jass::FirstOfGroup(g);
        if (u == nil) break;
        Jass::GroupRemoveUnit(g, u);
        if (u == source) continue;
        if (Jass::GetUnitState(u, Jass::UNIT_STATE_LIFE) <= 0) continue;
        if (!(Jass::IsUnitAlly(u, Jass::GetOwningPlayer(source)))) continue;
        string key = "" + Jass::GetHandleId(u);
        UnitData@ ud;
        if (UnitDataMap.get(key, @ud)) {
            float dx = Jass::GetUnitX(u) - Jass::GetUnitX(source);
            float dy = Jass::GetUnitY(u) - Jass::GetUnitY(source);
            bool inRange = (dx*dx + dy*dy) <= (radius * radius);
            if (inRange && !ud.HasBuff(buffTypeId)) {
                // Вернулся в радиус — дать ауру заново
                Buff@ auraBuff = CreateAuraBuff(name, desc, icon, buffTypeId, stats, isBuff, radius, source, purgeLevel, level);
                ud.AddBuff(auraBuff, u);
            } else if (!inRange && ud.HasBuff(buffTypeId)) {
                // Вышел из радиуса — убрать ауру
                ud.RemoveBuff(buffTypeId, u);
            }
        }
    }
    Jass::DestroyGroup(g);
}

// ============================================================
//  Тестовые кейсы
// ============================================================

void TestBuffSystem_AddBuff(unit u) {
    if (u == nil) return;
    string key = "" + Jass::GetHandleId(u);
    UnitData@ ud;
    if (!UnitDataMap.get(key, @ud)) {
        Jass::ConsolePrint("\n[Test] UnitData not found");
        return;
    }

    // Test 1: обычный бафф с длительностью и стаками
    UnitStatsData buffStats;
    buffStats.Reset();
    buffStats.strength = 10;
    buffStats.armor = 5;
    Buff@ testBuff = Buff("Благословение", "+10 силы, +5 защиты",
        "ReplaceableTextures\\CommandButtons\\BTNDivineIntervention.blp",
        'tb01', 15.0, buffStats, true, PURGE_NORMAL, 1, 3, true);
    ud.AddBuff(testBuff, u);
    Jass::ConsolePrint("\n[Test] Buff added: Благословение, dur=15, stack=3");

    // Test 2: дебафф
    UnitStatsData debuffStats;
    debuffStats.Reset();
    debuffStats.armor = -3;
    debuffStats.moveSpeed = -20;
    Buff@ testDebuff = Buff("Проклятие", "-3 защиты, -20 скорости",
        "ReplaceableTextures\\CommandButtons\\BTNCurse.blp",
        'td01', 10.0, debuffStats, false, PURGE_NORMAL, 1, 0, true);
    ud.AddBuff(testDebuff, u);
    Jass::ConsolePrint("\n[Test] Debuff added: Проклятие, dur=10");

    // Test 3: бессрочный бафф
    UnitStatsData permStats;
    permStats.Reset();
    permStats.hp = 100;
    Buff@ permBuff = Buff("Стойкость", "+100 ХП навсегда",
        "ReplaceableTextures\\CommandButtons\\BTNResistantSkin.blp",
        'tp01', -1.0, permStats, true, PURGE_NONE, 1, 0, true);
    ud.AddBuff(permBuff, u);
    Jass::ConsolePrint("\n[Test] Permanent buff added: Стойкость");
}

void TestBuffSystem_Aura(unit src) {
    if (src == nil) return;

    UnitStatsData auraStats;
    auraStats.Reset();
    auraStats.armor = 3;
    auraStats.hpRegen = 2;

    ApplyAuraToNearby(src, "Аура защиты", "+3 защиты, +2 реген ХП союзникам",
        "ReplaceableTextures\\CommandButtons\\BTNDevotion.blp",
        'ta01', auraStats, true, 600.0, PURGE_NONE, 1);
    Jass::ConsolePrint("\n[Test] Aura applied: radius=600");
}

void TestBuffSystem_Stacks(unit u) {
    if (u == nil) return;
    string key = "" + Jass::GetHandleId(u);
    UnitData@ ud;
    if (!UnitDataMap.get(key, @ud)) return;

    UnitStatsData stackStats;
    stackStats.Reset();
    stackStats.damage = 5;
    Buff@ stackBuff = Buff("Ярость", "+5 урона за стак",
        "ReplaceableTextures\\CommandButtons\\BTNBerserk.blp",
        'ts01', 8.0, stackStats, true, PURGE_NORMAL, 1, 1, true);

    if (ud.HasBuff('ts01')) {
        // Увеличиваем стак существующего баффа
        for (uint i = 0; i < ud.buffs.length(); i++) {
            if (ud.buffs[i].buffTypeId == 'ts01') {
                ud.buffs[i].stack += 1;
                ud.buffs[i].duration = 8.0; // обновить длительность
                Jass::ConsolePrint("\n[Test] Stack increased to " + Jass::I2S(ud.buffs[i].stack));
                break;
            }
        }
    } else {
        ud.AddBuff(stackBuff, u);
        Jass::ConsolePrint("\n[Test] Stack buff added: Ярость, stack=1");
    }
}