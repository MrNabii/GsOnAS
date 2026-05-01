// ============================================================
//  Cheats.as — Чит-пак (портировано из JASS)
//  Только самодостаточные функции, без внешних систем.
// ============================================================

// ---------- Глобальные ----------
hashtable nzHash = Jass::InitHashtable();
bool dd = false;

// ---------- Утилиты хеш-таблицы ----------
int GlobalHandle() {
    return Jass::GetHandleId(nzHash);
}

void SaveUnit(string hashName, unit target) {
    Jass::RemoveSavedHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName));
    Jass::SaveUnitHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName), target);
}

unit LoadUnit(string hashName) {
    return Jass::LoadUnitHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName));
}

trigger LoadTrig(string hashName) {
    if (Jass::LoadTriggerHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName)) == nil) {
        Jass::SaveTriggerHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName), Jass::CreateTrigger());
    }
    return Jass::LoadTriggerHandle(nzHash, GlobalHandle(), Jass::StringHash(hashName));
}

group CP_EnumUnits() {
    return Jass::LoadGroupHandle(nzHash, GlobalHandle(), Jass::StringHash("GlobalGroup"));
}

string LoadPlayerColors(player p) {
    if (!Jass::LoadBoolean(nzHash, GlobalHandle(), Jass::StringHash("PlayerColors"))) {
        Jass::SaveStr(nzHash, GlobalHandle(), 0, "|cFFff0303");
        Jass::SaveStr(nzHash, GlobalHandle(), 1, "|cFF0041ff");
        Jass::SaveStr(nzHash, GlobalHandle(), 2, "|cFF1ce6b9");
        Jass::SaveStr(nzHash, GlobalHandle(), 3, "|cFF540081");
        Jass::SaveStr(nzHash, GlobalHandle(), 4, "|cFFfffc00");
        Jass::SaveStr(nzHash, GlobalHandle(), 5, "|cFFfe8a0e");
        Jass::SaveStr(nzHash, GlobalHandle(), 6, "|cFF20c000");
        Jass::SaveStr(nzHash, GlobalHandle(), 7, "|cFFde5bb0");
        Jass::SaveStr(nzHash, GlobalHandle(), 8, "|cFF959697");
        Jass::SaveStr(nzHash, GlobalHandle(), 9, "|cFF7ebff1");
        Jass::SaveStr(nzHash, GlobalHandle(), 10, "|cFF106246");
        Jass::SaveStr(nzHash, GlobalHandle(), 11, "|cFF4e2a04");
        Jass::SaveStr(nzHash, GlobalHandle(), 12, "|cFF9b0000");
        Jass::SaveStr(nzHash, GlobalHandle(), 13, "|cFF0000c3");
        Jass::SaveStr(nzHash, GlobalHandle(), 14, "|cFF00eaff");
        Jass::SaveStr(nzHash, GlobalHandle(), 15, "|cFFbe00fe");
        Jass::SaveStr(nzHash, GlobalHandle(), 16, "|cFFebcd87");
        Jass::SaveStr(nzHash, GlobalHandle(), 17, "|cFFf8a48b");
        Jass::SaveStr(nzHash, GlobalHandle(), 18, "|cFFdcb9eb");
        Jass::SaveStr(nzHash, GlobalHandle(), 19, "|cFFbfff80");
        Jass::SaveStr(nzHash, GlobalHandle(), 20, "|cFF282828");
        Jass::SaveStr(nzHash, GlobalHandle(), 21, "|cFFebf0ff");
        Jass::SaveStr(nzHash, GlobalHandle(), 22, "|cFF00781e");
        Jass::SaveStr(nzHash, GlobalHandle(), 23, "|cFFa46f33");
        Jass::SaveBoolean(nzHash, GlobalHandle(), Jass::StringHash("PlayerColors"), true);
    }
    return Jass::LoadStr(nzHash, GlobalHandle(), Jass::GetHandleId(Jass::GetPlayerColor(p))) + Jass::GetPlayerName(p) + "|r";
}

bool GetBool(string hashName) {
    return Jass::LoadBoolean(nzHash, Jass::GetHandleId(Jass::GetTriggerPlayer()), Jass::StringHash(hashName));
}

float GetInfo(unit target, string whatInfo) {
    return Jass::LoadReal(nzHash, Jass::GetHandleId(target), Jass::StringHash(whatInfo));
}

string GetStr(string hashName) {
    return Jass::LoadStr(nzHash, Jass::GetHandleId(Jass::GetExpiredTimer()), Jass::StringHash(hashName));
}

int GetInt(string hashName) {
    return Jass::LoadInteger(nzHash, Jass::GetHandleId(Jass::GetExpiredTimer()), Jass::StringHash(hashName));
}

int GetIntP(int i, string hashName) {
    return Jass::LoadInteger(nzHash, Jass::GetHandleId(Jass::Player(i)), Jass::StringHash(hashName));
}

int GetChtrLvl(player target) {
    return Jass::LoadInteger(nzHash, Jass::GetHandleId(target), Jass::StringHash("CheaterLvl"));
}

unit SelectedUnit(player locPlayer) {
    Jass::GroupEnumUnitsSelected(CP_EnumUnits(), locPlayer, nil);
    SaveUnit("SelectedUnit", Jass::FirstOfGroup(CP_EnumUnits()));
    Jass::GroupClear(CP_EnumUnits());
    return LoadUnit("SelectedUnit");
}

// ---------- Строковые утилиты ----------
int FindEmptyString(int begin, string text) {
    int len = Jass::StringLength(text);
    int i = begin;
    while (true) {
        if (Jass::SubString(text, i, i + 1) == " ")
            return i;
        if (i == len) break;
        i++;
    }
    return len;
}

int Char2Id(string input) {
    int pos = 0;
    string chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    string findChar;
    while (true) {
        findChar = Jass::SubString(chars, pos, pos + 1);
        if (findChar == "" or findChar == input) break;
        pos++;
    }
    if (pos < 10) return pos + 48;
    if (pos < 36) return pos + 65 - 10;
    return pos + 97 - 36;
}

int S2ID(string input) {
    return ((Char2Id(Jass::SubString(input, 0, 1)) * 256
           + Char2Id(Jass::SubString(input, 1, 2))) * 256
           + Char2Id(Jass::SubString(input, 2, 3))) * 256
           + Char2Id(Jass::SubString(input, 3, 4));
}

string Id2Char(int input) {
    int pos = input - 48;
    if (input >= 97)      pos = input - 97 + 36;
    else if (input >= 65) pos = input - 65 + 10;
    return Jass::SubString("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", pos, pos + 1);
}

string ID2S(int input) {
    int result = input / 256;
    string ch = Id2Char(input - 256 * result);
    input = result / 256;
    ch = Id2Char(result - 256 * input) + ch;
    result = input / 256;
    return Id2Char(result) + Id2Char(input - 256 * result) + ch;
}

bool Find_String(string str1, string str2) {
    string text = Jass::StringCase(str1, false);
    string toFind = Jass::StringCase(str2, false);
    int i = 0;
    int idx = Jass::StringLength(toFind);
    int textLen = Jass::StringLength(text);
    if (idx > textLen) return false;
    while (true) {
        if (Jass::SubString(text, i, i + idx) == toFind)
            return true;
        if (i + idx > textLen) break;
        i++;
    }
    return false;
}

string New_Item_ID(string itemID) {
    int i = 0;
    string chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int charsLen = Jass::StringLength(chars);
    array<int> pos(4);

    i = 0;
    while (Jass::SubString(itemID, 3, 4) != Jass::SubString(chars, i, i + 1)) i++;
    pos[3] = pos[3] + i + 1;
    if (pos[3] == charsLen) { pos[3] = 0; pos[2] = pos[2] + 1; }

    i = 0;
    while (Jass::SubString(itemID, 2, 3) != Jass::SubString(chars, i, i + 1)) i++;
    pos[2] = pos[2] + i;
    if (pos[2] == charsLen) { pos[2] = 0; pos[1] = pos[1] + 1; }

    i = 0;
    while (Jass::SubString(itemID, 1, 2) != Jass::SubString(chars, i, i + 1)) i++;
    pos[1] = pos[1] + i;
    if (pos[1] >= charsLen) pos[1] = charsLen;

    return "I" + Jass::SubString(chars, pos[1], pos[1] + 1)
              + Jass::SubString(chars, pos[2], pos[2] + 1)
              + Jass::SubString(chars, pos[3], pos[3] + 1);
}

// ---------- Юнит-хелперы ----------
float UnitMaxLife(unit target) {
    return Jass::GetUnitState(target, Jass::UNIT_STATE_MAX_LIFE);
}

float UnitRestoreLife(unit target, float value) {
    float curHp = Jass::GetUnitState(target, Jass::UNIT_STATE_LIFE);
    if (curHp + value >= UnitMaxLife(target))
        value = UnitMaxLife(target) - curHp;
    Jass::SetUnitState(target, Jass::UNIT_STATE_LIFE, curHp + value);
    return value;
}

float UnitMaxMana(unit target) {
    return Jass::GetUnitState(target, Jass::UNIT_STATE_MAX_MANA);
}

float UnitRestoreMana(unit target, float value) {
    float curMp = Jass::GetUnitState(target, Jass::UNIT_STATE_MANA);
    if (curMp + value >= UnitMaxMana(target))
        value = UnitMaxMana(target) - curMp;
    Jass::SetUnitState(target, Jass::UNIT_STATE_MANA, curMp + value);
    return value;
}

// ---------- Текстовая метка ----------
void MakeTextTag(unit targ, string text, float size, float speed, float angle,
                 float lifespan, float fadepoint, bool flag, bool visibility) {
    speed = speed * 0.071 / 128;
    size = size * 0.023 / 10;
    texttag tt = Jass::CreateTextTag();
    Jass::SetTextTagText(tt, text, size);
    Jass::SetTextTagPos(tt, Jass::GetUnitX(targ), Jass::GetUnitY(targ), 50);
    Jass::SetTextTagVelocity(tt, speed * Jass::Cos(Jass::GetRandomReal(1, 180) * 0.01745329),
                                  speed * Jass::Sin(angle * 0.01745329));
    Jass::SetTextTagPermanent(tt, flag);
    Jass::SetTextTagLifespan(tt, lifespan);
    Jass::SetTextTagFadepoint(tt, fadepoint);
    if (visibility)
        Jass::SetTextTagVisibility(tt, true);
    else
        Jass::SetTextTagVisibility(tt, Jass::GetLocalPlayer() == Jass::GetOwningPlayer(targ));
    tt = nil;
}

// ---------- Блокировка урона ----------
void BlockDMGAct() {
    int handleID = Jass::GetHandleId(Jass::GetExpiredTimer());
    UnitRestoreLife(Jass::LoadUnitHandle(nzHash, handleID, Jass::StringHash("TargetedUnit")),
                    Jass::LoadReal(nzHash, handleID, Jass::StringHash("DamageTaken")));
    Jass::PauseTimer(Jass::GetExpiredTimer());
    Jass::FlushChildHashtable(nzHash, handleID);
    Jass::DestroyTimer(Jass::GetExpiredTimer());
}

void BlockDMG_Init(unit target, float damage, timer t, float delay, bool typ) {
    int handleID = Jass::GetHandleId(t);
    Jass::SaveUnitHandle(nzHash, handleID, Jass::StringHash("TargetedUnit"), target);
    Jass::SaveReal(nzHash, handleID, Jass::StringHash("DamageTaken"), damage);
    Jass::TimerStart(t, delay, typ, @BlockDMGAct);
}

float DetectDmgDealt(float def, float buffed) {
    if (buffed > 1) return buffed;
    return def;
}

// ---------- Инвентарь ----------
int GetInventoryIndexOfItem(unit source, int itemId, item ignoreditem) {
    for (int index = 0; index < 6; index++) {
        item slotItem = Jass::UnitItemInSlot(source, index);
        bool match = (slotItem != ignoreditem and Jass::GetItemTypeId(slotItem) == itemId);
        slotItem = nil;
        if (match) return index;
    }
    return -1;
}

// ---------- Таймер-колбэки ----------
void ResetCDAction() {
    int h = Jass::GetHandleId(Jass::GetExpiredTimer());
    Jass::UnitResetCooldown(Jass::LoadUnitHandle(nzHash, h, Jass::StringHash("CDUnit")));
}

void RegenHPMPAction() {
    int h = Jass::GetHandleId(Jass::GetExpiredTimer());
    float val = Jass::LoadReal(nzHash, h, Jass::StringHash("RGHPMP"));
    UnitRestoreLife(Jass::LoadUnitHandle(nzHash, h, Jass::StringHash("RGUnit")), val);
    UnitRestoreMana(Jass::LoadUnitHandle(nzHash, h, Jass::StringHash("RGUnit")), val);
}

// ---------- Событийные колбэки ----------
void FastBUTAct() {
    if (GetBool("BUTFast")) {
        Jass::CreateUnit(Jass::GetTriggerPlayer(), Jass::GetTrainedUnitType(),
                         Jass::GetUnitX(Jass::GetTriggerUnit()), Jass::GetUnitY(Jass::GetTriggerUnit()), 270);
        Jass::UnitSetConstructionProgress(Jass::GetTriggerUnit(), 100);
        Jass::UnitSetUpgradeProgress(Jass::GetTriggerUnit(), 100);
        Jass::SetPlayerTechResearched(Jass::GetTriggerPlayer(), Jass::GetResearched(),
            Jass::GetPlayerTechCount(Jass::GetTriggerPlayer(), Jass::GetResearched(), true) + 1);
    }
}

void InfiniteItem_Act() {
    if (GetBool("InfiniteCharge")) {
        int idx = GetInventoryIndexOfItem(Jass::GetManipulatingUnit(), Jass::GetItemTypeId(Jass::GetManipulatedItem()), nil);
        item slotItm = Jass::UnitItemInSlot(Jass::GetManipulatingUnit(), idx);
        if (Jass::GetItemTypeId(Jass::GetManipulatedItem()) == Jass::GetItemTypeId(slotItm)) {
            Jass::SetItemCharges(Jass::GetManipulatedItem(), Jass::GetItemCharges(Jass::GetManipulatedItem()) + 1);
        }
        slotItm = nil;
    }
}

void GoldRating() {
    int handleID = Jass::GetHandleId(Jass::GetTriggerPlayer());
    int pCgv = Jass::LoadInteger(nzHash, handleID, Jass::StringHash("CurrentGold"));
    int pCgp = Jass::LoadInteger(nzHash, handleID, Jass::StringHash("GoldRatePercentage"));
    if (GetBool("GoldRate")) {
        if (Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_GOLD) > pCgv) {
            Jass::DisableTrigger(Jass::GetTriggeringTrigger());
            int curGold = Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_GOLD);
            Jass::SetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_GOLD,
                curGold + Jass::R2I((curGold - pCgv) * (pCgp / 100.)));
            Jass::EnableTrigger(Jass::GetTriggeringTrigger());
        }
    }
    Jass::SaveInteger(nzHash, handleID, Jass::StringHash("CurrentGold"),
        Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_GOLD));
}

void LumberRating() {
    int handleID = Jass::GetHandleId(Jass::GetTriggerPlayer());
    int pClv = Jass::LoadInteger(nzHash, handleID, Jass::StringHash("CurrentLumber"));
    int pClp = Jass::LoadInteger(nzHash, handleID, Jass::StringHash("LumberRatePercentage"));
    if (GetBool("LumberRate")) {
        if (Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_LUMBER) > pClv) {
            Jass::DisableTrigger(Jass::GetTriggeringTrigger());
            int curLumber = Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_LUMBER);
            Jass::SetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_LUMBER,
                curLumber + Jass::R2I((curLumber - pClv) * (pClp / 100.)));
            Jass::EnableTrigger(Jass::GetTriggeringTrigger());
        }
    }
    Jass::SaveInteger(nzHash, handleID, Jass::StringHash("CurrentLumber"),
        Jass::GetPlayerState(Jass::GetTriggerPlayer(), Jass::PLAYER_STATE_RESOURCE_LUMBER));
}

// ---------- Активация ----------
void ActEvent(int PID) {
    if (Jass::LoadBoolean(nzHash, Jass::GetHandleId(Jass::Player(PID)), Jass::StringHash("CPenabled"))) {
        Jass::DisplayTextToPlayer(Jass::Player(PID), 0, 0, "You already have |cFF00cc66activated|r |cFF3366ffNZCP|r.");
    } else {
        Jass::SaveBoolean(nzHash, Jass::GetHandleId(Jass::Player(PID)), Jass::StringHash("CPenabled"), true);
        Jass::SaveInteger(nzHash, Jass::GetHandleId(Jass::Player(PID)), Jass::StringHash("CheaterLvl"), 1);
        Jass::DisplayTextToPlayer(Jass::Player(PID), 0, 0,
            "|cFF038CFCNUZAMACUXE|r's CHEAT PACK has been |cFF00cc66activated|r!");
    }
}

void ArrowAct() {
    Debug("ArrowAct", "Arrow key pressed");
    int i = Jass::LoadInteger(nzHash, Jass::GetHandleId(Jass::GetTriggerPlayer()), Jass::StringHash("Lenght"));
    eventid aid = Jass::GetTriggerEventId();
    string seq = Jass::LoadStr(nzHash, GlobalHandle(), Jass::StringHash("ArrowSequence"));
    string expected = Jass::SubString(seq, i, i + 1);
    string got = Jass::LoadStr(nzHash, GlobalHandle(), Jass::GetHandleId(aid));

    if (expected == got) {
        if (i == Jass::StringLength(seq) - 1) {
            ActEvent(Jass::GetPlayerId(Jass::GetTriggerPlayer()));
            Jass::SaveInteger(nzHash, Jass::GetHandleId(Jass::GetTriggerPlayer()), Jass::StringHash("Lenght"), 0);
        } else {
            Jass::SaveInteger(nzHash, Jass::GetHandleId(Jass::GetTriggerPlayer()), Jass::StringHash("Lenght"), i + 1);
        }
    } else {
        Jass::SaveInteger(nzHash, Jass::GetHandleId(Jass::GetTriggerPlayer()), Jass::StringHash("Lenght"), 0);
    }
    aid = nil;
}

// ---------- Поиск предметов ----------
void ItemSearch() {
    int handleID = Jass::GetHandleId(Jass::GetExpiredTimer());
    string itemID = GetStr("Item_ID");
    string itemName = Jass::GetObjectName(S2ID(itemID));

    if (itemName != "Default string" and itemName != "") {
        if (Find_String(itemName, GetStr("To_Find"))) {
            Jass::Preload("Item ID: " + itemID + " Name: " + itemName);
            Jass::DisplayTimedTextToPlayer(Jass::Player(GetInt("PID")), 0, 0, 10,
                "|cFF00aaffItem ID:|r " + itemID + " |cFF00aaffName:|r " + itemName);
        }
    }
    if (itemID == "I0ZZ") {
        Jass::PauseTimer(Jass::GetExpiredTimer());
        Jass::PreloadGenEnd("[CP] ItemsExport\\Items [" + Jass::LoadStr(nzHash, handleID, Jass::StringHash("To_Find")) + "].txt");
        Jass::DisplayTimedTextToPlayer(Jass::Player(GetInt("PID")), 0, 0, 10,
            "Items file saved: [CP] ItemsExport/Items [" + Jass::LoadStr(nzHash, handleID, Jass::StringHash("To_Find")) + "].txt");
        Jass::FlushChildHashtable(nzHash, handleID);
        Jass::DestroyTimer(Jass::GetExpiredTimer());
    } else {
        Jass::SaveStr(nzHash, handleID, Jass::StringHash("Item_ID"), New_Item_ID(itemID));
    }
}

void ItemSearch_Init(int PID, string text, timer t, float delay, bool typ) {
    int handleID = Jass::GetHandleId(t);
    Jass::SaveInteger(nzHash, handleID, Jass::StringHash("PID"), PID);
    Jass::SaveStr(nzHash, handleID, Jass::StringHash("To_Find"), text);
    Jass::SaveStr(nzHash, handleID, Jass::StringHash("Item_ID"), "I000");
    Jass::PreloadGenClear();
    Jass::PreloadGenStart();
    Jass::TimerStart(t, delay, typ, @ItemSearch);
}

// ============================================================
//  CP_Commands — Обработчик чит-команд (чат с префиксом "-")
// ============================================================
void CP_Commands() {
    int PID = Jass::GetPlayerId(Jass::GetTriggerPlayer());
    int Value = 0;
    int Value2 = 0;
    int V3 = 0;
    float Value3 = 0;
    string chatStr = Jass::GetEventPlayerChatString();
    int chatLen = Jass::StringLength(chatStr);
    string Text = Jass::SubString(chatStr, 1, chatLen);
    int EmptyAt = FindEmptyString(0, Text);
    string Command = Jass::SubString(Text, 0, EmptyAt);
    string Payload = Jass::SubString(Text, EmptyAt + 1, chatLen);
    int EmptyAt2 = FindEmptyString(0, Payload);
    string Payload2 = Jass::SubString(Payload, EmptyAt2 + 1, chatLen);
    int EmptyAt3 = FindEmptyString(0, Payload2);
    string Payload3 = Jass::SubString(Payload2, EmptyAt3 + 1, chatLen);
    int HandleP = Jass::GetHandleId(Jass::Player(PID));
    int i = 0;
    unit u;
    group g;
    item itm;
    timer t;
    ability abil;
    Debug("CP_Commands", "Writen command: " + Text);
    // Активатор текстом
    if (Text == Jass::LoadStr(nzHash, GlobalHandle(), Jass::StringHash("Activator"))) {
        ActEvent(PID);
    }
    if (GetBool("CPenabled")) {
        Value = Jass::S2I(Payload);
        Value2 = Jass::S2I(Payload2);
        V3 = Jass::S2I(Payload3);
        Value3 = Jass::S2R(Payload2);
        SaveUnit("nzUnitSys", SelectedUnit(Jass::Player(PID)));

        if (GetChtrLvl(Jass::Player(PID)) >= GetChtrLvl(Jass::GetOwningPlayer(LoadUnit("nzUnitSys")))) {
            // -lvl <N>
            if (Command == "lvl") {
                if (Jass::IsUnitType(LoadUnit("nzUnitSys"), Jass::UNIT_TYPE_HERO)) {
                    if (Value > Jass::GetHeroLevel(LoadUnit("nzUnitSys")))
                        Jass::SetHeroLevel(LoadUnit("nzUnitSys"), Value, false);
                    else
                        Jass::UnitStripHeroLevel(LoadUnit("nzUnitSys"), Jass::GetHeroLevel(LoadUnit("nzUnitSys")) - Value);
                }
            }
            if (Command == "Glibis") {
                ForGroupAction(Ores, LoadUnit("nzUnitSys"), function(unit source, unit target) {
                    Jass::PingMinimap(Jass::GetUnitX(target), Jass::GetUnitY(target), 10);
                });
            }
            if (Command == "F1") {
                framehandle simple_btn;
                float width = .012/0.8;
                float height = .012/0.6;
                float x_offset = .001/0.8;
                float y_offset = .001/0.6;
                float x_margin = width * .01;
                float y_margin = height * .01;
                int MAX_COLUMNS = 12, MAX_ROWS = 2;
                float x = 0, y = 0;

                for (int j = 0; j <= MAX_COLUMNS * MAX_ROWS - 1; j++) {
                    simple_btn = Jass::GetFrameByName("BuffSystem_BuffPlaceHolder", j);
                    Jass::ClearFrameAllPoints(simple_btn);
                    Jass::SetFrameSize(simple_btn, width, height);
                    x = Value*0.001 + x_offset + (Jass::MathIntegerModulo(j, MAX_COLUMNS) * width) + (Jass::MathIntegerModulo(j, MAX_COLUMNS) * x_margin);
                    y = Value2*0.001 + y_offset + (Jass::MathRealFloor(j / MAX_COLUMNS) * height) + (Jass::MathRealFloor(j / MAX_COLUMNS) * y_margin);
                    Jass::SetFrameAbsolutePoint(simple_btn, Jass::FRAMEPOINT_TOPLEFT, x, y);
                    Jass::SetFramePriority(simple_btn, 5);
                    Jass::SetFrameTexture(simple_btn, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp", 0, false);
                    //Jass::SetFrameTextureEx(simple_btn, 0, "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-background", false, "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-border", Jass::BORDER_FLAG_ALL);
                    Jass::ShowFrame(simple_btn, true);
                    Debug("CP_Commands", "\nCreated Buff Placeholder " + Jass::I2S(j) + " at (" + Jass::R2S(x) + ", " + Jass::R2S(y) + ")");
                    Debug("CP_Commands", "\nTexture: " + Jass::GetFrameTexture(simple_btn, 0));
                }
            }
            if (Command == "F2") {
                TestBuffSystem_AddBuff(LoadUnit("nzUnitSys"));
                TestBuffSystem_Stacks(LoadUnit("nzUnitSys"));
                TestBuffSystem_Aura(LoadUnit("nzUnitSys"));
            }
            if (Command == "F3") {
                Jass::ClearFrameAllPoints(Jass::GetOriginFrame(Jass::ORIGIN_FRAME_ITEM_BUTTON, 6));
                Jass::SetFrameAbsolutePoint(Jass::GetOriginFrame(Jass::ORIGIN_FRAME_ITEM_BUTTON, 6), Jass::FRAMEPOINT_TOPLEFT, Value*0.001, Value2*0.001);
            }

            // UI frame tools (works with any frame name + createContext)
            // -fscale <FrameName> <Context> <Scale>
            // -fshow  <FrameName> <Context>
            // -fhide  <FrameName> <Context>
            // -freset <FrameName> <Context>
            // -fmove  <FrameName> <Context> <X> <Y>
            if (Command == "fscale" or Command == "fshow" or Command == "fhide" or Command == "freset" or Command == "fmove") {
                int frameNameEnd = FindEmptyString(0, Payload);
                string frameName = Jass::SubString(Payload, 0, frameNameEnd);
                int frameContext = Jass::S2I(Payload2);
                framehandle targetFrame = nil;

                if (frameName == "") {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 12,
                        "Usage: -fscale <FrameName> <Context> <Scale> | -fshow/-fhide/-freset <FrameName> <Context> | -fmove <FrameName> <Context> <X> <Y>");
                } else {
                    if (Jass::GetLocalPlayer() == Jass::GetTriggerPlayer()) {
                        targetFrame = Jass::GetFrameByName(frameName, frameContext);
                        if (targetFrame != nil) {
                            if (Command == "fscale") {
                                float frameScale = Jass::S2R(Payload3);
                                if (frameScale <= 0.) frameScale = 0.001;
                                Jass::SetFrameScale(targetFrame, frameScale);
                            }
                            if (Command == "fshow") {
                                Jass::ShowFrame(targetFrame, true);
                            }
                            if (Command == "fhide") {
                                Jass::ShowFrame(targetFrame, false);
                            }
                            if (Command == "freset") {
                                Jass::SetFrameScale(targetFrame, 1.0);
                                Jass::ShowFrame(targetFrame, true);
                            }
                            if (Command == "fmove") {
                                int splitXY = FindEmptyString(0, Payload3);
                                float frameX = Jass::S2R(Payload3);
                                float frameY = 0.;
                                if (splitXY < Jass::StringLength(Payload3)) {
                                    frameY = Jass::S2R(Jass::SubString(Payload3, splitXY + 1, Jass::StringLength(Payload3)));
                                }
                                Jass::ClearFrameAllPoints(targetFrame);
                                Jass::SetFrameAbsolutePoint(targetFrame, Jass::FRAMEPOINT_TOPLEFT, frameX, frameY);
                            }
                        }
                    }
                    if (targetFrame == nil and Jass::GetLocalPlayer() == Jass::GetTriggerPlayer()) {
                        Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                            "Frame not found: " + frameName + " (ctx " + Jass::I2S(frameContext) + ")");
                    }
                }
                targetFrame = nil;
            }

            // -fhelp
            if (Command == "fhelp") {
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 20,
                    "UI frame cmds: -fscale name ctx scale, -fshow name ctx, -fhide name ctx, -freset name ctx, -fmove name ctx x y");
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 20,
                    "Icon ctx: SimpleInfoPanelIconDamage(0/1), Armor(2), Rank(3), Food(4), Gold(5), child: InfoPanelIconBackdrop/Level/Label/Value");
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 20,
                    "Hero ctx 6: SimpleInfoPanelIconHero, InfoPanelIconHeroIcon, SimpleInfoPanelIconHeroText, InfoPanelIconHeroStrength/Agility/Intellect Label+Value");
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 20,
                    "Ally ctx 7: SimpleInfoPanelIconAlly + InfoPanelIconAllyTitle/GoldIcon/GoldValue/WoodIcon/WoodValue/FoodIcon/FoodValue/Upkeep");
            }
            // -str <N>
            if (Command == "str") {
                Jass::SetHeroStr(LoadUnit("nzUnitSys"), Value, true);
            }
            // -agi <N>
            if (Command == "agi") {
                Jass::SetHeroAgi(LoadUnit("nzUnitSys"), Value, true);
            }
            // -int <N>
            if (Command == "int") {
                Jass::SetHeroInt(LoadUnit("nzUnitSys"), Value, true);
            }
            // -sp <N>
            if (Command == "sp") {
                Jass::UnitModifySkillPoints(LoadUnit("nzUnitSys"), Value);
            }
            // -hp <N>
            if (Command == "hp") {
                Jass::SetWidgetLife(LoadUnit("nzUnitSys"), Value);
            }
            // -mp <N>
            if (Command == "mp") {
                Jass::SetUnitState(LoadUnit("nzUnitSys"), Jass::UNIT_STATE_MANA, Value);
            }
            // -ms <N>
            if (Command == "ms") {
                Jass::SetUnitMoveSpeed(LoadUnit("nzUnitSys"), Value);
            }
            // -owner <N>
            if (Command == "owner") {
                if (Value >= 1 and Value <= 24)
                    Jass::SetUnitOwner(LoadUnit("nzUnitSys"), Jass::Player(Value - 1), true);
            }
            // -xp <N>
            if (Command == "xp") {
                Jass::SetHeroXP(LoadUnit("nzUnitSys"), Value, false);
            }
            // -vul / -invul
            if (Command == "vul" or Command == "invul") {
                Jass::SetUnitInvulnerable(LoadUnit("nzUnitSys"), (Command == "invul"));
            }
            // -kill
            if (Command == "kill") {
                Jass::KillUnit(LoadUnit("nzUnitSys"));
            }
            // -revive
            if (Command == "revive") {
                g = Jass::CreateGroup();
                Jass::GroupEnumUnitsOfPlayer(g, Jass::Player(PID), nil);
                u = Jass::FirstOfGroup(g);
                if (LoadUnit("nzUnitSys") == nil)
                    Jass::ReviveHero(u, Jass::GetUnitX(u), Jass::GetUnitY(u), false);
                else
                    Jass::ReviveHero(u, Jass::GetUnitX(LoadUnit("nzUnitSys")), Jass::GetUnitY(LoadUnit("nzUnitSys")), false);
                Jass::DestroyGroup(g);
                g = nil;
                u = nil;
            }
            // -removeu
            if (Command == "removeu") {
                Jass::RemoveUnit(SelectedUnit(Jass::Player(PID)));
            }
            // -charge <slot> <amount>
            if (Command == "charge") {
                if (Value >= 1 and Value <= 6) {
                    item slotItm = Jass::UnitItemInSlot(LoadUnit("nzUnitSys"), Value - 1);
                    if (slotItm != nil)
                        Jass::SetItemCharges(slotItm, Value2);
                    else
                        Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                            "There's |cFFff9900no item|r in slot |cFF00aaff" + Jass::I2S(Value) + "|r.");
                    slotItm = nil;
                }
            }
            // -dd (debug damage toggle)
            if (Command == "dd") {
                dd = !dd;
            }

            // -- Damage System Commands --
            SaveUnit("DMGUnit", SelectedUnit(Jass::Player(PID)));

            // -dmgc <chance> <multiplier>
            if (Command == "dmgc") {
                if (Jass::LoadInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageHP")) <= 0) {
                    if (Value != 0) {
                        if (Value3 > 1.) {
                            Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGCChance"), Value);
                            Jass::SaveReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGMultiplier"), Value3);
                            Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                                "Critical Strike Chance: |cFFffcc00" + Jass::I2S(Value) + "%|r\nDamage Multiplier: |cFFffcc00" + Payload2 + "x|r");
                        }
                    } else {
                        Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGCChance"));
                        Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGMultiplier"));
                        Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("BuffedDMG"));
                        Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("TotalDMG"));
                        Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                            "|cFFff9900Critical Strike|r has been |cFFff1a1aremoved|r.");
                    }
                }
            }
            // -dmghp <percent>
            if (Command == "dmghp") {
                if (Jass::LoadReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGMultiplier")) <= 0.) {
                    if (Value != 0) {
                        Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageHP"), Value);
                        Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                            "Maximum HP Damage: |cFFffcc00" + Payload + "%|r");
                    } else {
                        Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageHP"));
                        Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("BuffedDMG"));
                        Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("TotalDMG"));
                        Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                            "|cFFff9900Maximum HP Damage|r has been |cFFff1a1aremoved|r.");
                    }
                }
            }
            // -dmgls <percent>
            if (Command == "dmgls") {
                if (Value != 0) {
                    Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageLS"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Life steal: |cFF00ff00" + Payload + "%|r");
                } else {
                    Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageLS"));
                    Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("TotalHealed"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Life steal|r has been |cFFff1a1aremoved|r.");
                }
            }
            // -dmgms <percent>
            if (Command == "dmgms") {
                if (Value != 0) {
                    Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageMS"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Mana steal: |cFF95b7e9" + Payload + "%|r");
                } else {
                    Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageMS"));
                    Jass::RemoveSavedReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("TotalManaStolen"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Mana steal|r has been |cFFff1a1aremoved|r.");
                }
            }
            // -dmgb <percent>
            if (Command == "dmgb") {
                if (Value != 0) {
                    Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToBlock"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Block damage: |cFFffcc00" + Payload + "%|r");
                } else {
                    Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToBlock"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Block damage|r has been |cFFff1a1aremoved|r.");
                }
            }
            // -dmgr <percent>
            if (Command == "dmgr") {
                if (Value != 0) {
                    Jass::SaveInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToReflect"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Reflect damage: |cFFffcc00" + Payload + "%|r");
                } else {
                    Jass::RemoveSavedInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToReflect"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Reflect damage|r has been |cFFff1a1aremoved|r.");
                }
            }
            // -status
            if (Command == "status") {
                float dmgMul = Jass::LoadReal(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGMultiplier"));
                int pctHP = Jass::LoadInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageHP"));
                if (dmgMul > 1.) {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 15,
                        "|cFFff9933Status|r\nCrit Chance: |cFFffcc00" +
                        Jass::I2S(Jass::LoadInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("DMGCChance"))) + "%|r\n" +
                        "Dmg Multiplier: |cFFffcc00" + Jass::R2S(dmgMul) + "x|r\n" +
                        "Total Dmg: |cFFff0000" + Jass::I2S(Jass::R2I(GetInfo(LoadUnit("DMGUnit"), "TotalDMG"))) + "|r\n" +
                        "Block: |cFFffcc00" + Jass::I2S(Jass::LoadInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToBlock"))) + "%|r\n" +
                        "Reflect: |cFFffcc00" + Jass::I2S(Jass::LoadInteger(nzHash, Jass::GetHandleId(LoadUnit("DMGUnit")), Jass::StringHash("PercentageToReflect"))) + "%|r");
                } else if (pctHP > 0) {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 15,
                        "|cFFff9933Status|r\nMax HP Damage: |cFFffcc00" + Jass::I2S(pctHP) + "%|r\n" +
                        "Total Dmg: |cFFff1a75" + Jass::I2S(Jass::R2I(GetInfo(LoadUnit("DMGUnit"), "TotalDMG"))) + "|r");
                }
            }
            // -copy <count>
            if (Command == "copy") {
                if (Value != 0 and Jass::GetUnitTypeId(LoadUnit("nzUnitSys")) != 0) {
                    for (i = 0; i < Value; i++) {
                        Jass::CreateUnit(Jass::GetOwningPlayer(LoadUnit("nzUnitSys")),
                            Jass::GetUnitTypeId(LoadUnit("nzUnitSys")),
                            Jass::GetUnitX(LoadUnit("nzUnitSys")),
                            Jass::GetUnitY(LoadUnit("nzUnitSys")), 270);
                    }
                }
            }
        } // ← конец первого GetChtrLvl check

        // -ploc <x> <y>
        if (Command == "ploc") {
            if (Jass::GetLocalPlayer() == Jass::GetTriggerPlayer()) {
                Jass::PingMinimapEx(Jass::S2R(Payload), Value3, 15, 51, 153, 255, true);
            }
        }
        // -share <p1> <p2> / -unshare <p1> <p2>
        if (Command == "share" or Command == "unshare") {
            if (Value >= 1 and Value <= 16) {
                if (Value2 >= 1 and Value2 <= 16) {
                    bool flag = (Command == "share");
                    Jass::SetPlayerAlliance(Jass::Player(Value - 1), Jass::Player(Value2 - 1), Jass::ALLIANCE_SHARED_VISION, flag);
                    Jass::SetPlayerAlliance(Jass::Player(Value - 1), Jass::Player(Value2 - 1), Jass::ALLIANCE_SHARED_CONTROL, flag);
                    Jass::SetPlayerAlliance(Jass::Player(Value - 1), Jass::Player(Value2 - 1), Jass::ALLIANCE_SHARED_ADVANCED_CONTROL, flag);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Shared " + LoadPlayerColors(Jass::Player(Value - 1)) + " with " + LoadPlayerColors(Jass::Player(Value2 - 1)));
                }
            }
        }
        // -nc (no cooldown)
        if (Command == "nc") {
            timer ncTimer = Jass::LoadTimerHandle(nzHash, Jass::GetHandleId(LoadUnit("nzUnitSys")), Jass::StringHash("NOCDTrig"));
            if (ncTimer == nil) {
                ncTimer = Jass::CreateTimer();
                Jass::SaveTimerHandle(nzHash, Jass::GetHandleId(LoadUnit("nzUnitSys")), Jass::StringHash("NOCDTrig"), ncTimer);
                Jass::SaveUnitHandle(nzHash, Jass::GetHandleId(ncTimer), Jass::StringHash("CDUnit"), LoadUnit("nzUnitSys"));
                Jass::TimerStart(ncTimer, 0.2, true, @ResetCDAction);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900No cooldown|r |cFF00cc66enabled|r.");
            } else {
                if (Payload == "off") {
                    Jass::PauseTimer(ncTimer);
                    Jass::FlushChildHashtable(nzHash, Jass::GetHandleId(ncTimer));
                    Jass::DestroyTimer(ncTimer);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900No cooldown|r |cFFff1a1adisabled|r.");
                }
            }
            ncTimer = nil;
        }

        // -learn <rawcode> / -unlearn <rawcode> (second ChtrLvl check)
        Value = S2ID(Payload); // переопределяем Value как rawcode
        if (GetChtrLvl(Jass::Player(PID)) >= GetChtrLvl(Jass::GetOwningPlayer(LoadUnit("nzUnitSys")))) {
            if (Command == "learn") {
                if (Value != 0 and Payload != "") {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Ability|r [|cFF00cc66" + Jass::GetObjectName(Value) + "|r] |cFF00cc66added|r");
                    Jass::UnitAddAbility(LoadUnit("nzUnitSys"), Value);
                }
            }
            if (Command == "unlearn") {
                if (Value != 0 and Payload != "") {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFff9900Ability|r [|cFF00cc66" + Jass::GetObjectName(Value) + "|r] |cFFff1a1aremoved|r");
                    Jass::UnitRemoveAbility(LoadUnit("nzUnitSys"), Value);
                }
            }
        }

        // -clear
        if (Command == "clear") {
            if (Jass::GetLocalPlayer() == Jass::GetTriggerPlayer())
                Jass::ClearTextMessages();
        }
        // -noreplay
        if (Command == "noreplay") {
            Jass::DoNotSaveReplay();
            Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Replay|r |cFFff1a1adisabled|r.");
        }
        // -act <new activator>
        if (Command == "act") {
            if (Payload != "" and Payload != Jass::LoadStr(nzHash, GlobalHandle(), Jass::StringHash("Activator"))) {
                Jass::SaveStr(nzHash, GlobalHandle(), Jass::StringHash("Activator"), Payload);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                    "|cFFff9900Activator|r changed to: |cFF00cc66" + Payload + "|r.");
            }
        }
        // -nowaste / -nowaste off
        if (Command == "nowaste") {
            if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("InfiniteCharge"))) {
                if (Payload == "off") {
                    Jass::RemoveSavedBoolean(nzHash, HandleP, Jass::StringHash("InfiniteCharge"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Infinite Charge|r |cFFff1a1adisabled|r.");
                }
            } else {
                Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("InfiniteCharge"), true);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Infinite Charge|r |cFF00cc66enabled|r.");
            }
        }
        // -gold <N> / -giveg <player> <amount>
        if (Command == "gold" or Command == "giveg") {
            if (Command == "gold") {
                Jass::SetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_GOLD,
                    Jass::GetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_GOLD) + Value);
            } else if (Command == "giveg") {
                if (Value >= 1 and Value <= 24) {
                    Jass::SetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_RESOURCE_GOLD,
                        Jass::GetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_RESOURCE_GOLD) + Value2);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Gave " + Jass::I2S(Value2) + " |cFFffff00gold|r to " + LoadPlayerColors(Jass::Player(Value - 1)));
                }
            }
        }
        // -lumber <N> / -givel <player> <amount>
        if (Command == "lumber" or Command == "givel") {
            if (Command == "lumber") {
                Jass::SetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_LUMBER,
                    Jass::GetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_LUMBER) + Value);
            } else if (Command == "givel") {
                if (Value >= 1 and Value <= 24) {
                    Jass::SetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_RESOURCE_LUMBER,
                        Jass::GetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_RESOURCE_LUMBER) + Value2);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Gave " + Jass::I2S(Value2) + " |cFF00cc66lumber|r to " + LoadPlayerColors(Jass::Player(Value - 1)));
                }
            }
        }
        // -food <N> / -givef <player> <amount>
        if (Command == "food" or Command == "givef") {
            if (Command == "food") {
                if (Value != 0) {
                    Jass::SetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_FOOD_CAP_CEILING, Value);
                    Jass::SetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_FOOD_CAP, Value);
                }
            } else if (Command == "givef") {
                if (Value >= 1 and Value <= 24) {
                    Jass::SetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_FOOD_CAP_CEILING, Value2);
                    Jass::SetPlayerState(Jass::Player(Value - 1), Jass::PLAYER_STATE_RESOURCE_FOOD_CAP, Value2);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "Gave " + Jass::I2S(Value2) + " |cFFb33c00food|r to " + LoadPlayerColors(Jass::Player(Value - 1)));
                }
            }
            if (Payload == "use" or Payload == "nouse") {
                Jass::SetUnitUseFood(LoadUnit("nzUnitSys"), (Payload == "use"));
            }
        }
        // -grate <percent>
        if (Command == "grate") {
            if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("GoldRate"))) {
                if (Value == 0) {
                    Jass::RemoveSavedBoolean(nzHash, HandleP, Jass::StringHash("GoldRate"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFffff00Gold Rate|r |cFFff1a1adisabled|r.");
                } else {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("GoldRatePercentage"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFffff00Gold Rate|r changed to |cFFffff00" + Jass::I2S(Value) + "%|r");
                }
            } else {
                if (Value > 0) {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("GoldRatePercentage"), Value);
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("CurrentGold"),
                        Jass::GetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_GOLD));
                    Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("GoldRate"), true);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFFffff00Gold Rate|r set to |cFFffff00" + Jass::I2S(Value) + "%|r");
                }
            }
        }
        // -lrate <percent>
        if (Command == "lrate") {
            if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("LumberRate"))) {
                if (Value == 0) {
                    Jass::RemoveSavedBoolean(nzHash, HandleP, Jass::StringHash("LumberRate"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFF009933Lumber Rate|r |cFFff1a1adisabled|r.");
                } else {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("LumberRatePercentage"), Value);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFF009933Lumber Rate|r changed to |cFF009933" + Jass::I2S(Value) + "%|r");
                }
            } else {
                if (Value > 0) {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("LumberRatePercentage"), Value);
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("CurrentLumber"),
                        Jass::GetPlayerState(Jass::Player(PID), Jass::PLAYER_STATE_RESOURCE_LUMBER));
                    Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("LumberRate"), true);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                        "|cFF009933Lumber Rate|r set to |cFF009933" + Jass::I2S(Value) + "%|r");
                }
            }
        }
        // -expr <percent>
        if (Command == "expr") {
            Jass::SetPlayerHandicapXP(Jass::Player(PID),
                (Value + Jass::R2I(100 * Jass::GetPlayerHandicapXP(Jass::Player(PID)))) * 0.01);
            Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                "|cFFe600e6Experience Rate|r changed to |cFFe600e6" + Jass::I2S(Value) + "%|r");
        }
        // -mh / -mh off
        if (Command == "mh") {
            fogmodifier mhFog = Jass::LoadFogModifierHandle(nzHash, HandleP, Jass::StringHash("MH"));
            if (mhFog == nil) {
                mhFog = Jass::CreateFogModifierRect(Jass::Player(PID), Jass::FOG_OF_WAR_VISIBLE, Jass::GetWorldBounds(), false, false);
                Jass::SaveFogModifierHandle(nzHash, HandleP, Jass::StringHash("MH"), mhFog);
                Jass::FogModifierStart(mhFog);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Map hack|r |cFF00cc66enabled|r.");
            } else {
                if (Payload == "off") {
                    Jass::FogModifierStop(mhFog);
                    Jass::DestroyFogModifier(mhFog);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Map hack|r |cFFff1a1adisabled|r.");
                }
            }
            mhFog = nil;
        }
        // -tp / -tp off / -tp M/P/A
        if (Command == "tp") {
            if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("TP"))) {
                if (Payload == "M") {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("TPKey"), 851986);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900TP|r key → |cFF00aaffMove|r.");
                }
                if (Payload == "P") {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("TPKey"), 851990);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900TP|r key → |cFF00aaffPatrol|r.");
                }
                if (Payload == "A") {
                    Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("TPKey"), 851983);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900TP|r key → |cFF00aaffAttack|r.");
                }
                if (Payload == "off") {
                    Jass::RemoveSavedBoolean(nzHash, HandleP, Jass::StringHash("TP"));
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Teleport|r |cFFff1a1adisabled|r.");
                }
            } else {
                Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("TP"), true);
                Jass::SaveInteger(nzHash, HandleP, Jass::StringHash("TPKey"), 851990);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Teleport|r |cFF00cc66enabled|r! Press P (patrol) to TP.");
            }
        }
        // -fast / -fast off
        if (Command == "fast") {
            if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("BUTFast"))) {
                if (Payload == "off") {
                    Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("BUTFast"), false);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Fast build/train|r |cFFff1a1adisabled|r.");
                }
            } else {
                Jass::SaveBoolean(nzHash, HandleP, Jass::StringHash("BUTFast"), true);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Fast build/train|r |cFF00cc66enabled|r.");
            }
        }
        // -rg <value> / -rg off
        Value3 = Jass::S2R(Payload); // переопределяем Value3
        if (Command == "rg") {
            timer rgTimer = Jass::LoadTimerHandle(nzHash, Jass::GetHandleId(LoadUnit("nzUnitSys")), Jass::StringHash("REGTrig"));
            if (rgTimer == nil) {
                rgTimer = Jass::CreateTimer();
                Jass::SaveTimerHandle(nzHash, Jass::GetHandleId(LoadUnit("nzUnitSys")), Jass::StringHash("REGTrig"), rgTimer);
                Jass::SaveUnitHandle(nzHash, Jass::GetHandleId(rgTimer), Jass::StringHash("RGUnit"), LoadUnit("nzUnitSys"));
                Jass::SaveReal(nzHash, Jass::GetHandleId(rgTimer), Jass::StringHash("RGHPMP"), Value3);
                Jass::TimerStart(rgTimer, 0.25, true, @RegenHPMPAction);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                    "|cFFff9900[EXTRA]|r HP & MP Regen: |cFFff9900" + Jass::R2S(Value3) + "|r/0.25s");
            } else {
                if (Payload == "off") {
                    Jass::PauseTimer(rgTimer);
                    Jass::FlushChildHashtable(nzHash, Jass::GetHandleId(rgTimer));
                    Jass::DestroyTimer(rgTimer);
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10, "|cFFff9900Regen buff|r |cFFff1a1aremoved|r.");
                    rgTimer = nil;
                    u = nil; g = nil; itm = nil; t = nil; abil = nil;
                    return;
                }
                Jass::SaveReal(nzHash, Jass::GetHandleId(rgTimer), Jass::StringHash("RGHPMP"), Value3);
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                    "|cFFff9900[EXTRA]|r HP & MP Regen: |cFFff9900" + Jass::R2S(Value3) + "|r/0.25s");
            }
            rgTimer = nil;
        }
        // -itemid <slot>
        if (Command == "itemid") {
            if (Value >= 1 and Value <= 6) {
                item checkItm = Jass::UnitItemInSlot(SelectedUnit(Jass::Player(PID)), Value - 1);
                if (checkItm != nil) {
                    Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 15,
                        "|cFF00aaffItem ID:|r " + ID2S(Jass::GetItemTypeId(checkItm)) +
                        "  |cFF00aaffName:|r " + Jass::GetObjectName(Jass::GetItemTypeId(checkItm)));
                }
                checkItm = nil;
            }
        }
        // -unitid
        if (Command == "unitid") {
            unit selU = SelectedUnit(Jass::Player(PID));
            Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 15,
                "|cFF00aaffUnit ID:|r " + ID2S(Jass::GetUnitTypeId(selU)) +
                "  |cFF00aaffName:|r " + Jass::GetObjectName(Jass::GetUnitTypeId(selU)));
            selU = nil;
        }
        // -sitem <name>
        if (Command == "sitem") {
            ItemSearch_Init(PID, Payload, Jass::CreateTimer(), 0.01, true);
        }
        // -s <rawcode> (spawn item + unit)
        Value = S2ID(Payload);
        if (Command == "s") {
            if (Value != 0 and Payload != "") {
                Jass::DisplayTimedTextToPlayer(Jass::Player(PID), 0, 0, 10,
                    "|cFFff9900Object|r [|cFF00cc66" + ID2S(Value) + "|r] |cFF00cc66spawned|r");
                itm = CreateItemCustom(Value, Jass::GetUnitX(LoadUnit("nzUnitSys")), Jass::GetUnitY(LoadUnit("nzUnitSys")));
                int chargeVal = Jass::S2I(Jass::SubString(Text, 7, 10));
                if (chargeVal > 1)
                    Jass::SetItemCharges(itm, chargeVal);
                itm = nil;
                SaveUnit("nzUnitSys", Jass::CreateUnit(Jass::Player(PID), Value,
                    Jass::GetUnitX(LoadUnit("nzUnitSys")), Jass::GetUnitY(LoadUnit("nzUnitSys")), 270));
            }
        }
        // -disable
        if (Command == "disable") {
            for (i = 0; i < 16; i++) {
                if (GetChtrLvl(Jass::Player(i)) > GetChtrLvl(Jass::Player(PID))) {
                    Jass::SaveInteger(nzHash, Jass::GetHandleId(Jass::Player(i)), Jass::StringHash("CheaterLvl"),
                        GetIntP(i, "CheaterLvl") - 1);
                }
            }
        }
    } // ← конец CPenabled

    // cleanup
    u = nil;
    g = nil;
    itm = nil;
    t = nil;
    abil = nil;
}

// ---------- TP Order Check ----------
void TP_OrderCheck() {
    int HandleP = Jass::GetHandleId(Jass::GetOwningPlayer(Jass::GetTriggerUnit()));
    if (Jass::LoadBoolean(nzHash, HandleP, Jass::StringHash("TP"))) {
        if (Jass::GetIssuedOrderId() == Jass::LoadInteger(nzHash, HandleP, Jass::StringHash("TPKey"))) {
            location orderLoc = Jass::GetOrderPointLoc();
            Jass::SetUnitPosition(Jass::GetTriggerUnit(), Jass::GetLocationX(orderLoc), Jass::GetLocationY(orderLoc));
            Jass::RemoveLocation(orderLoc);
            orderLoc = nil;
        }
    }
}

// ============================================================
//  InitCheats — вызвать один раз из GameStart()
// ============================================================
void InitCheats() {
    Debug("InitCheats", "Cheats Start initialization.");

    // Глобальная группа для SelectedUnit / EnumUnits
    Jass::SaveGroupHandle(nzHash, GlobalHandle(), Jass::StringHash("GlobalGroup"), Jass::CreateGroup());

    // Последовательность стрелок для активации (изменить по вкусу)
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::StringHash("ArrowSequence"), "UUDDLR");

    // Активатор по тексту (изменить по вкусу)
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::StringHash("Activator"), "q");

    trigger trg;

    // Чат-команды "-..."
    trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++) {
        Jass::TriggerRegisterPlayerChatEvent(trg, Jass::Player(i), "-", false);
    }
    Jass::TriggerAddAction(trg, @CP_Commands);
    Debug("InitCheats", "Cheats Trigger1 initialization.");
    // Стрелки для активации
    trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++) {
        Jass::TriggerRegisterPlayerEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_ARROW_LEFT_DOWN);
        Jass::TriggerRegisterPlayerEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_ARROW_RIGHT_DOWN);
        Jass::TriggerRegisterPlayerEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_ARROW_DOWN_DOWN);
        Jass::TriggerRegisterPlayerEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_ARROW_UP_DOWN);
    }
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::GetHandleId(Jass::EVENT_PLAYER_ARROW_LEFT_DOWN), "L");
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::GetHandleId(Jass::EVENT_PLAYER_ARROW_RIGHT_DOWN), "R");
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::GetHandleId(Jass::EVENT_PLAYER_ARROW_DOWN_DOWN), "D");
    Jass::SaveStr(nzHash, GlobalHandle(), Jass::GetHandleId(Jass::EVENT_PLAYER_ARROW_UP_DOWN), "U");
    Jass::TriggerAddAction(trg, @ArrowAct);
    Debug("InitCheats", "Cheats Trigger2 initialization.");
    // Gold rate
    trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++) {
        Jass::TriggerRegisterPlayerStateEvent(trg, Jass::Player(i), Jass::PLAYER_STATE_RESOURCE_GOLD, Jass::GREATER_THAN, 0);
    }
    Jass::TriggerAddAction(trg, @GoldRating);

    // Lumber rate
    trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++) {
        Jass::TriggerRegisterPlayerStateEvent(trg, Jass::Player(i), Jass::PLAYER_STATE_RESOURCE_LUMBER, Jass::GREATER_THAN, 0);
    }
    Jass::TriggerAddAction(trg, @LumberRating);

    // TP order check
    trg = Jass::CreateTrigger();
    for (int i = 0; i < 16; i++)
        Jass::TriggerRegisterPlayerUnitEvent(trg, Jass::Player(i), Jass::EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil);
    Jass::TriggerAddAction(trg, @TP_OrderCheck);

    trg = nil;
    Debug("InitCheats", "Cheats initialized.");
}
