// ============================================================
//  WavesMobs.as
//  Полностью AS-логика волн: настройки + таймерный цикл спавна.
//  Редактирование волн: функция WS_LoadConfig().
// ============================================================

array<int> WS_WaveType(100);
array<int> WS_WaveMob0(100);
array<int> WS_WaveMob1(100);
array<int> WS_WaveMob2(100);
array<int> WS_WaveMob3(100);
array<int> WS_WaveMiniBoss(100);
array<int> WS_WaveTickMinSpawns(100);
array<int> WS_WaveTickMaxSpawns(100);
array<float> WS_WaveTickTimer(100);
array<int> WS_WaveMaxSpawns(100);

array<rect> WS_NormalSpawnRects(20);
array<rect> WS_DemonSpawnRects(10);

group WS_AliveWaveUnits = Jass::CreateGroup();
timer WS_WaveTimer = nil;

int WS_WaveMinik = 0;
bool WS_Initialized = false;
int WS_Pack_next_time = 0;

// Состояние волн (AS-копия для удобной правки и использования в других AS-системах)
int udg_Wave_Number = 1;
int udg_Wave_count_spawns = 0;
int udg_Wave_next_time = 3;
int udg_Wave_Number_Count = 1;
int udg_Wave_Number_TP = 1;
bool udg_Wave_Last = false;
int udg_wave_count = 0;
bool udg_WaveWait = false;

bool WS_ShortMode = false;

void WS_SetShortMode(bool enabled) {
    WS_ShortMode = enabled;
}

void WS_MessagePlayers(string msg, float duration) {
    if (msg == "") return;

    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (Jass::GetPlayerController(p) == Jass::MAP_CONTROL_USER && Jass::GetPlayerSlotState(p) == Jass::PLAYER_SLOT_STATE_PLAYING) {
            Jass::DisplayTimedTextToPlayer(p, 0, 0, duration, msg);
        }
    }
}

bool WS_IsCommonWaveType(int wt) {
    return wt == 1 || wt == 11 || wt == 12 || wt == 112 || wt == 13 || wt == 113 || wt == 14;
}

void WS_OnWaveDeath(unit diedunit, unit killer) {
    if (diedunit == nil) return;
    Jass::GroupRemoveUnit(WS_AliveWaveUnits, diedunit);
    udg_wave_count = Jass::GroupGetCount(WS_AliveWaveUnits);
}

void WS_OnWaveSpawn(unit u) {
    if (u == nil) return;
    Jass::GroupAddUnit(WS_AliveWaveUnits, u);
    udg_wave_count = Jass::GroupGetCount(WS_AliveWaveUnits);
}

void WS_SetWave(int idx, int wt, int mobA, int mobB, int mobC, int mobD, int mini, int minSpawns, int maxSpawns, float tick, int maxTicks) {
    WS_WaveType[idx] = wt;
    WS_WaveMob0[idx] = mobA;
    if(mobA != 0) {
        RegisterDeathHandler(mobA, @WS_OnWaveDeath);
        RegisterOnSpawnHandler(mobA, @WS_OnWaveSpawn);
    }
    WS_WaveMob1[idx] = mobB;
    if(mobB != 0) {
        RegisterDeathHandler(mobB, @WS_OnWaveDeath);
        RegisterOnSpawnHandler(mobB, @WS_OnWaveSpawn);
    }
    WS_WaveMob2[idx] = mobC;
    if(mobC != 0) {
        RegisterDeathHandler(mobC, @WS_OnWaveDeath);
        RegisterOnSpawnHandler(mobC, @WS_OnWaveSpawn);
    }
    WS_WaveMob3[idx] = mobD;
    if(mobD != 0) {
        RegisterDeathHandler(mobD, @WS_OnWaveDeath);
        RegisterOnSpawnHandler(mobD, @WS_OnWaveSpawn);
    }
    WS_WaveMiniBoss[idx] = mini;
    if(mini != 0) {
        RegisterDeathHandler(mini, @WS_OnWaveDeath);
        RegisterOnSpawnHandler(mini, @WS_OnWaveSpawn);
    }
    WS_WaveTickMinSpawns[idx] = minSpawns;
    WS_WaveTickMaxSpawns[idx] = maxSpawns;
    WS_WaveTickTimer[idx] = tick;
    WS_WaveMaxSpawns[idx] = maxTicks;
    
}

void WS_LoadConfig() {
    WS_SetWave(1, 1, 'n00D', 0, 0, 0, 'n001', 20, 25, 18, 6);
    WS_SetWave(2, 1, 'n00C', 0, 0, 0, 'n002', 15, 20, 15, 8);
    WS_SetWave(3, 1, 'n00E', 0, 0, 0, 'n003', 25, 30, 25, 5);
    WS_SetWave(4, 1, 'n00F', 0, 0, 0, 'n004', 10, 15, 8, 12);
    WS_SetWave(5, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(6, 1, 'n00H', 0, 0, 0, 'n005', 15, 20, 8, 10);
    WS_SetWave(7, 1, 'n00I', 0, 0, 0, 'n006', 10, 15, 10, 10);
    WS_SetWave(8, 1, 'n00J', 0, 0, 0, 'n007', 10, 15, 12, 10);
    WS_SetWave(9, 1, 'n00K', 0, 0, 0, 'n008', 7, 10, 15, 10);
    WS_SetWave(10, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(11, 1, 'n00M', 0, 0, 0, 'n009', 12, 20, 8, 10);
    WS_SetWave(12, 1, 'n00N', 0, 0, 0, 'n00A', 13, 17, 8, 10);
    WS_SetWave(13, 1, 'n00O', 0, 0, 0, 'n00X', 15, 20, 12, 10);
    WS_SetWave(14, 1, 'n00P', 0, 0, 0, 'n00Y', 8, 10, 15, 10);
    WS_SetWave(15, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(16, 1, 'n00T', 0, 0, 0, 'n00Z', 10, 15, 20, 8);
    WS_SetWave(17, 1, 'n00S', 0, 0, 0, 'n010', 18, 22, 15, 8);
    WS_SetWave(18, 1, 'n00U', 0, 0, 0, 'n011', 10, 15, 15, 10);
    WS_SetWave(19, 1, 'n00V', 0, 0, 0, 'n012', 18, 25, 13, 8);
    WS_SetWave(20, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(21, 1, 'n018', 0, 0, 0, 'n013', 7, 9, 4.00, 30);
    WS_SetWave(22, 1, 'n019', 0, 0, 0, 'n014', 8, 9, 4.00, 30);
    WS_SetWave(23, 1, 'n01A', 0, 0, 0, 'n016', 3, 5, 7.00, 20);
    WS_SetWave(24, 1, 'n01B', 0, 0, 0, 'n022', 4, 6, 5.00, 30);
    WS_SetWave(25, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(26, 1, 'n01D', 0, 0, 0, 'n015', 4, 5, 8.00, 18);
    WS_SetWave(27, 1, 'n01E', 0, 0, 0, 'n01U', 2, 5, 10.00, 15);
    WS_SetWave(28, 1, 'n01F', 0, 0, 0, 'n03L', 4, 6, 5.00, 30);
    WS_SetWave(29, 1, 'n01G', 0, 0, 0, 'n01W', 5, 7, 5.00, 30);
    WS_SetWave(30, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(31, 1, 'n01K', 0, 0, 0, 'n03K', 8, 9, 5.00, 30);
    WS_SetWave(32, 1, 'n01L', 0, 0, 0, 'n021', 3, 6, 5.00, 30);
    WS_SetWave(33, 1, 'n01M', 0, 0, 0, 'n01T', 7, 9, 5.00, 30);
    WS_SetWave(34, 1, 'n01N', 0, 0, 0, 'n01V', 4, 6, 5.00, 30);
    WS_SetWave(35, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(36, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(37, 11, 'n01P', 0, 0, 0, 'n01Y', 5, 9, 4.00, 35);
    WS_SetWave(38, 11, 'n01R', 0, 0, 0, 'n03W', 3, 6, 7.00, 20);
    WS_SetWave(39, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(40, 12, 'n023', 'n026', 'n024', 'n025', 'n025', 2, 4, 8.00, 20);
    WS_SetWave(41, 11, 'n027', 0, 0, 0, 'n03T', 5, 7, 5.00, 30);
    WS_SetWave(42, 113, 'n028', 'n029', 0, 0, 'n03X', 2, 5, 5.00, 30);
    WS_SetWave(43, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(44, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(45, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(46, 1, 'n02E', 0, 0, 0, 'n03P', 5, 6, 5.00, 30);
    WS_SetWave(47, 1, 'n02F', 0, 0, 0, 'n01X', 7, 9, 5.00, 30);
    WS_SetWave(48, 1, 'n02G', 0, 0, 0, 'n03N', 4, 6, 6.00, 25);
    WS_SetWave(49, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(50, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(51, 11, 'n02N', 0, 0, 0, 'n03R', 1, 9, 5.00, 30);
    WS_SetWave(52, 11, 'n02O', 0, 0, 0, 'n03M', 2, 4, 7.00, 20);
    WS_SetWave(53, 11, 'n02Q', 0, 0, 0, 'n03U', 3, 7, 5.00, 30);
    WS_SetWave(54, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(55, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(56, 1, 'n02U', 0, 0, 0, 'n01Z', 6, 8, 6.00, 25);
    WS_SetWave(57, 1, 'n02V', 0, 0, 0, 'n020', 4, 9, 5.00, 30);
    WS_SetWave(58, 13, 'n02X', 'n02W', 0, 0, 'n03V', 2, 4, 5.00, 30);
    WS_SetWave(59, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(60, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(61, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(62, 11, 'n032', 0, 0, 0, 'n03Q', 6, 7, 5.00, 30);
    WS_SetWave(63, 11, 'n033', 0, 0, 0, 'n03S', 2, 3, 5.00, 30);
    WS_SetWave(64, 11, 'n034', 0, 0, 0, 'n03O', 1, 5, 5.00, 30);
    WS_SetWave(65, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(66, 1, 0, 0, 0, 0, 0, 0, 0, 6.00, 66);
    WS_SetWave(67, 14, 'e00W', 0, 0, 0, 'e00X', 4, 9, 5.00, 20);
    WS_SetWave(68, 14, 'n062', 0, 0, 0, 'n063', 2, 4, 5.00, 30);
    WS_SetWave(69, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(70, 1, 'n066', 0, 0, 0, 'n06B', 5, 6, 5.00, 30);
    WS_SetWave(71, 1, 'h05J', 0, 0, 0, 'h05L', 3, 4, 4.00, 30);
    WS_SetWave(72, 1, 'e00U', 0, 0, 0, 'e00V', 1, 4, 5.00, 32);
    WS_SetWave(73, 1, 'h05K', 0, 0, 0, 'h05M', 3, 4, 5.00, 30);
    WS_SetWave(74, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    WS_SetWave(75, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}

void WS_LoadSpawnRects() {
    WS_NormalSpawnRects[1] = Jass::Rect(-7456.0, -704.0, -7168.0, -288.0);
    WS_NormalSpawnRects[2] = Jass::Rect(-2848.0, -1440.0, -2688.0, -1312.0);
    WS_NormalSpawnRects[3] = Jass::Rect(7200.0, -1632.0, 7328.0, -1504.0);
    WS_NormalSpawnRects[4] = Jass::Rect(7477.0, -1514.0, 7707.0, -1585.0);
    WS_NormalSpawnRects[5] = Jass::Rect(6848.0, 7040.0, 6976.0, 7168.0);
    WS_NormalSpawnRects[6] = Jass::Rect(2304.0, 7008.0, 2560.0, 7264.0);
    WS_NormalSpawnRects[7] = Jass::Rect(4128.0, -3648.0, 4256.0, -3552.0);
    WS_NormalSpawnRects[8] = Jass::Rect(-416.0, -7008.0, -256.0, -6880.0);
    WS_NormalSpawnRects[9] = Jass::Rect(-6976.0, -6368.0, -6816.0, -6240.0);
    WS_NormalSpawnRects[10] = Jass::Rect(7680.0, -6752.0, 7840.0, -6624.0);
    WS_NormalSpawnRects[11] = Jass::Rect(7008.0, -3904.0, 7168.0, -3776.0);
    WS_NormalSpawnRects[12] = Jass::Rect(14989.0, -150.0, 14825.0, -519.0);
    WS_NormalSpawnRects[13] = Jass::Rect(10949.0, 5160.0, 11221.0, 5094.0);
    WS_NormalSpawnRects[14] = Jass::Rect(9702.0, -7010.0, 9822.0, -7213.0);

    WS_DemonSpawnRects[1] = Jass::Rect(-5408.0, 3264.0, -5216.0, 3456.0);
    WS_DemonSpawnRects[2] = Jass::Rect(-1952.0, 5376.0, -1760.0, 5568.0);
    WS_DemonSpawnRects[3] = Jass::Rect(-896.0, 320.0, -704.0, 512.0);
    WS_DemonSpawnRects[4] = Jass::Rect(2976.0, 2208.0, 3168.0, 2400.0);
    WS_DemonSpawnRects[5] = Jass::Rect(2144.0, -2272.0, 2336.0, -2080.0);
    WS_DemonSpawnRects[6] = Jass::Rect(-2144.0, -1696.0, -1952.0, -1504.0);
    WS_DemonSpawnRects[7] = Jass::Rect(-3648.0, -6880.0, -3456.0, -6688.0);
    WS_DemonSpawnRects[8] = Jass::Rect(4896.0, -5568.0, 5088.0, -5376.0);
}

void WS_PickSpawnPoint(int waveNum, float &out x, float &out y) {
    int wt = WS_WaveType[waveNum];

    if (wt == 11 || wt == 112 || wt == 113) {
        int i = Jass::GetRandomInt(1, 8);
        rect r = WS_DemonSpawnRects[i];
        x = Jass::GetRandomReal(Jass::GetRectMinX(r), Jass::GetRectMaxX(r));
        y = Jass::GetRandomReal(Jass::GetRectMinY(r), Jass::GetRectMaxY(r));
        return;
    }

    // Для type 14 используем обычные спавны как fallback.
    int idx = Jass::GetRandomInt(1, 14);
    rect nr = WS_NormalSpawnRects[idx];
    x = Jass::GetRandomReal(Jass::GetRectMinX(nr), Jass::GetRectMaxX(nr));
    y = Jass::GetRandomReal(Jass::GetRectMinY(nr), Jass::GetRectMaxY(nr));
}

void WS_SpawnUnitType(int unitType, float x, float y) {
    if (unitType == 0) return;

    unit u = Jass::CreateUnit(Jass::Player(11), unitType, x, y, 270.0);
}

void WS_SpawnCommonPack(int waveNum) {
    int minCnt = WS_WaveTickMinSpawns[waveNum];
    int maxCnt = WS_WaveTickMaxSpawns[waveNum];
    if (minCnt <= 0) minCnt = 1;
    if (maxCnt < minCnt) maxCnt = minCnt;

    int pack = Jass::GetRandomInt(minCnt, maxCnt);
    for (int i = 0; i < pack; i++) {
        float x;
        float y;
        WS_PickSpawnPoint(waveNum, x, y);

        int wt = WS_WaveType[waveNum];
        if (wt == 12 || wt == 112) {
            WS_SpawnUnitType(WS_WaveMob0[waveNum], x, y);
            WS_SpawnUnitType(WS_WaveMob1[waveNum], x, y);
            WS_SpawnUnitType(WS_WaveMob2[waveNum], x, y);
            WS_SpawnUnitType(WS_WaveMob3[waveNum], x, y);
        } else if (wt == 13 || wt == 113) {
            if (Jass::GetRandomInt(1, 2) == 1) {
                WS_SpawnUnitType(WS_WaveMob0[waveNum], x, y);
            } else {
                WS_SpawnUnitType(WS_WaveMob1[waveNum], x, y);
            }
        } else {
            WS_SpawnUnitType(WS_WaveMob0[waveNum], x, y);
        }
    }
}

void WS_TrySpawnMiniBoss(int waveNum, int nextSpawnCount) {
    int maxSpawns = WS_WaveMaxSpawns[waveNum];
    int miniType = WS_WaveMiniBoss[waveNum];
    if (maxSpawns <= 0 || miniType == 0) return;

    float progress = float(nextSpawnCount) / float(maxSpawns);
    bool needSpawn = (WS_WaveMinik == 0 && progress >= 0.3) || (WS_WaveMinik == 1 && progress >= 0.7);
    if (!needSpawn) return;

    WS_WaveMinik += 1;

    float x;
    float y;
    WS_PickSpawnPoint(waveNum, x, y);
    unit u = Jass::CreateUnit(Jass::Player(11), miniType, x, y, 270.0);
    RegisterUnit(u);
    UnitData@ ud = GetUnitData(u);
    ud.isMinik = true;
    if (WS_WaveMinik == 2)
        ud.isMiniBoss2 = true;

    if (u != nil) {
        Jass::SetUnitPathing(u, false);
    }
    u = nil;
}

void WS_StartBossWave(int waveNum) {
    if (waveNum == 5) Jass::ExecuteFunc("Trig_Wave_5_start_boss_Actions");
    else if (waveNum == 10) Jass::ExecuteFunc("Trig_Wave_10_start_boss_Actions");
    else if (waveNum == 15) Jass::ExecuteFunc("Trig_Wave_15_start_boss_Actions");
    else if (waveNum == 20) Jass::ExecuteFunc("Trig_Wave_20_start_boss_Actions");
    else if (waveNum == 25) Jass::ExecuteFunc("Trig_Wave_25_start_boss_Actions");
    else if (waveNum == 30) Jass::ExecuteFunc("Trig_Wave_30_start_boss_Actions");
    else if (waveNum == 35) Jass::ExecuteFunc("Trig_Wave_35_start_boss_Actions");
    else if (waveNum == 39) Jass::ExecuteFunc("Trig_Wave_39_start_boss_Actions");
    else if (waveNum == 45) Jass::ExecuteFunc("Trig_Wave_45_start_boss_Actions");
    else if (waveNum == 50) Jass::ExecuteFunc("Trig_Wave_50_start_boss_Actions");
    else if (waveNum == 55) Jass::ExecuteFunc("Trig_Wave_55_start_boss_Actions");
    else if (waveNum == 60) Jass::ExecuteFunc("Trig_Wave_60_start_boss_Actions");
    else if (waveNum == 65) Jass::ExecuteFunc("Trig_Wave_65_start_boss_Actions");
    else if (waveNum == 69) Jass::ExecuteFunc("Trig_Wave_69_start_boss_Actions");
    else if (waveNum == 74) Jass::ExecuteFunc("Trig_Wave_74_start_boss_Actions");
    else if (waveNum == 75) {
        if (Jass::GetRandomInt(1, 2) == 1) {
            Jass::ExecuteFunc("Trig_Wave_751_start_boss_Actions");
        } else {
            Jass::ExecuteFunc("Trig_Wave_752_start_boss_Actions");
        }
    }
}

void WS_StartSpecialWave(int waveNum) {
    if (waveNum == 36) Jass::ExecuteFunc("Trig_Wave_36_start_Actions");
    if (waveNum == 43) Jass::ExecuteFunc("Trig_Wave_43_start_Actions");
    if (waveNum == 44) Jass::ExecuteFunc("Trig_Wave_44_start_Actions");
    if (waveNum == 49) Jass::ExecuteFunc("Trig_Wave_49_start_Actions");
    if (waveNum == 54) Jass::ExecuteFunc("Trig_Wave_54_start_Actions");
    if (waveNum == 59) Jass::ExecuteFunc("Trig_Wave_59_start_Actions");
    if (waveNum == 61) Jass::ExecuteFunc("Trig_Wave_61_start_Actions");
}

void WS_StartCurrentWave() {
    int waveNum = udg_Wave_Number;
    int wt = WS_WaveType[waveNum];

    WS_WaveMinik = 0;
    WS_Pack_next_time = 0;
    udg_WaveWait = false;
    udg_Wave_count_spawns = 1;

    if (waveNum >= 1 && waveNum < int(g_Text_Wave_Brif.length())) {
        WS_MessagePlayers(g_Text_Wave_Brif[waveNum], 6.0);
    }

    if (wt == 2) {
        WS_StartBossWave(waveNum);
    } else if (wt == 3) {
        WS_StartSpecialWave(waveNum);
    }
}

void WS_EndCurrentWave() {
    int waveNum = udg_Wave_Number;

    if (waveNum >= 1 && waveNum < int(g_Text_Wave_Debrif.length())) {
        WS_MessagePlayers(g_Text_Wave_Debrif[waveNum], 6.0);
    }

    WS_WaveMinik = 0;
    WS_Pack_next_time = 0;
    udg_WaveWait = false;
    udg_Wave_count_spawns = 0;

    udg_Wave_Number += 1;
    udg_Wave_Number_Count += 1;
    udg_Wave_Number_TP = udg_Wave_Number;

    if (udg_Wave_Number > 75) {
        udg_Wave_Last = true;
        WS_MessagePlayers("All waves completed.", 8.0);
        return;
    }

    if (WS_ShortMode) {
        udg_Wave_next_time = 10;
    } else if (WS_WaveType[udg_Wave_Number] == 2) {
        udg_Wave_next_time = 120;
    } else {
        udg_Wave_next_time = 200;
    }
}

void WS_ProcessCommonWave() {
    int waveNum = udg_Wave_Number;

    if (udg_Wave_count_spawns == 0) {
        WS_StartCurrentWave();
        return;
    }

    int maxTicks = WS_WaveMaxSpawns[waveNum];
    if (udg_Wave_count_spawns <= maxTicks) {
        if (udg_wave_count >= 60) {
            return;
        }

        int nextSpawnCount = udg_Wave_count_spawns + 1;
        udg_Wave_count_spawns = nextSpawnCount;
        WS_TrySpawnMiniBoss(waveNum, nextSpawnCount);
        WS_SpawnCommonPack(waveNum);

        int nextTick = int(WS_WaveTickTimer[waveNum]);
        if (nextTick < 1) nextTick = 1;
        WS_Pack_next_time = nextTick;
        return;
    }

    if (udg_wave_count <= 0) {
        udg_WaveWait = false;
        WS_EndCurrentWave();
    } else {
        udg_WaveWait = true;
    }
}

void WS_ProcessBossOrSpecialWave() {
    if (udg_Wave_count_spawns == 0) {
        WS_StartCurrentWave();
        return;
    }

    if (udg_wave_count <= 0) {
        WS_EndCurrentWave();
    } 
}

void WS_OnTick() {
    if (udg_Wave_Last) return;
    if(!GameStarted) return;
    if (udg_Wave_next_time > 0) {
        if (WS_ShortMode && udg_Wave_next_time > 10) {
            udg_Wave_next_time = 10;
        }
        udg_Wave_next_time -= 1;
        return;
    }

    if (WS_Pack_next_time > 0) {
        WS_Pack_next_time -= 1;
        return;
    }

    int wt = WS_WaveType[udg_Wave_Number];
    if (WS_IsCommonWaveType(wt)) {
        WS_ProcessCommonWave();
    } else {
        WS_ProcessBossOrSpecialWave();
    }
}

void InitWaveSystemAS() {
    if (!WS_Initialized) {
        WS_LoadConfig();
        WS_LoadSpawnRects();
        WS_Initialized = true;
    }

    udg_Wave_Number = 1;
    udg_Wave_count_spawns = 0;
    udg_Wave_next_time = 120;
    udg_Wave_Number_Count = 1;
    udg_Wave_Number_TP = 1;
    udg_Wave_Last = false;
    udg_wave_count = 0;
    WS_Pack_next_time = 0;
    WS_WaveMinik = 0;

    if (WS_WaveTimer != nil) {
        Jass::DestroyTimer(WS_WaveTimer);
    }
    WS_WaveTimer = Jass::CreateTimer();
    Jass::TimerStart(WS_WaveTimer, 1.0, true, @WS_OnTick);

    WS_MessagePlayers("AS Wave system initialized", 4.0);
}
