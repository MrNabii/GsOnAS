//import UnitStats.as
//import CraftingSystemFrame.as

int US_PANEL_ID = 2;
int US_LINES_PER_PAGE = 24;

float US_PANEL_W = 0.14;
float US_PANEL_H = 0.4;
float US_LINE_HEIGHT = 0.014;

array<bool> US_IsOpen(12);
array<int> US_Page(12);

framehandle US_Backdrop;
framehandle US_Title;
framehandle US_CloseBtn;
framehandle US_OpenBtn;
framehandle US_OpenText;
framehandle US_PageText;
framehandle US_PrevBtn;
framehandle US_NextBtn;
array<framehandle> US_Lines;

int US_FrameCtx = 12000;

string US_FormatValue(float value, int decimals) {
    if (decimals <= 0) return Jass::I2S(Jass::R2I(value));
    return Jass::R2SW(value, 0, decimals);
}

string US_FormatPercentText(float value, bool isFraction, int decimals = 0) {
    float pct = isFraction ? (value * 100.0) : value;
    return US_FormatValue(pct, decimals) + "%";
}

string US_ColorText(const string &in color, const string &in text) {
    return color + text + "|r";
}

string US_ColorBaseValue(float value, int decimals) {
    return US_ColorText("|cffffffff", US_FormatValue(value, decimals));
}

string US_ColorBonusValue(float value, int decimals) {
    return US_ColorText("|cff00ff00", US_FormatValue(value, decimals));
}

string US_ColorTotalValue(float value, int decimals) {
    return US_ColorText("|cffffcc00", US_FormatValue(value, decimals));
}

string US_ColorBasePercent(float value, bool isFraction, int decimals = 0) {
    return US_ColorText("|cffffffff", US_FormatPercentText(value, isFraction, decimals));
}

string US_ColorBonusPercent(float value, bool isFraction, int decimals = 0) {
    return US_ColorText("|cff00ff00", US_FormatPercentText(value, isFraction, decimals));
}

string US_ColorTotalPercent(float value, bool isFraction, int decimals = 0) {
    return US_ColorText("|cffffcc00", US_FormatPercentText(value, isFraction, decimals));
}

bool US_IsZero(float value) {
    return value > -0.0001 && value < 0.0001;
}

string US_FormatStatLine(string name, float base, float total, int decimals) {
    float bonus = total - base;
    float finalVal = base + bonus;
    return name + ": " + US_ColorBaseValue(base, decimals)
        + " + " + US_ColorBonusValue(bonus, decimals)
        + " = " + US_ColorTotalValue(finalVal, decimals);
}

string US_FormatStatLinePct(string name, float base, float total, float pct, int decimals) {
    if (US_IsZero(pct)) {
        return US_FormatStatLine(name, base, total, decimals);
    }
    float bonus = total - base;
    float finalVal = (base + bonus) * (1 + pct);
    return name + ": " + US_ColorBaseValue(base, decimals)
        + " + " + US_ColorBonusValue(bonus, decimals)
        + " x " + US_FormatPercentText(pct, true)
        + " = " + US_ColorTotalValue(finalVal, decimals);
}

string US_FormatStatLinePercentValue(string name, float basePct, float totalPct, int decimals = 0) {
    float bonus = totalPct - basePct;
    float finalVal = basePct + bonus;
    return name + ": " + US_ColorBasePercent(basePct, false, decimals)
        + " + " + US_ColorBonusPercent(bonus, false, decimals)
        + " = " + US_ColorTotalPercent(finalVal, false, decimals);
}

string US_MainStatName(int mainStatType) {
    int t = mainStatType;
    if (t == 1) return "Сила";
    if (t == 2) return "Ловкость";
    if (t == 3) return "Разум";
    return "Неизвестно";
}

void US_BuildLines(UnitData@ ud, unit u, array<string>@ lines) {
    lines.resize(0);
    if (u != nil) {
        lines.insertLast("|cffffcc00Юнит:|r " + Jass::GetUnitName(u));
    }

    lines.insertLast("|cffffcc00Атрибуты|r");
    lines.insertLast(US_FormatStatLinePct("Сила", ud.baseStats.strength, ud.totalStats.strength, ud.totalStats.strengthPct, 0));
    lines.insertLast(US_FormatStatLinePct("Ловкость", ud.baseStats.agility, ud.totalStats.agility, ud.totalStats.agilityPct, 0));
    lines.insertLast(US_FormatStatLinePct("Разум", ud.baseStats.intelligence, ud.totalStats.intelligence, ud.totalStats.intelligencePct, 0));
    lines.insertLast("Основной стат: " + US_MainStatName(ud.baseStats.mainStatType));
    float mainBonus = ud.totalStats.mainStat - ud.baseStats.mainStat;
    lines.insertLast(US_FormatStatLinePct("Бонус осн. стата", 0, mainBonus, ud.totalStats.mainStatPct, 0));

    lines.insertLast("|cffffcc00Здоровье/Мана|r");
    lines.insertLast(US_FormatStatLinePct("ХП", ud.baseStats.hp, ud.totalStats.hp, ud.totalStats.hpPct, 0));
    lines.insertLast(US_FormatStatLinePct("МП", ud.baseStats.mp, ud.totalStats.mp, ud.totalStats.mpPct, 0));
    lines.insertLast(US_FormatStatLinePct("Реген ХП", ud.baseStats.hpRegen, ud.totalStats.hpRegen, ud.totalStats.hpRegenPct, 1));
    lines.insertLast(US_FormatStatLinePercentValue("Реген ХП %", ud.baseStats.hpRegenPercent * 100.0, ud.totalStats.hpRegenPercent * 100.0));
    lines.insertLast(US_FormatStatLinePct("Реген МП", ud.baseStats.mpRegen, ud.totalStats.mpRegen, ud.totalStats.mpRegenPct, 1));

    lines.insertLast("|cffffcc00Атака|r");
    lines.insertLast(US_FormatStatLinePct("Урон", ud.baseStats.damage, ud.totalStats.damage, ud.totalStats.damagePct, 0));
    lines.insertLast(US_FormatStatLinePct("Скорость атаки", ud.baseStats.attackSpeed, ud.totalStats.attackSpeed, ud.totalStats.attackSpeedPct, 2));
    lines.insertLast(US_FormatStatLinePercentValue("Крит урон", ud.baseStats.critDamage, ud.totalStats.critDamage));
    lines.insertLast(US_FormatStatLinePercentValue("Крит шанс", ud.baseStats.critChance, ud.totalStats.critChance));
    lines.insertLast(US_FormatStatLinePercentValue("Шанс стана", ud.baseStats.stunChance, ud.totalStats.stunChance));
    lines.insertLast(US_FormatStatLine("Длительность стана", ud.baseStats.stunDuration, ud.totalStats.stunDuration, 1));

    lines.insertLast("|cffffcc00Защита|r");
    lines.insertLast(US_FormatStatLinePct("Броня", ud.baseStats.armor, ud.totalStats.armor, ud.totalStats.armorPct, 0));
    lines.insertLast(US_FormatStatLine("Блок", ud.baseStats.block, ud.totalStats.block, 0));
    lines.insertLast(US_FormatStatLinePercentValue("Сопротивление маг.", ud.baseStats.resistMagic * 100.0, ud.totalStats.resistMagic * 100.0));
    lines.insertLast(US_FormatStatLinePercentValue("Сопротивление физ.", ud.baseStats.resistPhysical * 100.0, ud.totalStats.resistPhysical * 100.0));
    lines.insertLast(US_FormatStatLinePercentValue("Сопротивление общ.", ud.baseStats.resistAll * 100.0, ud.totalStats.resistAll * 100.0));

    lines.insertLast("|cffffcc00Модификаторы урона|r");
    lines.insertLast(US_FormatStatLinePercentValue("Бонус физ. урона", ud.baseStats.bonusPhysDamage * 100.0, ud.totalStats.bonusPhysDamage * 100.0));
    lines.insertLast(US_FormatStatLinePercentValue("Бонус маг. урона", ud.baseStats.bonusMagDamage * 100.0, ud.totalStats.bonusMagDamage * 100.0));
    lines.insertLast(US_FormatStatLinePercentValue("Бонус всего урона", ud.baseStats.bonusAllDamage * 100.0, ud.totalStats.bonusAllDamage * 100.0));

    lines.insertLast("|cffffcc00Хил|r");
    lines.insertLast(US_FormatStatLinePercentValue("Получаемый хил", ud.baseStats.healReceived * 100.0, ud.totalStats.healReceived * 100.0));
    lines.insertLast(US_FormatStatLinePercentValue("Исходящий хил", ud.baseStats.healOutput * 100.0, ud.totalStats.healOutput * 100.0));

    lines.insertLast("|cffffcc00Прочее|r");
    lines.insertLast(US_FormatStatLinePct("Скорость бега", ud.baseStats.moveSpeed, ud.totalStats.moveSpeed, ud.totalStats.moveSpeedPct, 0));
    lines.insertLast(US_FormatStatLinePct("Радиус", ud.baseStats.radius, ud.totalStats.radius, ud.totalStats.radiusPct, 0));
    lines.insertLast(US_FormatStatLinePct("Обнаружение", ud.baseStats.detection, ud.totalStats.detection, ud.totalStats.detectionPct, 0));
    lines.insertLast(US_FormatStatLinePct("Удача", ud.baseStats.luck, ud.totalStats.luck, ud.totalStats.luckPct, 0));
}

int US_GetTotalPages(int totalLines) {
    int pages = (totalLines + US_LINES_PER_PAGE - 1) / US_LINES_PER_PAGE;
    if (pages < 1) pages = 1;
    return pages;
}

void US_UpdatePlayer(int pid) {
    if (!US_IsOpen[pid]) return;

    unit u = Selectedunit[pid];
    array<string> lines;

    if (u == nil) {
        lines.insertLast("|cffff5555Нет выбранного юнита|r");
    } else {
        UnitData@ ud = GetUnitData(u);
        if (ud is null) {
            RegisterUnit(u);
            @ud = GetUnitData(u);
        }
        if (ud is null) {
            lines.insertLast("|cffff5555Нет данных по статам|r");
        } else {
            US_BuildLines(ud, u, lines);
        }
    }

    int totalLines = int(lines.length());
    int totalPages = US_GetTotalPages(totalLines);
    if (US_Page[pid] >= totalPages) US_Page[pid] = totalPages - 1;
    if (US_Page[pid] < 0) US_Page[pid] = 0;
    int startIdx = US_Page[pid] * US_LINES_PER_PAGE;

        for (int i = 0; i < US_LINES_PER_PAGE; i++) {
            int idx = startIdx + i;
            if (idx < totalLines) {
                if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
                    Jass::SetFrameText(US_Lines[i], lines[idx]);
                }
                if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
                    Jass::ShowFrame(US_Lines[i], true);
                }
            } else {
                if (Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::ShowFrame(US_Lines[i], false);
            }
        }
        if (Jass::GetLocalPlayer() == Jass::Player(pid))
        {
            Jass::SetFrameText(US_PageText, Jass::I2S(US_Page[pid] + 1) + "/" + Jass::I2S(totalPages));
            Jass::ShowFrame(US_PrevBtn, totalPages > 1 && US_Page[pid] > 0);
            Jass::ShowFrame(US_NextBtn, totalPages > 1 && US_Page[pid] < totalPages - 1);
        }
}

void US_Show(int pid) {
    US_IsOpen[pid] = true;
    US_Page[pid] = 0;
    if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
        Jass::ShowFrame(US_Backdrop, true);
        Jass::ShowFrame(US_CloseBtn, true);
        Jass::ShowFrame(US_PageText, true);
        Jass::ShowFrame(US_PrevBtn, false);
        Jass::ShowFrame(US_NextBtn, false);
    }
    US_UpdatePlayer(pid);
}

void US_Hide(int pid) {
    US_IsOpen[pid] = false;
    if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
        Jass::ShowFrame(US_Backdrop, false);
        Jass::ShowFrame(US_CloseBtn, false);
        Jass::ShowFrame(US_PageText, false);
        Jass::ShowFrame(US_PrevBtn, false);
        Jass::ShowFrame(US_NextBtn, false);
    }
}

void OpenUnitStatsFrame(int pid) {
    CF_OpenPanel(pid, US_PANEL_ID);
    if (CF_ActivePanelId[pid] != US_PANEL_ID) return;
    US_Show(pid);
}

void CloseUnitStatsFrame(int pid) {
    US_Hide(pid);
    if (CF_ActivePanelId[pid] == US_PANEL_ID) CF_ActivePanelId[pid] = 0;
}

void InitUnitStatsFrame() {
    US_Lines.resize(US_LINES_PER_PAGE);

    framehandle gameUI = Jass::GetOriginFrame(Jass::ORIGIN_FRAME_GAME_UI, 0);
    framehandle heroBtn = Jass::GetOriginFrame(Jass::ORIGIN_FRAME_HERO_BUTTON, 0);

    US_OpenBtn = Jass::CreateFrameByType("SIMPLEBUTTON", "US_OpenBtn", gameUI, "", 0);
    Jass::ClearFrameAllPoints(US_OpenBtn);
    Jass::SetFrameSize(US_OpenBtn, 0.020, 0.020);
    Jass::SetFrameTexture(US_OpenBtn, "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 1, true);
    Jass::SetFrameRelativePoint(US_OpenBtn, Jass::FRAMEPOINT_LEFT, heroBtn, Jass::FRAMEPOINT_RIGHT, 0.002, 0.017);
    Jass::SetFramePriority(US_OpenBtn, 6);
    Jass::ShowFrame(US_OpenBtn, true);

    US_Backdrop = Jass::CreateFrameByType("SIMPLEFRAME", "US_Backdrop", gameUI, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_Backdrop);
    Jass::SetFrameSize(US_Backdrop, US_PANEL_W, US_PANEL_H);
    Jass::SetFrameAbsolutePoint(US_Backdrop, Jass::FRAMEPOINT_TOPLEFT, 0.04, 0.58);
    Jass::SetFrameTextureEx(US_Backdrop, 0,
        "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-background", false,
        "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-border", Jass::BORDER_FLAG_ALL);
    Jass::SetFramePriority(US_Backdrop, 0);
    Jass::ShowFrame(US_Backdrop, false);

    US_Title = Jass::CreateFrameByType("SIMPLETEXT", "US_Title", US_Backdrop, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_Title);
    Jass::SetFrameFont(US_Title, "Fonts\\FRIZQT__.TTF", 0.012, 0);
    Jass::SetFrameText(US_Title, "|cffffcc00Статы|r");
    Jass::SetFrameTextAlignment(US_Title, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_CENTER);
    Jass::SetFrameRelativePoint(US_Title, Jass::FRAMEPOINT_TOP, US_Backdrop, Jass::FRAMEPOINT_TOP, 0, -0.008);
    Jass::SetFrameSize(US_Title, US_PANEL_W - 0.04, 0.018);
    Jass::ShowFrame(US_Title, true);

    US_CloseBtn = Jass::CreateFrameByType("SIMPLEBUTTON", "US_CloseBtn", US_Backdrop, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_CloseBtn);
    Jass::SetFrameSize(US_CloseBtn, 0.018, 0.018);
    Jass::SetFrameRelativePoint(US_CloseBtn, Jass::FRAMEPOINT_TOPRIGHT, US_Backdrop, Jass::FRAMEPOINT_TOPRIGHT, -0.003, -0.003);
    Jass::SetFrameTexture(US_CloseBtn, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp", 1, true);
    Jass::ShowFrame(US_CloseBtn, false);

    for (int i = 0; i < US_LINES_PER_PAGE; i++) {
        US_Lines[i] = Jass::CreateFrameByType("SIMPLETEXT", "US_Line", US_Backdrop, "", US_FrameCtx);
        US_FrameCtx++;
        Jass::ClearFrameAllPoints(US_Lines[i]);
        Jass::SetFrameFont(US_Lines[i], "Fonts\\FRIZQT__.TTF", 0.009, 0);
        Jass::SetFrameTextAlignment(US_Lines[i], Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_LEFT);
        Jass::SetFrameRelativePoint(US_Lines[i], Jass::FRAMEPOINT_TOPLEFT, US_Backdrop, Jass::FRAMEPOINT_TOPLEFT, 0.010, -0.030 - i * US_LINE_HEIGHT);
        Jass::SetFrameSize(US_Lines[i], US_PANEL_W - 0.02, US_LINE_HEIGHT);
        Jass::SetFrameText(US_Lines[i], "");
        Jass::ShowFrame(US_Lines[i], false);
    }

    US_PageText = Jass::CreateFrameByType("SIMPLETEXT", "US_PageText", US_Backdrop, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_PageText);
    Jass::SetFrameFont(US_PageText, "Fonts\\FRIZQT__.TTF", 0.010, 0);
    Jass::SetFrameTextAlignment(US_PageText, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_CENTER);
    Jass::SetFrameRelativePoint(US_PageText, Jass::FRAMEPOINT_BOTTOM, US_Backdrop, Jass::FRAMEPOINT_BOTTOM, 0, 0.008);
    Jass::SetFrameSize(US_PageText, 0.06, 0.014);
    Jass::SetFrameText(US_PageText, "1/1");
    Jass::ShowFrame(US_PageText, false);

    US_PrevBtn = Jass::CreateFrameByType("SIMPLEBUTTON", "US_PrevBtn", US_Backdrop, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_PrevBtn);
    Jass::SetFrameSize(US_PrevBtn, 0.018, 0.018);
    Jass::SetFrameRelativePoint(US_PrevBtn, Jass::FRAMEPOINT_RIGHT, US_PageText, Jass::FRAMEPOINT_LEFT, -0.004, 0.0);
    Jass::SetFrameTexture(US_PrevBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp", 1, true);
    Jass::ShowFrame(US_PrevBtn, false);

    US_NextBtn = Jass::CreateFrameByType("SIMPLEBUTTON", "US_NextBtn", US_Backdrop, "", US_FrameCtx);
    US_FrameCtx++;
    Jass::ClearFrameAllPoints(US_NextBtn);
    Jass::SetFrameSize(US_NextBtn, 0.018, 0.018);
    Jass::SetFrameRelativePoint(US_NextBtn, Jass::FRAMEPOINT_LEFT, US_PageText, Jass::FRAMEPOINT_RIGHT, 0.004, 0.0);
    Jass::SetFrameTexture(US_NextBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 1, true);
    Jass::ShowFrame(US_NextBtn, false);

    trigger openTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(openTrg, US_OpenBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(openTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        OpenUnitStatsFrame(pid);
    });

    trigger closeTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(closeTrg, US_CloseBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(closeTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        CloseUnitStatsFrame(pid);
    });

    trigger prevTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(prevTrg, US_PrevBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(prevTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        if (US_Page[pid] > 0) {
            US_Page[pid]--;
            US_UpdatePlayer(pid);
        }
    });

    trigger nextTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(nextTrg, US_NextBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(nextTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        US_Page[pid]++;
        US_UpdatePlayer(pid);
    });

    Jass::TimerStart(Jass::CreateTimer(), 0.33, true, function() {
        for (int pid = 0; pid < 10; pid++) {
            if (US_IsOpen[pid]) {
                US_UpdatePlayer(pid);
            }
        }
    });

    CF_RegisterPanel(US_PANEL_ID, @US_Hide);
}
