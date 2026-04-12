const int GC_RANGE_TIMER_KEY = 0;

trigger GC_ChatTrigger = nil;
trigger GC_AntiBotTrigger = nil;
trigger GC_NoffTrigger = nil;
hashtable SH = Jass::InitHashtable();

force ADEPTS;
force INKVISITION;
force KS_KickedPlayers;

array<bool> AliveGoblin(12);
array<bool> KS_Voted(11);
bool NoEnabled = false;
bool YesEnabled = false;

int KS_YesVotes = 0;
int KS_NoVotes  = 0;
leaderboard KS_Leaderboard = nil;
array<int> Cam_dist(20);

float Dmg_Just_Overall;
array<float> Dmg_MASSIVE(11);
array<float> Dmg_Massive_Phys(11);
array<float> Dmg_Massive_Magic(11);
array<float> Dmg_Massive_Pure(11);

array<group> CheckRangeUnits(20);

void ForceSetLeaderboard(leaderboard lb, force f) {
    for (int i = 0; i < 16; i++) {
        player p = Jass::Player(i);
        if (Jass::IsPlayerInForce(p, f)) {
            Jass::PlayerSetLeaderboard(p, lb);
        }
    }
}

int GC_MinInt(int a, int b) {
    return (a < b) ? a : b;
}

bool GC_IsAnalyzeCommand(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    if (cmd == "a" or cmd == "f" or cmd == "ф" or cmd == "а") return true;
    return false;
}

bool GC_IsShortModeOnCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "св" or cmd == "ыц" or cmd == "sw" or cmd == "cd";
}

bool GC_IsShortModeOffCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "носв" or cmd == "тщыц" or cmd == "nosw" or cmd == "yjcd";
}

bool GC_IsSkipCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "skip" or cmd == "ылшз" or cmd == "скип" or cmd == "crbg";
}

bool GC_IsRepickCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "repick" or cmd == "кузшсл" or cmd == "репик";
}

bool GC_IsCamCmd(string chatString) {
    if (Jass::SubString(chatString, 1, 5) == "zoom") return true;
    if (Jass::SubString(chatString, 1, 9) == "ящщь") return true;
    if (Jass::SubString(chatString, 1, 4) == "cam") return true;
    if (Jass::SubString(chatString, 1, 5) == "camm") return true;
    if (Jass::SubString(chatString, 1, 4) == "rfv") return true;
    if (Jass::SubString(chatString, 1, 4) == "pev") return true;
    if (Jass::SubString(chatString, 1, 4) == "кам") return true;
    if (Jass::SubString(chatString, 1, 5) == "камм") return true;
    if (Jass::SubString(chatString, 1, 4) == "сфь") return true;
    if (Jass::SubString(chatString, 1, 4) == "зум") return true;
    return false;
}

bool GC_IsClearCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "clear" or cmd == "cl" or cmd == "очт" or cmd == "кл" or cmd == "очистить" or cmd == "клеар";
}

bool GC_IsRollCmd(string chatString) {
    string cmd = Jass::SubString(chatString, 1, Jass::StringLength(chatString));
    return cmd == "roll" or cmd == "ролл";
}

bool GC_IsVipOrAdmin(player p) {
    //if (Jass::IsPlayerInForce(p, udg_VIP)) return true;
    return Admin_Player == p;
}

bool GC_IsAdeptOrInk(player p) {
    return Jass::IsPlayerInForce(p, ADEPTS) or Jass::IsPlayerInForce(p, INKVISITION);
}

bool GC_IsKickTargetInvalid(player triggerPlayer, int kickPlayerNr) {
    if (kickPlayerNr <= 0) return true;
    if (kickPlayerNr == Jass::GetPlayerId(triggerPlayer) + 1) return true;
    if (kickPlayerNr > 10) return true;

    player target = Jass::Player(kickPlayerNr - 1);
    if (Jass::GetPlayerSlotState(target) == Jass::PLAYER_SLOT_STATE_EMPTY) return true;
    if (Jass::IsPlayerInForce(target, KS_KickedPlayers)) return true;
    if (Jass::GetPlayerSlotState(target) == Jass::PLAYER_SLOT_STATE_LEFT) return true;

    target = nil;
    return false;
}

void GC_RemoveItemsOnRepick() {
    item it = Jass::GetEnumItem();
    if (Jass::GetItemUserData(it) == udg_Dummy_Int) {
        Jass::RemoveItem(it);
    }
    it = nil;
}

void GC_RemoveRangeMarker() {
    unit u = Jass::GetEnumUnit();
    if (Jass::GetWidgetLife(u) > 0) {
        Jass::KillUnit(u);
    }
    u = nil;
}

void GC_RemoveRangeTimer() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    Jass::RemoveSavedHandle(SH, Jass::LoadInteger(SH, th, 0), GC_RANGE_TIMER_KEY);
    Jass::FlushChildHashtable(SH, th);
    Jass::DestroyTimer(t);
    t = nil;
}

void GC_KickVoteTimeEnd() {
    //Trig_KS_TimeEnd_Actions();
}

void GC_ListAdminCandidates() {
    if (Jass::GetLocalPlayer() != ChatPlayer) return;

    for (int i = 0; i < 10; i++) {
        int pn = i + 1;
        if (AliveGoblin[pn]) {
            player p = Jass::Player(i);
            Jass::DisplayTextToPlayer(Jass::GetLocalPlayer(), 0, 0,
                PlayerColour(pn) + Jass::GetPlayerName(p) + "|r = " + Jass::I2S(pn));
            p = nil;
        }
    }
}

void GC_HandleKickVote(string chatString, player chatPlayer, int convertedPid) {
    if ((Jass::SubString(chatString, 0, 3) == "-да" or Jass::SubString(chatString, 0, 4) == "-yes") and YesEnabled) {
        if (!KS_Voted[convertedPid]) {
            if (GC_IsAdeptOrInk(chatPlayer)) {
                KS_YesVotes += 999;
            } else {
                KS_YesVotes += 1;
            }
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Голос засчитан|r");
            KS_Voted[convertedPid] = true;
            Jass::LeaderboardSetLabel(KS_Leaderboard,
                "Голосование - За: " + Jass::I2S(KS_YesVotes) + " Против: " + Jass::I2S(KS_NoVotes));
        } else {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Вы уже голосовали!|r");
        }
        return;
    }

    if ((Jass::SubString(chatString, 0, 3) == "-no" or Jass::SubString(chatString, 0, 4) == "-нет") and NoEnabled) {
        if (!KS_Voted[convertedPid]) {
            if (GC_IsAdeptOrInk(chatPlayer)) {
                KS_NoVotes += 999;
            } else {
                KS_NoVotes += 1;
            }
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Голос засчитан|r");
            KS_Voted[convertedPid] = true;
            Jass::LeaderboardSetLabel(KS_Leaderboard,
                "Голосование - За: " + Jass::I2S(KS_YesVotes) + " Против: " + Jass::I2S(KS_NoVotes));
        } else {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Вы уже голосовали!|r");
        }
        return;
    }
}

string ChatString;
int ChatStringLength;
player ChatPlayer;
int udg_Dummy_Int;
bool udg_KS_CanVote = false;
int udg_KS_KickPlayerNR = 0;
int KS_TempInteger = 0;
timer KS_Timer = nil;
array<bool> PlayerHaveConsole(16);
float Dummy_CosSin_Radius = 0;
float Dummy_Angle = 0;
float Dummy_Angle2 = 0;

void GC_OnChat() {
    int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
    int convertedPid = pid + 1;

    int Value = 0;
    int Value2 = 0;

    string chatString = Jass::GetEventPlayerChatString();
    int chatLen = Jass::StringLength(chatString);

    string text = Jass::SubString(chatString, 1, chatLen);
    int emptyAt = FindEmptyString(0, text);
    string command = Jass::SubString(text, 0, emptyAt);
    string payload = Jass::SubString(text, emptyAt + 1, chatLen);
    int emptyAt2 = FindEmptyString(0, payload);
    string payload2 = Jass::SubString(payload, emptyAt2 + 1, chatLen);

    Value = Jass::S2I(payload);
    Value2 = Jass::S2I(payload2);

    ChatString = chatString;
    ChatStringLength = chatLen;
    ChatPlayer = Jass::GetTriggerPlayer();
    udg_Dummy_Int = convertedPid;

    player chatPlayer = ChatPlayer;
    unit u = GoblinUnit[pid];
    unit selected = SelectedUnit(chatPlayer);
    int i = 0;
    int i2 = 0;
    float x = 0.;
    float y = 0.;
    float x2 = 0.;
    float y2 = 0.;
    string sstring = "";
    timer t;
    group g;
    item itm2;
    ability abil;
    int abi_id = 0;
    framehandle fh;

    int players_want_to_start = 0;

    GC_HandleKickVote(chatString, chatPlayer, convertedPid);

    Jass::ConsolePrint("Chat command: " + chatString + " from player " + Jass::GetPlayerName(chatPlayer));

    if (Jass::SubString(chatString, 0, 5) == "-kick" or Jass::SubString(chatString, 0, 4) == "-кик") {
        if (udg_KS_CanVote) {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Вы должны дождаться окончания этого голосования.|r");
            return;
        }

        udg_KS_KickPlayerNR = Value;
        if (GC_IsKickTargetInvalid(chatPlayer, udg_KS_KickPlayerNR)) {
            udg_KS_KickPlayerNR = 0;
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "|cfffed312Вы должны указать верный номер игрока, чтобы выгнать его.|r");
            return;
        }

        DisplayTextToPlayers(Jass::GetPlayerName(chatPlayer) + " |cfffed312хочет выгнать игрока |r" + Jass::GetPlayerName(Jass::Player(udg_KS_KickPlayerNR - 1)));

        KS_NoVotes = 1;
        if (GC_IsAdeptOrInk(chatPlayer)) {
            KS_YesVotes = 999;
            //Jass::TriggerEvaluate(gg_trg_KS_KickPlayer);
            return;
        } else {
            KS_YesVotes = 1;
        }

        udg_KS_CanVote = true;
        Jass::DisplayTextToPlayer(Jass::GetLocalPlayer(), 0, 0, "TRIGSTR_15417");

        KS_Voted[udg_KS_KickPlayerNR] = true;
        KS_Voted[convertedPid] = true;

        YesEnabled = true;
        NoEnabled = true;

        KS_TempInteger = 1;
        while (KS_TempInteger <= 10) {
            KS_Voted[KS_TempInteger] = false;
            KS_TempInteger += 1;
        }

        KS_Leaderboard = Jass::CreateLeaderboard();
        Jass::LeaderboardSetLabel(KS_Leaderboard,
            "Голосование - За: " + Jass::I2S(KS_YesVotes) + " Против: " + Jass::I2S(KS_NoVotes));
        ForceSetLeaderboard(KS_Leaderboard, PlayerForces);
        Jass::LeaderboardDisplay(KS_Leaderboard, true);
        Jass::LeaderboardAddItem(KS_Leaderboard,
            "|cfffed312Кик: |r" + Jass::GetPlayerName(Jass::Player(udg_KS_KickPlayerNR - 1)), 0, Jass::Player(udg_KS_KickPlayerNR - 1));
        Jass::LeaderboardSetStyle(KS_Leaderboard, true, true, false, false);
        KS_Timer = Jass::CreateTimer();
        Jass::TimerStart(KS_Timer, 20.00, false, @GC_KickVoteTimeEnd);
        //Jass::EnableTrigger(gg_trg_KS_KickPlayer);
        //Jass::TriggerEvaluate(gg_trg_KS_KickPlayer);
        return;
    }

    ///////if (GetSave_DN_Hazyl(chatPlayer) > 0 and Jass::SubString(chatString, 0, 6) == "-hazyl") {

    if (Jass::SubString(chatString, 0, 5) == "-kill") {
        if (u != nil) {
            Jass::RemoveItem(GetItemOfTypeFromUnitEx(u, 'I046'));
        }
        return;
    }

    if (Jass::SubString(chatString, 0, 8) == "-console") {
        if (Jass::GetLocalPlayer() == chatPlayer) {
            Jass::ConsoleEnable(true);
        }
        PlayerHaveConsole[pid] = true;
        return;
    }

    if (Jass::SubString(chatString, 0, 5) != "-time" and Jass::SubString(chatString, 0, 2) == "-t") {
        i = Jass::S2I(Jass::SubString(chatString, 3, 5));
        if (i < 1 or i > 10) return;

        Jass::SetPlayerAlliance(Jass::Player(i - 1), chatPlayer, Jass::ALLIANCE_SHARED_ADVANCED_CONTROL, true);
        if (MainMulitboard != nil) Jass::MultiboardDisplay(MainMulitboard, true);
        //Jass::MultiboardDisplay(Jass::bj_lastCreatedMultiboard, false);
        return;
    }

    if (command == "g" and Value2 == 0 and GameStarted) {
        i = Value;
        int playerGold = Jass::GetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD);
        if (i < 0 or i > playerGold) {
            i = playerGold;
        }

        if (selected == nil) {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "Невозможно скинуть " + Jass::I2S(i) + " голды");
            return;
        }

        player targetOwner = Jass::GetOwningPlayer(selected);
        int targetPid = Jass::GetPlayerId(targetOwner);
        if (targetPid < 0 or targetPid > 10 or targetOwner == chatPlayer or Jass::IsPlayerEnemy(targetOwner, chatPlayer)) {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "Невозможно скинуть " + Jass::I2S(i) + " голды");
            targetOwner = nil;
            return;
        }

        Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "Передал Игроку: " + Jass::I2S(i) + " голды");
        Jass::DisplayTextToPlayer(targetOwner, 0, 0, "Получил: " + Jass::I2S(i) + " голды");

        Jass::SetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD,
            GC_MinInt(Jass::GetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD) - i, 1000000));
        Jass::SetPlayerState(targetOwner, Jass::PLAYER_STATE_RESOURCE_GOLD,
            GC_MinInt(Jass::GetPlayerState(targetOwner, Jass::PLAYER_STATE_RESOURCE_GOLD) + i, 1000000));

        targetOwner = nil;
        return;
    }

    if (command == "g" and Value2 > 1 and GameStarted) {
        i = Value2;
        if (Value > 10 or Value < 1) return;

        int playerGold = Jass::GetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD);
        if (i < 0 or i > playerGold) {
            i = playerGold;
        }

        player targetPlayer = Jass::Player(Value - 1);
        if (Jass::IsPlayerEnemy(targetPlayer, chatPlayer)) {
            Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "Невозможно скинуть Врагу голды");
            targetPlayer = nil;
            return;
        }

        Jass::DisplayTextToPlayer(chatPlayer, 0, 0, "Передал Игроку: " + Jass::I2S(i) + " голды");
        Jass::DisplayTextToPlayer(targetPlayer, 0, 0, "Получил: " + Jass::I2S(i) + " голды");

        Jass::SetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD,
            GC_MinInt(Jass::GetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD) - i, 1000000));
        Jass::SetPlayerState(targetPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD,
            GC_MinInt(Jass::GetPlayerState(targetPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD) + i, 1000000));

        targetPlayer = nil;
        return;
    }

    if (Jass::IsPlayerInForce(chatPlayer, ADEPTS)) {
        if (command == "mute" and Value2 == 0) {
            if (Value > 10 or Value < 1) {
                DisplayTextToPlayers("|c00FF0000Ошибка |r");
                return;
            }
            Jass::SetPlayerMuted(Jass::Player(Value - 1), true);
            DisplayTextToPlayers("|c00FF0000Был замучен игрок: |r" + Jass::GetPlayerName(Jass::Player(Value - 1)));
            return;
        }

        if (command == "unmute" and Value2 == 0) {
            if (Value > 10 or Value < 1) {
                DisplayTextToPlayers("|c00FF0000Ошибка |r");
                return;
            }
            Jass::SetPlayerMuted(Jass::Player(Value - 1), false);
            DisplayTextToPlayers("|c00FF0000Был размучен игрок: |r" + Jass::GetPlayerName(Jass::Player(Value - 1)));
            return;
        }

        if (command == "Console") {
            Jass::ConsoleEnable(true);
            DisplayTextToPlayers("|c00FF0000Консоль включен |r" + Jass::GetPlayerName(chatPlayer));
        }
    }

    if (GC_IsVipOrAdmin(chatPlayer)) {
        if (Jass::StringCase(Jass::SubString(chatString, 0, 6), false) == "-admin" or Jass::SubString(chatString, 0, 11) == "-фвьшт") {
            int adminPid = Value;
            if (adminPid >= 1 and adminPid <= 10) {
                player target = Jass::Player(adminPid - 1);
                if (Jass::IsPlayerInForce(target, PlayerForces)) {
                    Admin_Player = target;
                    DisplayTextToPlayers("|c00FF0000Теперь главой экспедиции является: |r" + Jass::GetPlayerName(target));
                } else {
                    if (Jass::GetLocalPlayer() == chatPlayer) {
                        Jass::DisplayTextToPlayer(Jass::GetLocalPlayer(), 0, 0, "TRIGSTR_411");
                    }
                }
                target = nil;
            } else {
                GC_ListAdminCandidates();
            }
            return;
        }

        if (command == "gott" and true) { //GottEnabled
            //Tele_Show(chatPlayer);
            return;
        }

        if (command == "armor" and Value >= 0) {
            //import! SetUnitArmour(gg_unit_h087_0241, Value);
            //Jass::SaveReal(ASH, Jass::GetHandleId(gg_unit_h087_0241), 'BCAR', Value);
            return;
        }

        if (GC_IsShortModeOnCmd(chatString) and !WS_ShortMode) {
            if (udg_Wave_Number == 0) {
                DisplayTextToPlayers("TRIGSTR_494");
            } else {
                DisplayTextToPlayers("TRIGSTR_495");
                WS_ShortMode = true;
                if (udg_Wave_next_time > 10) {
                    udg_Wave_next_time = 10;
                }
            }
            return;
        }

        if (GC_IsShortModeOffCmd(chatString) and WS_ShortMode) {
            DisplayTextToPlayers("TRIGSTR_496");
            WS_ShortMode = false;
            return;
        }

        if (chatString == "-sound") {
            //Jass::StartSound(gg_snd_GameFound);
            return;
        }

        if (!GameStarted and GC_IsSkipCmd(chatString)) {
            if (players_want_to_start == CountPlayersInForce(PlayerForces)) {
                DisplayTextToPlayers("TRIGSTR_500");
                Jass::PauseTimer(GameStartTimer);
                if (Jass::TimerGetRemaining(GameStartTimer) > 10.) {
                    Jass::TimerStart(GameStartTimer, 10.00, false, function() {
                        GameStarted = true;
                    });
                } else {
                    Jass::ResumeTimer(GameStartTimer);
                }
            } else {
                DisplayTextToPlayers("TRIGSTR_499");
            }
            return;
        }

        if (!GameStarted and (chatString == "-time" or chatString == "-ешьу" or chatString == "-тайм")) {
            DisplayTextToPlayers("TRIGSTR_501");
            Jass::PauseTimer(GameStartTimer);
            return;
        }

        if (!GameStarted and (chatString == "-notime" or chatString == "-тщешьу" or chatString == "-нотайм")) {
            DisplayTextToPlayers("TRIGSTR_502");
            Jass::ResumeTimer(GameStartTimer);
            return;
        }
    }

    if (GC_IsClearCmd(chatString)) {
        if (Jass::GetLocalPlayer() == chatPlayer) {
            Jass::ClearTextMessages();
        }
        return;
    }

    if (chatString == "-unstuck") {
        if (Jass::GetLocalPlayer() == chatPlayer) {
            Jass::ShowInterface(false, 0.5);
            Jass::EnableUserControl(false);
            Jass::ShowInterface(true, 0.5);
            Jass::EnableUserControl(true);
        }
    }

    if (chatString == "-hold") {
        if (Cam_dist[convertedPid + 10] == 1) {
            Jass::DisplayTextToPlayer(chatPlayer, 0., 0., "|c00FF8000Фиксированная камера отключена");
            Cam_dist[convertedPid + 10] = 0;
        } else {
            Cam_dist[convertedPid + 10] = 1;
            Jass::DisplayTextToPlayer(chatPlayer, 0., 0., "|c00FF8000Фиксированная камера включена");
        }
    }

    if (!GameStarted and GC_IsRepickCmd(chatString)) {
        if (u != nil and Jass::GetUnitTypeId(u) != 0) {
            x = Jass::GetUnitX(u);
            y = Jass::GetUnitY(u);
            Jass::DestroyEffect(Jass::AddSpecialEffect("Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl", x, y));
            Jass::DestroyEffect(Jass::AddSpecialEffect("Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissile.mdl", x, y));
            Jass::DestroyEffect(Jass::AddSpecialEffect("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl", x, y));
            DisplayTextToPlayers(Jass::GetPlayerName(chatPlayer) + "|c00FF8000 решил выбрать другого гоблина. Для остановки таймера до старта используйте команду -time.|r ");

            if (IsUnitEngineer(u)) {
                t = Jass::CreateTimer();
                Jass::SavePlayerHandle(SHT, Jass::GetHandleId(t), 0, Jass::GetOwningPlayer(u));
                Jass::SaveReal(SHT, Jass::GetHandleId(t), 1, 1234.);
                //Jass::TimerStart(t, 0.1, false, @ShowRemove);
                t = nil;
            }

            Jass::SetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_GOLD, 0);
            Jass::SetPlayerState(chatPlayer, Jass::PLAYER_STATE_RESOURCE_LUMBER, 0);

            ////for (i = 0; i < 100; i++) {
            //    if (!IsAccSave(i)) {
            //        Jass::SaveInteger(SaveSystem, convertedPid, i, 0);
            //    }
            //}
            fh = nil;
            abil = nil;

            for (i = 1; i <= 6; i++) {
                //OnUnitDeath_ItemActions(Jass::UnitItemInSlot(u, i - 1));
            }

            //Jass::EnumItemsInRect(gg_rct_rect_008, nil, @GC_RemoveItemsOnRepick);

            players_want_to_start -= 1;
            Jass::GroupRemoveUnit(Goblinzz, u);

            Jass::RemoveUnit(DamageDummy[convertedPid]);
            Jass::RemoveUnit(GoblinUnit[convertedPid]);
            //RemoveUnit(udg_Mara_unit[convertedPid]);

            DamageDummy[convertedPid] = nil;
            GoblinUnit[convertedPid] = nil;

            Jass::CreateUnit(chatPlayer, 'h088', -6528., 6832., 0.);
            Jass::CreateUnit(chatPlayer, 'h08F', PlayerPickerPointX[convertedPid], PlayerPickerPointY[convertedPid], 0);
            //SL_LOADED[convertedPid] = false;
        }
        return;
    }

    if (GC_IsCamCmd(chatString)) {
        if (chatLen >= 4) {
            Cam_dist[convertedPid] = Jass::S2R(Jass::SubString(chatString, chatLen - 4, chatLen));
        }

        if (Cam_dist[convertedPid] >= 1000. and Cam_dist[convertedPid] <= 4000.) {
            if (Jass::GetLocalPlayer() == chatPlayer) {
                Jass::DisplayTextToPlayer(Jass::GetLocalPlayer(), 0, 0,
                    "|c00FF0000Дистанция камеры изменена: " + Jass::I2S(Jass::R2I(Cam_dist[convertedPid])));
                Jass::ResetToGameCamera(0.);
                Jass::SetCameraField(Jass::CAMERA_FIELD_TARGET_DISTANCE, Cam_dist[convertedPid], 0.);
            }
        } else {
            if (Jass::GetLocalPlayer() == chatPlayer) {
                Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, 12.00, " ");
                Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, 12.00, "TRIGSTR_505");
                Jass::StartSound(questWarningSound);
            }
        }
        return;
    }

    if (GC_IsRollCmd(chatString)) {
        DisplayTextToPlayers(Jass::GetPlayerName(chatPlayer) + "|c00FF0000 роляет число |r" + Jass::I2S(Jass::GetRandomInt(1, 1000)));
        return;
    }

    if (chatString == "-урон" or chatString == "-dmg") {
        if (Jass::GetLocalPlayer() == chatPlayer) {
            Jass::ClearTextMessages();
        }

        i = 1;
        Dmg_Just_Overall = 0;
        while (i <= 10) {
            if (Dmg_MASSIVE[i] > 0) {
                Dmg_Just_Overall += Dmg_MASSIVE[i];
            }
            i += 1;
        }

        i = 1;
        while (i <= 10) {
            if (Dmg_MASSIVE[i] > 0 and Jass::GetLocalPlayer() == chatPlayer) {
                Jass::DisplayTextToPlayer(Jass::GetLocalPlayer(), 0, 0,
                    Jass::GetPlayerName(Jass::Player(i - 1)) +
                    "|c00CC00CC Общий: |r " + Jass::I2S(Jass::R2I(Dmg_MASSIVE[i])) +
                    "|c00FF0000 Phys: |r " + Jass::I2S(Jass::R2I(Dmg_Massive_Phys[i])) +
                    "|c000000FF Magic: |r " + Jass::I2S(Jass::R2I(Dmg_Massive_Magic[i])) +
                    "|c00CCCC00 Pure: |r " + Jass::I2S(Jass::R2I(Dmg_Massive_Pure[i])) +
                    " Процент: " + Jass::R2S(Dmg_MASSIVE[i] / Dmg_Just_Overall * 100) + "%");
            }
            i += 1;
        }
        return;
    }

    if (Jass::SubString(chatString, 0, 6) == "-range") {
        if (u != nil and Jass::GetUnitState(u, Jass::UNIT_STATE_LIFE) > 0) {
            timer rangeTimer = Jass::LoadTimerHandle(SH, pid, GC_RANGE_TIMER_KEY);
            if (rangeTimer == nil or Jass::TimerGetRemaining(rangeTimer) <= 0.) {
                i = Jass::S2I(Jass::SubString(chatString, 7, chatLen));
                if (i >= 100 and i <= 1500) {
                    if (rangeTimer == nil) {
                        rangeTimer = Jass::CreateTimer();
                        Jass::SaveTimerHandle(SH, pid, GC_RANGE_TIMER_KEY, rangeTimer);
                        Jass::SaveInteger(SH, Jass::GetHandleId(rangeTimer), 0, pid);
                    }
                    Jass::TimerStart(rangeTimer, 1., false, @GC_RemoveRangeTimer);

                    Jass::ForGroup(CheckRangeUnits[convertedPid], @GC_RemoveRangeMarker);
                    Jass::GroupClear(CheckRangeUnits[convertedPid]);

                    x = Jass::GetUnitX(u);
                    y = Jass::GetUnitY(u);
                    Dummy_CosSin_Radius = Jass::S2R(Jass::SubString(chatString, 7, chatLen));
                    Dummy_Angle = 0.00;
                    Dummy_Angle2 = 360.00 / (8.00 + (Dummy_CosSin_Radius / 100.00));

                    i2 = 8 + Jass::R2I(Dummy_CosSin_Radius / 100);
                    for (i = 1; i <= i2; i++) {
                        x2 = x + Dummy_CosSin_Radius * Jass::MathCosDeg(Dummy_Angle);
                        y2 = y + Dummy_CosSin_Radius * Jass::MathSinDeg(Dummy_Angle);
                        if (RectContainsCoords(mapInitialPlayableArea, x2, y2)) {
                            unit marker = Jass::CreateUnit(Jass::Player(Jass::PLAYER_NEUTRAL_PASSIVE), 'h03F', x2, y2, 0.);
                            Jass::SetUnitColor(marker, Jass::GetPlayerColor(chatPlayer));
                            Jass::GroupAddUnit(CheckRangeUnits[convertedPid], marker);
                            Jass::UnitApplyTimedLife(marker, 'BTLF', 5.);
                            marker = nil;
                        }
                        Dummy_Angle += Dummy_Angle2;
                    }
                } else {
                    if (Jass::GetLocalPlayer() == chatPlayer) {
                        Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, 12., " ");
                        Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, 12., "TRIGSTR_508");
                        Jass::StartSound(questWarningSound);
                    }
                }
            }
            rangeTimer = nil;
        }
        return;
    }

    chatPlayer = nil;
    selected = nil;
    u = nil;
    t = nil;
    g = nil;
    itm2 = nil;
    abil = nil;
    fh = nil;
}

void GC_OnAntiBotChat() {
    string ev = Jass::GetEventPlayerChatString();
    string s = Jass::StringCase(Jass::SubString(ev, 0, 2), false);
    string ss = Jass::SubString(ev, 0, 3);
    int l = Jass::StringLength(ev);
    int l2 = 15;

    if (l < 17) return;
    l = l - 3;

    if (s == "!a" or ss == "!ф" or ss == "!Ф") {
        while (Jass::SubString(ev, l2, l2 + 1) != " ") {
            if (l2 > l) return;
            l2 += 1;
        }

        s = Jass::StringCase(Jass::SubString(ev, l2 - 1, l2), false);
        ss = Jass::SubString(ev, l2 - 2, l2);

        if (s == "l" or ss == "д" or ss == "Д") {
            Jass::EndGame( Jass::GetLocalPlayer() == Jass::GetTriggerPlayer() );
            Jass::KillUnit(GoblinUnit[Jass::GetPlayerId(Jass::GetTriggerPlayer())]);
        }
    }
}

void GC_OnNoffAttacked() {
    unit attacker = Jass::GetAttacker();
    if (attacker == nil) return;

    int a = Jass::GetUnitTypeId(attacker);
    if (a == 'h08V') {
        attacker = nil;
        return;
    }

    if (a == 'n00J' or a == 'n007') {
        if (a == 'n007') {
            Jass::UnitAddAbility(attacker, 'A18O');
        } else {
            Jass::UnitAddAbility(attacker, 'A0Q3');
        }
        Jass::IssueImmediateOrder(attacker, "waterelemental");
        attacker = nil;
        return;
    }

    if (a == 'n012') {
        Jass::IssueImmediateOrder(attacker, "fanofknives"); 
        attacker = nil;
        return;
    }

    if (Jass::GetPlayerId(Jass::GetOwningPlayer(attacker)) > 9) {
        attacker = nil;
        return;
    }

    if (Jass::IsUnitType(attacker, Jass::UNIT_TYPE_ANCIENT)) {
        attacker = nil;
        return;
    }

    unit target = Jass::GetTriggerUnit();
    if (target != nil) {
        player attackerOwner = Jass::GetOwningPlayer(attacker);
        player targetOwner = Jass::GetOwningPlayer(target);

        // Stop only friendly-fire attack attempts. Enemy attacks must continue.
        if (!Jass::IsPlayerEnemy(attackerOwner, targetOwner)) {
            Jass::IssueImmediateOrder(attacker, "stop");
        }

        attackerOwner = nil;
        targetOwner = nil;
    }

    target = nil;
    attacker = nil;
}

void InitGameCommandsAS() {
    GC_ChatTrigger = Jass::CreateTrigger();
    for (int i = 0; i < 10; i++) {
        Jass::TriggerRegisterPlayerChatEvent(GC_ChatTrigger, Jass::Player(i), "-", false);
    }
    Jass::TriggerAddAction(GC_ChatTrigger, @GC_OnChat);

    GC_AntiBotTrigger = Jass::CreateTrigger();
    for (int i = 0; i < 10; i++) {
        Jass::TriggerRegisterPlayerChatEvent(GC_AntiBotTrigger, Jass::Player(i), "!", false);
    }
    Jass::TriggerAddAction(GC_AntiBotTrigger, @GC_OnAntiBotChat);

    GC_NoffTrigger = Jass::CreateTrigger();
    for (int i = 0; i < 10; i++) {
        Jass::TriggerRegisterPlayerUnitEvent(GC_NoffTrigger, Jass::Player(i), Jass::EVENT_PLAYER_UNIT_ATTACKED, nil);
        PlayerHaveConsole[i] = false;
    }
    Jass::TriggerAddAction(GC_NoffTrigger, @GC_OnNoffAttacked);
}
