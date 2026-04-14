multiboard MainMulitboard = nil;
multiboard MainMultiboard = nil; // Compatibility alias for existing AS references.

timer MB_UpdateTimer = nil;
int MB_ElapsedSeconds = 0;
int MB_BuffLuck = 0;
array<int> MB_WaveReached(11);
int MB_PlayerRowsCount = 0;
array<int> MB_RowPlayerId(10);

string MB_PlayerColor(int playerNumber1) {
    if (playerNumber1 == 1) return "|c00FF0000";
    if (playerNumber1 == 2) return "|c000000FF";
    if (playerNumber1 == 3) return "|c001CE6B9";
    if (playerNumber1 == 4) return "|c00540081";
    if (playerNumber1 == 5) return "|c00FFFC01";
    if (playerNumber1 == 6) return "|c00FEBA0E";
    if (playerNumber1 == 7) return "|c0020C000";
    if (playerNumber1 == 8) return "|c00E55BB0";
    if (playerNumber1 == 9) return "|c00C0C0C0";
    if (playerNumber1 == 10) return "|c007EBFF1";
    if (playerNumber1 == 11) return "|c00106246";
    if (playerNumber1 == 12) return "|c004E2A04";
    return "|c00FFFFFF";
}

string MB_HeroIcon(unit u) {
    if (u == nil) return "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp";

    int id = Jass::GetUnitTypeId(u);
    if (id == 'N000' or id == 'N100') return "ReplaceableTextures\\CommandButtons\\BTNHeroTinker.blp";
    if (id == 'H000') return "BTNGoblinIn.blp";
    if (id == 'H003') return "BTNGoblinZeppelin.BLP";
    if (id == 'H001') return "BTNGoblinPyrotechnician.blp";
    if (id == 'H002') return "BTNGoblinFireworker.blp";
    if (id == 'H005') return "BTNGoblinMiner.blp";
    if (id == 'H006') return "BTNBombardier.blp";
    if (id == 'H004' or id == 'H104') return "BTNGoblintinkeralt.blp";

    return "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp";
}

float MB_UnitLifePercent(unit u) {
    if (u == nil) return 0.0;
    float maxLife = Jass::GetUnitMaxLife(u);
    if (maxLife <= 0.0) return 0.0;
    return Jass::GetUnitCurrentLife(u) / maxLife * 100.0;
}

float MB_UnitManaPercent(unit u) {
    if (u == nil) return 0.0;
    float maxMana = Jass::GetUnitMaxMana(u);
    if (maxMana <= 0.0) return 0.0;
    return Jass::GetUnitCurrentMana(u) / maxMana * 100.0;
}

bool MB_IsUnitAlive(unit u) {
    if (u == nil) return false;
    if (Jass::GetUnitState(u, Jass::UNIT_STATE_LIFE) <= 0.0) return false;
    if (Jass::IsUnitType(u, Jass::UNIT_TYPE_DEAD)) return false;
    return true;
}

void MB_SetItemStyle(int col1, int row1, bool showValue, bool showIcon) {
    if (MainMulitboard == nil) return;
    multiboarditem it = Jass::MultiboardGetItem(MainMulitboard, row1 - 1, col1 - 1);
    Jass::MultiboardSetItemStyle(it, showValue, showIcon);
    Jass::MultiboardReleaseItem(it);
    it = nil;
}

void MB_SetItemWidth(int col1, int row1, float width) {
    if (MainMulitboard == nil) return;
    multiboarditem it = Jass::MultiboardGetItem(MainMulitboard, row1 - 1, col1 - 1);
    Jass::MultiboardSetItemWidth(it, width / 100.0);
    Jass::MultiboardReleaseItem(it);
    it = nil;
}

void MB_SetItemValue(int col1, int row1, string value) {
    if (MainMulitboard == nil) return;
    multiboarditem it = Jass::MultiboardGetItem(MainMulitboard, row1 - 1, col1 - 1);
    Jass::MultiboardSetItemValue(it, value);
    Jass::MultiboardReleaseItem(it);
    it = nil;
}

void MB_SetItemIcon(int col1, int row1, string iconPath) {
    if (MainMulitboard == nil) return;
    multiboarditem it = Jass::MultiboardGetItem(MainMulitboard, row1 - 1, col1 - 1);
    Jass::MultiboardSetItemIcon(it, iconPath);
    Jass::MultiboardReleaseItem(it);
    it = nil;
}

string MB_Format2(int v) {
    if (v < 10) return "0" + Jass::I2S(v);
    return Jass::I2S(v);
}

void MB_SetClockTitle() {
    int sec = MB_ElapsedSeconds % 60;
    int min = (MB_ElapsedSeconds / 60) % 60;
    int hour = MB_ElapsedSeconds / 3600;
    string title = "|c00FF8000Экспедиция гоблинов |r" + MB_Format2(hour) + ":" + MB_Format2(min) + ":" + MB_Format2(sec);
    Jass::MultiboardSetTitleText(MainMulitboard, title);
}

int MB_GetPlayerLuck(int playerNumber1, unit goblin) {
    if (!MB_IsUnitAlive(goblin)) return 0;
    UnitData@ ud = GetUnitData(goblin);
    if (ud is null) return 0;
    return int(ud.totalStats.luck);
}

int MB_GetWaveNextTimeDisplay() {
    return udg_Wave_next_time;
}

void MB_UpdatePlayersRows() {
    int luckTeamSum = MB_BuffLuck;

    for (int idx = 0; idx < MB_PlayerRowsCount; idx++) {
        int pid = MB_RowPlayerId[idx];
        int i = pid + 1;
        int row = idx + 2;

        player p = Jass::Player(pid);
        unit u = GoblinUnit[pid];
        bool alive = MB_IsUnitAlive(u);

        string pName = Jass::GetPlayerName(p);
        if (Jass::GetPlayerSlotState(p) == Jass::PLAYER_SLOT_STATE_PLAYING) {
            if (Admin_Player == p) {
                MB_SetItemValue(2, row, Jass::I2S(i) + ". " + "|c00FFFFFF•A•|r " + MB_PlayerColor(i) + pName + "|r");
            } else {
                MB_SetItemValue(2, row, Jass::I2S(i) + ". " + MB_PlayerColor(i) + pName + "|r");
            }
        } else {
            MB_SetItemValue(2, row, Jass::I2S(i) + ". |c00999999" + pName + "|r");
        }

        if (u != nil) {
            MB_SetItemIcon(1, row, MB_HeroIcon(u));
            MB_SetItemValue(3, row, Jass::I2S(Jass::GetHeroLevel(u)));
        } else {
            MB_SetItemIcon(1, row, "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp");
            MB_SetItemValue(3, row, "-");
        }

        float lifePct = MB_UnitLifePercent(u);
        if (alive && lifePct > 50.0) {
            MB_SetItemValue(4, row, "|c0000FF00" + Jass::I2S(Jass::R2I(lifePct)) + "%|r");
        } else if (alive && lifePct > 20.0) {
            MB_SetItemValue(4, row, "|c00FFFF00" + Jass::I2S(Jass::R2I(lifePct)) + "%|r");
        } else if (alive && lifePct > 0.0) {
            MB_SetItemValue(4, row, "|c00FF0000" + Jass::I2S(Jass::R2I(lifePct)) + "%|r");
        } else {
            MB_SetItemValue(4, row, "|c009999990%|r");
        }

        float manaPct = MB_UnitManaPercent(u);
        if (alive && manaPct > 50.0) {
            MB_SetItemValue(5, row, "|c000080FF" + Jass::I2S(Jass::R2I(manaPct)) + "%|r");
        } else if (alive && manaPct > 20.0) {
            MB_SetItemValue(5, row, "|c00FFFF00" + Jass::I2S(Jass::R2I(manaPct)) + "%|r");
        } else if (alive && manaPct > 0.0) {
            MB_SetItemValue(5, row, "|c00FF0000" + Jass::I2S(Jass::R2I(manaPct)) + "%|r");
        } else {
            MB_SetItemValue(5, row, "|c009999990%|r");
        }

        MB_SetItemValue(6, row, "|c00FF8080" + Jass::I2S(Jass::GetPlayerState(p, Jass::PLAYER_STATE_RESOURCE_LUMBER)) + "|r");

        if (alive && MB_WaveReached[i] <= udg_Wave_Number) {
            MB_WaveReached[i] = udg_Wave_Number;
        }
        MB_SetItemValue(7, row, "|c0000AAAA" + Jass::I2S(MB_WaveReached[i]) + "|r");

        if (alive) {
            int luck = MB_GetPlayerLuck(i, u);
            luckTeamSum += luck;

            if (luck > 25) {
                MB_SetItemValue(8, row, "|c0020FF20" + Jass::I2S(luck) + "|r");
            } else if (luck > 0) {
                MB_SetItemValue(8, row, "|c00FFFF00" + Jass::I2S(luck) + "|r");
            } else if (luck == 0) {
                MB_SetItemValue(8, row, "|c00BBBBBB" + Jass::I2S(luck) + "|r");
            } else {
                MB_SetItemValue(8, row, "|c00FF2000" + Jass::I2S(luck) + "|r");
            }
        } else {
            MB_SetItemValue(8, row, "|c00999999 - |r");
        }

        p = nil;
        u = nil;
    }

    int enemiesRow = MB_PlayerRowsCount + 3;
    if (udg_wave_count == 0) {
        MB_SetItemValue(1, enemiesRow, "|c00FF0000Врагов: |r|c0080FF80" + Jass::I2S(udg_wave_count));
    } else if (udg_wave_count <= 30) {
        MB_SetItemValue(1, enemiesRow, "|c00FF0000Врагов: |r|c00FFFF80" + Jass::I2S(udg_wave_count));
    } else if (udg_wave_count <= 90) {
        MB_SetItemValue(1, enemiesRow, "|c00FF0000Врагов: |r|c00FF8000" + Jass::I2S(udg_wave_count));
    } else {
        MB_SetItemValue(1, enemiesRow, "|c00FF0000Врагов: |r|c00FF0000" + Jass::I2S(udg_wave_count));
    }
    if(!GameStarted) {
        MB_SetItemValue(2, enemiesRow, "|c0000AAFFОжидание начала игры...|r");
    }
    else {
        int waveNextTime = MB_GetWaveNextTimeDisplay();
        if (waveNextTime > 0) {
            MB_SetItemValue(2, enemiesRow,
                Jass::I2S(waveNextTime) + "|c00AAFF00с. до волны |r " + Jass::I2S(udg_Wave_Number));
        } else {
            int waveState = 0;
            int maxSpawns = WS_WaveMaxSpawns[udg_Wave_Number];
            if (maxSpawns > 0) {
                waveState = Jass::R2I(float(udg_Wave_count_spawns) / float(maxSpawns) * 100.0);
            }
            if (waveState > 100) waveState = 100;
            MB_SetItemValue(2, enemiesRow,
                "|c00FF0000Волна: |r|c0080FF80" + Jass::I2S(udg_Wave_Number) + " (" + Jass::I2S(waveState) + "%)");
        }
    }

    int luckRow = MB_PlayerRowsCount + 4;
    if (luckTeamSum > 40) {
        MB_SetItemValue(1, luckRow, "|c00FF8000Удача команды: |r40+");
    } else {
        MB_SetItemValue(1, luckRow, "|c00FF8000Удача команды: |r" + Jass::I2S(luckTeamSum));
    }
}

void MainMultiboardUpdate() {
    if (MainMulitboard == nil) return;
    if (!GameStarted) return;
    MB_ElapsedSeconds += 1;
    MB_SetClockTitle();
    MB_UpdatePlayersRows();
}

void MainMultiboardTick() {
    MainMultiboardUpdate();
}

void MainMultiboardApplyLayout() {
    int rowCount = Jass::MultiboardGetRowCount(MainMulitboard);

    for (int row = 1; row <= rowCount; row++) {
        MB_SetItemStyle(1, row, false, true);
        MB_SetItemStyle(2, row, true, false);
        MB_SetItemStyle(3, row, true, false);
        MB_SetItemStyle(4, row, true, false);
        MB_SetItemStyle(5, row, true, false);
        MB_SetItemStyle(6, row, true, false);
        MB_SetItemStyle(7, row, true, false);
        MB_SetItemStyle(8, row, true, false);

        MB_SetItemWidth(1, row, 1.10);
        MB_SetItemWidth(2, row, 10.00);
        MB_SetItemWidth(3, row, 2.00);
        MB_SetItemWidth(4, row, 3.50);
        MB_SetItemWidth(5, row, 3.50);
        MB_SetItemWidth(6, row, 2.00);
        MB_SetItemWidth(7, row, 2.20);
        MB_SetItemWidth(8, row, 1.10);
    }

    MB_SetItemStyle(6, 1, false, true);
    MB_SetItemStyle(8, 1, false, true);

    MB_SetItemStyle(1, MB_PlayerRowsCount + 3, true, false);
    MB_SetItemStyle(1, MB_PlayerRowsCount + 4, true, false);
    MB_SetItemStyle(1, MB_PlayerRowsCount + 5, true, false);

    MB_SetItemWidth(1, MB_PlayerRowsCount + 3, 10.00);
    MB_SetItemWidth(2, MB_PlayerRowsCount + 3, 10.00);
    MB_SetItemWidth(1, MB_PlayerRowsCount + 4, 10.00);
    MB_SetItemWidth(2, MB_PlayerRowsCount + 4, 10.00);
    MB_SetItemWidth(1, MB_PlayerRowsCount + 5, 10.00);
    MB_SetItemWidth(2, MB_PlayerRowsCount + 5, 10.00);

    MB_SetItemIcon(1, 1, "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp");
    MB_SetItemIcon(8, 1, "BTNClover.blp");
    MB_SetItemValue(2, 1, "|c0000FFFFИгрок|r");
    MB_SetItemValue(3, 1, "|c0000FFFFУр.|r");
    MB_SetItemValue(4, 1, "|c0000FFFFХп|r");
    MB_SetItemValue(5, 1, "|c0000FFFFМп|r");
    MB_SetItemIcon(6, 1, "BTNINV_Misc_Food_13.blp");
    MB_SetItemValue(7, 1, "|c0000FFFFВолн|r");

    for (int col = 1; col <= 8; col++) {
        MB_SetItemStyle(col, MB_PlayerRowsCount + 2, true, false);
        MB_SetItemWidth(col, MB_PlayerRowsCount + 2, 0.0);
    }
    MB_SetItemWidth(1, MB_PlayerRowsCount + 2, 25.4);
    MB_SetItemValue(1, MB_PlayerRowsCount + 2,
        "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
}

void InitMainMultiboardSystem() {
    if (MainMulitboard != nil) {
        Jass::DestroyMultiboard(MainMulitboard);
        MainMulitboard = nil;
        MainMultiboard = nil;
    }

    for (int i = 0; i <= 10; i++) {
        MB_WaveReached[i] = 0;
    }

    MB_PlayerRowsCount = 0;
    for (int i = 0; i < 10; i++) {
        player p = Jass::Player(i);
        if (Jass::IsPlayerInForce(p, PlayerForces)) {
            MB_RowPlayerId[MB_PlayerRowsCount] = i;
            MB_PlayerRowsCount += 1;
        }
        p = nil;
    }

    MB_ElapsedSeconds = 0;
    MainMulitboard = Jass::CreateMultiboard();
    MainMultiboard = MainMulitboard;

    Jass::MultiboardSetRowCount(MainMulitboard, MB_PlayerRowsCount + 5);
    Jass::MultiboardSetColumnCount(MainMulitboard, 8);
    Jass::MultiboardSetTitleText(MainMulitboard, "|c00FF8000Экспедиция гоблинов |r00:00:00");
    Jass::MultiboardDisplay(MainMulitboard, true);
    Jass::MultiboardMinimize(MainMulitboard, true);

    MainMultiboardApplyLayout();
    MainMultiboardUpdate();

    if (MB_UpdateTimer != nil) {
        Jass::PauseTimer(MB_UpdateTimer);
        Jass::DestroyTimer(MB_UpdateTimer);
        MB_UpdateTimer = nil;
    }

    MB_UpdateTimer = Jass::CreateTimer();
    Jass::TimerStart(MB_UpdateTimer, 1.00, true, @MainMultiboardTick);
}
