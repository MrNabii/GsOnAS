class HeroSaveData {
    int HeroTypeId;
    int HeroLevel;
    int HeroName;
    int HeroGold;
    int HeroSlots;
    int HeroMapVersion;
    int HeroNos;
    int HeroZoom;
    int HeroWave;
    int HeroSkill;
    array<int> HeroItems(24);
    array<int> HeroDonatKills(20);
}

class PlayerSaveData {
    array<int> PlayerBook(100);
    array<int> PlayerDonat(10);
    array<int> PlayerBossKills(20);
    array<int> PlayerDonatKill(20);
}

const string SAVE_FOLDER = "Goblin_Survival v1.6\\";
const string SAVE_FILE_EXT = ".txt";
const string SAVE_SYNC_PREFIX = "LoadDATA";
const bool SAVE_AUTOLOAD_BY_NAME = true;

const int SAVE_KEY_NICK = 1;
const int SAVE_KEY_HERO = 2;
const int SAVE_KEY_HERO_LEVEL = 3;
const int SAVE_KEY_GOLD = 4;
const int SAVE_KEY_SLOTS = 5;
const int SAVE_KEY_VERSION = 6;
const int SAVE_KEY_NOS = 7;
const int SAVE_KEY_ZOOM = 8;
const int SAVE_KEY_WAVE = 9;
const int SAVE_KEY_SKILL = 10;
const int SAVE_KEY_ITEM_START = 11;
const int SAVE_KEY_ITEM_COUNT = 24;
const int SAVE_KEY_DONAT_START = SAVE_KEY_ITEM_START + SAVE_KEY_ITEM_COUNT;
const int SAVE_KEY_DONAT_COUNT = 20;

array<HeroSaveData@> SaveHeroData(12);
array<bool> SaveLoaded(12);
array<bool> SaveApplied(12);
array<string> SaveNames(12);

string SaveAlphabet = "";
string SaveAlphabetCandidate = "";
int SaveAlphabetCandidateLen = 0;

const string SAVE_ALP_NICK_UPPER = "!#$%&()*+,-.0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`{|}~ †‡‰™¤¦§©®|°±µ";
const string SAVE_ALP_NICK_LOWER = "!#$%&()*+,-.0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[]^_`{|}~ †‡‰™¤¦§©®|°±µ";

array<int> SaveHeroTypeMap(9);

HeroSaveData@ SaveSystem_GetHeroData(int pid) {
    if (pid < 0 || pid >= int(SaveHeroData.length())) return null;
    if (SaveHeroData[pid] is null) {
        @SaveHeroData[pid] = @HeroSaveData();
    }
    return SaveHeroData[pid];
}

void SaveSystem_InitHeroTypeMap() {
    SaveHeroTypeMap[1] = 'H000';
    SaveHeroTypeMap[2] = 'H003';
    SaveHeroTypeMap[3] = 'H001';
    SaveHeroTypeMap[4] = 'H002';
    SaveHeroTypeMap[5] = 'H005';
    SaveHeroTypeMap[6] = 'H006';
    SaveHeroTypeMap[7] = 'H004';
    SaveHeroTypeMap[8] = 'N000';
}

int SaveSystem_GetHeroIndexFromTypeId(int typeId) {
    for (int i = 1; i < int(SaveHeroTypeMap.length()); i++) {
        if (SaveHeroTypeMap[i] == typeId) return i;
    }
    return 0;
}

int SaveSystem_GetHeroTypeIdByIndex(int idx) {
    if (idx <= 0 || idx >= int(SaveHeroTypeMap.length())) return 0;
    return SaveHeroTypeMap[idx];
}

int SaveSystem_ResolveHeroTypeId(int heroValue) {
    int mapped = SaveSystem_GetHeroTypeIdByIndex(heroValue);
    if (mapped != 0) return mapped;
    if (heroValue == 0) return 0;
    return heroValue;
}

int SaveSystem_KeyForLoad(int key) {
    return key + 100;
}

int SaveSystem_KeyForSave(int key) {
    return key - 100;
}

int SaveSystem_GetMinMapVersion() {
    return (MapVersion[0] < MapVersion[1]) ? MapVersion[0] : MapVersion[1];
}

int SaveSystem_GetMaxMapVersion() {
    return (MapVersion[0] > MapVersion[1]) ? MapVersion[0] : MapVersion[1];
}

int SaveSystem_GetCurrentMapVersion() {
    return SaveSystem_GetMaxMapVersion();
}

bool SaveSystem_IsActivePlayer(player p) {
    if (p == nil) return false;
    if (Jass::GetPlayerController(p) != Jass::MAP_CONTROL_USER) return false;
    return Jass::GetPlayerSlotState(p) == Jass::PLAYER_SLOT_STATE_PLAYING;
}

int SaveSystem_GetPlayerNameHash(player p) {
    if (p == nil) return 0;
    string res = SaveSystem_N2H(Jass::GetPlayerName(p), SAVE_ALP_NICK_UPPER, SAVE_ALP_NICK_LOWER, 10);
    if (res == "ERROR" || res == "ERROR2") return 0;
    return Jass::S2I(res);
}

string SaveSystem_N2H(string str, string alp1, string alp2, int sdv) {
    string s;
    string outStr;
    int sl = Jass::StringLength(str);
    int k = 0;
    int j = 1;
    int i = 1;
    int hc = 1;
    array<int> ii(32);
    int hash = 0;

    if (sl >= 3 && sl <= 24) {
        while (true) {
            s = Jass::SubString(str, i - 1, i);
            while (true) {
                if (s == Jass::SubString(alp1, j - 1, j) || s == Jass::SubString(alp2, j - 1, j)) {
                    ii[i] = 31 + j;
                    k += 1;
                    j = 100;
                }
                if (j >= Jass::StringLength(alp1)) break;
                j += 1;
            }
            if (i >= sl) break;
            i += 1;
            j = 1;
        }

        if (k != sl) {
            outStr = "ERROR";
        } else {
            while (true) {
                hash = hash + (ii[hc] * hc) + sdv;
                hc += 1;
                if (hc == k + 1) break;
            }
            outStr = Jass::I2S(hash);
        }
    } else {
        outStr = "ERROR2";
    }

    return outStr;
}

string SaveSystem_NormalizeFileName(string name) {
    int len = Jass::StringLength(name);
    while (len > 0 && Jass::SubString(name, len - 1, len) == " ") {
        len -= 1;
    }
    name = Jass::SubString(name, 0, len);
    name = SaveSystem_SanitizeFileName(name);
    return name;
}

string SaveSystem_SanitizeFileName(string name) {
    string result = "";
    int len = Jass::StringLength(name);
    for (int i = 0; i < len; i++) {
        string ch = Jass::SubString(name, i, i + 1);
        if (ch == "\\" || ch == "/") {
            result += "_";
        } else {
            result += ch;
        }
    }
    return result;
}

void SaveSystem_HandleSaveCommand(player p, string payload) {
    SaveSystem_SavePlayer(p, payload, true);
}

void SaveSystem_HandleLoadCommand(player p, string payload) {
    SaveSystem_RequestLoad(p, payload, false);
}

void InitSaveSystem() {
    SaveSystem_InitHeroTypeMap();
    SaveSystem_EnsureAlphabet();

    trigger sync = Jass::CreateTrigger();
    for (int i = 0; i < 10; i++) {
        Jass::TriggerRegisterPlayerSyncEvent(sync, Jass::Player(i), SAVE_SYNC_PREFIX, false);
    }
    Jass::TriggerAddAction(sync, @SaveSystem_OnSyncData);

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (!SaveSystem_IsActivePlayer(p)) {
            p = nil;
            continue;
        }
        SaveNames[i] = SaveSystem_NormalizeFileName(Jass::GetPlayerName(p));
        p = nil;
    }

    if (SAVE_AUTOLOAD_BY_NAME) {
        for (int i = 0; i < 10; i++) {
            player p = Jass::Player(i);
            if (!SaveSystem_IsActivePlayer(p)) {
                p = nil;
                continue;
            }
            if (SaveNames[i] != "") {
                SaveSystem_RequestLoad(p, SaveNames[i], true);
            }
            p = nil;
        }
    }

    Debug("InitSaveSystem", "Save system initialized");
}

void SaveSystem_OnAutoSaveTick() {
    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (!SaveSystem_IsActivePlayer(p)) {
            p = nil;
            continue;
        }
        if (SaveNames[i] != "") {
            SaveSystem_SavePlayer(p, SaveNames[i], false);
        }
        p = nil;
    }
}

bool SaveSystem_SavePlayer(player p, string fileName, bool showMessage) {
    if (p == nil) return false;
    int pid = Jass::GetPlayerId(p);
    HeroSaveData@ data = SaveSystem_GetHeroData(pid);
    if (data is null) return false;

    fileName = SaveSystem_NormalizeFileName(fileName);
    if (fileName == "") {
        fileName = SaveSystem_NormalizeFileName(Jass::GetPlayerName(p));
    }
    SaveNames[pid] = fileName;

    if (!SaveSystem_CollectHeroData(p, data)) {
        if (showMessage && Jass::GetLocalPlayer() == p) {
            Jass::DisplayTextToPlayer(p, 0, 0, "Save failed: hero not found.");
        }
        return false;
    }

    if (Jass::GetLocalPlayer() == p) {
        SaveSystem_EnsureAlphabet();
        string path = SAVE_FOLDER + fileName + SAVE_FILE_EXT;
        textfilehandle file = Jass::TextFileOpen(path);
        int checksum = SaveSystem_CalcChecksum(data);
        string checksumStr = Jass::I2S(checksum);
        Jass::TextFileWriteLine(file, Jass::I2S(Jass::StringLength(checksumStr)));
        Jass::TextFileWriteLine(file, checksumStr);

        int maxKey = SAVE_KEY_DONAT_START + SAVE_KEY_DONAT_COUNT - 1;
        for (int key = SAVE_KEY_NICK; key <= maxKey; key++) {
            int value = SaveSystem_GetValueByKey(data, key);
            Jass::TextFileWriteLine(file, SaveSystem_EncodeLine(key, value, checksum));
        }

        Jass::TextFileClose(file);
        if (showMessage) {
            Jass::DisplayTextToPlayer(p, 0, 0, "Saved: " + fileName);
        }
    }

    return true;
}

void SaveSystem_RequestLoad(player p, string fileName, bool silentIfMissing) {
    if (p == nil) return;
    int pid = Jass::GetPlayerId(p);

    fileName = SaveSystem_NormalizeFileName(fileName);
    if (fileName == "") {
        fileName = SaveSystem_NormalizeFileName(Jass::GetPlayerName(p));
    }
    SaveNames[pid] = fileName;

    if (Jass::GetLocalPlayer() != p) return;

    string path = SAVE_FOLDER + fileName + SAVE_FILE_EXT;
    if (!Jass::TextFileExists(path)) {
        if (!silentIfMissing) {
            Jass::DisplayTextToPlayer(p, 0, 0, "Save file not found: " + fileName);
        }
        return;
    }

    textfilehandle file = Jass::TextFileOpen(path);
    string cod = Jass::TextFileReadAllLines(file);
    Jass::TextFileClose(file);

    if (cod == "") {
        if (!silentIfMissing) {
            Jass::DisplayTextToPlayer(p, 0, 0, "Save file is empty: " + fileName);
        }
        return;
    }

    Jass::SendSyncData(SAVE_SYNC_PREFIX, cod);
}

void SaveSystem_OnSyncData() {
    SaveSystem_EnsureAlphabet();
    string cod = Jass::GetTriggerSyncData();
    player p = Jass::GetTriggerSyncPlayer();
    if (p == nil) return;
    int pid = Jass::GetPlayerId(p);

    HeroSaveData@ data = @HeroSaveData();
    bool ok = SaveSystem_ParseHeroData(cod, data);
    if (!ok || !SaveSystem_ValidateHeroData(p, data)) {
        if (Jass::GetLocalPlayer() == p) {
            Jass::DisplayTextToPlayer(p, 0, 0, "Save code is invalid.");
        }
        return;
    }

    @SaveHeroData[pid] = @data;
    SaveLoaded[pid] = true;
    SaveApplied[pid] = false;

    SaveSystem_ApplyToExistingHero(pid);
    if (Jass::GetLocalPlayer() == p) {
        Jass::DisplayTextToPlayer(p, 0, 0, "Loaded: " + SaveNames[pid]);
    }
}

bool SaveSystem_ParseHeroData(string cod, HeroSaveData@ data) {
    if (data is null) return false;
    string line;
    if (!SaveSystem_ReadLine(cod, line)) return false;
    int k = Jass::S2I(line);
    if (!SaveSystem_ReadLine(cod, line)) return false;
    int checksum = Jass::S2I(line);

    bool ok = true;
    while (SaveSystem_ReadLine(cod, line)) {
        if (line == "") break;
        string decoded = SaveSystem_RAW2I(line, SaveAlphabet);
        int dlen = Jass::StringLength(decoded);
        if (dlen < 3 + k) {
            ok = false;
            continue;
        }
        int loadKey = Jass::S2I(Jass::SubString(decoded, 0, 3));
        int loadValue = Jass::S2I(Jass::SubString(decoded, 3, dlen - k));
        int loadChecksum = Jass::S2I(Jass::SubString(decoded, dlen - k, dlen));
        if (loadChecksum != checksum) {
            ok = false;
        }
        SaveSystem_SetValueByKey(data, SaveSystem_KeyForSave(loadKey), loadValue);
    }

    return ok;
}

bool SaveSystem_ReadLine(string &inout text, string &out line) {
    if (text == "") {
        line = "";
        return false;
    }

    int pos = Jass::StringFindFirstOf(text, "\n", true);
    if (pos == -1) {
        line = text;
        text = "";
    } else {
        line = Jass::SubString(text, 0, pos);
        text = Jass::SubString(text, pos + 1, Jass::StringLength(text));
    }

    line = SaveSystem_StripCarriageReturn(line);
    return true;
}

string SaveSystem_StripCarriageReturn(string line) {
    int len = Jass::StringLength(line);
    if (len > 0 && Jass::SubString(line, len - 1, len) == "\r") {
        return Jass::SubString(line, 0, len - 1);
    }
    return line;
}

bool SaveSystem_ValidateHeroData(player p, HeroSaveData@ data) {
    if (data is null) return false;
    int expectedNick = SaveSystem_GetPlayerNameHash(p);
    if (expectedNick != 0 && data.HeroName != expectedNick) return false;

    int minVer = SaveSystem_GetMinMapVersion();
    int maxVer = SaveSystem_GetMaxMapVersion();
    if (data.HeroMapVersion < minVer || data.HeroMapVersion > maxVer) return false;

    if (SaveSystem_ResolveHeroTypeId(data.HeroTypeId) == 0) return false;
    return true;
}

int SaveSystem_GetLoadedHeroTypeId(int pid) {
    if (pid < 0 || pid >= int(SaveHeroData.length())) return 0;
    if (!SaveLoaded[pid]) return 0;
    HeroSaveData@ data = SaveSystem_GetHeroData(pid);
    if (data is null) return 0;
    return SaveSystem_ResolveHeroTypeId(data.HeroTypeId);
}

void SaveSystem_ApplyToExistingHero(int pid) {
    if (pid < 0 || pid >= int(GoblinUnit.length())) return;
    unit hero = GoblinUnit[pid];
    if (hero != nil) {
        SaveSystem_ApplyToHero(hero, pid);
    }
}

bool SaveSystem_ApplyToHero(unit hero, int playerIndex) {
    if (hero == nil) return false;
    int pid = playerIndex;
    if (pid < 0 || pid >= int(SaveHeroData.length())) return false;
    if (!SaveLoaded[pid] || SaveApplied[pid]) return false;

    HeroSaveData@ data = SaveSystem_GetHeroData(pid);
    if (data is null) return false;

    int expectedTypeId = SaveSystem_ResolveHeroTypeId(data.HeroTypeId);
    if (expectedTypeId != 0 && Jass::GetUnitTypeId(hero) != expectedTypeId) return false;

    if (data.HeroLevel > 1) {
        Jass::SetHeroLevel(hero, data.HeroLevel, false);
    }

    int currentSkill = Jass::GetHeroSkillPoints(hero);
    int delta = data.HeroSkill - currentSkill;
    if (delta != 0) {
        Jass::UnitModifySkillPoints(hero, delta);
    }

    player owner = Jass::GetOwningPlayer(hero);
    Jass::SetPlayerState(owner, Jass::PLAYER_STATE_RESOURCE_GOLD, data.HeroGold);
    SaveSystem_SetNosLevel(owner, data.HeroNos);

    if (data.HeroSlots > 0) {
        Jass::UnitInventorySetSize(hero, data.HeroSlots);
    }

    SaveSystem_ClearInventory(hero);
    SaveSystem_RestoreItems(hero, data);

    if (data.HeroZoom > 0 && Jass::GetLocalPlayer() == owner) {
        Jass::ResetToGameCamera(0.);
        Jass::SetCameraField(Jass::CAMERA_FIELD_TARGET_DISTANCE, data.HeroZoom, 0.);
    }

    SaveApplied[pid] = true;
    owner = nil;
    return true;
}

bool SaveSystem_CollectHeroData(player p, HeroSaveData@ data) {
    if (p == nil || data is null) return false;
    int pid = Jass::GetPlayerId(p);
    if (pid < 0 || pid >= int(GoblinUnit.length())) return false;

    unit hero = GoblinUnit[pid];
    if (hero == nil) return false;

    int typeId = Jass::GetUnitTypeId(hero);
    int heroIndex = SaveSystem_GetHeroIndexFromTypeId(typeId);
    data.HeroTypeId = (heroIndex != 0) ? heroIndex : typeId;
    data.HeroLevel = Jass::GetHeroLevel(hero);
    data.HeroSkill = Jass::GetHeroSkillPoints(hero);
    data.HeroGold = Jass::GetPlayerState(p, Jass::PLAYER_STATE_RESOURCE_GOLD);
    data.HeroSlots = Jass::UnitInventorySize(hero);
    data.HeroMapVersion = SaveSystem_GetCurrentMapVersion();
    data.HeroNos = SaveSystem_GetNosLevel(p);
    data.HeroZoom = SaveSystem_GetPlayerZoomForSave(p);
    data.HeroWave = udg_Wave_Number;
    data.HeroName = SaveSystem_GetPlayerNameHash(p);

    int invSize = Jass::UnitInventorySize(hero);
    int maxSlots = int(data.HeroItems.length());
    for (int i = 0; i < maxSlots; i++) {
        data.HeroItems[i] = Jass::GetRandomInt(9000, 9999);
        if (i >= invSize) continue;

        item it = Jass::UnitItemInSlot(hero, i);
        if (it == nil) continue;

        ItemStats@ stats = GetRegisteredItemData(it);
        if (stats !is null && stats.saveId > 1000) {
            data.HeroItems[i] = stats.saveId;
        }
        it = nil;
    }

    return true;
}

int SaveSystem_GetPlayerZoomForSave(player p) {
    if (Jass::GetLocalPlayer() != p) return 0;
    return Jass::R2I(Jass::GetCameraField(Jass::CAMERA_FIELD_TARGET_DISTANCE));
}

int SaveSystem_GetNosLevel(player p) {
    if (p == nil) return 0;
    int pid = Jass::GetPlayerId(p) + 1;
    if (pid < 1 || pid >= int(CS_NosUpgradeLevel.length())) return 0;
    return CS_NosUpgradeLevel[pid];
}

void SaveSystem_SetNosLevel(player p, int level) {
    CS_SetNosUpgradeLevel(p, level);
}

void SaveSystem_ClearInventory(unit hero) {
    if (hero == nil) return;
    int invSize = Jass::UnitInventorySize(hero);
    for (int i = 0; i < invSize; i++) {
        item it = Jass::UnitItemInSlot(hero, i);
        if (it == nil) continue;
        Jass::UnitRemoveItemFromSlot(hero, i);
        Jass::RemoveItem(it);
        it = nil;
    }
}

void SaveSystem_RestoreItems(unit hero, HeroSaveData@ data) {
    if (hero == nil || data is null) return;
    for (int i = 0; i < int(data.HeroItems.length()); i++) {
        int saveId = data.HeroItems[i];
        if (saveId <= 1000) continue;
        int itemTypeId = GetItemTypeIdBySaveId(saveId);
        if (itemTypeId == 0) continue;
        item it = CreateItemCustom(itemTypeId, Jass::GetUnitX(hero), Jass::GetUnitY(hero));
        Jass::UnitAddItem(hero, it);
        it = nil;
    }
}

int SaveSystem_GetValueByKey(HeroSaveData@ data, int key) {
    if (data is null) return 0;
    if (key == SAVE_KEY_NICK) return data.HeroName;
    if (key == SAVE_KEY_HERO) return data.HeroTypeId;
    if (key == SAVE_KEY_HERO_LEVEL) return data.HeroLevel;
    if (key == SAVE_KEY_GOLD) return data.HeroGold;
    if (key == SAVE_KEY_SLOTS) return data.HeroSlots;
    if (key == SAVE_KEY_VERSION) return data.HeroMapVersion;
    if (key == SAVE_KEY_NOS) return data.HeroNos;
    if (key == SAVE_KEY_ZOOM) return data.HeroZoom;
    if (key == SAVE_KEY_WAVE) return data.HeroWave;
    if (key == SAVE_KEY_SKILL) return data.HeroSkill;
    if (key >= SAVE_KEY_ITEM_START && key < SAVE_KEY_ITEM_START + SAVE_KEY_ITEM_COUNT) {
        return data.HeroItems[key - SAVE_KEY_ITEM_START];
    }
    if (key >= SAVE_KEY_DONAT_START && key < SAVE_KEY_DONAT_START + SAVE_KEY_DONAT_COUNT) {
        return data.HeroDonatKills[key - SAVE_KEY_DONAT_START];
    }
    return 0;
}

void SaveSystem_SetValueByKey(HeroSaveData@ data, int key, int value) {
    if (data is null) return;
    if (key == SAVE_KEY_NICK) { data.HeroName = value; return; }
    if (key == SAVE_KEY_HERO) { data.HeroTypeId = value; return; }
    if (key == SAVE_KEY_HERO_LEVEL) { data.HeroLevel = value; return; }
    if (key == SAVE_KEY_GOLD) { data.HeroGold = value; return; }
    if (key == SAVE_KEY_SLOTS) { data.HeroSlots = value; return; }
    if (key == SAVE_KEY_VERSION) { data.HeroMapVersion = value; return; }
    if (key == SAVE_KEY_NOS) { data.HeroNos = value; return; }
    if (key == SAVE_KEY_ZOOM) { data.HeroZoom = value; return; }
    if (key == SAVE_KEY_WAVE) { data.HeroWave = value; return; }
    if (key == SAVE_KEY_SKILL) { data.HeroSkill = value; return; }
    if (key >= SAVE_KEY_ITEM_START && key < SAVE_KEY_ITEM_START + SAVE_KEY_ITEM_COUNT) {
        data.HeroItems[key - SAVE_KEY_ITEM_START] = value;
        return;
    }
    if (key >= SAVE_KEY_DONAT_START && key < SAVE_KEY_DONAT_START + SAVE_KEY_DONAT_COUNT) {
        data.HeroDonatKills[key - SAVE_KEY_DONAT_START] = value;
        return;
    }
}

int SaveSystem_CalcChecksum(HeroSaveData@ data) {
    if (data is null) return 0;
    int sum = 0;
    int maxKey = SAVE_KEY_DONAT_START + SAVE_KEY_DONAT_COUNT - 1;
    for (int key = SAVE_KEY_NICK; key <= maxKey; key++) {
        sum += SaveSystem_GetValueByKey(data, key);
    }
    return sum;
}

string SaveSystem_EncodeLine(int key, int value, int checksum) {
    int loadKey = SaveSystem_KeyForLoad(key);
    string num = Jass::I2S(loadKey) + Jass::I2S(value) + Jass::I2S(checksum);
    return SaveSystem_I2RAW(num, SaveAlphabet);
}

int SaveSystem_StringModulo(string num, int base) {
    int carry = 0;
    int i = 0;
    int digit;
    while (true) {
        if (i >= Jass::StringLength(num)) break;
        digit = Jass::S2I(Jass::SubString(num, i, i + 1));
        carry = carry * 10 + digit;
        carry = carry - (carry / base) * base;
        i += 1;
    }
    return carry;
}

string SaveSystem_StringDivide(string num, int base) {
    string result = "";
    int carry = 0;
    int i = 0;
    int digit;
    int quotient;

    while (true) {
        if (i >= Jass::StringLength(num)) break;
        digit = Jass::S2I(Jass::SubString(num, i, i + 1));
        carry = carry * 10 + digit;
        quotient = carry / base;
        result = result + Jass::I2S(quotient);
        carry = carry - (quotient * base);
        i += 1;
    }

    while (true) {
        if (Jass::StringLength(result) == 0 || Jass::SubString(result, 0, 1) != "0") break;
        result = Jass::SubString(result, 1, Jass::StringLength(result));
    }

    if (result == "") {
        result = "0";
    }
    return result;
}

string SaveSystem_StringAdd(string num1, string num2) {
    string result = "";
    int carry = 0;
    int i = Jass::StringLength(num1) - 1;
    int j = Jass::StringLength(num2) - 1;
    int sum;

    while (true) {
        if (i < 0 && j < 0 && carry == 0) break;
        sum = carry;
        if (i >= 0) {
            sum = sum + Jass::S2I(Jass::SubString(num1, i, i + 1));
            i -= 1;
        }
        if (j >= 0) {
            sum = sum + Jass::S2I(Jass::SubString(num2, j, j + 1));
            j -= 1;
        }
        result = Jass::I2S(Jass::MathIntegerModulo(sum, 10)) + result;
        carry = sum / 10;
    }

    return result;
}

string SaveSystem_StringMultiply(string num, int multiplier) {
    string result = "0";
    string temp = "";
    int carry = 0;
    int product;
    int i = Jass::StringLength(num) - 1;

    while (true) {
        if (i < 0) break;
        product = Jass::S2I(Jass::SubString(num, i, i + 1)) * multiplier + carry;
        temp = Jass::I2S(Jass::MathIntegerModulo(product, 10)) + temp;
        carry = product / 10;
        i -= 1;
    }

    if (carry > 0) {
        temp = Jass::I2S(carry) + temp;
    }

    return SaveSystem_StringAdd(result, temp);
}

string SaveSystem_I2RAW(string num, string alp) {
    string res = "";
    int len = Jass::StringLength(alp);
    int remainder;

    while (true) {
        if (num == "0") break;
        remainder = SaveSystem_StringModulo(num, len);
        res = Jass::SubString(alp, remainder, remainder + 1) + res;
        num = SaveSystem_StringDivide(num, len);
    }

    return res;
}

string SaveSystem_RAW2I(string cod, string alp) {
    string res = "0";
    int len = Jass::StringLength(alp);
    int i = 0;
    int j;

    while (true) {
        if (i >= Jass::StringLength(cod)) break;
        j = 0;
        while (true) {
            if (j >= len) break;
            if (Jass::SubString(cod, i, i + 1) == Jass::SubString(alp, j, j + 1)) {
                res = SaveSystem_StringAdd(SaveSystem_StringMultiply(res, len), Jass::I2S(j));
                break;
            }
            j += 1;
        }
        i += 1;
    }

    return res;
}

void SaveSystem_EnsureAlphabet() {
    if (SaveAlphabet != "") return;
    SaveAlphabet = SaveSystem_FindAlphabetFromUnits();
    if (SaveAlphabet == "") {
        SaveAlphabet = SaveSystem_BuildFallbackAlphabet();
    }
}

string SaveSystem_FindAlphabetFromUnits() {
    SaveAlphabetCandidate = "";
    SaveAlphabetCandidateLen = 0;

    rect world = Jass::GetWorldBounds();
    group g = Jass::CreateGroup();
    Jass::GroupEnumUnitsInRect(g, world, nil);
    Jass::ForGroup(g, @SaveSystem_ScanAlphabetUnit);
    Jass::DestroyGroup(g);
    Jass::RemoveRect(world);

    return SaveAlphabetCandidate;
}

void SaveSystem_ScanAlphabetUnit() {
    unit u = Jass::GetEnumUnit();
    string name = Jass::GetUnitName(u);
    int len = Jass::StringLength(name);
    if (len > SaveAlphabetCandidateLen) {
        SaveAlphabetCandidateLen = len;
        SaveAlphabetCandidate = name;
    }
    u = nil;
}

string SaveSystem_BuildFallbackAlphabet() {
    string combined = SAVE_ALP_NICK_UPPER + SAVE_ALP_NICK_LOWER;
    string result = "";
    int len = Jass::StringLength(combined);
    for (int i = 0; i < len; i++) {
        string ch = Jass::SubString(combined, i, i + 1);
        if (!SaveSystem_ContainsChar(result, ch)) {
            result += ch;
        }
    }
    return result;
}

bool SaveSystem_ContainsChar(string s, string ch) {
    int len = Jass::StringLength(s);
    for (int i = 0; i < len; i++) {
        if (Jass::SubString(s, i, i + 1) == ch) return true;
    }
    return false;
}