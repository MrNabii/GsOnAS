//import General.as
//import Systems\\AbilitySystem.as
//import Systems\\OnSpawnAction.as
//import Systems\\SaveSystem.as
//import Systems\\StartFlow.as
//import Systems\\DamageSystem.as
//import Systems\\Cheats.as
//import Systems\\GameCommands.as
//import Systems\\LeaverOutOfList.as
//import InGameTexts.as
//import Systems\\DeathSystem.as
//import Systems\\CraftingSys.as
//import Systems\\CraftingSystemFrame.as
//import Systems\\UnitStatsFrame.as
//import Systems\\GlibaPlacePoints.as
//import Systems\\WavesMobs.as
//import Systems\\MainMultiboard.as

rect mapInitialPlayableArea = nil;
array<int> g_Gliba(10);
hashtable UnitHandleHT = Jass::InitHashtable();  // хранит unit handle по handleId
player Admin_Player = nil;
timer GameStartTimer = nil;

#include "General.as"
#include "Systems\\AbilitySystem.as"
#include "Systems\\OnSpawnAction.as"
#include "Systems\\SaveSystem.as"
#include "Systems\\StartFlow.as"
#include "Systems\\DamageSystem.as"
#include "Systems\\Cheats.as"
#include "Systems\\GameCommands.as"
#include "Systems\\LeaverOutOfList.as"
#include "InGameTexts.as"
#include "Systems\\DeathSystem.as"
#include "Systems\\CraftingSys.as"
#include "Systems\\CraftingSystemFrame.as"
#include "Systems\\UnitStatsFrame.as"
#include "Systems\\GlibaPlacePoints.as"
#include "Systems\\PortalPath.as"
#include "Systems\\WavesMobs.as"
#include "Systems\\MainMultiboard.as"

bool GameStarted = false;
array<int> MapVersion(100);
bool TestDebugMode = true;
force PlayerForces = nil;
force EnemiesForce = nil;
int ALLIANCE_ALLIED = 2;
sound questWarningSound = Jass::CreateSoundFromLabel("Warning", false, false, false, 10000, 10000);
sound questHintSound = Jass::CreateSoundFromLabel("Hint", false, false, false, 10000, 10000);

int CAMERA_MARGIN_LEFT   = 0;
int CAMERA_MARGIN_RIGHT  = 1;
int CAMERA_MARGIN_TOP    = 2;
int CAMERA_MARGIN_BOTTOM = 3;


float getMinRectX() {
    return - 6741.1;
}

float getMaxRectX() {
    return 14885.4;
}

float getMinRectY() {
    return - 6854.7;
}

float getMaxRectY() {
    return 6817.4;
}


void SetPlayerAllianceStateAlly(player sourcePlayer, player otherPlayer, bool flag){
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_PASSIVE,       flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_HELP_REQUEST,  flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_HELP_RESPONSE, flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_XP,     flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_SPELLS, flag);
}

void SetPlayerAllianceState(player sourcePlayer, player otherPlayer, int allianceState ){
    if (sourcePlayer == otherPlayer) 
        return;

    if (allianceState == ALLIANCE_ALLIED){
        SetPlayerAllianceStateAlly(        sourcePlayer, otherPlayer, true  );
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_VISION, false);
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_CONTROL, false);
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_ADVANCED_CONTROL, false);
    }
}

array<float> udg_UpTraderSpawnLocX(100);
array<float> udg_UpTraderSpawnLocY(100);
array<float> QuestSetPointX(100);   
array<float> QuestSetPointY(100);
array<float> udg_Quest_rectX(100);
array<float> udg_Quest_rectY(100);
array<rect> udg_Quest_rect(100);
array<rect> udg_MushroomsRects(100);
array<float> udg_SplashX(100);
array<float> udg_SplashY(100);
int  QUESTTYPE_OPT_DISCOVERED = 2;
int TainiksCounter = 0;
int GlibasCounter = 0;
int g_ready_players = 0;
void InitArrayValues() {    
    udg_UpTraderSpawnLocX[1] = -6704.;
    udg_UpTraderSpawnLocY[1] = -5136.;
    
    udg_UpTraderSpawnLocX[2] = -3760.;
    udg_UpTraderSpawnLocY[2] = 944.;
    
    udg_UpTraderSpawnLocX[3] = -3696.;
    udg_UpTraderSpawnLocY[3] = 48.;
    
    udg_UpTraderSpawnLocX[4] = 6896.;
    udg_UpTraderSpawnLocY[4] = 2608.;
    
    udg_UpTraderSpawnLocX[5] = 5104.;
    udg_UpTraderSpawnLocY[5] = 2736.;
    
    udg_UpTraderSpawnLocX[6] = 4272.;
    udg_UpTraderSpawnLocY[6] = 3280.;
    
    udg_UpTraderSpawnLocX[7] = 4208.;
    udg_UpTraderSpawnLocY[7] = 4944.;
    
    udg_UpTraderSpawnLocX[8] = 1840.;
    udg_UpTraderSpawnLocY[8] = 6416.;
    
    udg_UpTraderSpawnLocX[9] = 112.;
    udg_UpTraderSpawnLocY[9] = 6672.;
    
    udg_UpTraderSpawnLocX[10] = -1712.;
    udg_UpTraderSpawnLocY[10] = 6640.;
    
    udg_UpTraderSpawnLocX[11] = -2576.;
    udg_UpTraderSpawnLocY[11] = 6384.;
    
    udg_UpTraderSpawnLocX[12] = -3760.;
    udg_UpTraderSpawnLocY[12] = 6960.;
    
    udg_UpTraderSpawnLocX[13] = -5200.;
    udg_UpTraderSpawnLocY[13] = 6832.;
    
    udg_UpTraderSpawnLocX[14] = -5168.;
    udg_UpTraderSpawnLocY[14] = 4176.;
    
    udg_UpTraderSpawnLocX[15] = -4112.;
    udg_UpTraderSpawnLocY[15] = 2160.;
    
    udg_UpTraderSpawnLocX[16] = -4176.;
    udg_UpTraderSpawnLocY[16] = -1584.;
    
    udg_UpTraderSpawnLocX[17] = -3984.;
    udg_UpTraderSpawnLocY[17] = -4080.;
    
    udg_UpTraderSpawnLocX[18] = -4144.;
    udg_UpTraderSpawnLocY[18] = -5616.;
    
    udg_UpTraderSpawnLocX[19] = -6352.;
    udg_UpTraderSpawnLocY[19] = -6992.;
    
    udg_UpTraderSpawnLocX[20] = -2704.;
    udg_UpTraderSpawnLocY[20] = -7120.;
    
    udg_UpTraderSpawnLocX[21] = -3152.;
    udg_UpTraderSpawnLocY[21] = -5936.;
    
    udg_UpTraderSpawnLocX[22] = -1168.;
    udg_UpTraderSpawnLocY[22] = -7056.;
    
    udg_UpTraderSpawnLocX[23] = -1520.;
    udg_UpTraderSpawnLocY[23] = -6224.;
    
    udg_UpTraderSpawnLocX[24] = -1232.;
    udg_UpTraderSpawnLocY[24] = -3344.;
    
    udg_UpTraderSpawnLocX[25] = -2384.;
    udg_UpTraderSpawnLocY[25] = -2800.;
    
    udg_UpTraderSpawnLocX[26] = -560.;
    udg_UpTraderSpawnLocY[26] = -976.;
    
    udg_UpTraderSpawnLocX[27] = -1232.;
    udg_UpTraderSpawnLocY[27] = 16.;
    
    udg_UpTraderSpawnLocX[28] = -1488.;
    udg_UpTraderSpawnLocY[28] = 2736.;
    
    udg_UpTraderSpawnLocX[29] = -176.;
    udg_UpTraderSpawnLocY[29] = 1520.;
    
    udg_UpTraderSpawnLocX[30] = 752.;
    udg_UpTraderSpawnLocY[30] = 3376.;
    
    udg_UpTraderSpawnLocX[31] = 816.;
    udg_UpTraderSpawnLocY[31] = 4432.;
    
    udg_UpTraderSpawnLocX[32] = 1584.;
    udg_UpTraderSpawnLocY[32] = 5552.;
    
    udg_UpTraderSpawnLocX[33] = 2128.;
    udg_UpTraderSpawnLocY[33] = 2480.;
    
    udg_UpTraderSpawnLocX[34] = 1264.;
    udg_UpTraderSpawnLocY[34] = 848.;
    
    udg_UpTraderSpawnLocX[35] = 2224.;
    udg_UpTraderSpawnLocY[35] = 464.;
    
    udg_UpTraderSpawnLocX[36] = 3632.;
    udg_UpTraderSpawnLocY[36] = 368.;
    
    udg_UpTraderSpawnLocX[37] = 2864.;
    udg_UpTraderSpawnLocY[37] = 2320.;
    
    udg_UpTraderSpawnLocX[38] = 5072.;
    udg_UpTraderSpawnLocY[38] = 1520.;
    
    udg_UpTraderSpawnLocX[39] = 6064.;
    udg_UpTraderSpawnLocY[39] = 2192.;
    
    udg_UpTraderSpawnLocX[40] = 6960.;
    udg_UpTraderSpawnLocY[40] = 688.;
    
    udg_UpTraderSpawnLocX[41] = 5776.;
    udg_UpTraderSpawnLocY[41] = -1456.;
    
    udg_UpTraderSpawnLocX[42] = 7120.;
    udg_UpTraderSpawnLocY[42] = -1840.;
    
    udg_UpTraderSpawnLocX[43] = 4976.;
    udg_UpTraderSpawnLocY[43] = -2384.;
    
    udg_UpTraderSpawnLocX[44] = 3440.;
    udg_UpTraderSpawnLocY[44] = -2000.;
    
    udg_UpTraderSpawnLocX[45] = 3568.;
    udg_UpTraderSpawnLocY[45] = -1168.;
    
    udg_UpTraderSpawnLocX[46] = 1744.;
    udg_UpTraderSpawnLocY[46] = -1840.;
    
    udg_UpTraderSpawnLocX[47] = 528.;
    udg_UpTraderSpawnLocY[47] = -1424.;
    
    udg_UpTraderSpawnLocX[48] = 16.;
    udg_UpTraderSpawnLocY[48] = -2512.;
    
    udg_UpTraderSpawnLocX[49] = -304.;
    udg_UpTraderSpawnLocY[49] = -3888.;
    
    udg_UpTraderSpawnLocX[50] = 2320.;
    udg_UpTraderSpawnLocY[50] = -4048.;
    
    udg_UpTraderSpawnLocX[51] = 2896.;
    udg_UpTraderSpawnLocY[51] = -6096.;
    
    udg_UpTraderSpawnLocX[52] = 5040.;
    udg_UpTraderSpawnLocY[52] = -6800.;
    
    udg_UpTraderSpawnLocX[53] = 6096.;
    udg_UpTraderSpawnLocY[53] = -5392.;
    
    udg_UpTraderSpawnLocX[54] = -6992.;
    udg_UpTraderSpawnLocY[54] = -3888.;
    
    udg_UpTraderSpawnLocX[55] = 7632.;
    udg_UpTraderSpawnLocY[55] = -4368.;
    
    udg_UpTraderSpawnLocX[56] = 7792.;
    udg_UpTraderSpawnLocY[56] = -6096.;
    
    udg_UpTraderSpawnLocX[57] = 7408.;
    udg_UpTraderSpawnLocY[57] = -6928.;
    
    udg_UpTraderSpawnLocX[58] = 4816.;
    udg_UpTraderSpawnLocY[58] = -4496.;
    
    udg_UpTraderSpawnLocX[59] = -1648.;
    udg_UpTraderSpawnLocY[59] = -5040.;
    
    udg_UpTraderSpawnLocX[60] = -2512.;
    udg_UpTraderSpawnLocY[60] = -4816.;
    
    udg_UpTraderSpawnLocX[61] = -6864.;
    udg_UpTraderSpawnLocY[61] = -2096.;
    
    udg_UpTraderSpawnLocX[62] = -5328.;
    udg_UpTraderSpawnLocY[62] = 336.;
    
    udg_UpTraderSpawnLocX[63] = 5808.;
    udg_UpTraderSpawnLocY[63] = 6288.;
    
    udg_UpTraderSpawnLocX[64] = 5520.;
    udg_UpTraderSpawnLocY[64] = 5648.;
    
    udg_UpTraderSpawnLocX[65] = 5744.;
    udg_UpTraderSpawnLocY[65] = 4272.;
    
    
    
    QuestSetPointX[1] = -6208.;
    QuestSetPointY[1] = 1760.;
    
    QuestSetPointX[2] = -2432.;
    QuestSetPointY[2] = 2848.;
    
    QuestSetPointX[3] = -96.;
    QuestSetPointY[3] = 6272.;
    
    QuestSetPointX[4] = 5024.;
    QuestSetPointY[4] = 6080.;
    
    QuestSetPointX[5] = 6016.;
    QuestSetPointY[5] = 768.;
    
    QuestSetPointX[6] = 1312.;
    QuestSetPointY[6] = 608.;
    
    QuestSetPointX[7] = 576.;
    QuestSetPointY[7] = 3232.;
    
    QuestSetPointX[8] = -4768.;
    QuestSetPointY[8] = 832.;
    
    QuestSetPointX[9] = -3232.;
    QuestSetPointY[9] = 736.;
    
    QuestSetPointX[10] = -928.;
    QuestSetPointY[10] = -1824.;
    
    QuestSetPointX[11] = -2144.;
    QuestSetPointY[11] = -2688.;
    
    QuestSetPointX[12] = -4320.;
    QuestSetPointY[12] = -2496.;
    
    QuestSetPointX[13] = -6752.;
    QuestSetPointY[13] = -3680.;
    
    QuestSetPointX[14] = -3456.;
    QuestSetPointY[14] = -6080.;
    
    QuestSetPointX[15] = -3904.;
    QuestSetPointY[15] = -4288.;
    
    QuestSetPointX[16] = -1792.;
    QuestSetPointY[16] = -6208.;
    
    QuestSetPointX[17] = 672.;
    QuestSetPointY[17] = -1664.;
    
    QuestSetPointX[18] = 6528.;
    QuestSetPointY[18] = -2688.;
    
    QuestSetPointX[19] = 5344.;
    QuestSetPointY[19] = -6880.;
    
    QuestSetPointX[20] = 5920.;
    QuestSetPointY[20] = 4544.;
    
    udg_Quest_rectX[1] = -5120.;
    udg_Quest_rectY[1] = -1728.;
    
    udg_Quest_rectX[2] = 335.;
    udg_Quest_rectY[2] = -1600.;
    
    udg_Quest_rectX[3] = 1600.;
    udg_Quest_rectY[3] = -1728.;
    
    udg_Quest_rectX[4] = 2304.;
    udg_Quest_rectY[4] = -1408.;
    
    udg_Quest_rectX[5] = 5824.;
    udg_Quest_rectY[5] = 768.;
    
    udg_Quest_rectX[6] = 6496.;
    udg_Quest_rectY[6] = 2208.;
    
    udg_Quest_rectX[7] = 5440.;
    udg_Quest_rectY[7] = 4704.;
    
    udg_Quest_rectX[8] = 4896.;
    udg_Quest_rectY[8] = 4288.;
    
    udg_Quest_rectX[9] = 1344.;
    udg_Quest_rectY[9] = 352.;
    
    udg_Quest_rectX[10] = 2144.;
    udg_Quest_rectY[10] = 4960.;
    
    udg_Quest_rectX[11] = 1536.;
    udg_Quest_rectY[11] = 6400.;
    
    udg_Quest_rectX[12] = 224.;
    udg_Quest_rectY[12] = 3200.;
    
    udg_Quest_rectX[13] = -992.;
    udg_Quest_rectY[13] = 5248.;
    
    udg_Quest_rectX[14] = -2368.;
    udg_Quest_rectY[14] = 6080.;
    
    udg_Quest_rectX[15] = -3200.;
    udg_Quest_rectY[15] = 6784.;
    
    udg_Quest_rectX[16] = -5120.;
    udg_Quest_rectY[16] = 6208.;
    
    udg_Quest_rectX[17] = -4832.;
    udg_Quest_rectY[17] = 2688.;
    
    udg_Quest_rectX[18] = -5728.;
    udg_Quest_rectY[18] = 2016.;
    
    udg_Quest_rectX[19] = -4512.;
    udg_Quest_rectY[19] = 736.;
    
    udg_Quest_rectX[20] = -1248.;
    udg_Quest_rectY[20] = 2688.;
    
    udg_Quest_rectX[21] = -6496.;
    udg_Quest_rectY[21] = -4736.;
    
    udg_Quest_rectX[22] = -6336.;
    udg_Quest_rectY[22] = -6848.;
    
    udg_Quest_rectX[23] = -3776.;
    udg_Quest_rectY[23] = -5952.;
    
    udg_Quest_rectX[24] = -3648.;
    udg_Quest_rectY[24] = -6624.;
    
    udg_Quest_rectX[25] = -1568.;
    udg_Quest_rectY[25] = -6464.;
    
    udg_Quest_rectX[26] = -2112.;
    udg_Quest_rectY[26] = -6080.;
    
    udg_Quest_rectX[27] = -3616.;
    udg_Quest_rectY[27] = -4128.;
    
    udg_Quest_rectX[28] = -3040.;
    udg_Quest_rectY[28] = -4928.;
    
    udg_Quest_rectX[29] = -1568.;
    udg_Quest_rectY[29] = -4608.;
    
    udg_Quest_rectX[30] = -1312.;
    udg_Quest_rectY[30] = -7040.;
    
    udg_Quest_rectX[31] = -128.;
    udg_Quest_rectY[31] = -7008.;
    
    udg_Quest_rectX[32] = 64.;
    udg_Quest_rectY[32] = -4256.;
    
    udg_Quest_rectX[33] = 1056.;
    udg_Quest_rectY[33] = -3392.;
    
    udg_Quest_rectX[34] = 1664.;
    udg_Quest_rectY[34] = -5888.;
    
    udg_Quest_rectX[35] = 2944.;
    udg_Quest_rectY[35] = -6400.;
    
    udg_Quest_rectX[36] = 4576.;
    udg_Quest_rectY[36] = -6112.;
    
    udg_Quest_rectX[37] = 5600.;
    udg_Quest_rectY[37] = -6720.;
    
    udg_Quest_rectX[38] = 5344.;
    udg_Quest_rectY[38] = -5216.;
    
    udg_Quest_rectX[39] = 3264.;
    udg_Quest_rectY[39] = -3680.;
    
    udg_Quest_rectX[40] = 6720.;
    udg_Quest_rectY[40] = -5856.;
    
    udg_Quest_rectX[41] = 6720.;
    udg_Quest_rectY[41] = -3904.;
    
    udg_Quest_rectX[42] = 4704.;
    udg_Quest_rectY[42] = 5920.;
    
    udg_Quest_rectX[43] = 7104.;
    udg_Quest_rectY[43] = -4576.;
    
    udg_Quest_rectX[44] = 7104.;
    udg_Quest_rectY[44] = -6912.;
    
    udg_Quest_rectX[45] = 7744.;
    udg_Quest_rectY[45] = -5664.;
    
    udg_Quest_rectX[46] = 6944.;
    udg_Quest_rectY[46] = 4384.;
    
    udg_Quest_rectX[47] = 6944.;
    udg_Quest_rectY[47] = 4384.;
    
    udg_Quest_rectX[48] = 9616.;
    udg_Quest_rectY[48] = 3990.;
    
    udg_Quest_rectX[49] = 13900.;
    udg_Quest_rectY[49] = 684.;
    
    udg_Quest_rectX[50] = 14577.;
    udg_Quest_rectY[50] = 631.;
    
    udg_Quest_rectX[51] = 11411.;
    udg_Quest_rectY[51] = 2097.;
    
    udg_Quest_rectX[52] = 10051.;
    udg_Quest_rectY[52] = -2398.;
    
    udg_Quest_rectX[53] = 11081.;
    udg_Quest_rectY[53] = -146.;
    
    udg_Quest_rectX[54] = 8526.;
    udg_Quest_rectY[54] = -4114.;
    
    udg_Quest_rectX[55] = 10585.;
    udg_Quest_rectY[55] = -5552.;
    
    udg_Quest_rectX[56] = 9271.;
    udg_Quest_rectY[56] = -5891.;
    
    udg_Quest_rectX[57] = 7017.;
    udg_Quest_rectY[57] = -1407.;
    
    udg_Quest_rectX[58] = 10203.;
    udg_Quest_rectY[58] = 709.;
    
    udg_Quest_rectX[59] = 12858.;
    udg_Quest_rectY[59] = -2536.;
    
    
    udg_MushroomsRects[1] = Jass::Rect(1280.0, 5856.0, 1632.0, 6208.0);
	udg_MushroomsRects[2] = Jass::Rect(6240.0, 5888.0, 6560.0, 6144.0);
	udg_MushroomsRects[3] = Jass::Rect(3808.0, -1696.0, 4064.0, -1472.0);
	udg_MushroomsRects[4] = Jass::Rect(-6560.0, 864.0, -6272.0, 1088.0);
	udg_MushroomsRects[5] = Jass::Rect(512.0, 224.0, 896.0, 800.0);
	udg_MushroomsRects[6] = Jass::Rect(-2272.0, -2528.0, -1920.0, -2272.0);
	udg_MushroomsRects[7] = Jass::Rect(5952.0, -4096.0, 6208.0, -3872.0);
	udg_MushroomsRects[8] = Jass::Rect(-5120.0, -5824.0, -4736.0, -5408.0);
	udg_MushroomsRects[9] = Jass::Rect(-3648.0, -7360.0, -3392.0, -7136.0);
    udg_MushroomsRects[10] = Jass::Rect(10976, -4032, 11904, -3488);
    udg_MushroomsRects[11] = Jass::Rect(10752, -2368, 11680, -1984);
    udg_MushroomsRects[12] = Jass::Rect(8032, 64, 8672, 928);
    
    udg_SplashX[1] = -6080.;
    udg_SplashY[1] = 3488.;
    
    udg_SplashX[2] = -6560.;
    udg_SplashY[2] = 3456.;
    
    udg_SplashX[3] = 5792.;
    udg_SplashY[3] = -1728.;
    
    udg_SplashX[4] = 480.;
    udg_SplashY[4] = 2784.;
    
    udg_SplashX[5] = 7040.;
    udg_SplashY[5] = 1600.;
    
    udg_SplashX[6] = 7744.;
    udg_SplashY[6] = -5280.;
}

quest CreateQuestBJ(int questType, string title, string description, string iconPath) {
    quest Quest;

    Quest = Jass::CreateQuest();
    Jass::QuestSetTitle(Quest, title);
    Jass::QuestSetDescription(Quest, description);
    Jass::QuestSetIconPath(Quest, iconPath);
    Jass::QuestSetRequired(Quest, false);
    Jass::QuestSetDiscovered(Quest, true);
    Jass::QuestSetCompleted(Quest, false);
    return Quest;
}

bool IsPlaceableAtById( float x, float y )
{
    return Jass::IsUnitPlaceableAtById( 'h008', Jass::Player(0), x, y, 0, 0, 0, 0, true, false, false, false, false, false );
}

void SpawnInitResources() {
    // --------------------------------------------------------- Глыбы
    g_Gliba[0] = 'h008';
    g_Gliba[1] = 'h009';
    g_Gliba[2] = 'h00A';
    g_Gliba[3] = 'h00B';
    g_Gliba[4] = 'h00C';
    g_Gliba[5] = 'h007';
    float x = 0;
    float y = 0;

    InitGlibaPlacePoints();
    int glibaPointCount = GetGlibaPlacePointCount();
    int random;

    TainiksCounter = 0;
    for (int i = 0; i < 128; i++) {
        if (glibaPointCount > 0) {
            random = Jass::GetRandomInt(0, glibaPointCount - 1);
            x = GetRandomGlibaPlaceX(random);
            y = GetRandomGlibaPlaceY(random);
        } else {
            x = Jass::GetRandomReal(getMinRectX(), getMaxRectX());
            y = Jass::GetRandomReal(getMinRectY(), getMaxRectY());
        }
        Jass::CreateUnit(Jass::Player(Jass::GetPlayerNeutralPassive()), 'h01F', x, y, 0.0);
        TainiksCounter += 1;
    }

    GlibasCounter = 0;
    for (int i = 0; i < 48; i++) {
        if (glibaPointCount > 0) {
            random = Jass::GetRandomInt(0, glibaPointCount - 1);
            x = GetRandomGlibaPlaceX(random);
            y = GetRandomGlibaPlaceY(random);
        } else {
            x = Jass::GetRandomReal(getMinRectX(), getMaxRectX());
            y = Jass::GetRandomReal(getMinRectY(), getMaxRectY());
        }
        Jass::CreateUnit(Jass::Player(Jass::GetPlayerNeutralPassive()), 'h008', x, y, 0.0);
        GlibasCounter += 1;
    }
}

void TestAllPoints() {
    timer t = Jass::CreateTimer();
    int h = Jass::GetHandleId(t);
    Jass::SaveReal(SkillHT, h, 0, getMinRectX());
    Jass::SaveReal(SkillHT, h, 1, getMinRectY());
    Jass::TimerStart(t, 0.001, true, function() {
        timer t = Jass::GetExpiredTimer();
        int h = Jass::GetHandleId(t);
        textfilehandle file = Jass::TextFileOpen("points.txt");
        float x = Jass::LoadReal(SkillHT, h, 0);
        float y = Jass::LoadReal(SkillHT, h, 1);
        Jass::SaveReal(SkillHT, h, 0, x + 128);
        if (x + 128 >= getMaxRectX()) {
            Jass::SaveReal(SkillHT, h, 0, getMinRectX());
            Jass::SaveReal(SkillHT, h, 1, y + 128);
        }
        if (y + 128 >= getMaxRectY()) {
            Jass::DestroyTimer(t);
        }
        if (IsPlaceableAtById(x, y)) {
            Jass::TextFileWriteLine(file, "Placeable at x: " + x + " y: " + y);
            Debug("TestAllPoints", "\nPlaceable at x: " + x + " y: " + y);
        }
        Jass::TextFileClose(file);
    });
    
}

void InitHungerSystem() {
    timer t = Jass::CreateTimer();
    Jass::TimerStart(t, 15.0, true, function() {
        for(int i = 0; i <= 9; i++) {
            if(GoblinUnit[i] != nil && GameStarted) {
                food = Jass::GetPlayerState(Jass::GetOwningPlayer(GoblinUnit[i]), Jass::PLAYER_STATE_RESOURCE_LUMBER);
                if(food <= 0) {
                    Jass::SetUnitCurrentLife(GoblinUnit[i], Jass::GetUnitCurrentLife(GoblinUnit[i]) - Jass::GetUnitMaxLife(GoblinUnit[i]) * 0.25);
                    Jass::SetUnitCurrentMana(GoblinUnit[i], Jass::GetUnitCurrentMana(GoblinUnit[i]) - Jass::GetUnitMaxMana(GoblinUnit[i]) * 0.25);
                } else {
                        UnitStatsData Stats;
                        Stats.Reset();
                        Stats.strength = 20*(Jass::GetHeroLevel(u)/10+1);
                        Stats.agility = 20*(Jass::GetHeroLevel(u)/10+1);
                        Stats.intelligence = 20*(Jass::GetHeroLevel(u)/10+1);
                        Buff@ Buff = Buff("Сытость", "+20 к всем статам за уровень.",
                            "ReplaceableTextures\\CommandButtons\\BTNDevour.blp.blp",
                            'td01', 20.0, Stats, false, PURGE_NONE, 1, 0, true);
                        ud.AddBuff(Buff, u);
                }
                Jass::SetPlayerState(Jass::GetOwningPlayer(GoblinUnit[i]), Jass::PLAYER_STATE_RESOURCE_LUMBER, Jass::GetPlayerState(Jass::GetOwningPlayer(GoblinUnit[i]), Jass::PLAYER_STATE_RESOURCE_LUMBER) - 1);
            }
        }
    });
}

player FirstPlayer = nil;

void GameStart() {
    Debug("GameStart", "GameStart begin");

    MapVersion[0] = 300;
    MapVersion[1] = 310;
    Jass::LoadTOCFile("war3mapImported\\SkillCharge.toc");

    Jass::DestroyTimer(Jass::GetExpiredTimer());
    InitArrayValues();
    Start_Texts_Init();



    for(uint i = 0; i < g_VK.length(); i++){
        Jass::ShowUnit(g_VK[i], false);
    }

    Jass::EnableOperationLimit(false);

    Jass::AntiHackEnable(true);
    Jass::AntiHackEnableModuleCheck(true);
    Jass::AntiHackEnableAddressCheck(true);
    Jass::AntiHackEnableBreakpointCheck(true);
    Jass::AntiHackEnableProcessCheck(true);

    Jass::SetMoveSpeedMaxAllowed(800);
    Jass::SetMoveSpeedMinAllowed(0);



    //TimerStart(udg_Bridge_1_Timer, GetRandomReal(120.00, 360.00), false, null) 
    // TODO Надо сделать спавн мостов.
    // TriggerExecute(gg_trg_Admin_rights) Admin Rights
    
    


    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Молитва Гобу", g_strmsg[0], "ReplaceableTextures\\CommandButtons\\BTNStormEarth&Fire.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Уровни персонажей и скиллов", g_strmsg[1], "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Бонусы от количества игроков", g_strmsg[2], "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Удача", g_strmsg[3], "BTNClover.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Команды для хоста", g_strmsg[5], "ReplaceableTextures\\CommandButtons\\BTNSpy.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Команды для всех", g_strmsg[6], "ReplaceableTextures\\CommandButtons\\BTNSpy.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Goblin Workshop", g_strmsg[7], "ReplaceableTextures\\CommandButtons\\BTNBlacksmith.blp" );
    CreateQuestBJ( QUESTTYPE_OPT_DISCOVERED, "Записка из лагеря", g_strmsg[9], "ReplaceableTextures\\CommandButtons\\BTNScroll.blp" );
    



    mapInitialPlayableArea = Jass::Rect(Jass::GetCameraBoundMinX()-Jass::GetCameraMargin(CAMERA_MARGIN_LEFT), Jass::GetCameraBoundMinY()-Jass::GetCameraMargin(CAMERA_MARGIN_BOTTOM), Jass::GetCameraBoundMaxX()+Jass::GetCameraMargin(CAMERA_MARGIN_RIGHT), Jass::GetCameraBoundMaxY()+Jass::GetCameraMargin(CAMERA_MARGIN_TOP));
    Debug("GameStart", "Map bounds prepared");
    if(TestDebugMode) Jass::ConsoleEnable(true);
    PlayerForces = Jass::CreateForce();
    EnemiesForce = Jass::CreateForce();
    FirstPlayer = nil;
    for(uint i = 0; i <= 9; i++){
        if ((Jass::GetPlayerController(Jass::Player(i)) == Jass::MAP_CONTROL_USER and Jass::GetPlayerSlotState(Jass::Player(i)) == Jass::PLAYER_SLOT_STATE_PLAYING)) {
            Jass::ForceAddPlayer(PlayerForces, Jass::Player(i));
            if (FirstPlayer == nil) FirstPlayer = Jass::Player(i);
        }
    }
    Admin_Player = FirstPlayer;
    Debug("GameStart", "Admin player=" + ((Admin_Player != nil) ? Jass::GetPlayerName(Admin_Player) : "nil"));
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(10));
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(11));
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(13));
    Jass::SetBuffBaseRealArrayFieldById('BHad', Jass::ABILITY_RLF_ARMOR_BONUS_HAD1, 0, 0);
    Jass::SetBuffBaseRealArrayFieldById('BUim', Jass::ABILITY_RLF_DAMAGE_DEALT_UIM3, 0, 0.);
    Jass::SetBuffBaseRealArrayFieldById('BNht', Jass::ABILITY_RLF_DATA_FIELD_A, 0, 0.);
    Jass::SetMapFlag(Jass::MAP_LOCK_RESOURCE_TRADING, true);


    fogmodifier fogm;
    fogm = Jass::CreateFogModifierRect(Jass::Player(10), Jass::FOG_OF_WAR_VISIBLE, mapInitialPlayableArea, true, false);
    Jass::FogModifierStart(fogm);
    fogm = Jass::CreateFogModifierRect(Jass::Player(11), Jass::FOG_OF_WAR_VISIBLE, mapInitialPlayableArea, true, false);
    Jass::FogModifierStart(fogm);
    Jass::ForForce(PlayerForces, function() {
        fogmodifier fogm;
        fogm = Jass::CreateFogModifierRect(Jass::GetEnumPlayer(), Jass::FOG_OF_WAR_VISIBLE, Jass::GetWorldBounds(), false, false);
        Jass::FogModifierStart(fogm);
        Jass::FogModifierStop(fogm);
        fogm = nil;
    });
    fogm = nil;
    Jass::SetCreepCampFilterState(false);
    Jass::EnableMinimapFilterButtons(true, false);

    SetPlayerAllianceState( Jass::Player(10), Jass::Player(13), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(11), Jass::Player(13), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(13), Jass::Player(10), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(13), Jass::Player(11), ALLIANCE_ALLIED );
    
    Jass::SetTimeOfDayScale( 0.00 );
    Jass::SetFloatGameState(Jass::GAME_STATE_TIME_OF_DAY, 0.00);
    Jass::SuspendTimeOfDay(true);
    Jass::CameraSetSmoothingFactor(1.);

    //TestAllPoints();

    


    for(uint i = 0; i < 10; i ++){
        if(Jass::IsPlayerInForce(Jass::Player(i), PlayerForces)){
            g_ready_players += 1;
            Jass::SetPlayerState( Jass::Player(i), Jass::ConvertPlayerState(2), 100 );
            Jass::UnitShareVision( g_VisionGiver[0], Jass::Player(i), true );
            Jass::UnitShareVision( g_VisionGiver[1], Jass::Player(i), true );
            Jass::UnitShareVision( g_VisionGiver[2], Jass::Player(i), true );
            Jass::UnitShareVision( g_VisionGiver[3], Jass::Player(i), true );
            Jass::UnitShareVision( g_VisionGiver[4], Jass::Player(i), true );
            if (Jass::GetLocalPlayer() == Jass::Player(i)) {
                Jass::PanCameraToTimed(-6529.1, 6851.9, 1.);
            }
        } else {
            Jass::RemoveUnit(g_HeroTaker2[i]);
            Jass::RemoveUnit(g_HeroTaker[i]);
        }
    }

    Debug("GameStart", "Init step: SG_InitStartTimer");
    SG_InitStartTimer();
    Debug("GameStart", "Init step: InitBaseStats");
    InitBaseStats();
    Debug("GameStart", "Init step: InitItemTemplates");
    InitItemTemplates();
    Debug("GameStart", "Init step: InitItemDescriptions");
    InitItemDescriptions();
    Debug("GameStart", "Init step: InitItemTriggers");
    InitItemTriggers();
    Debug("GameStart", "Init step: InitSpawnTrigger");
    InitSpawnTrigger();
    Debug("GameStart", "Init step: InitSaveSystem");
    InitSaveSystem();
    Debug("GameStart", "Init step: InitDeathSystem");
    InitDeathSystem();
    Debug("GameStart", "Init step: InitAbilityCastSystem");
    InitAbilityCastSystem();
    Debug("GameStart", "Init step: InitDamageSystem");
    InitDamageSystem();
    Debug("GameStart", "Init step: SpawnInitResources");
    SpawnInitResources();
    Debug("GameStart", "Init step: InitGameCommandsAS");
    InitGameCommandsAS();
    Debug("GameStart", "Init step: InitLeaverOutOfListAS");
    InitLeaverOutOfListAS();
    Debug("GameStart", "Init step: InitPortalPath");
    InitPortalPath();
    Debug("GameStart", "Init step: InitWaveSystemAS");
    InitWaveSystemAS();
    Debug("GameStart", "Init step: InitMainMultiboardSystem");
    InitMainMultiboardSystem();
    Debug("GameStart", "Init step: InitCraftingSystem");
    InitCraftingSystem();
    Debug("GameStart", "Init step: InitBuffSystem");
    InitBuffSystem();
    Debug("GameStart", "Init step: InitCraftingSystemFrame");
    InitCraftingSystemFrame();
    Debug("GameStart", "Init step: InitUnitStatsFrame");
    InitUnitStatsFrame();
    Debug("GameStart", "Init step: HungerSystemInit");
    InitHungerSystem();
    if(TestDebugMode) {
        Debug("GameStart", "Init step: InitCheats");
        InitCheats();
    }
    Debug("GameStart", "\nGameStartCompleted");
}

void MainPart() {
    Debug("MainPart", "MainPart timer scheduled");
    Jass::TimerStart(Jass::CreateTimer(), 0.1, false, @GameStart ) ;
}
